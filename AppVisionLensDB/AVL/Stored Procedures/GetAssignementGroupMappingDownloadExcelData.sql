/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE proc [AVL].[GetAssignementGroupMappingDownloadExcelData] --7097,9829
@CustomerId varchar(20),
@ProjectID varchar(20)
as
begin
begin try

select DISTINCT UAG.UserID,(STUFF((SELECT distinct ', ' + RTRIM(LTRIM(AG.AssignmentGroupName))
							  FROM AVL.UserAssignmentGroupMapping UAM
							  
							  join AVL.BOTAssignmentGroupMapping AG on 
							  AG.AssignmentGroupMapID=UAM.AssignmentGroupMapID and AG.ProjectID=UAM.ProjectID
							  where UAM.IsDeleted = 0 and AG.IsDeleted=0 AND UAM.ProjectID=@ProjectID
							  and UAG.UserID=UAM.UserID
							  FOR XML PATH(''), TYPE
							 ).value('.', 'NVARCHAR(MAX)') 
								, 1, 1, '')) as 'AssignementGroup'
 into #TempData
 from AVL.UserAssignmentGroupMapping UAG 
 JOIN AVL.MAS_LoginMaster Lm on Lm.UserID=UAG.UserID
where UAG.ProjectID=@ProjectID and UAG.IsDeleted=0 


select 
Lm.EmployeeID as 'Employee ID',
Lm.EmployeeName as 'Employee Name',
Temp.AssignementGroup as 'Assignement Group' 
from #TempData Temp
RIGHT JOIN AVL.MAS_LoginMaster Lm on Lm.UserID=Temp.UserID
where Lm.ProjectID=@ProjectID and LM.IsDeleted=0
ORDER by [Employee ID]

select AssignmentGroupName,SupportTypeID from AVL.BOTAssignmentGroupMapping
 where ProjectID=@ProjectID and AssignmentGroupCategoryTypeID=2 and IsBOTGroup=0 and IsDeleted=0
 ORDER by AssignmentGroupName
END TRY 
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);
SELECT
	@ErrorMessage = ERROR_MESSAGE()
EXEC AVL_InsertError	'[AVL].[GetAssignementGroupMappingDownloadExcelData]'
						,@ErrorMessage
						,0
						,0
END CATCH
END
