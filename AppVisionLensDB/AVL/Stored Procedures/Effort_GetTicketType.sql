/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- [AVL].[Effort_GetTicketType] 48
CREATE PROCEDURE [AVL].[Effort_GetTicketType]
@ProjectId  int 
AS
BEGIN
BEGIN TRY

SELECT TTM.TicketTypeMappingID AS TicketTypeID,TTM.TicketType AS TicketTypeName FROM  [AVL].[TK_MAP_TicketTypeMapping] TTM
WHERE TTM.ProjectID=@ProjectId AND TTM.IsDeleted=0 AND (TTM.AVMTicketType not in (9,10,20) OR TTM.AVMTicketType IS NULL)

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Effort_GetTicketType] ', @ErrorMessage, @ProjectId,0
		
	END CATCH  
END

--SELECT * FROM [AVL].[TK_MAP_TicketTypeMapping]  WHERE ProjectID=48

--exec AVL.Effort_GetTicketType 2
