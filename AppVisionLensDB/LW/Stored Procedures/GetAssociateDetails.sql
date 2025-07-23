
/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
CREATE PROCEDURE [LW].[GetAssociateDetails] --  '800308'              
 @AssociateID NVARCHAR(50)                
AS                
BEGIN                
              
 DECLARE @Esaprojectid nvarchar(50);              
 DECLARE @projectid int              
 Select @Esaprojectid = Esaprojectid from avl.mas_projectmaster WITH(NOLOCK)           
 where projectid = @projectid and isdeleted = 0              
 -- SET NOCOUNT ON added to prevent extra result sets from                
 -- interfering with SELECT statements.                
 SET NOCOUNT ON;                
 BEGIN TRY                
  --Section 1 :- Getting the EmployeeID & EmployeeName                
  SELECT DISTINCT TOP 1 EmployeeID AS ID,                
    EmployeeName AS Name                
  FROM AVL.MAS_LoginMaster WHERE EmployeeID=@AssociateID AND IsDeleted=0                
                
  --Section 2 :- Getting the Project ID & Project Name                
  SELECT               
  URM.ProjectID AS ID,                
  URM.ProjectName AS Name,                
  URM.EsaProjectID as esaProjectID                
  FROM RLE.VW_ProjectLevelRoleAccessDetails  URM (NOLOCK)     where URM.associateid= @AssociateID        
  --INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK)                
  --ON URM.esaprojectid=PM.esaprojectid                
  --AND URM.associateid='687596'                
  --AND PM.isdeleted = 0              
  UNION                 
  SELECT                 
  PM.ProjectID AS ID,                
  PM.ProjectName AS Name,                
  PM.EsaProjectID  as esaProjectID                
  FROM AVL.MAS_LoginMaster  LM (NOLOCK)                
  INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK)                
  ON LM.ProjectID=PM.ProjectID                
  AND LM.EmployeeID=@AssociateID                
  AND LM.IsDeleted=0  AND PM.IsDeleted=0                
                
  --Section 3 :- Getting the Customer ID & Customer Name                
  SELECT                 
  URM.CustomerID AS ID,                
  URM.CustomerName AS Name                
  FROM RLE.VW_ProjectLevelRoleAccessDetails  URM (NOLOCK)    where URM.associateid= @AssociateID             
  --INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK)                
  --ON URM.Esaprojectid=PM.EsaProjectID                
  --AND URM.Associateid=@AssociateID                
  --INNER JOIN AVL.Customer C ON C.CustomerID=PM.CustomerID                
  --AND C.IsDeleted=0  AND PM.IsDeleted=0                
  UNION                 
  SELECT                 
  C.CustomerID AS ID,                
  C.CustomerName AS Name                
  FROM AVL.MAS_LoginMaster  LM (NOLOCK)                
  INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK)                
  ON LM.ProjectID=PM.ProjectID                
  AND LM.EmployeeID=@AssociateID                
  AND LM.IsDeleted=0                
  INNER JOIN AVL.Customer C ON C.CustomerID=PM.CustomerID                
  AND C.IsDeleted=0 AND PM.IsDeleted=0                
  --Section 2 :- Getting the Role ID & Role Name                
  SELECT                 
  DISTINCT R.ApplensRoleID AS ID,                
  R.RoleName AS Name                
  FROM RLE.VW_ProjectLevelRoleAccessDetails R WITH (NOLOCK)            
  --inner join AVL.MAS_ProjectMaster mp WITH (NOLOCK)           
  --on mp.EsaProjectID = r.ESAProjectID              
  --inner join avl.Customer c WITH (NOLOCK)           
  --on mp.CustomerId = c.CustomerID              
  where R.Associateid =  @AssociateID              
  AND  R.Rolekey = 'RLE003'              
  UNION                
  SELECT DISTINCT 9 AS ID,                
  'Lead' AS Name FROM avl.MAS_LoginMaster L WITH (NOLOCK)               
  INNER JOIN AVL.MAS_ProjectMaster PM WITH (NOLOCK)          
  ON PM.ProjectID=L.ProjectID                 
  WHERE  (L.HcmSupervisorID = @AssociateID or  L.TSApproverID =  @AssociateID)                 
  AND l.IsDeleted = 0 and ISNULL(PM.IsDeleted,0)=0                 
  UNION                
  SELECT                 
  DISTINCT R.ApplensRoleId AS ID,                
  R.RoleName AS Name                
  FROM RLE.VW_ProjectLevelRoleAccessDetails R WITH (NOLOCK)                
  where R.Associateid = @AssociateID                
  AND R.RoleKey = 'RLE023'                 
                
END TRY                
BEGIN CATCH                
 SELECT                
  ERROR_NUMBER() AS ErrorNumber,                
  ERROR_STATE() AS ErrorState,                
  ERROR_SEVERITY() AS ErrorSeverity,                
  ERROR_PROCEDURE() AS ErrorProcedure,                
  ERROR_LINE() AS ErrorLine,                
  ERROR_MESSAGE() AS ErrorMessage;                
END CATCH;                
END
