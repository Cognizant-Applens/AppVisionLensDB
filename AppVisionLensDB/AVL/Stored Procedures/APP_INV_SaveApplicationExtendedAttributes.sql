/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[APP_INV_SaveApplicationExtendedAttributes]   
@applicationID bigint,
@userBase nvarchar(50),
@incallwdgreen nvarchar(50),
@infraallwdgreen nvarchar(50),
@infoallwdgreen nvarchar(50),
@incallwdamber nvarchar(50),
@infraallwdamber nvarchar(50),
@infoallwdamber nvarchar(50),
@userName nvarchar(50),
@isUpdate bit,
@supportWindowID bigint,
@supportCategoryID bigint,
@OtherSupportWindow nvarchar(100)
AS
BEGIN
BEGIN TRY
DECLARE @count BIGINT;
IF @applicationID > 0
BEGIN

SELECT
	@count = 1
FROM AVL.APP_MAS_Extended_ApplicationDetail
WHERE ApplicationID = @applicationID;

IF @count IS NOT NULL AND @count = 1 BEGIN
UPDATE AVL.APP_MAS_Extended_ApplicationDetail
SET	UserBase = LTRIM(RTRIM(@userBase))
	,Incallwdgreen = @incallwdgreen
	,Infraallwdgreen = @infraallwdgreen
	,Infoallwdgreen = @infoallwdgreen
	,Incallwdamber = @incallwdamber
	,Infraallwdamber = @infraallwdamber
	,Infoallwdamber = @infoallwdamber
	,ModifiedBy = @userName
	,ModifiedDate = GETDATE()
	,SupportWindowID = @supportWindowID
	,SupportCategoryID = @supportCategoryID
	,OtherSupportWindow= LTRIM(RTRIM(@OtherSupportWindow))
WHERE ApplicationID = @applicationID;
END ELSE BEGIN
INSERT INTO AVL.APP_MAS_Extended_ApplicationDetail (ApplicationID,
UserBase,
Incallwdgreen,
Infraallwdgreen,
Infoallwdgreen,
Incallwdamber,
Infraallwdamber,
Infoallwdamber,
CreatedBy,
CreatedDate,
SupportWindowID,
SupportCategoryID,
OtherSupportWindow)
	VALUES (@applicationID, LTRIM(RTRIM(@userBase)), @incallwdgreen, @infraallwdgreen, @infoallwdgreen, @incallwdamber, @infraallwdamber, @infoallwdamber, @userName, GETDATE(), @supportWindowID, @supportCategoryID, LTRIM(RTRIM(@OtherSupportWindow)))

END
END
END TRY BEGIN CATCH

DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()


EXEC AVL_InsertError	'[AVL].[APP_INV_SaveApplicationExtendedAttributes]'
						,@ErrorMessage
						,@userName
						,@applicationID

END CATCH
END
