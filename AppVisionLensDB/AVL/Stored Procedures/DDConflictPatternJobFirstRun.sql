
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[DDConflictPatternJobFirstRun]
AS
BEGIN
DECLARE @Result BIT;
BEGIN TRY
BEGIN TRAN

--To get job start and end date
DECLARE @JobTableID INT,@JobStartDate DATE, @JobEndDate DATE

SET @JobStartDate=(SELECT DATEADD(dd, DATEPART(DW,GETDATE())*-1-27, GETDATE()))

SET @JobEndDate=(SELECT GETDATE())



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
	AND CONVERT(DATE,TD.Closeddate) >= @JobStartDate AND CONVERT(DATE,TD.Closeddate) <  @JobEndDate
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


	----------DD pattern table Conflicts--------
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


	---------------------------------------

	
		
--select * FROm #TempBase

--Fetching Conflict patterns from base	
	SELECT 
	projectid
	,ApplicationID
	,CauseCodeMapID
	,ResolutionCodeMapID
	--,TB.RowCounts
	INTO #TempConflictBasePattern
	FROM #TempBase TB 
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

	--SELECT * FROM #TempFinalConflictBasePattern
SELECT COUNT(ProjectID) AS NoOfOccurence,ProjectID INTO #TempJobDetails FROM #TempFinalConflictBasePattern GROUP BY ProjectID

--merge and insert into DD conflict pattern table
	MERGE [AVL].[DDConflictPatterns] AS TARGET
	USING #TempFinalConflictBasePattern AS SOURCE 
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

	--SELECT * FROM [AVL].[DDConflictPatterns]
	--SELECT * FROM #TempFinalConflictBasePattern

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


	DECLARE @TaskName VARCHAR(500),@TaskUrl VARCHAR(max),@TaskApplication VARCHAR(500),@TaskStatus VARCHAR(100),@TaskType VARCHAR(100);
	DECLARE @TaskId INT = 30;
	SELECT @TaskName = taskname FROM dbo.taskmaster WHERE taskid=@TaskId;
	SELECT @TaskUrl = taskurl FROM dbo.taskurl WHERE taskid=@TaskId AND IsDeleted=0;
	SELECT @TaskApplication = applicationname FROM dbo.taskapplication WHERE taskid=@TaskId AND IsDeleted=0;
	SELECT @TaskStatus = STATUS FROM dbo.taskstatus WHERE taskstatusid=1 AND IsDeleted=0;
	SELECT @TaskType = tasktype FROM dbo.tasktype WHERE tasktypeid=1 AND IsDeleted=0;


	INSERT INTO AVL.MyTasksCLInDD 
	SELECT  EmployeeID AS'UserId'
       ,@TaskId AS 'TaskId'
	   ,@TaskName AS 'TaskName'
	   ,@TaskUrl AS 'TaskUrl'
       ,' The DD patterns are identified to have conflicts for the Project  "'+ RTRIM(ESAProjectID) + ': ' + ProjectName 
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
	    #TempTaskFinal
-- insert into job main table
--		INSERT INTO [AVL].[CLInDDJobStatus] VALUES(@JobStartDate,@JobEndDate,'Success',GETDATE(),0,'System',GETDATE())
--		SET @JobTableID = (SELECT TOP 1 ID FROM [AVL].[CLInDDJobStatus] ORDER BY JobDate DESC)
---- insert into job project wise trans table
--		INSERT INTO [AVL].[CLInDDProjectWiseJobDetails] 
--		SELECT @JobTableID,ProjectID,0,NoOfOccurence FROM #TempJobDetails
		 

--Trigger task end
		DROP TABLE #TempTicketDetail
		DROP TABLE #TempBase
		DROP TABLE #TempConflictBasePattern
		DROP TABLE #TempFinalConflictBasePattern
		DROP TABLE #TempTask
		DROP TABLE #TempTaskFinal
		DROP TABLE #TempJobDetails		
		
COMMIT TRAN
SET @Result = 1;
SELECT @Result 
END TRY  
	BEGIN CATCH  

	    DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage as ErrorMessage
		
		ROLLBACK TRAN

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[DDConflictPatternJobFirstRun]', @ErrorMessage, 0,0

		/***INSERT INTO JOB STATUS TABLE***/  
		INSERT INTO MAS.JobStatus(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate)  
		Values(1,@JobStartDate,@JobEndDate,'Failed',GETDATE(),0,'CLJob',GETDATE()) 
		

	DECLARE @Subjecttext VARCHAR(MAX);  
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
										  +'<font color="#000000"><b>[AVL].[DDConflictPatternJobFirstRun]</b></font>'
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
		SET @Result = 0;
		SELECT @Result 
	END CATCH  
END


