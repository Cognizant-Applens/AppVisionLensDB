/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetAnalystLeadRoleDetails]
  (                
   	@UserId NVARCHAR(50) = ''
  )
AS
BEGIN  
 
BEGIN TRY 
  SET NOCOUNT ON;

IF Not EXISTS(select TOP 1 HcmSupervisorID from AVL.MAS_LoginMaster (NOLOCK) WHERE  
 ( IsDeleted=0  AND (TSApproverID=@UserId or HcmSupervisorID=@UserId)))  
	 BEGIN	 
		 SELECT DISTINCT UserId,PM.ProjectID,PM.ProjectName,C.CustomerID,
		 CustomerName,PM.EsaProjectID,C.BusinessUnitID,BusinessUnitName,isnull(ESA_AccountID,0)ESA_AccountID,
		  'Analyst' as Role
		 FROM  AVL.MAS_LoginMaster LM (nolock)
		 INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON LM.ProjectID = PM.ProjectID AND LM.IsDeleted=0 AND PM.IsDeleted=0
		 --INNER JOIN ESA.ProjectAssociates PA ON LM.EmployeeID = PA.AssociateID 
		 --AND PM.EsaProjectID= PA.ProjectID
		 INNER JOIN [AVL].[Customer] C (NOLOCK) ON C.CustomerID = LM.CustomerID AND C.IsDeleted=0
		 INNER JOIN [MAS].[BusinessUnits]  B (nolock) on B.BusinessUnitID = C.BusinessUnitID
		 WHERE LM.EmployeeID=@UserId AND LM.isdeleted=0
	 END 
ELSE
    BEGIN	
	  SELECT DISTINCT UserId,PM.ProjectId,PM.ProjectName,C.CustomerID,
		 CustomerName,PM.EsaProjectID,C.BusinessUnitID,BusinessUnitName,isnull(ESA_AccountID,0)ESA_AccountID,
		 'Analyst' as Role
		 FROM  AVL.MAS_LoginMaster LM (nolock)
		 INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON LM.ProjectID = PM.ProjectID AND LM.IsDeleted=0 AND PM.IsDeleted=0
		 INNER JOIN [AVL].[Customer] C (nolock) ON C.CustomerID = LM.CustomerID AND C.IsDeleted=0
		 INNER JOIN [MAS].[BusinessUnits]  B (nolock) on B.BusinessUnitID = C.BusinessUnitID
		 WHERE LM.EmployeeID=@UserId AND LM.isdeleted=0 AND ( TSApproverID !=@UserId OR TSApproverID IS NULL)
   UNION
    SELECT DISTINCT UserId,PM.ProjectId,PM.ProjectName,C.CustomerID,
		 CustomerName,PM.EsaProjectID,C.BusinessUnitID,BusinessUnitName,isnull(ESA_AccountID,0)ESA_AccountID,
		 'Lead' as Role
		 FROM  AVL.MAS_LoginMaster LM (nolock)
		 INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON LM.ProjectID = PM.ProjectID AND LM.IsDeleted=0 AND PM.IsDeleted=0
		 INNER JOIN [AVL].[Customer] C (nolock) ON C.CustomerID = LM.CustomerID AND C.IsDeleted=0
		 INNER JOIN [MAS].[BusinessUnits]  B (nolock) on B.BusinessUnitID = C.BusinessUnitID
		 WHERE  LM.isdeleted=0 AND (TSApproverID =@UserId OR (TSApproverID is null AND HcmSupervisorID=@UserId)) 
	END
 END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()	
		EXEC AVL_InsertError '[AVL].[KEDB_GetAnalystLeadRoleDetails] ', @ErrorMessage, @UserId,''
		RETURN @ErrorMessage
  END CATCH   
END
