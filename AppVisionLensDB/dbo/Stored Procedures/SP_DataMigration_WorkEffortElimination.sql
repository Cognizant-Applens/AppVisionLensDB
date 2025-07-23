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
-- Author: Devika 
-- Create date: 11 July 2018
-- Description: Migration of Work Effort Elimination Module
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- Test: EXEC [dbo].[SP_DataMigration_WorkEffortElimination] '1220264'1200960 1220264 1230048 1202377 1230552 1230064 1204036 1201096 1200885 1229409

-- SP_DataMigration_WorkEffortElimination '1222953','1000217758'
--SP_DataMigration_WorkEffortElimination '1222953','1000219016'


-- EXEC SP_DataMigration_WorkEffortElimination 1201185,'1000195935', 1
-- EXEC SP_DataMigration_WorkEffortElimination '1224804', '1000171606'
-- EXEC SP_DataMigration_WorkEffortElimination '1201125', '1000192711'
-- EXEC SP_DataMigration_WorkEffortElimination '1230064', '1000165665'
-- ================================================================================= 
CREATE PROCEDURE [dbo].[SP_DataMigration_WorkEffortElimination]
(
	@AccountId BIGINT, -- AVM DART ESA Account ID
	@ESAProjectIDs NVARCHAR(MAX), -- ESA Project IDs
	@IsIncrementalProject BIT
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
		
			  ---------- Get all projects or specific project(s) for the Accounts ----------
			  SELECT Item AS ESAProjectID INTO #ESAProjectIds FROM dbo.Split(@ESAProjectIDs, ',')

              DECLARE @ProjectDetails TABLE 
              ( 
                     AccountID INT,
                     AccountName NVARCHAR(MAX),
                     ProjectID INT,
                     EsaProjectID NVARCHAR(MAX),
                     ProjectName VARCHAR(MAX)
              )

				INSERT INTO @ProjectDetails
					SELECT	DA.AccountID AS AccountID,
							AccountName,
							PM.ProjectID,
							PM.EsaProjectID,
							PM.ProjectName
					FROM AVMDART.MAS.ProjectMaster (NOLOCK) PM
					JOIN AVMDART.[MAP].[DeptAcctMapping] (NOLOCK) DA
						ON DA.AccountID = @AccountId AND DA.DeptAccountID = PM.DeptAccountID 
							AND DA.IsDeleted = 'N' AND PM.IsDeleted = 'N'
					JOIN AVL.Customer (NOLOCK) CUST
						ON CUST.ESA_AccountID = DA.AccountID AND CUST.IsDeleted = 0
					JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APLPM
						ON APLPM.EsaProjectID = PM.EsaProjectID AND APLPM.IsDeleted = 0
					WHERE @ESAProjectIDs IS NULL OR PM.EsaProjectID IN (SELECT ESAProjectID FROM #ESAProjectIds)
						
				
				DROP TABLE #ESAProjectIds 

				-------------------------- Push Heal Project Pattern Mapping Dynamic Table ----------------------------------
				PRINT 'Heal Project Pattern'

				PRINT 'Column name'

				INSERT INTO AVL.DEBT_PRJ_HealProjectPatternColumnMapping
				(
					ProjectID,
					ColumnID,
					IsActive,
					CreatedBy,
					CreatedDate
				)
				SELECT	PM.ProjectID,
						AVHCM.ColumnID,
						CASE WHEN HPPMCol.IsActive='Y' THEN 1 ELSE 0 END,
						'Migrated',
						GETDATE()
				FROM AVMDART.PRJ.Heal_ProjectPatternColumnMapping (NOLOCK) HPPMCol 
				JOIN AVMDART.MAS.Heal_ColumnMaster (NOLOCK) HCM 
					ON HCM.ColumnID = HPPMCol.ColumnID AND HCM.IsActive = 'Y'
				JOIN AVL.DEBT_MAS_HealColumnMaster (NOLOCK) AVHCM 
					ON AVHCM.ColumnName = HCM.ColumnName AND AVHCM.IsActive = 1
				JOIN @ProjectDetails PD ON PD.ProjectID = HPPMCol.ProjectID
				JOIN AVL.MAS_ProjectMaster (NOLOCK) PM ON PM.EsaProjectID = PD.EsaProjectID AND PM.IsDeleted = 0
				
				
				SELECT HPPM.* 
				INTO #Heal_ProjectPatternColumnMappingcolumn
				FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping (NOLOCK) HPPM
				JOIN AVL.MAS_ProjectMaster (NOLOCK) PM ON PM.ProjectID = HPPM.ProjectID
				JOIN @ProjectDetails PD ON PD.EsaProjectID = PM.EsaProjectID
				
				PRINT 'Column name after'
			
				INSERT INTO AVL.DEBT_PRJ_HealProjectPatternMappingDynamic 
				(
					ProjectID,
					AvoidableFlag,
					TicketType,
					ApplicationID,
					PatternFrequency,
					PatternStatus,
					CreatedBy,
					CreatedDate,
					ModifiedBy,
					ModifiedDate,
					IsDeleted,
					IsManual,
					HealPattern
				)
				SELECT DISTINCT	APM.ProjectID,
								TD.AvoidableFlag,
								PPMD.TicketType,
								AAM.ApplicationID,
								PPMD.PatternFrequency,
								PPMD.PatternStatus,
								'Migrated' AS CreatedBy,
								GETDATE() AS CreatedDate,
								NULL AS ModifiedBy,
								NULL AS ModifiedDate,
								CASE WHEN PPMD.IsDeleted = 'N' THEN 0 ELSE 1 END AS Isdeleted,
								PPMD.IsManual,
								CAST(AAM.ApplicationID AS NVARCHAR(MAX))+'-'+CAST(MRC.ResolutionID AS NVARCHAR(MAX))+'-'
								+CAST(MCC.CauseID AS NVARCHAR(MAX))+'-'+CAST(DC.DebtClassificationID AS NVARCHAR(MAX))+'-'
								+CAST(AF.AvoidableFlagID AS NVARCHAR(MAX))+'-'
								+CASE WHEN ISNULL(TmpHppm.ColumnID, 0) > 0 THEN CONVERT(VARCHAR(100), ISNULL(TD.ServiceID, '0')) ELSE '0' END
								+'-'+CASE WHEN ISNULL(TmpHppmNature.ColumnID, 0) > 0 THEN CONVERT(VARCHAR(100), ISNULL(TD.NatureoftheTicket, '0')) ELSE '0' END
								+'-'+CASE WHEN ISNULL(TmpHppmTech.ColumnID, 0) > 0 THEN CONVERT(VARCHAR(100), '0') ELSE '0' END
								+'-'+CASE WHEN ISNULL(TmpHppmkedb.ColumnID, 0) > 0 THEN CONVERT(VARCHAR(100), ISNULL(TD.KEDBPath, '0')) ELSE '0' END
								+'-0-0-0' AS HealPattern
				FROM AVMDART.PRJ.Heal_ProjectPatternMappingDynamic (NOLOCK) PPMD
				JOIN @ProjectDetails PD
					ON PD.ProjectID = PPMD.ProjectID
				JOIN AVMDART.TRN.Heal_TicketDetails (NOLOCK) HTD
					ON PPMD.ProjectPatternMapID = HTD.ProjectPatternMapID 
				JOIN AVMDART.PRJ.Heal_ParentChild HPC (NOLOCK) 
					ON HPC.ProjectPatternMapID = HTD.ProjectPatternMapID AND HPC.HealingTicketID = HTD.HealingTicketID 
						 AND HPC.HealingTicketID <> '0' AND HPC.ProjectID=PD.ProjectID
				JOIN AVMDART.PRJ.TicketMaster (NOLOCK) TM ON TM.TicketID = HPC.DARTTicketID
					AND TM.ProjectID = pd.ProjectID
					AND ISNULL(TM.IsDeleted, 'N') = 'N' 
				JOIN AVMDART.[MAS].[ProjectMaster] (NOLOCK) DPM
					ON DPM.ProjectID = PD.ProjectID 
				JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APM
					ON APM.EsaProjectID = DPM.EsaProjectID AND APM.IsDeleted = 0
				JOIN AVL.TK_TRN_TicketDetail (NOLOCK) TD ON TD.TicketID = TM.TicketID AND APM.ProjectID = TD.ProjectID
				JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AAM
					ON AAM.ApplicationID = TD.ApplicationID
				JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APPAM
					ON APPAM.ApplicationID = AAM.ApplicationID AND APM.ProjectID = APPAM.ProjectID
				LEFT JOIN #Heal_ProjectPatternColumnMappingcolumn TmpHppm 
					ON TmpHppm.Projectid = APPAM.ProjectID AND TmpHppm.ColumnID = 6 AND TmpHppm.IsActive = 1
				LEFT JOIN #Heal_ProjectPatternColumnMappingcolumn TmpHppmNature 
					ON TmpHppmNature.Projectid = APPAM.ProjectID AND TmpHppmNature.ColumnID = 7 AND TmpHppmNature.IsActive = 1
				LEFT JOIN #Heal_ProjectPatternColumnMappingcolumn TmpHppmTech 
					ON TmpHppmTech.Projectid = APPAM.ProjectID AND TmpHppmTech.ColumnID = 8 AND TmpHppmTech.IsActive = 1
				LEFT JOIN #Heal_ProjectPatternColumnMappingcolumn TmpHppmkedb 
					ON TmpHppmkedb.Projectid = APPAM.ProjectID AND TmpHppmkedb.ColumnID = 9 AND TmpHppmkedb.IsActive = 1
				JOIN AVL.DEBT_MAS_DebtClassification (NOLOCK) DC ON DC.DebtClassificationID = TD.DebtClassificationMapID
				JOIN AVL.DEBT_MAS_AvoidableFlag (NOLOCK) AF ON AF.AvoidableFlagID = TD.AvoidableFlag
				JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) MCC 
					ON MCC.CauseID = TD.CauseCodeMapID AND MCC.ProjectID = APM.ProjectID
				JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) MRC ON MRC.ResolutionID = TD.ResolutionCodeMapID AND MRC.ProjectID = APM.ProjectID
				LEFT JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic (NOLOCK) HPPMD
					ON HPPMD.ProjectID = APM.ProjectID AND HPPMD.IsDeleted = 0
				WHERE HPPMD.ProjectID IS NULL

				----SELECT * from #ticket

				-------------------------------- PUSH DEBT TRN Heal Ticket Details -------------------------------
				PRINT 'Heal Ticket Details'

				SELECT  ProjectPatternMapID,
						ProjectID,
						ApplicationID = xDim.value('/x[1]','int'), --could change to desired datatype (int ?)
						ResolutionCode = xDim.value('/x[2]','int'),
						CauseCode = xDim.value('/x[3]','int'),
						DebtClassificationID = xDim.value('/x[4]','int'),
						AvoidableFlag = xDim.value('/x[5]','int')
	   			INTO #Heal_ProjectPatternMapping
				FROM  
				(
					SELECT ProjectPatternMapID AS ProjectPatternMapID, APM.ProjectID AS ProjectID,
						CAST('<x>' + REPLACE(HealPattern, '-', '</x><x>')+'</x>' AS XML) AS xDim
					FROM @ProjectDetails DPM
					JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APM
						ON APM.EsaProjectID = DPM.EsaProjectID AND APM.IsDeleted = 0
					JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM 
						ON HPPM.ProjectID = APM.ProjectID
				) AS A


				INSERT INTO AVL.DEBT_TRN_HealTicketDetails 
				(
					ProjectPatternMapID,
					HealingTicketID,
					TicketType,
					DARTStatusID,
					Assignee,
					ApplicationID,
					OpenDate,
					PriorityID,
					IsManual,
					IsPushed,
					CreatedBy,
					CreatedDate,
					ModifiedBy,
					ModifiedDate,
					IsDeleted,
					IsMappedToProblemTicket,
					PlannedEffort,
					HealTypeId,
					PlannedStartDate,
					PlannedEndDate,
					ReleasePlanning
				)
				SELECT DISTINCT	HPPM.ProjectPatternMapID,
						HTD.HealingTicketID,
						HTD.TicketType,
						ADS.DARTStatusID,
						HTD.Assignee,
						AAM.ApplicationID,
						HTD.OpenDate,
						APRM.PriorityID,
						HTD.IsManual,
						HTD.IsPushed,
						'Migrated' AS CreatedBy,
						GETDATE() AS CreatedDate,
						NULL AS ModifiedBy,
						NULL AS ModifiedDate,
						CASE WHEN HTD.IsDeleted = 'N' THEN 0 ELSE 1 END,
						HTD.IsMappedToProblemTicket,
						HTD.PlannedEffort,
						AHTM.ID,
						HTD.PlannedStartDate,
						HTD.PlannedEndDate,
						NULL AS ReleasePlanning
			FROM AVMDART.TRN.Heal_TicketDetails (NOLOCK) HTD
			JOIN AVMDART.[PRJ].[Heal_ProjectPatternMappingDynamic] (NOLOCK) DPPM
				ON DPPM.ProjectPatternMapID = HTD.ProjectPatternMapID
			JOIN @ProjectDetails DPM
				ON DPM.ProjectID = DPPM.ProjectID
			JOIN AVMDART.PRJ.Heal_ParentChild (NOLOCK) HPC 
				ON HPC.ProjectPatternMapID = DPPM.ProjectPatternMapID AND HPC.ProjectID = DPPM.ProjectID
			JOIN AVMDART.PRJ.TicketMaster (NOLOCK) PTM 
				ON HPC.DARTTicketID = PTM.TICKETID AND HPC.ProjectID = PTM.ProjectID
			JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APM
				ON APM.EsaProjectID = DPM.EsaProjectID
			JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM
				ON HPPM.ProjectID = APM.ProjectID
			JOIN AVMDART.MAS.ApplicationMaster (NOLOCK) DAM
				ON DAM.ApplicationID = HTD.ApplicationID
			JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AAM
				ON AAM.ApplicationName = DAM.ApplicationName
			JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APPAM
				ON APPAM.ApplicationID = AAM.ApplicationID AND APM.ProjectID = APPAM.ProjectID
			LEFT JOIN AVMDART.[MAS].[DARTStatus] (NOLOCK) DDS
				ON DDS.DARTSatusID = HTD.DARTStatusID
			LEFT JOIN [AVL].[TK_MAS_DARTTicketStatus] (NOLOCK) ADS
				ON ADS.DARTStatusName = DDS.DartStatusName
			LEFT JOIN AVMDART.[PRJ].[PriorityMaster] (NOLOCK) DPRM
				ON DPRM.PriorityID = HTD.PriorityID
			LEFT JOIN [AVL].[TK_MAS_Priority] APRM
				ON APRM.PriorityName = DPRM.PriorityName
			LEFT JOIN AVMDART.[MAS].[HealTypeMaster] (NOLOCK) DHTM
				ON DHTM.ID = HTD.HealTypeid
			LEFT JOIN [AVL].[HealTypeMaster] (NOLOCK) AHTM
				ON AHTM.HealTypeValue = DHTM.HealTypeValue
			JOIN AVL.TK_TRN_TicketDetail (NOLOCK) TD
				ON TD.TicketID = HPC.DARTTicketID AND TD.ProjectID = APM.ProjectID
			JOIN #Heal_ProjectPatternMapping HPPMTEMP 
				ON APM.ProjectID = HPPMTEMP.ProjectID AND HPPM.ProjectPatternMapID = HPPMTEMP.ProjectPatternMapID  
					AND TD.DebtClassificationMapID = HPPMTEMP.DebtClassificationID AND TD.CauseCodeMapID = HPPMTEMP.CauseCode
					AND TD.ApplicationID = HPPMTEMP.ApplicationID AND TD.ResolutionCodeMapID = HPPMTEMP.ResolutionCode
					AND TD.AvoidableFlag = HPPMTEMP.AvoidableFlag
			LEFT JOIN AVL.DEBT_TRN_HealTicketDetails (NOLOCK) AHTD
				ON AHTD.ProjectPatternMapID = HPPM.ProjectPatternMapID
			WHERE AHTD.ProjectPatternMapID IS NULL

			---------------------------------- PUSH DEBT TRN Heal Tickets Log -------------------------------

			INSERT INTO AVL.DEBT_TRN_HealTicketsLog 
			(
				ProjectID,
				HealingTicketID,
				ActivityID,
				Priority,
				Assignee,
				Status,
				ProblemTicketID,
				NewHealingTicketID,
				ServiceID,
				ParentTicket,
				TableName,
				CreatedBy,
				CreatedDate,
				PlannedEffort,
				HealTypeId,
				PlannedStartDate,
				PlannedEndDate
			)
			SELECT	APM.ProjectID,
					DHTL.HealingTicketID,
					AACM.ActivityID,
					DHTL.Priority,
					DHTL.Assignee,
					DHTL.Status,
					DHTL.ProblemTicketID,
					DHTL.NewHealingTicketID,
					ASM.ServiceID,
					DHTL.ParentTicket,
					'AVL.DEBT_TRN_HealTicketDetails',
					'Migrated' AS CreatedBy,
					GETDATE() AS CreatedDate,
					DHTL.PlannedEffort,
					AHTM.ID,
					DHTL.PlannedStartDate,
					DHTL.PlannedEndDate
			FROM AVMDART.TRN.Heal_TicketsLog (NOLOCK) DHTL
			INNER JOIN @ProjectDetails DPM
				ON DPM.ProjectID = DHTL.ProjectID
			JOIN AVL.MAS_ProjectMaster (NOLOCK) APM
				ON APM.EsaProjectID = DPM.EsaProjectID
			LEFT JOIN AVMDART.[MAS].[ActivityMaster] (NOLOCK) DACM
				ON DACM.ActivityID = DHTL.ActivityID
			LEFT JOIN [AVL].[MAS_ActivityMaster] (NOLOCK) AACM
				ON AACM.ActivityName = DACM.ActivityName
			LEFT JOIN AVMDART.[MAS].[ServiceMaster] (NOLOCK) DSM
				ON DSM.ServiceID = DHTL.ServiceID
			LEFT JOIN [AVL].[TK_MAS_Service] (NOLOCK) ASM
				ON ASM.ServiceName = DSM.ServiceName
			LEFT JOIN AVMDART.[MAS].[HealTypeMaster] (NOLOCK) DHTM
				ON DHTM.ID = DHTL.HealTypeid
			LEFT JOIN [AVL].[HealTypeMaster] (NOLOCK) AHTM
				ON AHTM.HealTypeValue = DHTM.HealTypeValue
			LEFT JOIN AVL.DEBT_TRN_HealTicketsLog (NOLOCK) AHTL
				ON AHTL.ProjectID = APM.ProjectID
			WHERE AHTL.ProjectID IS NULL


			---------------------------------- PUSH DEBT PRJ Heal Parent Child -------------------------------

			--PRINT'parent'
			INSERT INTO AVL.DEBT_PRJ_HealParentChild 
			(
				ProjectPatternMapID,
				ProjectID,
				HealingTicketID,
				DARTTicketID,
				MapStatus,
				CreatedBy,
				CreatedDate,
				ModifiedBy,
				ModifiedDate,
				IsDeleted,
				IsManual
			)
			SELECT DISTINCT HPPM.ProjectPatternMapID,
				APM.ProjectID,
				HPC.HealingTicketID,
				HPC.DARTTicketID,
				HPC.MapStatus,
				'Migrated' AS CreatedBy,
				HPC.CreatedDate AS CreatedDate,
				NULL AS ModifiedBy,
				NULL AS ModifiedDate,
				CASE WHEN HPC.IsDeleted = 'N' THEN 0 ELSE 1 END,
				HPC.IsManual
			FROM AVMDART.PRJ.Heal_ParentChild (NOLOCK) HPC
			JOIN AVMDART.[PRJ].[Heal_ProjectPatternMappingDynamic] (NOLOCK) DPPM
				ON DPPM.ProjectPatternMapID = HPC.ProjectPatternMapID AND dppm.ProjectID = hpc.ProjectID
			JOIN @ProjectDetails DPM
				ON DPM.ProjectID = DPPM.ProjectID
			JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APM
				ON APM.EsaProjectID = DPM.EsaProjectID AND APM.IsDeleted = 0
			JOIN #Heal_ProjectPatternMapping HPPMTEMP 
				ON APM.ProjectID = HPPMTEMP.ProjectID 
			JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM
				ON HPPM.ProjectID = APM.ProjectID AND HPPM.ProjectPatternMapID = HPPMTEMP.ProjectPatternMapID
			JOIN AVL.TK_TRN_TicketDetail (NOLOCK) TD 
				ON  TD.ProjectID = APM.ProjectID AND TD.TicketID = HPC.DARTTicketID AND ISNULL(TD.IsDeleted, 0) = 0
					AND TD.DebtClassificationMapID = HPPMTEMP.DebtClassificationID AND TD.CauseCodeMapID = HPPMTEMP.CauseCode
					AND TD.ApplicationID = HPPMTEMP.ApplicationID AND TD.ResolutionCodeMapID = HPPMTEMP.ResolutionCode
					AND TD.AvoidableFlag = HPPMTEMP.AvoidableFlag
			LEFT JOIN AVL.DEBT_PRJ_HealParentChild (NOLOCK) AHPC
				ON AHPC.ProjectID = APM.ProjectID AND AHPC.HealingTicketID = HPC.HealingTicketID AND AHPC.DARTTicketID = HPC.DARTTicketID
			WHERE AHPC.ProjectID IS NULL


			-------------------------------- PUSH DEBT PRJ Heal Problem Ticket Master -------------------------------

			INSERT INTO AVL.DEBT_PRJ_HealProblemTicketMaster 
			(
				ProjectID,
				ApplicationID,
				PDartTicketID,
				IsMappedToProblemTicket,
				Status,
				CreatedBy,
				CreatedDate,
				ModifiedBy,
				ModifiedDate,
				IsDeleted
			)
			SELECT DISTINCT	APM.ProjectID,
					AAM.ApplicationID,
					PTMAS.PDartTicketID,
					PTMAS.IsMappedToProblemTicket,
					PTMAS.Status,
					'Migrated' AS CreatedBy,
					GETDATE() AS CreatedDate,
					NULL AS ModifiedBy,
					NULL AS ModifiedDate,
					CASE WHEN PTMAS.IsDeleted = 'N' THEN 0 ELSE 1 END
			FROM AVMDART.PRJ.Heal_ProblemTicketMaster (NOLOCK) PTMAS
			JOIN @ProjectDetails DPM
				ON DPM.ProjectID = PTMAS.ProjectID
			JOIN AVMDART.[PRJ].[TicketMaster] (NOLOCK) AVMTM
				ON AVMTM.TicketID = PTMAS.PDartTicketID AND AVMTM.ProjectID = DPM.ProjectID
			JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APM
				ON APM.EsaProjectID = DPM.EsaProjectID AND APM.IsDeleted = 0
			JOIN AVL.TK_TRN_TicketDetail (NOLOCK) TD
				ON TD.TicketID = PTMAS.PDartTicketID AND TD.ProjectID = APM.ProjectID
			JOIN AVMDART.MAS.ApplicationMaster (NOLOCK) DAM
				ON DAM.ApplicationID = PTMAS.ApplicationID
			JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AAM
				ON AAM.ApplicationName = DAM.ApplicationName
			JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APPAM
				ON APPAM.ApplicationID = AAM.ApplicationID AND APM.ProjectID = APPAM.ProjectID
			LEFT JOIN AVL.DEBT_PRJ_HealProblemTicketMaster (NOLOCK) AHPTMAS
				ON AHPTMAS.ProjectID = APM.ProjectID
			WHERE AHPTMAS.ProjectID IS NULL


			-------------------------------- PUSH DEBT PRJ Heal Problem Ticket Mapping -------------------------------

			INSERT INTO AVL.DEBT_PRJ_HealProblemTicketMapping 
			(
				ProblemTicketMapID,
				PDartTicketID,
				HealingTicketID,
				IsMappedToProblemTicket,
				Status,
				CreatedBy,
				CreatedDate,
				ModifiedBy,
				ModifiedDate,
				IsDeleted
			)
			SELECT DISTINCT	APTMAS.ProblemTicketMapID,
					PTM.PDartTicketID,
					PTM.HealingTicketID,
					PTM.IsMappedToProblemTicket,
					PTM.Status,
					'Migrated' AS CreatedBy,
					GETDATE() AS CreatedDate,
					NULL AS ModifiedBy,
					NULL AS ModifiedDate,
					CASE WHEN PTM.IsDeleted = 'N' THEN 0 ELSE 1 END
			FROM AVMDART.PRJ.Heal_ProblemTicketMapping (NOLOCK) PTM
			JOIN AVMDART.[PRJ].[Heal_ProblemTicketMaster] (NOLOCK) PTMAS
				ON PTMAS.ProblemTicketMapID = PTM.ProblemTicketMapID
			JOIN @ProjectDetails DPM
				ON DPM.ProjectID = PTMAS.ProjectID
			JOIN AVMDART.[PRJ].[TicketMaster] (NOLOCK) AVMTM
				ON AVMTM.TicketID = PTMAS.PDartTicketID AND AVMTM.ProjectID = DPM.ProjectID
			JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APM
				ON APM.EsaProjectID = DPM.EsaProjectID AND APM.IsDeleted = 0
			JOIN AVL.TK_TRN_TicketDetail (NOLOCK) TD
				ON TD.TicketID = PTM.PDartTicketID AND TD.ProjectID = APM.ProjectID
			JOIN [AVL].[DEBT_PRJ_HealProblemTicketMaster] (NOLOCK) APTMAS
				ON APTMAS.ProjectID = APM.ProjectID AND APTMAS.ApplicationID = PTMAS.ApplicationID AND APTMAS.PDARTTicketID = PTMAS.PDARTTicketID
			LEFT JOIN AVL.DEBT_PRJ_HealProblemTicketMapping (NOLOCK) AHPTM
				ON AHPTM.ProblemTicketMapID = APTMAS.ProjectID
			WHERE AHPTM.ProblemTicketMapID IS NULL


			-------------------------------- PUSH Heal ReMapping Tickets -------------------------------


			INSERT INTO AVL.Heal_ReMappingTickets 
			(
				SrcHealingTicketID,
				SrcProjectPatternMapID,
				DesHealingTicketID,
				DesProjectPatternMapID,
				DartTicketID,
				CreatedBy,
				CreatedDate,
				ModifiedBy,
				ModifiedDate,
				IsDeleted
			)
			SELECT DISTINCT	HTAP.HealingTicketID,
					HTAP.ProjectPatternMapID,
					HTAPdes.HealingTicketID,
					HTAPdes.ProjectPatternMapID,
					RMT.DartTicketID,
					'Migrated' AS CreatedBy,
					GETDATE() AS CreatedDate,
					NULL AS ModifiedBy,
					NULL AS ModifiedDate,
					CASE WHEN RMT.IsDeleted = 'N' THEN 0 ELSE 1 END
			FROM AVMDART.TRN.Heal_ReMappingTickets (NOLOCK) RMT
			JOIN AVMDART.TRN.Heal_TicketDetails (NOLOCK) AHT
				ON RMT.SrcHealingTicketID = AHT.HealingTicketID AND RMT.SrcProjectPatternMapID IS NOT NULL 
					AND RMT.SrcProjectPatternMapID = AHT.ProjectPatternMapID
			JOIN AVMDART.TRN.Heal_TicketDetails (NOLOCK) AHTDES
				ON RMT.DesHealingTicketID = AHTDES.HealingTicketID AND RMT.DesProjectPatternMapID IS NOT NULL
					AND AHTDES.ProjectPatternMapID = RMT.DesProjectPatternMapID
			JOIN AVMDART.PRJ.Heal_ProjectPatternMappingDynamic (NOLOCK) HPPMSrc
				ON HPPMSrc.ProjectPatternMapID = AHTDES.ProjectPatternMapID
			JOIN AVMDART.PRJ.Heal_ProjectPatternMappingDynamic (NOLOCK) HPPMDesc
				ON HPPMDesc.ProjectPatternMapID = AHT.ProjectPatternMapID
			JOIN AVL.DEBT_TRN_HealTicketDetails (NOLOCK) HTAP 
				ON HTAP.HealingTicketID = RMT.SrcHealingTicketID
			JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic (NOLOCK) AHPPMD
				ON HTAP.ProjectPatternMapID = AHPPMD.ProjectPatternMapID
			JOIN AVL.DEBT_TRN_HealTicketDetails (NOLOCK) HTAPdes 
				ON HTAPdes.HealingTicketID = RMT.DesHealingTicketID
			JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic (NOLOCK) AHPPMDES
				ON HTAPdes.ProjectPatternMapID = AHPPMDES.ProjectPatternMapID
			LEFT JOIN AVL.Heal_ReMappingTickets (NOLOCK) DLM
				ON RMT.SrcHealingTicketID = DLM.SrcHealingTicketID AND DLM.SrcProjectPatternMapID = HTAP.ProjectPatternMapID
					AND DLM.DesHealingTicketID = RMT.DesHealingTicketID AND DLM.DesProjectPatternMapID = HTAPdes.ProjectPatternMapID
					AND DLM.DartTicketID = RMT.DartTicketID
			WHERE DLM.SrcHealingTicketID IS NULL


			------------------------------------------- Delinking --------------------------------------------

			INSERT AVL.DEBT_PRJ_DelinkMapping 
			(
				OldHealingTicketID, 
				OldProjectPatternMapID, 
				NewHealingTicketID, 
				NewProjectPatternMapID, 
				DartTicketID, 
				IsDeleted,
				CreatedBy, 
				CreatedDate, 
				ModifiedBy, 
				ModifiedDate
			)
			SELECT DISTINCT	HDM.OldHealingTicketID,
					HDM.OldProjectPatternMapID,
					HDM.NewHealingTicketID,
					HDM.NewProjectPatternMapID,
					HDM.DartTicketID,
					CASE WHEN HDM.IsDeleted <> 'Y' THEN 0 ELSE 1 END,
					'Migrated',
					GETDATE(),
					NULL,
					NULL
			FROM AVMDART.PRJ.Heal_DelinkMapping (NOLOCK) HDM
			JOIN AVMDART.TRN.Heal_TicketDetails (NOLOCK) AHT
				ON HDM.OldHealingTicketID = AHT.HealingTicketID AND HDM.OldProjectPatternMapID IS NOT NULL
					AND HDM.OldProjectPatternMapID = AHT.ProjectPatternMapID
			JOIN AVMDART.TRN.Heal_TicketDetails (NOLOCK) AHTDES
				ON HDM.NewHealingTicketID = AHTDES.HealingTicketID AND HDM.NewProjectPatternMapID IS NOT NULL
					AND AHTDES.ProjectPatternMapID = HDM.NewProjectPatternMapID
			JOIN AVMDART.PRJ.Heal_ProjectPatternMappingDynamic (NOLOCK) HPPMSrc
				ON HPPMSrc.ProjectPatternMapID = AHTDES.ProjectPatternMapID
			JOIN AVMDART.PRJ.Heal_ProjectPatternMappingDynamic (NOLOCK) HPPMDesc
				ON HPPMDesc.ProjectPatternMapID = AHT.ProjectPatternMapID
			JOIN AVL.DEBT_TRN_HealTicketDetails (NOLOCK) HTAP
				ON HTAP.HealingTicketID = HDM.OldHealingTicketID
			JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic (NOLOCK) AHPPMD
				ON HTAP.ProjectPatternMapID = AHPPMD.ProjectPatternMapID
			JOIN AVL.DEBT_TRN_HealTicketDetails (NOLOCK) HTAPdes
				ON HTAPdes.HealingTicketID = HDM.NewHealingTicketID
			JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic (NOLOCK) AHPPMDES
				ON HTAPdes.ProjectPatternMapID = AHPPMDES.ProjectPatternMapID
			LEFT JOIN AVL.DEBT_PRJ_DelinkMapping (NOLOCK) ADLM
				ON ADLM.OldHealingTicketID = HDM.OldHealingTicketID AND ADLM.OldProjectPatternMapID = AHPPMD.ProjectPatternMapID
					AND ADLM.NewHealingTicketID = HDM.NewHealingTicketID AND ADLM.NewProjectPatternMapID = AHPPMDES.ProjectPatternMapID
			WHERE ADLM.OldHealingTicketID IS NULL

			---------------------------------------------------------------------- Update Heal Pattern-------------------------------------------------------

			--UPDATE HPPM
			--SET HealPattern =
			--	CAST(HPPM.ApplicationID AS NVARCHAR(100)) + '-' + 
			--	CAST(TD.ResolutionCodeMapID AS NVARCHAR(100)) + '-' + 
			--	CAST(TD.CauseCodeMapID AS NVARCHAR(100)) + '-' +
			--	CAST(TD.DebtClassificationMapID AS NVARCHAR(100)) + '-' + 
			--	CAST(TD.AvoidableFlag AS NVARCHAR(100))
			--FROM AVL.DEBT_PRJ_HealProjectPatternMappingDynamic (NOLOCK) HPPM
			--JOIN AVL.DEBT_TRN_HealTicketDetails (NOLOCK) HT
			--	ON HPPM.ProjectPatternMapID = HT.ProjectPatternMapID
			--JOIN AVL.DEBT_PRJ_HealParentChild (NOLOCK) HPC
			--	ON HPC.HealingTicketID = HT.HealingTicketID AND HPC.ProjectPatternMapID = HPPM.ProjectPatternMapID
			--JOIN AVL.TK_TRN_TicketDetail (NOLOCK) TD
			--	ON TD.TicketID = HPC.DARTTicketID
			--JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
			--	ON PM.ProjectID = TD.ProjectID AND PM.IsDeleted = 0
			--JOIN @ProjectDetails PD
			--	ON PD.EsaProjectID = PM.EsaProjectID

			-- Log the Work Effort Elimination migration is successful for the respective account.
			IF @IsIncrementalProject = 1
			BEGIN

				UPDATE DataMigrationLogInc SET WorkEffortEliminationStatus = 'S' 
				WHERE AccountID = @AccountId AND ESAProjectID = @ESAProjectIDs

			END
			ELSE
			BEGIN

				UPDATE DataMigrationLog SET WorkEffortEliminationStatus = 'S' 
				WHERE AccountID = @AccountId AND ESAProjectID = @ESAProjectIDs

			END

		COMMIT TRAN

	END TRY 
	BEGIN CATCH

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage AS ErrorMessage

		ROLLBACK TRAN

		-- Log the Error in Data Migration Log Table.   
		IF @IsIncrementalProject = 1
		BEGIN

			UPDATE DataMigrationLogInc
			SET	WorkEffortEliminationStatus = 'F', WorkEffortEliminationErrorMessage = @ErrorMessage
			WHERE AccountID = @AccountId AND ESAProjectID = @ESAProjectIDs

		END
		ELSE
		BEGIN

			UPDATE DataMigrationLog
			SET	WorkEffortEliminationStatus = 'F', WorkEffortEliminationErrorMessage = @ErrorMessage
			WHERE AccountID = @AccountId AND ESAProjectID = @ESAProjectIDs

		END

	END CATCH

END
