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
-- Author:		Sreeya
-- Create date: 3-7-2018
-- Description:	Gets Application names By CustomerID
-- =============================================
CREATE PROCEDURE [dbo].[APP_INV_GetApplicationNamesByCustomerID] 
	-- Add the parameters for the stored procedure here
	@CustomerID BIGINT
AS
BEGIN
BEGIN TRY
	SELECT 
			AL.ApplicationID,AL.ApplicationName
	FROM 
			AVL.APP_MAS_ApplicationDetails AL join avl.BusinessClusterMapping BS 
	ON
		AL.SubBusinessClusterMapID=bs.BusinessClusterMapID and BS.CustomerID=@CustomerID;
		END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[APP_INV_GetApplicationNamesByCustomerID] ', @ErrorMessage, 0,@CustomerID
		
	END CATCH  



END
