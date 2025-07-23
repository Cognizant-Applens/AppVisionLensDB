/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure [dbo].[GetUserServiceLevelDetails]
@CustomerID varchar(20)

as
begin
select distinct 
  STUFF((SELECT distinct ', ' + t1.ServiceLevelID
         from [AVL].[UserServiceLevelMapping] t1
         where t.EmployeeID = t1.EmployeeID
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,2,'') ServiceLevelID
from [AVL].[UserServiceLevelMapping] t where EmployeeID in (select Employeeid from [AVL].[MAS_LoginMaster] where CustomerID=7 and isdeleted=0)

end

--GetUserServiceLevelDetails 7,515869
