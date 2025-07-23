
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
-- Revision By   : Annadurai.S    
-- Description   : Move the Employee Details from App Vision Lens ESA Employee table to Login Master table.    
-- Revision Date : 11 Jan 2019    
-- Create date   : 24 Dec 2018    
-- ====================================================================================================================     
CREATE   PROCEDURE [AVL].[EvaluateEmployeeESA]    
AS    
BEGIN     
 BEGIN TRY    
  BEGIN TRAN     
    
  IF EXISTS (SELECT 1 FROM [$(AVMCOEESADB)].[DBO].[ESAJobStatus] WHERE AppvisionProdESARefresh = 1)  
  BEGIN    
    
   CREATE TABLE #AssociateDetails    
   (    
    SNo INT IDENTITY(1,1),    
    AssociateID NVARCHAR(50),    
    AssociateName VARCHAR(255),    
    Designation NVARCHAR(200),    
    Grade CHAR(3),    
    Email NVARCHAR(255),    
    Supervisor_ID VARCHAR(31),    
    Supervisor_Name VARCHAR(302),    
    ESAProjectID NVARCHAR(50),    
    ProjectID INT,    
    CustomerID INT,    
    LocationID INT,    
    Assignment_Location NVARCHAR(12),    
    Offshore_Onsite VARCHAR(3)    
   )    
    
   INSERT INTO #AssociateDetails    
   (    
    AssociateID,    
    ESAProjectID,    
    AssociateName,    
    Designation,    
    Grade,    
    Email,    
    Supervisor_ID,    
    Supervisor_Name,    
    Assignment_Location,    
    Offshore_Onsite    
   )    
   SELECT DISTINCT a.AssociateID, pa.ProjectID, '', '', '', '', '', '', '', ''    
   FROM esa.Associates (NOLOCK) a     
   JOIN esa.ProjectAssociates (NOLOCK) pa ON TRIM(a.AssociateID) = TRIM(pa.AssociateID)   
   WHERE a.IsActive = 1    
      
   UPDATE ad SET ad.AssociateName = a.AssociateName,    
        ad.Designation = a.Designation,    
        ad.Grade = a.Grade,    
        ad.Email = a.Email,    
        ad.Supervisor_ID = a.Supervisor_ID,    
        ad.Supervisor_Name = a.Supervisor_Name,    
        ad.Assignment_Location = a.Assignment_Location,    
        ad.Offshore_Onsite = a.Offshore_Onsite      
   FROM #AssociateDetails ad     
   JOIN esa.Associates (NOLOCK) a ON ad.AssociateID = a.AssociateID    
        
   --SELECT 'Before ProjectID Update #AssociateDetails'    
   --SELECT * FROM #AssociateDetails    
    
   UPDATE ad SET   ad.ProjectID = pm.ProjectID,    
       ad.CustomerID = pm.CustomerID     
   FROM #AssociateDetails ad     
   JOIN avl.MAS_ProjectMaster (NOLOCK) pm ON ad.EsaProjectID = pm.EsaProjectID    
    
   --SELECT '#AssociateDetails'    
   --SELECT * FROM #AssociateDetails    
    
   /* -- Existing Associates Active -- */    
   SELECT ad.*     
   INTO #ExistingAssociatesActive     
   FROM AVL.MAS_LoginMaster (NOLOCK) lm     
   JOIN #AssociateDetails ad ON lm.EmployeeID = ad.AssociateID AND lm.ProjectID = ad.ProjectID    
   WHERE lm.isDeleted = 0    
    
   SELECT ea.*     
   INTO #ExistingAssociatesCognizantActive     
   FROM #ExistingAssociatesActive ea     
   JOIN avl.Customer c ON ea.CustomerID = c.CustomerID     
   WHERE c.IsCognizant = 1    
    
   UPDATE na SET na.LocationID = lm.ID     
   FROM #ExistingAssociatesCognizantActive na     
   JOIN esa.LocationMaster lm ON na.Assignment_Location = lm.Assignment_Location    
    
   DROP TABLE #ExistingAssociatesActive    
    
   --SELECT '#ExistingAssociatesCognizantActive'    
   --SELECT * FROM #ExistingAssociatesCognizantActive    
    
   /* -- Existing Associates DeActivated -- */    
   SELECT ad.*     
   INTO #ExistingAssociatesDeActivated     
   FROM AVL.MAS_LoginMaster (NOLOCK) lm     
   JOIN #AssociateDetails ad ON lm.EmployeeID = ad.AssociateID AND lm.ProjectID = ad.ProjectID AND lm.isDeleted = 1    
    
   SELECT ea.*     
   INTO #ExistingAssociatesCognizantDeActivated     
   FROM #ExistingAssociatesDeActivated ea     
   JOIN avl.Customer c ON ea.CustomerID = c.CustomerID     
   WHERE c.IsCognizant = 1    
    
   UPDATE na SET na.LocationID = lm.ID     
   FROM #ExistingAssociatesCognizantDeActivated na     
   JOIN esa.LocationMaster lm ON na.Assignment_Location = lm.Assignment_Location    
    
   DROP TABLE #ExistingAssociatesDeActivated    
    
   --SELECT '#ExistingAssociatesCognizantDeActivated'    
   --SELECT * FROM #ExistingAssociatesCognizantDeActivated      
   /* -- New Associates -- */    
   SELECT ad.*     
   INTO #newAssociates     
   FROM #AssociateDetails AS ad WHERE NOT EXISTS     
   (     
    SELECT UserID FROM AVL.MAS_LoginMaster (NOLOCK) AS lm     
    WHERE lm.EmployeeID = ad.AssociateID AND lm.ProjectID = ad.ProjectID    
   )    
    
   UPDATE na SET na.LocationID = lm.ID     
   FROM #newAssociates na     
   JOIN esa.LocationMaster lm ON na.Assignment_Location = lm.Assignment_Location    
    
   --SELECT '#newAssociates'    
   --SELECT * FROM #newAssociates    
    
   /* -- Removed Associates from project -- */    
   SELECT ad.*     
   INTO #RemovedAssociates     
   FROM AVL.MAS_LoginMaster (NOLOCK) AS ad     
   JOIN avl.Customer (NOLOCK) c ON c.CustomerID = ad.CustomerID     
   WHERE (IsNonESAAuthorized IS NULL OR IsNonESAAuthorized = 0)    
    AND NOT EXISTS     
    (     
     SELECT lm.AssociateID FROM #AssociateDetails AS lm     
     WHERE lm.AssociateID = ad.EmployeeID AND lm.ProjectID = ad.ProjectID     
    )     
    
   --SELECT '#RemovedAssociates'    
   --SELECT * FROM #RemovedAssociates    
    
       
    
   IF EXISTS (SELECT 1 FROM #newAssociates)    
   BEGIN     
        
    INSERT INTO AVL.MAS_LoginMaster    
    (    
     ProjectID,    
     CustomerID,    
     EmployeeID,    
     EmployeeName,    
     EmployeeEmail,    
     HCMSupervisorID,    
     TSApproverID,     
     CreatedDate,    
     CreatedBy,    
     IsDeleted,    
     LocationID,    
     Offshore_Onsite,    
     IsNonESAAuthorized    
    )    
    SELECT ProjectID,     
      CustomerID,     
      TRIM(AssociateID) AS AssociateID,   
      AssociateName,     
      Email,    
      Supervisor_ID,    
      Supervisor_ID,    
      GETDATE(),    
      'System',    
      0,    
      LocationID,    
      Offshore_Onsite,    
      0     
    FROM #newAssociates      
    WHERE ISNULL(ProjectID, 0) > 0 AND ISNULL(CustomerID, 0) > 0    
    
   END    
    
   IF EXISTS (SELECT 1 FROM #ExistingAssociatesCognizantActive)    
   BEGIN     
    
    UPDATE at SET at.EmployeeName = ea.AssociateName,    
        at.EmployeeEmail = ea.Email,    
        at.HcmSupervisorID = ea.Supervisor_ID,    
        at.LocationID = ea.LocationID,    
        at.Offshore_Onsite = ea.Offshore_Onsite,    
        at.ModifiedDate = GETDATE(),    
        at.ModifiedBy = 'System',    
        at.IsNonESAAuthorized = 0       
    FROM AVL.MAS_LoginMaster (NOLOCK) at     
    JOIN #ExistingAssociatesCognizantActive ea     
     ON at.EmployeeID = ea.AssociateID AND at.ProjectID = ea.ProjectID AND at.isDeleted = 0    
      
   END    
    
   IF EXISTS (SELECT 1 FROM #ExistingAssociatesCognizantDeActivated)    
   BEGIN     
    
    UPDATE at SET at.EmployeeName = ea.AssociateName,    
        at.EmployeeEmail = ea.Email,    
        at.HcmSupervisorID = ea.Supervisor_ID,    
        at.LocationID = ea.LocationID,    
        at.Offshore_Onsite = ea.Offshore_Onsite,    
        at.IsDeleted = 0,    
        at.ModifiedDate = GETDATE(),    
        at.ModifiedBy = 'System',    
        at.IsNonESAAuthorized = 0        
    FROM AVL.MAS_LoginMaster (NOLOCK) at     
    JOIN #ExistingAssociatesCognizantDeActivated ea     
     ON at.EmployeeID = ea.AssociateID AND at.ProjectID = ea.ProjectID AND at.isDeleted = 1    
      
   END    
    
    
   IF EXISTS (SELECT 1 FROM #RemovedAssociates)    
   BEGIN     
    
    UPDATE at SET     
       at.IsDeleted = 1,    
       at.ModifiedDate = GETDATE(),    
       at.ModifiedBy = 'System'       
    FROM AVL.MAS_LoginMaster (NOLOCK) at     
    JOIN #RemovedAssociates ea     
     ON at.EmployeeID = ea.EmployeeID AND at.ProjectID = ea.ProjectID AND at.isDeleted = 0     
        
   END    
            
    
   /* ---- Account changed users ---*/    
   SELECT LM.* INTO #AccountChange FROM AVL.MAS_LoginMaster LM WHERE NOT EXISTS     
   (    
    SELECT AD.AssociateID FROM #AssociateDetails AD WHERE AD.AssociateID=Lm.EmployeeID and Ad.CustomerID=Lm.CustomerID     
   )     
   AND lm.IsDeleted=0     
   AND LM.IsNonESAAuthorized=1     
    
   IF EXISTS( SELECT 1 FROM #AccountChange)    
   BEGIN     
    UPDATE LM SET     
       LM.IsDeleted = 1,    
       LM.ModifiedDate = GETDATE(),    
       LM.ModifiedBy = 'System'       
    FROM AVL.MAS_LoginMaster (NOLOCK) LM     
    JOIN #AccountChange AC ON LM.EmployeeID = AC.EmployeeID AND LM.ProjectID = AC.ProjectID    
    WHERE  LM.IsDeleted=0 and LM.IsNonESAAuthorized=1     
   END    
    
   DROP TABLE #AssociateDetails    
   DROP TABLE #AccountChange    
   DROP TABLE #ExistingAssociatesCognizantActive    
   DROP TABLE #ExistingAssociatesCognizantDeActivated    
   DROP TABLE #newAssociates    
   DROP TABLE #RemovedAssociates    
    
  END    
  COMMIT TRAN    
    
 END TRY    
 BEGIN CATCH        
    
  ROLLBACK TRAN    
    
  UPDATE [$(AVMCOEESADB)].[DBO].ESAJobStatus SET AppvisionESALiveRefresh = 0  
    
  DECLARE @ErrorMessage VARCHAR(MAX);    
  DECLARE @MailSubject VARCHAR(MAX);      
  DECLARE @MailBody  VARCHAR(MAX);    
    
  SELECT @ErrorMessage = ERROR_MESSAGE()    
  SELECT @ErrorMessage AS ErrorMessage    
    
  SELECT @MailSubject = CONCAT(@@SERVERNAME,': ESA Job Failure Notification')    
    
  SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in AppVision PROD ESA Refresh during the ESA Job Execution!<br>    
       <br>Error: ', @ErrorMessage,    
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')    
    
  -- Insert Error Details      
  -- EXEC AVL_InsertESAJobError '[AVL].[EvaluateEmployeeESA]', @ErrorMessage, 0, 'AppVision ESA  to Live Data Refresh', @@SERVERNAME    
  INSERT INTO [$(AVMCOEESADB)].DBO.ESAJobErrors        
  (    
   JobName,    
   ErrorSource,    
   ErrorDescription,    
   CreatedBy,    
   CreatedDate,    
   ServerName    
  )        
  SELECT 'AppVision ESA  to Live Data Refresh', '[AVL].[EvaluateEmployeeESA]', @ErrorMessage, '0', GETDATE(), @@SERVERNAME    
    
  ---Mail Option Added by Annadurai on 11.01.2019 to send mail during error ESAJob    
       DECLARE @recipientsAddress NVARCHAR(4000)='';    
       SET @recipientsAddress = (SELECT ConfigValue FROM AVL.AppLensConfig WHERE ConfigName='Mail' AND IsActive=1);       
       EXEC [AVL].[SendDBEmail] @To=@recipientsAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody
	    ------------------------------------------------------------     
      
 END CATCH      
    
END  


