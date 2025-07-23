/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[GetTicketType] --4
@ProjectId  int 
AS
BEGIN
BEGIN TRY

select TT.TicketTypeID ,TT.TicketTypeName from [AVL].[TK_MAS_TicketType] TT
join [AVL].[TK_MAP_TicketTypeMapping] TTM ON TT.TicketTypeID=TTM.AVMTicketType WHERE TTM.ProjectId=@ProjectId

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[GetTicketType] ', @ErrorMessage, @ProjectId,0
		
	END CATCH  



END





--select * from [AVL].[TK_MAS_TicketType]
--select * from [AVL].[TK_MAP_TicketTypeMapping]


--update [AVL].[TK_MAP_TicketTypeMapping]

--select * from [AVL].[MAS_ProjectMaster]
