/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetAHTicketDescriptionDecryption]
AS
BEGIN
BEGIN TRY
BEGIN TRAN
	
	SELECT TicketDescription,HTD.ProjectPatternMapID,HTD.TicketType,HTD.HealingTicketID
	FROM AVL.DEBT_TRN_HealTicketDetails (NOLOCK) HTD 
	WHERE HTD.IsDeleted = 0 
	AND HTD.TicketType IN ('A','H') 
	AND (ISNULL(HTD.TicketDescription,'') <> '')
	

COMMIT TRAN
END TRY  
	BEGIN CATCH  
	 DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage as ErrorMessage
		
	ROLLBACK TRAN

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetAHTicketDescriptionDecryption]', @ErrorMessage, 0,0
	END CATCH 
END
