/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

			CREATE proc [dbo].[CheckForScreen] 
			@ProjectID int=null,
			@ITSMScreenID int=null,
			@CustomerID int=null
			as
			begin
			BEGIN TRY

			if(exists (select Id,CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,
			CreatedBy,CreatedDate,ModifiedBy,ModifiedDate from [AVL].[PRJ_ConfigurationProgress] where ITSMScreenId=@ITSMScreenID AND ProjectID=@ProjectID AND CustomerID=@CustomerID AND IsDeleted=0))
			BEGIN
			SELECT 1 as present
			END
			ELSE
			BEGIN
			select 0 as present
			END
			END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[CheckForScreen] ', @ErrorMessage, @ProjectID,@CustomerID
		
	END CATCH  



			end
