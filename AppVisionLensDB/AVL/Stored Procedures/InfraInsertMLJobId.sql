/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/



CREATE PROCEDURE [AVL].[InfraInsertMLJobId] (@ProjectID         NVARCHAR(50), 
                                     @InitialLearningId NVARCHAR(50), 
                                     @MLJobId           NVARCHAR(500), 
                                     @JobType           NVARCHAR(10), 
                                     @JobMessage        NVARCHAR(50), 
                                     @UserID            NVARCHAR(20), 
                                     @FileName          NVARCHAR(500), 
                                     @DataPath          NVARCHAR(500)) 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

          --Debt_InsertMLJobId 
          IF EXISTS (SELECT ProjectID, 
                            InitialLearningID 
                     FROM   AVL.ML_TRN_MLSamplingJobStatusInfra
                     WHERE  ProjectID = @ProjectID 
                            AND InitialLearningID = @initialLearningId) 
            BEGIN 
                UPDATE AVL.ML_TRN_MLSamplingJobStatusInfra 
                SET    IsDeleted = 1 
                WHERE  ProjectID = @ProjectID 
                       AND InitialLearningID = @initialLearningId 
            END 

          INSERT INTO AVL.ML_TRN_MLSamplingJobStatusInfra
                      (ProjectID, 
                       InitialLearningID, 
                       JobIdFromML, 
                       [FileName], 
                       DataPath, 
                       DARTJobStatus, 
                       InitiatedBy, 
                       JobMessage, 
                       JobType, 
                       CreatedDate, 
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
            '[AVL].[InfraInsertMLJobId]', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
