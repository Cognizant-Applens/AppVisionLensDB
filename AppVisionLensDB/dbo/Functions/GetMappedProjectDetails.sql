/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ==============================================================  
-- Author:  835658  
-- Create date: 11 May 2021  
-- Description: Function is to get project details for user 
-- ==============================================================  
      
CREATE FUNCTION [dbo].[GetMappedProjectDetails]
(
	@EmployeeID VARCHAR(20), 
	@CustomerID AS INT,
	@RoleID AS INT=NULL
)
RETURNS TABLE 
AS
RETURN 
(
	
SELECT  
UDF.EmployeeID,
UDF.AccessLevelID,
UDF.ProjectID,
UDF.ESAProjectID,
UDF.CustomerID,
UDF.ProjectName,
C.CustomerName,
UDF.RoleName,
UDF.DataSource
FROM 
(SELECT 
DISTINCT URM.EmployeeID,
URM.AccessLevelID ,
COALESCE(PM.ProjectID,PM1.ProjectID,PM2.ProjectID) AS ProjectID,
COALESCE(PM.EsaProjectID,PM1.EsaProjectID,PM2.EsaProjectID) AS ESAProjectID,
COALESCE(PM.ProjectName,PM1.ProjectName,PM2.ProjectName) AS ProjectName,
COALESCE(PM.CustomerID,C.CustomerID,C1.CustomerID) AS CustomerID,
RM.RoleName,
C.CustomerName,
URM.DataSource
FROM AVL.UserRoleMapping URM
INNER JOIN AVL.RoleMaster RM ON RM.RoleId=URM.RoleID
LEFT JOIN [MAS].[BusinessUnits] bu on URM.AccessLevelID = bu.BusinessUnitID AND URM.AccessLevelSourceID=2
LEFT JOIN AVL.Customer C1 on c1.BusinessUnitID=bu.BusinessUnitID and C1.IsDeleted <>1
LEFT JOIN AVL.MAS_ProjectMaster PM2 on pm2.CustomerID=c1.CustomerID and PM2.IsDeleted <>1
LEFT JOIN AVL.MAS_ProjectMaster PM ON URM.AccessLevelID = PM.ProjectID AND URM.AccessLevelSourceID=4 and PM.IsDeleted <>1
LEFT JOIN AVl.Customer C ON URM.AccessLevelID= C.CustomerID AND URM.AccessLevelSourceID=3 and C.IsDeleted <>1
LEFT JOIN AVL.MAS_ProjectMaster PM1 ON PM1.CustomerID=C.CustomerID AND PM1.CustomerID=URM.AccessLevelID and PM1.IsDeleted <>1
WHERE URM.EmployeeID=@EmployeeID AND URM.IsActive=1
AND URM.RoleID = CASE WHEN @RoleID=0 THEN URM.RoleID
ELSE  @RoleID END
AND COALESCE(PM.CustomerID,C.CustomerID,C1.CustomerID)=@CustomerID
) UDF INNER JOIN AVL.Customer C 
ON UDF.CustomerID=C.CustomerID
)
