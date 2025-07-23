/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [BOT].[GetBOTRepositoryFilterDetails]	
	@Flag INT
AS
BEGIN
BEGIN TRY	
	SET NOCOUNT ON;

	DECLARE @IsDeleted INT = 0
	--FETCH BoT Type details
	IF(@Flag = 1)
		BEGIN
				SELECT DISTINCT Id as ID, Type as [Name] FROM bot.BOTType 
				WHERE IsDeleted = @IsDeleted
				
		END
		IF (@Flag = 2)
		BEGIN
				SELECT DISTINCT Id as ID, TargetApplicationName as Name FROM bot.TargetApplication 
				WHERE IsDeleted = @IsDeleted
				
		END
		IF (@Flag = 3)
		BEGIN
				SELECT DISTINCT PrimaryTechnologyId as ID, PrimaryTechnologyName as Name FROM avl.APP_MAS_PrimaryTechnology 
				WHERE IsDeleted = @IsDeleted
				
		END
END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		INSERT INTO AVL.Errors VALUES(0,'BOT.GetBOTRepositoryFilterDetails',@ErrorMessage,'system',GETDATE())
	
END CATCH

END
