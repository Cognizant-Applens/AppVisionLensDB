


/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[UniquePatternFirstJob]
AS
BEGIN
DECLARE @Result BIT;
BEGIN TRY
BEGIN TRAN
DECLARE @ScopeId INT
DECLARE @TaskName VARCHAR(500),@TaskUrl VARCHAR(max),@TaskApplication VARCHAR(500),@TaskStatus VARCHAR(100),@TaskType VARCHAR(100);
DECLARE @TaskId INT;
DECLARE @TaskNameForPattern VARCHAR(500),@TaskUrlForPattern  VARCHAR(max),@TaskApplicationForPattern  VARCHAR(500);
DECLARE @TaskIdForPattern INT;
DECLARE @JobTableID INT;

DELETE FROM [AVL].[MyTasksCLInDD]

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


DECLARE @JobEndDate DATE;
DECLARE @JobStartDate DATE;
SET @JobEndDate=(SELECT GETDATE())
SET @JobStartDate=(SELECT DATEADD(wk, 0, DATEADD(wk, DATEDIFF(wk, 0,GETDATE()-5), -1)))



/***BASE FILTER CONDITIONS***/



SELECT DISTINCT TD.ProjectID,
TD.ApplicationID,
CauseCodeMapID,
ResolutionCodeMapID,
DebtClassificationMapID,
AvoidableFlag,
ResidualDebtMapID,
Count(TD.ProjectID) 'NoOfPatterns'
INTO #TmpDetails
FROM AVL.TK_TRN_TicketDetail(NOLOCK) TD 
JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON TD.ProjectID=PM.ProjectID
JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDD ON PM.ProjectID=PDD.ProjectID
INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) MAD ON MAD.ApplicationID = TD.ApplicationID AND MAD.IsActive = 1
JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) APM ON TD.ProjectID=APM.ProjectID AND TD.ApplicationID=APM.ApplicationID and APM.IsDeleted=0
JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON TD.ProjectID=CC.ProjectID AND TD.CauseCodeMapID=CC.CauseID AND CC.IsDeleted=0
JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC ON TD.ProjectID=CC.ProjectID AND TD.ResolutionCodeMapID=RC.ResolutionID AND RC.IsDeleted=0
WHERE CauseCodeMapID is not null AND 
ResolutionCodeMapID is not null AND DebtClassificationMapID is not null 
AND AvoidableFlag is not null AND ResidualDebtMapID is not null
AND TD.DARTStatusID=8
AND PM.IsDebtEnabled='Y' AND (TD.DebtClassificationMode=4 OR TD.DebtClassificationMode=5)
AND CONVERT(DATE,TD.Closeddate) >=
CASE WHEN (PDD.IsDDAutoClassified='Y' AND IsDDAutoClassifiedDate IS NOT NULL) THEN PDD.IsDDAutoClassifiedDate
ELSE PDD.DebtEnablementDate
END
AND CONVERT(DATE,TD.Closeddate) < @JobEndDate
GROUP BY TD.ProjectID,TD.ApplicationID,CauseCodeMapID,
ResolutionCodeMapID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID



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
UPDATE PD SET PD.IsDDAutoClassified='Y',PD.IsDDAutoClassifiedDate=GETDATE(),PD.IsDDAutoClassifiedBy='system',PD.ModifiedBy='system',PD.IsTicketApprovalNeeded='N',PD.ModifiedDate=GETDATE()
FROM AVL.MAS_ProjectDebtDetails PD JOIN #TmpProjectwiseCount DE ON PD.ProjectID=DE.ProjectID
WHERE IsDDAutoClassified!='Y'

------***TASK TO ENABLE DD***----------
SELECT DISTINCT A.TSApproverID,A.PROJECTID INTO #TaskToEnableDD FROM AVL.MAS_LoginMaster A JOIN #TaskProject B
ON A.ProjectID=B.ProjectID AND A.IsDeleted=0 AND (A.TSApproverID IS NOT NULL AND A.TSApproverID <> '')

