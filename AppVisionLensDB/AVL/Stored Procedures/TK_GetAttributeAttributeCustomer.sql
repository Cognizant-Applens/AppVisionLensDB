/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[AVL].[TK_GetAttributeAttributeCustomer] 7,0,8,0,''

--STANDARD PROJECTID
CREATE PROCEDURE [AVL].[TK_GetAttributeAttributeCustomer]
@ProjectId BIGINT,
@serviceid INT,
@DARTStatusID INT,
@TicketStatusID BIGINT
AS 
BEGIN 
BEGIN TRY
SET NOCOUNT ON;
		SELECT 0 AS ServiceID,AM.AttributeName,0 AS ProjectStatusID,
		0 AS ProjectID,tm.StatusID AS DARTStatusID FROM AVL.MAS_TicketTypeStatusAttributeMaster tm
		inner join  AVL.MAS_AttributeMaster am
		ON TM.AttributeID=AM.AttributeID
		WHERE StatusID=@DARTStatusID AND FieldType='M' and am.IsDeleted =0
		
SET NOCOUNT OFF;
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()




		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[TK_GetTicketAttributeCustomer]', @ErrorMessage, @ProjectId,0
		
	END CATCH 
END
