/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ADM].[GetCCARoleDetails]  
  (                
   	@UserId NVARCHAR(50) = ''
  )
AS
BEGIN  
 
BEGIN TRY 
  SET NOCOUNT ON;

SELECT DISTINCT 0 AS UserId, EmployeeID,PM.ProjectID,PM.ProjectName,C.CustomerID,
		CustomerName,PM.EsaProjectID,C.BusinessUnitID, b.BusinessUnitName,isnull(ESA_AccountID,0)ESA_AccountID,
		r.RoleName  as Role, SW.IsApplensAsALM,C.IsCognizant,pp.PODDetailID
		FROM  [PP].[Project_PODDetails] pp
		inner join ADM.AssociateAttributes aa on pp.PODDetailID=aa.PODDetailID
		inner join avl.MAS_LoginMaster l on l.UserID= aa.UserId 
		inner join pp.ALM_RoleMaster r on r.RoleID= aa.CCARole
		--AVL.UserRoleMapping URM (NOLOCK)
		--INNER JOIN MAS.RLE_Roles RM (NOLOCK) ON  RM.RoleID = URM.RoleID
		INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON pp.ProjectID = PM.ProjectID
		AND pp.IsDeleted=0 AND PM.IsDeleted=0
		INNER JOIN [AVL].[Customer] C (NOLOCK) ON C.CustomerID = PM.CustomerID AND C.IsDeleted=0
		INNER JOIN MAS.BusinessUnits  B (nolock) on B.BusinessUnitID = C.BusinessUnitID
		--INNER JOIN pp.OplEsaData OPL (NOLOCK) ON OPL.ProjectID=PM.ProjectID AND OPL.IsDeleted=0
		INNER JOIN pp.ProjectAttributeValues PAV (NOLOCK) ON PM.ProjectID =PAV.ProjectID AND PAV.IsDeleted=0
		INNER JOIN MAS.PPAttributeValues PPAV (NOLOCK) ON PPAV.AttributeValueID=PAV.AttributeValueID
		AND PPAV.AttributeID=1 AND PPAV.IsDeleted=0
		INNER JOIN PP.ScopeOfWork SW (NOLOCK) ON SW.ProjectID = PM.ProjectID AND SW.IsDeleted = 0 
		---Only NonAlm User filter
		and SW.IsApplensAsALM=0

		WHERE l.EmployeeID= @UserId --AND URM.IsActive=1 --AND OPL.Projectowningunit='ADM'
		AND PPAV.AttributeValueID IN (1,4) --and RM.RoleId IN ( 6,7)

UNION		
		SELECT DISTINCT 0 AS UserId, URM.AssociateId as EmployeeID,PM.ProjectID,PM.ProjectName,C.CustomerID,
		CustomerName,PM.EsaProjectID,C.BusinessUnitID, b.BusinessUnitName,isnull(ESA_AccountID,0)ESA_AccountID,
		'Product Manager' as Role, SW.IsApplensAsALM,C.IsCognizant,NULL
		--FROM  AVL.UserRoleMapping URM (NOLOCK)
		FROM [RLE].[VW_UserRoleMappingDataAccess] URM
		INNER JOIN MAS.RLE_Roles RM (NOLOCK) ON  RM.ApplensRoleID = URM.ApplensRoleID
		INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON URM.ProjectID = PM.ProjectID
		--AND URM.IsActive=1 
		AND PM.IsDeleted=0
		INNER JOIN [AVL].[Customer] C (NOLOCK) ON C.CustomerID = PM.CustomerID AND C.IsDeleted=0
		INNER JOIN MAS.BusinessUnits  B (nolock) on B.BusinessUnitID = C.BusinessUnitID
		--INNER JOIN pp.OplEsaData OPL (NOLOCK) ON OPL.ProjectID=PM.ProjectID AND OPL.IsDeleted=0
		INNER JOIN pp.ProjectAttributeValues PAV (NOLOCK) ON PM.ProjectID =PAV.ProjectID AND PAV.IsDeleted=0
		INNER JOIN MAS.PPAttributeValues PPAV (NOLOCK) ON PPAV.AttributeValueID=PAV.AttributeValueID
		AND PPAV.AttributeID=1 AND PPAV.IsDeleted=0
		INNER JOIN PP.ScopeOfWork SW (NOLOCK) ON SW.ProjectID = PM.ProjectID AND SW.IsDeleted = 0
		---Only NonAlm User filter
		and SW.IsApplensAsALM=0
		WHERE URM.AssociateId= @UserId --AND URM.IsActive=1 --AND OPL.Projectowningunit='ADM'
		AND PPAV.AttributeValueID IN (1,4) and RM.RoleKey IN ( 'RLE004','RLE005')		
 END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()	
		EXEC AVL_InsertError '[ADM].[GetCCARoleDetails] ', @ErrorMessage, @UserId,''
		RETURN @ErrorMessage
  END CATCH   
END
