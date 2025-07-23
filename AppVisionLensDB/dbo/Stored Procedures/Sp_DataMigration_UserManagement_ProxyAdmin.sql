/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ==============================================================================
-- Author:Anitha
-- Create date: 19/7/2018
-- Description: Migration of Roles for User Management
--Test :Exec [dbo].[Sp_DataMigration_UserManagement_ProxyAdmin] '1000083654,1000171606,1000192711'
-- ==============================================================================
CREATE PROCEDURE [dbo].[Sp_DataMigration_UserManagement_ProxyAdmin]
(
	@ESAProjectIDs NVARCHAR(MAX)
)
AS	
BEGIN
	
	SET NOCOUNT ON;


	DECLARE @ProjectList TABLE
	(
		ProjectId BIGINT
	)

	INSERT INTO @ProjectList
		SELECT ProjectID FROM AVL.MAS_ProjectMaster 
		WHERE EsaProjectID IN (SELECT Item FROM dbo.Split(@ESAProjectIDs, ','))

	SELECT ECM.EmployeeId, EPM.ProjectId, ERM.RoleId, RM.RoleName 
	INTO #ProjectsMapped
	FROM AVL.EmployeeProjectMapping (NOLOCK) EPM
	LEFT JOIN AVL.EmployeeCustomerMapping (NOLOCK) ECM 
		ON EPM.EmployeeCustomerMappingId = ECM.Id
	LEFT JOIN AVL.EmployeeRoleMapping (NOLOCK) ERM 
		ON EPM.EmployeeCustomerMappingId = ERM.EmployeeCustomerMappingId
	LEFT JOIN AVL.RoleMaster (NOLOCK) RM 
		ON ERM.RoleId = RM.RoleId 
	WHERE EPM.ProjectId IN (SELECT ProjectId From @ProjectList)

	SELECT ProjectID INTO #All_MappedPrj FROM #ProjectsMapped ORDER BY ProjectId ASC 
	SELECT ProjectID INTO #SA_MappedPrj FROM #ProjectsMapped WHERE RoleId = 1 
	--Omitting Applens team ID's
	AND EmployeeId NOT IN (132399,132568,215573,371789,383323,519410,575633,587567,627384,659977,683989) 
	 ORDER BY ProjectId ASC 
	SELECT ProjectID INTO #A_MappedPrj FROM #ProjectsMapped WHERE RoleId = 6
	AND EmployeeId NOT IN (132399,132568,215573,371789,383323,519410,575633,587567,627384,659977,683989)
	 ORDER BY ProjectId ASC 
	SELECT ProjectID INTO #PA_MappedPrj FROM #ProjectsMapped WHERE RoleId = 7
	AND EmployeeId NOT IN (132399,132568,215573,371789,383323,519410,575633,587567,627384,659977,683989)
	 ORDER BY ProjectId ASC

	DECLARE @AVL_ExcludingProject TABLE
	(
		ProjectID BIGINT
	)

	INSERT INTO @AVL_ExcludingProject
		SELECT DISTINCT ProjectID FROM #SA_MappedPrj 

	INSERT INTO @AVL_ExcludingProject
		SELECT DISTINCT AM.ProjectID 
		FROM #A_MappedPrj AM 
		JOIN #SA_MappedPrj SA ON AM.ProjectID <> SA.ProjectID

	SELECT DISTINCT PA.ProjectID INTO #ExcludingProject FROM #PA_MappedPrj PA 
	WHERE ProjectID IN (SELECT ProjectID FROM @AVL_ExcludingProject)

	--- Get projects that does not have (SuperAdmin or Admin) and (Proxy Admin) role
	SELECT DISTINCT PM.EsaProjectID, P.ProjectID 
	INTO #GetLeadRoleFromDart 
	FROM #All_MappedPrj P
	JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
		ON P.ProjectID = PM.ProjectID
	WHERE P.ProjectID NOT IN (SELECT ProjectID FROM #ExcludingProject)

	SELECT * FROM #GetLeadRoleFromDart

	--- Get projects that Contains (SuperAdmin or Admin) and (Proxy Admin) role 
	--SELECT DISTINCT PM.EsaProjectID,P.ProjectID INTO #NOTNeededLeadRoleFromDart FROM #All_MappedPrj P
	--INNER JOIN AVL.MAS_ProjectMaster (NOLOCK)  PM ON P.ProjectID=PM.ProjectID
	-- WHERE P.ProjectID IN (SELECT ProjectID FROM #ExcludingProject)

	--SELECT * FROM #NOTNeededLeadRoleFromDart

	DECLARE @DartDistinctLeadsandAdminId TABLE
	(
		CognizantId NVARCHAR(50),
		EsaProjectID NVARCHAR(max),
		AVL_ProjectId BIGINT
	)

	SELECT Dart_PM.ProjectID, Dart_PM.EsaProjectID, AVL_Prj.ProjectID AS AVL_ProjectId  
	INTO #DartProjects 
	FROM [AVMDART].MAS.ProjectMaster (NOLOCK) Dart_PM 
	JOIN #GetLeadRoleFromDart AVL_Prj ON Dart_PM.EsaProjectID = AVL_Prj.EsaProjectID

	---- Getting LeadId's and Admin from Dart for AVL Active Projects 
	DECLARE @DartAdminandLeadsIds TABLE
	(
		CognizantId NVARCHAR(50),
		EsaProjectID NVARCHAR(max),
		AVL_ProjectId BIGINT
	)

	INSERT INTO @DartAdminandLeadsIds
		SELECT Dart_LM.cognizantID, DP.EsaProjectID, DP.AVL_ProjectId 
		FROM [AVMDART].PRJ.LoginMaster (NOLOCK) Dart_LM 
		JOIN #DartProjects DP ON Dart_LM.ProjectID = DP.ProjectID
		WHERE Dart_LM.GradeID = 2 
		UNION
		SELECT Dart_LM.cognizantID, DP.EsaProjectID, DP.AVL_ProjectId 
		FROM [AVMDART].PRJ.LoginMaster (NOLOCK) Dart_LM 
		JOIN #DartProjects DP ON Dart_LM.ProjectID = DP.ProjectID
		WHERE Dart_LM.GradeID = 3

	--- Getting Distinct CognizantId of Admin and Lead Id From Dart

	INSERT INTO @DartDistinctLeadsandAdminId
		SELECT DISTINCT cognizantID, EsaProjectID, AVL_ProjectId FROM @DartAdminandLeadsIds

	-- SELECT * FROM @DartDistinctLeadsandAdminId ORDER BY CognizantId ASC

	------ ChecKing wheather the Dart (CognizantId) has Account level access in AppLens
	SELECT ECM.ID, PM.ProjectID 
	INTO #AVL_CogId_Account 
	FROM AVL.EmployeeCustomerMapping (NOLOCK) ECM
	JOIN AVL.MAS_ProjectMaster (NOLOCK) PM ON ECM.CustomerID = PM.CustomerID
	WHERE PM.ProjectID IN (SELECT DISTINCT AVL_ProjectId FROM @DartDistinctLeadsandAdminId) 
		AND ECM.EmployeeId IN (SELECT DISTINCT cognizantID FROM @DartDistinctLeadsandAdminId)

	--SELECT * FROM #AVL_CogId_Account

	---- Role Access if CognizantId has access for project else Project and Role access given if cognizantId Has access for that Account 
	SELECT T.ID, T.ProjectID, CASE WHEN EPM.ProjectId IS NULL THEN 0 ELSE 1 END AS StatusForRole
	INTO #ProxyAdminAccess 
	FROM #AVL_CogId_Account T  
	LEFT JOIN AVL.EmployeeProjectMapping (NOLOCK) EPM 
		ON T.ID = EPM.EmployeeCustomerMappingId AND T.ProjectID = EPM.ProjectID

	--SELECT * FROM #ProxyAdminAccess

	INSERT INTO AVL.EmployeeRoleMapping (EmployeeCustomerMappingId, RoleId, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
		SELECT T.ID, 7, 'Migrated', GETDATE(), NULL, NULL FROM #ProxyAdminAccess T
		Left JOIN AVL.EmployeeRoleMapping ERM ON T.ID=ERM.EmployeeCustomerMappingId AND ERM.RoleId <> 7
		WHERE T.StatusForRole = 1 AND ERM.EmployeeCustomerMappingId is NULL

	INSERT INTO AVL.EmployeeProjectMapping (EmployeeCustomerMappingId, ProjectId, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
		SELECT T.ID, T.ProjectID, 'Migrated', GETDATE(), NULL, NULL FROM #ProxyAdminAccess T
		LEFT JOIN AVL.EmployeeProjectMapping EPM ON T.ID=EPM.EmployeeCustomerMappingId AND T.ProjectID=Epm.ProjectId
		WHERE T.StatusForRole = 0 AND EPM.ProjectId is NULL

	INSERT INTO AVL.EmployeeRoleMapping (EmployeeCustomerMappingId, RoleId, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
		SELECT T.ID, 7, 'Migrated', GETDATE(), NULL, NULL FROM #ProxyAdminAccess T
		Left JOIN AVL.EmployeeRoleMapping ERM ON T.ID=ERM.EmployeeCustomerMappingId AND ERM.RoleId <> 7
		WHERE T.StatusForRole = 0 AND ERM.EmployeeCustomerMappingId is NULL

	--- Droping temp tables

	Drop Table #ProjectsMapped
	Drop Table #All_MappedPrj
	Drop Table #SA_MappedPrj
	Drop Table #A_MappedPrj
	Drop Table #PA_MappedPrj
	Drop Table #ExcludingProject
	Drop Table #GetLeadRoleFromDart
	Drop Table #DartProjects
	Drop Table #AVL_CogId_Account
	Drop Table #ProxyAdminAccess
	--DROP TABLE #NOTNeededLeadRoleFromDart

END
