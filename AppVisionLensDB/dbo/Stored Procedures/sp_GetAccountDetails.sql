/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--sp_GetAccountDetails 587567,7
CREATE proc [dbo].[sp_GetAccountDetails](
@EmployeeId varchar(50),
@CustomerId varchar(10)
)
As 
Begin
declare @userId varchar(20)
select @userId=UserID from [AVL].[MAS_LoginMaster] 
 where EmployeeID=@EmployeeId and IsDeleted=0 and CustomerID=@CustomerId

Select A.AccountID,AccountName from AVL.AccountUserMapping AUM
inner join 
[ESA].[BUAccounts] A on A.AccountID=AUM.AccountId
 and Userid=@userId
End
