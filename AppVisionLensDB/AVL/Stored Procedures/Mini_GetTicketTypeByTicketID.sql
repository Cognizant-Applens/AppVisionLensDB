/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- Author:      Prakash     
-- Create date:      23 Nov 2018
-- Description:   get ticket type
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- [AVL].[Mini_GetNonDeliveryActivityByEmployeeID] '627384',7

-- ============================================================================ 

-- [AVL].[Mini_GetTicketTypeByTicketID]  'TICKETD1',10337
CREATE PROCEDURE [AVL].[Mini_GetTicketTypeByTicketID] 
(
@TicketID varchar(50),
@ProjectID varchar(50)
)
AS
BEGIN
BEGIN TRY
select td.TicketDescription as TicketDesc,td.TicketTypeMapID as TicketTypeID,tm.TicketType as TicketType 
from AVL.TK_TRN_TicketDetail(NOLOCK) TD
join AVL.TK_MAP_TicketTypeMapping TM ON
td.TicketTypeMapID=tm.TicketTypeMappingID
where TD.TicketID=@TicketID and TD.ProjectID=@ProjectID and ISNULL(TD.IsDeleted,0)=0 
and ISNULL(tm.IsDeleted,0)=0

		END TRY  

BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[Mini_GetTicketTypeByTicketID]', @ErrorMessage, '',0
END CATCH  

END
