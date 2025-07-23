/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[sp_ActiveUATUser]
As 
Begin

	update LM set LM.IsDeleted=0 from AVL.MAS_LoginMaster LM join  [dbo].[EmployeeActive] EA on EA.EmployeeId=LM.EmployeeID and EA.ISActive=1

	update C set C.IsDeleted =0 from AVL.EmployeeCustomerMapping LM join  [dbo].[EmployeeActive] EA on EA.EmployeeId=LM.EmployeeID
	join AVL.Customer C on C.CustomerID=LM.CustomerID 
	and EA.ISActive=1

	
	update C set C.IsDeleted =0 from AVL.MAS_LoginMaster LM join  [dbo].[EmployeeActive] EA on EA.EmployeeId=LM.EmployeeID
	join AVL.Customer C on C.CustomerID=LM.CustomerID 
	and EA.ISActive=1

	update PM set PM.IsDeleted =0  from AVL.MAS_LoginMaster LM join  [dbo].[EmployeeActive] EA on EA.EmployeeId=LM.EmployeeID
	join AVL.MAS_ProjectMaster PM on PM.ProjectID=LM.ProjectID
	and EA.ISActive=1

END
