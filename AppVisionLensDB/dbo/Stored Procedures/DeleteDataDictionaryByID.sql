/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- Author:		 Dhivya        
-- Create Date:  Jan 30 2019
-- Description:  To delete the pattern from data dictionary table
-- DB Name :     AppVisionlens
-- ============================================================================ 

CREATE Proc [dbo].[DeleteDataDictionaryByID] 
(
@DataDetails_delete [dbo].[TVP_ProjectDataDictionary_Delete] READONLY,
@EmployeeID NVARCHAR(100)
)
AS
BEGIN
BEGIN TRY
	BEGIN TRAN
	SET NOCOUNT ON;
	DECLARE @result BIT
	SELECT
	DD.ID,
		 DD.ProjectID
		,DD.ApplicationID
		,DD.CauseCodeID
		,DD.ResolutionCodeID
		INTO #Temp
	FROM @DataDetails_delete DD


	UPDATE PDD set PDD.IsDeleted=1,PDD.DebtClassificationID = '',PDD.AvoidableFlagID = '',PDD.ResidualDebtID = '', 
	PDD.ReasonForResidual = '',PDD.ExpectedCompletionDate = NULL,PDD.ModifiedBy=@EmployeeID,PDD.ModifiedDate=GETDATE()
	from  [AVL].[Debt_MAS_ProjectDataDictionary] AS PDD
	INNER join @DataDetails_delete AS TE on TE.ProjectID = PDD.ProjectID and TE.[ApplicationID] = PDD.ApplicationID
	and TE.[CauseCodeID] = PDD.CauseCodeID and TE.ResolutionCodeID = PDD.ResolutionCodeID AND TE.ID=PDD.ID

	SET @result = 1
		SELECT
		@result AS RESULT
	COMMIT TRAN
END TRY 
BEGIN CATCH
IF @@TRANCOUNT > 0 BEGIN
ROLLBACK TRAN
SET @result = 0
END
DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()		
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[DeleteDataDictionaryByID]', @ErrorMessage, 0,0
END CATCH
END
