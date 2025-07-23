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
-- Create date: 8-5-2019
-- Description:	Gets the ticket summary description for the set of tickets
-- =============================================*/
CREATE PROCEDURE [AVL].[GetTicketSummaryDescriptionDetails_MultilingualInfra] 
@TicketID dbo.TVP_TicketID READONLY ,
@ProjectID BIGINT,
@CogID VARCHAR(50)
AS
BEGIN
BEGIN TRY
		-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT TD.TicketID,TD.TicketDescription,TD.TicketSummary FROM AVL.TK_TRN_TicketDetail TD
 WITH (NOLOCK) JOIN @TicketID TVP
ON TVP.TicketID=TD.TicketID AND TD.ProjectID=@ProjectID AND TD.IsDeleted=0;
		SET NOCOUNT OFF;
END TRY

BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()

	--INSERT Error

	EXEC AVL_InsertError 'AVL.GetTicketSummaryDescriptionDetails_MultilingualInfra',@ErrorMessage,@CogID,@ProjectID
END CATCH
END
