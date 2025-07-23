/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- author:		
-- create date: 
-- Modified by : 686186
-- Modified For: RHMS CR
-- description: 
-- =============================================

-- EXEC [AVL].[APP_INV_GetProjectForAccount] 7297,'104559'
CREATE procedure [AVL].[APP_INV_GetProjectForAccount]
-- add the parameters for the stored procedure here
(
@customerid bigint,
@employeeid nvarchar(500)
)
as
begin
begin try
		select distinct pm.projectid,pm.projectname
				from 
				[avl].[vw_employeecustomerprojectrolebumapping] ecpm
				--avl.employeecustomermapping evm
				--join
				--avl.employeeprojectmapping epm on epm.employeecustomermappingid=evm.id
				join
				avl.mas_projectmaster pm on pm.projectid=ecpm.projectid
				where 
				ecpm.customerid=@customerid and ecpm.employeeid=@employeeid and pm.isdeleted=0

end try
begin catch

	DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()

	--INSERT Error

	EXEC AVL_InsertError 'AVL.APP_INV_GetProjectForAccount',@ErrorMessage,0,@customerid
			
end catch
end
