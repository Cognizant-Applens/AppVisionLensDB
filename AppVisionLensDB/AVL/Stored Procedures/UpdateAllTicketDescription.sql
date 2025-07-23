/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/****** Object:  StoredProcedure [AVL].[UpdateAllTicketDescription]    Script Date: 4/12/2021 3:48:13 PM ******/
-- =========================================================================================
-- Author      : Saravanan .B
-- Create date : 09 Apr 2021
-- Description : Procedure to Update All TicketDescription               
-- Test        : [AVL].[UpdateAllTicketDescription] 
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [AVL].[UpdateAllTicketDescription] 
@TableName VARCHAR(100),
@EncryptedColumnName  VARCHAR(100),
@IdentityColumnName VARCHAR(50),
@TVP_TicketDescriptionList [AVL].[TicketDescription] READONLY
AS
BEGIN
BEGIN TRY
BEGIN TRAN
	
	SET NOCOUNT ON
	DECLARE @sqlCommand NVARCHAR(500),@StatusMsg VARCHAR(20)

	CREATE TABLE #TempTicketDescription(
	ID BIGINT,
	TicketDescription NVARCHAR(MAX)
	)

	INSERT INTO #TempTicketDescription Select ID,TicketDescription FROM @TVP_TicketDescriptionList

	SET @sqlCommand=N'UPDATE TD SET TD.'  +
	    @EncryptedColumnName + '= TVP.TicketDescription
		FROM ' + @TableName +' TD JOIN #TempTicketDescription TVP 
		ON TVP.ID =TD.'+ @IdentityColumnName 

	EXEC sp_executesql @sqlCommand

	 IF OBJECT_ID(N'tempdb..#TempTicketDescription') IS NOT NULL
            BEGIN
                 DROP TABLE #TempTicketDescription
            END
   SET NOCOUNT OFF
   SET @StatusMsg='success'
   SELECT @StatusMsg AS 'Status'

COMMIT TRAN
END TRY  
	BEGIN CATCH  
	 DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		SELECT @ErrorMessage as ErrorMessage
		SET @StatusMsg='fail'
        SELECT @StatusMsg AS 'Status'
	ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[UpdateAllTicketDescription]', @ErrorMessage, 0,0
	END CATCH 
END
