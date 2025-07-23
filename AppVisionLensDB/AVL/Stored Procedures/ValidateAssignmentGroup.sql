/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ValidateAssignmentGroup] 
@ProjectID varchar(20),
@Mode varchar(50)
AS
BEGIN
BEGIN TRY
	if(@Mode='ITSM')
	begin
	select ClientUserID as ID from AVL.MAS_LoginMaster(NOLOCK) where ProjectID=@ProjectID and IsDeleted=0
	END
	ELSE IF(@Mode='UserManagement')
	BEGIN
	select AssignmentGroupName as ID from AVL.BOTAssignmentGroupMapping(NOLOCK) where ProjectID=@ProjectID and AssignmentGroupCategoryTypeID=1 and IsDeleted=0 
	END
END TRY
  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[ValidateAssignmentGroup]', @ErrorMessage, 0,0
	END CATCH  
END
