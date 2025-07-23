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
-- Create date: 15-5-2019
-- Description: Updates the translated values
-- =============================================*/
CREATE PROCEDURE [AVL].[UpdateMultilingualTranslatedTickets]
AS
BEGIN
BEGIN TRY
		-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--SELECT * FROM AVL.MultilingualTickets;
BEGIN TRAN
UPDATE 
  MLV 
SET 
  MLV.TicketDescription = CASE WHEN (
    MLV.IsTicketDescriptionUpdated = 1 
    AND MT.HasTicketDescriptionError = 0
  ) THEN MT.TicketDescription ELSE MLV.TicketDescription END, 
  MLV.IsTicketDescriptionUpdated = CASE WHEN (
    MLV.IsTicketDescriptionUpdated = 1 
    AND MT.HasTicketDescriptionError = 0
  ) THEN 0
	ELSE MLV.IsTicketDescriptionUpdated END, 
  MLV.ResolutionRemarks = CASE WHEN (
    MLV.IsResolutionRemarksUpdated = 1 
    AND MT.HasResolutionRemarksError = 0
  ) THEN MT.ResolutionRemarks ELSE MLV.ResolutionRemarks END, 
  MLV.IsResolutionRemarksUpdated = CASE WHEN(
    MLV.IsResolutionRemarksUpdated = 1 
    AND MT.HasResolutionRemarksError = 0
  ) THEN 0 ELSE MLV.IsResolutionRemarksUpdated END, 
  MLV.TicketSummary = CASE WHEN (
    MLV.IsTicketSummaryUpdated = 1 
    AND MT.HasTicketSummaryError = 0
  ) THEN MT.TicketSummary ELSE MLV.TicketSummary END, 
  MLV.IsTicketSummaryUpdated = CASE WHEN(
    MLV.IsTicketSummaryUpdated = 1 
    AND MT.HasTicketSummaryError = 0
  ) THEN 0 ELSE MLV.IsTicketSummaryUpdated END, 
  MLV.Comments = CASE WHEN (
    MLV.IsCommentsUpdated = 1 
    AND MT.HasCommentsError = 0
  ) THEN MT.Comments ELSE MLV.Comments END, 
  MLV.IsCommentsUpdated = CASE WHEN(
    MLV.IsCommentsUpdated = 1 
    AND MT.HasCommentsError = 0
  ) THEN 0 ELSE MLV.IsCommentsUpdated END, 
  MLV.FlexField1 = CASE WHEN(
    MLV.IsFlexField1Updated = 1 
    AND MT.HasFlexField1Error = 0
  ) THEN MT.FlexField1 ELSE MLV.FlexField1 END, 
  MLV.IsFlexField1Updated = CASE WHEN(
    MLV.IsFlexField1Updated = 1 
    AND MT.HasFlexField1Error = 0
  ) THEN 0 ELSE MLV.IsFlexField1Updated END, 
  MLV.FlexField2 = CASE WHEN(
    MLV.IsFlexField2Updated = 1 
    AND MT.HasFlexField2Error = 0
  ) THEN MT.FlexField2 ELSE MLV.FlexField2 END, 
  MLV.IsFlexField2Updated = CASE WHEN(
    MLV.IsFlexField2Updated = 1 
    AND MT.HasFlexField2Error = 0
  ) THEN 0 ELSE MLV.IsFlexField2Updated END, 
  MLV.FlexField3 = CASE WHEN(
    MLV.IsFlexField3Updated = 1 
    AND MT.HasFlexField3Error = 0
  ) THEN MT.FlexField3 ELSE MLV.FlexField3 END, 
  MLV.IsFlexField3Updated = CASE WHEN(
    MLV.IsFlexField3Updated = 1 
    AND MT.HasFlexField3Error = 0
  ) THEN 0  ELSE MLV.IsFlexField3Updated END, 
  MLV.FlexField4 = CASE WHEN(
    MLV.IsFlexField4Updated = 1 
    AND MT.HasFlexField4Error = 0
  ) THEN MT.FlexField4 ELSE MLV.FlexField4 END, 
  MLV.IsFlexField4Updated = CASE WHEN(
    MLV.IsFlexField4Updated = 1 
    AND MT.HasFlexField4Error = 0
  ) THEN 0 ELSE MLV.IsFlexField4Updated END, 
  MLV.Category = CASE WHEN(
    MLV.IsCategoryUpdated = 1 
    AND MT.HasCategoryError = 0
  ) THEN MT.Category ELSE MLV.Category END, 
  MLV.IsCategoryUpdated = CASE WHEN(
    MLV.IsCategoryUpdated = 1 
    AND MT.HasCategoryError = 0
  ) THEN 0 ELSE MLV.IsCategoryUpdated END, 
  MLV.Type = CASE WHEN(
    MLV.IsTypeUpdated = 1 
    AND MT.HasTypeError = 0
  ) THEN MT.Type ELSE MLV.Type END, 
  MLV.IsTypeUpdated = CASE WHEN(
    MLV.IsTypeUpdated = 1 
    AND MT.HasTypeError = 0
  ) THEN 0 ELSE MLV.IsTypeUpdated END, 
  ModifiedBy = MT.CreatedBy, 
  ModifiedDate = GETDATE() 
