/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC  [AVL].[TK_GetKEDBAvailable]
CREATE PROCEDURE [AVL].[TK_GetKEDBAvailable]

AS
BEGIN
BEGIN TRY

	SELECT 
	 KEDBAvailableIndicatorID,KEDBAvailableIndicatorName --left(KEDBAvailableIndicatorName, charindex('(', KEDBAvailableIndicatorName) - 1) as KEDBAvailableIndicatorName 
	FROM [AVL].[TK_MAS_KEDBAvailableIndicator] WHERE IsDeleted = 0

		UNION
	SELECT '0' AS KEDBAvailableIndicatorID,'N/A' AS KEDBAvailableIndicatorName

	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[TK_GetKEDBAvailable] ', @ErrorMessage, 0,0
		
	END CATCH  



END
