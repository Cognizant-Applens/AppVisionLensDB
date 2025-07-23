/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[ITSM_ML_GetMLSamplingJobDetails]

AS
BEGIN
BEGIN TRY
		SELECT ID AS InitialLearningID,
		ProjectID  AS ProjectID,
		'ML' AS MLJobType
		FROM AVL.ML_PRJ_InitialLearningState
		WHERE IsMLSentOrReceived='Sent' AND IsDeleted=0
		
		UNION
		
		SELECT ID AS InitialLearningID,
		ProjectID  AS ProjectID,
		'Sampling' AS MLJobType
		 FROM AVL.ML_PRJ_InitialLearningState
		WHERE IsSamplingSentOrReceived='Sent' AND IsDeleted=0
		
		
		--SELECT * FROM TRN.MLSamplingJobStatus	
		
		
		--SELECT * FROM TRN.MLSamplingJobStatus			
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ITSM_ML_GetMLSamplingJobDetails] ', @ErrorMessage, 0,0
		
	END CATCH  

END
