/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- Author:      Prakash     
-- Create date:      23 Nov 2018
-- Description:   is session running
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
--  [AVL].[Mini_GetUserDetails] --'686186'

-- ============================================================================ 
-- [AVL].[Mini_IsSessionsRunning]  '471742'
CREATE PROCEDURE [AVL].[Mini_IsSessionsRunning] --'686186'
(
@EmployeeID varchar(15)
)
AS
BEGIN
BEGIN TRY

	DECLARE @IsRunning VARCHAR(10);
		DECLARE @TicketID NVARCHAR(100);
	SET @IsRunning=(SELECT COUNT(*) FROM AVL.TK_Mini_Sessions(NOLOCK) WHERE EmployeeID=@EmployeeID
		AND IsRunning=0  AND  CONVERT(DATE,CreatedOn)=CONVERT(DATE,GETDATE()))

	SET @TicketID=(SELECT TOP 1 TicketID FROM AVL.TK_Mini_Sessions(NOLOCK) WHERE EmployeeID=@EmployeeID
		AND IsRunning=0 AND  CONVERT(DATE,CreatedOn)=CONVERT(DATE,GETDATE())  order by SessionID desc)
	IF @TicketID = 'No Ticket'
	SET @TicketID='Ticket'
		IF @IsRunning >0
			SELECT CONCAT(@TicketID , ' is currently running') AS IsRunning
		ELSE
		SELECT 0 AS IsRunning

END TRY
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[Mini_IsSessionsRunning]', @ErrorMessage, @EmployeeID,0
END CATCH 
END
