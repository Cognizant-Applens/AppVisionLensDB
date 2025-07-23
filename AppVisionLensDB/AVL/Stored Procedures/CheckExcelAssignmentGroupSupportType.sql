/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[CheckExcelAssignmentGroupSupportType]
@ProjectID varchar(20),
@AssignmentGroupMapSupportType as [AVL].[TVP_AssignmentGroupMapSupportType] READONLY
as 
begin
begin try
select * into #TempSupportType1 from @AssignmentGroupMapSupportType where [AssignmentGroupName] is not NULL

select AssignmentGroupName,SupportTypeID into #TempSupportType2 from AVL.BOTAssignmentGroupMapping
 where ProjectID=@ProjectID and AssignmentGroupCategoryTypeID=2 and IsBOTGroup=0 and IsDeleted=0
 ORDER by AssignmentGroupName

 select * from #TempSupportType2
 EXCEPT
 select * from #TempSupportType1
END TRY 
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);
SELECT
	@ErrorMessage = ERROR_MESSAGE()
EXEC AVL_InsertError	'[AVL].[CheckExcelAssignmentGroupSupportType]'
						,@ErrorMessage
						,0
						,0
END CATCH
END
