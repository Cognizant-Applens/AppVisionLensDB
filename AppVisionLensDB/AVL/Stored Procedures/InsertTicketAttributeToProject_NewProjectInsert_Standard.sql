/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[InsertTicketAttributeToProject_NewProjectInsert_Standard]
@ProjectID INT
AS
BEGIN

	 UPDATE [AVL].[MAS_ProjectMaster] SET TicketAttributeIntegartion = 1  where ProjectID = @ProjectID
	 
		IF NOT EXISTS(SELECT * FROM [AVL].[PRJ_StandardAttributeProjectStatusMaster] WHERE Projectid = @ProjectID AND IsDeleted = 0)
			BEGIN
				INSERT INTO [AVL].[PRJ_StandardAttributeProjectStatusMaster]
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
					TicketMasterFields 
				FROM [AVL].[MAS_StandardAttributeStatusMaster] where IsDeleted = 0 
			END
			ELSE IF EXISTS (SELECT * FROM [AVL].[PRJ_StandardAttributeProjectStatusMaster] WHERE Projectid = @ProjectID AND IsDeleted = 0)
			BEGIN
				IF NOT EXISTS(SELECT * FROM [AVL].[PRJ_StandardAttributeProjectStatusMaster] WHERE Projectid = @ProjectID and AttributeID = 89 AND IsDeleted = 0)
				BEGIN
					INSERT INTO [AVL].[PRJ_StandardAttributeProjectStatusMaster]
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
						TicketMasterFields 
					FROM [AVL].[MAS_StandardAttributeStatusMaster] WHERE AttributeID = 89 and IsDeleted = 0 
				END
				IF NOT EXISTS(SELECT * FROM [AVL].[PRJ_StandardAttributeProjectStatusMaster] WHERE Projectid = @ProjectID and AttributeID = 90 and IsDeleted = 0)
				BEGIN
					INSERT INTO [AVL].[PRJ_StandardAttributeProjectStatusMaster]
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
						TicketMasterFields 
					FROM [AVL].[MAS_StandardAttributeStatusMaster] WHERE AttributeID = 90 and IsDeleted = 0 
				END
			END
	 
END
