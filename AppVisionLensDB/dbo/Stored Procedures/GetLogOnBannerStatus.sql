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
EXEC [dbo].[GetLogOnBannerStatus] 'OneAVM', 823150
*/
CREATE PROCEDURE [dbo].[GetLogOnBannerStatus]
(
	@ModuleName NVARCHAR(250),
	@AssociateId NVARCHAR(50)
)
AS
BEGIN
	SELECT count(id) Status FROM [dbo].[LogOnBannerDetails] WHERE ModuleName = @ModuleName AND AssociateId = @AssociateId AND IsDeleted = 0
END
