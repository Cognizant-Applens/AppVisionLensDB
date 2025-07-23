/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


--exec CheckUser '687596',7,4
CREATE Proc [dbo].[CheckUser]
(
@EmployeeID varchar,
@CustomerID int,
@ProjectID int
)
AS
BEGIN
select top 1 C.IsCognizant from avl.Customer C 
join avl.MAS_LoginMaster LM on C.CustomerID=LM.CustomerID
where C.CustomerID=@CustomerID 
and LM.EmployeeID=@EmployeeID 
and LM.ProjectID=@ProjectID 
and LM.IsDeleted = 0

END
