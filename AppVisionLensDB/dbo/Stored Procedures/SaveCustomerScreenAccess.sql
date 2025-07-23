/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROC [dbo].[SaveCustomerScreenAccess]
@Mode varchar(20)=null,
@CustomerId bigint=null,
@ScreenId int=null,
@IsEnable bit=null,
@ID VARCHAR(100)
AS BEGIN
BEGIN TRY
BEGIN TRAN

IF(@Mode='SaveAccess')
delete from AVL.MAP_CustomerScreenMapping where CustomerID=@CustomerId and ScreenID=@ScreenId
INSERT INTO AVL.MAP_CustomerScreenMapping([CustomerID],[ScreenID],[IsEnabled],CreatedDate,CreatedBy)
VALUES(@CustomerId,@ScreenId,@IsEnable,GETDATE(),@ID)

IF(@Mode='GetScreen')

SELECT ScreenID,ScreenName from AVL.ScreenMaster
COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[SaveCustomerScreenAccess] ', @ErrorMessage, 0,@CustomerId
		
	END CATCH  


END
