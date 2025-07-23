CREATE PROCEDURE GetMigratedParentAccountsFromCRS    
AS    
BEGIN    
Truncate table dbo.MigratedParentAccounts    
 insert into dbo.MigratedParentAccounts (Account,AccountID,ParentAccountID,ParentAccount,IsActive,LastModified)     
 (SELECT       
 a.[Name]  as CustomerName    
 ,a.[Peoplesoft_Customer_Id__C] as CustomerID,    
 a.Financial_Ultimate_Customer_Id__C as ParentID,    
 b.Name ,1 as Active, getdate() as LastModified    
 FROM CTSINTBMVPCRSR1.[CentralRepository_Report].[dbo].[vw_CentralRepository_SFDC_Account] a   
 Join CTSINTBMVPCRSR1.[CentralRepository_Report].[dbo].[vw_CentralRepository_SFDC_Financial_Ultimate_Parent_Account] b   
 on a.Financial_Ultimate_Customer_Id__C= b.Financial_Ultimate_Customer_id__C       
 where Crm_Status__C='Active') ORDER BY b.Name    
   
    
END