/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [AVL].[UpdateSingleTicketServiceName] 

@ProjectID BIGINT, 
@ServiceName VARCHAR(MAX),
@TicketID VARCHAR(MAX),
@TicketTypeMapID INT
AS
BEGIN
BEGIN TRY
DECLARE @ServiceID BIGINT


SET @ServiceID = (SELECT ServiceID FROM avl.TK_MAS_Service WHERE ServiceName = @ServiceName)

IF(@Serviceid <> 0) 
BEGIN
	IF EXISTS(SELECT TOP 1 ServiceID FROM avl.TK_MAP_TicketTypeServiceMapping WHERE ProjectID=@ProjectID
	AND TicketTypeMappingID=@TicketTypeMapID AND IsDeleted = 0	AND ServiceID=@ServiceID)
	AND 
	EXISTS(SELECT  TOP 1 ServiceID FROM avl.TK_MAS_ServiceActivityMapping sam join
			AVL.TK_PRJ_ProjectServiceActivityMapping psam on sam.ServiceMappingID = psam.ServiceMapID
			WHERE psam.ProjectID = @ProjectID
			AND sam.IsDeleted = 0 AND psam.IsDeleted=0 AND sam.ServiceID = @ServiceID)
				BEGIN
				UPDATE avl.TK_TRN_TicketDetail SET ServiceClassificationMode = 5, ServiceID = @ServiceID WHERE projectid = @ProjectID AND TicketID = @TicketID AND IsDeleted = 0
				SELECT @ServiceID AS ServiceID
				END
END 
		
END TRY 
BEGIN CATCH 
	DECLARE @ErrorMessage VARCHAR(MAX); 
	SELECT @ErrorMessage = ERROR_NUMBER() 	 
	EXEC AVL_INSERTERROR 
		'[AVL].[UpdateSingleTicketServiceName]', 
		@ErrorMessage, 
		@ProjectID, 
        0 
	END CATCH 
END
