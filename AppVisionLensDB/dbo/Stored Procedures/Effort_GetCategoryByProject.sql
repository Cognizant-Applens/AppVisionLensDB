/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Proc [dbo].[Effort_GetCategoryByProject]
@ApplicationID int=null--3
as 
begin
BEGIN TRY
select distinct SPM.CategoryID,SPM.CategoryName from AVL.TK_TRN_TicketDetail TD 
join AVL.APP_MAP_ApplicationProjectMapping APM on TD.ApplicationID=APM.ApplicationID
join AVL.TK_PRJ_ServiceProjectMapping SPM on APM.ProjectID=SPM.ProjectID where TD.ApplicationID=@ApplicationID
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[dbo].[Effort_GetCategoryByProject] ', @ErrorMessage, @ApplicationID,0
	END CATCH  
END


--exec Effort_GetCategoryByProject 3
--select * from AVL.APP_MAP_ApplicationProjectMapping

--select * from AVL.TK_TRN_TicketDetail

--select * from AVL.TK_PRJ_ServiceProjectMapping
