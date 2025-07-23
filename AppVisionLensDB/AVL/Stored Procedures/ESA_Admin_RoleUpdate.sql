/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ESA_Admin_RoleUpdate]
AS
BEGIN
		
		BEGIN TRY
		BEGIN TRAN 

		DECLARE @Associate TABLE
		(
		AssociateID nvarchar(50),
		ProjectID bigint,
		ESAProjectID nvarchar(50),
		AccountID bigint,
		RoleID int 
		)	

		/* ====== Total Employee =====*/
		INSERT INTO @Associate(AssociateID,ProjectID,AccountID,ESAProjectID)
		SELECT DISTINCT AM.AssociateID AS AssociateID,PMA.ProjectID AS ProjectID,C.CustomerID AS AccountID,PMA.EsaProjectID
		FROM ESA.Associates AM
		INNER JOIN ESA.ProjectAssociates PAM ON AM.AssociateID=PAM.AssociateID
		INNER JOIN ESA.Projects PM ON PAM.ProjectID = PM.ID
		INNER join AVL.MAS_ProjectMaster PMA on pm.ID = PMA.EsaProjectID
		INNER JOIN AVL.Customer C ON PMA.CustomerID=C.CustomerID AND C.IsDeleted = 0
		where AM.IsActive = 1  

		/* ===== NEW EMPLOYEEID List =====*/
		IF EXISTS(select * from sys.objects where type = 'U' AND name = 'NEWEMPLOYEEIDS_esajob')
		BEGIN
				PRINT 'DROP table NEWEMPLOYEEIDS_esajob'
				DROP table NEWEMPLOYEEIDS_esajob 
		END

		CREATE table NEWEMPLOYEEIDS_esajob 
		(
			EMPLOYEEID nvarchar(50) ,
			ProjectID BIGINT,
			ESAProjectID NVARCHAR(50) NULL
		)

		INSERT INTO NEWEMPLOYEEIDS_esajob(EMPLOYEEID,ProjectID)
		SELECT  distinct A.AssociateID,A.ProjectID from @Associate A 
		--EXCEPT
		--SELECT EmployeeId as AssociateID,AccessLevelID as ProjectID from AVL.UserRoleMapping WHERE AccessLevelSourceID=4 AND RoleID=6 AND IsActive=1

		
		DECLARE @Temp_Associate TABLE
		(
			AssociateID nvarchar(50),
			ProjectID BIGINT,
			AccountID BIGINT,
			EsaProjectID VARCHAR(50) NULL
		)
		
		if EXISTS(select EMPLOYEEID from NEWEMPLOYEEIDS_esajob)
		BEGIN
			/* ===== Update ESA ProjectID === */
			UPDATE ne SET ne.ESAProjectID=pm.EsaProjectID from NEWEMPLOYEEIDS_esajob ne join Avl.MAS_ProjectMaster pm on ne.ProjectID=pm.ProjectID
		END
		SELECT '#New Employees'
		--SELECT * from NEWEMPLOYEEIDS_esajob
				
				SELECT ProjectManagerID,ID as ESAProjectID into #ProjectManagers FROM esa.Projects where ProjectManagerID is not null and ProjectManagerID !='' AND ProjectManagerID !='0'
				SELECT AccountManagerID,ID as ESAProjectID INTO #AccountManagers FROM esa.Projects where AccountManagerID IS NOT NULL AND AccountManagerID !='' AND AccountManagerID !='0'

			--SELECT AM.EMPLOYEEID AS AssociateID,AM.ProjectID AS ProjectID into #ProjectManager  
			--					FROM ESA.Projects p
			--					INNER JOIN NEWEMPLOYEEIDS_esajob AM	on am.EMPLOYEEID=p.ProjectManagerID --and am.ESAProjectID	=p.ID ORDER BY AM.EMPLOYEEID

			SELECT '#ProjectManager'
			SELECT * from #ProjectManagers --where ProjectManagerID='383323'

			--SELECT AM.EMPLOYEEID AS AssociateID,p. AS ProjectID into #AccountManager 
			--					FROM ESA.Projects p
			--					INNER JOIN NEWEMPLOYEEIDS_esajob AM on am.EMPLOYEEID=p.AccountManagerID and am.ESAProjectID=p.ID	

			SELECT '#AccountManager'
			SELECT * from #AccountManagers
			
			CREATE TABLE #ManagerLists
			(
				AssociateID nvarchar(50),
				ProjectID BIGINT
			) 		
				INSERT INTO #ManagerLists(AssociateID,ProjectID)
				SELECT DISTINCT pmm.ProjectManagerID as AssociateID,pm.ProjectID from #ProjectManagers pmm join avl.MAS_ProjectMaster pm on pmm.ESAProjectID=pm.EsaProjectID

				DROP TABLE #ProjectManagers

				INSERT INTO #ManagerLists(AssociateID,ProjectID)
				SELECT DISTINCT pmm.AccountManagerID as AssociateID,pm.ProjectID from #AccountManagers pmm join avl.MAS_ProjectMaster pm on pmm.ESAProjectID=pm.EsaProjectID

				DROP TABLE #AccountManagers

		SELECT DISTINCT pma.* into #ProjectManagersList from #ManagerLists pma 
		where NOT EXISTS (select * from avl.UserRoleMapping urm 
							where urm.RoleID=6 and urm.AccessLevelSourceID=4 AND pma.AssociateID=urm.EmployeeID and pma.ProjectID=urm.AccessLevelID)--and urm.IsActive=1 
		
					
		SELECT DISTINCT urm.* into #PMListDeleted from  avl.UserRoleMapping urm 
								where urm.RoleID=6 and urm.AccessLevelSourceID=4 and urm.IsActive=1 AND urm.DataSource='ESA' AND
								NOT EXISTS (select * from #ManagerLists pma where pma.AssociateID=urm.EmployeeID and pma.ProjectID=urm.AccessLevelID)
			

		SELECT '#ProjectManagersList'
		SELECT * from #ProjectManagersList

		SELECT DISTINCT pma.* into #ProjectManagersListNotActive 
		from #ManagerLists pma where EXISTS 
		(select * from avl.UserRoleMapping urm 
		where urm.RoleID=6 and urm.AccessLevelSourceID=4 and urm.IsActive=0 AND pma.AssociateID=urm.EmployeeID and pma.ProjectID=urm.AccessLevelID)
		
		SELECT '#ProjectManagersList Not Active'
		SELECT * from #ProjectManagersListNotActive

		IF EXISTS(SELECT AssociateID from #ProjectManagersListNotActive)
		BEGIN

				UPDATE urm  SET urm.IsActive=1,urm.ModifiedBy='ESA',urm.ModifiedDate=GETDATE() 
										from AVL.UserRoleMapping urm 
										join #ProjectManagersListNotActive pma
										on urm.EmployeeID=pma.AssociateID and urm.AccessLevelID=pma.ProjectID 
										WHERE urm.RoleID=6 and urm.AccessLevelSourceID=4 and urm.IsActive=0 AND urm.DataSource='ESA'

		END

		DROP TABLE #ProjectManagersListNotActive
		
		SELECT '#PMListDeleted'
		SELECT * FROM #PMListDeleted
		
		/* ==== DeActivate PM & AM Access ====*/
		IF EXISTS(SELECT EmployeeID FROM #PMListDeleted)
		BEGIN 

				UPDATE urm  SET IsActive=0 from AVL.UserRoleMapping urm join #PMListDeleted pma
										on urm.EmployeeID=pma.EmployeeID and urm.AccessLevelID=pma.AccessLevelID 
										WHERE urm.RoleID=6 and urm.AccessLevelSourceID=4 AND urm.DataSource='ESA'

		END
		
		DROP TABLE #PMListDeleted
		--SELECT '#AccountManagersList'
		--SELECT * from #AccountManagersList

		--SELECT AssociateID,ProjectID into #ProjectManagers from #ProjectManagersList
		--UNION 
		--SELECT AssociateID,ProjectID from #AccountManagersList

		--SELECT '#ProjectManagers'
		--SELECT * from #ProjectManagers

		
		--DROP TABLE #AccountManagersList

		--- GETDATE() AS SMALLDATETIME
	
		--	--INSERT into AVL.EmployeeRoleMapping
		If EXISTS (SELECT AssociateID from #ProjectManagersList)
		BEGIN
			INSERT INTO AVL.UserRoleMapping(EmployeeId,RoleID,AccessLevelSourceID,AccessLevelID,IsActive,CreatedBy,CreatedDate,DataSource,ModifiedDate,ModifiedBy)
			SELECT distinct ta.AssociateID,6,4,ta.ProjectID,1,'ESA',GETDATE(),'ESA' ,GETDATE(),'' 
									FROM #ProjectManagersList ta 
		END
        /* ====== EMPLOYEE SCREEN MAPPING =====*/
		
		DECLARE @NewAssociates TABLE
		(
			AssociateID nvarchar(50),
			AccountID BIGINT
		)		
		
		If EXISTS (SELECT AssociateID from #ProjectManagersList)
		BEGIN
				INSERT into @Temp_Associate(AssociateID,ProjectID,AccountID,EsaProjectID)
					SELECT DISTINCT AM.AssociateID AS AssociateID,AM.ProjectID AS ProjectID,C.CustomerID AS AccountID,PMA.EsaProjectID
						FROM #ProjectManagersList AM
						INNER JOIN AVL.MAS_ProjectMaster PMA on PMA.ProjectID = AM.ProjectID
						INNER JOIN AVL.Customer C ON C.CustomerID = PMA.CustomerID AND C.IsDeleted = 0
		

		 DROP TABLE #ProjectManagersList

		INSERT INTO @NewAssociates
		SELECT DISTINCT ta.AssociateID,ta.AccountID 
						FROM @Temp_Associate ta 

		DECLARE @ScreenRole  TABLE
		(
			ID INT IDENTITY(1,1),
			ScreenID int
		) 

		INSERT INTO @screenRole
		SELECT ScreenID FROM AVL.ScreenMaster where IsActive =1
		
		DECLARE @PROCESSCOUNT INT 
		DECLARE @COUNT INT
		DECLARE @SCREENID INT

		SET @COUNT = (SELECT count(ScreenID) FROM AVL.ScreenMaster where IsActive =1 )
		
		SET @PROCESSCOUNT = 1

		WHILE @PROCESSCOUNT <= @COUNT
		BEGIN	

			SET @SCREENID = (SELECT ScreenID FROM @ScreenRole WHERE ID = @PROCESSCOUNT)			
			
			INSERT INTO AVL.EmployeeScreenMapping(EmployeeID,CustomerID,ScreenId,RoleId,AccessRead,AccessWrite)
											SELECT ta.AssociateID,ta.AccountID,@SCREENID,6,0,1 FROM @NewAssociates ta 
												WHERE NOT EXISTS (SELECT * from AVL.EmployeeScreenMapping esm 
																	WHERE esm.EmployeeID=ta.AssociateID and esm.CustomerID=ta.AccountID and esm.ScreenId=@SCREENID and esm.RoleId=6)
	
			SET @PROCESSCOUNT = @PROCESSCOUNT+1

			END
		END
	COMMIT TRAN
	END TRY
	BEGIN CATCH    
		ROLLBACK TRAN

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage as ErrorMessage
		SELECT ERROR_LINE() as ErrorLine
		
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[ESA_Admin_RoleUpdate]', @ErrorMessage, 0,0
		
	END CATCH  
END
