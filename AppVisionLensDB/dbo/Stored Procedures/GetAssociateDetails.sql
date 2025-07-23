/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ================================================
-- Common Stored Procure to get the User's base information
-- User's Project Details
-- User's Customer Details
-- 25th November 2019		201422 - Sivakumar		Added Emploee ID & Employee Name
--													Added Project ID & Project Name
--													Added Customer ID & Customer Name
-- ================================================
CREATE PROCEDURE [dbo].[GetAssociateDetails] 
	@AssociateID NVARCHAR(50)
AS
BEGIN
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
		PM.ProjectID AS ID,
		PM.ProjectName AS Name,
		PM.EsaProjectID as esaProjectID
		FROM AVL.UserRoleMapping  URM (NOLOCK)
		INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK)
		ON URM.AccessLevelID=PM.ProjectID
		AND URM.EmployeeID=@AssociateID
		AND URM.AccessLevelSourceID=4
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
		C.CustomerID AS ID,
		C.CustomerName AS Name
		FROM AVL.UserRoleMapping  URM (NOLOCK)
		INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK)
		ON URM.AccessLevelID=PM.ProjectID
		AND URM.EmployeeID=@AssociateID
		AND URM.AccessLevelSourceID=4
		INNER JOIN AVL.Customer C ON C.CustomerID=PM.CustomerID
		AND C.IsDeleted=0  AND PM.IsDeleted=0
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
		DISTINCT R.RoleId AS ID,
		R.RoleName AS Name
		FROM AVL.UserRoleMapping URM 
		INNER JOIN AVL.RoleMaster R 
		ON URM.RoleID=R.RoleId
		AND R.IsActive=1
		AND URM.IsActive=1
		AND URM.EmployeeID = @AssociateID
		AND ((URM.RoleID = 3 and AccessLevelSourceID = 4) OR
			(URM.RoleID = 3 and AccessLevelSourceID = 3))
		UNION
		SELECT DISTINCT 9 AS ID,
		'Lead' AS Name FROM avl.MAS_LoginMaster L 
		INNER JOIN AVL.MAS_ProjectMaster PM ON PM.ProjectID=L.ProjectID 
		WHERE  (L.HcmSupervisorID = @AssociateID or  L.TSApproverID =  @AssociateID) 
		AND l.IsDeleted = 0 and ISNULL(PM.IsDeleted,0)=0 
		UNION
		SELECT 
		DISTINCT R.RoleId AS ID,
		R.RoleName AS Name
		FROM AVL.UserRoleMapping URM 
		INNER JOIN AVL.RoleMaster R 
		ON URM.RoleID=R.RoleId
		AND R.IsActive=1
		AND URM.IsActive=1
		AND URM.EmployeeID = @AssociateID
		AND URM.RoleID = 19 

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
