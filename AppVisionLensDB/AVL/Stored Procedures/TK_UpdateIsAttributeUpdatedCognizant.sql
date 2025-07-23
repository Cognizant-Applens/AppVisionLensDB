/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
    
CREATE PROCEDURE [AVL].[TK_UpdateIsAttributeUpdatedCognizant]                 
@ProjectId BIGINT,                
@ServiceID INT,                
@TicketStatusID BIGINT,                
@TicketID NVARCHAR(1000),                
@TicketTypeID BIGINT=0  
                    
AS                 
BEGIN                 
 BEGIN TRY                
 SET NOCOUNT ON;                
 CREATE TABLE #AttributeTemp                
 (                
 ID BIGINT IDENTITY(1,1),                
 AttributeName NVARCHAR(1000) NULL,                
 TicketDetailFields NVARCHAR(1000) NULL                
 )                
 DECLARE @DARTStatusID INT;                
 DECLARE @FlexField1Name NVARCHAR(100)='Flex Field (1)'                
 DECLARE @FlexField2Name NVARCHAR(100)='Flex Field (2)'                
 DECLARE @FlexField3Name NVARCHAR(100)='Flex Field (3)'                
 DECLARE @FlexField4Name NVARCHAR(100)='Flex Field (4)'                
 SET @DARTStatusID=(SELECT TicketStatus_ID FROM AVL.TK_MAP_ProjectStatusMapping(NOLOCK)                 
      WHERE ProjectID=@ProjectId AND StatusID=@TicketStatusID AND IsDeleted=0)                
 DECLARE @TicketAttributeIntegration CHAR                
 SET @TicketAttributeIntegration =(SELECT ISNULL(IsMainSpringConfigured,'N') as Config from AVL.MAS_ProjectMaster(NOLOCK)                 
          WHERE ProjectID = @ProjectId AND Isdeleted = 0)                
                
  IF(@TicketAttributeIntegration = 'Y')                
   BEGIN                
    IF NOT EXISTS(SELECT TOP 1 StatusName from AVL.PRJ_MainspringAttributeProjectStatusMaster (NOLOCK)                 
         WHERE Projectid = @ProjectId and IsDeleted = 0)                 
     BEGIN                 
      INSERT INTO #AttributeTemp                
      SELECT                 
      D.AttributeName,                 
      AM.TicketDetailFields                
      FROM AVL.MAS_MainspringAttributeStatusMaster D (NOLOCK)                 
      LEFT JOIN AVL.MAS_AttributeMaster(NOLOCK) AM ON D.AttributeID=AM.AttributeID  and AM.IsDeleted=0                 
      WHERE D.ServiceID=@serviceid AND D.StatusID=@DARTStatusID AND D.FieldType='M'                
      AND D.IsDeleted= 0                
     END                 
   ELSE                
    BEGIN                 
     INSERT INTO #AttributeTemp                 
     SELECT                 
     D.AttributeName,                 
     AM.TicketDetailFields                
     FROM AVL.PRJ_MainspringAttributeProjectStatusMaster D (NOLOCK)                 
     LEFT JOIN AVL.MAS_AttributeMaster(NOLOCK) AM ON D.AttributeID=AM.AttributeID and AM.IsDeleted = 0                
     WHERE D.Projectid=@ProjectId AND D.ServiceID=@serviceid                 
     AND D.StatusID=@DARTStatusID  AND D.FieldType='M'                   
     AND D.IsDeleted= 0                
    END                 
  END                
 ELSE                
  BEGIN                 
   IF NOT EXISTS(SELECT TOP 1 StatusName from AVL.PRJ_StandardAttributeProjectStatusMaster (NOLOCK)                 
       WHERE Projectid = @ProjectId and IsDeleted = 0)                 
    BEGIN                
     INSERT INTO #AttributeTemp                
     SELECT                 
     D.AttributeName,                  
     AM.TicketDetailFields                
     FROM AVL.MAS_StandardAttributeStatusMaster D (NOLOCK)                 
     LEFT JOIN AVL.MAS_AttributeMaster(NOLOCK) AM ON D.AttributeID=AM.AttributeID and AM.IsDeleted = 0                
     WHERE D.ServiceID=@serviceid AND D.StatusID=@DARTStatusID AND D.FieldType='M'                
        AND D.IsDeleted= 0                 
    END                
   ELSE                
    BEGIN                
     INSERT INTO #AttributeTemp                
     SELECT                 
     D.AttributeName,                 
     AM.TicketDetailFields                
     FROM AVL.PRJ_StandardAttributeProjectStatusMaster D (NOLOCK)                 
     LEFT JOIN AVL.MAS_AttributeMaster(NOLOCK) AM ON D.AttributeID=AM.AttributeID and AM.IsDeleted =0                
     WHERE D.Projectid=@ProjectId AND D.ServiceID=@serviceid AND D.StatusID=@DARTStatusID                
     AND D.FieldType='M' AND D.IsDeleted= 0                 
    END                   
  END  
  
  DECLARE @IsAttributeUpdatedFlg VARCHAR(10)  
      DECLARE @AlgorithmKey NVARCHAR(25)      
 DECLARE @NotUpdated bit      
