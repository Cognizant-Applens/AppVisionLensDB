CREATE PROCEDURE [dbo].[EDSTimesheetDetail_Refresh]
  
AS  
  
BEGIN TRY  
  
BEGIN TRANSACTION  
    
	SELECT * INTO #EDSTimesheetDetail_All
	FROM DiscoverEDS.EDS.TimesheetDetail_All WITH (NOLOCK)
	WHERE TimesheetSubmissionDate >= DATEADD(YEAR, -1, GETDATE())

	TRUNCATE TABLE dbo.TimesheetDetail_All
	 
	--SELECT * FROM dbo.TimesheetDetail_All ORDER BY CreatedDate
   
	INSERT INTO [dbo].[TimesheetDetail_All]
			   ([EsaProjectID]
			   ,[ProjectName]
			   ,[ActivityCode]
			   ,[ActivityDescription]
			   ,[Hours]
			   ,[SubmitterID]
			   ,[TimesheetSubmissionDate]
			   ,[TimesheetStatus]
			   ,[Submitterdate]
			   ,[CreatedBy]
			   ,[CreatedDate]
			   ,[ModifiedBy]
			   ,[ModifiedDate])
	SELECT		[EsaProjectID]
			   ,[ProjectName]
			   ,[ActivityCode]
			   ,[ActivityDescription]
			   ,[Hours]
			   ,[SubmitterID]
			   ,[TimesheetSubmissionDate]
			   ,[TimesheetStatus]
			   ,[Submitterdate]
			   ,[CreatedBy]
			   ,[CreatedDate]
			   ,'Job'
			   ,GETDATE()
	from #EDSTimesheetDetail_All

--Send Success mail notification    
 --DECLARE @MailSubject VARCHAR(MAX);        
 --DECLARE @MailBody  VARCHAR(MAX);      
         
 --SELECT @MailSubject = CONCAT(@@servername, ' EDSTimesheetDetail_Refresh - Job Success Notification')      
 --SELECT @MailBody = '<font color="Black" face="Arial" Size = "2">Hi Team,<br><br>EDS Timesheet data succesfully synced from Discover EDS to Appvisionlens!<br><br>  
 --     Regards,<br>Applens Support Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>'       
     
 --EXEC msdb.dbo.sp_send_dbmail @recipients = 'AVMCoEL1Team@cognizant.com;AVMDARTL2@cognizant.com,ApplensQlik@cognizant.com',   
 --@profile_name ='ApplensSupport',      
 --@subject = @MailSubject,      
 --@body = @MailBody,      
 --@body_format = 'HTML';   
 
 DROP TABLE #EDSTimesheetDetail_All

COMMIT TRANSACTION
  
END TRY  
  
BEGIN CATCH  
  
 ROLLBACK TRANSACTION  
   
 --DECLARE @ErrorMessage VARCHAR(MAX);             
 --SELECT @ErrorMessage = ERROR_MESSAGE()             
   
 ----Send failure mail notification    
 --DECLARE @MailSubjectFailure VARCHAR(MAX);        
 --DECLARE @MailBodyFailure  VARCHAR(MAX);      
         
 --SELECT @MailSubjectFailure = CONCAT(@@servername, ' EDSTimesheetDetail_Refresh - Job Failure Notification')      
 --SELECT @MailBodyFailure = CONCAT('<font color="Black" face="Arial" Size = "2">Hi Team, <br><br>Oops! Error occurred while syncing timesheet data from DiscoverEDS to Appvisionlens!<br>      
 --       <br>Error: ', @ErrorMessage,      
 --       '<br><br>Regards,<br>Applens Support Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')      
     
 --EXEC msdb.dbo.sp_send_dbmail @recipients = 'AVMCoEL1Team@cognizant.com;AVMDARTL2@cognizant.com,ApplensQlik@cognizant.com',      
 --@profile_name ='ApplensSupport',      
 --@subject = @MailSubjectFailure,      
 --@body = @MailBodyFailure,      
 --@body_format = 'HTML';        
    
END CATCH




