/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/*-- =============================================
-- Author:		Sreeya
-- Create date: 28-6-2018
-- Description:	Gets the portfolio name based on the customer id
-- =============================================*/
CREATE PROCEDURE [AVL].[CL_GetPortfolioName]
@EmployeeID nvarchar(max),
@CustomerId bigint
AS
BEGIN
BEGIN TRY
IF EXISTS(SELECT TOP(1) BusinessClusterName FROM AVL.BusinessCluster WHERE 
			CustomerID=@CustomerId AND IsHavingSubBusinesss=0)
BEGIN
		 SELECT TOP(1) BusinessClusterName FROM AVL.BusinessCluster WHERE 
			CustomerID=@CustomerId AND IsHavingSubBusinesss=0
END
ELSE 
		 BEGIN
		 SELECT 'Portfolio'
		 END
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[CL_GetPortfolioName] ', @ErrorMessage, @CustomerId,@EmployeeID
		
	END CATCH  
END