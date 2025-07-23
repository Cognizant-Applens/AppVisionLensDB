/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[InsertProjectForMLClassification] 
	    @ProjectID BIGINT,
		@UserID	NVARCHAR(50),
		@IsAutoClassified CHAR,
		@IsDDAutoClassified CHAR,
		@AutoClassificationDate DATETIME = null,
		@DDAutoClassificationDate char,
		@IsAutoClassifiedInfra CHAR,
		@IsDDAutoClassifiedInfra CHAR,
		@AutoClassificationDateInfra DATETIME = null,
		@DDAutoClassificationDateInfra char
AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;
	INSERT into AVL.TK_ProjectForMLClassification (ProjectID,EmployeeID,IsAutoClassified,IsDDAutoClassified,DDAutoClassificationDate,AutoClassificationDate,CreatedBy,
	CreatedDate,IsAutoClassifiedInfra,IsDDAutoClassifiedInfra,DDAutoClassificationDateInfra,AutoClassificationDateInfra)
	VALUES(@ProjectID,@UserID,@IsAutoClassified,@IsDDAutoClassified,@DDAutoClassificationDate,@AutoClassificationDate,@UserID,GETDATE(),@IsAutoClassifiedInfra,
	@IsDDAutoClassifiedInfra,@DDAutoClassificationDateInfra,@AutoClassificationDateInfra)
END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[InsertProjectForMLClassification]', @ErrorMessage ,''
END CATCH   
	SET NOCOUNT OFF;
END
