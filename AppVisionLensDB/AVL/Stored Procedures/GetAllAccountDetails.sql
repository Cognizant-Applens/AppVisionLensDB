/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetAllAccountDetails](
@UserId VARCHAR(50)
)
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;

	--App Projects
	SELECT  DISTINCT C.customerid,C.customername, C.Esa_AccountID as EsaAccId FROM AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APM 
	INNER JOIN avl.mas_Projectmaster (NOLOCK) PM ON PM.ProjectID=APM.ProjectID AND PM.IsDeleted=0 AND APM.IsDeleted=0
	INNER JOIN  avl.customer (NOLOCK) C ON C.CustomerId=PM.CustomerId AND C.IsDeleted=0  AND C.Esa_AccountID IS NOT NULL

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetAllAccountDetails]', @ErrorMessage, @UserId,0
		
	END CATCH  
END
