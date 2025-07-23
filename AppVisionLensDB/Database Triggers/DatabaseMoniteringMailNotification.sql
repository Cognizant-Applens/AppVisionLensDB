/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/





CREATE trigger [DatabaseMoniteringMailNotification] on  database 
   for    CREATE_PROCEDURE,  ALTER_PROCEDURE,  DROP_PROCEDURE,
         --CREATE_INDEX , ALTER_INDEX  ,DROP_INDEX,
         --CREATE_TRIGGER, ALTER_TRIGGER, DROP_TRIGGER,
         CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION,
         ALTER_TABLE,DROP_TABLE
  
as
begin


         Declare @data xml
         set @data=Eventdata()

         Insert into SCHEMA_LOG values
         (
         @data.value('(/EVENT_INSTANCE/LoginName)[1]','nvarchar(255)'),
         @data.value('(/EVENT_INSTANCE/EventType)[1]','nvarchar(255)'),
         @data.value('(/EVENT_INSTANCE/ObjectName)[1]','nvarchar(255)'),
         @data.value('(/EVENT_INSTANCE/ObjectType)[1]','nvarchar(255)'),
         getdate(),
         HOST_NAME()  

         )
		 
declare @results varchar(max)
declare @UserName VARCHAR(150)
declare @HostName VARCHAR(50)  
declare @subjectText varchar(max)
declare @objectName VARCHAR(255)
declare @objectType VARCHAR(255)
declare @eventType VARCHAR(255)
declare @body VARCHAR(max)
declare @bodytext VARCHAR(255)
declare @subject VARCHAR(255)

SELECT @UserName = SYSTEM_USER, @HostName = HOST_NAME()  
SET @subjectText = 'DDL Modification on ' + @@SERVERNAME + ' by ' + @UserName
SET @results = 
  (SELECT @data.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)'))
SET @objectName = (SELECT @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'VARCHAR(255)'))
SET @objectType = (SELECT @data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'VARCHAR(255)'))
SET @eventType = (SELECT @data.value('(/EVENT_INSTANCE/EventType)[1]','nvarchar(255)'))
SET  @body =  'User: '+@username+' from '+@hostname+' performed action of type ['+@eventType+'] on DatabaseName :'+db_name()+' ['+@ObjectType+']:['+@objectName+'] at '+CONVERT(VARCHAR(20),GETDATE(),100)
 
--Send Mail when the trigger is called

EXEC msdb.dbo.sp_send_dbmail
 @profile_name = 'ApplensSupport',
 @recipients = 'rameshkumar.n@cognizant.com;Karthick.Muthukrishnan@cognizant.com;Prabhu.RethinamSambasivam@cognizant.com;dineshvarman.t@cognizant.com',
 @body = @body,
 @subject = @subjectText,
 @exclude_query_output = 1 --Suppress 'Mail Queued' message
         
end


GO
DISABLE TRIGGER [DatabaseMoniteringMailNotification]
    ON DATABASE;

