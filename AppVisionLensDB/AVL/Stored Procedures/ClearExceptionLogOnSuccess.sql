/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		Sreeya
-- Create date: 20-6-2019
-- Description:	Clear Exception Log On Success
-- =============================================
CREATE PROCEDURE [AVL].[ClearExceptionLogOnSuccess]
@TimeTickerIDSupportType AVL.[TVP_TimeTickerSupportTypeMapping] READONLY
AS
BEGIN
BEGIN TRY
		-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DELETE MET FROM AVL.MultilingualErrorTrace MET JOIN @TimeTickerIDSupportType TT ON TT.ID=MET.TimeTickerID AND TT.SupportType=MET.SupportType;
	SET NOCOUNT OFF;
END TRY

BEGIN CATCH
 DECLARE @ErrorMessage VARCHAR(MAX);  
	  SELECT @ErrorMessage = ERROR_MESSAGE()  
	  --INSERT Error      
	  EXEC AVL_InsertError 'AVL.ClearExceptionLogOnSuccess', @ErrorMessage, 0, 0  
END CATCH
END
