/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/*-- =============================================
-- Author:		Sreeya
-- Create date: 14-5-2019
-- Description:	Gets MultiLingual Tickets
-- =============================================*/
CREATE PROCEDURE [AVL].[GetMultilingualTickets]
AS
BEGIN
BEGIN TRY
		-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT x.* 
INTO #tblValues
FROM (
		SELECT MTV.TimeTickerID,TD.ProjectID,
		MTV.IsTicketDescriptionUpdated,TD.TicketDescription,
		MTV.IsResolutionRemarksUpdated,TD.ResolutionRemarks,
		MTV.IsTicketSummaryUpdated,TD.TicketSummary,
		MTV.IsCommentsUpdated,TD.Comments,
		MTV.IsFlexField1Updated,TD.FlexField1,
		MTV.IsFlexField2Updated,TD.FlexField2,
		MTV.IsFlexField3Updated,TD.FlexField3,
		MTV.IsFlexField4Updated,TD.FlexField4,
		MTV.IsCategoryUpdated,TD.Category,
		MTV.IsTypeUpdated,TD.Type,
		1 AS 'TicketType'
		 FROM avl.TK_TRN_Multilingual_TranslatedTicketDetails MTV 
		JOIN
		AVL.TK_TRN_TicketDetail TD ON TD.TimeTickerID=MTV.TimeTickerID
		AND TD.IsDeleted=0 and MTV.Isdeleted=0 AND
		(MTV.IsTicketDescriptionUpdated=1 OR MTV.IsResolutionRemarksUpdated=1
		OR MTV.IsTicketSummaryUpdated=1 OR MTV.IsCommentsUpdated=1
		OR MTV.IsFlexField1Updated=1 OR MTV.IsFlexField2Updated=1
		OR MTV.IsFlexField3Updated=1 OR MTV.IsFlexField4Updated=1
		OR MTV.IsCategoryUpdated=1 OR MTV.IsTypeUpdated=1)

		UNION 

		SELECT MTV.TimeTickerID,TD.ProjectID,
		MTV.IsTicketDescriptionUpdated,TD.TicketDescription,
		MTV.IsResolutionRemarksUpdated,TD.ResolutionRemarks,
		MTV.IsTicketSummaryUpdated,TD.TicketSummary,
		MTV.IsCommentsUpdated,TD.Comments,
		MTV.IsFlexField1Updated,TD.FlexField1,
		MTV.IsFlexField2Updated,TD.FlexField2,
		MTV.IsFlexField3Updated,TD.FlexField3,
		MTV.IsFlexField4Updated,TD.FlexField4,
		MTV.IsCategoryUpdated,TD.Category,
		MTV.IsTypeUpdated,TD.Type,
		2 AS 'TicketType'
		 FROM avl.TK_TRN_Multilingual_TranslatedInfraTicketDetails MTV 
		JOIN
		AVL.TK_TRN_InfraTicketDetail TD ON TD.TimeTickerID=MTV.TimeTickerID
		AND TD.IsDeleted=0 and MTV.Isdeleted=0 AND
		(MTV.IsTicketDescriptionUpdated=1 OR MTV.IsResolutionRemarksUpdated=1
		OR MTV.IsTicketSummaryUpdated=1 OR MTV.IsCommentsUpdated=1
		OR MTV.IsFlexField1Updated=1 OR MTV.IsFlexField2Updated=1
		OR MTV.IsFlexField3Updated=1 OR MTV.IsFlexField4Updated=1
		OR MTV.IsCategoryUpdated=1 OR MTV.IsTypeUpdated=1)

		) x;

		SELECT DISTINCT ProjectID AS 'ProjectID' into
		#tblProject FROM #tblValues;

		SELECT * FROM #tblValues

		SELECT ML.ProjectID,LM.LanguageValue,PM.MSubscriptionKey AS 'Key' FROM MAS.MAS_LanguageMaster LM JOIN AVL.PRJ_MAP_MultilingualLanguage ML 
		ON LM.LanguageID=ML.LanguageID JOIN #tblProject tv JOIN Avl.MAS_ProjectMaster PM
		ON PM.ProjectID=tv.ProjectID ON tv.ProjectID=ML.ProjectID
		WHERE ML.Isdeleted=0 AND LM.IsDeleted=0 AND lm.LanguageID!=1 AND ML.LanguageID!=1
		AND PM.IsDeleted=0 ;

		IF OBJECT_ID('tempdb..#tblValues', 'U') IS NOT NULL
		BEGIN
       	DROP TABLE #tblValues
		END 

	SET NOCOUNT OFF;
END TRY

BEGIN CATCH
	DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetMultilingualTickets] ', @ErrorMessage, 0, 0 
END CATCH
END