SET @AlgorithmKey=(SELECT  TOP 1  AlgorithmKey FROM [ML].[TRN_MLTransaction] WHERE ProjectId=@ProjectId AND SupportTypeId=1 AND ISNULL(IsActiveTransaction,0)=1)           
SET @NotUpdated=(SELECT  TOP 1 IsAttributeUpdated FROM AVL.TK_TRN_TicketDetail WHERE ProjectID = @ProjectId AND TicketID=@TicketID)      
      
IF(@AlgorithmKey ='AL002' AND @NotUpdated=0)         
BEGIN        
        
Declare @DataExists bit        
        
CREATE TABLE #newAlgo(        
 DataExists bit        
)        
--Get Column Mapping                  
SELECT FN.TK_TicketDetailColumn     into #columnMap                   
FROM [ML].[TRN_MLTransaction] MT                        
JOIN [ML].[TRN_TransactionCategorical] MD ON MD.MLTransactionId=MT.TransactionId                         
JOIN [MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=MD.CategoricalFieldId                         
WHERE ProjectId= @ProjectId  AND ISNULL(MT.IsActiveTransaction,0)=1 AND SupportTypeId=1                         
UNION                        
(SELECT FN.TK_TicketDetailColumn FROM [ML].[TRN_MLTransaction] t LEFT join                         
[MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=t.IssueDefinitionId                        
or FN.FieldMappingId=t.ResolutionProviderId                         
WHERE t.ProjectId= @ProjectId  AND ISNULL(t.IsActiveTransaction,0)=1 AND SupportTypeId=1)        
        
DECLARE @GetQuery NVARCHAR(MAX)                  
DECLARE @result nvarchar(max)                  
SET @GetQuery=STUFF((SELECT ' ' + ' ' + QUOTENAME(TK_TicketDetailColumn)  +' IS  NULL'+' OR'                  
           from #columnMap (NOLOCK)                       
           FOR XML PATH(''), TYPE                        
           ).value('.', 'NVARCHAR(MAX)')                         
           ,1,0,'')               
        
SET @result='Insert into #newAlgo Select Top 1 1 FROM  AVL.TK_TRN_TicketDetail WHERE TicketId='''+ Convert(Varchar(50),@TicketID) +''' and ('+@GetQuery+' '                  
SET @result=(SELECT left(@result, len(@result)-2))         
SET @result = @result +')'        
EXEC sp_executesql @result;          
        
select @DataExists=DataExists from #newAlgo        
        
IF(@DataExists is NULL)        
BEGIN        
 SET @IsAttributeUpdatedFlg = 1      
 SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated      
 Update AVL.TK_TRN_TicketDetail SET IsAttributeUpdated=@IsAttributeUpdatedFlg WHERE ProjectID = @ProjectId AND TicketID=@TicketID       
  AND @ServiceID <> 0        
END        
        
DROP TABLE #columnMap        
DROP TABLE #newAlgo        
        
END        
 

  SELECT TimeTickerID,TicketID,ApplicationID,ProjectID,AssignedTo,AssignmentGroup,EffortTillDate,ServiceID                
   ,TicketDescription,IsDeleted,CauseCodeMapID,DebtClassificationMapID,ResidualDebtMapID,ResolutionCodeMapID                
   ,ResolutionMethodMapID,KEDBAvailableIndicatorMapID,KEDBUpdatedMapID,KEDBPath,PriorityMapID,ReleaseTypeMapID                
   ,SeverityMapID,TicketSourceMapID,TicketStatusMapID,TicketTypeMapID,BusinessSourceName,Onsite_Offshore,PlannedEffort                
   ,EstimatedWorkSize,ActualEffort,ActualWorkSize,Resolvedby,Closedby,ElevateFlagInternal,RCAID,PlannedDuration                
   ,Actualduration,TicketSummary,NatureoftheTicket,Comments,RepeatedIncident,RelatedTickets,TicketCreatedBy                
   ,SecondaryResources,EscalatedFlagCustomer,ReasonforRejection,AvoidableFlag,ReleaseDate,TicketCreateDate                
   ,PlannedStartDate,PlannedEndDate,ActualStartdateTime,ActualEnddateTime,OpenDateTime,StartedDateTime                
   ,WIPDateTime,OnHoldDateTime,CompletedDateTime,ReopenDateTime,CancelledDateTime,RejectedDateTime,Closeddate                
   ,AssignedDateTime,OutageDuration,MetResponseSLAMapID,MetAcknowledgementSLAMapID,MetResolutionMapID                
   ,EscalationSLA,TKBusinessID,InscopeOutscope,IsAttributeUpdated,NewStatusDateTime,IsSDTicket,IsManual,DARTStatusID                
   ,ResolutionRemarks,ITSMEffort,CreatedBy,CreatedDate,LastUpdatedDate,ModifiedBy,ModifiedDate,IsApproved                
   ,ReasonResidualMapID,ExpectedCompletionDate,ApprovedBy,DAPId,DebtClassificationMode,FlexField1,FlexField2                
   ,FlexField3,FlexField4,Category,[Type],IsPartiallyAutomated INTO #TempTM                 
   FROM AVL.TK_TRN_TicketDetail (NOLOCK)                 
   WHERE ProjectID = @ProjectId AND TicketID = @TicketID                
                
  DECLARE @AttributeCount BIGINT = 1                
  DECLARE @CountMin INT                
  DECLARE @CountMax INT                              
  DECLARE @OptionalAttributeType int                
  SELECT TOP 1 @OptionalAttributeType=OptionalAttributeType from AVL.MAS_ProjectDebtDetails(NOLOCK)                 
  WHERE ProjectID=@ProjectId AND ISNULL(IsDeleted,0)=0                
                
  IF (@OptionalAttributeType=1 OR @OptionalAttributeType=3)             
  BEGIN                
   SELECT ColumnID INTO #Temp FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)                 
   WHERE ProjectID=@ProjectId AND IsActive=1                
   DECLARE @FlexField1 NVARCHAR(20);                
   DECLARE @FlexField2 NVARCHAR(20);                
   DECLARE @FlexField3 NVARCHAR(20);                
   DECLARE @FlexField4 NVARCHAR(20);                
                
   SET @FlexField1=(SELECT TOP 1 AttributeName FROM #AttributeTemp(NOLOCK) WHERE AttributeName=@FlexField1Name)                
   SET @FlexField2=(SELECT TOP 1 AttributeName FROM #AttributeTemp(NOLOCK) WHERE AttributeName=@FlexField2Name)                
 SET @FlexField3=(SELECT TOP 1 AttributeName FROM #AttributeTemp(NOLOCK) WHERE AttributeName=@FlexField3Name)                
   SET @FlexField4=(SELECT TOP 1 AttributeName FROM #AttributeTemp(NOLOCK) WHERE AttributeName=@FlexField4Name)                
   IF(@serviceid in (1,4,5,6,7,8,10))                
    BEGIN                
     IF EXISTS (SELECT ColumnID FROM #Temp(NOLOCK) WHERE ColumnID =11 AND @DARTStatusID=8 AND @FlexField1 IS NULL)                
      BEGIN                
       INSERT INTO #AttributeTemp                
       SELECT @FlexField1Name AS AttributeName,'FlexField(1)' AS TicketDetailFields                 
                
      END                
     IF EXISTS (SELECT ColumnID FROM #Temp(NOLOCK) WHERE ColumnID =12 AND @DARTStatusID=8 AND @FlexField2 IS NULL)                
      BEGIN                
       INSERT INTO #AttributeTemp                
       SELECT @FlexField2Name AS AttributeName,'FlexField(2)' AS TicketDetailFields                 
      END                
     IF EXISTS (SELECT ColumnID FROM #Temp(NOLOCK) WHERE ColumnID =13 AND @DARTStatusID=8 AND @FlexField3 IS NULL)                
      BEGIN                
       INSERT INTO #AttributeTemp                
      SELECT @FlexField3Name AS AttributeName,'FlexField(3)' AS TicketDetailFields                 
      END                
     IF EXISTS (SELECT ColumnID FROM #Temp(NOLOCK) WHERE ColumnID =14 AND @DARTStatusID=8 AND @FlexField4 IS NULL)                
      BEGIN                
       INSERT INTO #AttributeTemp                
       SELECT @FlexField4Name AS AttributeName,'FlexField(4)' AS TicketDetailFields                 
      END                
    END                
  END                
                
IF EXISTS (SELECT IsAutoClassified From AVL.MAS_ProjectDebtDetails(NOLOCK) where IsAutoClassified='Y'                 
      and ProjectID=@ProjectId AND IsDeleted=0 AND @DARTStatusID=8 AND @serviceid in (1,4,5,6,7,8,10))                
BEGIN                
   IF  EXISTS ( SELECT TOP 1 IsOptionalField FROM ML.ConfigurationProgress(NOLOCK)                 
       where ProjectId=@ProjectId and IsDeleted=0 AND IsOptionalField = 1)                 
       BEGIN                
        INSERT INTO #AttributeTemp                
        SELECT 'Resolution Method' AS AttributeName,'ResolutionRemarks' AS TicketDetailFields                 
       END                
 declare @IsTicketDescriptionOpted int;                
 set @IsTicketDescriptionOpted=(select TOP 1 IsTicketDescriptionOpted from ml.ConfigurationProgress(NOLOCK) where projectid=@ProjectId AND IsDeleted = 0                
          ORDER BY ID ASC)                
                
 If(@IsTicketDescriptionOpted=1)                
begin                
 INSERT INTO #AttributeTemp                
 SELECT 'Ticket Description' AS AttributeName,'TicketDescription' AS TicketDetailFields                 
 end                 
END                 
                
  UPDATE TD SET TD.ServiceClassificationMode =                  
   CASE                  
   WHEN TD.ServiceClassificationMode = 3 THEN 4                 
   WHEN TD.ServiceClassificationMode = 4                 
    OR TD.ServiceClassificationMode = 6  THEN TD.ServiceClassificationMode                
   WHEN TD.ServiceClassificationMode = 5 THEN 6                                             
   END                   
  FROM avl.TK_TRN_TicketDetail TD                
  WHERE TD.TicketID = @TicketID                
   AND TD.ProjectID = @ProjectID                
   AND TD.IsDeleted = 0                
   AND @serviceid <> 0                
   AND TD.ServiceID != @ServiceID                
                   
                
  UPDATE  #TempTM SET ReleaseTypeMapID   =NULL WHERE ReleaseTypeMapID             =0  
  UPDATE  #TempTM SET SeverityMapID    =NULL WHERE SeverityMapID     =0  
  UPDATE  #TempTM SET KEDBAvailableIndicatorMapID =NULL WHERE KEDBAvailableIndicatorMapID  =0  
  UPDATE  #TempTM SET MetAcknowledgementSLAMapID =NULL WHERE MetAcknowledgementSLAMapID  =0  
  UPDATE  #TempTM SET MetResolutionMapID   =NULL WHERE MetResolutionMapID    =0  
  UPDATE  #TempTM SET MetResponseSLAMapID   =NULL WHERE MetResponseSLAMapID    =0  
  UPDATE  #TempTM SET NatureoftheTicket   =NULL WHERE NatureoftheTicket    =0  
  UPDATE  #TempTM SET ReleaseTypeMapID   =NULL WHERE ReleaseTypeMapID    =0  
  UPDATE  #TempTM SET DebtClassificationMapID  =NULL WHERE DebtClassificationMapID   =0  
  UPDATE  #TempTM SET ElevateFlagInternal   =NULL WHERE ElevateFlagInternal    =0  
  UPDATE  #TempTM SET EscalatedFlagCustomer   =NULL WHERE EscalatedFlagCustomer    =0  
  UPDATE  #TempTM SET AvoidableFlag    =NULL WHERE AvoidableFlag     =0  
  UPDATE  #TempTM SET CauseCodeMapID    =NULL WHERE CauseCodeMapID     =0  
  UPDATE  #TempTM SET KEDBUpdatedMapID   =NULL WHERE KEDBUpdatedMapID    =0  
  UPDATE  #TempTM SET ActualWorkSize    =NULL WHERE ActualWorkSize    ='0.00'  
  UPDATE  #TempTM SET EstimatedWorkSize   =NULL WHERE EstimatedWorkSize   ='0.00'  
  UPDATE  #TempTM SET OutageDuration    =NULL WHERE OutageDuration    ='0.00'  
  UPDATE  #TempTM SET PlannedEffort    =NULL WHERE PlannedEffort    ='0.00'  
  UPDATE  #TempTM SET ResolutionRemarks   =NULL WHERE ResolutionRemarks   =''  
  UPDATE  #TempTM SET IsPartiallyAutomated     =2 WHERE IsPartiallyAutomated      =''  
                
                
  DELETE FROM #AttributeTemp WHERE ISNULL(TicketDetailFields,'') IN('NULL','','effortTilldate','StatusID','Onsite_Offshore',                
  'TicketCreatedBy')                
                
  DECLARE @TotalAttributeCount BIGINT = (SELECT COUNT(1) FROM #AttributeTemp(NOLOCK))                 
  SET @CountMin = (SELECT MIN(ID) FROM #AttributeTemp(NOLOCK))                
  SET @CountMax = (SELECT MAX(ID) FROM #AttributeTemp(NOLOCK))                
  --TO DO REMOVE BRACKETS IN MASTER TABLE                
                
  UPDATE #AttributeTemp set TicketDetailFields = REPLACE(REPLACE(TicketDetailFields,')',''),'(','')                
  DECLARE @AttributeName VARCHAR(500)                 
  DECLARE @Selectquery NVARCHAR(1000)='';                
  DECLARE @rowcntAvailable INT=0;                
          
 WHILE(@CountMin < = @CountMax AND @AttributeCount > 0)                
  BEGIN                
   SET @rowcntAvailable=0;                
   SET @AttributeName = (SELECT TicketDetailFields FROM #AttributeTemp(NOLOCK) WHERE ID=@CountMin)                
   SET @Selectquery='SELECT @cnt=COUNT(1) FROM #TempTM WHERE '+@AttributeName+ ' IS NOT NULL'                
   IF(@AttributeName = 'TicketDescription')                
   BEGIN                 
    SET @Selectquery='SELECT @cnt=COUNT(1) FROM #TempTM WHERE '+@AttributeName+ '<>'''''                
   END                
   exec sp_executesql @Selectquery, N'@cnt int out', @rowcntAvailable out                 
   IF @rowcntAvailable>0                
    BEGIN                
     SET @AttributeCount = @AttributeCount + 1;                
    END                
   SET @CountMin = @CountMin+1                  
  END                
 SET @AttributeCount = @AttributeCount -1                
   --Check If AHTicket                        
 DECLARE @IsAHTicket INT, @BusinessImpact INT,@ImpactComments VARCHAR(100)                        
                        
 SELECT @IsAHTicket =(SELECT CASE WHEN TT.HealingTicketID IS NOT NULL THEN 1 ELSE 0 END  AS 'IsAHTicket'),                        
  @BusinessImpact=TT.BusinessImpactId,                        
  @ImpactComments=TT.ImpactComments                        
  FROM AVL.TK_TRN_TicketDetail(NOLOCK) TM                              
  INNER JOIN avl.DEBT_TRN_HealTicketDetails TT ON TM.TicketID=TT.HealingTicketID AND TT.IsDeleted=0                              
  INNER JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic PM ON PM.ProjectPatternMapID=TT.ProjectPatternMapID AND TM.ProjectID=PM.ProjectID                               
  INNER JOIN avl.TK_MAP_TicketTypeMapping (NOLOCK) TTM on TM.ProjectID = TTM.ProjectID AND TM.TicketTypeMapID = TTM.TicketTypeMappingID AND TTM.IsDeleted = 0                              
  WHERE tm.ProjectID = @ProjectId  and tm.TicketID = @TicketID                        
                        
  --If Not AH Ticket                   
  IF(@AttributeCount = @TotalAttributeCount AND (ISNULL(@IsAHTicket,0)=0))                              
   BEGIN                                 
    SET @IsAttributeUpdatedFlg = 1                              
    SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                              
    UPDATE AVL.TK_TRN_TicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg, ServiceID = @serviceid,                              
    TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                              
    WHERE ProjectID = @ProjectId AND TicketID = @TicketID and @serviceid <> 0                              
   END                              
  ELSE  IF(ISNULL(@IsAHTicket,0)=0)                             
   BEGIN                               
    SET @IsAttributeUpdatedFlg = 0                              
    SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                              
    UPDATE AVL.TK_TRN_TicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg, ServiceID = @serviceid,                              
    TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                               
     WHERE ProjectID = @ProjectId AND TicketID = @TicketID AND @serviceid <> 0                              
   END                          
                           
    --IF AH Ticket                        
    IF(@AttributeCount = @TotalAttributeCount AND (@DARTStatusID=8 OR @DARTStatusID=9) AND  ((ISNULL(@IsAHTicket,0)=1)                      
   AND(@BusinessImpact<>0 OR ISNULL(@BusinessImpact,'')<>'')                      
  AND (ISNULL(@ImpactComments,'')<>'')))                               
   BEGIN                                 
    SET @IsAttributeUpdatedFlg = 1                        
SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                              
    UPDATE AVL.TK_TRN_TicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg, ServiceID = @serviceid,                              
    TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                              
    WHERE ProjectID = @ProjectId AND TicketID = @TicketID and @serviceid <> 0                              
   END                              
  ELSE IF(ISNULL(@IsAHTicket,0)=1 AND (@DARTStatusID=8 OR @DARTStatusID=9))                               
   BEGIN                               
    SET @IsAttributeUpdatedFlg = 0                            
    SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                             
    UPDATE AVL.TK_TRN_TicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg, ServiceID = @serviceid,                              
    TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                               
     WHERE ProjectID = @ProjectId AND TicketID = @TicketID AND @serviceid <> 0                     
   END               
               
            
            
    --Not in completed/Closed Status AH Tickets            
  IF(@AttributeCount = @TotalAttributeCount AND (@DARTStatusID<>8 AND @DARTStatusID<>9) AND  ((ISNULL(@IsAHTicket,0)=1)))             
  BEGIN             
   SET @IsAttributeUpdatedFlg = 1                        
SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                              
    UPDATE AVL.TK_TRN_TicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg, ServiceID = @serviceid,                              
    TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                              
    WHERE ProjectID = @ProjectId AND TicketID = @TicketID and @serviceid <> 0           
  END            
  ELSE IF(ISNULL(@IsAHTicket,0)=1 AND (@DARTStatusID<>8 AND @DARTStatusID<>9))                               
   BEGIN                               
    SET @IsAttributeUpdatedFlg = 0                            
    SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                             
    UPDATE AVL.TK_TRN_TicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg, ServiceID = @serviceid,                              
    TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                               
     WHERE ProjectID = @ProjectId AND TicketID = @TicketID AND @serviceid <> 0                              
   END             
             
 --To update the ticket details of heal and automation                
  SELECT TM.ProjectID,TM.TicketID,TM.DARTStatusID                
  INTO #StatusChangedTemp                
  FROM avl.TK_TRN_TicketDetail(NOLOCK) TM                
  INNER JOIN avl.DEBT_TRN_HealTicketDetails(NOLOCK) TT ON TM.TicketID=TT.HealingTicketID AND TT.IsDeleted = 0                
  INNER JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic(NOLOCK) PM ON PM.ProjectPatternMapID=TT.ProjectPatternMapID AND TM.ProjectID=PM.ProjectID                 
  INNER JOIN avl.TK_MAP_TicketTypeMapping (NOLOCK) TTM on TM.ProjectID = TTM.ProjectID AND TM.TicketTypeMapID = TTM.TicketTypeMappingID AND TTM.IsDeleted = 0                
  WHERE TM.ProjectID = @ProjectId AND tm.TicketID = @TicketID AND TTM.AVMTicketType IN (9,10)                  
  --AND ISNULL(TT.ManualNonDebt,0)<>1 AND ISNULL(PM.ManualNonDebt,0)<>1                
                
  DECLARE @TcktMasStatus VARCHAR(50)                
  SELECT  @TcktMasStatus =@DARTStatusID                
                   
  DECLARE @HealTblStatus VARCHAR(50)                 
  SET @HealTblStatus = (SELECT HTD.DARTStatusID FROM avl.DEBT_TRN_HealTicketDetails(NOLOCK) HTD                 
        WHERE HTD.HealingTicketID = @TicketID --AND ISNULL(HTD.ManualNonDebt,0)<>1                 
        AND HTD.IsDeleted = 0)                   
                 
  IF(@TcktMasStatus <> @HealTblStatus)                
   BEGIN                
    INSERT INTO avl.DEBT_TRN_HealTicketsLog                
    SELECT ProjectID,TicketID,1,NULL,NULL,DARTStatusID,NULL,NULL,NULL,NULL,'TRN.Heal_TicketDetails',NULL,NULL,NULL,NULL,'system',GETDATE()                
    FROM #StatusChangedTemp(NOLOCK)                
   END                
  ---Update status of HEalTicket                
  UPDATE TT                 
  SET TT.DARTStatusID=@DARTStatusID,TT.ModifiedDate=getdate(), TT.ClosedDate = TM.Closeddate                
  FROM AVL.TK_TRN_TicketDetail(NOLOCK) TM                
  INNER JOIN avl.DEBT_TRN_HealTicketDetails TT ON TM.TicketID=TT.HealingTicketID AND TT.IsDeleted=0                
  INNER JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic PM ON PM.ProjectPatternMapID=TT.ProjectPatternMapID AND TM.ProjectID=PM.ProjectID                 
  INNER JOIN avl.TK_MAP_TicketTypeMapping (NOLOCK) TTM on TM.ProjectID = TTM.ProjectID AND TM.TicketTypeMapID = TTM.TicketTypeMappingID AND TTM.IsDeleted = 0                
  WHERE tm.ProjectID = @ProjectId  and tm.TicketID = @TicketID  AND TTM.AVMTicketType IN (9,10)                 
  --AND ISNULL(TT.ManualNonDebt,0)<>1 AND ISNULL(PM.ManualNonDebt,0)<>1                
                
  IF @DARTStatusID = 8                
  BEGIN                
   UPDATE PM                 
   SET PM.PatternStatus = 0, PM.ModifiedDate=GETDATE()                
   FROM AVL.TK_TRN_TicketDetail(NOLOCK) TM                
   INNER JOIN avl.DEBT_TRN_HealTicketDetails(NOLOCK) TT ON TM.TicketID=TT.HealingTicketID AND TT.IsDeleted=0                
   INNER JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic PM ON TM.ProjectID=PM.ProjectID AND PM.ProjectPatternMapID=TT.ProjectPatternMapID                 
   WHERE TM.ProjectID = @ProjectId AND  TM.TicketID = @TicketID                 
   --AND ISNULL(TT.ManualNonDebt,0)<>1 AND ISNULL(PM.ManualNonDebt,0)<>1                
  END                
                
  EXEC AVL.DebtClassificationModeUpdate @ProjectId, @TicketID                
                
  --DROP TABLE IF EXISTS #AttributeTemp                
  --DROP TABLE IF EXISTS #TempTM          
          
               
  IF OBJECT_ID('tempdb..#AttributeTemp', 'U') IS NOT NULL                
  BEGIN                
   DROP TABLE #AttributeTemp                
  END                
  IF OBJECT_ID('tempdb..#TempTM', 'U') IS NOT NULL                
  BEGIN                
   DROP TABLE #TempTM                
  END                
  IF OBJECT_ID('tempdb..#Temp', 'U') IS NOT NULL                
  BEGIN                
   DROP TABLE #Temp                
  END                
  IF OBJECT_ID('tempdb..#StatusChangedTemp', 'U') IS NOT NULL                
  BEGIN                
   DROP TABLE #StatusChangedTemp                
  END                
 SET NOCOUNT OFF;                
 END TRY                  
BEGIN CATCH                  
                
  DECLARE @ErrorMessage VARCHAR(MAX);                
  SELECT @ErrorMessage = ERROR_MESSAGE()                
  EXEC AVL_InsertError '[AVL].[TK_UpdateIsAttributeUpdatedCognizant]', @ErrorMessage, @ProjectId,0                
                  
 END CATCH                 
END
