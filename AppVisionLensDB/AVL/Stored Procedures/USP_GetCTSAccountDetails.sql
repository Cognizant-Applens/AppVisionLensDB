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
-- create date:           
-- Modified by : 835658          
-- Modified For:  RHMS New Role API            
-- description: getting account details using employeeid          
-- ====================================================================          
CREATE PROCEDURE [AVL].[USP_GetCTSAccountDetails]         
 -- Add the parameters for the stored procedure here              
 @AssociateID VARCHAR(100),              
 @isCognizant varchar(10)=1              
AS              
BEGIN              
-- SET NOCOUNT ON added to prevent extra result sets from              
 -- interfering with SELECT statements.              
 SET NOCOUNT ON;              
    -- SELECT statements for procedure here           
 SELECT distinct ESAProjectID,ESACustomerID,BusinessUnitID as BUID,BusinessUnitName as BUNAME INTO #temproletable     
 FROM  RLE.VW_ProjectLevelRoleAccessDetails PRA (NOLOCK) Where  PRA.AssociateId =@AssociateID --and BusinessUnitID not in (1)         
        
 CREATE TABLE #AccountDetails              
 (              
  BUID INT,              
  BUName NVARCHAR(50),              
  AccountID INT,              
  AccountName NVARCHAR(50),              
  ProjectID INT,              
  ProjectName NVARCHAR(50),              
  IsCognizant INT,              
  IsEffortConfigured INT,              
  SupportTypeId INT              
 )              
                
  INSERT INTO #AccountDetails              
  SELECT              
  --DISTINCT               
   CAST(PRA.BUID AS INT) as BUID,              
   BUName AS BUName,               
   CAST(C.CustomerID AS INT) AS AccountID,               
   C.CustomerName AS AccountName,               
   CAST(P.ProjectID AS INT) AS ProjectID,               
   P.ProjectName AS ProjectName,               
   C.IsCognizant,              
   ISNULL(CAST(C.IsEffortConfigured AS INT),0) AS IsEffortConfigured,              
   PC.SupportTypeId              
  FROM              
              
   #temproletable(NOLOCK) PRA                
   INNER JOIN              
   AVL.MAS_ProjectMaster(NOLOCK)  P ON P.ESAProjectID=PRA.ESAProjectID AND P.IsDeleted<>1 and p.IsDebtEnabled='Y'              
  INNER JOIN               
   AVL.MAP_ProjectConfig(NOLOCK) PC ON PC.ProjectID = P.ProjectID              
  INNER JOIN               
   AVL.Customer(NOLOCK)  C ON PRA.ESACustomerID= C.ESA_AccountId AND C.IsDeleted<>1              
  INNER JOIN               
   AVL.PRJ_ConfigurationProgress(NOLOCK)  CP ON CP.ProjectID=P.ProjectID  AND CP.IsDeleted<>1 AND CP.ScreenID=5 AND CP.CompletionPercentage=100                          
              
  SELECT              
  DISTINCT BUID, BUName              
  FROM              
   #AccountDetails              
                
  SELECT              
  DISTINCT BUID, AccountID,AccountName,IsCognizant,IsEffortConfigured              
  FROM              
   #AccountDetails              
                 
  SELECT              
  DISTINCT BUID, AccountID,ProjectID,ProjectName, SupportTypeId              
  FROM              
   #AccountDetails order by ProjectName ASC              
END