FROM 
  AVL.TK_TRN_Multilingual_TranslatedTicketDetails MLV 
  JOIN [AVL].[MultilingualTickets] MT ON MLV.TimeTickerID = MT.TimeTickerID AND MT.TicketType=1
WHERE 
  MLV.Isdeleted = 0;



  UPDATE 
  MLV 
SET 
  MLV.TicketDescription = CASE WHEN (
    MLV.IsTicketDescriptionUpdated = 1 
    AND MT.HasTicketDescriptionError = 0
  ) THEN MT.TicketDescription ELSE MLV.TicketDescription END, 
  MLV.IsTicketDescriptionUpdated = CASE WHEN (
    MLV.IsTicketDescriptionUpdated = 1 
    AND MT.HasTicketDescriptionError = 0
  ) THEN 0
	ELSE MLV.IsTicketDescriptionUpdated END, 
  MLV.ResolutionRemarks = CASE WHEN (
    MLV.IsResolutionRemarksUpdated = 1 
    AND MT.HasResolutionRemarksError = 0
  ) THEN MT.ResolutionRemarks ELSE MLV.ResolutionRemarks END, 
  MLV.IsResolutionRemarksUpdated = CASE WHEN(
    MLV.IsResolutionRemarksUpdated = 1 
    AND MT.HasResolutionRemarksError = 0
  ) THEN 0 ELSE MLV.IsResolutionRemarksUpdated END, 
  MLV.TicketSummary = CASE WHEN (
    MLV.IsTicketSummaryUpdated = 1 
    AND MT.HasTicketSummaryError = 0
  ) THEN MT.TicketSummary ELSE MLV.TicketSummary END, 
  MLV.IsTicketSummaryUpdated = CASE WHEN(
    MLV.IsTicketSummaryUpdated = 1 
    AND MT.HasTicketSummaryError = 0
  ) THEN 0 ELSE MLV.IsTicketSummaryUpdated END, 
  MLV.Comments = CASE WHEN (
    MLV.IsCommentsUpdated = 1 
    AND MT.HasCommentsError = 0
  ) THEN MT.Comments ELSE MLV.Comments END, 
  MLV.IsCommentsUpdated = CASE WHEN(
    MLV.IsCommentsUpdated = 1 
    AND MT.HasCommentsError = 0
  ) THEN 0 ELSE MLV.IsCommentsUpdated END, 
  MLV.FlexField1 = CASE WHEN(
    MLV.IsFlexField1Updated = 1 
    AND MT.HasFlexField1Error = 0
  ) THEN MT.FlexField1 ELSE MLV.FlexField1 END, 
  MLV.IsFlexField1Updated = CASE WHEN(
    MLV.IsFlexField1Updated = 1 
    AND MT.HasFlexField1Error = 0
  ) THEN 0 ELSE MLV.IsFlexField1Updated END, 
  MLV.FlexField2 = CASE WHEN(
    MLV.IsFlexField2Updated = 1 
    AND MT.HasFlexField2Error = 0
  ) THEN MT.FlexField2 ELSE MLV.FlexField2 END, 
  MLV.IsFlexField2Updated = CASE WHEN(
    MLV.IsFlexField2Updated = 1 
    AND MT.HasFlexField2Error = 0
  ) THEN 0 ELSE MLV.IsFlexField2Updated END, 
  MLV.FlexField3 = CASE WHEN(
    MLV.IsFlexField3Updated = 1 
    AND MT.HasFlexField3Error = 0
  ) THEN MT.FlexField3 ELSE MLV.FlexField3 END, 
  MLV.IsFlexField3Updated = CASE WHEN(
    MLV.IsFlexField3Updated = 1 
    AND MT.HasFlexField3Error = 0
  ) THEN 0  ELSE MLV.IsFlexField3Updated END, 
  MLV.FlexField4 = CASE WHEN(
    MLV.IsFlexField4Updated = 1 
    AND MT.HasFlexField4Error = 0
  ) THEN MT.FlexField4 ELSE MLV.FlexField4 END, 
  MLV.IsFlexField4Updated = CASE WHEN(
    MLV.IsFlexField4Updated = 1 
    AND MT.HasFlexField4Error = 0
  ) THEN 0 ELSE MLV.IsFlexField4Updated END, 
  MLV.Category = CASE WHEN(
    MLV.IsCategoryUpdated = 1 
    AND MT.HasCategoryError = 0
  ) THEN MT.Category ELSE MLV.Category END, 
  MLV.IsCategoryUpdated = CASE WHEN(
    MLV.IsCategoryUpdated = 1 
    AND MT.HasCategoryError = 0
  ) THEN 0 ELSE MLV.IsCategoryUpdated END, 
  MLV.Type = CASE WHEN(
    MLV.IsTypeUpdated = 1 
    AND MT.HasTypeError = 0
  ) THEN MT.Type ELSE MLV.Type END, 
  MLV.IsTypeUpdated = CASE WHEN(
    MLV.IsTypeUpdated = 1 
    AND MT.HasTypeError = 0
  ) THEN 0 ELSE MLV.IsTypeUpdated END, 
  ModifiedBy = MT.CreatedBy, 
  ModifiedDate = GETDATE() 
