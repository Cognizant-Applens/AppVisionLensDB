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
-- Author   : Dinesh Babu  
-- Create date   : 24 Dec 2018  
-- Description   : Insert, Update, Activate and De-activate Customer Details in Applens  
-- Revision By   : Annadurai.S  
-- Revision Date : 11 Jan 2019  
-- Revision Desc : Add default value of IsDaliy=0 as per Viji's instruction    
-- ====================================================================================================================   
CREATE   PROCEDURE [AVL].[EvaluateCustomerESA]  
  
AS   
  
BEGIN   
  
 BEGIN TRY  
  BEGIN TRAN   
  
   IF EXISTS (SELECT 1 FROM [$(AVMCOEESADB)].[DBO].[ESAJobStatus] WHERE AppvisionProdESARefresh = 1)  
   BEGIN  
  
    SELECT bua.AccountID,   
      bua.AccountName,  
      bul.BusinessUnitID,  
      bua.BUID AS esaBuid,  
      bu.BUName,  
      ESABU.BusinessUnitID AS BusinessUnitID -- New BU after Department Change  
    INTO #BUAccounts   
    FROM [ESA].[BUAccounts] bua   
    JOIN [ESA].BusinessUnits bu ON bua.BUID = bu.BUID  
    JOIN [MAS].[BusinessUnits] bul ON bu.BUName = bul.BusinessUnitName  
    JOIN [ESA].AccountHierarchyDetails AH  
     ON AH.Peoplesoft_Customer_Id = bua.AccountID  
    JOIN [ESA].ESABusinessUnit ESABU  
     ON ESABU.BusinessUnitName = AH.Bu  
    WHERE bua.IsActive = 1  
       
    SELECT bua.*   
    INTO #ExistingCustomerActive   
    FROM #BUAccounts bua   
    JOIN Avl.Customer c ON  bua.AccountID = c.ESA_AccountID   
    WHERE c.IsCognizant = 1 AND c.IsDeleted = 0   
          
    SELECT C.*   
    INTO #ExistingCustomerDeActivated   
    FROM #BUAccounts bua   
    JOIN Avl.Customer c ON bua.AccountID = c.ESA_AccountID   
    WHERE c.IsCognizant = 1 AND c.IsDeleted = 1   
  
    SELECT AccountID   
    INTO #NewCustomerList   
    FROM #BUAccounts  
    EXCEPT   
    SELECT ESA_AccountID   
    FROM AVL.Customer   
    WHERE IsCognizant = 1  
  
    SELECT bua.*   
    INTO #NewCustomer   
    FROM #BUAccounts AS bua   
    JOIN #NewCustomerList ncl ON bua.AccountID = ncl.AccountID   
  
    DROP TABLE #NewCustomerList  
  
    SELECT ESA_AccountID   
    INTO #RemovedCustomerList   
    FROM avl.Customer   
    WHERE IsCognizant = 1  
    EXCEPT  
    SELECT AccountID   
    FROM #BUAccounts  
  
    SELECT c.*   
    INTO #RemovedCustomer   
    FROM avl.Customer c   
    JOIN #RemovedCustomerList rcl ON c.ESA_AccountID = rcl.ESA_AccountID  
  
    DROP TABLE #RemovedCustomerList  
  
    /* -- Insert New Customer -- */  
    IF EXISTS (SELECT 1 FROM #NewCustomer)  
    BEGIN   
       
     INSERT INTO AVl.Customer  
     (  
      CustomerName,  
      BUID,  
      BusinessUnitID, -- New BU  
      IsCognizant,  
      ESA_AccountID,  
      IsDeleted,  
      isDaily,  
      CreatedBy,  
      CreatedDate  
     )  
     SELECT BU.AccountName,  
       BU.BUID,  
       BU.BusinessUnitID,  
       1,  
       BU.AccountID,  
       0,  
       0,  
       'System',  
       GETDATE()   
     FROM #NewCustomer BU     
       
     CREATE TABLE #CustomerList  
     (  
      SNO    INT IDENTITY(1,1),  
      Customerid  INT,  
      CustomerName NVARCHAR(50)       
     )  
  
     INSERT INTO #CustomerList (Customerid, CustomerName)  
      SELECT c.Customerid, c.CustomerName   
      FROM AVl.Customer c   
      JOIN #NewCustomer nc ON c.ESA_AccountID = nc.AccountID  
  
     DECLARE @Customer  INT   
     DECLARE @TotalCustomer INT  
  
     SELECT @TotalCustomer = COUNT(1) FROM #CustomerList  
  
     SET @Customer = 1  
  
     WHILE (@Customer <= @TotalCustomer)  
     BEGIN   
           
      DECLARE @CustomerID  INT  
      DECLARE @LOBID   INT  
      DECLARE @PortFolioID INT  
  
      SELECT @CustomerID = customerid   
      FROM #CustomerList   
      WHERE SNO = @Customer  
           
      IF EXISTS (SELECT 1 FROM AVL.BusinessCluster   
         WHERE CustomerID = @CustomerID AND [BusinessClusterName] = 'LOB' AND IsDeleted = 0)  
      BEGIN  
  
       SELECT @LOBID = BusinessClusterID   
       FROM AVL.BusinessCluster   
       WHERE CustomerID = @CustomerID AND [BusinessClusterName] = 'LOB' AND IsDeleted = 0  
  
      END  
      ELSE  
      BEGIN  
        
       INSERT INTO AVL.BusinessCluster   
       (  
        [BusinessClusterName],  
        [ParentBusinessClusterID],  
        [IsHavingSubBusinesss],  
        [IsDeleted],  
        [CustomerID],  
        [CreatedBy],  
        [CreatedDate]  
       )  
       VALUES('LOB', NULL, 1, 0, @CustomerID, 'System', GETDATE())  
           
       SET @LOBID = SCOPE_IDENTITY()   
  
      END  
           
      IF EXISTS (SELECT 1 FROM AVL.BusinessCluster WHERE CustomerID = @CustomerID   
         AND [BusinessClusterName] = 'Portfolio' AND IsDeleted = 0 AND [ParentBusinessClusterID] = @LOBID)  
      BEGIN  
             
       SELECT @PortFolioID = BusinessClusterID   
       FROM AVL.BusinessCluster   
       WHERE CustomerID = @CustomerID AND [BusinessClusterName] = 'Portfolio' AND IsDeleted = 0 AND [ParentBusinessClusterID] = @LOBID  
         
      END  
      ELSE  
      BEGIN  
            
       INSERT INTO AVL.BusinessCluster  
       (  
        [BusinessClusterName],  
        [ParentBusinessClusterID],  
        [IsHavingSubBusinesss],  
        [IsDeleted],  
        [CustomerID],  
        [CreatedBy],  
        [CreatedDate]  
       )  
       VALUES('Portfolio', @LOBID, 1, 0, @CustomerID, 'System', GETDATE())  
  
       SET @PortFolioID = SCOPE_IDENTITY()   
         
      END  
        
      IF NOT EXISTS (SELECT 1 FROM AVL.BusinessCluster WHERE CustomerID = @CustomerID   
       AND [BusinessClusterName] = 'App Group' AND IsDeleted = 0 AND [ParentBusinessClusterID] = @PortFolioID)  
      BEGIN  
              
       INSERT into AVL.BusinessCluster  
       (  
        [BusinessClusterName],  
        [ParentBusinessClusterID],  
        [IsHavingSubBusinesss],  
        [IsDeleted],  
        [CustomerID],  
        [CreatedBy],  
        [CreatedDate]  
       )  
       VALUES('App Group', @PortFolioID, 0, 0, @CustomerID, 'System', GETDATE())  
  
      END  
  
      IF NOT EXISTS (SELECT 1 FROM avl.PRJ_ConfigurationProgress WHERE ScreenID = 1 AND CustomerID = @CustomerID)  
      BEGIN  
             
       INSERT INTO avl.PRJ_ConfigurationProgress  
       (  
        CustomerID,  
        ScreenID,  
        CompletionPercentage,  
        IsDeleted,  
        CreatedBy,  
        CreatedDate)  
       VALUES (@CustomerID, 1, 25, 0, 'System', GETDATE())  
             
      END  
  
      SET @Customer = @Customer + 1  
        
     END  
  
     DROP TABLE #CustomerList  
    END  
       
    /* -- Update isdeleted = 1 for not available in new  list */  
    IF EXISTS (SELECT 1 FROM #RemovedCustomer)  
    BEGIN   
       
     UPDATE c   
     SET c.ISDeleted  = 1,  
      ModifiedBy  = 'System',  
      ModifiedDate = GETDATE()   
     FROM AVl.Customer c   
     JOIN #RemovedCustomer rc ON rc.ESA_AccountID = c.ESA_AccountID AND c.IsCognizant = 1  
       
    END  
       
    /* -- Updating existing Customer Active --*/  
    IF EXISTS (SELECT 1 FROM #ExistingCustomerActive)  
    BEGIN   
       
     UPDATE c   
     SET c.BusinessUnitID = ec.BusinessUnitID,  
      c.CustomerName = ec.AccountName,  
      ModifiedBy  = 'System',  
      ModifiedDate = GETDATE()  
     FROM AVl.Customer c   
     JOIN #ExistingCustomerActive ec ON ec.AccountID = c.ESA_AccountID   
     WHERE c.IsCognizant = 1  
       
    END  
  
    /* -- Updating existing Customer DeActivated --*/  
    IF EXISTS (SELECT 1 FROM #ExistingCustomerDeActivated)  
    BEGIN   
       
     UPDATE c   
     SET c.IsDeleted  = 0,  
      c.BusinessUnitID = ec.BusinessUnitID,  
      c.CustomerName = ec.CustomerName,  
      ModifiedBy  = 'System',  
      ModifiedDate = GETDATE()  
     FROM AVl.Customer c   
     JOIN #ExistingCustomerDeActivated ec ON ec.ESA_AccountID = c.ESA_AccountID  
     WHERE c.IsCognizant = 1  
       
    END  
   
    DROP TABLE #BUAccounts  
    DROP TABLE #NewCustomer  
    DROP TABLE #ExistingCustomerActive  
    DROP TABLE #RemovedCustomer  
    DROP TABLE #ExistingCustomerDeActivated  
  
   END  
  COMMIT TRAN  
 END TRY  
 BEGIN CATCH      
  ROLLBACK TRAN  
  
  UPDATE [$(AVMCOEESADB)].[DBO].ESAJobStatus SET AppvisionESALiveRefresh = 0  
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  DECLARE @MailSubject  VARCHAR(MAX);    
  DECLARE @MailBody     VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  SELECT @ErrorMessage AS ErrorMessage  
  
  SELECT @MailSubject = CONCAT(@@SERVERNAME,': ESA Job Failure Notification')  
  
  SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in AppVision ESA  to Live Data Refresh during the ESA Job Execution!<br>  
       <br>Error: ', @ErrorMessage,  
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')  
  
  -- Insert ESA Job Error Details    
  -- EXEC AVL_InsertESAJobError '[AVL].[EvaluateCustomerESA]', @ErrorMessage, 0, 'AppVision ESA  to Live Data Refresh', @@SERVERNAME  
  INSERT INTO [$(AVMCOEESADB)].DBO.ESAJobErrors    
  (  
   JobName,  
   ErrorSource,  
   ErrorDescription,  
   CreatedBy,  
   CreatedDate,  
   ServerName  
  )     
  SELECT 'AppVision ESA  to Live Data Refresh', '[AVL].[EvaluateCustomerESA]', @ErrorMessage, '0', GETDATE(), @@SERVERNAME   
  
  
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


