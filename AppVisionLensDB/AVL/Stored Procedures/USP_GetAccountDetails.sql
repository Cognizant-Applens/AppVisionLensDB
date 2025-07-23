/***************************************************************************              
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET              
*Copyright [2018] – [2021] Cognizant. All rights reserved.              
*NOTICE: This unpublished material is proprietary to Cognizant and              
*its suppliers, if any. The methods, techniques and technical              
  concepts herein are considered Cognizant confidential and/or trade secret information.               
                
*This material may be covered by U.S. and/or foreign patents or patent applications.               
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.              
***************************************************************************/              
              
-- ====================================================================              
-- author:                
-- create by: 688715              
-- create date: 11/21/2020              
-- description: getting account details using employeeid              
-- EXEC [AVL].[USP_GetAccountDetails] '835205'              
-- ====================================================================      
  
CREATE PROCEDURE [AVL].[USP_GetAccountDetails] --'800308'                       
 -- Add the parameters for the stored procedure here                            
 @AssociateID NVARCHAR(100)                            
AS                            
BEGIN                               
 SET NOCOUNT ON;                              
BEGIN TRY                             
 SELECT BusinessUnitName, BusinessUnitID,ApplensRoleID, RoleName,RoleKey,Priority, ESACustomerID, AssociateId ,ESAProjectID                    
  into #tempAssociateRoleData                          
    FROM RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK)                   
 Where Associateid = @AssociateID --and   BusinessUnitID not in (6)            
 CREATE TABLE #AccountDetails                              
 (                              
  BUID BIGINT,                              
  BUName NVARCHAR(50),                              
  AccountID BIGINT,                              
  AccountName NVARCHAR(50),                              
  ProjectID BIGINT,                              
  ProjectName NVARCHAR(50),                              
  IsCognizant INT,                              
  IsEffortConfigured INT,                              
  ITSMEffort INT,                              
  EsaProjectID NVARCHAR(50),                              
  SupportTypeId INT,                              
  RoleId INT,                              
  RoleName NVARCHAR(100),                              
  Priority INT,                        
  RoleKey nvarchar(100),            
  IsDebtEnabled char(1),            
  CompletionPercentage int            
 )                              
                                
 INSERT INTO #AccountDetails                                  
 SELECT                              
  DISTINCT                               
  PL.BusinessUnitID,                              
  PL.BusinessUnitName,                              
  C.CustomerID AS AccountID,                               
  C.CustomerName AS AccountName,                               
  P.ProjectID AS ProjectID,                               
  P.ProjectName AS ProjectName,                               
  C.IsCognizant,                              
  ISNULL(CAST(C.IsEffortConfigured AS INT),0) AS IsEffortConfigured,                              
  CASE WHEN CM.ServiceDartColumn IS NOT NULL THEN 1 ELSE 0 END as ITSMEFFORT,                              
  P.EsaProjectID,                              
  PC.SupportTypeId,                              
  PL.ApplensRoleID as RoleId,                              
  PL.RoleName,                          
  PL.[Priority],                        
  PL.RoleKey,            
  p.IsDebtEnabled,            
  CP.CompletionPercentage            
 FROM                              
 #tempAssociateRoleData PL (NOLOCK)                              
 INNER JOIN                               
  AVL.Customer(NOLOCK)  C ON C.ESA_AccountId=PL.ESACustomerID AND C.IsDeleted<>1                              
 INNER JOIN                              
  AVL.MAS_ProjectMaster(NOLOCK) P ON P.EsaProjectID=PL.ESAProjectid and P.CustomerID = C.CustomerId AND P.IsDeleted<>1                              
 INNER JOIN                               
  AVL.MAP_ProjectConfig(NOLOCK) PC ON PC.ProjectID = P.ProjectID                              
 LEFT JOIN                               
  AVL.PRJ_ConfigurationProgress(NOLOCK)  CP ON CP.ProjectID=P.ProjectID                           
  AND CP.IsDeleted<>1 AND CP.ScreenID=5                     
  INNER JOIN                        
  RLE.VW_GetRoleMaster(NOLOCK) RM ON RM.ApplensRoleId = PL.ApplensRoleId  AND RM.RoleKey IN ('RLE002','RLE003','RLE001')                        
 LEFT JOIN                               
  AVL.ITSM_PRJ_SSISColumnMapping CM (NOLOCK) ON CM.ProjectID=P.ProjectID AND CM.ServiceDartColumn='ITSM Effort'                              
 WHERE                               
  PL.Associateid = @AssociateID  --and c.CustomerID <> 2                            
                              
 SELECT                              
 DISTINCT BUID, BUName                              
 FROM                              
  #AccountDetails(NOLOCK) where IsDebtEnabled='Y' And CompletionPercentage=100                             
                                
 SELECT                              
 DISTINCT BUID, AccountID,AccountName,IsCognizant,IsEffortConfigured                              
 FROM                              
  #AccountDetails (NOLOCK)  where IsDebtEnabled='Y' And CompletionPercentage=100                            
                                 
 SELECT                              
 DISTINCT BUID, AccountID,ProjectID,ProjectName, SupportTypeId, IsCognizant,                               
    IsEffortConfigured, ITSMEffort, EsaProjectID                              
 FROM                              
  #AccountDetails(NOLOCK)                         
  WHERE RoleKey IN ('RLE002','RLE003','RLE001')   AND IsDebtEnabled='Y' And CompletionPercentage=100                      
  order by ProjectName ASC                              
                              
 SELECT                               
 DISTINCT ProjectID,RoleId,RoleName,Priority                               
 FROM                                 
   #AccountDetails  (NOLOCK)                             
                               
 DROP TABLE IF EXISTS #AccountDetails                              
END TRY                               
 BEGIN CATCH                                    
  DROP TABLE IF EXISTS #AccountDetails                              
                              
  DECLARE @ErrorMessage VARCHAR(MAX);                      
  SELECT @ErrorMessage = ERROR_MESSAGE()                                
                                
  --INSERT Error                                    
  EXEC AVL_InsertError '[AVL].[USP_GetAccountDetails]', @ErrorMessage,@AssociateID                        
                                  
 END CATCH           
 SET NOCOUNT OFF;          
END
