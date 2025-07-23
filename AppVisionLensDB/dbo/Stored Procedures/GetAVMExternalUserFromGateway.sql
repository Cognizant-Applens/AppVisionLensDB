
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] ? [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE   PROCEDURE [dbo].[GetAVMExternalUserFromGateway]
AS  
BEGIN
DECLARE @Date DateTime = GetDate();  
 DECLARE @JobName VARCHAR(100)= 'Get External User Details from CRS Server';  
 DECLARE @JobStatusSuccess VARCHAR(100)='Success';  
 DECLARE @JobStatusFail VARCHAR(100)='Failed';  
 DECLARE @JobStatusInProgress VARCHAR(100)='InProgress';  
 DECLARE @JobId int;  
 DECLARE @JobStatusId int;  
 
 SET NOCOUNT ON;


SELECT @JobId = JobID FROM MAS.JobMaster WHERE JobName = @JobName;   
  
 INSERT INTO MAS.JobStatus (
              JobId, 
              StartDateTime, 
              EndDateTime, 
              JobStatus, 
              JobRunDate, 
              IsDeleted, 
              CreatedBy, 
              CreatedDate)   
      VALUES(@JobId, @Date, @Date, @JobStatusInProgress, @Date, 0, SYSTEM_USER, @Date);  
  
 SET @JobStatusId= SCOPE_IDENTITY(); 

BEGIN TRY      
 
BEGIN TRANSACTION 

       MERGE  [RLE].[ExternalUserDetails] AS appTarget
       USING (
                               SELECT UserId,Status,Email,FirstName,LastName,FullName,Country,City,UserType,ProjectId,RequestorId,
                               Description,
                                                     CASE   
                                                                   WHEN TRIM(AccountExpiryDate) = 'No end date' THEN '9999-12-31 11:59:59.999'   
                                                                   ELSE CONVERT(DATETIME,AccountExpiryDate,120)
                                                     END AS AccountExpiryDate,
                                                     AccountCreationDate   
                                                     from [$(AVMCOEESADB)].[dbo].[AVMExternalUser] 
                 ) AS Source
              ON (appTarget.UserId = Source.UserId)
       WHEN MATCHED
       THEN
         UPDATE SET appTarget.[UserId] = Source.[UserId]
                         , appTarget.[ModifiedDate] = GetDate()
                         , appTarget.[ModifiedBy] = SYSTEM_USER 
       WHEN NOT MATCHED BY TARGET
       THEN
         INSERT ([UserId]
                      , [Status]
                      , [Email]
                      , [FirstName]
                      , [LastName]
                      , [FullName]
                      , [Country]
                      , [City]
                      , [UserType]
                      , [ProjectId]
                      , [RequestorId]
                      , [Description]
                      , [AccountExpiryDate]
                      , [AccountCreationDate]
                      , [Isdeleted]
                      , [CreatedDate]
                      , [CreatedBy])
         VALUES (Source.[UserId]
                      , Source.[Status]
                      , Source.[Email]
                      , Source.[FirstName]
                      , Source.[LastName]
                      , Source.[FullName]
                      , Source.[Country]
                      , Source.[City]
                      , Source.[UserType]
                      , Source.[ProjectId]
                      , Source.[RequestorId]
                      , Source.[Description]
                      , Source.[AccountExpiryDate]
                      , Source.[AccountCreationDate]
                      , 0
                      , GetDate()
                      , SYSTEM_USER);

       COMMIT TRANSACTION 

       UPDATE MAS.JobStatus Set JobStatus = @JobStatusSuccess, EndDateTime = GETDATE() WHERE ID = @JobStatusId    
       
END TRY  
  
BEGIN CATCH      
 
       IF (XACT_STATE()) = -1        
              BEGIN        
              ROLLBACK TRANSACTION;        
              END;        
       IF (XACT_STATE()) = 1        
              BEGIN        
              COMMIT TRANSACTION;           
              END;      

       UPDATE MAS.JobStatus Set JobStatus = @JobStatusFail, EndDateTime = GETDATE() WHERE ID = @JobStatusId    
  
       DECLARE @HostName NVARCHAR(50);      
       DECLARE @Associate NVARCHAR(50);      
       DECLARE @ErrorCode NVARCHAR(50);      
       DECLARE @ErrorMessage NVARCHAR(MAX);      
       DECLARE @ModuleName VARCHAR(30)='RoleAPI';      
       DECLARE @DbName VARCHAR(30)='AppVisionLens';      
       DECLARE @getdate  DATETIME=GETDATE();      
       DECLARE @DbObjName VARCHAR(50)=(OBJECT_NAME(@@PROCID));      

       SET @HostName=(SELECT HOST_NAME());      
       SET @Associate=(SELECT SUSER_NAME());      
       SET @ErrorCode=(SELECT ERROR_NUMBER());      
       SET @ErrorMessage=(SELECT ERROR_MESSAGE());      
      
      
       EXEC AppVisionLensLogging.[dbo].[InsertLog] 'Critical','ERROR',@HostName,@Associate,@getdate,NULL,'SQL',      
              @ModuleName,@JobName,@DbName,@DbObjName,@@SPID,@ErrorCode,@ErrorMessage,      
                      @JobStatusFail,NULL,NULL     
       UPDATE MAS.JobStatus Set JobStatus = @JobStatusFail, EndDateTime = GETDATE() WHERE ID = @JobStatusId 
 END CATCH      
END
