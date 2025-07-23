

/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[DDConflictPatternJob]
AS
BEGIN
BEGIN TRY
BEGIN TRAN

--To get job start and end date
DECLARE @JobTableID INT,@JobStartDate DATE, @JobEndDate DATE, @IsSuccess NVARCHAR(50)
SET @IsSuccess = (SELECT TOP 1 JobStatus FROM [AVL].[CLInDDJobStatus] ORDER BY JobDate DESC)
IF(@IsSuccess = 'Success')
	BEGIN
		SET @JobStartDate = (SELECT DATEADD(DAY, DATEDIFF(DAY, -1, GETDATE()) / 7 * 7, -1)) 

		SET @JobEndDate = (SELECT DATEADD(DAY, DATEDIFF(DAY, -1, GETDATE()) / 7 * 7, 5)) 

	END
ELSE IF (@IsSuccess = 'Failed')
	BEGIN
		SET @JobStartDate = (SELECT TOP 1 EndDateTime FROM [AVL].[CLInDDJobStatus] WHERE JobStatus = 'Success' ORDER BY JobDate DESC)

		SET @JobEndDate = (SELECT DATEADD(DAY, DATEDIFF(DAY, -1, GETDATE()) / 7 * 7, 5)) 
	END

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
	INNER JOIN [AVL].[MAS_ProjectMaster] PM (NOLOCK) ON TD.ProjectID = PM.ProjectID AND PM.IsDeleted = 0 AND TD.IsDeleted = 0 
	INNER JOIN AVL.MAS_ProjectDebtDetails PD (NOLOCK) ON PM.ProjectID = PD.ProjectID AND PD.IsDeleted = 0
	INNER JOIN AVL.APP_MAS_ApplicationDetails MAD (NOLOCK) ON MAD.ApplicationID = TD.ApplicationID AND MAD.IsActive = 1
	INNER JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APM ON MAD.ApplicationID = APM.ApplicationID AND APM.IsDeleted = 0
	INNER JOIN AVL.DEBT_MAP_CauseCode CC (NOLOCK) ON CC.CauseID = TD.CauseCodeMapID AND CC.IsDeleted = 0
	INNER JOIN AVL.DEBT_MAP_ResolutionCode RC (NOLOCK) ON RC.ResolutionID = TD.ResolutionCodeMapID AND RC.IsDeleted = 0
	WHERE TD.DebtClassificationMode IN (3,4,5) AND TD.DARTStatusID = 8 
	AND TD.Closeddate BETWEEN @JobStartDate AND @JobEndDate
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
	,COUNT(*) AS RowCounts		
	INTO #TempBase
	FROM #TempTicketDetail TD (NOLOCK)	
	GROUP BY TD.ApplicationID
	,TD.CauseCodeMapID
	,TD.ResolutionCodeMapID
	,TD.DebtClassificationMapID
	,TD.ResidualDebtMapID
	,TD.AvoidableFlag
	,TD.ProjectID
	
		
--select * FROm #TempBase

	CREATE TABLE #TempConflictBasePattern
	(
	[ProjectID] [bigint] NOT NULL,
	[ApplicationID] [bigint] NOT NULL,
	[CauseCodeID] [bigint] NOT NULL,
	[ResolutionCodeID] [bigint] NOT NULL,	
	[RowCounts] [int] NULL
	)

--Fetching Conflict patterns from base
	INSERT INTO #TempConflictBasePattern
	SELECT projectid,ApplicationID,CauseCodeMapID,ResolutionCodeMapID,
	TB.RowCounts  	
	FROM #TempBase TB --WHERE TB.projectid =10337 
	GROUP BY projectid,ApplicationID,CauseCodeMapID,ResolutionCodeMapID
	,TB.RowCounts 
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
	SELECT TCB.projectid,TCB.ApplicationID,TCB.CauseCodeID,TCB.ResolutionCodeID,TB.DebtClassificationMapID
	,TB.ResidualDebtMapID
	,TB.AvoidableFlag,
	TCB.RowCounts  	
	FROM #TempBase TB INNER JOIN #TempConflictBasePattern TCB ON TB.ProjectID = TCB.ProjectID
	AND TB.ApplicationID = TCB.ApplicationID
	AND TB.CauseCodeMapID = TCB.CauseCodeID
	AND TB.ResolutionCodeMapID = TCB.ResolutionCodeID


	--SELECT * FROM #TempFinalConflictBasePattern
SELECT COUNT(*) AS NoOfOccurence,ProjectID INTO #TempJobDetails FROM #TempFinalConflictBasePattern GROUP BY ProjectID

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
	AND LM.IsDeleted = 0


	DECLARE @TaskName VARCHAR(500),@TaskUrl VARCHAR(max),@TaskApplication VARCHAR(500),@TaskStatus VARCHAR(100),@TaskType VARCHAR(100);
	DECLARE @TaskId INT = 30;
	SELECT @TaskName = taskname FROM dbo.taskmaster WHERE taskid=@TaskId;
	SELECT @TaskUrl = taskurl FROM dbo.taskurl WHERE taskid=@TaskId AND IsDeleted=0;
	SELECT @TaskApplication = applicationname FROM dbo.taskapplication WHERE taskid=@TaskId AND IsDeleted=0;
	SELECT @TaskStatus = STATUS FROM dbo.taskstatus WHERE taskstatusid=2 AND IsDeleted=0;
	SELECT @TaskType = tasktype FROM dbo.tasktype WHERE tasktypeid=2 AND IsDeleted=0;


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
       ,GETDATE() AS 'DueDate' --- Due Date
       ,'N' AS 'Read'
       ,0 AS 'ExpiryAfterRead'
       ,CustomerID AS 'Accountid'
   FROM
	    #TempTaskFinal
-- insert into job main table
		INSERT INTO [AVL].[CLInDDJobStatus] VALUES(@JobStartDate,@JobEndDate,'Success',GETDATE(),0,'System',GETDATE())
		SET @JobTableID = (SELECT TOP 1 ID FROM [AVL].[CLInDDJobStatus] ORDER BY JobDate DESC)
-- insert into job project wise trans table
		INSERT INTO [AVL].[CLInDDProjectWiseJobDetails] 
		SELECT @JobTableID,ProjectID,0,NoOfOccurence FROM #TempJobDetails
		 

--Trigger task end
		DROP TABLE #TempTicketDetail
		DROP TABLE #TempBase
		DROP TABLE #TempConflictBasePattern
		DROP TABLE #TempFinalConflictBasePattern
		DROP TABLE #TempTask
		DROP TABLE #TempTaskFinal
		DROP TABLE #TempJobDetails
COMMIT TRAN

END TRY  
	BEGIN CATCH  

	    DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage as ErrorMessage
		
		ROLLBACK TRAN

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[DDConflictPatternJob]', @ErrorMessage, 0,0

		INSERT INTO [AVL].[CLInDDJobStatus] VALUES(@JobStartDate,@JobEndDate,'Failed',GETDATE(),0,'System',GETDATE())
		

	DECLARE @Subjecttext VARCHAR(MAX);  
	DECLARE @tableHTML  VARCHAR(MAX);

	SET @Subjecttext = 'Data dictionary Conflict Pattern Job failure'
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
										 +'Data dictionary CL Conflict Pattern Job failure in '
										  +'<font color="#000000"><b>[AVL].[DDConflictPatternJob]</b></font>'
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
		
	END CATCH  
END