SELECT DISTINCT LM.EmployeeID,TE.ProjectID,LM.IsDeleted,PM.EsaProjectID,PM.ProjectName,LM.CustomerID INTO #TempTaskForDD FROM AVL.MAS_LoginMaster LM 
JOIN #TaskToEnableDD TE ON LM.ProjectID=TE.ProjectID AND LM.EmployeeID=TE.TSApproverID
JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON TE.ProjectID=PM.ProjectID
WHERE LM.IsDeleted=0

--------TASK FOR Enabling DD-------------

INSERT INTO [AVL].[MyTasksCLInDD]
SELECT  EmployeeID AS'UserId'
       ,@TaskId AS 'TaskId'
	   ,@TaskName AS 'TaskName'
	   ,@TaskUrl AS 'TaskUrl'
       ,' The Data Dictionary has been Auto enable for the Project  "'+ RTRIM(ESAProjectID) + '-' + ProjectName 
	     +'". Click here to view the Details'
         AS 'TaskDetails'
       ,@TaskApplication AS 'Application'
       ,@TaskStatus AS 'Status'
       ,GETDATE() AS 'RefreshedTime'
       ,'System' AS 'CreatedBy'
       , GETDATE() AS 'CreatedTime'
       ,NULL AS 'ModifiedBy'
       ,NULL AS 'ModifiedTime'
       ,@TaskType AS 'TaskType'
       ,NULL AS 'ExpiryDate'
       ,NULL AS 'DueDate' --- Due Date
       ,'N' AS 'Read'
       ,2 AS 'ExpiryAfterRead'
       ,CustomerID AS 'Accountid'
   FROM
	    #TempTaskForDD 
 
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



INSERT INTO [AVL].[MyTasksCLInDD]
SELECT  EmployeeID AS'UserId'
       ,@TaskIdForPattern AS 'TaskId'
	   ,@TaskNameForPattern AS 'TaskName'
	   ,@TaskUrlForPattern AS 'TaskUrl'
       ,' The Data Dictionary Patterns ('+ NoOfPatterns +') are created by system from the Manual debt classified tickets for the Project "'+ RTRIM(ESAProjectID) + '-' + ProjectName 
	     +'". Click here to view the Details'
         AS 'TaskDetails'
       ,@TaskApplicationForPattern AS 'Application'
       ,@TaskStatus AS 'Status'
       ,GETDATE() AS 'RefreshedTime'
       ,'System' AS 'CreatedBy'
       , GETDATE() AS 'CreatedTime'
       ,NULL AS 'ModifiedBy'
       ,NULL AS 'ModifiedTime'
       ,@TaskType AS 'TaskType'
       ,NULL AS 'ExpiryDate'
       ,NULL AS 'DueDate' --- Due Date
       ,'N' AS 'Read'
       ,2 AS 'ExpiryAfterRead'
       ,CustomerID AS 'Accountid'
   FROM
	    #TempTaskForDDFinal   


/***INSERT INTO JOB STATUS TABLE***/
INSERT INTO MAS.JobStatus(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate)
Values(1,@JobStartDate,@JobEndDate,'Success',GETDATE(),0,'CLJob',GETDATE())

select @ScopeId = Scope_Identity()

/***INSERT PROJECTWISE PATTERN COUNT***/

INSERT INTO [AVL].[CLInDDProjectWiseJobDetails]
SELECT @ScopeId,ProjectID,NoOfPatterns,0 FROM #TmpProjectwiseCount

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

COMMIT TRAN
SET @Result = '1';
SELECT @Result
END TRY  
BEGIN CATCH 
DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage as ErrorMessage
		
		ROLLBACK TRAN

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[UniquePatternFirstJob]', @ErrorMessage, 0,0
		/***INSERT INTO JOB STATUS TABLE***/  
		INSERT INTO MAS.JobStatus(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate)  
		Values(1,@JobStartDate,@JobEndDate,'Failed',GETDATE(),0,'CLJob',GETDATE()) 

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
END


