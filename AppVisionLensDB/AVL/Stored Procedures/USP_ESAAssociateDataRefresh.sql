

/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
-- ====================================================================================================================  
-- Author   : Prakash  
-- Create date   : 02 Apr 2019  
-- Description   : Move the ESA Associate Details from AVMCOEESA DB to App Vision Lens ESA Associate table.  
-- Revision By   : Annadurai.S  
-- Revision Date : 14 Jan 2019  
-- ====================================================================================================================   
  
CREATE   PROCEDURE [AVL].[USP_ESAAssociateDataRefresh]  
AS  
BEGIN  
  
 BEGIN TRY  
  BEGIN TRAN   
    
   IF EXISTS (SELECT 1 FROM [$(AVMCOEESADB)].DBO.[ESAJobStatus]  
      WHERE ESADataUpdate = 1 AND AppvisionProdESARefresh = 1)  
   BEGIN  
      
    DECLARE @Total_Associates BIGINT  
     
    SELECT DISTINCT   
     A.Associate_ID,  
     A.Associate_Name,   
     A.Designation,   
     A.Grade,   
     A.EMail_ID,   
     1 AS IsActive,  
     A.Supervisor_ID,  
     A.Supervisor_Name  
    INTO #Associate   
    FROM [$(AVMCOEESADB)].dbo.GMSPMO_Associate A (NOLOCK)  
    ORDER BY A.Associate_ID     
      
    SELECT DISTINCT   
     aa.Associate_ID,  
     AA.Jobcode,  
     AA.Offshore_Onsite,  
     AA.Assignment_Location,  
     AA.[State],  
     AA.City,  
     AA.Country   
    INTO #LocationAssocaites   
    FROM [$(AVMCOEESADB)].dbo.GMSPMO_Associate Aa  
  
    SELECT  A.Associate_ID,  
      A.Associate_Name,  
      A.Designation,  
      A.Grade,  
      A.EMail_ID,   
      A.IsActive,  
      A.Supervisor_ID,  
      A.Supervisor_Name ,  
      AA.Jobcode,  
      AA.Offshore_Onsite,  
      AA.Assignment_Location,  
      AA.[State],  
      AA.City,  
      AA.Country   
    INTO #NewAssociates   
    FROM #Associate a   
    LEFT JOIN #LocationAssocaites Aa   
     ON a.Associate_ID = Aa.Associate_ID  
     
    SELECT @Total_Associates = COUNT(1) FROM #NewAssociates    
     
    SELECT @Total_Associates  
     
    IF (@Total_Associates > 0)  
    BEGIN  
    
     TRUNCATE TABLE ESA.Associates  
        
     INSERT INTO ESA.Associates   
     (  
      AssociateID,   
      AssociateName,   
      Designation,   
      Grade,   
      EMail,   
      IsActive,   
      LastModifiedDate,  
      Supervisor_ID,  
      Supervisor_Name,  
      Jobcode,  
      Offshore_Onsite,  
      Assignment_Location,  
      [State],  
      City,  
      Country  
     )    
     SELECT Associate_ID,   
       ISNULL(Associate_Name, ''),   
       ISNULL(Designation, ''),   
       ISNULL(Grade, ''),   
       ISNULL(EMail_ID, ''),   
       1,   
       GETDATE(),  
       ISNULL(Supervisor_ID, ''),   
       ISNULL(Supervisor_Name, ''),  
       ISNULL(Jobcode,''),  
       ISNULL(Offshore_Onsite,''),  
       ISNULL(Assignment_Location,''),  
       ISNULL([State],''),  
       ISNULL(City,''),  
       ISNULL(Country,'')  
     FROM #NewAssociates  
  
      /*SVP+ changes for 103480 associate*/  
  
      IF NOT EXISTS(SELECT top 1 1 FROM ESA.ASSOCIATES WHERE AssociateID='103480' and Isactive=1)---svp + role  
      
      BEGIN  
  
       INSERT INTO ESA.Associates  
           (AssociateID,AssociateName,Designation,Grade,Email,PassportNo,PassPortIssueDate  
           ,PassportExpiryDate,IsActive,LastModifiedDate,Supervisor_ID,Supervisor_Name  
           ,JobCode,Offshore_Onsite,Assignment_Location,City,State,Country)  
       VALUES  
         ('103480','Dhanakoti,Ramesh','SVP','E20','Ramesh.Dhanakoti@cognizant.com'  
         ,null,'','',1,getdate(),null,null,null,'OF',null,null,null,null)  
       
       END  
  
      /*SVP+ changes for 103480 associate*/  
       
    END  
     
    --Delete # temp tables  
    DROP TABLE #Associate  
  
   END  
  COMMIT TRAN  
 END TRY  
 BEGIN CATCH     
    
  ROLLBACK TRAN  
  
  UPDATE [$(AVMCOEESADB)].DBO.ESAJobStatus SET AppvisionProdESARefresh = 0    
  
  DECLARE @ErrorMessage NVARCHAR(4000);      
  DECLARE @ErrorSeverity INT;      
  DECLARE @ErrorState  INT;      
  
  SELECT @ErrorMessage = ERROR_MESSAGE(),      
    @ErrorSeverity = ERROR_SEVERITY(),      
    @ErrorState  = ERROR_STATE();    
  
  DECLARE @MailSubject VARCHAR(MAX);    
  DECLARE @MailBody    VARCHAR(MAX);  
  
  SELECT @MailSubject = CONCAT(@@SERVERNAME, ': ESA Job Failure Notification')  
  
  SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in AppVision PROD ESA Refresh during the ESA Job Execution!<br>  
       <br>Error: ',@ErrorMessage,  
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')  
            
  -- Insert Error Details     
  -- EXEC AVL_InsertESAJobError '[AVL].[USP_ESAAssociateDataRefresh]', @ErrorMessage, 0, 'AppVision PROD ESA Refresh', @@SERVERNAME  
    
  INSERT INTO [$(AVMCOEESADB)].DBO.ESAJobErrors    
  (  
   JobName,  
   ErrorSource,  
   ErrorDescription,  
   CreatedBy,  
   CreatedDate,  
   ServerName  
  )      
  SELECT 'AppVision PROD ESA Refresh', '[AVL].[USP_ESAAssociateDataRefresh]', @ErrorMessage, '0', GETDATE(), @@SERVERNAME   
  
  ---Mail Option Added by Annadurai on 11.01.2019 to send mail during error ESAJob  
     DECLARE @recipientsAddress NVARCHAR(4000)='';  
     SET @recipientsAddress = (SELECT ConfigValue FROM AVL.AppLensConfig WHERE ConfigName='Mail' AND IsActive=1);     
     EXEC [AVL].[SendDBEmail] @To=@recipientsAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody
         
        ------------------------------------------------------    
  
 END CATCH  
END  

