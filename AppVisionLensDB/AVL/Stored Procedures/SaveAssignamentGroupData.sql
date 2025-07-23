/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROC [AVL].[SaveAssignamentGroupData]
@ProjectID BIGINT,
@EmployeeID varchar(20),
@AssignmentGroupSaveData AS [AVL].[TVP_AssignmentGroupSaveData] READONLY
AS
BEGIN
BEGIN TRY
declare @CustomerID int=( SELECT
		CustomerID
	FROM AVL.MAS_ProjectMaster(NOLOCK)
	WHERE ProjectID = @ProjectID
	AND IsDeleted = 0)
DECLARE @IsCognizant int=( SELECT
		(case when IsCognizant=1 then 1 ELSE 0 end) 
	FROM AVL.Customer(NOLOCK)
	WHERE CustomerID = @CustomerID
	AND IsDeleted = 0)

UPDATE AGM
SET	AGM.AssignmentGroupName = Temp.AssignmentGroup
	,AGM.AssignmentGroupCategoryTypeID = Temp.CategoryID
	,AGM.SupportTypeID = Temp.SupportTypeID
	,AGM.IsBOTGroup = Temp.IsBoTGroup
	,AGM.ModifiedBy = @EmployeeID
	,AGM.ModifiedDate = GETDATE()
FROM AVL.BOTAssignmentGroupMapping AGM
JOIN @AssignmentGroupSaveData Temp
	ON Temp.AssignmentGroupMapID = AGM.AssignmentGroupMapID
	AND AGM.IsDeleted = 0

INSERT INTO AVL.BOTAssignmentGroupMapping (AssignmentGroupName
, ProjectID
, AssignmentGroupCategoryTypeID
, SupportTypeID
, IsBOTGroup
, IsDeleted
, CreatedBy
, CreatedDate)
	(SELECT
		AssignmentGroup
		,@ProjectID
		,CategoryID
		,SupportTypeID
		,IsBoTGroup
		,0
		,@EmployeeID
		,GETDATE()
	FROM @AssignmentGroupSaveData
	WHERE AssignmentGroupMapID = 0)
if(@IsCognizant=1)
BEGIN

	IF NOT EXISTS (SELECT (Id) FROM AVL.PRJ_ConfigurationProgress WHERE ProjectID = @ProjectID
		AND ScreenID = 2
		AND ITSMScreenId = 12 and IsDeleted=0) 
	BEGIN
		INSERT INTO AVL.PRJ_ConfigurationProgress (CustomerID
		, ProjectID
		, ScreenID
		, ITSMScreenId
		, CompletionPercentage
		, IsDeleted
		, CreatedBy
		, CreatedDate)
			VALUES (@CustomerID, @ProjectID, 2, 12, 100, 0, @EmployeeID, GETDATE())
	END
END
ELSE
BEGIN
	IF NOT EXISTS (SELECT (Id) FROM AVL.PRJ_ConfigurationProgress WHERE ProjectID = @ProjectID
		AND ScreenID = 2
		AND ITSMScreenId = 10 and IsDeleted=0) 
	BEGIN
		INSERT INTO AVL.PRJ_ConfigurationProgress (CustomerID
		, ProjectID
		, ScreenID
		, ITSMScreenId
		, CompletionPercentage
		, IsDeleted
		, CreatedBy
		, CreatedDate)
			VALUES (@CustomerID, @ProjectID, 2, 10, 100, 0, @EmployeeID, GETDATE())
	END
END
END TRY BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);
SELECT
	@ErrorMessage = ERROR_MESSAGE()
EXEC AVL_InsertError	'[AVL].[SaveAssignamentGroupData]'
						,@ErrorMessage
						,0
						,0
END CATCH

END
