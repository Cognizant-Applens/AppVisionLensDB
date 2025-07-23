/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[Effort_GetNonTicketActivityService]  

@ProjectID int=null  

AS
BEGIN
begin try  
select

DISTINCT SPM.ProjectID,SPM.ServiceID,SPM.ServiceName from AVL.TK_PRJ_ServiceProjectMapping SPM
where SPM.ProjectID=@ProjectID AND SPM.ServiceID=41
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Effort_GetNonTicketActivityService] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  
END
