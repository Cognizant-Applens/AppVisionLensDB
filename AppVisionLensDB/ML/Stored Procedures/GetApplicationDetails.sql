/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC [ML].[GetApplicationDetails]  10337
CREATE PROCEDURE [ML].[GetApplicationDetails] 
@ProjectID BIGINT
AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;

		SELECT DISTINCT APM.ApplicationID,AD.ApplicationName 
		FROM avl.APP_MAP_ApplicationProjectMapping (NOLOCK) APM
		INNER JOIN avl.APP_MAS_ApplicationDetails(NOLOCK) AD 
		ON APM.ApplicationID=AD.ApplicationID
		INNER JOIN AVL.MAP_ProjectConfig(NOLOCK) PC 
		ON PC.ProjectID=APM.ProjectID
		WHERE APM.ProjectID=@ProjectID AND ISNULL(PC.SupportTypeId,1)<>2
		ORDER BY AD.ApplicationName ASC 
 
	SET NOCOUNT OFF;
END TRY
BEGIN CATCH

		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[ML].[GetApplicationDetails] ', @ErrorMessage,@ProjectID

END CATCH
END
