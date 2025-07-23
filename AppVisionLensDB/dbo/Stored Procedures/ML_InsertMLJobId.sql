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
-- Create date:      11 FEB 2018 
-- Description:      SP for Initial Learning 
-- Test:             [dbo].[ML_InsertMLJobId] 
-- ============================================================================ 
CREATE PROCEDURE [dbo].[ML_InsertMLJobId] (@ProjectID         NVARCHAR(50), 
                                     @initialLearningId NVARCHAR(50), 
                                     @MLJobId           NVARCHAR(500), 
                                     @JobType           NVARCHAR(10), 
                                     @JobMessage        NVARCHAR(MAX), 
                                     @UserID            NVARCHAR(20), 
                                     @FileName          NVARCHAR(MAX), 
                                     @DataPath          NVARCHAR(MAX)) 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

          --Debt_InsertMLJobId 
          IF EXISTS (SELECT ProjectID, 
                            InitialLearningID 
                     FROM   AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                     WHERE  ProjectID = @ProjectID 
                            AND InitialLearningID = @initialLearningId) 
            BEGIN 
                UPDATE AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                SET    isdeleted = 1 
                WHERE  ProjectID = @ProjectID 
                       AND InitialLearningID = @initialLearningId 
            END 

          INSERT INTO AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                      (ProjectID, 
                       InitialLearningID, 
                       JobIdFromML, 
                       [FileName], 
                       DataPath, 
                       DARTJobStatus, 
                       InitiatedBy, 
                       JobMessage, 
                       JobType, 
                       CreatedOn, 
                       CreatedBy, 
                       IsDeleted) 
          VALUES     (@ProjectID, 
                      @initialLearningId, 
                      @MLJobId, 
                      @FileName, 
                      @DataPath, 
                      '', 
                      @UserID, 
                      '', 
                      @JobType, 
                      GETDATE(), 
                      @UserID, 
                      0) 

          --SELECT * from TRN.MLSamplingJobStatus 
          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_InsertMLJobId] ', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
