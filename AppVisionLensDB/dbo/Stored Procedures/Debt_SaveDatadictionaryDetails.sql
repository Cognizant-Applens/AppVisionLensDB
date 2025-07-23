/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure [dbo].[Debt_SaveDatadictionaryDetails]
(
@DataDetails [dbo].[TVP_ProjectDataDictionary] READONLY
)
AS
BEGIN
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON;
DECLARE @result BIT
SELECT
	DD.ID
	,DD.ProjectID
	,DD.ApplicationID
	,DD.CauseCodeID
	,DD.ResolutionCodeID
	,DD.DebtClassificationID
	,DD.AvoidableFlagID
	,DD.ResidualDebtID
	,DD.ReasonForResidual
	,NULLIF(CONVERT(VARCHAR, DD.ExpectedCompletionDate, 101),NULL) AS ExpectedCompletionDate
	,DD.CreatedBy
	,DD.ModifiedBy
	INTO #Temp
FROM @DataDetails DD

UPDATE [AVL].[Debt_MAS_ProjectDataDictionary]
SET --	ProjectID = t2.ProjectID
	--,ApplicationID = t2.ApplicationID
	CauseCodeID = t2.CauseCodeID
	,ResolutionCodeID = t2.ResolutionCodeID
	,DebtClassificationID = t2.DebtClassificationID
	,AvoidableFlagID = t2.AvoidableFlagID
	,ResidualDebtID = t2.ResidualDebtID
	--,ReasonForResidual = t2.ReasonForResidual
	--,ExpectedCompletionDate = t2.ExpectedCompletionDate
	,ModifiedBy = t2.ModifiedBy
	,ModifiedDate = GETDATE()
FROM [AVL].[Debt_MAS_ProjectDataDictionary] t1
JOIN @DataDetails t2
	ON t1.ID = t2.ID
	--AND t2.ID <> 0 
	WHERE t1.ProjectID=t2.ProjectID AND t1.ID = t2.ID 
IF EXISTS(select 1 from @DataDetails  where [AvoidableFlagID] = 3 and [ResidualDebtID] = 2)
BEGIN
	UPDATE [AVL].[Debt_MAS_ProjectDataDictionary]
	SET   ReasonForResidual = 0,ExpectedCompletionDate = NULL
	FROM [AVL].[Debt_MAS_ProjectDataDictionary] t1
	JOIN @DataDetails t2
		ON t1.ID = t2.ID
		--AND t2.ID <> 0 
	WHERE t1.ProjectID=t2.ProjectID AND t1.ID = t2.ID and t2.[AvoidableFlagID] = 3 and 
	t2.[ResidualDebtID] = 2
END


	SET @result = 1
	SELECT
	@result AS RESULT
	DROP TABLE #Temp
	SET NOCOUNT OFF;
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
		EXEC AVL_InsertError 'Debt_SaveDatadictionaryDetails', @ErrorMessage, 0,0
END CATCH




END
