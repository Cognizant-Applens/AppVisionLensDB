/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[DeleteMLClassification_TicketUpload]
(
@ProjectID bigint,
@SupportType int
)
AS
BEGIN
BEGIN TRY
	delete from AVL.TK_MLClassification_TicketUpload where ProjectID = @ProjectID  and SupportType = @SupportType
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[DeleteMLClassification_TicketUpload] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  

END