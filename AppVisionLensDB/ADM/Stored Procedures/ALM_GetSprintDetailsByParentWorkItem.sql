/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [ADM].[ALM_GetSprintDetailsByParentWorkItem](
@userId VARCHAR(50),
@projectId BIGINT,
@ParentWorkItemId VARCHAR(100)
)
AS            
BEGIN     
BEGIN TRY       
SET NOCOUNT ON;  

	SELECT * INTO #tempParentWorkItemSprintMethod FROM (
	select ATWD.sprintDetailsId from ADM.ALM_TRN_WorkItem_Details(NOLOCK) ATWD  
	WHERE  ATWD.WorkItem_Id = @ParentWorkItemId   AND ATWD.IsDeleted=0 --@ParentWorkItemId  
	AND ATWD.Project_Id = @projectId
	AND  ATWD.IsDeleted=0
	)t1 

	SELECT SD.SprintDetailsId,SD.SprintName
	FROM #tempParentWorkItemSprintMethod(NOLOCK) AS PLE
	INNER JOIN ADM.ALM_TRN_Sprint_Details SD (NOLOCK) ON PLE.sprintDetailsId = SD.sprintDetailsId
	INNER JOIN PP.ALM_MAS_SprintStatus SM (NOLOCK) ON SD.StatusId = SM.SprintStatusId
	WHERE SD.IsDeleted=0 AND SM.SprintStatusId NOT IN (4,5)
SET NOCOUNT OFF;
END TRY 
 BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()	
		EXEC AVL_InsertError '[ADM].[ALM_GetSprintDetailsByParentWorkItem] ', @ErrorMessage, @userId,@projectId
		RETURN @ErrorMessage
  END CATCH             
END
