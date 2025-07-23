/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =====================================================================================================================
-- Author      : Manoj, Shobana
-- Create date : 07 Jan 2019
-- Description : Procedure to insert or update mandatory attributes based on Is Debt Enabled and Is Mainspring Enabled               
-- Test        : [dbo].[AutoDebt_InsertTicketAttributes] 37857, 'Y'
-- Revision    :
-- Revised By  :
-- =====================================================================================================================
CREATE PROCEDURE [dbo].[AutoDebt_InsertTicketAttributes]
(
	@ProjectID INT,
	@IsMainspring CHAR 
)
AS
BEGIN
	BEGIN TRY

		-- If Mainspring Enabled is 'No' and Is Debt Enabled is 'Yes' (As we are enabling the debt, we are not checking the condition)
		IF @IsMainspring = 'N'
		BEGIN

			-- If the given project is not present in Standard Attribute Project Status Master
			IF NOT EXISTS (SELECT ProjectId FROM AVL.PRJ_StandardAttributeProjectStatusMaster WHERE ProjectId = @ProjectId and IsDeleted=0)
			BEGIN

				-- Insert all the data from Standard Attribute Status Master to Standard Attribute Project Status Master for the given project
				INSERT INTO AVL.PRJ_StandardAttributeProjectStatusMaster
				(
					ServiceID,
					ServiceName,
					AttributeID,
					AttributeName,
					StatusID,
					StatusName,
					FieldType,
					CreatedDate,
					CreatedBy,
					ModifiedDate,
					ModifiedBy,
					IsDeleted,
					Projectid,
					TicketMasterFields
				)
				SELECT
						SASM.ServiceID,
						SASM.ServiceName,
						SASM.AttributeID,
						SASM.AttributeName,
						SASM.StatusID,
						SASM.StatusName,
						SASM.FieldType,
						GETDATE(), -- CreatedDate
						'System', -- CreatedBy
						NULL, -- ModifiedDate
						NULL, -- ModifiedBy
						SASM.IsDeleted,
						@ProjectID, 
						SASM.TicketMasterFields
				FROM AVL.MAS_StandardAttributeStatusMaster (NOLOCK) SASM
				where IsDeleted=0

			END

			-- Update the Mandatory Attributes in Standard Attribute Project Status Master from Debt Attribute Status Master
			UPDATE SAPSM 
			SET SAPSM.FieldType = DASM.FieldType
			FROM AVL.PRJ_StandardAttributeProjectStatusMaster (NOLOCK) SAPSM
			JOIN AVL.MAS_DebtAttributeStatusMaster (NOLOCK) DASM
				ON SAPSM.ServiceID = DASM.ServiceID AND SAPSM.AttributeID = DASM.AttributeID AND SAPSM.StatusID = DASM.StatusID 
			WHERE SAPSM.Projectid = @ProjectID AND SAPSM.FieldType = 'O' AND  DASM.FieldType = 'M' and SAPSM.IsDeleted=0 and DASM.IsDeleted=0

		END
		
		-- If Mainspring Enabled is 'No' and Is Debt Enabled is 'Yes' (As we are enabling the debt, we are not checking the condition)
		IF @IsMainspring = 'Y'
		BEGIN

			-- If the given project is not present in Mainspring Attribute Project Status Master
			IF NOT EXISTS (SELECT ProjectId FROM AVL.PRJ_MainspringAttributeProjectStatusMaster WHERE ProjectId = @ProjectId and IsDeleted=0)
			BEGIN
	
				-- Insert all the data from Mainspring Attribute Status Master to Mainspring Attribute Project Status Master for the given project	
				INSERT INTO AVL.PRJ_MainspringAttributeProjectStatusMaster
				(
					ServiceID,
					ServiceName,
					AttributeID,
					AttributeName,
					StatusID,
					StatusName,
					FieldType,
					CreatedDateTime,
					CreatedBy,
					ModifiedDateTime,
					ModifiedBy,
					IsDeleted,
					Projectid,
					TicketMasterFields
				)
				SELECT
						MASM.ServiceID,
						MASM.ServiceName,
						MASM.AttributeID,
						MASM.AttributeName,
						MASM.StatusID,
						MASM.StatusName,
						MASM.FieldType,
						GETDATE(), -- CreatedDateTime
						'System', -- CreatedBy
						NULL, -- ModifiedDateTime
						NULL, -- ModifiedBy
						MASM.IsDeleted,
						@ProjectID, 
						MASM.TicketDetailFields
				FROM AVL.MAS_MainspringAttributeStatusMaster (NOLOCK) MASM
				where IsDeleted =0

			END

			-- Update the Mandatory Attributes in Mainspring Attribute Project Status Master from Debt Attribute Status Master
			UPDATE MAPSM 
			SET MAPSM.FieldType = DASM.FieldType
			FROM AVL.PRJ_MainspringAttributeProjectStatusMaster (NOLOCK) MAPSM
			JOIN AVL.MAS_DebtAttributeStatusMaster (NOLOCK) DASM
				ON MAPSM.ServiceID = DASM.ServiceID AND MAPSM.AttributeID = DASM.AttributeID AND MAPSM.StatusID = DASM.StatusID 
			WHERE MAPSM.Projectid = @ProjectID AND MAPSM.FieldType = 'O' AND DASM.FieldType = 'M' AND MAPSM.IsDeleted=0 AND DASM.IsDeleted=0

		END
	
	
	END TRY
	BEGIN CATCH
       
			DECLARE @ErrorMessage VARCHAR(MAX);

			SELECT @ErrorMessage = ERROR_MESSAGE()
		              
	END CATCH

END
