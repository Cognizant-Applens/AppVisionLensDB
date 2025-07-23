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
-- Author:		Menaka S
-- Create date: 3-6-2019
-- Description:	Gets the ticket summary description for the set of tickets
--MODIFICATION HISTORY
--USERID       USERNAME    DATE            REASON
--687591       Menaka S    28/6/2019       Included SupportTypeID

-- =============================================*/
CREATE PROCEDURE [AVL].[GetTicketSummaryDescriptionDetails_Multilingual_ByTicketID] 
@TicketID VARCHAR(150) ,
@ProjectID BIGINT,
@CogID VARCHAR(50)=NULL,
@SupportTypeID INT
AS
BEGIN
BEGIN TRY
IF(@SupportTypeID = 1 )
BEGIN
SELECT TD.TicketID,TD.TicketDescription,TD.TicketSummary FROM AVL.TK_TRN_TicketDetail TD
 
WHERE TD.ProjectID = @ProjectID AND TD.IsDeleted=0 AND TD.TicketID=@TicketID;
END
ELSE IF(@SupportTypeID = 2)
BEGIN
SELECT TD.TicketID,TD.TicketDescription,TD.TicketSummary FROM AVL.TK_TRN_InfraTicketDetail TD
 
WHERE TD.ProjectID = @ProjectID AND TD.IsDeleted=0 AND TD.TicketID=@TicketID;
END
END TRY

BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()

	--INSERT Error

	EXEC AVL_InsertError 'GetTicketSummaryDescriptionDetails_Multilingual_ByTicketID',@ErrorMessage,@CogID,@ProjectID
END CATCH


END
