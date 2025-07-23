/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROC [AVL].[GetUserAssignementGroupmappingGridData] --10337
@customerID varchar(20),
@projectid varchar(20)
AS
BEGIN
BEGIN TRY

select PM.EsaProjectID as ProjectID,PM.ProjectName,LM.EmployeeID,LM.EmployeeName,Ag.AssignmentGroupName from AVL.BOTAssignmentGroupMapping AG  
join AVL.UserAssignmentGroupMapping UAM on UAM.ProjectID=AG.ProjectID and UAM.AssignmentGroupMapID=AG.AssignmentGroupMapID
join AVL.MAS_LoginMaster LM on LM.UserID=UAM.UserID and LM.ProjectID = UAM.ProjectID
join AVL.MAS_ProjectMaster PM on PM.ProjectID=@ProjectID and PM.IsDeleted=0
where LM.IsDeleted=0 and UAM.IsDeleted=0 and AG.IsDeleted=0 and UAM.ProjectID=@ProjectID
ORDER by LM.EmployeeID

END TRY 
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);
SELECT
	@ErrorMessage = ERROR_MESSAGE()
EXEC AVL_InsertError	'[AVL].[GetUserAssignementGroupmappingGridData]'
						,@ErrorMessage
						,0
						,0
END CATCH
END
