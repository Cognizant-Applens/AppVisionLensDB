/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =================================================================================  
-- Author:  Annadurai.S  
-- Create date: 5 June 2018
-- Description: Migration of Ticketing Module Configuration
-- AppVisionLens_Migration - App Lens DB, [AVMDART] - AVM DART DB
-- Test: EXEC SP_DataMigration_TickingModuleConfiguration 1228467 ,'1000173504'
-- ================================================================================= 

CREATE PROCEDURE [dbo].[SP_DataMigration_TickingModuleConfiguration]
(
	@AccountID BIGINT, -- DART ESA ACCOUNT ID
	@ESAProjectIDs NVARCHAR(MAX) -- ESA Project IDs
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN

			DECLARE @ProjectDetails TABLE 
			( 
				AccountID INT,
				AccountName NVARCHAR(MAX),
				ProjectID INT,
				EsaProjectID NVARCHAR(MAX),
				ProjectName NVARCHAR(MAX),
				AVLProjectID BIGINT
			)
	
			---------- Get all projects or specific project(s) for the Accounts ----------
			
			SELECT Item AS ESAProjectID INTO #ESAProjectIds FROM dbo.Split(@ESAProjectIDs, ',')

			INSERT INTO @ProjectDetails
				SELECT DA.AccountID AS AccountID,
					AccountName,
					PM.ProjectID,
					PM.EsaProjectID,
					PM.ProjectName,
					APLPM.ProjectID
				FROM AVMDART.MAS.ProjectMaster (NOLOCK) PM
				JOIN AVMDART.[MAP].[DeptAcctMapping] (NOLOCK) DA 
					ON DA.AccountID = @AccountID AND DA.DeptAccountID = PM.DeptAccountID
						AND DA.IsDeleted = 'N' AND PM.IsDeleted = 'N'
				JOIN AVL.Customer (NOLOCK) cust
					ON cust.ESA_AccountID = DA.AccountID AND cust.IsDeleted = 0 
				JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APLPM
					ON APLPM.EsaProjectID = PM.EsaProjectID AND APLPM.IsDeleted = 0
				WHERE @ESAProjectIDs IS NULL OR PM.EsaProjectID IN (SELECT ESAProjectID FROM #ESAProjectIds)
				
select * from @ProjectDetails
			------------------------------------------------ EFFORT TRACKING -------------------------------------------------------------

		    ---------- Push the data for Project Configuration Table ----------

			PRINT 'Project Config'

			INSERT INTO AVL.MAP_ProjectConfig 
			(	
				ProjectID,
				Uploadinactiveuser,
				Ticketsource,
				Defaultermail,
				CreatedBY,
				CreatedDateTime,
				ModifiedBy,
				ModifiedDateTime,
				IsC20DownloadEnabled,
				Severity,
				ApprovalMail,
				ApprovalMailStartDay,
				ApprovalMailEndDay,
				ApprovalMailFrequency,
				ApproveMailNextDate,
				AutoUploadCount,
				TimeZoneId,
				TSSubmitRules,
				IsAutoAssigneeForDART,
				AutoUploadForDARTCount,
				TicketSharePathUsers,
				TktDfltrMail,
				TktDfltrMailStartDay,
				TktDfltrMailEndDay,
				TktDfltrMailFrequency,
				IsEffortFlag,
				IsMandatoryFlag,
				TicketdefaulterMailNextDate,
				IsTicketTypeMappedForService,
				Workinghours,
				ReportForAssociates,
				ReportForSupervisor
			)
			SELECT 			
				PM.ProjectID,
				DARTPC.Uploadinactiveuser,
				DARTPC.Ticketsource,
				CASE WHEN (ISNULL(DARTPC.Defaultermail, '') = '') OR DARTPC.Defaultermail = 'N' THEN '0' ELSE '1' END, -- Default value should be 'N'
				'Migrated', -- Created By
				GETDATE(),  -- Created DateTime
				NULL, -- Modified By
				NULL, -- Modified DateTime,
				DARTPC.IsC20DownloadEnabled,
				DARTPC.Severity,
				CASE WHEN (ISNULL(DARTPC.ApprovalMail, '') = '') OR DARTPC.ApprovalMail = 'N' THEN '0' ELSE '1' END,
				DARTPC.ApprovalMailStartDay,
				DARTPC.ApprovalMailEndDay,
				DARTPC.ApprovalMailFrequency,
				DARTPC.ApproveMailNextDate,
				DARTPC.AutoUploadCount,
				TM.TimeZoneId,
				DARTPC.TSSubmitRules,
				DARTPC.IsAutoAssigneeForDART,
				DARTPC.AutoUploadForDARTCount,
				DARTPC.TicketSharePathUsers,
				DARTPC.TktDfltrMail,
				DARTPC.TktDfltrMailStartDay,
				DARTPC.TktDfltrMailEndDay,
				DARTPC.TktDfltrMailFrequency,
				DARTPC.IsEffortFlag,
				DARTPC.IsMandatoryFlag,
				DARTPC.TicketdefaulterMailNextDate,
				DARTPC.IsTicketTypeMappedForService,
				DARTPC.Workinghours,
				DARTPC.ReportForAssociates,
				DARTPC.ReportForSupervisor
			FROM AVMDART.MAP.ProjectConfig (NOLOCK) DARTPC
			JOIN @ProjectDetails PD 
				ON PD.ProjectID = DARTPC.Projectid
			JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
				ON PM.EsaProjectID = PD.EsaProjectID
			LEFT JOIN AVMDART.MAS.TimeZoneMaster (NOLOCK) DARTTZ
				ON DARTTZ.TimeZoneID = DARTPC.TimeZoneId
			LEFT JOIN AVL.MAS_TimeZoneMaster (NOLOCK) TM
				ON TM.TimeZoneName = DARTTZ.TimeZoneName
			LEFT JOIN AVL.MAP_ProjectConfig (NOLOCK) PC
				ON PC.ProjectID = PM.ProjectID
			WHERE PC.ProjectID IS NULL
			
		
			---------- Update Customer Master Table ----------

			SELECT cust.CustomerID, 
				CASE WHEN COUNT(DISTINCT ISNULL(dartpc.SDTicketFormat, 'AL')) > 1 THEN 1 
					 WHEN COUNT(DISTINCT ISNULL(dartpc.SDTicketFormat, 'AL')) = 1 THEN 0
				END
				AS StateofSD 
			INTO #TEMP
			FROM AVMDART.MAP.ProjectConfig (NOLOCK) DARTPC 
			JOIN @ProjectDetails PDS 
				ON PDS.ProjectID = DARTPC.ProjectID
			JOIN AVL.Customer (NOLOCK) cust 
				ON cust.ESA_AccountID = PDS.AccountID
			JOIN AVL.MAS_ProjectMaster (NOLOCK) appproj
				ON appproj.CustomerID = cust.CustomerID AND PDS.EsaProjectID = appproj.EsaProjectID
			WHERE appproj.IsDeleted = 0 AND cust.IsDeleted = 0 --AND DARTPC.SDTicketFormat IS NOT NULL
			GROUP BY cust.CustomerID


	  		UPDATE C 
				SET IsEffortConfigured = 1,
				IsEffortTrackActivityWise = ISNULL(CTC.IsEffortTrackActivityWise, 1), -- INPUT FROM PROJECT TEAM
				EffortTrackingMethod = 'M',
				IsDaily = ISNULL(CTC.IsDaily, 1), -- INPUT FROM PROJECT TEAM
				TimezoneId = TM.TimeZoneId,
				DefaulterMail = 1,
				SDTicketFormat = CASE WHEN C.SDTicketFormat = 'AL' THEN C.SDTicketFormat  
									  ELSE CASE WHEN tmp.StateofSD = 1 THEN 'AL' ELSE ISNULL(DARTPC.SDTicketFormat, 'AL') END END
			FROM AVL.Customer (NOLOCK) C
			LEFT JOIN DBO.DataMigration_CustomerwiseTicketingConfig (NOLOCK) CTC
				ON CTC.ESA_AccountID = C.ESA_AccountID
			RIGHT JOIN #Temp tmp ON C.CustomerID = tmp.CustomerID
			LEFT JOIN @ProjectDetails P 
				ON P.AccountID = C.ESA_AccountID
			JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
				ON PM.EsaProjectID = P.EsaProjectID
			LEFT JOIN AVMDART.MAP.ProjectConfig (NOLOCK) DARTPC 
				ON DARTPC.ProjectID = P.ProjectID
			LEFT JOIN AVMDART.MAS.TimeZoneMaster (NOLOCK) DARTTZ
				ON DARTTZ.TimeZoneID = DARTPC.TimeZoneId
			LEFT JOIN AVL.MAS_TimeZoneMaster (NOLOCK) TM
				ON TM.TimeZoneName = DARTTZ.TimeZoneName AND TM.TimeZoneId = 32

			
			DROP TABLE #Temp

			PRINT 'End Project Config'
			------------------------------------------------------------------------------------------------------------------------------
			
			------------------------------------------------ MANDATE ATTRIBUTES ----------------------------------------------------------
			--DECLARE @ProjectCount AS INT
			--DECLARE @ProjectLoopCounter AS INT = 1

			--SELECT @ProjectCount = COUNT(AVLProjectID) FROM @ProjectDetails

			--SELECT ROW_NUMBER() OVER (ORDER BY AVLProjectID ASC) AS RowNo, AVLProjectID
			--INTO #AVLProjectIDs
			--FROM @ProjectDetails

			--DECLARE @AVLProjectID BIGINT

			--WHILE @ProjectLoopCounter <= @ProjectCount
			--BEGIN

			--	SELECT @AVLProjectID = AVLProjectID FROM #AVLProjectIDs WHERE RowNo = @ProjectLoopCounter

			--	select @AVLProjectID

			--	EXEC SP_DataMigration_InsertTicketAttributes
			--		@ProjectID = @AVLProjectID,
			--		@UserID = 'Migrated'

			--	SET @ProjectLoopCounter = @ProjectLoopCounter + 1

			--END

			--DROP TABLE #AVLProjectIDs

			---------- Push the data for Standard Attribute Project Status Master Table ----------

			--PRINT 'Standard Attribute Project Status Master'

			--INSERT INTO AVL.PRJ_StandardAttributeProjectStatusMaster
			-- (
			--	ServiceID,
			--	ServiceName,
			--	AttributeID,
			--	AttributeName,
			--	StatusID,
			--	StatusName,
			--	FieldType,
			--	CreatedDate,
			--	CreatedBy,
			--	ModifiedDate,
			--	ModifiedBy,
			--	IsDeleted,		
			--	Projectid,
			--	TicketMasterFields
			--)
			--SELECT 
			--	S.ServiceID,
			--	DARTSA.ServiceName,
			--	AM.AttributeID,
			--	DARTSA.AttributeName,
			--	DS.DARTStatusID,
			--	DARTSA.C20StatusName,
			--	DARTSA.FieldType,
			--	GETDATE() AS CreatedDateTime,
			--	'Migrated' AS CreatedBy,
			--	NULL AS ModifiedDateTime,
			--	NULL AS ModifiedBy,
			--	CASE WHEN DARTSA.IsDeleted = 'Y' THEN 1 ELSE 0 END,			
			--	PM.ProjectID,
			--	DARTSA.TicketMasterFields 
			--FROM AVMDART.MAS.StandardAttributeProjectStatusMaster (NOLOCK) DARTSA
			--JOIN @ProjectDetails PD 
			--	ON PD.ProjectID = DARTSA.ProjectID
			--JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
			--	ON PM.EsaProjectID = PD.EsaProjectID 
			--JOIN AVL.MAS_AttributeMaster (NOLOCK) AM 
			--	ON AM.AttributeName = DARTSA.AttributeName AND AM.IsDeleted = 0
			--JOIN AVL.TK_MAS_DARTTicketStatus (NOLOCK) DS 
			--	ON REPLACE(DS.DARTStatusName, CHAR(160), CHAR(32)) = REPLACE(DARTSA.C20StatusName, CHAR(160), CHAR(32))
			--LEFT JOIN AVL.TK_MAS_Service (NOLOCK) S 
			--	ON S.ServiceName = DARTSA.ServiceName
			--LEFT JOIN AVL.PRJ_StandardAttributeProjectStatusMaster (NOLOCK) SA
			--	ON SA.ProjectID = PD.ProjectID AND SA.ServiceName = DARTSA.ServiceName 
			--	AND REPLACE(SA.StatusName, CHAR(160), CHAR(32)) = REPLACE(DARTSA.C20StatusName, CHAR(160), CHAR(32))
			--		 AND SA.AttributeName = DARTSA.AttributeName 
			--		AND SA.FieldType = DARTSA.FieldType
			--WHERE SA.ProjectID IS NULL 

			--PRINT 'End Standard Attribute Project Status Master'

			------------ Push the data for Mainspring Attribute Project Status Master Table ----------

			--PRINT 'Mainspring Attribute Project Status Master'

			--INSERT INTO AVL.PRJ_MainspringAttributeProjectStatusMaster
			--(
			--	ServiceID,
			--	ServiceName,
			--	AttributeID,
			--	AttributeName,
			--	StatusID,
			--	StatusName,
			--	FieldType,
			--	CreatedDateTime,
			--	CreatedBy,
			--	ModifiedDateTime,
			--	ModifiedBy,
			--	IsDeleted,	
			--	Projectid,
			--	TicketMasterFields		   	
			--)
			--SELECT
			--	S.ServiceID,
			--	DARTMPM.ServiceName,
			--	AM.AttributeID,
			--	DARTMPM.AttributeName,
			--	DS.DARTStatusID,
			--	DARTMPM.C20StatusName,
			--	DARTMPM.FieldType,
			--	GETDATE(), -- Created By,
			--	'Migrated', -- Created DateTime,
			--	NULL, -- Modified DateTime,
			--	NULL, -- Modified By,
			--	CASE WHEN DARTMPM.IsDeleted = 'N' THEN 0 ELSE 1 END,
			--	PM.Projectid,
			--	DARTMPM.TicketMasterFields
			--FROM AVMDART.MAS.MainspringAttributeProjectStatusMaster (NOLOCK) DARTMPM 
			--JOIN @ProjectDetails PD 
			--	ON PD.ProjectID = DARTMPM.ProjectId 
			--JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
			--	ON PM.EsaProjectID = PD.EsaProjectID
			--JOIN AVL.MAS_AttributeMaster (NOLOCK) AM 
			--	ON AM.AttributeName = DARTMPM.AttributeName AND AM.IsDeleted = 0
			--JOIN AVL.TK_MAS_DARTTicketStatus (NOLOCK) DS 
			--	ON REPLACE(DS.DARTStatusName, CHAR(160), CHAR(32)) = REPLACE(DARTMPM.C20StatusName, CHAR(160), CHAR(32))
			--LEFT JOIN AVL.TK_MAS_Service (NOLOCK) S 
			--	ON S.ServiceName = DARTMPM.ServiceName			
			--LEFT JOIN AVL.PRJ_MainspringAttributeProjectStatusMaster (NOLOCK) MPM 
			--	ON MPM.ProjectID = PD.ProjectID AND MPM.ServiceName = DARTMPM.ServiceName
			--	AND MPM.AttributeName = DARTMPM.AttributeName
			--	AND REPLACE(MPM.StatusName, CHAR(160), CHAR(32)) = REPLACE(DARTMPM.C20StatusName, CHAR(160), CHAR(32))				
			--	AND MPM.FieldType = DARTMPM.FieldType
			--WHERE MPM.ProjectID IS NULL

			--PRINT 'End Mainspring Attribute Project Status Master'

			-- Insert Configuration Progress logic for Ticketing Module Configuration
			DECLARE @ApplensAccountID BIGINT;

			SELECT @ApplensAccountID = PM.CustomerID 
			FROM @ProjectDetails PD 
			JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
				ON PM.EsaProjectID = PD.EsaProjectID 
			JOIN  AVL.Customer (NOLOCK) Cust
				ON Cust.ESA_AccountID = PD.AccountID AND Cust.CustomerID = pm.CustomerID
			WHERE cust.IsDeleted = 0 AND pm.IsDeleted = 0

			--EXEC SP_DataMigration_InsertConfigurationProgress @ApplensAccountID, @ESAProjectIDs, 2

			-- Log the Ticketing Module Configuration migration is successful for the respective account.
			UPDATE DataMigrationLog SET TicketingConfigStatus = 'S' WHERE AccountID = @AccountID

			COMMIT TRAN

	END TRY  
	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage AS ErrorMessage
              
		ROLLBACK TRAN

		-- Log the Error in Data Migration Log Table.   
		UPDATE DataMigrationLog SET TicketingConfigStatus = 'F', TicketingConfigErrorMessage = @ErrorMessage
		WHERE AccountID = @AccountID
              
	END CATCH  


END
