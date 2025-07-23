/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[SaveUserAssignamentGroupMappingData]
@ProjectID BIGINT,
@CustomerID BIGINT,
@EmployeeID varchar(30),
@UserAssignmentGroupMapping AS [AVL].[TVP_UserAssignmentGroupMapping] READONLY
AS
BEGIN
BEGIN TRY

CREATE TABLE #FinalSaveData
(
EmployeeID varchar(30),
UserID bigint,
AssignmentGroupName varchar(max),
AssignementGroupMapID bigint,
ProjectID varchar(30),
)

INSERT INTO #FinalSaveData
SELECT LM.EmployeeID,LM.UserID,AG.AssignmentGroupName,Ag.AssignmentGroupMapID,@ProjectID
FROM AVL.MAS_LoginMaster LM 
 join @UserAssignmentGroupMapping TVP on LM.EmployeeID=TVP.[EmployeeID] and LM.IsDeleted=0 and LM.ProjectID=@ProjectID
left join AVL.BOTAssignmentGroupMapping AG on AG.AssignmentGroupName=Ltrim(Rtrim(TVP.[AssignmentGroupMapName]))
and AG.ProjectID=@ProjectID and AG.IsDeleted=0




UPDATE UAG set IsDeleted=1
from AVL.UserAssignmentGroupMapping UAG
join #FinalSaveData Temp on Temp.UserID=UAG.UserID
 where UAG.ProjectID=@ProjectID

 DELETE #FinalSaveData where ProjectID=@ProjectID and AssignementGroupMapID is NULL

 MERGE AVL.UserAssignmentGroupMapping AS UAG
USING #FinalSaveData AS Temp 
ON (UAG.UserID = Temp.UserID and UAG.ProjectID=@ProjectID and UAG.AssignmentGroupMapID=Temp.AssignementGroupMapID) 
--When records are matched, update the records if there is any change
WHEN MATCHED
THEN UPDATE SET UAG.IsDeleted=0,UAG.ModifiedBy=@EmployeeID,UAG.ModifiedDate=GETDATE()
--When no records are matched, insert the incoming records from source table to target table
WHEN NOT MATCHED BY TARGET 
THEN INSERT (ProjectID,UserID,AssignmentGroupMapID,IsDeleted,CreatedBy,CreatedDate) 
VALUES (Temp.ProjectID,Temp.UserID,Temp.AssignementGroupMapID,0,@EmployeeID,GETDATE());


SELECT @@rowcount as 'RowCount'

END TRY 
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);
SELECT
	@ErrorMessage = ERROR_MESSAGE()
EXEC AVL_InsertError	'[AVL].[TVP_UserAssignmentGroupMapping]'
						,@ErrorMessage
						,0
						,0
END CATCH

END
