/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
-- [dbo].[GetPriority] 146918
CREATE PROCEDURE [dbo].[GetPriority]
@ProjectId int
AS
BEGIN
SET NOCOUNT ON
BEGIN TRY
SELECT PM.PriorityIDMapID as PriorityID,PM.PriorityName FROM [AVL].[TK_MAP_PriorityMapping] PM (NOLOCK)
WHERE PM.ProjectId=@ProjectId AND PM.IsDeleted=0
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[dbo].[GetPriority] ', @ErrorMessage, @ProjectId,0
	END CATCH 
	SET NOCOUNT OFF
END
