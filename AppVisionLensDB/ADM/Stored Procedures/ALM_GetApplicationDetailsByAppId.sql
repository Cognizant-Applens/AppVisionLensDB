/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


		
		
	CREATE PROCEDURE [ADM].[ALM_GetApplicationDetailsByAppId]
	(
		@userId VARCHAR(50),
		@applicationId BIGINT
	)
	AS            
	BEGIN    
		BEGIN TRY       
			SET NOCOUNT ON  
			SELECT	ApplicationName AS ApplicationName

			FROM	AVL.APP_MAS_ApplicationDetails(NOLOCK)
			WHERE	ApplicationID = @applicationId
					AND IsActive = 1

		
		END TRY 
		 BEGIN CATCH
		  DECLARE @ErrorMessage VARCHAR(MAX);
			SELECT @ErrorMessage = ERROR_MESSAGE()	
				EXEC AVL_InsertError '[ADM].[ALM_GetApplicationDetailsByAppId] ', @ErrorMessage, @userId,@applicationId
				RETURN @ErrorMessage
		  END CATCH 
	END
