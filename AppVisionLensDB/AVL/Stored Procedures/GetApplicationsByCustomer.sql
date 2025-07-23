/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetApplicationsByCustomer]
@EmployeeID VARCHAR(150),
@CustomerID VARCHAR(50)
AS
BEGIN  
BEGIN TRY 
  SET NOCOUNT ON;  
  SELECT DISTINCT Applicationid 
  FROM avl.EmployeeCustomerMapping ecm 
INNER JOIN avl.EmployeeSubClusterMapping es on es.EmployeeCustomerMappingId = ecm.id
INNER JOIN avl.BusinessClusterMapping b on es.subclusterid = b.businessclustermapid 
INNER JOIN avl.APP_MAS_ApplicationDetails ap on ap.SubBusinessClusterMapID = b.BusinessClusterMapID
WHERE ecm.EmployeeId = @EmployeeID 
AND ecm.CustomerId = @CustomerID
END TRY
 BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetApplicationByCustomer] ', @ErrorMessage, @EmployeeID,@CustomerID
  END CATCH   
END
