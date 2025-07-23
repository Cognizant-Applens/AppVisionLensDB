/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[SP_DataMigration_AVMDARTAPPLENS_Inc] --'1229409'
(
	@ESAAccountID NVARCHAR(20) -- ESA AccountID
	--@ProjectIDs NVARCHAR(MAX) = NULL -- ESA Project ID
)
AS
BEGIN

	DECLARE @CustomerIDs TABLE
	(
		ESA_AccountID NVARCHAR(max)
	)
	INSERT INTO @CustomerIDs 
	
		SELECT DISTINCT ESA_AccountID FROM DataMigration_IncProjects (NOLOCK) where ESA_AccountID = @ESAAccountID

	IF OBJECT_ID (N'DataMigrationLogInc', N'U') IS NULL 
	BEGIN


		CREATE TABLE DataMigrationLogInc
		(
			ID BIGINT IDENTITY(1, 1),
			AccountID BIGINT,
			ESAProjectID NVARCHAR(25),
			DDStatus CHAR(1) NULL, -- Holds 'S' - Success, 'F' - Failure
			TicketingModuleStatus CHAR(1) NULL, -- Holds 'S' - Success, 'F' - Failure
			WorkEffortEliminationStatus CHAR(1) NULL, -- Holds 'S' - Success, 'F' - Failure
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

				IF NOT EXISTS (SELECT 1 FROM DataMigrationLogInc (NOLOCK) WHERE AccountID = @CustomerID)
				BEGIN

					INSERT INTO DataMigrationLogInc
					(
						AccountID,
						ESAProjectID,
						DDStatus,
						TicketingModuleStatus,
						WorkEffortEliminationStatus,
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
						NULL
					)

				END

				DECLARE @ProjectIDs NVARCHAR(MAX)
				SET @ProjectIDs = (SELECT STUFF((SELECT DISTINCT ',' + esaprojectid
								FROM DataMigration_IncProjects (NOLOCK) WHERE ESA_AccountID = @CustomerID
								FOR XML PATH(''), TYPE).value('.[1]', 'NVARCHAR(MAX)'), 1, 1, '')) 
				
				PRINT @ProjectIDs
				

				IF NOT EXISTS (SELECT 1 FROM DataMigrationLogInc (NOLOCK) 
					WHERE AccountID = @CustomerID AND DDStatus= 'S')
				BEGIN

					-- Migrate Data Dictionary
					EXEC SP_DataMigration_DataDictionary @CustomerID, @ProjectIDs, 1

				END
					
				IF NOT EXISTS (SELECT 1 FROM DataMigrationLogInc (NOLOCK) 
					WHERE AccountID = @CustomerID AND TicketingModuleStatus= 'S')
				BEGIN

					--Migrate Ticketing Module
					EXEC SP_DataMigration_TicketingModule @CustomerID, @ProjectIDs, 1

				END

				-- Migrate Work Effort Elimination if Ticketing module migration is successful
				IF EXISTS (SELECT 1 FROM DataMigrationLogInc (NOLOCK) 
					WHERE AccountID = @CustomerID AND TicketingModuleStatus = 'S')
				BEGIN

					-- Migrate Work Effort Elimination
					EXEC SP_DataMigration_WorkEffortElimination @CustomerID, @ProjectIDs, 1

				END

		   END

		   SET @loop = @loop + 1

       END TRY  
       BEGIN CATCH  

			DECLARE @ErrorMessage VARCHAR(MAX);

            SELECT @ErrorMessage = ERROR_MESSAGE()

            SELECT @ErrorMessage AS ErrorMessage
              
       END CATCH  

    END

END
