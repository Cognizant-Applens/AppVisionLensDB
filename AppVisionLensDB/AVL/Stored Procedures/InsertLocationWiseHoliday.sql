
/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] � [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
-- ====================================================================================================================  
-- Author   : Umamaheswari  
-- Create Date   : 10 Oct 2019  
-- Description   : Get the Location wise Holiday list from CRS   
-- Revision By   :   
-- Revision Date : 10 Oct 2019  
-- ====================================================================================================================   
  
CREATE   PROCEDURE [AVL].[InsertLocationWiseHoliday]  
AS     
 SET NOCOUNT ON;  
BEGIN      
  
 BEGIN TRY   
    
  DECLARE @JobID INT  
  DECLARE @JobName VARCHAR(50) = 'Location Wise Holiday details'  
  DECLARE @Success VARCHAR(10) ='Success'  
  DECLARE @Failed VARCHAR(10) ='Failed'  
  
  DECLARE @MailSubject NVARCHAR(500);    
  DECLARE @MailBody  NVARCHAR(MAX);  
  DECLARE @MailRecipients NVARCHAR(MAX);  
  DECLARE @MailContent NVARCHAR(500);  
  DECLARE @Status CHAR(1)  
  DECLARE @ScriptName  NVARCHAR(100)  
     DECLARE @ErrorMessage VARCHAR(MAX);  
                        
            SET @MailRecipients = ''  
  
   SELECT @JobID = JobID FROM MAS.JobMaster WHERE JobName =@JobName  
  
      SELECT @MailRecipients = @MailRecipients + EmployeeEmail + ';'  From [MAS].[JobWiseMailDetails] Where IsDeleted = 0 AND JobId = @JobID  
   
   SELECT @MailSubject = CONCAT(@@servername, ':  Location Wise Holiday details Job Notification')     
    
   SET @MailContent = 'Location Wise Holiday details Job Gateway - Applens has been Started .'  
  
   SELECT @MailBody =  [dbo].[fn_FmtEmailBody_Message](@MailContent)  
   EXEC [AVL].[SendDBEmail] @To=@MailRecipients,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody   
  
 BEGIN TRANSACTION  
  IF EXISTS(SELECT TOP 1 1 FROM [$(AVMCOEESADB)].DBO.HolidayDetails)  
  BEGIN   
    
   TRUNCATE TABLE ESA.HolidayDetails  
  
   INSERT INTO ESA.HolidayDetails  
    ( LOCATION,  
     HOLIDAY_SCHEDULE,  
     HOLIDAY,  
                    DESCRIPTION,  
     HOLIDAY_HRS_NUMBER  
    )          
   SELECT DISTINCT   
    LOCATION,  
    HOLIDAY_SCHEDULE,  
    HOLIDAY ,  
                null,  
    HOLIDAY_HRS_NUMBER  
   FROM [$(AVMCOEESADB)].DBO.HolidayDetails  
     
   SELECT 1 AS Success  
  
   IF EXISTS(SELECT TOP 1 1 FROM ESA.HolidayDetails)  
    BEGIN       
     INSERT INTO MAS.JobStatus  
     (JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)  
     VALUES(@JobID,(CONCAT(YEAR(GETDATE()),'-','01','-','01')),(CONCAT(YEAR(GETDATE()),'-','12','-','31')),@Success,(CONCAT(YEAR(GETDATE()), '-', '12','-' , '20')),0,@JobName,GETDATE(),(SELECT COUNT(ID) FROM ESA.HolidayDetails),0,0)  
  
     SELECT @MailSubject = CONCAT(@@servername, ':  Location Wise Holiday details Job Success Notification')     
    
     SET @MailContent = 'Location Wise Holiday details job Gateway - Applens has been completed successfully.'      
       
     SELECT @MailBody = [dbo].[fn_FmtEmailBody_Message](@MailContent)  
    
	   EXEC [AVL].[SendDBEmail] @To=@MailRecipients,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody   
  
    END  
      
   END   
    
  ELSE  
  BEGIN   
    SELECT 0 AS Success   
    SET @ErrorMessage = 'No Records found in AppLens Holiday table'  
    RAISERROR (@ErrorMessage,16,1);  
  END   
    COMMIT TRANSACTION    
 END TRY  
 BEGIN CATCH    
 ROLLBACK TRANSACTION  
  
  INSERT INTO MAS.JobStatus  
   (JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)  
  VALUES(@JobID,(CONCAT(YEAR(GETDATE()),'-','01','-','01')),(CONCAT(YEAR(GETDATE()),'-','12','-','31')),@Failed,(CONCAT(YEAR(GETDATE()), '-', '12','-' , '20')),0,@JobName,GETDATE(),0,0,0)  
  
  SELECT @MailSubject = CONCAT(@@servername, ': Location wise Holiday Tracker Job Failure Notification')     
  SELECT @ErrorMessage = ERROR_MESSAGE()   
  SET @MailContent = 'Oops! Error Occurred in Location wise Holiday Tracker during the CRS Holiday List insertion Execution!'  
  SET @Status = 'E'   
  SET @ScriptName = '[AVL].[InsertLocationWiseHoliday]'  
  SELECT @MailBody =[dbo].[fn_FormatEmailBody](@ErrorMessage,@MailContent,@Status,@ScriptName)  
  
  ---Mail Option Added by Annadurai on 11.01.2019 to send mail during error ESAJob  
  EXEC [AVL].[SendDBEmail] @To=@MailRecipients,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody
    
 END CATCH   
   
END  


