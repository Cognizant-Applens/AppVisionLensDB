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
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [AVL].[GetApplicationHierarchyMapping] 
	-- Add the parameters for the stored procedure here
@CustomerID bigint,
@UserID nvarchar(300)
AS
BEGIN
BEGIN TRY
SELECT		
				AL.BusinessClusterMapID,
				AL.BusinessClusterBaseName,
				AL.BusinessClusterID,
				AL.ParentBusinessClusterMapID ,
				AL.IsHavingSubBusinesss,
				AD.ApplicationID,
				ad.ApplicationName
FROM 
				AVL.BusinessClusterMapping AL
WITH(NOLOCK)
LEFT JOIN
				AVL.APP_MAS_ApplicationDetails AD
WITH(NOLOCK)
ON
				AD.SubBusinessClusterMapID=AL.BusinessClusterMapID
				WHERE 
		
		
				CustomerID = @CustomerID
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[APP_INV_GetApplicationAttributes]', @ErrorMessage, @CustomerID, @UserID 
END CATCH
END
