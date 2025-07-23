/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		Team SunRays
-- Create date: 10-19-2020
-- Description:	[RLE].[SyncESARoleDetails] - ESA Role details sync job SP
-- =============================================

CREATE PROCEDURE [RLE].[SyncESARoleDetails]
AS

BEGIN
	SET XACT_ABORT ON; 
	SET NOCOUNT ON;

	BEGIN --DECLARATION

			DECLARE @ProjManager NVARCHAR(50) = 'Project Manager' ,
			@AccManager NVARCHAR(50) = 'Account Manager',
			@AllESAAssociates NVARCHAR(50) = 'All ESA Allocated Associates',
			@TSApprover NVARCHAR(50) = 'TimeSheet Approvers',
			@ProjectOwner NVARCHAR(50) = 'Project Owner';

			DECLARE @JobName NVARCHAR(100)= 'ESA Role Details Sync';
			DECLARE @JobStatusSuccess NVARCHAR(100)='Success';
			DECLARE @JobStatusFail NVARCHAR(100)='Failed';
			DECLARE @JobStatusInProgress NVARCHAR(100)='InProgress';
			DECLARE @JobId INT,@JobStatusId INT;
			DECLARE	@DataSource NVARCHAR(50) = 'ESA'; 
			DECLARE @User NVARCHAR(50) = 'System';
			DECLARE @Date DateTime = GetDate();
		
    END	
	
		BEGIN --GENERAL SELECTION CASE

			SELECT @JobId = JobID FROM MAS.JobMaster WHERE JobName = @JobName;

		END

	BEGIN --JOB INSERTION 

			INSERT INTO MAS.JobStatus (JobId, StartDateTime, EndDateTime, JobStatus, JobRunDate, IsDeleted, CreatedBy, CreatedDate) 
			   VALUES(@JobId, @Date, @Date, @JobStatusInProgress, @Date, 0, @User, @Date);

			SET @JobStatusId= SCOPE_IDENTITY();

    END
	BEGIN TRY
	BEGIN TRANSACTION
		
		--IF ANY NEW ESAROLENAME ADDED IN RLE.ESARoleMapping TABLE NEED TO ADDED INTO THIS #TEMP TABLE SELECTION CASE
		BEGIN --#TEMPSOURCE TABLE DATA POPULATING
		
			SELECT DISTINCT pm.AssociateId, erm.ApplensRoleID, erm.GroupID, pm.ProjectID,pm.ESARole

			INTO #TempSource

			FROM RLE.ESARoleMapping erm
				JOIN (	SELECT	DISTINCT ProjectID, ProjectManagerID AssociateId, @ProjManager ESARole
						FROM	AVL.MAS_projectMaster
						WHERE	IsDeleted = 0 AND ISNULL(ProjectManagerID,'') <> ''

						UNION

						SELECT	DISTINCT ProjectID, AccountManagerID AssociateId, @AccManager ESARole 
						FROM	AVL.MAS_projectMaster
						WHERE	IsDeleted = 0 AND ISNULL(AccountManagerID,'') <> '' 

						UNION

						SELECT	DISTINCT ProjectID, ProjectOwner AssociateId, @ProjectOwner ESARole 
						FROM	AVL.MAS_projectMaster
						WHERE	IsDeleted = 0 AND ISNULL(ProjectOwner,'') <> ''
					
						UNION

						SELECT	DISTINCT npm.ProjectID, AssociateID, @AllESAAssociates ESARole
						FROM	ESA.ProjectAssociates pa
								JOIN AVL.MAS_projectMaster npm on npm.ESAProjectID = pa.ProjectID 
														AND npm.IsDeleted = 0

						UNION

						SELECT	DISTINCT pm.ProjectID, lm.TSApproverID AssociateID, @TSApprover ESARole 
						FROM	AVL.MAS_LoginMaster lm
								JOIN AVL.MAS_ProjectMaster pm on pm.ProjectID = lm.ProjectID AND pm.IsDeleted = 0
						WHERE	lm.IsDeleted = 0 AND ISNULL(lm.TSApproverID,'') <> ''
					
													) pm ON erm.ESARoleName = pm.ESARole 
						WHERE	erm.IsDeleted = 0
		END
		
		/* User role mapping sync for ESA User roles*/
		BEGIN --MERGE QUERY FOR RLE.UserRoleMapping
			MERGE RLE.UserRoleMapping As T
			USING (	SELECT DISTINCT AssociateID,ApplensRoleID,GroupID FROM	#TempSource) AS S
						ON T.AssociateID = S.AssociateID 
							AND T.ApplensRoleID = S.ApplensRoleID
							AND T.GroupID = S.GroupID
							AND T.DataSource = @DataSource

			WHEN NOT MATCHED BY TARGET
				THEN	INSERT (AssociateID, ApplensRoleID, GroupID, Createdby, CreatedDate, DataSource)
						VALUES (S.AssociateID, S.ApplensRoleID, S.GroupID, @User, @Date, @DataSource)

			WHEN NOT MATCHED BY SOURCE
							AND T.DataSource = @DataSource 
							AND T.IsDeleted = 0 

				THEN	UPDATE 
						SET T.IsDeleted = 1,
							T.ModifiedBy = @User,
							T.ModifiedDate = @Date

			WHEN MATCHED 
					AND T.DataSource = @DataSource 
					AND T.IsDeleted = 1
				THEN	UPDATE
						SET T.IsDeleted = 0,
							T.ModifiedBy = @User,
							T.ModifiedDate = @Date;
		END

		/*User Role ESA Qualifier's sync*/
		BEGIN --MERGE QUERY FOR RLE.UserRoleDataAccess FROM RLE.UserRoleMapping
			MERGE RLE.UserRoleDataAccess AS T
			USING(SELECT DISTINCT urm.RoleMappingID, urm.AssociateID, src.ProjectID FROM RLE.UserRoleMapping urm
							JOIN #TempSource src ON src.AssociateID = urm.AssociateID
													AND urm.ApplensRoleID = src.ApplensRoleID 
													AND urm.GroupID = src.GroupID
				 WHERE urm.IsDeleted = 0 AND urm.DataSource = @DataSource) AS S
					ON T.ProjectID = S.ProjectID AND T.RoleMappingID = S.RoleMappingID AND T.AssociateID = S.AssociateID AND T.DataSource = @DataSource

			WHEN NOT MATCHED BY TARGET
				THEN	INSERT (RoleMappingID, AssociateID, ProjectID, CreatedBy, CreatedDate, DataSource)
						VALUES (S.RoleMappingID, S.AssociateID, S.ProjectID, @User, @Date, @DataSource)

			WHEN NOT MATCHED BY SOURCE			
			                AND T.DataSource = @DataSource 
							AND T.IsDeleted = 0 
				THEN	UPDATE 
						SET T.IsDeleted = 1,
							T.ModifiedBy = @User,
							T.ModifiedDate = @Date

			WHEN MATCHED
					AND T.DataSource = @DataSource 
					AND T.IsDeleted = 1
				THEN	UPDATE
						SET T.IsDeleted = 0,
							T.ModifiedBy = @User,
							T.ModifiedDate = @Date; 
		END

		BEGIN --DROP TABLE
			DROP TABLE IF EXISTS #TempSource
		END
	COMMIT TRANSACTION
		BEGIN --JOB UPDATION 
			UPDATE	MAS.JobStatus 
			SET		JobStatus = @JobStatusSuccess, EndDateTime = GETDATE() 
			WHERE	ID = @JobStatusId
		END
	END TRY
	BEGIN CATCH

		BEGIN -- COMMIT OR ROLLBACK TRANSACTION
			IF (XACT_STATE()) = -1  
			BEGIN  
				ROLLBACK TRANSACTION;  
			END;  
			IF (XACT_STATE()) = 1  
			BEGIN  
				COMMIT TRANSACTION;     
			END;
		END
		
		BEGIN --JOB Failure UPDATION 
			UPDATE	MAS.JobStatus 
			SET		JobStatus = @JobStatusFail, EndDateTime = GETDATE() 
			WHERE	ID = @JobStatusId
		END

		BEGIN --ERROR VARIABLES DECLARATION
			DECLARE @HostName NVARCHAR(50) = (SELECT HOST_NAME());
			DECLARE @Associate NVARCHAR(50) = (SELECT SUSER_NAME());
			DECLARE @ErrorCode	NVARCHAR(50) = (SELECT ERROR_NUMBER());
			DECLARE @ErrorMessage NVARCHAR(MAX) = (SELECT ERROR_MESSAGE());
			DECLARE @ModuleName NVARCHAR(30) = 'RoleAPI';
			DECLARE @DbName NVARCHAR(30) = 'AppVisionLens';
			DECLARE @getdate  DATETIME = GETDATE();
			DECLARE @DbObjName NVARCHAR(50) = (OBJECT_NAME(@@PROCID));
		END	

		BEGIN -- LOGGING FRAMEWORK LOGGING
			EXEC AppVisionLensLogging.[dbo].[InsertLog] 'Critical','ERROR',@HostName,@Associate,@getdate,NULL,'SQL',
														@ModuleName,@JobName,@DbName,@DbObjName,@@SPID,@ErrorCode,@ErrorMessage,
														@JobStatusFail,NULL,NULL;
		END
	
	END CATCH
END
