/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[AVL].[KEDB_GetAccountProjectDetails] '11558,7097,8774,8804,8834,9026,9503,9540,9569,9563,8960',625986

CREATE PROCEDURE [AVL].[KEDB_GetAccountProjectDetails]
  (                
    @CustomerId NVARCHAR(200),
	@UserId NVARCHAR(50) = ''
  )
AS
BEGIN  
 
BEGIN TRY 
  SET NOCOUNT ON;

   DECLARE @Customer TABLE (CustomerId BIGINT);
   INSERT INTO @Customer
	  SELECT item  FROM   Split (@CustomerId, ',')

   SELECT 	DISTINCT
	C.CustomerID,C.CustomerName,PM.ProjectID, PM.ProjectName,PM.EsaProjectID,
	C.BusinessUnitID,BusinessUnitName,isnull(ESA_AccountID,0)ESA_AccountID,RoleName AS Role	
	FROM [AVL].[Customer] C	(nolock)
	INNER JOIN @Customer t ON C.CustomerID = t.CustomerId
	INNER JOIN AVL.MAS_ProjectMaster PM (nolock) ON C.CustomerID=PM.CustomerID
	INNER JOIN [MAS].[BusinessUnits]  B (nolock) on B.BusinessUnitID = C.BusinessUnitID
	INNER JOIN AVL.APP_MAP_ApplicationProjectMapping APM (nolock) ON APM.ProjectID = PM.ProjectID and APM.IsDeleted=0
	INNER JOIN AVL.MAS_LoginMaster lm (nolock) on c.CustomerID = lm.CustomerID
    AND lm.ProjectID=PM.ProjectID and EmployeeID = @UserId  AND LM.IsDeleted=0
	INNER JOIN [AVL].[UserRoleMapping] URM (NOLOCK) on URM.EmployeeID = LM.EmployeeID 
	AND URM.AccessLevelID = LM.ProjectID  AND URM.IsActive=1
	INNER JOIN [AVL].[RoleMaster] RM (NOLOCK) ON RM.RoleId  = URM.RoleID  AND RM.IsActive=1
	WHERE   C.IsDeleted=0 AND PM.IsDeleted=0  AND B.IsDeleted =0
	 ORDER BY C.CustomerID
   END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[KEDB_GetAccountProjectDetails] ', @ErrorMessage, @UserId,''
		RETURN @ErrorMessage
  END CATCH   
END
