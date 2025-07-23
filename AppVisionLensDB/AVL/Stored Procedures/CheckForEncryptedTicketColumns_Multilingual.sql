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
-- Create date: 20-6-2019
-- Description:	Get Encrypted Columns
-- =============================================*/
CREATE PROCEDURE [AVL].[CheckForEncryptedTicketColumns_Multilingual]
	-- Add the parameters for the stored procedure here
	@ProjectID BIGINT,
	@CogID VARCHAR(100)
AS
BEGIN
	BEGIN TRY
			-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Columns VARCHAR(MAX);

	SELECT  MCM.ColumnName AS 'Columns' FROM AVL.PRJ_MultilingualColumnMapping MCP
	JOIN AVL.MAS_MultilingualColumnMaster MCM ON MCM.ColumnID=MCP.ColumnID  WHERE MCP.ProjectID=@ProjectID 
	AND MCM.IsActive=1 AND MCP.IsActive=1;
		SET NOCOUNT OFF;
	END TRY

	BEGIN CATCH
	 DECLARE @ErrorMessage VARCHAR(MAX);  
  
	  SELECT @ErrorMessage = ERROR_MESSAGE()  
	  --INSERT Error      
	  EXEC AVL_InsertError 'AVL.CheckForEncryptedTicketColumns_Multilingual', @ErrorMessage, @CogID, @projectID  
  
  
	END CATCH
END
