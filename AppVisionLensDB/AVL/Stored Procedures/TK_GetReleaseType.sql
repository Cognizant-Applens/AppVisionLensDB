/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC [AVL].[TK_GetReleaseType]
CREATE PROCEDURE [AVL].[TK_GetReleaseType]

AS
BEGIN
BEGIN TRY

	
	--SELECT ReleaseTypeID,left(ReleaseTypeName, charindex('(', ReleaseTypeName) - 1) as ReleaseTypeName 
	SELECT ReleaseTypeID,ReleaseTypeName 
	FROM AVL.TK_MAS_ReleaseType WHERE IsDeleted = 0
	UNION
	SELECT '0' AS ReleaseTypeID,'N/A' AS ReleaseTypeName

	SELECT BusinessImpactId,BusinessImpactName from [AVL].[BusinessImpact](NOLOCK) where isdeleted=0  
	
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[TK_GetReleaseType] ', @ErrorMessage, 0,0
		
	END CATCH  




END
