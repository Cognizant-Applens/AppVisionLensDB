/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[DebtManualInsert]
@CustomerID bigint, 
@ProjectID bigint
AS
BEGIN
             --UPDATE AVL.MAS_ProjectMaster SET IsDebtEnabled = 'Y' WHERE ProjectID = @projectid AND IsDeleted=0
               DECLARE @AttributeType CHAR
			   DECLARE @Iscognizant INT

			   SET @Iscognizant = (SELECT IsCognizant FROM AVL.Customer WHERE CustomerID = @CustomerID AND IsDeleted = 0)
               SET @AttributeType = (SELECT ISNULL(IsMainSpringConfigured,'N')AS IsMainSpringConfigured FROM AVL.MAS_ProjectMaster WHERE ProjectID =@projectid AND IsDeleted=0)
            IF (@AttributeType='Y')
            BEGIN
            
              PRINT 'dept'
                        UPDATE m set m.FieldType = d.FieldType
                        from AVL.PRJ_MainspringAttributeProjectStatusMaster as M
                        INNER JOIN AVL.MAS_DebtAttributeStatusMaster AS D on m.ServiceID = d.ServiceID and m.AttributeID = d.AttributeID AND m.StatusID = d.StatusID
                        where D.FieldType = 'M' and m.Projectid = @ProjectID
                                          
            END
            ELSE 
            BEGIN
			IF(@Iscognizant = '1')
			BEGIN
                       IF NOT EXISTS (SELECT TOP 1 * FROM AVL.PRJ_StandardAttributeProjectStatusMaster WHERE Projectid = @ProjectID AND IsDeleted = 0)
			BEGIN
					INSERT INTO AVL.PRJ_StandardAttributeProjectStatusMaster 
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
				FROM AVL.MAS_StandardAttributeStatusMaster where IsDeleted=0

				UPDATE m set m.FieldType = 'M'
                        from AVL.PRJ_StandardAttributeProjectStatusMaster as M
                        INNER JOIN AVL.MAS_DebtAttributeStatusMaster AS D on m.ServiceID = d.ServiceID and m.AttributeID = d.AttributeID AND m.StatusID = d.StatusID
                        where D.FieldType = 'M'  and m.Projectid = @ProjectID and m.IsDeleted =0 and d.IsDeleted=0
			END
			ELSE
			BEGIN
				UPDATE m set m.FieldType = 'M'
                        from AVL.PRJ_StandardAttributeProjectStatusMaster as M
                        INNER JOIN AVL.MAS_DebtAttributeStatusMaster AS D on m.ServiceID = d.ServiceID and m.AttributeID = d.AttributeID AND m.StatusID = d.StatusID
                        where D.FieldType = 'M'  and m.Projectid = @ProjectID and m.IsDeleted =0 and d.IsDeleted=0
			END
            END                        
            END
            SELECT 1 AS RESULT
   
		END
