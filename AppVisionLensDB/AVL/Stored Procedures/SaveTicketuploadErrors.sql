/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE AVL.SaveTicketuploadErrors
(
@EmployeeID NVARCHAR(50),
@ProjectID varchar(50),
@CustomerID varchar(50),
@Error_Details varchar(8000),
@UploadedFileName varchar(8000)
)
AS
BEGIN 

BEGIN	TRY
INSERT INTO [AVL].[TicketUploadErrors]
           ([EmployeeID]
           ,[ProjectID]
           ,[CustomerID]
           ,[Error_Details]
		   ,[UploadedFileName]
           ,[CreatedOn])
		SELECT @EmployeeID,@ProjectID,@CustomerID,@Error_Details,@UploadedFileName,GETDATE()

		
END TRY 
BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);

		SET @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage
		--INSERT Error    
		EXEC AVL_InsertError 'AVL.SaveTicketuploadErrors', @ErrorMessage, 0,0
	
END CATCH

END
