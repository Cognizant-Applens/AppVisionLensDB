/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : Annadurai
-- Create date : 12.06.2019 
-- Description : Procedure to check whether New ESA Project ID is already configured or not 
--					and other basic validations     
-- Revision    :
-- Revised By  :
-- =========================================================================================
--[AVL].[CheckProjectIDForMigration] 121212122,1232133
CREATE PROCEDURE [AVL].[CheckProjectIDForMigration]
(     
       @OldESAProjectID NVARCHAR(MAX),
       @NewESAProjectID NVARCHAR(MAX)	  
)
AS
BEGIN
  BEGIN TRY
      
	  DECLARE @ValidationMessage NVARCHAR(MAX) = ''
	  DECLARE @IsOldESAProjectIDPresent BIT = 0
	  DECLARE @IsNewESAProjectIDPresent BIT = 0
	  DECLARE @COUNT INT
	  DECLARE @OldProjectID BIGINT
	  DECLARE @NewProjectID BIGINT

	  SELECT @OldProjectID = ProjectID FROM AVL.MAS_ProjectMaster WHERE ESAProjectID = @OldESAProjectID
	  SELECT @NewProjectID = ProjectID FROM AVL.MAS_ProjectMaster WHERE ESAProjectID = @NewESAProjectID
	 
	  IF ISNULL(@OldProjectID, 0) <> 0
	  BEGIN

		SET @IsOldESAProjectIDPresent = 1

	  END
	  IF EXISTS (SELECT ESAProjectID FROM AVL.MAS_ProjectMaster WHERE ESAProjectID = @NewESAProjectID)
	  BEGIN

		SET @IsNewESAProjectIDPresent = 1

	  END

	  IF @IsOldESAProjectIDPresent = 0 AND @IsNewESAProjectIDPresent = 0
	  BEGIN

		SET @ValidationMessage = 'Both Old & New ESA Project IDs are not present in project Master'

	  END

	  ELSE IF @IsOldESAProjectIDPresent = 0
	  BEGIN

	     SET @ValidationMessage = 'Old ESA Project ID is not present in Project Master'

	  END

	  ELSE IF @IsNewESAProjectIDPresent = 0
	  BEGIN

	     SET @ValidationMessage = 'New ESA Project ID is not present in Project Master'

	  END
	  ELSE IF @OldESAProjectID = @NewESAProjectID
	  BEGIN

		 SET @ValidationMessage = 'Old & New ESA Project ID cannot be same.'

	  END

	  IF @ValidationMessage = ''
	  BEGIN

		  SELECT TD.ProjectID
		  INTO #ConfigurationDetails 
		  FROM AVL.TK_TRN_TicketDetail (NOLOCK) TD
		  WHERE TD.ProjectID = @NewProjectID

		  UNION

		  SELECT DISTINCT PC.ProjectID
		  FROM AVL.PRJ_ConfigurationProgress (NOLOCK) PC
		  WHERE PC.ProjectID = @NewProjectID
	  
		  UNION

		  SELECT DISTINCT APM.ProjectID
		  FROM AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APM
		  WHERE APM.ProjectID = @NewProjectID

		  UNION
	
		  SELECT DISTINCT APC.ProjectID
		  FROM AVL.MAP_ProjectConfig (NOLOCK) APC
		  WHERE APC.ProjectID = @NewProjectID


		  IF EXISTS (SELECT ProjectID FROM #ConfigurationDetails)
		  BEGIN

			SET @COUNT = 1

		  END

		  -- Check whether the both	Old & New ESA Projects are within the same Accounts.
		  IF NOT EXISTS ( SELECT PM.CustomerID 
						  FROM [AVL].[MAS_ProjectMaster] (NOLOCK) PM
						  JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) PMN  
							ON PMN.CustomerID = PM.CustomerID 
						  WHERE PM.ESAProjectID = @OldESAProjectID AND PMN.ESAProjectID = @NewESAProjectID)

		  BEGIN 

			SET @ValidationMessage = 'Unable to migrate as both Old & New ESA Projects are of different customers.'

		  END
		  ELSE IF NOT EXISTS ( SELECT 1 FROM AVL.PRJ_ConfigurationProgress (NOLOCK) PC WHERE ProjectID = @OldProjectID AND ScreenID = 2)

		  BEGIN 

			SET @ValidationMessage = 'Unable to migrate as Old ESA Project does not have any data.'

		  END 
		  ELSE IF @COUNT > 0
		  BEGIN

			SET @ValidationMessage = 'Unable to migrate as New ESA Project ID is already configured.'

		  END

	  END

	  SELECT @ValidationMessage AS ValidationMessage

  END TRY
  BEGIN CATCH

		ROLLBACK TRAN

		DECLARE @ErrorMessage VARCHAR(MAX);
		
		SELECT @ErrorMessage = ERROR_MESSAGE()

		--- INSERT Error Message ---
		EXEC AVL_InsertError '[AVL].[CheckProjectIDForMigration]', @ErrorMessage, 0, 0

  END CATCH
END
