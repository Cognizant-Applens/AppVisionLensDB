/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ITSM_GetSupportTypeListByProjectID] 
(
@ProjectID INT,
@ITSMConfigStatus CHAR,
@ITSMToolID INT
)
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;

		DECLARE @listStr VARCHAR(MAX)
		SELECT MPC.SupportTypeID , STM.SupportTypeName, MP.SupportTypeId AS PrjSupportTypeID
		--, TTM.AVMTicketType 
		FROM AVL.SupportTypeMaster (NOLOCK) STM
		INNER JOIN AVL.TK_MAP_TicketTypeMapping (NOLOCK) MPC
		ON STM.SupportTypeId = MPC.SupportTypeId AND STM.IsDeleted = 0 
		INNER JOIN AVL.MAP_ProjectConfig MP
		ON MP.SupportTypeId = STM.SupportTypeId AND MP.ProjectID = @ProjectID
		--INNER JOIN [AVL].[TK_MAP_TicketTypeMapping] TTM 
		--ON TTM.ProjectID = MPC.ProjectID AND TTM.IsDeleted = 0
		WHERE MPC.ProjectID = @ProjectID	

END TRY  

	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		  
		EXEC AVL_InsertError ' [AVL].[ITSM_GetSupportTypeListByProjectID]', @ErrorMessage, @ProjectID, '0' 
		
	END CATCH  

END
