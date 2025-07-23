/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [BOT].[InsertChildTicketDescription]
@insertChildTicketDescription ChildTicketDescriptionType READONLY
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
--DECLARE @jobId NVARCHAR(50) = CAST((SELECT DATEDIFF(second,'2020-01-01 00:00:00.000',GETDATE())) AS NVARCHAR(50))
DECLARE  @jobId NVARCHAR(50)
SET  @jobId = (SELECT JobId FROM [BOT].[ChildTicketDescriptionJobMonitor] WHERE JobId=(SELECT MAX(JobId) FROM [BOT].[ChildTicketDescriptionJobMonitor] WHERE JobType='DecryptionJob'))

INSERT INTO [BOT].[ChildTicketDescriptionDecrypted]
SELECT @jobId,ictd.*,'System',GETDATE(),'System',GETDATE() FROM @insertChildTicketDescription ictd

--INSERT INTO [BOT].[ChildTicketDescriptionJobMonitor]
--VALUES(@jobId,'No','System',GETDATE(),'System',GETDATE())

--MERGE [dbo].[ChildTicketDescriptionDecrypted] ctdd
--USING @insertChildTicketDescription ictd
--ON
--ctdd.[TimeTickerID]=ictd.[TimeTickerID] AND
--ctdd.[TicketID]=ictd.[TicketID] AND
--ctdd.[ApplicationID]=ictd.[ApplicationID] AND
--ctdd.[ProjectID]=ictd.[ProjectID] AND
--ctdd.[AssignedTo]=ictd.[AssignedTo] AND
--ctdd.[TicketDescription]=ictd.[TicketDescription] AND
--ctdd.[ModifiedDate]=ictd.[ModifiedDate] AND 
--ictd.[ModifiedDate] = GETDATE() - 1
--WHEN MATCHED
--THEN 
--UPDATE SET
--ctdd.[TimeTickerID]=ictd.[TimeTickerID],
--ctdd.[TicketID]=ictd.[TicketID],
--ctdd.[ApplicationID]=ictd.[ApplicationID],
--ctdd.[ProjectID]=ictd.[ProjectID],
--ctdd.[AssignedTo]=ictd.[AssignedTo],
--ctdd.[TicketDescription]=ictd.[TicketDescription],
--ctdd.[ModifiedDate]=ictd.[ModifiedDate]
--WHEN NOT MATCHED BY TARGET
--THEN
--INSERT([TimeTickerID],[TicketID],[ApplicationID],[ProjectID],[AssignedTo],[TicketDescription],[ModifiedDate],[CreatedBySystem],[CreatedDateSystem],[ModifiedBySystem],[ModifiedDateSystem])
--VALUES(
--ictd.[TimeTickerID],ictd.[TicketID],ictd.[ApplicationID],ictd.[ProjectID],ictd.[AssignedTo],ictd.[TicketDescription],ictd.[ModifiedDate],'SYSTEM',GETDATE(),'SYSTEM',GETDATE());
END TRY
BEGIN CATCH
DECLARE @errorMessage VARCHAR(MAX);

		SELECT @errorMessage = ERROR_MESSAGE()
		EXEC [BOT].[InsertError] '[BOT].[InsertChildTicketDescription]',@errorMessage,0,0
END CATCH
END
