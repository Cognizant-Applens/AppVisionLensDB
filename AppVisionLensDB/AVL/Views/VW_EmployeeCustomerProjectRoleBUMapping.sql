/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/



CREATE VIEW [AVL].[VW_EmployeeCustomerProjectRoleBUMapping]
AS
SELECT 
DISTINCT URM.EmployeeID,
URM.AccessLevelID ,
COALESCE(PM.ProjectID,PM1.ProjectID,PM2.ProjectID) AS ProjectID,
COALESCE(PM.EsaProjectID,PM1.EsaProjectID,PM2.EsaProjectID) AS ESAProjectID,
COALESCE(PM.ProjectName,PM1.ProjectName,PM2.ProjectName) AS ProjectName,
COALESCE(PM.CustomerID,C.CustomerID,C1.CustomerID) AS CustomerID,
URM.RoleID
FROM AVL.UserRoleMapping URM
LEFT JOIN AVL.BusinessUnit bu on URM.AccessLevelID = bu.BUID AND URM.AccessLevelSourceID=2
LEFT JOIN AVL.Customer C1 on c1.BUID=bu.BUID and C1.IsDeleted<>1
LEFT JOIN AVL.MAS_ProjectMaster PM2 on pm2.CustomerID=c1.CustomerID and PM2.IsDeleted<>1
LEFT JOIN AVL.MAS_ProjectMaster PM ON URM.AccessLevelID = PM.ProjectID AND URM.AccessLevelSourceID=4 and PM.IsDeleted<>1
LEFT JOIN AVl.Customer C ON URM.AccessLevelID= C.CustomerID AND URM.AccessLevelSourceID=3 and C.IsDeleted<>1
LEFT JOIN AVL.MAS_ProjectMaster PM1 ON PM1.CustomerID=C.CustomerID AND PM1.CustomerID=URM.AccessLevelID and PM1.IsDeleted<>1
WHERE URM.IsActive=1
