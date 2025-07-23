/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ML].[Infra_GetTowerDetails] 
@ProjectID BIGINT
AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;

	 		
		SELECT DISTINCT IPM.TowerId,AMR.TowerName
			FROM AVL.InfraTowerProjectMapping(NOLOCK) IPM  					
		
		INNER JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) AMR
			ON IPM.TowerID=AMR.InfraTowerTransactionID
		INNER JOIN AVL.MAP_ProjectConfig(NOLOCK) PC 
			ON PC.ProjectID=IPM.ProjectID
		WHERE IPM.ProjectID=@ProjectID AND PC.SupportTypeId<>1
			ORDER BY AMR.TowerName ASC 

		
 
	SET NOCOUNT OFF;
END TRY
BEGIN CATCH

		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[ML].[Infra_GetTowerDetails] ', @ErrorMessage,@ProjectID

END CATCH
END
