/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

		
	CREATE PROCEDURE [ADM].[ALM_GetWorkItemIdAndTitleByWorkItemID]
	(
		@userId VARCHAR(50),
		@projectId BIGINT,
		@WorkItemId NVARCHAR(100) 
	)
	AS            
	BEGIN    
		BEGIN TRY       
			SET NOCOUNT ON  
			SELECT	WorkItem_Id + ' - ' + WorkItem_Title AS WorkItemIdTitle

			FROM	[ADM].[ALM_TRN_WorkItem_Details]
			WHERE	WorkItem_Id = @WorkItemId
					AND IsDeleted = 0

		
		END TRY 
		 BEGIN CATCH
		  DECLARE @ErrorMessage VARCHAR(MAX);
			SELECT @ErrorMessage = ERROR_MESSAGE()	
				EXEC AVL_InsertError '[ADM].[ALM_GetWorkItemIdAndTitleByWorkItemID] ', @ErrorMessage, @userId,@projectId
				RETURN @ErrorMessage
		  END CATCH 
	END
