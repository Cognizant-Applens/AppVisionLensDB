/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure [AVL].[KEDB_DeleteKA] 
(
 @KAID bigint	,
 @ProjectID bigint ,
 @UserId nvarchar(50)  
 )

AS
BEGIN	
	BEGIN TRY
		SET NOCOUNT ON;						
		
		UPDATE [AVL].[KEDB_TRN_KATicketDetails] SET IsDeleted = 1, ModifiedBy = @Userid, ModifiedOn = GETDATE()
		WHERE KAId = @KAID AND ProjectId = @ProjectID					

		UPDATE [AVL].[KEDB_TRN_KATicketActivityDetails] SET IsDeleted = 1, ModifiedBy = @Userid, ModifiedOn = GETDATE() WHERE kaid = @KAID						

		UPDATE [AVL].[KEDB_TRN_KARating_MapTicketId] SET IsDeleted = 1, ModifiedBy = @Userid, ModifiedOn = GETDATE()
		WHERE KAId = @KAID AND ProjectId = @ProjectID

		UPDATE [AVL].[KEDB_TRN_KATicketLinkDetails] SET IsDeleted = 1, ModifiedBy = @Userid, ModifiedOn = GETDATE() WHERE KAId = @KAID				

		UPDATE [AVL].[KEDB_TRN_KAServiceMapping] SET IsDeleted = 1 ,ModifiedBy = @Userid, ModifiedOn = GETDATE() 
		WHERE KAId = @KAID

		UPDATE [AVL].[KEDB_TRN_KTicketMapping] SET IsDeleted = 1, ModifiedBy = @Userid, ModifiedOn = GETDATE() 
		FROM [AVL].[KEDB_TRN_KATicketDetails] td join avl.KEDB_TRN_KTicketMapping TM 
		on td.KATicketID = tm.KATicketId 
		WHERE KAID = @KAID AND TM.ProjectId = @ProjectID

		INSERT INTO [AVL].[KEDB_AuditWorkLog]
		SELECT  @KAID,@ProjectID,'Deleted','',@UserId,GETDATE()  


	END TRY

	BEGIN CATCH

			DECLARE @ErrorMessage VARCHAR(MAX);

			SELECT @ErrorMessage = ERROR_MESSAGE()

			--INSERT Error    
			EXEC AVL_InsertError '[AVL].[KEDB_DeleteKA]', @ErrorMessage, 0,0


	END CATCH
		 
END
