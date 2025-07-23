/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetMultilingualTicketsByTicketID] 
(
	@TicketID		[VARCHAR](100),
	@SupportTypeID  INT
)
AS
BEGIN
BEGIN TRY

IF (@SupportTypeID = 1) -- If Ticket is App
BEGIN

	SELECT	MTV.TimeTickerID, TD.ProjectID,
			MTV.IsTicketDescriptionUpdated, TD.TicketDescription,
			MTV.IsResolutionRemarksUpdated, TD.ResolutionRemarks,
			MTV.IsTicketSummaryUpdated, TD.TicketSummary,
			MTV.IsCommentsUpdated, TD.Comments,
			MTV.IsFlexField1Updated, TD.FlexField1,
			MTV.IsFlexField2Updated, TD.FlexField2,
			MTV.IsFlexField3Updated, TD.FlexField3,
			MTV.IsFlexField4Updated, TD.FlexField4,
			MTV.IsCategoryUpdated, TD.Category,
			MTV.IsTypeUpdated, TD.Type
	INTO #tblValues
	FROM [AVL].TK_TRN_Multilingual_TranslatedTicketDetails MTV 
	JOIN AVL.TK_TRN_TicketDetail TD 
		ON TD.TimeTickerID = MTV.TimeTickerID AND TD.IsDeleted = 0 AND ISNULL(MTV.Isdeleted, 0) = 0 AND
			(MTV.IsTicketDescriptionUpdated = 1 OR MTV.IsResolutionRemarksUpdated = 1
			OR MTV.IsTicketSummaryUpdated = 1 OR MTV.IsCommentsUpdated = 1
			OR MTV.IsFlexField1Updated = 1 OR MTV.IsFlexField2Updated = 1
			OR MTV.IsFlexField3Updated = 1 OR MTV.IsFlexField4Updated = 1
			OR MTV.IsCategoryUpdated = 1 OR MTV.IsTypeUpdated = 1)
	WHERE TD.TicketID = @TicketID

	SELECT DISTINCT ProjectID AS 'ProjectID' 
	INTO #tblProject 
	FROM #tblValues;

	SELECT * FROM #tblValues

	SELECT ML.ProjectID, LM.LanguageValue, PM.MSubscriptionKey AS 'Key' 
	FROM MAS.MAS_LanguageMaster LM 
	JOIN AVL.PRJ_MAP_MultilingualLanguage ML 
		ON LM.LanguageID = ML.LanguageID 
	JOIN #tblProject tv 
		ON tv.ProjectID = ML.ProjectID
	JOIN Avl.MAS_ProjectMaster PM
		ON PM.ProjectID = tv.ProjectID
	WHERE ML.Isdeleted = 0 AND LM.IsDeleted = 0 AND lm.LanguageID != 1 AND ML.LanguageID != 1
		AND PM.IsDeleted = 0;

	DROP TABLE #tblValues

END
ELSE IF (@SupportTypeID = 2) -- If Ticket is Infra
BEGIN
		
	SELECT	MTV.TimeTickerID, TD.ProjectID,
			MTV.IsTicketDescriptionUpdated, TD.TicketDescription,
			MTV.IsResolutionRemarksUpdated, TD.ResolutionRemarks,
			MTV.IsTicketSummaryUpdated, TD.TicketSummary,
			MTV.IsCommentsUpdated, TD.Comments,
			MTV.IsFlexField1Updated, TD.FlexField1,
			MTV.IsFlexField2Updated, TD.FlexField2,
			MTV.IsFlexField3Updated, TD.FlexField3,
			MTV.IsFlexField4Updated, TD.FlexField4,
			MTV.IsCategoryUpdated, TD.Category,
			MTV.IsTypeUpdated, TD.Type
	INTO #tblValues1
	FROM [AVL].TK_TRN_Multilingual_TranslatedInfraTicketDetails MTV 
	JOIN AVL.TK_TRN_TicketDetail TD 
		ON TD.TimeTickerID = MTV.TimeTickerID AND TD.IsDeleted = 0 AND ISNULL(MTV.Isdeleted, 0) = 0 
			AND (MTV.IsTicketDescriptionUpdated = 1 OR MTV.IsResolutionRemarksUpdated = 1
					OR MTV.IsTicketSummaryUpdated = 1 OR MTV.IsCommentsUpdated = 1
					OR MTV.IsFlexField1Updated = 1 OR MTV.IsFlexField2Updated = 1
					OR MTV.IsFlexField3Updated = 1 OR MTV.IsFlexField4Updated = 1
					OR MTV.IsCategoryUpdated = 1 OR MTV.IsTypeUpdated = 1)
	WHERE TD.TicketID = @TicketID

	SELECT DISTINCT ProjectID AS 'ProjectID' 
	INTO #tblProject1 
	FROM #tblValues1;

	SELECT * FROM #tblValues1

	SELECT ML.ProjectID, LM.LanguageValue, PM.MSubscriptionKey AS 'Key' 
	FROM MAS.MAS_LanguageMaster LM 
	JOIN AVL.PRJ_MAP_MultilingualLanguage ML 
		ON LM.LanguageID = ML.LanguageID 
	JOIN #tblProject1 tv 
		ON tv.ProjectID = ML.ProjectID
	JOIN Avl.MAS_ProjectMaster PM
		ON PM.ProjectID = tv.ProjectID 
	WHERE ML.Isdeleted = 0 AND LM.IsDeleted = 0 AND lm.LanguageID != 1 AND ML.LanguageID != 1
		AND PM.IsDeleted = 0;

	DROP TABLE #tblValues1
		
END

END TRY

BEGIN CATCH
	
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetMultilingualTicketsByTicketID]', @ErrorMessage, 0, 0 

END CATCH


END
