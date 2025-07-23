/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================ 
-- Author:           Devika 
-- Create date:      22 June 2018 
-- Description:      To update whether optional field upload is optional for the project  
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB 
-- EXEC [dbo].[ML_UpdateOptionalFieldUpload]  9352 
-- ============================================================================ 
CREATE PROCEDURE [dbo].[ML_UpdateOptionalFieldUpload] --318 
  @ProjectID BIGINT,
  @SupportTypeID INT
AS 
  BEGIN 
      BEGIN TRY 
		DECLARE @CriteriaMet NVARCHAR(50);
          BEGIN TRAN 
		  IF @SupportTypeID=2
		  BEGIN
			  UPDATE AVL.ML_PRJ_InitialLearningStateInfra 
			  SET    OptionalFieldupl = 'O' 
			  WHERE  ProjectID = @ProjectID 
					 AND IsDeleted = 0 

			 EXEC @CriteriaMet= [AVL].[ML_GetCriteriaMetInfra] @ProjectID
		 END
		 ELSE
			BEGIN
				UPDATE AVL.ML_PRJ_InitialLearningState
			  SET    OptionalFieldupl = 'O' 
			  WHERE  ProjectID = @ProjectID 
					 AND IsDeleted = 0 

			  EXEC @CriteriaMet= [AVL].[ML_GetCriteriaMetApp] @ProjectID
			END
          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_UpdateOptionalFieldUpload] ', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
