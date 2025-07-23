
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : Dhivya Bharathi M
-- Create date : Jan 3, 2020
-- Description :          
-- Test        : AVL.NonDeliverySuggestedActivityJob 'DhivyaBharathi.M@cognizant.com;Suganya.Thangavel3@cognizant.com'
-- Revision    :
-- Revised By  :
-- =========================================================================================

CREATE PROCEDURE [AVL].[NonDeliverySuggestedActivityJob]
@MailerRecipients NVARCHAR(4000)
AS 
  BEGIN 
	BEGIN TRY 
		SET NOCOUNT ON;
		DECLARE @MasterJobID BIGINT;
		DECLARE @LastRunJobID BIGINT;
		DECLARE @RecentJobID BIGINT;
		DECLARE @JobName NVARCHAR(100)='Non Delivery Suggested Activity Job';
		DECLARE @LastJobRunDate DATETIME =NULL;
		DECLARE @JobStatusSuccess varchar(10)='Success'
		DECLARE @JobStatusFailed varchar(10)='Failed'
		DECLARE @InsertedCount INT= 0;
		CREATE TABLE #SuggestedActivities
		(
		ProjectID BIGINT NOT NULL,
		ProjectName NVARCHAR(50) NULL,
		SuggestedActivityName NVARCHAR(50) NULL
		)
		set @MasterJobID=(SELECT JobID FROM [MAS].[JobMaster] WHERE JobName=@JobName)

		SET @LastRunJobID=(SELECT TOP 1 ID FROM MAS.JobStatus WHERE JobId=@MasterJobID
					AND JobStatus= 'Success'
					ORDER BY CreatedDate DESC)
		SET @LastJobRunDate=(SELECT JobRunDate FROM MAS.JobStatus WHERE JobId=@MasterJobID
					AND JobStatus= 'Success'
					AND ID=@LastRunJobID)
		INSERT INTO  MAS.JobStatus(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate) 
		VALUES (@MasterJobID,GETDATE(),'','',GETDATE(),0,@JobName,GETDATE())

		SET @RecentJobID  = SCOPE_IDENTITY();

		IF @LastRunJobID IS NULL
		BEGIN
			INSERT INTO #SuggestedActivities
			SELECT DISTINCT EsaProjectID,PM.ProjectName,NSA.SuggestedActivityName 
			FROM AVL.TM_NonDeliverySuggestedActivity(NOLOCK) NSA
			INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON NSA.ProjectID=PM.ProjectID 
			WHERE ISNULL(NSA.IsDeleted,0)=0  AND ISNULL(PM.IsDeleted,0) =0 
			ORDER BY PM.ProjectName,NSA.SuggestedActivityName  ASC
		END
		ELSE
		BEGIN

			INSERT INTO #SuggestedActivities
			SELECT DISTINCT EsaProjectID,PM.ProjectName,NSA.SuggestedActivityName  
			FROM AVL.TM_NonDeliverySuggestedActivity(NOLOCK) NSA
			INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON NSA.ProjectID=PM.ProjectID 
			WHERE ISNULL(NSA.IsDeleted,0)=0 
			AND ((CONVERT(DATETIME,CreatedDateTime) >=  CONVERT(DATETIME,@LastJobRunDate) OR
				(CONVERT(DATETIME,ModifiedDateTime) >=  CONVERT(DATETIME,@LastJobRunDate))))
			ORDER BY PM.ProjectName,NSA.SuggestedActivityName ASC
		END
		SET @InsertedCount =(SELECT COUNT(SuggestedActivityName) FROM #SuggestedActivities)
		IF EXISTS (SELECT SuggestedActivityName FROM #SuggestedActivities)
		BEGIN
			DECLARE @tableHTML  NVARCHAR(MAX);
			DECLARE @Subjecttext NVARCHAR(4000);  	
			SET @Subjecttext = 'Non Delivery Activity list'	;
			---------------mailer body---------------

			SET @tableHTML =
				'<html style="width:auto !important">'+
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
							Hi Team,'
							+ '</BR>'
							+'&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp'
							+'</BR>'
							+'Please find the below Non delivery activity suggested by the projects.'
							+'</BR>'
							+'</BR>'
							+ N'<Center>  
								<table style="border:1px solid black;border-collapse:collapse;" CELLPADDING="5" CELLSPACING="0" bordercolor = "#000011" border = "1">  
								<font color="Black" face="Arial" Size = "2">'  
								+ N'<tr>'  
								+ N'<th Width = "200px" bgcolor = "#4D317E" bordercolor = "#000000" CELLPADDING="0" CELLSPACING="0">  
								<font color="White" face="Arial" Size = "2">Esa Project Id</font>  
								</th>'  
								+ N'<th Width = "200px" bgcolor = "#4D317E" bordercolor = "#000000" CELLPADDING="0" CELLSPACING="0">  
								<font color="White" face="Arial" Size = "2">Project Name</font>  
								</th>'  
								+ N'<th Width = "200px" bgcolor = "#4D317E" bordercolor = "#000000" CELLPADDING="0" CELLSPACING="0">  
								<font color="White" face="Arial" Size = "2">Suggested Activity Name</font>  
								</th>'  
								SET @tableHTML = @tableHTML  
								+ CAST(( SELECT td = ISNULL(ProjectID, 0), '',  
								td = ISNULL(ProjectName, ''), '',  
								td = ISNULL(SuggestedActivityName, ''), '' 
								FROM #SuggestedActivities  
								ORDER BY ProjectName,SuggestedActivityName
								FOR  
								XML PATH('tr') ,  
								TYPE  
								) AS NVARCHAR(MAX)) + N'  
								</font>  
								</Center></table>'  
							+'</BR>'										
							+'</font>  
							</Left>' 
							+ N'
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
			
			-------------executing mail-------------
			EXEC [AVL].[SendDBEmail] @To=@MailerRecipients,
    @From='ApplensSupport@cognizant.com',
    @Subject =@Subjecttext,
    @Body = @tableHTML


			IF OBJECT_ID('tempdb..#SuggestedActivities', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #SuggestedActivities
			END
			SET NOCOUNT OFF;
	END
		UPDATE MAS.JobStatus SET EndDateTime = GETDATE(),JobStatus = @JobStatusSuccess,InsertedRecordCount=@InsertedCount
		WHERE ID  = @RecentJobID
	END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
		UPDATE MAS.JobStatus set EndDateTime = GETDATE(),JobStatus = @JobStatusFailed where ID  = @RecentJobID
        --INSERT Error     
        EXEC AVL_INSERTERROR  'AVL.NonDeliverySuggestedActivityJob', @ErrorMessage,  0, 
        0 
    END CATCH 
  END


