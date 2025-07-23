/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[InsertTicketAttributeToProject_NewProjectInsert_Mainspring]
@ProjectID INT
AS
BEGIN
BEGIN TRY
BEGIN TRAN

	 UPDATE [AVL].[MAS_ProjectMaster] SET TicketAttributeIntegartion = 2  where ProjectID = @ProjectID
	 
		IF NOT EXISTS(SELECT * FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] WHERE Projectid = @ProjectID)
			BEGIN
				INSERT INTO [AVL].[PRJ_MainspringAttributeProjectStatusMaster]
				SELECT
					ServiceID,
					ServiceName,
					AttributeID,
					AttributeName,
					StatusID,
					StatusName,
					FieldType,
					GETDATE(),
					'Admin',
					NULL,
					NULL,
					IsDeleted,
					@ProjectID,
					TicketDetailFields 
				FROM [AVL].[MAS_MainspringAttributeStatusMaster] where IsDeleted = 0
			END
			ELSE IF EXISTS (SELECT * FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] WHERE Projectid = @ProjectID)
			BEGIN
				IF NOT EXISTS(SELECT * FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] WHERE Projectid = @ProjectID and AttributeID = 89)
				BEGIN
					INSERT INTO [AVL].[PRJ_MainspringAttributeProjectStatusMaster]
					SELECT
						ServiceID,
						ServiceName,
						AttributeID,
						AttributeName,
						StatusID,
						StatusName,
						FieldType,
						GETDATE(),
						'Admin',
						NULL,
						NULL,
						IsDeleted,
						@ProjectID,
						TicketDetailFields 
					FROM [AVL].[MAS_MainspringAttributeStatusMaster] WHERE AttributeID = 89 and IsDeleted = 0
				END
				IF NOT EXISTS(SELECT * FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] WHERE Projectid = @ProjectID and AttributeID = 90)
				BEGIN
					INSERT INTO [AVL].[PRJ_MainspringAttributeProjectStatusMaster]
					SELECT
						ServiceID,
						ServiceName,
						AttributeID,
						AttributeName,
						StatusID,
						StatusName,
						FieldType,
						GETDATE(),
						'Admin',
						NULL,
						NULL,
						IsDeleted,
			     		@ProjectID,
						TicketDetailFields 
					FROM [AVL].[MAS_MainspringAttributeStatusMaster] WHERE AttributeID = 90 and IsDeleted = 0
				END
			END	
			COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[InsertTicketAttributeToProject_NewProjectInsert_Mainspring]', 
@ErrorMessage, @ProjectID ,0
		
	END CATCH   
END
