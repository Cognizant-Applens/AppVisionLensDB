/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================================
-- Author				: 
-- Create date			: 
-- Description			: 
-- Modified By			: 683989
-- Modified Reasion     : To Get Active Application Details as per CR 
-- Revised Date			: 13 Aug 2019
-- ============================================================================================
CREATE PROCEDURE [AVL].[APP_INV_GetApplicationNamesByCustomerID] 
		@CustomerID BIGINT,
		@UserID NVARCHAR(50)
AS
BEGIN
	BEGIN TRY

		SET NOCOUNT ON;

		DECLARE @IsActive INT = 1;

		SELECT	AL.ApplicationID,
				AL.ApplicationName
		FROM AVL.APP_MAS_ApplicationDetails AL WITH(NOLOCK) 
		JOIN AVL.BusinessClusterMapping BS WITH(NOLOCK)
			ON AL.SubBusinessClusterMapID = BS.BusinessClusterMapID AND BS.CustomerID = @CustomerID
		WHERE AL.IsActive = @IsActive

	END TRY  
	BEGIN CATCH 
	
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		
		EXEC AVL_InsertError '[AVL].[APP_INV_GetApplicationNamesByCustomerID]', @ErrorMessage, @UserID, @CustomerID 
		
	END CATCH  
END
