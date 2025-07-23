/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : Priya Dharshini
-- Create date : 19 Mar 2018
-- Description : Procedure to update the language preference of an employee.               
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [AVL].[SaveLanguageByEmployee]
(
	@EmployeeID NVARCHAR(50),
	@Language NVARCHAR(50),
	@UserID NVARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN

			DECLARE @LanguageID INT
			DECLARE @IsDeleted INT = 0

			-- Update the user's language if already record exists in the user language preference table.
			IF EXISTS (SELECT TOP 1 EmployeeID FROM [AVL].[UserPreferenceLanguage] (NOLOCK) WHERE EmployeeID = @EmployeeID AND IsDeleted = @IsDeleted)
			BEGIN

				SELECT @LanguageID = LanguageID 
				FROM [MAS].[MAS_LanguageMaster] WHERE LanguageName = @Language

				IF (ISNULL(@LanguageID, '') <> '')
			    BEGIN

					UPDATE [AVL].[UserPreferenceLanguage] 
					SET LanguageID = @LanguageID, ModifiedDate = GETDATE(), ModifiedBy = @UserID 
					WHERE EmployeeID = @EmployeeID

				END

			END
			
		COMMIT TRAN

	END TRY
	BEGIN CATCH

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		ROLLBACK TRAN

	END CATCH
END
