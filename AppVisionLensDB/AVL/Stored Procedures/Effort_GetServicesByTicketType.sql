/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure [AVL].[Effort_GetServicesByTicketType]
@TicketTypeID int=null,
@IsDart int=null
as
begin
BEGIN TRY
	SELECT SPM.ServiceID,SPM.ServiceName FROM AVL.TK_PRJ_ServiceProjectMapping SPM
	left join AVL.TK_MAP_TicketTypeServiceMapping TTSM on TTSM.ServiceID=SPM.ServiceID
	left JOIN AVL.TK_MAP_TicketTypeMapping TTM on TTM.TicketTypeMappingID=TTSM.TicketTypeMappingID
	left join AVL.TK_MAS_TicketType TT on TT.TicketTypeName=TTM.TicketType
	where TT.TicketTypeID=@TicketTypeID and TTSM.IsDart=@IsDart
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Effort_GetServicesByTicketType]', @ErrorMessage, 0,0
		
	END CATCH  
END
