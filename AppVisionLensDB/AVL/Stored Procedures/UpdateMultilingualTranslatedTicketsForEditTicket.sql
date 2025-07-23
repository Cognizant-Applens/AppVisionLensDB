/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[UpdateMultilingualTranslatedTicketsForEditTicket]

@MultiLingualTable dbo.TVP_EditTicketMultiLingual READONLY

AS


BEGIN
BEGIN TRY
		-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

BEGIN TRAN
IF EXISTS(SELECT TICKETTYPE FROM  @MultiLingualTable WHERE TICKETTYPE = 1)
BEGIN
UPDATE 
  MLV 
SET 

  MLV.TicketDescription = CASE WHEN ISNULL(MT.TicketDescription,'') ='' AND ISNULL(TD.TicketDescription,'')  <> '' AND 
                          MT.HasTicketDescriptionError = 0 THEN MLV.TicketDescription ELSE MT.TicketDescription END,
  MLV.IsTicketDescriptionUpdated = MT.IsTicketDescriptionUpdated,

  MLV.ResolutionRemarks = CASE WHEN ISNULL(MT.ResolutionRemarks,'') ='' AND ISNULL(TD.ResolutionRemarks,'')  <> '' AND 
                          MT.HasResolutionRemarksError = 0 THEN MLV.ResolutionRemarks ELSE MT.ResolutionRemarks END,
  MLV.IsResolutionRemarksUpdated = MT.IsResolutionRemarksUpdated ,

  MLV.TicketSummary = CASE WHEN ISNULL(MT.TicketSummary,'') ='' AND ISNULL(TD.TicketSummary,'')  <> '' AND 
                          MT.HasTicketSummaryError = 0 THEN MLV.TicketSummary ELSE MT.TicketSummary END,  
  MLV.IsTicketSummaryUpdated = MT.IsTicketSummaryUpdated,

  MLV.Comments = CASE WHEN ISNULL(MT.Comments,'') ='' AND ISNULL(TD.Comments,'')  <> '' AND 
                          MT.HasCommentsError = 0 THEN MLV.Comments ELSE MT.Comments END, 

  MLV.IsCommentsUpdated = MT.IsCommentsUpdated,

  MLV.FlexField1 = CASE WHEN ISNULL(MT.FlexField1,'') ='' AND ISNULL(TD.FlexField1,'')  <> '' AND 
                          MT.HasFlexField1Error = 0 THEN MLV.FlexField1 ELSE MT.FlexField1 END , 

  MLV.IsFlexField1Updated = MT.IsFlexField1Updated,

  MLV.FlexField2 = CASE WHEN ISNULL(MT.FlexField2,'') ='' AND ISNULL(TD.FlexField2,'')  <> '' AND 
                          MT.HasFlexField2Error = 0 THEN MLV.FlexField2 ELSE MT.FlexField2 END ,  

  MLV.IsFlexField2Updated = MT.IsFlexField2Updated,

  MLV.FlexField3 =  CASE WHEN ISNULL(MT.FlexField3,'') ='' AND ISNULL(TD.FlexField3,'')  <> '' AND 
                          MT.HasFlexField3Error = 0 THEN MLV.FlexField3 ELSE MT.FlexField3 END ,  

  MLV.IsFlexField3Updated = MT.IsFlexField3Updated,

  MLV.FlexField4 = CASE WHEN ISNULL(MT.FlexField4,'') ='' AND ISNULL(TD.FlexField4,'')  <> '' AND 
                          MT.HasFlexField4Error = 0 THEN MLV.FlexField4 ELSE MT.FlexField4 END ,  

  MLV.IsFlexField4Updated = MT.IsFlexField4Updated,
  MLV.Category = MT.Category , 
  MLV.IsCategoryUpdated = MT.IsCategoryUpdated,
  MLV.Type = MT.Type , 
  MLV.IsTypeUpdated = MT.IsTypeUpdated,
  ModifiedDate = GETDATE() 
FROM 
  AVL.TK_TRN_Multilingual_TranslatedTicketDetails MLV 
  JOIN @MultiLingualTable MT ON MLV.TimeTickerID = MT.TimeTickerID AND MT.TicketType=1
  INNER JOIN [AVL].[TK_TRN_TicketDetail] TD 
  ON TD.TimeTickerID = MLV.TimeTickerID 
WHERE 
  ISNULL(MLV.Isdeleted,0) = 0;

  END
  ELSE
  BEGIN

  UPDATE 
  MLV 
