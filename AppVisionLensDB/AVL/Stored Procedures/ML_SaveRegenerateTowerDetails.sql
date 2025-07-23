/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ML_SaveRegenerateTowerDetails] 
(@ProjectID         BIGINT, 
@lstRegenerateTower [AVL].[IDList] READONLY,
@UserId            NVARCHAR(50)=NULL,
@CustomerID        BIGINT) 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 
			DECLARE @InitialLearningID BIGINT 
		   INSERT INTO [AVL].ML_PRJ_InitialLearningStateInfra 
		   (ProjectID,SentBy,SentOn,CreatedBy,CreatedDate,IsDeleted,IsSDTicket,IsDartTicket)
			VALUES     (@ProjectID,@UserId,  GETDATE(),@UserId,GETDATE(),0,1,1)

          SET @InitialLearningID=(SELECT SCOPE_IDENTITY())

          IF EXISTS(SELECT ProjectID FROM   AVL.ML_TRN_RegeneratedTowerDetails(NOLOCK) 
					WHERE  ProjectID = @ProjectID AND IsDeleted = 0) 
            BEGIN 
                UPDATE AVL.ML_TRN_RegeneratedTowerDetails SET IsDeleted = 1 WHERE  ProjectID = @ProjectID 
            END 

          --inserting selected app details from regenerate popup 
          INSERT INTO AVL.ML_TRN_RegeneratedTowerDetails 
                      (InitialLearningID, 
                       CustomerID, 
                       ProjectID, 
                       TowerID, 
                       CreatedBy, 
                       CreatedDate, 
                       IsDeleted, 
                       IsMLSignOff, 
                       FromDate, 
                       ToDate) 
          SELECT @InitialLearningID,@CustomerID,@ProjectID,ID,@UserId,GETDATE(), 
                 0, 0,DATEADD(MONTH, -6, GETDATE() - 1),GETDATE() - 1 
          FROM   @lstRegenerateTower 

          --Updating isregenerated flag and Initial Learning State Table Columns,
		  --startdate by default is updated as 6 months from getdate-1 which can be changed from ui 
          UPDATE AVL.ML_PRJ_InitialLearningStateInfra 
          SET    IsRegenerated = 1,IsNoiseEliminationSentorReceived = NULL,IsMLSentOrReceived = NULL, 
                 IsSamplingInProgress = NULL,IsSamplingSentOrReceived = NULL,
				 StartDate = DATEADD(MONTH, -6, GETDATE() - 1), 
                 EndDate = GETDATE() - 1 
          WHERE  ID = @InitialLearningID AND ProjectID = @ProjectID 

          COMMIT TRAN 
      
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = Error_message() 
          ROLLBACK TRAN 
          --INSERT Error     
          EXEC Avl_inserterror '[AVL].[ML_SaveRegenerateTowerDetails] ',@ErrorMessage,@ProjectID,0 
      END CATCH 
  END
