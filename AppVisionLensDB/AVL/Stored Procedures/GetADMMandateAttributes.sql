/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ===============================================================
-- Author		: Shobana
-- Create date	: 16-July-2020
-- Description	: Get the Mandate Attributes for ADM
-- Revision		: 
-- Revised By	: 
-- Test         : [AVL].[GetADMMandateAttributes] 
-- ===============================================================

CREATE PROCEDURE [AVL].[GetADMMandateAttributes]
AS
BEGIN
	BEGIN TRY
		SELECT DISTINCT WMAP.AttributeId,AttributeName,ExecutionMethodId,ExecutionMethodName,
		MA.MandateId,MA.MandateName
		FROM ADM.WorkItemMandateAttributeMapping(NOLOCK) WMAP
		JOIN ADM.MAS_WorkItemAttributes(NOLOCK) WIA 
			ON WIA.AttributeId = WMAP.AttributeId AND WMAP.IsDeleted = 0 AND WIA.IsDeleted = 0
		JOIN (SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS ExecutionMethodName from Mas.PPAttributeValues (NOLOCK) PPA
			INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0
			WHERE AttributeName = 'ExecutionMethod') EM
			ON EM.ID = WMAP.ExecutionMethodId 
		JOIN ADM.MAS_MandateApplicability(NOLOCK) MA 
			ON MA.MandateId = WMAP.MandateId AND MA.IsDeleted = 0
	END TRY   
	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetADMMandateAttributes]', @ErrorMessage, 'System',0
		
	END CATCH  
END
