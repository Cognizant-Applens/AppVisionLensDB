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
-- Author:		<>
-- Create date: <>
-- Description:	<[GetDetailsForBOT]>
-- =============================================
--exec [BOT].[CheckUsersDetails] '',''
CREATE proc [BOT].[CheckUsersDetails] --'',''
(
@Author NVARCHAR(7)='',
@ContactMail NVARCHAR(100)=''
)
AS
BEGIN 
 DECLARE @isAuthor int=-1
 DECLARE @isContactDL int=-1
  IF(@Author !='' AND @ContactMail!='')
  BEGIN
    SET @isAuthor = (Select COUNT(*) from AVL.MAS_LoginMaster(NOLOCK) where EmployeeID =@Author AND IsDeleted=0)
	SET @isContactDL= (SELECT COUNT(*) FROM BOT.MasterRepository where BotName =@ContactMail AND IsDeleted=0)
	SELECT @isAuthor AS Author,@isContactDL AS ContactMail
  END
  ELSE IF(@Author !='')
  BEGIN
    SET @isAuthor = (Select COUNT(*) from AVL.MAS_LoginMaster(NOLOCK) where EmployeeID =@Author AND IsDeleted=0)
	SELECT @isAuthor AS Author,@isContactDL AS ContactMail
  END
  ELSE --(@ContactDL!='')
  BEGIN
	SET @isContactDL= (SELECT COUNT(*) FROM BOT.MasterRepository where BotName =@ContactMail AND IsDeleted=0)
	SELECT @isAuthor AS Author,@isContactDL AS ContactMail
  END
	
END
