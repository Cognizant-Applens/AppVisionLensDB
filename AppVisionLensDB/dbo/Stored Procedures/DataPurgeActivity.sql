

CREATE PROCEDURE [dbo].[DataPurgeActivity]
AS
BEGIN
BEGIN TRY
	
	DECLARE @Cursor CURSOR;
	DECLARE @ServerName NVARCHAR(25);
	DECLARE @DatabaseName NVARCHAR(25);
	DECLARE @TableName NVARCHAR(100);
	DECLARE @ConditionColumnName NVARCHAR(25);
	DECLARE @DataRetainedDays INT;
	DECLARE @RetainedDate NVARCHAR(25);
	DECLARE @SQL NVARCHAR(max)
	DECLARE @SQL_UPDATE NVARCHAR(max)
	DECLARE @SQL_SELECT NVARCHAR(max)
	DECLARE @Month_Start_Date DATE
	DECLARE @Year_Start_Date DATE
	DECLARE @Today_Date DATE
	DECLARE @JobID INT
	DECLARE @JobName VARCHAR(50) = 'DataPurgeActivity'
	DECLARE @Failed VARCHAR(10) ='Failed'
				
	DECLARE @MailSubject_Started NVARCHAR(500);		
	DECLARE @MailBody_started NVARCHAR(MAX);				
	DECLARE @MailContent_started NVARCHAR(500);
	DECLARE @MailSubject_Completed NVARCHAR(500);		
	DECLARE @MailBody_Completed NVARCHAR(MAX);				
	DECLARE @MailContent_Completed NVARCHAR(500);
	
	SET @Month_Start_Date=DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)
	SET @Year_Start_Date= DATEADD(yy, DATEDIFF(yy, 0, convert(varchar, getdate(), 23)), 0)
	SET @Today_Date=CONVERT(date, GETDATE()) 

	SELECT @JobID = JobID FROM [MAS].JobMaster WHERE JobName =@JobName
	
	SELECT @MailSubject_Started = CONCAT(@@servername, ':  DataPurgeActivity')			
		
	SET @MailContent_started = 'DataPurgeActivity Job has been Started .'

	SELECT @MailBody_started =  [dbo].[fn_FmtEmailBody_Message](@MailContent_started)
	EXEC [AVL].[SendDBEmail] @To='AVMDARTL2@cognizant.com;AVMCoEL1Team@cognizant.com',
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject_Started,
    @Body = @MailBody_started

	BEGIN
	BEGIN TRANSACTION

	IF (@Today_Date !=@Month_Start_Date AND @Today_Date !=@Year_Start_Date)
	BEGIN		
		SET @Cursor = CURSOR FOR
		SELECT ServerName,DatabaseName,TableName,ConditionColumnName,DataRetainedDays 
		FROM MAS.DataPurgeActvityMaster WITH(NOLOCK)
		WHERE ScheduledFrequency ='Daily' AND ISDELETED=0 
	END
	ELSE IF (@Today_Date = @Month_Start_Date AND @Today_Date !=@Year_Start_Date)
	BEGIN
		SET @Cursor = CURSOR FOR
		SELECT ServerName,DatabaseName,TableName,ConditionColumnName,DataRetainedDays 
		FROM MAS.DataPurgeActvityMaster WITH(NOLOCK)
		WHERE (ScheduledFrequency ='Daily' OR ScheduledFrequency ='Monthly') AND ISDELETED=0
	END 
	ELSE IF(@Today_Date = @Month_Start_Date AND @Today_Date =@Year_Start_Date)
	BEGIN 
		SET @Cursor = CURSOR FOR
		SELECT ServerName,DatabaseName,TableName,ConditionColumnName,DataRetainedDays 
		FROM MAS.DataPurgeActvityMaster WITH(NOLOCK)
		WHERE (ScheduledFrequency ='Daily' OR ScheduledFrequency ='Monthly' OR ScheduledFrequency ='Yearly') AND ISDELETED=0 	END
	END

    OPEN @Cursor 
    FETCH NEXT FROM @Cursor 
    INTO @ServerName,@DatabaseName,@TableName,@ConditionColumnName,@DataRetainedDays
    WHILE @@FETCH_STATUS = 0
    BEGIN
	
	SET @RetainedDate= CONVERT(varchar,GETDATE()-@DataRetainedDays,10)
	SET @RetainedDate = CAST(@RetainedDate as Date)
	--SET @SQL='DELETE FROM ' + @ServerName+'.'+@DatabaseName+'.'+@TableName + ' WHERE '+ @ConditionColumnName +'<'+''''+@RetainedDate+''''
	SET @SQL='DELETE FROM ' + @DatabaseName+'.'+@TableName + ' WHERE '+ @ConditionColumnName +'<'+''''+@RetainedDate+''''
	EXEC (@SQL)
	SET @SQL_UPDATE='UPDATE MAS.DataPurgeActvityMaster SET LastProcessedDate=GETDATE() WHERE  ServerName ='''+ @ServerName+''' and DatabaseName ='''+@DatabaseName+''' and TableName = '''+@TableName + ''''
	EXEC (@SQL_UPDATE)
    FETCH NEXT FROM @Cursor 
    INTO @ServerName,@DatabaseName,@TableName,@ConditionColumnName,@DataRetainedDays  
    END; 

    CLOSE @Cursor ;
    DEALLOCATE @Cursor;

	COMMIT TRANSACTION

	SELECT @MailSubject_Completed = CONCAT(@@servername, ': DataPurgeActivity Job Notification ')			
	SET @MailContent_Completed = 'DataPurgeActivity Job has been Completed.'
	SELECT @MailBody_Completed =  [dbo].[fn_FmtEmailBody_Message](@MailContent_Completed)
	EXEC [AVL].[SendDBEmail] @To='AVMDARTL2@cognizant.com;AVMCoEL1Team@cognizant.com',
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject_Completed,
    @Body = @MailBody_Completed

	END TRY  
	BEGIN CATCH 	
	ROLLBACK TRANSACTION

	INSERT INTO [MAS].JobStatus
	(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)
	VALUES(@JobID,GETDATE(),GETDATE(),@Failed,GetDate(),0,@JobName,GETDATE(),0,0,0)
					

	DECLARE @MailSubject	NVARCHAR(500);		
	DECLARE @MailBody		NVARCHAR(MAX);
	DECLARE @MailRecipients NVARCHAR(MAX);
	DECLARE @MailContent	NVARCHAR(500);
	DECLARE @ErrorMessage	VARCHAR(MAX);	

	DECLARE @Status CHAR(1)
	DECLARE @ScriptName  NVARCHAR(100)
		
	SELECT @MailSubject = CONCAT(@@servername, ':  DataPurgeActivity Job Failure Notification')			
	SELECT @ErrorMessage = ERROR_MESSAGE()	
	SET @MailContent = 'Oops! Error Occurred in DataPurgeActivity Stored Procedure !'
	SET @Status = 'E'	
	SET @ScriptName = 'DataPurgeActivity-[MS].[DataPurgeActivity]'
	SELECT @MailBody =[dbo].[fn_FormatEmailBody](@ErrorMessage,@MailContent,@Status,@ScriptName)

	EXEC [AVL].[SendDBEmail] @To='AVMDARTL2@cognizant.com;AVMCoEL1Team@cognizant.com',
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody	 

	EXEC AVL_InsertError 'dbo.DataPurgeActivity', @ErrorMessage, 'SYSTEM',0

	END CATCH  
End