SET 
  MLV.TicketDescription = CASE WHEN ISNULL(MT.TicketDescription,'') ='' AND ISNULL(TD.TicketDescription,'')  <> '' AND 
                          MT.HasTicketDescriptionError = 0 THEN MLV.TicketDescription ELSE MT.TicketDescription END,
  MLV.IsTicketDescriptionUpdated = MT.IsTicketDescriptionUpdated,

  MLV.ResolutionRemarks = CASE WHEN ISNULL(MT.ResolutionRemarks,'') ='' AND ISNULL(TD.ResolutionRemarks,'')  <> '' AND 
                          MT.HasResolutionRemarksError = 0 THEN MLV.ResolutionRemarks ELSE MT.ResolutionRemarks END,
  MLV.IsResolutionRemarksUpdated = MT.IsResolutionRemarksUpdated ,

  MLV.TicketSummary = CASE WHEN ISNULL(MT.TicketSummary,'') ='' AND ISNULL(TD.TicketSummary,'')  <> '' AND 
                          MT.HasTicketSummaryError = 0 THEN MLV.TicketSummary ELSE MT.TicketSummary END,  
  MLV.IsTicketSummaryUpdated = MT.IsTicketSummaryUpdated,

  MLV.Comments = CASE WHEN ISNULL(MT.Comments,'') ='' AND ISNULL(TD.Comments,'')  <> '' AND 
                          MT.HasCommentsError = 0 THEN MLV.Comments ELSE MT.Comments END, 

  MLV.IsCommentsUpdated = MT.IsCommentsUpdated,

  MLV.FlexField1 = CASE WHEN ISNULL(MT.FlexField1,'') ='' AND ISNULL(TD.FlexField1,'')  <> '' AND 
                          MT.HasFlexField1Error = 0 THEN MLV.FlexField1 ELSE MT.FlexField1 END , 

  MLV.IsFlexField1Updated = MT.IsFlexField1Updated,

  MLV.FlexField2 = CASE WHEN ISNULL(MT.FlexField2,'') ='' AND ISNULL(TD.FlexField2,'')  <> '' AND 
                          MT.HasFlexField2Error = 0 THEN MLV.FlexField2 ELSE MT.FlexField2 END ,  

  MLV.IsFlexField2Updated = MT.IsFlexField2Updated,

  MLV.FlexField3 =  CASE WHEN ISNULL(MT.FlexField3,'') ='' AND ISNULL(TD.FlexField3,'')  <> '' AND 
                          MT.HasFlexField3Error = 0 THEN MLV.FlexField3 ELSE MT.FlexField3 END ,  

  MLV.IsFlexField3Updated = MT.IsFlexField3Updated,

  MLV.FlexField4 = CASE WHEN ISNULL(MT.FlexField4,'') ='' AND ISNULL(TD.FlexField4,'')  <> '' AND 
                          MT.HasFlexField4Error = 0 THEN MLV.FlexField4 ELSE MT.FlexField4 END ,  

  MLV.IsFlexField4Updated = MT.IsFlexField4Updated,
  MLV.Category = MT.Category , 
  MLV.IsCategoryUpdated = MT.IsCategoryUpdated,
  MLV.Type = MT.Type , 
  MLV.IsTypeUpdated = MT.IsTypeUpdated,
  ModifiedDate = GETDATE() 
FROM 
  AVL.TK_TRN_Multilingual_TranslatedInfraTicketDetails MLV 
  JOIN  @MultiLingualTable MT  ON MLV.TimeTickerID = MT.TimeTickerID AND MT.TicketType=2
  INNER JOIN [AVL].TK_TRN_InfraTicketDetail TD 
  ON TD.TimeTickerID = MLV.TimeTickerID 
  
WHERE 
  ISNULL(MLV.Isdeleted,0) = 0
  END
  select * from @MultiLingualTable
COMMIT TRAN;

	SET NOCOUNT OFF;
END TRY

BEGIN CATCH
ROLLBACK TRAN;
 DECLARE @ErrorMessage VARCHAR(MAX);  
 DELETE FROM AVL.MultilingualTickets ;
	  SELECT @ErrorMessage = ERROR_MESSAGE()  
	  --INSERT Error      
	  EXEC AVL_InsertError 'UpdateMultilingualTranslatedTicketsForEditTicket', @ErrorMessage, 0, 0  
END CATCH
END
