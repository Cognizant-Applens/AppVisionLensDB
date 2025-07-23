/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetLoginRedirection]
(  
@customerid BIGINT  
)
AS  

BEGIN  
BEGIN TRY
SET NOCOUNT ON;
if((select count(ID) from [AVL].[LoginRedirection] where CustomerID=@customerid AND IsDeleted = 0)>0)
begin
select 1 as Redirect
end
else 
begin
select 0 as Redirect
end
SET NOCOUNT OFF;   
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError ' [AVL].[GetLoginRedirection]   ', @ErrorMessage, @customerid,0
	END CATCH  
END
