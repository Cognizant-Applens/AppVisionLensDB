/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[UpdateDebtMandateAttributes]
@ProjectID int,
@AttributeType varchar(10)
AS
BEGIN
		   UPDATE [AVL].[MAS_ProjectMaster] SET IsDebtEnabled = 'Y' WHERE ProjectID = @projectid AND IsDeleted=0
		-- IF (@AttributeType='2')
		-- BEGIN
		 
		 
		--		UPDATE m set m.FieldType = d.FieldType
		--		FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] AS M
		--		INNER JOIN [AVL].[MAS_DebtAttributeStatusMaster] AS D ON m.ServiceID = d.ServiceID and m.AttributeID = d.AttributeID AND m.StatusID = d.StatusID
		--		WHERE D.FieldType = 'M' and m.Projectid = @ProjectID
							
		--END

		-- IF (@AttributeType='3')
		-- BEGIN
		--		UPDATE m set m.FieldType = d.FieldType
		--		from MAS.C20AttributeProjectStatusMaster as M
		--		INNER JOIN [AVL].[MAS_DebtAttributeStatusMaster] AS D on m.ServiceID = d.ServiceID and m.AttributeID = d.AttributeID AND m.C20StatusID = d.C20StatusID
		--		where D.FieldType = 'M'  and m.Projectid = @ProjectID
					
		--END
		
		 --IF (@AttributeType='1')
		 --BEGIN
				UPDATE m set m.FieldType = d.FieldType
				FROM [AVL].[PRJ_StandardAttributeProjectStatusMaster] AS M
				INNER JOIN [AVL].[MAS_DebtAttributeStatusMaster] AS D ON m.ServiceID = d.ServiceID and m.AttributeID = d.AttributeID AND m.StatusID = d.StatusID
				WHERE D.FieldType = 'M'  and m.Projectid = @ProjectID and m.IsDeleted = 0 and D.IsDeleted =0 
						
		--END
END
