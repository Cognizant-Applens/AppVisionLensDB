/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		Team Sunraysr
-- Create date: 09-24-2020
-- Description:	EXEC [MAS].[GetParentCustomersByCustomerID] 21 - Get all parent customers
-- =============================================
CREATE PROCEDURE [MAS].[GetParentCustomersByCustomerID] 
(
	@CustomerID INT 
)
AS
BEGIN

	SET NOCOUNT ON
	
	SELECT	pc.ParentCustomerID,pc.ParentCustomerName,
			cu.CustomerID
			
	FROM	MAS.ParentCustomers pc 
			JOIN AVL.Customer cu ON cu.ParentCustomerID = pc.ParentCustomerID AND cu.IsDeleted = 0
	WHERE	pc.IsDeleted = 0 and cu.CustomerID = @CustomerID

END