/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
    
     
      
CREATE PROCEDURE [AVL].[CLDDPatternIdentificationJob]        
AS        
BEGIN        
DECLARE @Result BIT;        
SET NOCOUNT ON;        
BEGIN TRY        
BEGIN TRAN        
        
DECLARE @ScopeId BIGINT;        
DECLARE @TaskName VARCHAR(500),@TaskUrl VARCHAR(max),@TaskApplication VARCHAR(500),@TaskStatus VARCHAR(100),@TaskType VARCHAR(100);        
DECLARE @TaskId INT;        
DECLARE @TaskNameForPattern VARCHAR(500),@TaskUrlForPattern  VARCHAR(max),@TaskApplicationForPattern  VARCHAR(500);        
DECLARE @TaskIdForPattern INT;        
DECLARE @JobTableID INT,@JobStartDate DATE, @JobEndDate DATE;        
DECLARE @ConflictTaskName VARCHAR(500),@ConflictTaskUrl VARCHAR(max),@ConflictTaskApplication VARCHAR(500);        
DECLARE @ConflictTaskId INT;        
      
--DELETE FROM [AVL].[MyTasksCLInDD]      
        
SELECT @TaskId=TaskID FROM dbo.taskmaster WHERE TaskName='Auto DD Enablement';        
SELECT @TaskName = taskname FROM dbo.taskmaster WHERE taskid=@TaskId;        
SELECT @TaskUrl = taskurl FROM dbo.taskurl WHERE taskid=@TaskId AND IsDeleted=0;        
SELECT @TaskApplication = applicationname FROM dbo.taskapplication WHERE taskid=@TaskId AND IsDeleted=0;        
SELECT @TaskStatus = [status] FROM dbo.taskstatus WHERE taskstatusid=1 AND IsDeleted=0;        
SELECT @TaskType = tasktype FROM dbo.tasktype WHERE tasktypeid=1 AND IsDeleted=0;         
        
        
        
SELECT @TaskIdForPattern=TaskID FROM dbo.taskmaster WHERE TaskName='DD Unique Pattern';        
SELECT @TaskNameForPattern = taskname FROM dbo.taskmaster WHERE taskid=@TaskIdForPattern;        
SELECT @TaskUrlForPattern = taskurl FROM dbo.taskurl WHERE taskid=@TaskIdForPattern AND IsDeleted=0;        
SELECT @TaskApplicationForPattern = applicationname FROM dbo.taskapplication WHERE taskid=@TaskIdForPattern AND IsDeleted=0;        
        
        
        
--TO GET THE JOB START AND END DATE        
        
        
SET @JobStartDate = (SELECT TOP 1 EndDateTime FROM MAS.JobStatus WHERE JobId=1 AND JobStatus = 'Success' ORDER BY JobRunDate DESC)         
SET @JobEndDate = (SELECT GETDATE())         
        
/***BASE FILTER CONDITIONS***/        
        
SELECT DISTINCT TD.ProjectID,TD.ApplicationID,        
CauseCodeMapID,ResolutionCodeMapID,        
DebtClassificationMapID,AvoidableFlag,        
ResidualDebtMapID,Count(TD.ProjectID) 'NoOfPatterns' INTO #TmpDetails        
FROM AVL.TK_TRN_TicketDetail(NOLOCK) TD         
JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON TD.ProjectID=PM.ProjectID        
INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) MAD ON MAD.ApplicationID = TD.ApplicationID AND MAD.IsActive = 1        
JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) APM ON TD.ProjectID=APM.ProjectID AND TD.ApplicationID=APM.ApplicationID and APM.IsDeleted=0        
JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON TD.ProjectID=CC.ProjectID AND TD.CauseCodeMapID=CC.CauseID AND CC.IsDeleted=0        
JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC ON TD.ProjectID=CC.ProjectID AND TD.ResolutionCodeMapID=RC.ResolutionID AND RC.IsDeleted=0        
WHERE CauseCodeMapID is not null AND         
ResolutionCodeMapID is not null AND DebtClassificationMapID is not null AND AvoidableFlag is not null AND ResidualDebtMapID is not null        
AND TD.DARTStatusID=8      
AND PM.IsDebtEnabled='Y' AND (TD.DebtClassificationMode=4 OR TD.DebtClassificationMode=5)        
AND CONVERT(DATE,TD.Closeddate) >= @JobStartDate AND CONVERT(DATE,TD.Closeddate) <= @JobEndDate        
GROUP BY TD.ProjectID,TD.ApplicationID,CauseCodeMapID,ResolutionCodeMapID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID        
        
        
/***FILTER TICKETS >=THRESHOLD***/        
        
