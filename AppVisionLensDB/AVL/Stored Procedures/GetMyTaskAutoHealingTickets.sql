/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/*-- =============================================
-- Author:		Sreeya
-- Create date: 2-8-2018
-- Description:	Fetches data from A/H table and send to API
-- =============================================*/
CREATE PROCEDURE [AVL].[GetMyTaskAutoHealingTickets]
@UserID varchar(50)
AS
BEGIN
BEGIN TRY
BEGIN TRAN
IF EXISTS(SELECT 1 FROM AVL.MyTaskAutoHealingJob)
BEGIN
	SELECT * FROM AVL.MyTaskAutoHealingJob ;
	DELETE FROM AVL.MyTaskAutoHealingJob;
END

COMMIT TRAN

END TRY

BEGIN CATCH
ROLLBACK TRAN
	DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()

	--INSERT Error

	EXEC AVL_InsertError 'AVL.GetMyTaskAutoHealingTickets',@ErrorMessage,0,0
END CATCH

END
