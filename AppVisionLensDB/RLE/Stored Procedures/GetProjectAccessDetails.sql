/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [RLE].[GetProjectAccessDetails]
AS
BEGIN
	SELECT Distinct p.ProjectId, p.ESAProjectId, r.RoleKey, r.RoleName, rm.AssociateId, a.AssociateName
	FROM AVL.MAS_projectMaster p 
	LEFT JOIN RLE.UserRoleDataAccess da on da.CustomerId = p.CustomerId and da.Isdeleted = 0
	LEFT JOIN RLE.UserRoleMapping rm on da.RoleMappingID = rm.RoleMappingId and rm.Isdeleted = 0
	LEFT JOIN ESA.Associates a on rm.AssociateId = a.AssociateID and a.IsActive = 1
	LEFT JOIN MAS.RLE_Roles r on rm.ApplensRoleId = r.ApplensRoleId and r.IsDeleted = 0
	Where p.IsDeleted = 0 AND r.RoleKey IN (N'RLE012', N'RLE014', N'RLE013') 
	UNION
	SELECT Distinct p.ProjectId, p.ESAProjectId, r.RoleKey, r.RoleName, rm.AssociateId, a.AssociateName
	FROM AVL.MAS_projectMaster p 
	LEFT JOIN RLE.UserRoleDataAccess da on da.ProjectID = p.ProjectID and da.Isdeleted = 0
	LEFT JOIN RLE.UserRoleMapping rm on da.RoleMappingID = rm.RoleMappingId and rm.Isdeleted = 0
	LEFT JOIN ESA.Associates a on rm.AssociateId = a.AssociateID and a.IsActive = 1
	LEFT JOIN MAS.RLE_Roles r on rm.ApplensRoleId = r.ApplensRoleId and r.IsDeleted = 0
	Where p.IsDeleted = 0 AND r.RoleKey IN (N'RLE010') 

END
