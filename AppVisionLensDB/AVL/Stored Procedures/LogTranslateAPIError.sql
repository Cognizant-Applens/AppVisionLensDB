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
-- Create date: 5-20-2019
-- Description:	Logs Translate API error
-- =============================================*/
CREATE PROCEDURE [AVL].[LogTranslateAPIError] 
@TimeTickerID BIGINT ,
@TranslateText VARCHAR(MAX),
@ErrorScope VARCHAR(1000),
@ErrorMessage VARCHAR(MAX),
@User VARCHAR(50),
@SupportType INT
AS
BEGIN
BEGIN TRY
		-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 INSERT INTO AVL.MultilingualErrorTrace(TimeTickerID, TranslateText, ErrorScope, ErrorMessage, CreatedBy,
  CreatedDate,SupportType) VALUES(@TimeTickerID,@TranslateText,@ErrorScope,@ErrorMessage,@User,GETDATE(),@SupportType)
	SET NOCOUNT OFF;
END TRY
BEGIN CATCH

		SELECT @ErrorMessage = ERROR_MESSAGE()
		
		EXEC AVL_InsertError '[AVL].[LogTranslateAPIError]', @ErrorMessage, 0,@TimeTickerID
END CATCH
END
