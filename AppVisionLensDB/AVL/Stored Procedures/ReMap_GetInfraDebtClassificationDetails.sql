-- =============================================
-- Author:		<Saravanan.B>
-- Create date: <07/08/2020>
-- Description:	<ReMap_GetInfraDebtClassificationDetails>
-- =============================================
CREATE PROCEDURE [AVL].[ReMap_GetInfraDebtClassificationDetails]
AS
BEGIN
BEGIN TRY

	SELECT DebtClassificationID,DebtClassificationName FROM [AVL].[DEBT_MAS_DebtClassificationInfra] WHERE IsDeleted =0 

	END TRY  
   BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[ReMap_GetInfraDebtClassificationDetails]', @ErrorMessage, 0,0
		
	END CATCH  

END