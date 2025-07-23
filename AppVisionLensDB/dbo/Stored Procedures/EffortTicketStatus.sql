/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure [dbo].[EffortTicketStatus] 
@EmployeeId nvarchar(50)
as
begin
BEGIN TRY
select distinct TicketStatus_ID as StatusID,StatusName as StatusName from [AVL].TK_MAP_ProjectStatusMapping where projectId in 
(select ProjectId from [AVL].[MAS_LoginMaster] where EmployeeID=@EmployeeId)
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[dbo].[EffortTicketStatus]  ', @ErrorMessage, @EmployeeId,0
	END CATCH  
end
