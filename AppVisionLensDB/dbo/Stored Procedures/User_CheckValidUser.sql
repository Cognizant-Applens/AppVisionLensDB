/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[User_CheckValidUser] 
@EmployeeID nvarchar(50),
@CustomerID nvarchar(100)
AS
BEGIN
 SET NOCOUNT ON;  
 DECLARE @result bit    
	 BEGIN TRY
	  BEGIN TRANSACTION
	  select EmployeeID,EmployeeName from [AVL].[MAS_LoginMaster] where IsDeleted=0 and EmployeeID=@EmployeeID 
	  and CustomerID=@CustomerID
	 COMMIT TRANSACTION
	  --SET @result= 1
     END TRY

	 BEGIN CATCH
	      IF @@TRANCOUNT > 0
		    BEGIN
			   ROLLBACK TRANSACTION
			   --SET @result= 0 
		    END
	 END CATCH

	 --SELECT @result AS RESULT
    SET NOCOUNT OFF; 
END

--exec User_CheckValidUser '12234'
