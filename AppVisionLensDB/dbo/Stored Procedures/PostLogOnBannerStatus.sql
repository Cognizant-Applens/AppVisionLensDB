/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/*
Author:823150
EXEC [dbo].[PostLogOnBannerStatus] 'OneAVM', ''
*/
CREATE PROCEDURE [dbo].[PostLogOnBannerStatus]
(
	@ModuleName NVARCHAR(250),
	@AssociateId NVARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		IF ISNULL(@ModuleName,'') = '' OR LEN(@ModuleName) = 0
		BEGIN
			RAISERROR('Invalid parameter: @ModuleName cannot be NULL or empty', 18, 0)
			RETURN
		END

		IF ISNULL(@AssociateId,'') = '' OR LEN(@AssociateId) = 0
		BEGIN
			RAISERROR('Invalid parameter: @AssociateId cannot be NULL or empty', 18, 0)
			RETURN
		END

		Insert INTO dbo.LogOnBannerDetails (ModuleName,AssociateId,CreatedDate) Values(@ModuleName,@AssociateId,GETDATE())
	END TRY
	BEGIN CATCH
		DECLARE @Error_Message nvarchar(max)
			SELECT
				@Error_Message = ERROR_MESSAGE();

				RAISERROR(@Error_Message, 18, 0)
	END CATCH
END
