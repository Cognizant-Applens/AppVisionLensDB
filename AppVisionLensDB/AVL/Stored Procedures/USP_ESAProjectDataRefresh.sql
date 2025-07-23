

-- ==============================================================================    
-- Author:  <Dinesh Babu>    
-- Create date: <15.12.2015>    
-- Description: <Updating ESA table with new entries for Accounts and Projects>    
-- Revision By   : Annadurai.S    
-- Revision Date : 11 Jan 2019    
-- Revision comment: Added Job Fail message    
-- ==============================================================================    
    
CREATE   PROCEDURE [AVL].[USP_ESAProjectDataRefresh]    
AS    
BEGIN    
    
 BEGIN TRY    
  BEGIN TRAN    
    
  IF EXISTS (SELECT 1 FROM [$(AVMCOEESADB)].DBO.[ESAJobStatus]    
     WHERE ESADataUpdate = 1 AND AppvisionProdESARefresh = 1)    
  BEGIN    
    
   -- Insert / Update / Activate / Deactivate Market, Market Unit and Business Unit    
         EXEC [AVL].[Evaluate_Market_MU_BU_ESA]    
       
   DECLARE @Total_Accounts BIGINT       
   DECLARE @Total_Projects BIGINT    
    
   -- New BU Sync up    
   INSERT INTO ESA.BusinessUnits    
    SELECT DISTINCT    
      (SELECT MAX(BUID) + 1 FROM ESA.BusinessUnits) AS buid,     
      P.CTS_VERTICAL         AS BUName,    
      P.CTS_VERTICAL         AS PracticeCode,    
      P.CTS_VERTICAL         AS ShortName,    
      1            AS IsActive,    
      GETDATE()    
    FROM [$(AVMCOEESADB)].dbo.GMSPMO_Project P (NOLOCK)     
    LEFT JOIN ESA.BusinessUnits BU ON BU.Practicecode = P.CTS_VERTICAL    
    WHERE BU.buname IS NULL     
    
       
   SELECT DISTINCT Account_ID,     
     Account_Name,    
     P.CTS_VERTICAL AS BUPracticecode,     
     BU.BUID,    
     CASE WHEN Status = 'A' THEN 1 ELSE 0 END AS IsActive,     
     GETDATE() AS LastModifiedDate    
   INTO #Account_Master    
   FROM [$(AVMCOEESADB)].dbo.GMSPMO_Project P (NOLOCK)     
   INNER JOIN ESA.BusinessUnits BU ON BU.Practicecode = P.CTS_VERTICAL    
        
   SELECT @Total_Accounts = COUNT(1) FROM #Account_Master      
       
   IF (@Total_Accounts > 0)    
   BEGIN      
       
    TRUNCATE TABLE ESA.BUAccounts           
         
    INSERT INTO ESA.BUAccounts     
    (    
     AccountID,     
     AccountName,     
     BUID,     
     IsActive,     
     LastModifiedDate    
    )    
    SELECT Account_ID,     
      Account_Name,     
      BUID,     
      IsActive,     
      LastModifiedDate    
    FROM #Account_Master    
          
   END    
        
       
   SELECT P.Project_ID,     
     Project_Small_Desc,     
     ACCOUNT_ID,     
     Project_Start_Date,     
     Project_End_Date,     
     RM.Project_Manager AS ProjectManagerID,    
     Account_Manager_ID AS AccountManagerID,    
     CTS_VERTICAL,    
     Project_Type,    
     Billability_Type,    
     [Status]    
   INTO #Project    
   FROM [$(AVMCOEESADB)].dbo.GMSPMO_Project P     
   LEFT JOIN [$(AVMCOEESADB)].[dbo].[RHMSprojectManager] RM ON RM.Project_ID = P.Project_ID  
   WHERE P.STATUS = 'A'     
        
   SELECT @Total_Projects = COUNT(1) FROM #Project      
       
   IF (@Total_Projects > 0)    
   BEGIN      
       
    TRUNCATE TABLE ESA.Projects    
          
    INSERT INTO ESA.Projects    
    (    
     ID,     
     Name,     
     AccountID,     
     ProjectStartDate,     
     ProjectEndDate,    
     ProjectManagerID,    
     AccountManagerID,    
     CTS_VERTICAL,    
     Project_Small_Desc,    
     ProjectType,    
     BillabilityType,    
     ProjectStatus    
    )     
    SELECT Project_ID,     
      Project_Small_Desc,     
      ACCOUNT_ID,     
      Project_Start_Date,     
      Project_End_Date,    
      ProjectManagerID,    
      AccountManagerID,    
      CTS_VERTICAL,    
      Project_Small_Desc,    
      Project_Type,    
      Billability_Type,    
      [Status]     
    FROM #Project    
    
   END     
       
   /** Project Department mapping and Department Master - Begin **/    
    
   TRUNCATE TABLE ESA.ProjectDepartment;    
                         
            INSERT INTO ESA.ProjectDepartment (ESAProjectID, DepartmentName, IsDeleted, CreatedBy, CreatedDateTime)    
  SELECT DISTINCT GA.Project_ID, GA.Dept_Name, 0, 'SYSTEM', GETDATE()     
    FROM [$(AVMCOEESADB)].dbo.GMSPMO_Project GP     
       LEFT JOIN [$(AVMCOEESADB)].[dbo].[RHMSprojectManager] RM ON RM.Project_ID = GP.Project_ID  
    JOIN [$(AVMCOEESADB)].dbo.GMSPMO_Associate GA     
     ON GP.Project_ID = GA.Project_ID AND GA.Associate_ID =    
      CASE WHEN GP.Project_Owner IS NOT NULL THEN  GP.Project_Owner     
       ELSE RM.Project_Manager END;  
    
       
    -- Insert / Activate / De-activate Department    
   INSERT INTO ESA.Department     
    SELECT DISTINCT NULL, PD.DepartmentName, 0, 'SYSTEM', GETDATE(), NULL, NULL    
    FROM (SELECT DISTINCT DepartmentName FROM ESA.ProjectDepartment) PD    
    LEFT JOIN ESA.Department D    
     ON D.DepartmentName = PD.DepartmentName    
    WHERE D.DepartmentName IS NULL    
    
      UPDATE D    
   SET D.IsDeleted = CASE WHEN PD.DepartmentName IS NULL THEN 1 ELSE 0 END,    
    D.ModifiedBy = 'SYSTEM', D.ModifiedDateTime = GETDATE()    
   FROM ESA.Department D    
   LEFT JOIN (SELECT DISTINCT DepartmentName FROM ESA.ProjectDepartment) PD    
    ON D.DepartmentName = PD.DepartmentName      
    
   /** Project Department mapping and Department Master - End **/    
           
   DROP TABLE #Account_Master     
   DROP TABLE #Project    
    
  END    
  COMMIT TRAN    
 END TRY    
 BEGIN CATCH        
  ROLLBACK TRAN    
    
  UPDATE [$(AVMCOEESADB)].DBO.[ESAJobStatus] SET AppvisionProdESARefresh = 0    
    
  DECLARE @ErrorMessage NVARCHAR(4000);        
  DECLARE @ErrorSeverity INT;        
  DECLARE @ErrorState  INT;        
    
  SELECT @ErrorMessage = ERROR_MESSAGE(),        
    @ErrorSeverity = ERROR_SEVERITY(),        
    @ErrorState  = ERROR_STATE();        
      
  DECLARE @MailSubject VARCHAR(MAX);      
  DECLARE @MailBody  VARCHAR(MAX);    
    
  SELECT @MailSubject = CONCAT(@@SERVERNAME, ': ESA Job Failure Notification')    
    
  SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in AppVision PROD ESA Refresh during the ESA Job Execution!<br>    
       <br>Error: ', @ErrorMessage,    
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')    
       
  -- Insert Error Details         
  --EXEC AVL_InsertESAJobError '[AVL].[USP_ESAProjectDataRefresh]', @ErrorMessage, 0,'AppVision PROD ESA Refresh', @@SERVERNAME    
    
  INSERT INTO [$(AVMCOEESADB)].DBO.ESAJobErrors      
  (    
   JobName,    
   ErrorSource,    
   ErrorDescription,    
   CreatedBy,    
   CreatedDate,    
   ServerName    
  )      
  SELECT 'AppVision PROD ESA Refresh', '[AVL].[USP_ESAProjectDataRefresh]', @ErrorMessage, '0', GETDATE(), @@SERVERNAME     
    
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