Select A.ProjectID,ApplicationID,CauseCodeMapID,ResolutionCodeMapID,DebtClassificationMapID,        
AvoidableFlag,ResidualDebtMapID,NoOfPatterns         
INTO #PatternsGTThreshold        
FROM #TmpDetails A JOIN AVL.MAS_ProjectDebtDetails PD ON A.ProjectID=PD.ProjectID        
WHERE A.NoOfPatterns >= PD.DDThresholdCount        
        
        
/***FILTER THE MODIFIED PATTERNS TO DELETE***/        
SELECT ProjectID,ApplicationID,CauseCodeMapID,ResolutionCodeMapID INTO #TmpDelete FROM #PatternsGTThreshold        
GROUP BY ProjectID,ApplicationID,CauseCodeMapID,ResolutionCodeMapID        
HAVING COUNT(1)>1        
        
/***DELETING THE MODIFIED PATTERNS***/        
DELETE A FROM #PatternsGTThreshold A JOIN #TmpDelete B        
ON A.ProjectID=B.ProjectID AND A.ApplicationID=B.ApplicationID        
AND A.CauseCodeMapID=B.CauseCodeMapID AND A.ResolutionCodeMapID=B.ResolutionCodeMapID        
        
/***FINDING THE PATTERNS LESS THAN THRESHOLD***/        
Select A.ProjectID,ApplicationID,CauseCodeMapID,ResolutionCodeMapID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,NoOfPatterns         
INTO #PatternsLTThrshold        
FROM #TmpDetails A JOIN AVL.MAS_ProjectDebtDetails PD ON A.ProjectID=PD.ProjectID        
WHERE A.NoOfPatterns < PD.DDThresholdCount        
        
