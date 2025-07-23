/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Proc [dbo].[AVL_GetAccountByEmployeeID] --'627384'

@EmployeeID nvarchar(max)

as

begin



select Cust.CustomerID,Cust.CustomerName  from [AVL].[MAS_LoginMaster] LM join [AVL].[Customer] Cust on Cust.CustomerID=LM.CustomerID 

WHERE LM.EmployeeID=@EmployeeID AND LM.Isdeleted=0

end
