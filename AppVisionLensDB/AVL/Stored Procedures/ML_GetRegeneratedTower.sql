/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ML_GetRegeneratedTower] 
@ProjectID BIGINT
AS 
  BEGIN
	  SET NOCOUNT ON; 
      BEGIN TRY 
		SELECT DISTINCT IPM.TowerID,TD.TowerName FROM AVL.InfraTowerProjectMapping(NOLOCK) IPM
		INNER JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) TD
		ON IPM.TowerID=TD.InfraTowerTransactionID
		LEFT JOIN AVL.ML_TRN_MLPatternValidationInfra(NOLOCK) MPV 
		ON IPM.ProjectID=MPV.ProjectID AND IPM.TowerID=MPV.TowerID
		WHERE IPM.ProjectID=@ProjectID AND MPV.ID IS NULL
		AND IPM.IsEnabled=1 AND ISNULL(IPM.IsDeleted,0)=0
	  END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = ERROR_MESSAGE() 
          --INSERT Error     
          EXEC AVL_INSERTERROR '[AVL].[ML_GetRegeneratedTower] ',  @ErrorMessage, '',  @ProjectID 
      END CATCH 
  END
