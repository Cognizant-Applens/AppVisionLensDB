/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROC [dbo].[InsertErrorlogCL]
@ProjectID bigint =null,
@Step nvarchar(2000),
@ErrorMessage nvarchar(3000),
@Source nvarchar(3000) = null
AS
BEGIN

INSERT INTO ErrorlogCL VALUES(@ProjectID,@Step,@ErrorMessage, GETDATE())
EXEC [dbo].[MailForCLJobFailure] @ProjectID, @Step, @ErrorMessage, @Source
END
