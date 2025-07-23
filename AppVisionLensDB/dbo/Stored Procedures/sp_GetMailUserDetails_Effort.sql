/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE  [dbo].[sp_GetMailUserDetails_Effort] -- exec [dbo].[sp_GetMailUserDetails_Effort] '132568',42718,';0;0;0;0'

(

@projectid INT,

@MailTo VARCHAR(50) 

)

AS

BEGIN

SET NOCOUNT ON;

	SELECT EmployeeEmail FROM AVL.MAS_LoginMaster (NOLOCK)  where EmployeeID in (SELECT ITEM FROM dbo.Split(@MailTo, ';')) and ProjectID = @projectid and IsDeleted = 0

SET NOCOUNT OFF;

END
