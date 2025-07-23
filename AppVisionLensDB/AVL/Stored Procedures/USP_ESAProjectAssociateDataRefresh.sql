/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
    
-- =================================================================    
-- Author:  <Dinesh Babu>    
-- Create date: <15.12.2015>    
-- Description: <Updating Project Associates table with new entries>    
-- Revision By   : Annadurai.S    
-- Revision Date : 11 Jan 2019    
-- =================================================================    
    
CREATE   PROCEDURE [AVL].[USP_ESAProjectAssociateDataRefresh]    
    
AS    
    
BEGIN    
    
 BEGIN TRY    
    
  BEGIN TRAN    
     
   IF EXISTS (SELECT 1 FROM [$(AVMCOEESADB)].DBO.[ESAJobStatus]    
      WHERE ESADataUpdate = 1 AND AppvisionProdESARefresh = 1)    
   BEGIN    
    
    DECLARE @Total_ProjectAssociates BIGINT       
    
    SELECT  DISTINCT AA.Associate_ID,    
       AA.Project_ID,    
       aa.Assignmentstartdate,    
       aa.Assignmentenddate,     
       AA.Allocation_Percentage,     
       GETDATE() AS LastModifiedDate,    
       AA.Dept_Name,    
       AA.Grade,    
       AA.City    
    INTO #NewProjectAssociates     
    FROM [$(AVMCOEESADB)].DBO.GMSPMO_Associate AA (NOLOCK)    
    
    SELECT DISTINCT AA.Associate_ID,     
        AA.Project_ID,     
        aa.Assignmentstartdate,     
        aa.Assignmentenddate,    
        AA.Allocation_Percentage,    
        aa.LastModifiedDate,    
        AA.Dept_Name,    
        AA.Grade,    
        AA.City,    
        Proj.Name,    
        Proj.CTS_VERTICAL,    
        Proj.Project_Small_Desc,    
        proj.ACCOUNTID,    
        bua.AccountName    
    INTO #ProjectAssociates    
    FROM #NewProjectAssociates aa     
    LEFT JOIN ESA.Projects Proj (NOLOCK) ON Proj.ID = AA.Project_ID     
    LEFT JOIN ESA.Associates ASSO (NOLOCK) ON ASSO.AssociateID = AA.Associate_ID    
    LEFT JOIN ESA.BUAccounts bua (NOLOCK) On bua.AccountID = proj.AccountID     
          
    DROP TABLE #NewProjectAssociates    
    
    SELECT COUNT(1) FROM #ProjectAssociates     
    SELECT @Total_ProjectAssociates = COUNT(1) FROM #ProjectAssociates      
         
    IF (@Total_ProjectAssociates > 0)    
    BEGIN     
          
     TRUNCATE TABLE ESA.ProjectAssociates     
         
     INSERT INTO ESA.ProjectAssociates     
     (    
      AssociateID,     
      ProjectID,     
      Allocationstartdate,     
      Allocationenddate,     
      Allocationpercent,     
      LastModifiedDate,    
      Project_Small_Desc,    
      ACCOUNT_ID,    
      ACCOUNT_NAME,    
      CTS_VERTICAL,    
      Dept_Name,    
      Grade,    
      City    
     )    
     SELECT Associate_ID,     
       Project_ID,     
       AssignmentStartDate,     
       AssignmentEndDate,     
       Allocation_Percentage,     
       LastModifiedDate,    
       Project_Small_Desc,    
       ACCOUNTID,    
       AccountName,    
       CTS_VERTICAL,    
       Dept_Name,    
       Grade,    
       city    
     FROM #ProjectAssociates    
     /*SVP+ changes for 103480 associate*/  
  
       IF NOT EXISTS (SELECT TOP 1 1 FROM ESA.ProjectAssociates WHERE AssociateID='103480')  
       BEGIN  
       INSERT INTO [ESA].[ProjectAssociates]  
          (  
        [AssociateID],[ProjectID],[AllocationStartDate],[AllocationEndDate]  
          ,[AllocationPercent],[LastModifiedDate],[ACCOUNT_ID],[ACCOUNT_NAME]  
          ,[CTS_VERTICAL],[Project_Small_Desc],[Allocation_Percentage]  
          ,[Dept_Name],[Grade],[City])  
       VALUES  
        ('103480',1000179368,'2022-01-01','2022-12-31',100,null  
          ,'1230511','ADM Internal','INTERNAL','ADM_C_Leadership_GSLL'  
          ,null,'ADM-Operational Excellence',null,null)  
       END  
  
  
     /*SVP+ changes for 103480 associate*/         
    END    
    
    DROP TABLE #ProjectAssociates    
      
   END    
    
  COMMIT TRAN    
    
 END TRY    
    
 BEGIN CATCH        
    
  ROLLBACK TRAN    
    
  UPDATE [$(AVMCOEESADB)].DBO.ESAJobStatus SET AppvisionProdESARefresh = 0    
    
  DECLARE @ErrorMessage NVARCHAR(4000);        
  DECLARE @ErrorSeverity INT;        
  DECLARE @ErrorState  INT;      
  DECLARE @MailSubject VARCHAR(MAX);      
  DECLARE @MailBody  VARCHAR(MAX);    
    
  SELECT @ErrorMessage = ERROR_MESSAGE(),        
    @ErrorSeverity = ERROR_SEVERITY(),        
    @ErrorState  = ERROR_STATE();     
        
  SELECT @MailSubject = CONCAT(@@SERVERNAME, ': ESA Job Failure Notification')    
    
  SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in AppVision PROD ESA Refresh during the ESA Job Execution!<br>    
       <br>Error: ', @ErrorMessage,    
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')    
    
  -- Insert Error Details    
  -- EXEC AVL_InsertESAJobError '[AVL].[USP_ESAProjectAssociateDataRefresh] ', @ErrorMessage, 0, 'AppVision PROD ESA Refresh', @@SERVERNAME    
      
  INSERT INTO [$(AVMCOEESADB)].DBO.ESAJobErrors      
  (    
   JobName,    
   ErrorSource,    
   ErrorDescription,    
   CreatedBy,    
   CreatedDate,    
   ServerName    
  )       
  SELECT 'AppVision PROD ESA Refresh', '[AVL].[USP_ESAProjectAssociateDataRefresh]', @ErrorMessage, '0', GETDATE(), @@SERVERNAME     
    
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

