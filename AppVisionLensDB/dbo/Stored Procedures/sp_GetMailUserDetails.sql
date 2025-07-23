/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE  [dbo].[sp_GetMailUserDetails] -- exec [dbo].[sp_GetMailUserDetails] '132568',42718,';0;0;0;0'

(

@Empid VARCHAR(50),

@projectid INT,

@MailTo VARCHAR(50) 

)

AS

BEGIN
BEGIN TRY
SET NOCOUNT ON;

	SELECT EmployeeName,EmployeeEmail FROM AVL.MAS_LoginMaster (NOLOCK)  where EmployeeID in (SELECT ITEM FROM dbo.Split(@MailTo, ';')) and ProjectID = @projectid and IsDeleted = 0

SET NOCOUNT OFF;

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'sp_GetMailUserDetails', @ErrorMessage, @Empid ,@projectid
		
	END CATCH  
end
