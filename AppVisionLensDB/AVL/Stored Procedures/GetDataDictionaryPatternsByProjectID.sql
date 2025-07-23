/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- Author:		 Dhivya        
-- Create Date:  Jan 30 2019
-- Description:  Get the data dictionary patterns
-- DB Name :     AppVisionlens
-- ============================================================================ 
CREATE PROC [AVL].[GetDataDictionaryPatternsByProjectID] --89401,154,10506
(
@ProjectID int,
@ApplicationIDs [AVL].[IDList] READONLY
)
AS
BEGIN

BEGIN TRY
SET NOCOUNT ON
	DECLARE @ProjectName NVARCHAR(1000)
	CREATE TABLE #ApplicationIDs
	(
	ID BIGINT NULL
	)

	INSERT INTO #ApplicationIDs
	SELECT ID FROM @ApplicationIDs

	SELECT DD.[ID],[ProjectID],[ApplicationID],[CauseCodeID],[ResolutionCodeID],[DebtClassificationID],
	[AvoidableFlagID],[ResidualDebtID],[ReasonForResidual],[ExpectedCompletionDate],[IsDeleted],
	CASE  WHEN CreatedBy='Migrated' THEN 'User'  ELSE CreatedBy END AS[CreatedBy],
	[CreatedDate],[ModifiedBy],[ModifiedDate]
	INTO #DDTemp 
	FROM [AVL].[Debt_MAS_ProjectDataDictionary] DD With (NOLOCK)
	WHERE DD.ProjectID=@ProjectID AND ISNULL(DD.IsDeleted,0)=0
	AND DD.ApplicationID IN(SELECT ID FROM #ApplicationIDs)

	SELECT ApplicationID,ApplicationName INTO #APP_MAS_ApplicationDetails FROM AVL.APP_MAS_ApplicationDetails AD With (NOLOCK)
	WHERE AD.ApplicationID IN(SELECT ID FROM #ApplicationIDs) AND AD.IsActive=1

	SET @ProjectName=(SELECT ProjectName FROM AVL.MAS_ProjectMaster With (NOLOCK) WHERE ProjectID=@ProjectID AND ISNULL(IsDeleted,0)=0)

	SELECT RC.ResolutionID,RC.ResolutionCode INTO #DEBT_MAP_ResolutionCode FROM AVL.DEBT_MAP_ResolutionCode RC With (NOLOCK)
	WHERE RC.ProjectID=@ProjectID 
	AND ISNULL(RC.IsDeleted,0)=0

	SELECT CC.CauseID,CC.CauseCode INTO #DEBT_MAP_CauseCode FROM AVL.DEBT_MAP_CauseCode CC With (NOLOCK)
	WHERE CC.ProjectID=@ProjectID
	AND CC.IsDeleted=0


	SELECT DISTINCT DD.[ID]
	,DD.[ProjectID]
	,@ProjectName AS ProjectName
	,DD.[ApplicationID]
	,AD.ApplicationName
	,DD.[CauseCodeID]
	,CC.CauseCode
	,DD.[ResolutionCodeID]
	,RC.ResolutionCode
	,DD.[DebtClassificationID]
	,DC.DebtClassificationName
	,DD.[AvoidableFlagID]
	,AF.AvoidableFlagName
	,DD.[ResidualDebtID]
	,RD.ResidualDebtName
	,DD.[ReasonForResidual]
	,RFR.ReasonResidualName
	,CONVERT(VARCHAR, DD.[ExpectedCompletionDate], 101) as ExpectedCompletionDate
	,DD.[IsDeleted]
	,DD.[CreatedBy]
	,DD.[CreatedDate]
	,DD.[ModifiedBy]
	,DD.[ModifiedDate]
	FROM #DDTemp DD With (NOLOCK)
	INNER JOIN #APP_MAS_ApplicationDetails AD (NOLOCK) ON DD.ApplicationID=AD.ApplicationID
	INNER JOIN #DEBT_MAP_ResolutionCode RC (NOLOCK) on DD.ResolutionCodeID =RC.ResolutionID
	INNER JOIN #DEBT_MAP_CauseCode CC (NOLOCK) on   DD.CauseCodeID  =CC.CauseID
	INNER JOIN AVl.DEBT_MAS_DebtClassification(NOLOCK) DC on DD.DebtClassificationID =DC.DebtClassificationID
	AND ISNULL(DC.IsDeleted,0)=0
	INNER JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AF on DD.AvoidableFlagID=AF.AvoidableFlagID AND ISNULL(AF.IsDeleted,0)=0
	INNER JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RD on DD.ResidualDebtID=RD.ResidualDebtID AND ISNULL(RD.IsDeleted,0)=0
	LEFT JOIN [AVL].[TK_MAS_ReasonForResidual](NOLOCK) RFR on DD.ReasonForResidual =RFR.ReasonResidualID
	AND ISNULL(RD.IsDeleted,0)=0
	WHERE DD.ProjectID=@ProjectID 
	AND ISNULL(DD.IsDeleted,0)=0
	ORDER BY DD.CreatedDate DESC

	DROP TABLE #ApplicationIDs
	DROP TABLE #DDTemp
	DROP TABLE #APP_MAS_ApplicationDetails
	DROP TABLE #DEBT_MAP_ResolutionCode
	DROP TABLE #DEBT_MAP_CauseCode
SET NOCOUNT OFF
END TRY

	BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[GetDataDictionaryPatternsByProjectID]', @ErrorMessage, 0, 0 
		
	END CATCH  
  END
