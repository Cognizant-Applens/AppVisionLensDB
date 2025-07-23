/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================   
-- Author:           688715   
-- Create date:      26/12/2019  
-- Description:      SP for Initial Learning   
-- Test:             EXEC [ML].[GetValidateTickets] 10337,2 
-- ============================================================================  
CREATE PROC [ML].[GetValidateTickets]
 @ID BIGINT,
 @Choose TINYINT,
 @IsRegenerate BIT = NULL
AS 
  BEGIN 
      BEGIN TRY 
	  DECLARE @IsDescriptionTranslateField  BIT = 0,
			  @IsResolutionRemarksTranslateField  BIT = 0,
			  @LatestID INT = 0;
	  SET @LatestID = (CASE 
				  WHEN @IsRegenerate = 0 THEN ( SELECT TOP 1 ID FROM   ML.ConfigurationProgress
												 WHERE  projectid = @ID 
												 AND IsDeleted = 0 ORDER  BY ID asc )
					ELSE ( SELECT max(ID) FROM   ML.ConfigurationProgress 
						   WHERE  projectid = @ID AND IsDeleted = 0 and ISNULL(IsMLSentOrReceived,'') <>'Received'
						 )
	               END
				  ) 


				  	
		IF EXISTS(SELECT TOP 1 * FROM AVL.MAS_ProjectMaster WHERE ProjectID= @ID AND IsDeleted = 0 AND IsMultilingualEnabled = 1)
		BEGIN
			SET @IsDescriptionTranslateField = ([AVL].[CheckIfMultilingualColumnsActiveOrNot](@ID, 1, 1));
			SET @IsResolutionRemarksTranslateField = ([AVL].[CheckIfMultilingualColumnsActiveOrNot](@ID, 3, 1));
		END 
	   SELECT 
		DISTINCT
		CP.ID,
        TV.TicketID, 
		CONVERT(BIGINT, PM.ProjectID) AS ESAProjectID,
		CASE WHEN(@Choose = 1 OR (@Choose = 2 AND @IsDescriptionTranslateField = 0)) THEN TV.TicketDescription 
			ELSE ISNULL(MTT.TicketDescription, TV.TicketDescription)
		END AS TicketDecryptedDescription,
		CASE WHEN(@Choose = 1 OR (@Choose = 2 AND @IsResolutionRemarksTranslateField = 0)) THEN TV.OptionalField
			ELSE ISNULL(MTT.ResolutionRemarks, TV.OptionalField)
		END AS ResolutionRemarks,
		TV.AvoidableFlagID
		,TV.ResidualDebtID
		,TV.DebtClassificationID
		,TV.CauseCodeID
		,TV.ResolutionCodeID
		,CASE WHEN @IsDescriptionTranslateField = 1 THEN MTT.IsTicketDescriptionUpdated 
			ELSE CAST(0 AS BIT) END AS IsTicketDescriptionTranslate,
		CASE WHEN @IsResolutionRemarksTranslateField = 1 THEN MTT.IsResolutionRemarksUpdated 
			ELSE CAST(0 AS BIT) END AS IsResolutionRemarksTranslate
		FROM
		ML.TicketValidation TV
		JOIN ML.ConfigurationProgress(NOLOCK) CP ON CP.ProjectID = TV.ProjectID AND CP.ID=TV.InitialLearningID
		JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.ProjectID = TV.ProjectID AND PM.IsDeleted = 0
		JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON TD.TicketID = TV.TicketID AND TD.ProjectID = TV.ProjectID AND TD.IsDeleted = 0
		LEFT JOIN AVL.TK_TRN_Multilingual_TranslatedTicketDetails(NOLOCK) MTT ON MTT.TimeTickerID = TD.TimeTickerID
		WHERE TV.ProjectID = @ID AND TV.IsDeleted = 0  AND CP.ID = @LatestID	
	
	  END TRY
	  BEGIN CATCH
	   DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            'GetValidateTickets]', 
            @ErrorMessage, 
            @ID, 
            0 
	  END CATCH
  END
