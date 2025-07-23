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
-- Author:    835658 
-- Create date: 14/07/2020
-- Description:   SP for Initial Learning 

-- =============================================  
CREATE PROCEDURE [ML].[Infra_GetNoiseEliminationData] (@ID BIGINT,@IsRegenerate BIT) 
AS 
  BEGIN 
      BEGIN TRY 		
		DECLARE @RegenerateID BIGINT = 0;
		DECLARE @ILIDCount INT = 0;

		SET @ILIDCount = (SELECT COUNT(ID) FROM ML.InfraConfigurationProgress WHERE ProjectID = @ID)
		
		SET @RegenerateID = (SELECT Max(ID) FROM   ML.InfraConfigurationProgress 
							WHERE  ProjectID = @ID AND IsDeleted = 0 
							AND ISNULL(IsMLSentOrReceived,'') <>'Received')
		
		SELECT TDD.ID,TDD.TicketDescNoiseWord,TDD.Frequency,TDD.IsActive
        FROM   ML.InfraTicketDescNoiseWords TDD
		INNER JOIN ML.InfraConfigurationProgress CP
		ON TDD.InitialLearningID = CP.ID
        AND  TDD.ProjectID  = @ID AND ((@IsRegenerate = 0 AND @ILIDCount = 1) 
		OR (@IsRegenerate = 0 AND @ILIDCount > 1 AND CP.IsMLSentOrReceived = 'Received')		
		OR(@IsRegenerate = 1 AND CP.ID = @RegenerateID)) 		
	  
        SELECT OFW.ID,OFW.OptionalFieldNoiseWord,OFW.Frequency,OFW.IsActive
        FROM   ML.InfraOptionalFieldNoiseWords OFW
		INNER JOIN ML.InfraConfigurationProgress CP
		ON OFW.InitialLearningID = CP.ID
		AND OFW.ProjectID  = @ID AND ((@IsRegenerate = 0 AND @ILIDCount = 1)
		OR (@IsRegenerate = 0 AND @ILIDCount > 1 AND CP.IsMLSentOrReceived = 'Received')
		OR(@IsRegenerate = 1  AND CP.ID = @RegenerateID))         

                        
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
            '[ML].[Infra_GetNoiseEliminationData]', 
            @ErrorMessage, 
            @ID, 
            0 
      END CATCH 
  END
