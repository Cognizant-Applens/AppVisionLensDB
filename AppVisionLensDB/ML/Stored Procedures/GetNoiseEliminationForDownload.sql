/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================= 
-- Author:    683989 
-- Create date: 14/12/2019 
-- Description:   SP for Initial Learning Noice Data Download
-- [ML].[GetNoiseEliminationForDownload]  
-- =============================================  
CREATE PROCEDURE [ML].[GetNoiseEliminationForDownload] (                                                  
                  @ProjectID INT) 
AS 
  BEGIN 
      BEGIN TRY 
	  DECLARE @InitialID BIGINT = 0;
	  SET @InitialID = (SELECT TOP 1 ID FROM ML.ConfigurationProgress WHERE  projectid = @ProjectID   
                  AND IsDeleted = 0 ORDER BY ID DESC) 
	 
		SELECT SNo,Description FROM ML.NoiseEliminationInstruction(nolock)

		SELECT TicketDescNoiseWord,Frequency, IsActive
		FROM   ML.TicketDescNoiseWords_Dump
		WHERE  ProjectID  = @ProjectID AND InitialLearningID = @InitialID
		UNION
		SELECT TicketDescNoiseWord,Frequency, IsActive
		FROM   ML.TicketDescNoiseWords
		WHERE  ProjectID  = @ProjectID AND InitialLearningID = @InitialID
		AND source='SBB'

		SELECT OptionalFieldNoiseWord,Frequency, IsActive
		FROM   ML.OptionalFieldNoiseWords_Dump
		WHERE  ProjectID  = @ProjectID AND InitialLearningID = @InitialID	
		UNION
		SELECT OptionalFieldNoiseWord,Frequency, IsActive
		FROM   ML.OptionalFieldNoiseWords
		WHERE  ProjectID  = @ProjectID AND InitialLearningID = @InitialID
		AND source='SBB'


	  END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          DECLARE @ErrorSeverity INT; 
          DECLARE @ErrorState INT; 

          SELECT @ErrorMessage = Error_message() 

          SELECT @ErrorSeverity = Error_severity() 

          SELECT @ErrorState = Error_state() 

          SELECT @ErrorMessage = Error_message() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC Avl_inserterror 
            '[AVL].[ML_GetNoiseEliminationForDownload]', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
