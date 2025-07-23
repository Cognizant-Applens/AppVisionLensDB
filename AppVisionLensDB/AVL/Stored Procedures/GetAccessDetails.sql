/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetAccessDetails](
@UserId VARCHAR(50)=NULL,
@RoleId INT=NULL
)
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;

SELECT SM.ScreenID,SM.ScreenName,SA.TypeOfAccess FROM AVL.RoleScreenMapping SA
INNER JOIN AVL.RoleMaster RM ON SA.RoleId=RM.RoleId
INNER JOIN [AVL].[EmployeeRoleMapping] URM ON RM.RoleId=URM.RoleID
INNER JOIN [AVL].[EmployeeCustomerMapping] LM ON URM.EmployeeCustomerMappingId=LM.ID AND LM.EmployeeID=@UserId
AND SA.RoleId=@RoleId
INNER JOIN AVL.ScreenMaster SM ON SM.ScreenID=SA.ScreenId

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetAccessDetails_New]', @ErrorMessage, @UserId,0
		
	END CATCH  
END
