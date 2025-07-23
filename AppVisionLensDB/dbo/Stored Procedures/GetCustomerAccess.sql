/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[GetCustomerAccess] @customerId VARCHAR(50)=NULL
AS
BEGIN
BEGIN TRY
Select DISTINCT b.IsDebtEnabled IsDebtengineEnabled,a.IsEffortConfigured from AVL.Customer a
 INNER JOIN AVL.MAS_ProjectMaster b ON 
a.CustomerID=b.CustomerID WHERE a.CustomerID=@customerId AND A.IsDeleted=0 AND B.IsDeleted=0
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[dbo].[GetCustomerAccess] ', @ErrorMessage, 0,@customerId
	END CATCH  
End
