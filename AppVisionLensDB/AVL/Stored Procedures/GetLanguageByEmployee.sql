-- =========================================================================================
-- Author      : Priya Dharshini
-- Create date : 18 Mar 2018
-- Description : Procedure to insert the default language 'English' in user preference table 
--				 and get the language of an employee              
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [AVL].[GetLanguageByEmployee]
(
	@EmployeeID NVARCHAR(50),
	@ModuleName VARCHAR(5) = NULL
)
AS
BEGIN

	BEGIN TRY
	SET NOCOUNT ON
		BEGIN TRAN
		
		DECLARE @LanguageID INT
		DECLARE @IsDeleted INT = 0
		DECLARE @DefaultLanguage NVARCHAR(50) = 'English'
		
		-- If the employee does not exists, set the language preference default as 'English' by inserting into the table.
		IF NOT EXISTS (SELECT TOP 1 EmployeeID FROM [AVL].[UserPreferenceLanguage] With (NOLOCK) WHERE EmployeeID = @EmployeeID AND IsDeleted = @IsDeleted)
		BEGIN

			SELECT @LanguageID = LanguageID 
			FROM [MAS].[MAS_LanguageMaster] With (NOLOCK) WHERE LanguageName = @DefaultLanguage

			IF (ISNULL(@LanguageID, '') <> '')
			BEGIN
			
				INSERT INTO [AVL].[UserPreferenceLanguage] VALUES (@EmployeeID, @LanguageID, GETDATE(), @EmployeeID, NULL, NULL, @IsDeleted)
			
			END

		END
		IF @ModuleName='TM'
			BEGIN
			-- Get the employee's language.
				SELECT EmployeeID, LanguageName AS [Language] 
				FROM [AVL].[UserPreferenceLanguage]  UPL With (NOLOCK)
				JOIN [MAS].[MAS_LanguageMaster] (NOLOCK) LM 
					ON LM.LanguageID = UPL.LanguageID
				WHERE EmployeeID = @EmployeeID AND UPL.IsDeleted = @IsDeleted 
			END
		ELSE
			BEGIN	
				SELECT @EmployeeID as EmployeeID, LanguageName AS [Language] 		
				FROM [MAS].[MAS_LanguageMaster] With (NOLOCK) 
				WHERE  LanguageID = 1
			END

	COMMIT TRAN
	SET NOCOUNT OFF
	END TRY
	BEGIN CATCH

		ROLLBACK TRAN

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		              
  END CATCH
END
