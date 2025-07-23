/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_DeleteTicketTypeListByProjectID] --4
(
@TicketTypeMapID INT,
@ProjectID INT,
@UserId VARCHAR
)
AS
	BEGIN
		IF NOT EXISTS(SELECT * FROM AVL.TM_TRN_TimesheetDetail WHERE PROJECTID = @ProjectID AND TicketTypeMapID = @TicketTypeMapID)
			BEGIN
				UPDATE AVL.TK_MAP_TicketTypeMapping
				SET IsDeleted = 1,
					ModifiedDateTime = GETDATE(),
					ModifiedBY = @UserId
					WHERE PROJECTID = @ProjectID AND TicketTypeMappingID = @TicketTypeMapID

				UPDATE AVL.TK_MAP_TicketTypeServiceMapping
				SET IsDeleted = 1,
					ModifiedDateTime = GETDATE(),
					ModifiedBY = @UserId
					WHERE PROJECTID = @ProjectID AND TicketTypeMappingID = @TicketTypeMapID
				SELECT 1 AS Result
			END
		ELSE
			BEGIN
				SELECT 0 AS Result
			END
		
	END
