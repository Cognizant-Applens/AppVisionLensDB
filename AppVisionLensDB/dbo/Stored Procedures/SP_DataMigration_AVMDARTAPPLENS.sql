/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[SP_DataMigration_AVMDARTAPPLENS] --'1229409'
--(
	 --@pESAAccountID BIGINT -- ESA AccountID
	--@ProjectIDs NVARCHAR(MAX) = NULL -- ESA Project ID
--)
AS
BEGIN

	DECLARE @CustomerIDs TABLE
	(
		ESA_AccountID NVARCHAR(max)
	)
	INSERT INTO @CustomerIDs 

	
	
		SELECT DISTINCT ESA_AccountID FROM DataMigration_Projects (NOLOCK)
		 --where EsaProjectID in('1000173547')

		


	IF OBJECT_ID (N'DataMigrationLog', N'U') IS NULL 
	BEGIN


		CREATE TABLE DataMigrationLog
		(
			ID BIGINT IDENTITY(1, 1),
			AccountID BIGINT,
			ESAProjectID NVARCHAR(25),
			MasterStatus CHAR(1) NULL, -- Holds 'S' - Success, 'F' - Failure
			AppInventoryStatus CHAR(1) NULL, -- Holds 'S' - Success, 'F' - Failure
			ITSMStatus CHAR(1) NULL, -- Holds 'S' - Success, 'F' - Failure
			TicketingConfigStatus CHAR(1) NULL, -- Holds 'S' - Success, 'F' - Failure
			DebtConfigStatus CHAR(1) NULL, -- Holds 'S' - Success, 'F' - Failure
			DDStatus CHAR(1) NULL, -- Holds 'S' - Success, 'F' - Failure
			TicketingModuleStatus CHAR(1) NULL, -- Holds 'S' - Success, 'F' - Failure
			WorkEffortEliminationStatus CHAR(1) NULL, -- Holds 'S' - Success, 'F' - Failure
			MasterErrorMessage NVARCHAR(MAX) NULL,
			AppInventoryErrorMessage NVARCHAR(MAX) NULL,
			ITSMErrorMessage NVARCHAR(MAX) NULL,
			TicketingConfigErrorMessage NVARCHAR(MAX) NULL,
			DebtConfigErrorMessage NVARCHAR(MAX) NULL,
			DDErrorMessage NVARCHAR(MAX) NULL,
			TicketingModuleErrorMessage NVARCHAR(MAX) NULL,
			WorkEffortEliminationErrorMessage NVARCHAR(MAX) NULL
		)

	END
	
	DECLARE @CustomerID BIGINT = 0,
			@CustomerCount INT,
			@loop INT;

    SET @loop = 1

    SELECT ROW_NUMBER() OVER (ORDER BY ESA_AccountID ASC) AS RowNo, ESA_AccountID
	INTO #AccountIDs 
	FROM  @CustomerIDs

    SELECT @CustomerCount = COUNT(ESA_AccountID) FROM #AccountIDs

    WHILE ( @loop <= @CustomerCount )
    BEGIN

       BEGIN TRY

		   SET @CustomerID = 0

		   SELECT @CustomerID = ESA_AccountID FROM #AccountIDs WHERE RowNo = @loop

		   IF @CustomerID > 0
		   BEGIN

				IF NOT EXISTS (SELECT 1 FROM DataMigrationLog (NOLOCK) WHERE AccountID = @CustomerID)
				BEGIN

					INSERT INTO DataMigrationLog
					(
						AccountID,
						ESAProjectID,
						MasterStatus,
						AppInventoryStatus,
						ITSMStatus,
						TicketingConfigStatus,
						DebtConfigStatus,
						DDStatus,
						TicketingModuleStatus,
						WorkEffortEliminationStatus,
						MasterErrorMessage,
						AppInventoryErrorMessage,
						ITSMErrorMessage,
						TicketingConfigErrorMessage,
						DebtConfigErrorMessage,
						DDErrorMessage,
						TicketingModuleErrorMessage,
						WorkEffortEliminationErrorMessage
					)
					VALUES
					(
						@CustomerID,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL
					)

				END

				DECLARE @ProjectIDs NVARCHAR(MAX)
				SET @ProjectIDs = (SELECT STUFF((SELECT DISTINCT ',' + esaprojectid
								FROM DataMigration_Projects (NOLOCK) WHERE ESA_AccountID = @CustomerID
								FOR XML PATH(''), TYPE).value('.[1]', 'NVARCHAR(MAX)'), 1, 1, '')) 
				--SET @ProjectIDs='1000216564'
				
				PRINT @ProjectIDs

				IF NOT EXISTS (SELECT 1 FROM DataMigrationLog (NOLOCK) 
						WHERE AccountID = @CustomerID AND MasterStatus = 'S')
				BEGIN

					-- Update Masters - Login and Project Masters
					EXEC SP_DataMigration_Masters @CustomerID, @ProjectIDs

				END
				---commented by annadurai for appventory
				--IF NOT EXISTS (SELECT 1 FROM DataMigrationLog (NOLOCK) 
				--		WHERE AccountID = @CustomerID AND AppInventoryStatus = 'S')
				--BEGIN
				  
				--   IF EXISTS (SELECT TOP 1 ESA_AccountID FROM DataMigration_Projects (NOLOCK) WHERE ESA_AccountID = @CustomerID AND IsAppInventory = 1)
				--   BEGIN

				--		-- Migrate App Inventory 
				--		EXEC SP_DataMigration_AppInventory @CustomerID, @ProjectIDs

				--   END

				--END


				--IF NOT EXISTS (SELECT 1 FROM DataMigrationLog (NOLOCK) 
				--	WHERE AccountID = @CustomerID AND ITSMStatus = 'S')
				--BEGIN
					
				--	-- Migration ITSM Configuration
				--	EXEC SP_DataMigration_ITSMConfiguration @CustomerID, @ProjectIDs

				--END

				IF NOT EXISTS (SELECT 1 FROM DataMigrationLog (NOLOCK) 
					WHERE AccountID = @CustomerID AND TicketingConfigStatus = 'S')
				BEGIN

					-- Migrate Ticketing Module Configuration
					EXEC SP_DataMigration_TickingModuleConfiguration @CustomerID, @ProjectIDs

				END

				IF NOT EXISTS (SELECT 1 FROM DataMigrationLog (NOLOCK) 
						WHERE AccountID = @CustomerID AND DebtConfigStatus = 'S')
				BEGIN
				
					-- Migrate Debt Configuration
					EXEC SP_DataMigration_DebtConfiguration @CustomerID, @ProjectIDs
				
				END

				-- Migrate Transactional modules if Admin Console migration is successful
				--IF EXISTS (SELECT 1 FROM DataMigrationLog (NOLOCK) 
				--	WHERE AccountID = @CustomerID AND AppInventoryStatus = 'S' AND ITSMStatus = 'S' 
				--		AND TicketingConfigStatus = 'S' AND DebtConfigStatus = 'S')
				--BEGIN

					--IF NOT EXISTS (SELECT 1 FROM DataMigrationLog (NOLOCK) 
					--	WHERE AccountID = @CustomerID AND DDStatus= 'S')
					--BEGIN

					--	-- Migrate Data Dictionary
					--	EXEC SP_DataMigration_DataDictionary @CustomerID, @ProjectIDs

					--END
					
					--IF NOT EXISTS (SELECT 1 FROM DataMigrationLog (NOLOCK) 
					--	WHERE AccountID = @CustomerID AND TicketingModuleStatus= 'S')
					--BEGIN

					--	-- Migrate Ticketing Module
					--	EXEC SP_DataMigration_TicketingModule @CustomerID, @ProjectIDs

					--END

					---- Migrate Work Effort Elimination if Ticketing module migration is successful
					--IF EXISTS (SELECT 1 FROM DataMigrationLog (NOLOCK) 
					--	WHERE AccountID = @CustomerID AND TicketingModuleStatus = 'S')
					--BEGIN

					--	-- Migrate Work Effort Elimination
					--	EXEC SP_DataMigration_WorkEffortElimination @CustomerID, @ProjectIDs

					--END

				--END

		   END

		   SET @loop = @loop + 1

       END TRY  
       BEGIN CATCH  

			DECLARE @ErrorMessage VARCHAR(MAX);

            SELECT @ErrorMessage = ERROR_MESSAGE()

            SELECT @ErrorMessage AS ErrorMessage
              
       END CATCH  

    END

	-- Execute Mainspring Job SP to fill Service Activity for migrated Projects
	EXEC MS.JobForServiceActivity 


END
