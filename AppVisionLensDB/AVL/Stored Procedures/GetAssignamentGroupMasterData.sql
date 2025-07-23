/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[GetAssignamentGroupMasterData]
AS
BEGIN
BEGIN TRY
	
	SELECT AssignmentGroupTypeID as categoryID
	,AssignmentGroupTypeName as Categoryname 
	FROM AVL.MAS_AssignmentGroupType 
	where IsDeleted=0

	SELECT  STM.SupportTypeId
	,STM.SupportTypeName 
	FROM AVL.SupportTypeMaster STM
	where IsDeleted=0 and STM.SupportTypeId<>3

END TRY
  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetAssignamentGroupMasterData]', @ErrorMessage, 0,0
	END CATCH  
END
