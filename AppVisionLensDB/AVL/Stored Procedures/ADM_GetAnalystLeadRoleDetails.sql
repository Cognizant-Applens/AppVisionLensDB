/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ADM_GetAnalystLeadRoleDetails]  
  (                
   	@UserId NVARCHAR(50) = ''
  )
AS
BEGIN  
 
BEGIN TRY 
  SET NOCOUNT ON;

  DECLARE @isHcmSupervisorID VARCHAR(50)
  SET @isHcmSupervisorID = (select TOP 1 HcmSupervisorID from AVL.MAS_LoginMaster (NOLOCK) WHERE  
 (IsDeleted=0  AND (TSApproverID=@UserId or HcmSupervisorID=@UserId))) 

		 SELECT DISTINCT UserId,LM.EmployeeID,PM.ProjectID,PM.ProjectName,C.CustomerID,
		 CustomerName,PM.EsaProjectID,C.BusinessUnitID, b.BusinessUnitName,isnull(ESA_AccountID,0)ESA_AccountID,
		  'Analyst' as Role, SW.IsApplensAsALM,C.IsCognizant
		 FROM  AVL.MAS_LoginMaster LM (nolock)
		 INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON LM.ProjectID = PM.ProjectID AND LM.IsDeleted=0 AND PM.IsDeleted=0
		 INNER JOIN [AVL].[Customer] C (NOLOCK) ON C.CustomerID = LM.CustomerID AND C.IsDeleted=0
		 INNER JOIN ESA.ESABusinessUnit  B (nolock) on B.BusinessUnitID = C.BusinessUnitID
		 --INNER JOIN pp.OplEsaData OPL (NOLOCK) ON OPL.ProjectID=PM.ProjectID AND OPL.IsDeleted=0 
		 INNER JOIN pp.ProjectAttributeValues PAV (NOLOCK) ON PM.ProjectID =PAV.ProjectID AND PAV.IsDeleted=0 
		 INNER JOIN MAS.PPAttributeValues PPAV (NOLOCK) ON PPAV.AttributeValueID=PAV.AttributeValueID AND PPAV.AttributeID=1 AND PPAV.IsDeleted=0
		 INNER JOIN PP.ScopeOfWork SW (NOLOCK) ON SW.ProjectID = PM.ProjectID AND SW.IsDeleted = 0
		 WHERE LM.EmployeeID=@UserId AND LM.isdeleted=0 AND PPAV.AttributeValueID IN (1,4) --OPL.Projectowningunit='ADM' AND PPAV.AttributeValueID IN (1,4)
		 AND @isHcmSupervisorID IS NULL 
	 UNION 
		 SELECT DISTINCT UserId,LM.EmployeeID,PM.ProjectId,PM.ProjectName,C.CustomerID,
		 CustomerName,PM.EsaProjectID,C.BusinessUnitID, b.BusinessUnitName,isnull(ESA_AccountID,0)ESA_AccountID,
		 'Analyst' as Role, SW.IsApplensAsALM,C.IsCognizant
		 FROM  AVL.MAS_LoginMaster LM (nolock)
		 INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON LM.ProjectID = PM.ProjectID AND LM.IsDeleted=0 AND PM.IsDeleted=0
		 INNER JOIN [AVL].[Customer] C (nolock) ON C.CustomerID = LM.CustomerID AND C.IsDeleted=0
		 INNER JOIN ESA.ESABusinessUnit  B (nolock) on B.BusinessUnitID = C.BusinessUnitID
		 --INNER JOIN pp.OplEsaData OPL (NOLOCK) ON OPL.ProjectID=PM.ProjectID AND OPL.IsDeleted=0 
		 INNER JOIN pp.ProjectAttributeValues PAV (NOLOCK) ON PM.ProjectID =PAV.ProjectID AND PAV.IsDeleted=0 
		 INNER JOIN MAS.PPAttributeValues PPAV (NOLOCK) ON PPAV.AttributeValueID=PAV.AttributeValueID AND PPAV.AttributeID=1 AND PPAV.IsDeleted=0
		 INNER JOIN PP.ScopeOfWork SW (NOLOCK) ON SW.ProjectID = PM.ProjectID AND SW.IsDeleted = 0
		 WHERE LM.EmployeeID=@UserId AND LM.isdeleted=0 AND PPAV.AttributeValueID IN (1,4)--OPL.Projectowningunit='ADM' AND PPAV.AttributeValueID IN (1,4)
		 AND ( TSApproverID !=@UserId OR TSApproverID IS NULL)
   UNION
		SELECT DISTINCT UserId,LM.EmployeeID,PM.ProjectId,PM.ProjectName,C.CustomerID,
		 CustomerName,PM.EsaProjectID,C.BusinessUnitID,b.BusinessUnitName,isnull(ESA_AccountID,0)ESA_AccountID,
		 'Lead' as Role, SW.IsApplensAsALM,C.IsCognizant
		 FROM  AVL.MAS_LoginMaster LM (nolock)
		 INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON LM.ProjectID = PM.ProjectID AND LM.IsDeleted=0 AND PM.IsDeleted=0
		 INNER JOIN [AVL].[Customer] C (nolock) ON C.CustomerID = LM.CustomerID AND C.IsDeleted=0
		 INNER JOIN ESA.ESABusinessUnit  B (nolock) on B.BusinessUnitID = C.BusinessUnitID
		 --INNER JOIN pp.OplEsaData OPL (NOLOCK) ON OPL.ProjectID=PM.ProjectID AND OPL.IsDeleted=0 
		 INNER JOIN pp.ProjectAttributeValues PAV (NOLOCK) ON PM.ProjectID =PAV.ProjectID AND PAV.IsDeleted=0 
		 INNER JOIN MAS.PPAttributeValues PPAV (NOLOCK) ON PPAV.AttributeValueID=PAV.AttributeValueID AND PPAV.AttributeID=1 AND PPAV.IsDeleted=0
		 INNER JOIN PP.ScopeOfWork SW (NOLOCK) ON SW.ProjectID = PM.ProjectID AND SW.IsDeleted = 0
		 WHERE  LM.isdeleted=0 AND PPAV.AttributeValueID IN (1,4)--OPL.Projectowningunit='ADM' AND PPAV.AttributeValueID IN (1,4) 		
		 AND (TSApproverID =@UserId OR (TSApproverID is null AND HcmSupervisorID=@UserId)) 
	UNION		
		SELECT DISTINCT 0 AS UserId, EmployeeID,PM.ProjectID,PM.ProjectName,C.CustomerID,
		CustomerName,PM.EsaProjectID,C.BusinessUnitID, b.BusinessUnitName,isnull(ESA_AccountID,0)ESA_AccountID,
		RM.RoleName  as Role, SW.IsApplensAsALM,C.IsCognizant
		FROM  AVL.UserRoleMapping URM (NOLOCK)
		INNER JOIN AVL.RoleMaster RM (NOLOCK) ON  RM.RoleID = URM.RoleID
		INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON URM.AccessLevelID = PM.ProjectID
		AND URM.IsActive=1 AND PM.IsDeleted=0
		INNER JOIN [AVL].[Customer] C (NOLOCK) ON C.CustomerID = PM.CustomerID AND C.IsDeleted=0
		INNER JOIN ESA.ESABusinessUnit  B (nolock) on B.BusinessUnitID = C.BusinessUnitID
		--INNER JOIN pp.OplEsaData OPL (NOLOCK) ON OPL.ProjectID=PM.ProjectID AND OPL.IsDeleted=0
		INNER JOIN pp.ProjectAttributeValues PAV (NOLOCK) ON PM.ProjectID =PAV.ProjectID AND PAV.IsDeleted=0
		INNER JOIN MAS.PPAttributeValues PPAV (NOLOCK) ON PPAV.AttributeValueID=PAV.AttributeValueID
		AND PPAV.AttributeID=1 AND PPAV.IsDeleted=0
		INNER JOIN PP.ScopeOfWork SW (NOLOCK) ON SW.ProjectID = PM.ProjectID AND SW.IsDeleted = 0
		WHERE URM.EmployeeID= @UserId AND URM.IsActive=1 --AND OPL.Projectowningunit='ADM'
		AND PPAV.AttributeValueID IN (1,4) and RM.RoleId IN ( 6,7)		
 END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()	
		EXEC AVL_InsertError '[AVL].[GetADMWAYRoleDetails]', @ErrorMessage, @UserId,''
		RETURN @ErrorMessage
  END CATCH   
END