/***IDENTIFY THE CONFLICT PATTERNS***/        
SELECT ProjectID,ApplicationID,CauseCodeMapID,ResolutionCodeMapID INTO #InvalidPatterns FROM        
(SELECT ProjectID,ApplicationID,CauseCodeMapID,ResolutionCodeMapID FROM #PatternsGTThreshold        
INTERSECT        
SELECT ProjectID,ApplicationID,CauseCodeMapID,ResolutionCodeMapID FROM #PatternsLTThrshold)A        
        
/***DELETE THE CONFLICT PATTERNS FROM UNIQUE TABLE***/        
DELETE A FROM #PatternsGTThreshold A JOIN #InvalidPatterns B        
ON A.ProjectID=B.ProjectID AND A.ApplicationID=B.ApplicationID        
AND A.CauseCodeMapID=B.CauseCodeMapID AND A.ResolutionCodeMapID=B.ResolutionCodeMapID        
        
/***EXISTING UNIQUE PATTERN IN DD TABLE===Conflict Pattern***/        
SELECT B.ProjectID,B.ApplicationID,B.CauseCodeMapID,B.ResolutionCodeMapID,B.DebtClassificationMapID,        
B.AvoidableFlag,B.ResidualDebtMapID         
INTO #ConflictPatterns         
FROM [AVL].[Debt_MAS_ProjectDataDictionary] A JOIN #PatternsGTThreshold B ON A.ProjectID=B.ProjectID         
AND A.ApplicationID=B.ApplicationID AND A.CauseCodeID=B.CauseCodeMapID         
AND A.ResolutionCodeID=B.ResolutionCodeMapID WHERE A.IsDeleted=0        
        
        
--DELETING ALL THE EXISTING DD ACTIVE BASE PATTERN FROM UNIQUE PATTERNS***/        
DELETE A FROM #PatternsGTThreshold A JOIN #ConflictPatterns B        
ON A.ProjectID=B.ProjectID AND A.ApplicationID=B.ApplicationID        
AND A.CauseCodeMapID=B.CauseCodeMapID AND A.ResolutionCodeMapID=B.ResolutionCodeMapID        
         
        
        
/***INSERT OR UPDATE IN DD TABLE***/        
        
MERGE [AVL].[Debt_MAS_ProjectDataDictionary] AS PD        
USING #PatternsGTThreshold AS PG        
ON (PD.ProjectID=PG.ProjectID AND PD.ApplicationID=PG.ApplicationID AND PD.CauseCodeID=PG.CauseCodeMapID        
AND PD.ResolutionCodeID=PG.ResolutionCodeMapID AND PD.DebtClassificationID=PG.DebtClassificationMapID        
AND PD.AvoidableFlagID=PG.AvoidableFlag AND PD.ResidualDebtID=PG.ResidualDebtMapID)        
WHEN MATCHED AND PD.IsDeleted=1        
THEN UPDATE SET PD.IsDeleted=0,PD.IsPatternFromJob=1,PD.ModifiedBy='System',PD.ModifiedDate=GETDATE()        
WHEN NOT MATCHED THEN        
INSERT(ProjectID,ApplicationID,CauseCodeID,ResolutionCodeID,DebtClassificationID,AvoidableFlagID,ResidualDebtID,        
IsDeleted,EffectiveDate,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,IsPatternFromJob)        
VALUES(PG.ProjectID,PG.ApplicationID,PG.CauseCodeMapID,PG.ResolutionCodeMapID        
,PG.DebtClassificationMapID,PG.AvoidableFlag,PG.ResidualDebtMapID,        
0,GETDATE(),'System',GETDATE(),NULL,NULL,1);        
        
/***PROJECT WISE DD PATTERN COUNT***/        
SELECT ProjectID,COUNT(ProjectID) as 'NoOfPatterns' INTO #TmpProjectwiseCount FROM #PatternsGTThreshold GROUP BY ProjectID        
        
        
        
/***PROJECTS TO ENABLE DD***/        
SELECT A.ProjectID INTO #TaskProject FROM #TmpProjectwiseCount A JOIN AVL.MAS_ProjectDebtDetails B        
ON A.ProjectID=B.ProjectID WHERE IsDDAutoClassified!='Y'         
---ENABLE DD---------        
UPDATE PD SET PD.IsDDAutoClassified='Y',PD.IsDDAutoClassifiedDate=GETDATE(),PD.IsDDAutoClassifiedBy='system',PD.IsTicketApprovalNeeded='N',PD.ModifiedBy='system',PD.ModifiedDate=GETDATE()        
FROM AVL.MAS_ProjectDebtDetails PD JOIN #TmpProjectwiseCount DE ON PD.ProjectID=DE.ProjectID        
WHERE IsDDAutoClassified!='Y'        
        
        
------***TASK TO ENABLE DD***----------        
SELECT DISTINCT A.TSApproverID,A.PROJECTID INTO #TaskToEnableDD FROM AVL.MAS_LoginMaster A JOIN #TaskProject B        
ON A.ProjectID=B.ProjectID AND A.IsDeleted=0 AND (A.TSApproverID IS NOT NULL AND A.TSApproverID <> '')       
        
SELECT DISTINCT LM.EmployeeID,TE.ProjectID,LM.IsDeleted,PM.EsaProjectID,PM.ProjectName,LM.CustomerID INTO #TempTaskForDD FROM AVL.MAS_LoginMaster LM         
JOIN #TaskToEnableDD TE ON LM.ProjectID=TE.ProjectID AND LM.EmployeeID=TE.TSApproverID        
JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON TE.ProjectID=PM.ProjectID        
WHERE LM.IsDeleted=0        
        
    
     SELECT DISTINCT lm.ProjectId,LM.HCMSupervisorId,    
    ' Data Dictionary has been auto enabled for your project "'+ RTRIM(ESAProjectID) + '-' + ProjectName       
     +'" based on the manual classification done by the Analyst. Click the link to view it'      
       AS 'TaskDetails'     
from #TempTaskForDD tf    
 join AVL.MAS_LoginMaster lm(nolock) on     
  lm.ProjectID = tf.ProjectID and lm.IsDeleted = 0    
  where LM.HCMSupervisorId is not null     
         
 ------***TASK TO ADD DD PATTERNS***-----------        
 CREATE TABLE #TempTaskForDDFinal        
 (        
 EmployeeID NVARCHAR(50),        
 ProjectID bigint,        
 NoOfPatterns NVARCHAR(4000),        
 EsaProjectID NVARCHAR(50),        
 ProjectName NVARCHAR(50),        
 CustomerID BIGINT,        
 IsDeleted BIT        
 )        
        
SELECT DISTINCT A.TSApproverID,A.PROJECTID,B.NoOfPatterns INTO #TaskForDDPattern FROM AVL.MAS_LoginMaster A JOIN #TmpProjectwiseCount B        
ON A.ProjectID=B.ProjectID AND A.IsDeleted=0 AND (A.TSApproverID IS NOT NULL AND A.TSApproverID <> '')      
        
INSERT INTO #TempTaskForDDFinal        
SELECT DISTINCT LM.EmployeeID,TE.ProjectID,TE.NoOfPatterns,PM.EsaProjectID,PM.ProjectName,LM.CustomerID,LM.IsDeleted FROM AVL.MAS_LoginMaster LM         
JOIN #TaskForDDPattern TE ON LM.ProjectID=TE.ProjectID AND LM.EmployeeID=TE.TSApproverID        
JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON TE.ProjectID=PM.ProjectID        
WHERE LM.IsDeleted=0        
        
        
----------------CONFLICT PATTERN IDENTIFICATION-----------------------        
        
        
SELECT          
 TD.ApplicationID         
 ,TD.CauseCodeMapID        
 ,TD.ResolutionCodeMapID        
 ,TD.DebtClassificationMapID        
 ,TD.ResidualDebtMapID        
 ,TD.AvoidableFlag        
 ,TD.ProjectID          
 INTO #TempTicketDetail        
 FROM [AVL].[TK_TRN_TicketDetail] TD (NOLOCK)        
 INNER JOIN [AVL].[MAS_ProjectMaster] PM (NOLOCK)         
  ON TD.ProjectID = PM.ProjectID AND PM.IsDeleted = 0 AND TD.IsDeleted = 0         
 INNER JOIN AVL.MAS_ProjectDebtDetails PD (NOLOCK)         
  ON PM.ProjectID = PD.ProjectID AND PD.IsDeleted = 0        
 INNER JOIN AVL.APP_MAS_ApplicationDetails MAD (NOLOCK)         
  ON MAD.ApplicationID = TD.ApplicationID AND MAD.IsActive = 1        
 INNER JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APM         
  ON MAD.ApplicationID = APM.ApplicationID AND APM.IsDeleted = 0 AND APM.ProjectID = TD.ProjectID        
 INNER JOIN AVL.DEBT_MAP_CauseCode CC (NOLOCK)         
  ON CC.CauseID = TD.CauseCodeMapID AND CC.IsDeleted = 0 AND CC.ProjectID = TD.ProjectID        
 INNER JOIN AVL.DEBT_MAP_ResolutionCode RC (NOLOCK)         
  ON RC.ResolutionID = TD.ResolutionCodeMapID AND RC.IsDeleted = 0 AND RC.ProjectID = TD.ProjectID       
 WHERE TD.DebtClassificationMode IN (3,4,5) AND TD.DARTStatusID = 8         
 --AND TD.ProjectID = 10337        
 AND CONVERT(DATE,TD.Closeddate) >= @JobStartDate AND CONVERT(DATE,TD.Closeddate) < @JobEndDate        
 AND PD.IsDDAutoClassified = 'Y'        
 AND TD.CauseCodeMapID IS NOT NULL         
 AND TD.ResolutionCodeMapID IS NOT NULL         
 AND TD.DebtClassificationMapID IS NOT NULL        
 AND TD.ResidualDebtMapID IS NOT NULL        
 AND TD.AvoidableFlag IS NOT NULL        
        
        
--Base Conflict patterns        
SELECT          
 TD.ApplicationID         
 ,TD.CauseCodeMapID        
 ,TD.ResolutionCodeMapID        
 ,TD.DebtClassificationMapID        
 ,TD.ResidualDebtMapID        
 ,TD.AvoidableFlag        
 ,TD.ProjectID         
 ,COUNT(1) AS RowCounts          
 INTO #TempBase        
 FROM #TempTicketDetail TD (NOLOCK)         
 GROUP BY         
 TD.ApplicationID        
 ,TD.CauseCodeMapID        
 ,TD.ResolutionCodeMapID        
 ,TD.DebtClassificationMapID        
 ,TD.ResidualDebtMapID        
 ,TD.AvoidableFlag        
 ,TD.ProjectID        
         
          
--select * FROm #TempBase        
   -----DD Table Conflicts------------      
 SELECT         
 projectid        
 ,ApplicationID        
 ,CauseCodeMapID        
 ,ResolutionCodeMapID        
 INTO #DDPattern        
 FROM #TempBase TB         
 GROUP BY         
 projectid        
 ,ApplicationID        
 ,CauseCodeMapID        
 ,ResolutionCodeMapID          
 HAVING COUNT(1) = 1      
      
 SELECT DC.ProjectID,DC.ApplicationID,DC.CauseCodeMapID,DC.ResolutionCodeMapID,TB.DebtClassificationMapID,        
TB.AvoidableFlag,TB.ResidualDebtMapID,TB.RowCounts INTO #TempDDConflictPattern        
 FROM #DDPattern DC INNER JOIN #TempBase TB         
 ON DC.ProjectID = TB.ProjectID        
 AND DC.ApplicationID = TB.ApplicationID        
 AND DC.CauseCodeMapID = TB.CauseCodeMapID        
 AND DC.ResolutionCodeMapID = TB.ResolutionCodeMapID      
       
SELECT B.ProjectID,B.ApplicationID,B.CauseCodeMapID,B.ResolutionCodeMapID,B.DebtClassificationMapID,        
B.AvoidableFlag,B.ResidualDebtMapID,B.RowCounts         
INTO #DDConflictPattern         
FROM [AVL].[Debt_MAS_ProjectDataDictionary] A JOIN #TempDDConflictPattern B ON A.ProjectID=B.ProjectID         
AND A.ApplicationID=B.ApplicationID AND A.CauseCodeID=B.CauseCodeMapID         
AND A.ResolutionCodeID=B.ResolutionCodeMapID WHERE A.IsDeleted=0       
      
DELETE CP FROM #DDConflictPattern CP JOIN [AVL].[Debt_MAS_ProjectDataDictionary] PDD        
ON CP.ApplicationID =PDD.ApplicationID AND CP.CauseCodeMapID=PDD.CauseCodeID        
AND CP.ResolutionCodeMapID=PDD.ResolutionCodeID AND CP.DebtClassificationMapID=PDD.DebtClassificationID        
AND CP.AvoidableFlag=PDD.AvoidableFlagID AND CP.ResidualDebtMapID=PDD.ResidualDebtID        
AND CP.ProjectID = PDD.ProjectID      
WHERE PDD.IsDeleted=0        
      
      
      
--Fetching Conflict patterns from base         
 SELECT         
 projectid        
 ,ApplicationID        
 ,CauseCodeMapID        
 ,ResolutionCodeMapID        
 --,TB.RowCounts        
 INTO #TempConflictBasePattern        
 FROM #TempBase TB --WHERE TB.projectid =10337         
 GROUP BY         
 projectid        
 ,ApplicationID        
 ,CauseCodeMapID        
 ,ResolutionCodeMapID        
 --,TB.RowCounts         
 HAVING COUNT(1) > 1        
         
        
--sELECT * fROM #TempConflictBasePattern        
        
 CREATE TABLE #TempFinalConflictBasePattern        
 (        
 [ProjectID] [bigint] NOT NULL,        
 [ApplicationID] [bigint] NOT NULL,        
 [CauseCodeID] [bigint] NOT NULL,        
 [ResolutionCodeID] [bigint] NOT NULL,        
 [DebtClassificationID] [bigint] NULL,        
 [ResidualDebtID] [int] NULL,        
 [AvoidableFlagID] [int] NULL,         
 [RowCounts] [int] NULL        
 )        
--conflict patterns with the respective debt outcomes        
 INSERT INTO #TempFinalConflictBasePattern         
 SELECT         
 TCB.projectid        
 ,TCB.ApplicationID        
 ,TCB.CauseCodeMapID        
 ,TCB.ResolutionCodeMapID        
 ,TB.DebtClassificationMapID        
 ,TB.ResidualDebtMapID        
 ,TB.AvoidableFlag,        
 TB.RowCounts           
 FROM #TempBase TB INNER JOIN #TempConflictBasePattern TCB         
  ON TB.ProjectID = TCB.ProjectID        
 AND TB.ApplicationID = TCB.ApplicationID        
 AND TB.CauseCodeMapID = TCB.CauseCodeMapID        
 AND TB.ResolutionCodeMapID = TCB.ResolutionCodeMapID        
      
 ---INSERT THE DD Conflict---------      
 INSERT INTO #TempFinalConflictBasePattern      
 SELECT ProjectID,      
 ApplicationID,      
 CauseCodeMapID,      
 ResolutionCodeMapID,      
 DebtClassificationMapID,        
 ResidualDebtMapID,      
 AvoidableFlag,      
 RowCounts         
 FROM #DDConflictPattern      
        
 SELECT DISTINCT ProjectID,ApplicationID,CauseCodeID,ResolutionCodeID,DebtClassificationID,ResidualDebtID,AvoidableFlagID,RowCounts INTO #FinalDDConflictPatterns      
 FROM #TempFinalConflictBasePattern      
        
 --SELECT * FROM #TempFinalConflictBasePattern        
SELECT COUNT(ProjectID) AS NoOfOccurence,ProjectID INTO #TempJobDetails FROM #FinalDDConflictPatterns GROUP BY ProjectID        
        
--merge and insert into DD conflict pattern table        
 MERGE [AVL].[DDConflictPatterns] AS TARGET        
 USING #FinalDDConflictPatterns AS SOURCE         
 ON (TARGET.projectid = SOURCE.projectid)        
 AND (TARGET.ApplicationID = SOURCE.ApplicationID)        
 AND (TARGET.CauseCodeID = SOURCE.CauseCodeID)        
 AND (TARGET.ResolutionCodeID = SOURCE.ResolutionCodeID)        
 AND (TARGET.DebtClassificationID = SOURCE.DebtClassificationID)        
 AND (TARGET.AvoidableFlagID = SOURCE.AvoidableFlagID)        
 AND (TARGET.ResidualDebtID = SOURCE.ResidualDebtID)        
 AND (TARGET.IsDeleted = 0)        
         
--When records are matched, add the occurence with the existing one        
 WHEN MATCHED         
 THEN UPDATE SET TARGET.NoOfOccurence = (TARGET.NoOfOccurence + SOURCE.RowCounts), TARGET.ModifiedBy = 'System', TARGET.ModifiedDate = GETDATE()        
--when records are not matched insert it        
 WHEN NOT MATCHED BY TARGET         
 THEN INSERT (ProjectID,ApplicationID,CauseCodeID,ResolutionCodeID,DebtClassificationID,        
 AvoidableFlagID,        
 ResidualDebtID        
 ,NoOfOccurence        
 ,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)        
 VALUES        
 (SOURCE.ProjectID,SOURCE.ApplicationID,SOURCE.CauseCodeID,SOURCE.ResolutionCodeID,SOURCE.DebtClassificationID,        
 SOURCE.AvoidableFlagID,        
 SOURCE.ResidualDebtID,SOURCE.RowCounts,0,'System',GETDATE(),NULL,NULL);        
        
        
--Conflicts inserted to trigger task        
 SELECT ProjectID,ApplicationID,CauseCodeID,ResolutionCodeID,DebtClassificationID,AvoidableFlagID,ResidualDebtID         
 INTO #TempNewConflictPatternsForTask         
 FROM [AVL].[DDConflictPatterns] (NOLOCK)         
 WHERE IsDeleted = 0         
 AND CreatedBy = 'System'        
 AND CONVERT(DATE,CreatedDate) = CONVERT(DATE,GETDATE())        
        
--Trigger task begin        
 SELECT DISTINCT LM.TSApproverID  AS 'EmployeeID',PM.EsaProjectID AS 'ESAProjectID',TC.ProjectID,PM.ProjectName,PM.CustomerID        
 INTO #TempTask         
 FROM #TempNewConflictPatternsForTask TC (NOLOCK)        
 INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON PM.ProjectID=TC.ProjectID AND PM.IsDeleted = 0        
 INNER JOIN AVL.MAS_LoginMaster LM (NOLOCK) ON PM.ProjectID=LM.ProjectID AND LM.IsDeleted = 0         
 AND (LM.TSApproverID IS NOT NULL AND LM.TSApproverID <> '')        
 GROUP BY TC.ProjectID,PM.ProjectName,LM.TSApproverID,PM.CustomerID,PM.EsaProjectID     
        
 SELECT DISTINCT LM.EmployeeID,TT.EsaProjectID,TT.ProjectID,TT.ProjectName,TT.CustomerID         
 INTO #TempTaskFinal        
 FROM #TempTask TT INNER JOIN AVL.MAS_LoginMaster LM (NOLOCK) ON LM.EmployeeID = TT.EmployeeID        
 AND LM.ProjectID = TT.ProjectID      
 AND LM.IsDeleted = 0        
        
        
 SELECT @ConflictTaskId=TaskID FROM dbo.taskmaster WHERE TaskName='DD Conflict Pattern';        
 SELECT @ConflictTaskName = taskname FROM dbo.taskmaster WHERE taskid=@ConflictTaskId;        
 SELECT @ConflictTaskUrl = taskurl FROM dbo.taskurl WHERE taskid=@ConflictTaskId AND IsDeleted=0;        
 SELECT @ConflictTaskApplication = applicationname FROM dbo.taskapplication WHERE taskid=@ConflictTaskId AND IsDeleted=0;        
      
            
       select DISTINCT LM.ProjectId,LM.HCMSupervisorId,    
    ' Conflicting patterns has been identified in Data dictionary for the project "'+ RTRIM(ESAProjectID) + '-' + ProjectName       
     +'" .Click the link to view it'      
       AS 'TaskDetails'    
     from #TempTaskFinal tf    
  join AVL.MAS_LoginMaster lm(nolock) on     
  lm.ProjectID = tf.ProjectID and lm.IsDeleted = 0    
  where LM.HCMSupervisorId is not null     
        
        
CREATE TABLE #TmpProjectwiseJobInsert        
(        
ProjectID BIGINT,        
NoOfPatterns BIGINT,        
NoOfOccurence BIGINT        
)        
          
INSERT INTO #TmpProjectwiseJobInsert(ProjectID,NoOfPatterns,NoOfOccurence)        
SELECT ProjectID,NoOfPatterns,0 FROM #TmpProjectwiseCount        
        
MERGE #TmpProjectwiseJobInsert AS PWI        
USING #TempJobDetails AS TJD        
ON PWI.ProjectID=TJD.ProjectID        
WHEN MATCHED THEN        
UPDATE SET PWI.NoOfOccurence=TJD.NoOfOccurence        
WHEN NOT MATCHED THEN        
INSERT(ProjectID,NoOfPatterns,NoOfOccurence)        
VALUES(TJD.ProjectID,0,TJD.NoOfOccurence);        
        
--TRIGGER TASK END          
        
        
        
/***INSERT INTO JOB STATUS TABLE***/        
INSERT INTO MAS.JobStatus(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate)        
Values(1,@JobStartDate,@JobEndDate,'Success',GETDATE(),0,'CLJob',GETDATE())        
        
select @ScopeId = Scope_Identity()        
--SET @JobTableID = (SELECT TOP 1 ID FROM [AVL].[CLInDDJobStatus] ORDER BY JobDate DESC)        
        
/***INSERT INTO job project wise trans table***/        
        
INSERT INTO [AVL].[CLInDDProjectWiseJobDetails]        
SELECT @ScopeId,ProjectID,NoOfPatterns,NoOfOccurence FROM #TmpProjectwiseJobInsert        
        
DROP TABLE #TmpDetails        
DROP TABLE #PatternsGTThreshold        
DROP TABLE #PatternsLTThrshold        
DROP TABLE #InvalidPatterns        
DROP TABLE #ConflictPatterns        
DROP TABLE #TmpProjectwiseCount        
DROP TABLE #TaskProject        
DROP TABLE #TaskToEnableDD        
DROP TABLE #TempTaskForDD        
DROP TABLE #TempTaskForDDFinal        
DROP TABLE #TaskForDDPattern        
DROP TABLE #TempTicketDetail        
DROP TABLE #TempBase        
DROP TABLE #TempConflictBasePattern        
DROP TABLE #TempFinalConflictBasePattern        
DROP TABLE #TempJobDetails        
DROP TABLE #TempTask        
DROP TABLE #TempTaskFinal        
DROP TABLE #TmpProjectwiseJobInsert        
DROP TABLE #DDPattern      
DROP TABLE #DDConflictPattern      
DROP TABLE #TempDDConflictPattern      
        
        
        
 COMMIT TRAN        
SET @Result = '1';        
SELECT @Result         
END TRY          
 BEGIN CATCH          
        
     ROLLBACK TRAN        
        
     DECLARE @ErrorMessage VARCHAR(MAX);        
        
  SELECT @ErrorMessage = ERROR_MESSAGE()        
        
  SELECT @ErrorMessage as ErrorMessage         
          
 /***INSERT INTO JOB STATUS TABLE***/        
INSERT INTO MAS.JobStatus(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate)        
Values(1,@JobStartDate,@JobEndDate,'Failed',GETDATE(),0,'CLJob',GETDATE())        
        
  --INSERT Error            
  EXEC AVL_InsertError '[AVL].[CLDDPatternIdentificationJob]', @ErrorMessage, 0,0          
        
 DECLARE @Subjecttext VARCHAR(max);          
 DECLARE @tableHTML  VARCHAR(MAX);        
        
 SET @Subjecttext = 'Continuous Learning in Data Dictionary Job failure'        
 SET @tableHTML ='<html style="width:auto !important">'+        
   '<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">'+        
   '<table width="650" face="Times New Roman,serif" border="0" cellpadding="0" cellspacing="0" style="margin-left:60px;font-family:sans-serif;font-size:14px;font-weight:normal">'+        
   '<tbody>'+        
   '<tr>'+        
   '<td valign="top" style="padding: 0;">'+        
   '<div align="center" style="text-align: center;">'+        
   '<table width="650" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">'+        
   '<tbody>'+        
     '<tr style="height:50px">'+        
                                    '<td width="auto" valign="top" align="center">'+        
                                     '<img src="\\CTSC01165050301\WeeklyUAT\ApplensBanner.png" width="700" height="50" style="border-width: 0px;"/>'+        
                                    '</td>'+        
    '</tr>'+        
            
     '<tr style="background-color:#F0F8FF">'+        
                                    '<td valign="top" style="padding: 0;">'+        
                                        '<div align="center" style="text-align: center;margin-left:50px">'+        
                                            '<table width="650" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">'+        
                                                       
             '<tbody>'+        
             '</br>'+        
                                                          
             N'<left>         
                    
          <font-weight:normal>        
                  
           Hi All,'        
           + '</BR>'        
           +'&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp'        
           +'</BR>'        
           +'Data dictionary Pattern Job failure in '        
            +'<font color="#000000"><b>SP - [AVL].[CLDDPatternIdentificationJob]</b></font>'        
           +'</BR>'        
           +'</BR>'        
           +'Exception Message: '+@ErrorMessage+        
           +'</BR>'        
           +'</BR>'        
           +'Requesting you to check this issue details in Errors log table'        
           +'</BR>'        
           +'</BR>'        
           +'PS : This is system generated mail, please do not reply to this mail.'        
           +'</font>          
        </Left>'         
                  +        
          N'        
                
        <p align="left">          
        <font color="Black" Size = "2" font-weight=bold>          
        <b> Thanks & Regards,</b>        
         </font>         
         </BR>        
         Solution Zone Team           
          </BR>        
          </BR>        
           <font size="1">                
       **This is an Auto Generated Mail. Please Do not reply to this mail**        
       </font>        
       </p>' +           
               
        
                                                '</tbody>'+        
                                            '</table>'+        
                                        '</div>'+        
                                   '</td>'+        
                     '</tr>'+        
   '</tbody>'+        
   '</table>'+        
   '</div>'+        
   '</td>'+        
   '</tr>'+        
   '</tbody>'+        
   '</table>'+        
   '</body>' +        
   '</html>'        
           
   -----------executing mail-------------        
   DECLARE @recipientsAddress NVARCHAR(4000)='';        
            SET @recipientsAddress = (SELECT ConfigValue FROM AVL.AppLensConfig WHERE ConfigName='Mail' AND IsActive=1);           
      EXEC [AVL].[SendDBEmail] @To=@recipientsAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@Subjecttext,
    @Body = @tableHTML        
   SET @Result = '0';        
  SELECT @Result        
 END CATCH             
SET NOCOUNT OFF;      
END