FROM 
  AVL.TK_TRN_Multilingual_TranslatedInfraTicketDetails MLV 
  JOIN [AVL].[MultilingualTickets] MT ON MLV.TimeTickerID = MT.TimeTickerID AND MT.TicketType=2
WHERE 
  MLV.Isdeleted = 0;


--SELECT MTV.ReferenceID INTO #TblRefID FROM AVL.MultilingualTickets MT JOIN AVL.[PRJ.MultilingualTranslatedValues] MTV 
--ON MTV.TimeTickerID=MT.TimeTickerID WHERE MTV.Isdeleted=0 AND MTV.TicketCreatedType=4 
--AND MTV.IsTicketDescriptionUpdated=0 AND MTV.IsResolutionRemarksUpdated=0 AND
--MTV.IsTicketSummaryUpdated=0 AND MTV.IsCommentsUpdated=0 AND 
--MTV.IsFlexField1Updated=0 AND MTV.IsFlexField2Updated=0 AND
--MTV.IsFlexField3Updated=0 AND MTV.IsFlexField4Updated=0 AND
--MTV.IsCategoryUpdated=0 AND MTV.IsTypeUpdated=0;

--UPDATE T1 SET T1.IsMultiLingualTranslated=1 FROM  AVL.ML_PRJ_InitialLearningState T1 JOIN #TblRefID T2 ON T1.ID=T2.ReferenceID
-- WHERE T1.IsDeleted=0;

COMMIT TRAN;
DELETE FROM AVL.MultilingualTickets;
	SET NOCOUNT OFF;
END TRY

BEGIN CATCH
ROLLBACK TRAN;
 DECLARE @ErrorMessage VARCHAR(MAX);  
 DELETE FROM AVL.MultilingualTickets ;
	  SELECT @ErrorMessage = ERROR_MESSAGE()  
	  --INSERT Error      
	  EXEC AVL_InsertError 'AVL.CheckIfMultilingualEnabled', @ErrorMessage, 0, 0  
END CATCH
END
