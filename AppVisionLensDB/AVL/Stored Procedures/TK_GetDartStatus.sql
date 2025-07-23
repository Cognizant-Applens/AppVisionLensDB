/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[TK_GetDartStatus]
(
@StatusID BIGINT,
@ProjectID BIGINT
)
AS
BEGIN
BEGIN TRY

	SELECT DS.DARTStatusID,DS.DARTStatusName FROM AVL.TK_MAP_ProjectStatusMapping PS INNER JOIN AVL.TK_MAS_DARTTicketStatus DS
	ON PS.TicketStatus_ID = DS.DARTStatusID WHERE PS.StatusID = @StatusID AND Ps.ProjectID = @ProjectID

	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[TK_GetDartStatus] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  



END
