/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ML_CreateInitialLearningIDForRegenerate] @ProjectID  INT, 
                                                             @EmployeeID VARCHAR(250) 
AS 
  BEGIN 
  BEGIN TRY
  BEGIN TRAN 
      --creating new transaction id in initial learningstate table for regeneration 
      INSERT INTO [AVL].[ML_PRJ_InitialLearningState]
           ([ProjectID]
            ,[SentBy]
           ,[SentOn]
           ,[CreatedBy]
           ,[CreatedDate]
           ,[IsDeleted]
           ,[IsSDTicket]
           ,[IsDartTicket]
          ) 
      VALUES     (@ProjectID, 
                  @EmployeeID, 
                  GETDATE(), 
                  @EmployeeID, 
                  GETDATE(), 
                  0, 
                  1, 
                  1
                )
				   COMMIT TRAN  
				    END TRY 

      BEGIN CATCH 
	   DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          -- Insert Error     
          EXEC AVL_INSERTERROR 
            '[AVL].[ML_CreateInitialLearningIDForRegenerate]', 
            @ErrorMessage, 
            @ProjectID, 
            0 
	  END CATCH
  END
