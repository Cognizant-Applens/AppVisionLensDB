/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[Effort_GetIsSaveOrSubmitOfTicket]
@TimesheetID bigint=0
as 
begin
BEGIN TRY
	select StatusId from AVL.TM_PRJ_Timesheet where TimesheetId=@TimesheetID
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Effort_GetIsSaveOrSubmitOfTicket] ', @ErrorMessage, 0,0
		
	END CATCH  
END
