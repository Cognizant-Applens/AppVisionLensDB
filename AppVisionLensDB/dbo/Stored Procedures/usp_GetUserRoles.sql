/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[dbo].[usp_GetUserRoles] '575633'
CREATE PROCEDURE [dbo].[usp_GetUserRoles]( 
@AssociateId CHAR(100))


AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY

SELECT top 1 L.RoleID AS RoleId,r.RoleName as RoleName,

RTRIM(L.EmployeeName) AS [AssociateName]


from AVL.MAS_LoginMaster L (NOLOCK)
left join AVL.RoleMaster R (NOLOCK) on r.RoleId=l.RoleID where EmployeeID=@AssociateId
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[usp_GetUserRoles] ', @ErrorMessage, 0,@AssociateId
		
	END CATCH  
	SET NOCOUNT OFF;
END
