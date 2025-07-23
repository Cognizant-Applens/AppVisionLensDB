/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROC [dbo].[GetScreenDetails] 
(
@CustomerId int=null
)
AS BEGIN
SET NOCOUNT ON;
BEGIN TRY
select DISTINCT SM.ScreenID,ISNULL(CSM.IsEnabled,0) AS IsEnabled into #Temp 
from AVL.ScreenMaster SM (NOLOCK)
left join AVL.MAP_CustomerScreenMapping CSM (NOLOCK)
ON SM.ScreenID=CSM.ScreenID AND CSM.CustomerID=@CustomerId
where SM.IsActive=1 

if exists(select 1 from AVL.Customer (NOLOCK) where CustomerID=@CustomerId and isCognizant=1)
BEGIN
delete from #Temp where ScreenID=9
End
select * from #temp (NOLOCK)
END TRY
BEGIN CATCH

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError ' [dbo].[GetScreenDetails] ', @ErrorMessage, 0,@CustomerId
		

END CATCH
SET NOCOUNT OFF;
END
