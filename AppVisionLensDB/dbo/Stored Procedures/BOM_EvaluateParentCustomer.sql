
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE   PROCEDURE [dbo].[BOM_EvaluateParentCustomer]
AS
BEGIN
	BEGIN TRY
		IF EXISTS (
				SELECT TOP 1 1
				FROM [$(AVMCOEESADB)].[dbo].[MigratedParentAccounts]
				)
			BEGIN TRAN

		SELECT ParentAccount
			,ParentAccountID
			,Account
			,AccountID
		INTO #AllAccountList
		FROM [$(AVMCOEESADB)].[dbo].[MigratedParentAccounts]

		SELECT aal.*
		INTO #NewCustomer
		FROM #AllAccountList AS aal
		WHERE NOT EXISTS (
				SELECT ParentCustomerName
					,ParentCustomerID
					,CustomerName
					,CustomerID
				FROM ESA.BUParentAccounts AS c
				WHERE aal.AccountID = c.ESA_AccountID
					AND aal.ParentAccountID = c.ParentCustomerID
				)

		INSERT INTO ESA.BUParentAccounts (
			ParentCustomerID
			,ParentCustomerName
			,ESA_AccountID
			,CustomerName
			,CustomerID
			,IsActive
			,CreatedBy
			,CreatedDate
			)
		SELECT nc.ParentAccountID
			,nc.ParentAccount
			,nc.AccountID
			,nc.Account
			,b.CustomerID
			,1
			,'System'
			,GETDATE()
		FROM #NewCustomer nc
		INNER JOIN AVL.Customer b ON nc.AccountID = b.ESA_AccountID

		IF @@TRANCOUNT > 0
		COMMIT TRAN
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN

		DECLARE @ErrorMessage VARCHAR(4000);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage AS ErrorMessage

		--ROLLBACK TRAN  
		--INSERT Error      
		EXEC AVL_InsertError '[dbo].[BOM_EvaluateParentCustomer] '
			,@ErrorMessage
			,0
			,0
	END CATCH
END
