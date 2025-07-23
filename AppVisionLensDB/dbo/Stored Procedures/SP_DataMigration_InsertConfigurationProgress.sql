/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ===============================================================  
-- Author:  Annadurai.S  
-- Create date: 26 June 2018
-- Description: Migration of  Configuration Progress
-- AppVisionLens - App Lens DB
-- EXEC SP_DataMigration_InsertConfigurationProgress  5497, 1
-- ===============================================================  

CREATE PROC [dbo].[SP_DataMigration_InsertConfigurationProgress] 
(
	@CustomerId INT, -- Applens Customer Running ID
	@ESAProjectIDs NVARCHAR(MAX), -- ESA Project IDs
	@Module INT -- 1 - ITSM, 2 - Ticketing Module Config, 3 - Debt Config
) 
AS 
BEGIN
	BEGIN TRY
		BEGIN TRAN

			DECLARE @DebtControlMethod NVARCHAR(1) = 'M';
			
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
				SELECT  PM.CustomerID AS AccountID,
						'' AS AccountName,			
						PM.ProjectID,
						PM.EsaProjectID,
						PM.ProjectName  
				FROM AVL.MAS_ProjectMaster (NOLOCK) PM 
				WHERE PM.CustomerID = @CustomerID AND PM.IsDeleted = 0  
					AND (@ESAProjectIDs IS NULL OR PM.EsaProjectID IN (SELECT ESAProjectID FROM #ESAProjectIds))
					SELECT * from @ProjectDetails					

			DECLARE @TempTable TABLE
			(
				CustomerID VARCHAR(MAX),		
				ProjectID VARCHAR(MAX),
				ScreenID INT,
				ITSMScreenID NVARCHAR(MAX),
				Totalvalue INT,
				Percentage DECIMAL(9,2),
				Isdeleted INT
			)

			IF(@Module = 2 OR @Module = 3) 
			BEGIN
			 
				INSERT INTO @TempTable
				(
					CustomerID,
					ProjectID,
					ScreenID,
					ITSMScreenID,
					Totalvalue,
					Percentage,
					Isdeleted		  
				)
				SELECT DISTINCT
					@CustomerID,
					ProjectID,
					--CASE WHEN @Module = 3 THEN ProjectID ELSE NULL END,
					5,
					NULL,
					0,
					0.0,
					0
				FROM @ProjectDetails

			END

			------ Debt Configration Progress -------
			IF (@Module = 3)
			BEGIN

				PRINT 'DCONFIG';

				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.MAS_ProjectDebtDetails (NOLOCK) PD
					ON PD.ProjectID = t.ProjectID AND PD.IsDeleted = 0 
				JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
					ON PM.ProjectID = PD.ProjectID  
				WHERE (ISNULL(IsAutoClassified, '') <> '' OR ISNULL(IsDDAutoClassified, '') <> '' 
					OR ISNULL(IsDebtEnabled, '') <> '') 

				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.MAS_ProjectDebtDetails (NOLOCK) PD
					ON PD.ProjectID = t.ProjectID AND PD.IsDeleted = 0
				WHERE ISNULL(IsCostTracked, '') <> '' 

				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.Debt_BlendedRateCardDetails (NOLOCK) BR
					ON BR.ProjectID = t.ProjectID AND BR.IsDeleted = 0
				WHERE ISNULL(BlendedRate, 0) <> 0 

				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.MAS_ProjectDebtDetails (NOLOCK) PD 
					ON PD.ProjectID = t.ProjectID AND PD.IsDeleted = 0
				WHERE ISNULL(IsTicketApprovalNeeded, '') <>'' 
					

				UPDATE @TempTable SET Percentage = (TotalValue * 50) / 4

				-- added newly end
				UPDATE @TempTable SET Totalvalue = 0


				IF (@DebtControlMethod <> '')
				BEGIN
					UPDATE  @TempTable SET Totalvalue = Totalvalue + 1
				END


				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.DEBT_MAS_HealProjectThresholdMaster (NOLOCK) PD 
					ON PD.ProjectID = t.ProjectID AND PD.IsDeleted = 0

				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.Heal_EffortConfigureState (NOLOCK) PD 
					ON PD.ProjectID = t.ProjectID AND PD.HealType = 'Simple' AND PD.IsDeleted = 0	
				
				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.Heal_EffortConfigureState (NOLOCK) PD 
					ON PD.ProjectID = t.ProjectID AND PD.HealType = 'Medium' AND PD.IsDeleted = 0 

				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.Heal_EffortConfigureState (NOLOCK) PD 
					ON PD.ProjectID = t.ProjectID AND PD.HealType = 'Complex' AND PD.IsDeleted = 0 

				UPDATE @TempTable SET Percentage = Percentage + ((TotalValue * 50) / 5)

			END

			---- Ticketing Module Configuration Progress ----
			IF (@Module = 2)
			BEGIN

				PRINT 'TICFIG';

				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.Customer (NOLOCK) C 
					ON C.CustomerID = t.CustomerID AND C.IsEffortTrackActivityWise IS NOT NULL

				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.Customer (NOLOCK) C 
					ON C.CustomerID = t.CustomerID AND ISNULL(C.EffortTrackingMethod, '') <> ''

				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.Customer (NOLOCK) C 
					ON C.CustomerID = t.CustomerID AND C.IsDaily IS NOT NULL

				--UPDATE @TempTable 
				--SET Totalvalue = t.Totalvalue + 1
				--FROM @TempTable t 
				--JOIN AVL.Customer (NOLOCK) C 
				--	ON C.CustomerID = t.CustomerID AND ISNULL(C.TimezoneId, 0) <> 0

				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.Customer (NOLOCK) C 
					ON C.CustomerID = t.CustomerID AND ISNULL(C.DefaulterMail, '') <> ''

				UPDATE @TempTable 
				SET Totalvalue = t.Totalvalue + 1
				FROM @TempTable t 
				JOIN AVL.Customer (NOLOCK) C 
					ON C.CustomerID = t.CustomerID AND ISNULL(C.SDTicketFormat, '') <> ''

		
				UPDATE @TempTable SET Percentage = Percentage + (TotalValue * 100) / 5

			END

			---- ITSM Configuration Progress ----
			IF (@Module = 1)
			BEGIN
					
				PRINT 'ITSM';

				--- 1. Home Mapping ---

				INSERT INTO @TempTable
					SELECT
						@CustomerID,
						PM.ProjectID,
						2,
						1,
						0,
						100,
						0
	   				FROM @ProjectDetails P
					JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
						ON PM.ProjectID = P.ProjectID AND ISNULL(PM.ITSMID, 0) <> 0
		

				--- 2. Column Mapping ---

				INSERT INTO @TempTable
					SELECT
						@CustomerID,
						P.ProjectID,
						2,
						2,
						0,
						100,
						0
					FROM @ProjectDetails P
					JOIN AVL.ITSM_PRJ_SSISColumnMapping (NOLOCK) CM 
						ON CM.ProjectID = P.ProjectID AND CM.IsDeleted = 0
		

				--- 3. Service Configuration ---

				INSERT INTO @TempTable
					SELECT
						@CustomerID,
						P.ProjectID,
						2,
						3,
						0,
						100,
						0
	   				FROM @ProjectDetails P
					JOIN  AVL.TK_PRJ_ProjectServiceActivityMapping (NOLOCK) SAM 
						ON SAM.ProjectID = P.ProjectID AND SAM.IsDeleted = 0
		

				--- 4. Ticket Type ---

				INSERT INTO @TempTable
					SELECT
						@CustomerID,
						P.ProjectID,
						2,
						4,
						0,
						100,
						0
	   				FROM @ProjectDetails P
					INNER JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) TT 
						ON TT.ProjectID = P.ProjectID AND TT.IsDeleted = 0

				--- 5. Priority Management ---

				INSERT INTO @TempTable
					SELECT
						@CustomerID,
						P.ProjectID,
						2,
						5,
						0,
						100,
						0
	   				FROM @ProjectDetails P
					JOIN AVL.TK_MAP_PriorityMapping (NOLOCK) PRI 
						ON PRI.ProjectID = P.ProjectID AND PRI.IsDeleted = 0


				--- 6. Severity Management ---

				INSERT INTO @TempTable
					SELECT
						@CustomerID,
						P.ProjectID,
						2,
						6,
						0,
						100,
						0
	   				FROM @ProjectDetails P
					JOIN AVL.[TK_MAP_SeverityMapping] (NOLOCK) SM 
						ON SM.ProjectID = P.ProjectID AND SM.IsDeleted = 0


				--- 7. Ticket Status ---

				INSERT INTO @TempTable
					SELECT
						@CustomerID,
						P.ProjectID,
						2,
						7,
						0,
						100,
						0
	   				FROM @ProjectDetails P
					JOIN AVL.[TK_MAP_ProjectStatusMapping] (NOLOCK) PSM 
						ON PSM.ProjectID = P.ProjectID AND PSM.IsDeleted = 0 
						
				--- 8. Cause Code ---

				INSERT INTO @TempTable
					SELECT
						@CustomerID,
						P.ProjectID,
						2,
						8,
						0,
						100,
						0
	   				FROM @ProjectDetails P
					JOIN AVL.[DEBT_MAP_CauseCode] (NOLOCK)  CC 
						ON CC.ProjectID = P.ProjectID AND CC.IsDeleted = 0 

				--- 9. Resolution Code ---

				INSERT INTO @TempTable
					SELECT
						@CustomerID,
						P.ProjectID,
						2,
						9,
						0,
						100,
						0
	   				FROM @ProjectDetails P
					JOIN AVL.[DEBT_MAP_ResolutionCode] (NOLOCK) RC 
						ON RC.ProjectID = P.ProjectID AND RC.IsDeleted = 0 

				--- 10. Ticket Source ---

				INSERT INTO @TempTable
					SELECT
						@CustomerID,
						P.ProjectID,
						2,
						10,
						0,
						100,
						0
	   				FROM @ProjectDetails P
					JOIN AVL.TK_MAP_SourceMapping (NOLOCK) TS 
						ON TS.ProjectID = P.ProjectID AND TS.IsDeleted = 0  
						
				
				--- 11. Ticket Upload Configuration ---

				INSERT INTO @TempTable
					SELECT
						@CustomerID,
						P.ProjectID,
						2,
						11,
						0,
						100,
						0
	   				FROM @ProjectDetails P
					JOIN DBO.TicketUploadProjectConfiguration (NOLOCK) TUC 
						ON TUC.ProjectID = P.ProjectID AND TUC.IsDeleted = 0  
						

				INSERT INTO AVL.PRJ_ConfigurationProgress 
					SELECT DISTINCT CustomerID,
						ProjectID,
						ScreenID,
						ITSMScreenID,
						Percentage,
						0,
						'Migrated',
						GETDATE(),
						NULL,
						NULL,
						NULL,
						NULL
					FROM @TempTable 
					ORDER BY 2
  
			END

			IF(@Module = 2 OR @Module = 3) 
			BEGIN

				PRINT 'tcconfig';

				INSERT INTO AVL.PRJ_ConfigurationProgress 
					SELECT CustomerID,
						ProjectID,
						CASE WHEN @Module = 3 THEN 5 ELSE 4 END,
						NULL,
						ROUND(Percentage, 0),
						0,
						'Migrated',
						GETDATE(),
						NULL,
						NULL,
						NULL,
						NULL
					FROM @TempTable 

			END
	
		COMMIT TRAN

	END TRY  
	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage AS ErrorMessage
              
		ROLLBACK TRAN
              
	END CATCH  

END
