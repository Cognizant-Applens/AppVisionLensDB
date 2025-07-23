CREATE PROCEDURE [ML].[CL_JobToExportTickets]       
AS      
BEGIN      
SET NOCOUNT ON;      
BEGIN TRY      
BEGIN TRAN      
DECLARE @JBDate datetime,      
  @Month int,@startdatetemp int,      
  @CreatedBy nvarchar(150),      
  @minCount BIGINT,      
  @maxCount BIGINT,      
  @i BIGINT,      
  @ValidDescriptionCount int,      
  @ValidDetailDescriptionCount int,      
  @ValidMLCLDescriptionCount int,      
  @ProjectID BIGINT,      
  @countforjob INT,      
  @monthforjob INT,      
  @STARTDATE DATETIME,      
  @EndDate DATETIME,      
  @IsNoiseSkipAndContinue BIT,      
  @PresenceOfOptional BIT,      
  @CountforOptionalField INT,    
  @OptFieldID INT,       
  @countforoptnull INT,      
  @TotalTickets DECIMAL(18, 2),      
  @ValidDebtFields DECIMAL(18, 2),      
  @ValidTicketDebtFieldsPercent DECIMAL(18, 2),       
  @IsConditionMetForDebtFields NVARCHAR(10),      
  @FromDate DateTime,      
  @ToDate DateTime,      
  @IsMultilingualDescription INT,    
  @InitialId BIGINT;      
      
      
CREATE TABLE #TempForJob      
(      
 [TimeTickerID] [bigint] ,      
 [TicketID] [nvarchar](50) ,      
 [ProjectID] [bigint],      
 [ApplicationID] [bigint] ,      
 [DebtClassificationID] [bigint] ,      
 [AvoidableFlagID] [bigint],      
 [ResidualDebtID] [bigint],      
 [CauseCodeID] [bigint] ,      
 [ResolutionCodeID] [bigint] ,      
 ClosedDate [datetime],    
 CompletedDate [datetime],    
 DARTStatusID [int],      
 IsSDTicket [bit],      
 IsMultilingualEnabled int,      
 TicketFrom varchar(50),      
 [TicketDescription] [nvarchar](max) ,      
 AdditionalText nvarchar(max),      
 OptionalFieldID int,    
 Desc_Base_WorkPattern NVARCHAR(500),    
 Desc_Sub_WorkPattern NVARCHAR(500),    
 Res_Base_WorkPattern NVARCHAR(500),    
 Res_Sub_WorkPattern NVARCHAR(500),    
 IsTicketDescOpt BIT    
)      
    
CREATE TABLE #ProjectTableDetails      
 (      
    PID BIGINT IDENTITY(1,1),      
    ProjectID BIGINT null,      
    TicketDescription CHAR null,      
    Ticketsufficient CHAR null,      
    DebtFieldsSufficient CHAR NULL,      
    STARTDATE DATETIME,      
    EndDate DATETIME,    
 IsTicketDescOpt BIT    
 )       
      
CREATE TABLE  #projtempfile      
(      
 ProjectName NVARCHAR(1000),      
 ContLearningId BIGINT,      
 ProjectID BIGINT,      
)       
      
UPDATE ML.CL_ProjectJobDetails SET StatusForJob = 1, IsDeleted = 1       
WHERE DATEDIFF(DAY,JOBDATE,GETDATE())<>0 and CONVERT(DATE, JOBDATE) < CONVERT(DATE,GETDATE())        
      
     
INSERT INTO #ProjectTableDetails(ProjectID,STARTDATE,EndDate,IsTicketDescOpt)      
SELECT DISTINCT PM.ProjectID,PD.MLSignOffDate,PJD.JobDate,CP.IsTicketDescriptionOpted     
FROM AVL.MAS_ProjectMaster(NOLOCK) PM    
JOIN ML.ConfigurationProgress(NOLOCK) CP    
ON PM.ProjectID = CP.ProjectID     
 AND CP.IsDeleted = 0 AND PM.IsDeleted = 0    
JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PD     
ON CP.ProjectID= PD.ProjectID      
 AND PD.IsDeleted = 0    
JOIN ML.CL_ProjectJobDetails(NOLOCK) PJD    
ON PD.ProjectID = PJD.ProjectID AND PD.IsMLSignOff = '1' AND PD.MLSignOffDate IS NOT NULL  AND PJD.StatusForJob=0  AND PJD.IsDeleted = 0    
JOIN ML.TRN_MLTransaction MLTRN ON MLTRN.ProjectId = PJD.ProjectID AND MLTRN.ISActiveTransaction =1 AND MLTRN.AlgorithmKey = 'AL001' AND MLTRN.SupportTypeId = 1  
WHERE DATEDIFF(DAY,PJD.JobDate,GETDATE())=0    
 AND CAST(PJD.JobDate AS DATE) >= CAST(PD.MLSignOffDate AS DATE)      
      
      
SET @minCount= (SELECT MIN(PID) FROM #ProjectTableDetails)      
SET @maxCount= (SELECT MAX(PID) FROM #ProjectTableDetails)      
SET @i = @minCount;      
      
WHILE(@i<=@maxCount)      
BEGIN              
     
      
 SET @ProjectID = (SELECT ProjectID FROM #ProjectTableDetails  WHERE PID=@i)      
 SET @countforjob=(SELECT COUNT(ProjectID) FROM ML.CL_ProjectJobDetails WITH(NOLOCK) WHERE ProjectID=@ProjectID)      
 SET @IsMultilingualDescription = (SELECT       
           CASE WHEN ISNULL(IsMultilingualEnabled,0) = 1 AND ((SELECT AVL.CheckIfMultilingualColumnsActiveOrNot(@ProjectID ,1,1)) = 1)      
            THEN 1      
            ELSE 0      
          END AS IsMultilingualDescription FROM AVL.MAS_ProjectMaster WHERE ProjectID = @ProjectID AND IsDeleted = 0)       
      
 IF(@countforjob >= 1)      
 BEGIN      
 --//check if any run job were successful      
  IF NOT EXISTS(SELECT ProjectID,PresentStatus FROM ML.CL_PRJ_ContLearningState WITH(NOLOCK) WHERE ProjectID=@ProjectID and PresentStatus=4)      
  BEGIN           
   /*No jobs were sucessfully completed. so run from ML sign off date to current job date*/      
   SET @STARTDATE=(SELECT MLSignOffDate FROM AVL.MAS_ProjectDebtDetails WITH(NOLOCK) WHERE ProjectID=@ProjectID)                  
  END      
  ELSE      
  BEGIN      
   SET @STARTDATE=(SELECT TOP(1) CONVERT(DATE,CreatedDate) FROM ML.CL_PRJ_ContLearningState WITH(NOLOCK) WHERE ProjectID=@ProjectID AND PresentStatus=4 ORDER BY CreatedDate DESC)                         
  END           
  UPDATE  #ProjectTableDetails SET STARTDATE=@STARTDATE WHERE PID=@i      
 END     
 SET @EndDate = (SELECT EndDate FROM #ProjectTableDetails WHERE PID=@i)    
    
 UPDATE        
 ML.CL_ProjectJobDetails       
 SET       
 StartDateTime=@STARTDATE,      
 EndDateTime=@EndDate,      
 ModifiedBy='SYSTEM',      
 ModifiedDate=GETDATE()       
 WHERE       
 DATEDIFF(DAY,JOBDATE,GETDATE())=0       
 AND         
 StatusForJob=0        
 AND       
 ProjectID=@ProjectID      
      
 UPDATE  C       
 SET IsDeleted = 1      
 FROM ML.CL_PRJ_ContLearningState C       
 WHERE ProjectID = @ProjectID      
      
 INSERT INTO ML.CL_PRJ_ContLearningState    
  (projectid,      
   IsSDTicket,      
   ISDartTicket,      
   CreatedBy,      
   CreatedDate,      
   IsDeleted,      
   ProjectJobID,      
   PresentStatus)       
  VALUES      
   (@ProjectID,      
  1,      
  1,      
   'System',    
   Getdate(),      
   0,      
   (SELECT       
  TOP 1 ID       
   FROM        
  ML.CL_ProjectJobDetails WITH(NOLOCK)      
   WHERE       
  ProjectID=@ProjectID       
   AND       
  StatusForJob=0      
   ),      
   0);     
    
 INSERT INTO #TempForJob      
 SELECT DISTINCT        
  TD.TimeTickerID,       
  TD.TicketID,      
  TD.ProjectID,       
  TD.ApplicationID,      
  TD.[DebtClassificationMapID] AS DebtClassificationID,       
  TD.AvoidableFlag As [AvoidableFlagID],       
  TD.[ResidualDebtMapID] AS [ResidualDebtID],      
  TD.[CauseCodeMapID] AS CauseCodeID,      
  TD.[ResolutionCodeMapID] AS ResolutionCodeID,      
  TD.ClosedDate,    
  TD.CompletedDateTime,    
  TD.DARTStatusID,      
  TD.[IsSDTicket],       
  PM.IsMultilingualEnabled,       
  CASE WHEN MBD.TicketID IS NOT NULL      
    THEN 'ML'      
   ELSE 'TD'      
  END AS TicketFrom,      
  CASE WHEN ISNULL(PM.IsMultilingualEnabled,0) = 0 OR ((SELECT AVL.CheckIfMultilingualColumnsActiveOrNot(PM.ProjectID ,1,0)) = 1)      
    THEN TD.TicketDescription      
   WHEN PM.IsMultilingualEnabled = 1 AND ((SELECT AVL.CheckIfMultilingualColumnsActiveOrNot(PM.ProjectID ,1,1)) = 1) AND TTD.IsTicketDescriptionUpdated = 0      
    THEN TTD.TicketDescription      
  END AS TicketDescription,      
  CASE WHEN OPM.IsOptionalField = 1 THEN    
  CASE WHEN ISNULL(PM.IsMultilingualEnabled,0) = 0 OR ((SELECT AVL.CheckIfMultilingualColumnsActiveOrNot(PM.ProjectID ,3,0)) = 1)      
   THEN TD.ResolutionRemarks      
   WHEN PM.IsMultilingualEnabled = 1 AND ((SELECT AVL.CheckIfMultilingualColumnsActiveOrNot(PM.ProjectID ,3,1)) = 1) AND TTD.IsResolutionRemarksUpdated = 0      
   THEN TTD.ResolutionRemarks      
  END    
  ELSE NULL      
    END AS AdditionalText,    
  OPM.IsOptionalField,       
  CASE WHEN TD.TicketDescriptionBasePattern = '' OR TD.TicketDescriptionBasePattern IS NULL    
    THEN '0'    
   ELSE TD.TicketDescriptionBasePattern    
  END AS Desc_Base_WorkPattern,    
 CASE WHEN TD.TicketDescriptionSubPattern = '' OR TD.TicketDescriptionSubPattern IS NULL    
   THEN '0'    
  ELSE TD.TicketDescriptionSubPattern    
  END AS Desc_Sub_WorkPattern,    
  CASE WHEN OPM.IsOptionalField = 1 THEN    
   CASE WHEN TD.ResolutionRemarksBasePattern = '' OR TD.ResolutionRemarksBasePattern IS NULL    
    THEN '0'    
   ELSE TD.ResolutionRemarksBasePattern    
   END    
 ELSE '0'    
 END AS Res_Base_WorkPattern,    
 CASE WHEN OPM.IsOptionalField = 1 THEN    
   CASE WHEN TD.ResolutionRemarksSubPattern = '' OR TD.ResolutionRemarksSubPattern IS NULL    
    THEN '0'    
   ELSE TD.ResolutionRemarksSubPattern    
   END    
 ELSE '0'    
 END AS Res_Sub_WorkPattern,    
  OPM.IsTicketDescriptionOpted    
 FROM #ProjectTableDetails PTD    
 JOIN [AVL].[TK_TRN_TicketDetail] TD WITH(NOLOCK) ON PTD.ProjectID = TD.ProjectID AND TD.IsDeleted = 0    
 JOIN [AVL].TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TTM.TicketTypeMappingID = TD.TicketTypeMapID  AND TTM.IsDeleted = 0       
 JOIN [AVL].[APP_MAS_ApplicationDetails](NOLOCK) AD ON AD.ApplicationID = TD.ApplicationID AND AD.IsActive = 1     
 JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.ProjectID = TD.ProjectID AND PM.IsDeleted = 0      
 JOIN [AVL].[Customer](NOLOCK) C ON C.CustomerID = PM.CustomerID AND C.IsDeleted = 0       
 JOIN [ML].[ConfigurationProgress](NOLOCK) OPM ON OPM.ProjectID = PM.ProjectID AND OPM.IsDeleted = 0    
 LEFT JOIN [AVL].[PRJ_MultilingualColumnMapping](NOLOCK) PCM ON OPM.IsTicketDescriptionOpted = 1 AND PCM.ProjectID = PM.ProjectID AND PCM.IsActive = 1      
 LEFT JOIN [AVL].[TK_TRN_Multilingual_TranslatedTicketDetails](NOLOCK) TTD ON OPM.IsTicketDescriptionOpted = 1 AND  TTD.TimeTickerID = TD.TimeTickerID AND TTD.Isdeleted = 0      
 LEFT JOIN [ML].[BaseDetails](NOLOCK) MBD ON MBD.TicketID = TD.TicketID AND TD.ProjectID=MBD.ProjectID AND MBD.Isdeleted = 0     
 AND  (OPM.IsTicketDescriptionOpted = 1 AND MBD.TicketDescriptionPattern IS NULL OR MBD.TicketDescriptionPattern ='')    
 WHERE        
 (TD.DebtClassificationMode IN(4,5)) AND    
 ((OPM.IsTicketDescriptionOpted = 1 AND TD.TicketDescription IS NOT NULL AND TD.TicketDescription <> '')    
 OR (OPM.IsTicketDescriptionOpted = 0 AND TD.TicketDescriptionBasePattern IS NOT NULL AND TD.TicketDescriptionBasePattern <> '0'))    
 AND ((TD.DARTStatusID = 8 AND TD.Closeddate BETWEEN  PTD.STARTDATE AND PTD.EndDate) OR    
 (TD.DARTStatusID = 9 AND TD.CompletedDateTime BETWEEN PTD.STARTDATE AND PTD.EndDate))    
 AND ((C.IsCognizant = 1 AND TD.ServiceID IN (1,4,5,6,7,8,10)) OR (C.IsCognizant = 0 AND TTM.DebtConsidered ='Y'))        
 AND ISNULL(TD.CauseCodeMapID,0) <> 0 AND ISNULL(TD.ResolutionCodeMapID,0) <> 0        
    AND PM.ProjectID = @ProjectID    
     
  DECLARE @ticketCount BIGINT,      
     @IsMLRegenerateProgress char,      
     @JobStatus BIGINT,      
     @IsConditionMetForTDesc NVARCHAR(10),      
     @ValidTicketDescPercent DECIMAL(18,2),      
     @IsTranslateTicketDescription INT;      
  SET @JobStatus = NULL      
  --Condition to check the debt 80% in tickets          
  --Condition 1: Check Ticket Descriptio 80% accuracy      
   --DELETE FROM #TempForJob WHERE ProjectID = @ProjectID AND TicketFrom = 'TD' AND (ClosedDate < @STARTDATE OR ClosedDate > @EndDate)      
   IF @JobStatus IS NULL      
   BEGIN      
       
     SET @ticketCount = (SELECT COUNT(TicketID) FROM #TempForJob WHERE ProjectID = @ProjectID AND        
      TicketFrom = 'TD' OR TicketFrom = 'ML')      
      
    IF @ticketCount = 0      
    BEGIN      
      
    SET @JobStatus = 1      
      
    END      
      
    ELSE IF @ticketCount > 0      
    BEGIN      
      
     SET @ValidDetailDescriptionCount = (SELECT COUNT(ProjectID) FROM  #TempForJob WHERE ProjectID=@ProjectID      
      AND ((IsTicketDescOpt = 1 AND ISNULL(TicketDescription,'') <>'' AND TicketDescription<>'TicketDescription'      
      AND TicketFrom = 'TD')    
      OR (IsTicketDescOpt = 0 AND ISNULL(Desc_Base_WorkPattern,'') <>'' AND Desc_Base_WorkPattern<>'0'      
      AND TicketFrom = 'TD')));      
      
    SET @ValidMLCLDescriptionCount = (SELECT COUNT(ProjectID) FROM  #TempForJob WHERE ProjectID=@ProjectID      
    AND ((IsTicketDescOpt = 1 AND ISNULL(TicketDescription,'') <>'' AND TicketDescription<>'TicketDescription'      
      AND TicketFrom = 'ML')    
      OR (IsTicketDescOpt = 0 AND ISNULL(Desc_Base_WorkPattern,'') <>'' AND Desc_Base_WorkPattern<>'0'      
      AND TicketFrom = 'ML')));      
      
     SET @ValidDescriptionCount = @ValidDetailDescriptionCount + @ValidMLCLDescriptionCount;      
      
     SET @ValidTicketDescPercent = ( ( CAST (@ValidDescriptionCount AS DECIMAL)/  CAST (@ticketCount AS DECIMAL))  * 100 );       
      
     UPDATE T       
     SET TicketDescription = CASE WHEN @ValidTicketDescPercent >= 80 AND @ValidDetailDescriptionCount > 0       
           THEN 'Y' ELSE 'N' END      
    FROM #ProjectTableDetails T      
    WHERE       
    projectId=@ProjectID      
        
     END      
        
    IF @JobStatus IS NULL AND @ticketCount>=10      
    BEGIN      
      
    IF @ValidTicketDescPercent < 80 OR @ValidDetailDescriptionCount = 0     
    BEGIN      
     IF(@IsMultilingualDescription = 1)      
     BEGIN       
   SET @JobStatus = 7;      
     END      
     ELSE      
     BEGIN      
   SET @JobStatus = 2;      
     END      
    END      
    ELSE      
    BEGIN      
    UPDATE #ProjectTableDetails SET Ticketsufficient='Y' WHERE ProjectID=@ProjectID      
     
         
       SET @ValidDebtFields=(SELECT COUNT(DISTINCT T.TicketID)       
             FROM   #TempForJob(NOLOCK) T       
                                                   
             WHERE  T.ProjectID = @ProjectID       
              AND DebtClassificationId IS NOT NULL       
              AND AvoidableFlagID IS NOT NULL       
              AND CauseCodeID IS NOT NULL       
          AND ResolutionCodeID IS NOT NULL       
              AND ResidualDebtId IS NOT NULL)       
      
                   
      
       SET @ValidTicketDebtFieldsPercent= ( ( CAST(@ValidDebtFields AS DECIMAL) / CAST (@ticketCount AS DECIMAL) ) * 100 );       
        
     UPDATE T       
     SET DebtFieldsSufficient = CASE WHEN @ValidTicketDebtFieldsPercent >= 80        
           THEN 'Y' ELSE 'N' END      
     FROM  #ProjectTableDetails T      
   WHERE       
   projectId=@ProjectID;      
          
    IF @ValidTicketDebtFieldsPercent < 80       
     BEGIN      
     SET @JobStatus = 8;      
     END      
    END      
    END      
    ELSE      
    BEGIN      
         
     SET @JobStatus = 1;         
      
     UPDATE      
   #ProjectTableDetails       
   SET       
   Ticketsufficient='N'       
   WHERE       
   projectId=@ProjectID;      
    END      
   END      
      
   IF(@JobStatus IS NOT NULL)      
   BEGIN      
   UPDATE  ML.CL_PRJ_ContLearningState SET PresentStatus=@JobStatus,ModifiedBy='SYSTEM',ModifiedDate=GETDATE()       
      
    WHERE ProjectID=@ProjectID AND IsDeleted=0;      
    SELECT @JBDate =JobDate FROM ML.CL_ProjectJobDetails WITH(NOLOCK) WHERE ProjectID=@ProjectID AND (ISNULL(IsDeleted,0)= 0)       
    DECLARE @NextDayID INT = 5      
    SET @JBDate= DATEADD(DAY, (DATEDIFF(DAY, @NextDayID, GETDATE()) / 7) * 7 + 7, @NextDayID)       
      
    INSERT  INTO ML.CL_ProjectJobDetails      
    ([ProjectID],      
    [JobDate],      
    [StartDateTime],      
    [StatusForJob],      
    [CreatedBy],      
    [CreatedDate],      
    [IsDeleted])       
    SELECT       
    TOP 1    
     ProjectID,      
     @JBDate,      
     StartDateTime,      
     0,      
     'SYSTEM',      
     GETDATE(),      
     0       
    FROM       
     ML.CL_ProjectJobDetails WITH(NOLOCK)      
    WHERE       
     CAST(JobDate AS DATE) = CAST(GETDATE() AS DATE)       
    AND       
     ISNULL(IsDeleted,0)=0      
    AND       
     ProjectID=@ProjectID      
      
    UPDATE       
     ML.CL_ProjectJobDetails       
    SET       
     StatusForJob=1,      
     HasError=1 ,      
     IsDeleted=1,      
     ModifiedBy='SYSTEM',      
     ModifiedDate=GETDATE()       
    WHERE       
     ProjectID=@ProjectID       
    AND       
     ISNULL(IsDeleted,0)=0      
     AND       
     CAST(JobDate AS DATE) = CAST(GETDATE() AS DATE) ;      
      
    UPDATE       
     AVL.MAS_ProjectDebtDetails       
    SET       
     ISCLSIGNOFF=0,    
     ModifiedBy='SYSTEM',      
     ModifiedDate=GETDATE()      
    WHERE      
   ProjectID=@ProjectID       
    AND       
     ISCLSIGNOFF=1;      
   END       
  SET @i=@i+1;      
 END      
       
      
SELECT       
 PID,    
    ProjectID,      
 TicketDescription,      
 Ticketsufficient,      
 DebtFieldsSufficient,      
 STARTDATE,      
 EndDate,    
 IsTicketDescOpt INTO #tempproj FROM #ProjectTableDetails;      
       
DELETE  FROM #tempproj WHERE  TicketDescription='N' OR Ticketsufficient='N' OR DebtFieldsSufficient = 'N'    
DELETE FROM #ProjectTableDetails      
    
INSERT       
INTO       
 #ProjectTableDetails       
SELECT     
    ProjectID,      
    TicketDescription,      
    Ticketsufficient,      
    DebtFieldsSufficient,      
    STARTDATE,      
    EndDate,    
 IsTicketDescOpt BIT      
FROM       
 #tempproj;      
      
      
DECLARE @loopstartinsert BIGINT;      
DECLARE @loopendinsert BIGINT;      
SET @loopstartinsert= (SELECT MIN(PID) FROM #ProjectTableDetails)      
SET @loopendinsert= (SELECT MAX(PID) FROM #ProjectTableDetails)      
       
      
DECLARE @j bigint=@loopstartinsert;      
--Delete the old values      
DELETE V     
FROM ML.CL_TRN_TicketValidation  V       
INNER JOIN #TempForJob T ON T.ProjectID = V.ProjectID AND V.TicketID = T.TicketID      
      
WHILE(@j<=@loopendinsert)      
BEGIN      
 DECLARE @ProjectID1 BIGINT;      
 SET @FromDate=(SELECT STARTDATE FROM #ProjectTableDetails WHERE PID=@j )      
 SET @ToDate=(SELECT EndDate FROM #ProjectTableDetails WHERE PID=@j )      
 SET @ProjectID1 = (SELECT ProjectID FROM #ProjectTableDetails WHERE PID=@j)      
       
       
 INSERT       
 INTO       
  ML.CL_TRN_TicketValidation      
  (ProjectID,      
  TicketID,      
  TicketDescription,      
  ApplicationID,      
  DebtClassificationID,      
 AvoidableFlagID,      
  ResidualDebtID,      
  CauseCodeID,      
  ResolutionCodeID,      
  OptionalFieldProj,      
  CreatedBy,      
  CreatedDate,      
  IsDeleted,    
  TicketDescriptionBasePattern,    
  TicketDescriptionSubPattern,    
  ResolutionRemarksBasePattern,    
  ResolutionRemarksSubPattern)      
 SELECT      
   ProjectID,      
   TicketID,       
   TicketDescription,       
   ApplicationID,        
   DebtClassificationID,       
   AvoidableFlagID,        
   [ResidualDebtID],       
   CauseCodeID,       
   ResolutionCodeID,      
   AdditionalText,      
   'SYSTEM',      
   GETDATE(),      
   0,    
   Desc_Base_WorkPattern,    
   Desc_Sub_WorkPattern,    
   Res_Base_WorkPattern,    
   Res_Sub_WorkPattern    
 FROM       
  #TempForJob(NOLOCK)       
 WHERE       
  ProjectID=@ProjectID1       
 AND       
  ((DARTStatusID = 8 AND ClosedDate BETWEEN @FromDate AND @ToDate)     
  OR (DARTStatusID = 9 AND CompletedDate BETWEEN @FromDate AND @ToDate))    
 AND        
  [IsSDTicket]       
  IN       
  (1,0)       
     
        
DECLARE @BUName VARCHAR(1000);      
DECLARE @DepartmentID VARCHAR(MAX);      
DECLARE @AccountName VARCHAR(MAX);      
DECLARE @ProjectName VARCHAR(MAX);      
DECLARE @ContLearningId INT;      
      
SELECT      
  @ContLearningId=ContLearningID,       
  @ProjectName=PM.ProjectName,      
  @AccountName=Cust.CustomerName,      
  @BUName=BU.BUName       
FROM      
  ML.CL_PRJ_ContLearningState(NOLOCK) Cont       
JOIN       
 [AVL].[MAS_ProjectMaster](NOLOCK) PM       
ON        
 Cont.Projectid=PM.ProjectID       
JOIN      
  [AVL].[Customer](NOLOCK) Cust       
ON       
 PM.CustomerID=Cust.CustomerID       
JOIN       
 [AVL].[BusinessUnit](NOLOCK) BU       
ON       
 BU.BUID=Cust.BUID       
WHERE       
 Cont.IsDeleted=0       
AND       
 PM.Isdeleted=0       
AND       
 Cust.IsDeleted=0       
AND       
 BU.Isdeleted=0       
AND      
  PM.ProjectID=@ProjectID1      
      
      
DECLARE @Prjtext nvarchar(128) = @ProjectName      
SET @ProjectName = (SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(      
       REPLACE(REPLACE(REPLACE(REPLACE(@Prjtext,      
        '-',''),'@',''),'#',''),'$',''),'/',''),      
        ',',''),'.',''),'*',''),'%',''))      
            
   
      
INSERT       
INTO      
  #projtempfile      
   (      
   ProjectName,      
   ContLearningId,      
   ProjectID      
    )      
SELECT       
 REPLACE(@ProjectName,' ','_') ,      
 @ContLearningId,@ProjectID1      
      
SET @j=@j+1;      
END      
      
      
      
UPDATE        
  C      
SET       
 PresentStatus=3,      
 ModifiedBy='SYSTEM',      
 ModifiedDate=GETDATE()       
 FROM ML.CL_PRJ_ContLearningState C      
 INNER JOIN #ProjectTableDetails P ON P.ProjectID = C.ProjectID       
WHERE      
       
 IsDeleted=0       
AND       
 (PresentStatus NOT IN (1,2,6,7,8))      
    
SELECT       
 DM.BUName AS DepartmentName,      
 DAM.CustomerName as AccountName,      
 PM.EsaProjectID,      
 PM.PROJECTID,      
 A.TicketID,      
  A.TicketDescription,      
  AMR.ApplicationName,      
  AT.ApplicationTypename,      
  MT.PrimaryTechnologyName AS TechnologyName,      
 AM.DebtClassificationName AS [DebtClassification],      
  AM1.AvoidableFlagName AS [AvoidableFlag],       
 AM2.[ResidualDebtName] AS [ResidualDebt],      
   AM3.CauseCode AS [CauseCode],       
 AM4.ResolutionCode AS [ResolutionCode],      
 CASE WHEN ISNULL(AdditionalText,'') = '' THEN '' ELSE AdditionalText END AS AdditionalText,    
 A.Desc_Base_WorkPattern,    
 A.Desc_Sub_WorkPattern,    
 A.Res_Base_WorkPattern,    
 A.Res_Sub_WorkPattern,    
 A.IsTicketDescOpt    
FROM       
 #TempForJob A WITH(NOLOCK)      
LEFT JOIN [AVL].[DEBT_MAS_DebtClassification](NOLOCK) AM ON a.DebtClassificationId=AM.DebtClassificationID      
LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AM1 ON a.AvoidableFlagID=AM1.AvoidableFlagID      
LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt](NOLOCK) AM2 ON a.ResidualDebtID=AM2.ResidualDebtID      
LEFT JOIN  [AVL].[DEBT_MAP_CauseCode](NOLOCK) AM3 ON A.CauseCodeID=AM3.CAUSEID AND A.ProjectID=AM3.ProjectID AND AM3.IsDeleted=0      
LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode](NOLOCK) AM4 ON A.ResolutionCodeID=AM4.RESOLUTIONID AND A.ProjectID=AM4.ProjectID AND AM3.IsDeleted=0      
LEFT JOIN [AVL].[APP_MAS_ApplicationDetails](NOLOCK) AMR ON A.ApplicationID=AMR.ApplicationID      
LEFT JOIN [AVL].[APP_MAS_OwnershipDetails](NOLOCK) AT ON AMR.CodeOwnership=AT.ApplicationTypeID      
LEFT JOIN [AVL].[APP_MAS_PrimaryTechnology](NOLOCK) MT ON AMR.PrimaryTechnologyID=MT.PrimaryTechnologyID      
LEFT JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON A.ProjectID=PM.ProjectID      
LEFT JOIN [AVL].[Customer](NOLOCK) DAM ON PM.CustomerID=DAM.CustomerID AND DAM.IsDeleted =0      
LEFT JOIN [AVL].[BusinessUnit](NOLOCK) DM ON DAM.BUID=DM.BUID AND DM.IsDeleted=0       
      
SELECT distinct ProjectName,ContLearningId AS ContLearningId,ProjectID FROM #projtempfile      
      
 SET NOCOUNT OFF    
      
COMMIT TRAN      
END TRY        
BEGIN CATCH        
              
  ROLLBACK TRAN      
  DECLARE @ErrorMessage VARCHAR(MAX);      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
        
  --INSERT Error          
  EXEC AVL_InsertError '[ML].[CL_JobToExportTickets] ', @ErrorMessage, 0,0      
        
 END CATCH         
END
