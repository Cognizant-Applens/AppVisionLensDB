/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================------
--	Author: Dhivya Bharathi M   
--  Create date:    April 16 2019   
-- ============================================================================
CREATE PROCEDURE [AVL].[Infra_GetCustomerDetails]
@CustomerID bigint
AS
BEGIN
	BEGIN TRY
		SELECT ISNULL(IsCognizant,0) AS IsCognizant FROM AVL.Customer WHERE CustomerID=@CustomerID
	END TRY  
	BEGIN CATCH  
			DECLARE @ErrorMessage VARCHAR(MAX);
			SELECT @ErrorMessage = ERROR_MESSAGE()
			EXEC AVL_InsertError 'AVL.Infra_GetCustomerDetails', @ErrorMessage, 0,0
		END CATCH  
END
