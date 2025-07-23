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
-- Create date: 20-5-2019
-- Description:	Logs Subscription Error
-- =============================================*/
CREATE PROCEDURE [AVL].[LogTranslateAPIKeyError]
@ProjectID BIGINT,
@Key NVARCHAR(500),
@Error NVARCHAR(MAX),
@User VARCHAR(50)
AS
BEGIN
BEGIN TRY
		-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 INSERT INTO AVL.MultilingualKeyFailureTrace(ProjectID,MSubscriptionKey,ErrorMessage,CreatedBy,CreatedDate)
 VALUES(@ProjectID,@Key,@Error,@User,GETDATE())
 	SET NOCOUNT OFF;
END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		
		EXEC AVL_InsertError '[AVL].[LogTranslateAPIKeyError]', @ErrorMessage, 0,@ProjectID
END CATCH
END
