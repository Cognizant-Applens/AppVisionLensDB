/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[SP_DataMigration_InsertTicketAttributes]
(
	@ProjectID BIGINT,
	@UserID VARCHAR(10)
)
AS
BEGIN
	BEGIN TRY

		DECLARE @IsMainspring CHAR(1);
		DECLARE @IsDebt CHAR(1);

		SET @IsMainspring = (SELECT ISNULL(IsMainSpringConfigured, 'N') FROM AVL.MAS_ProjectMaster (NOLOCK) WHERE ProjectID = @ProjectID)
		SET @IsDebt = (SELECT ISNULL(IsDebtEnabled, 'N') FROM AVL.MAS_ProjectMaster (NOLOCK) WHERE ProjectID = @ProjectID)

		DELETE FROM AVL.PRJ_StandardAttributeProjectStatusMaster WHERE PROJECTID = @ProjectID
		DELETE FROM AVL.PRJ_MainspringAttributeProjectStatusMaster WHERE PROJECTID = @ProjectID

		IF @IsMainspring = 'N' AND @IsDebt = 'N'
		BEGIN

			INSERT INTO AVL.PRJ_StandardAttributeProjectStatusMaster
			(
				ServiceID, ServiceName, AttributeID, AttributeName, StatusID, StatusName, FieldType,
				CreatedDate, CreatedBy, ModifiedDate, ModifiedBy, IsDeleted, Projectid, TicketMasterFields
			)
			SELECT ServiceID, ServiceName, AttributeID, AttributeName, StatusID, StatusName,
				FieldType, GETDATE(), @UserID, NULL, NULL, IsDeleted, @ProjectID, TicketMasterFields 
			FROM AVL.MAS_StandardAttributeStatusMaster (NOLOCK)

		END

		ELSE IF @IsMainspring ='Y' AND @IsDebt ='N'
		BEGIN

			INSERT INTO AVL.PRJ_MainspringAttributeProjectStatusMaster
			(
				ServiceID, ServiceName, AttributeID, AttributeName, StatusID, StatusName, FieldType,
				CreatedDateTime, CreatedBy, ModifiedDateTime, ModifiedBy, IsDeleted, Projectid, TicketMasterFields
			)
			SELECT ServiceID, ServiceName, AttributeID, AttributeName, StatusID, StatusName,
				FieldType, GETDATE(), @UserID, NULL, NULL, IsDeleted, @ProjectID, TicketDetailFields 
			FROM AVL.MAS_MainspringAttributeStatusMaster (NOLOCK)

		END

		ELSE IF @IsMainspring ='N' AND @IsDebt = 'Y'
		BEGIN

			INSERT INTO AVL.PRJ_StandardAttributeProjectStatusMaster
			(
				ServiceID, ServiceName, AttributeID, AttributeName, StatusID, StatusName, FieldType,
				CreatedDate, CreatedBy, ModifiedDate, ModifiedBy, IsDeleted, Projectid, TicketMasterFields
			)
			SELECT ServiceID, ServiceName, AttributeID, AttributeName, StatusID, StatusName,
				FieldType, GETDATE(), @UserID, NULL, NULL, IsDeleted, @ProjectID, TicketMasterFields 
			FROM AVL.MAS_StandardAttributeStatusMaster (NOLOCK)

			UPDATE A SET A.FieldType = D.FieldType
			FROM AVL.PRJ_StandardAttributeProjectStatusMaster (NOLOCK) A
			JOIN AVL.MAS_DebtAttributeStatusMaster (NOLOCK) D
				ON A.ServiceID = D.ServiceID AND A.AttributeID = D.AttributeID AND A.StatusID = D.StatusID 
			WHERE A.Projectid = @ProjectID AND A.FieldType <> 'M'

		END
		ELSE IF @IsMainspring = 'Y' AND @IsDebt = 'Y'
		BEGIN
	
			INSERT INTO AVL.PRJ_MainspringAttributeProjectStatusMaster
			(
				ServiceID, ServiceName, AttributeID, AttributeName, StatusID, StatusName, FieldType,
				CreatedDateTime, CreatedBy, ModifiedDateTime, ModifiedBy, IsDeleted, Projectid, TicketMasterFields
			)
			SELECT ServiceID, ServiceName, AttributeID, AttributeName, StatusID, StatusName,
				FieldType, GETDATE(), @UserID, NULL, NULL, IsDeleted, @ProjectID, TicketDetailFields 
			FROM AVL.MAS_MainspringAttributeStatusMaster (NOLOCK)


			UPDATE A SET A.FieldType = D.FieldType
			FROM AVL.PRJ_MainspringAttributeProjectStatusMaster (NOLOCK) A
			JOIN AVL.MAS_DebtAttributeStatusMaster (NOLOCK) D
				ON A.ServiceID = D.ServiceID AND A.AttributeID = D.AttributeID AND A.StatusID = D.StatusID 
			WHERE A.Projectid = @ProjectID AND A.FieldType <> 'M'

		END
		ELSE
		BEGIN

			INSERT INTO AVL.PRJ_StandardAttributeProjectStatusMaster
			(
				ServiceID, ServiceName, AttributeID, AttributeName, StatusID, StatusName, FieldType,
				CreatedDate, CreatedBy, ModifiedDate, ModifiedBy, IsDeleted, Projectid, TicketMasterFields
			)
			SELECT ServiceID, ServiceName, AttributeID, AttributeName, StatusID, StatusName,
				FieldType, GETDATE(), @UserID, NULL, NULL, IsDeleted, @ProjectID, TicketMasterFields 
			FROM AVL.MAS_StandardAttributeStatusMaster (NOLOCK)

		END

	END TRY  
	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError 'SP_DataMigration_InsertTicketAttributes', @ErrorMessage, @ProjectID, @UserID 
		
	END CATCH  
END
