/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_GetViewAllInfraPattern] --10337 
(@ProjectID BIGINT) 
AS 
  BEGIN
 
    BEGIN TRY 
    BEGIN TRAN
 
      DECLARE @CustomerID INT=0;
 
      DECLARE @IsCognizantID INT;

SET @CustomerID = (SELECT TOP 1
		CustomerID
	FROM AVL.MAS_LoginMaster
	WHERE ProjectID = @ProjectID
	AND IsDeleted = 0)
SET @IsCognizantID = (SELECT TOP 1
		IsCognizant
	FROM AVL.Customer
	WHERE CustomerID = @CustomerID
	AND IsDeleted = 0)

SELECT
	* INTO #DEBT_MLPATTERNVALIDATION
FROM AVL.ML_TRN_MLPatternValidationInfra(NOLOCK) MV
WHERE MV.ProjectID = @ProjectID
AND MV.IsDeleted = 0

CREATE TABLE #TMP_FINAL(ID INT IDENTITY (1, 1),
TowerID NVARCHAR(MAX),
TicketPattern NVARCHAR(MAX),
SubPattern NVARCHAR(MAX),
AdditionalPattern NVARCHAR(MAX),
AdditionalSubPattern NVARCHAR(MAX),
MLAccuracy DECIMAL(10, 2),
Occur INT,
CauseCode INT,
ResolutionCode INT)

INSERT INTO #TMP_FINAL
	SELECT DISTINCT
		TowerID
		,TicketPattern
		,SubPattern
		,AdditionalPattern
		,AdditionalSubPattern
		,MAX(MLAccuracy) AS MLAccuracy
		,MAX(TicketOccurence) AS TicketOccurence
		,MLCauseCodeID
		,MLResolutionCode
	FROM #DEBT_MLPATTERNVALIDATION
	WHERE TicketPattern <> '0'
	AND TicketOccurence != 0
	GROUP BY	TowerID
				,TicketPattern
				,SubPattern
				,AdditionalPattern
				,AdditionalSubPattern
				,MLCauseCodeID
				,MLResolutionCode

DECLARE @num INT;

SET @num = 1

DECLARE @max INT

SET @max = (SELECT
		MAX(id)
	FROM #TMP_FINAL)

DECLARE @Pattern NVARCHAR(MAX)
DECLARE @Accuracy DECIMAL(10, 2)
DECLARE @ApplicationID NVARCHAR(MAX)
DECLARE @Occurance INT
DECLARE @SubPattern NVARCHAR(MAX)
DECLARE @AdditionalPattern NVARCHAR(MAX)
DECLARE @AdditionalSubPattern NVARCHAR(MAX)
DECLARE @CauseCode INT
DECLARE @ResolutionCode INT

CREATE TABLE #MAXIDS(tickid INT,
TowerID NVARCHAR(MAX),
TicketPattern NVARCHAR(MAX),
SubPattern NVARCHAR(MAX),
AdditionalPattern NVARCHAR(MAX),
AdditionalSubPattern NVARCHAR(MAX),
MLAccuracy DECIMAL(10, 2),
Occurance INT,
CauseCode INT,
resolutioncode INT)

INSERT INTO #MAXIDS
	SELECT
		d.ID
		,d.TowerID
		,d.TicketPattern
		,d.SubPattern
		,d.AdditionalPattern
		,d.AdditionalSubPattern
		,d.MLAccuracy
		,d.TicketOccurence
		,d.MLCauseCodeID
		,d.MLResolutionCode
	FROM #DEBT_MLPATTERNVALIDATION D
	INNER JOIN #TMP_FINAL t
		ON t.TowerID = d.TowerID
		AND t.TicketPattern = d.TicketPattern
		AND t.SubPattern = d.SubPattern
		AND t.AdditionalPattern = d.AdditionalPattern
		AND t.AdditionalSubPattern = d.AdditionalSubPattern
		AND t.CauseCode = d.MLCauseCodeID
		AND t.ResolutionCode = d.MLResolutionCode
	WHERE ProjectID = @ProjectID
	AND IsDeleted = 0

DECLARE @OveridenCount INT
DECLARE @IsRegenerated CHAR(1)

SET @OveridenCount = (SELECT
		COUNT(OverridenPatternCount)
	FROM AVL.ML_TRN_MLPatternValidationInfra
	WHERE ProjectID = @ProjectID
	AND IsDeleted = 0
	AND OverridenPatternCount = 1)
SET @IsRegenerated = (SELECT TOP 1
		ISNULL(IsRegenerated, 0)
	FROM [AVL].ML_PRJ_InitialLearningStateInfra
	WHERE ProjectID = @ProjectID
	AND IsDeleted = 0
	ORDER BY id DESC)

UPDATE AVL.ML_TRN_MLPatternValidationInfra
SET OverridenPatternTotalCount = @OveridenCount

IF (@IsRegenerated = 1) BEGIN
DECLARE @LatestID INT

SET @LatestID = (SELECT TOP 1
		ID
	FROM [AVL].ML_PRJ_InitialLearningStateInfra
	WHERE ProjectID = @ProjectID
	AND IsDeleted = 0
	ORDER BY ID DESC)

UPDATE P
SET P.IsMLSignoff =
					CASE
						WHEN PD.IsMLSignOffInfra = 1 THEN 1
						ELSE 0
					END
FROM AVL.ML_TRN_MLPatternValidationInfra P
LEFT JOIN [AVL].[MAS_ProjectDebtDetails] PD
	ON PD.ProjectID = p.ProjectID
WHERE P.ProjectID = @ProjectID
AND p.IsDeleted = 0
AND PD.IsDeleted = 0
AND p.InitialLearningID <> @LatestID

UPDATE p
SET p.ISMLSignoff =
					CASE
						WHEN rg.ISMLSignoff = 1 THEN 1
						ELSE 0
					END
FROM AVL.ML_TRN_MLPatternValidationInfra p
LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails rg
	ON rg.ProjectID = p.ProjectID
	AND p.InitialLearningID = rg.InitialLearningID
WHERE p.ProjectID = @ProjectID
AND p.IsDeleted = 0
AND rg.IsDeleted = 0

UPDATE P
SET P.IsDeleted = 1
FROM AVL.ML_TRN_MLPatternValidationInfra P
LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails rg
	ON rg.ProjectID = p.ProjectID
	AND rg.TowerID = p.TowerID
WHERE rg.IsDeleted = 0
AND P.IsDeleted = 0
AND P.ProjectID = @ProjectID
AND P.InitialLearningID <> @LatestID
END ELSE BEGIN
UPDATE p
SET p.ISMLSignoff =
					CASE
						WHEN PD.IsMLSignOffInfra = 1 THEN 1
						ELSE 0
					END
FROM AVL.ML_TRN_MLPatternValidationInfra p
LEFT JOIN [AVL].[MAS_ProjectDebtDetails] PD
	ON PD.ProjectID = p.ProjectID
WHERE p.ProjectID = @ProjectID
AND p.IsDeleted = 0
AND PD.IsDeleted = 0
END

SELECT
	MAX(MLAccuracy) AS MLAccuracy
	,MAX(tickid) AS TickID
	,MAX(Occurance) AS Occurance
	,TowerID
	,TicketPattern
	,SubPattern
	,AdditionalPattern
	,AdditionalSubPattern
	,CauseCode
	,ResolutionCode INTO #TEMPMAXIDS
FROM #MAXIDS
GROUP BY	TowerID
			,TicketPattern
			,SubPattern
			,AdditionalPattern
			,AdditionalSubPattern
			,CauseCode
			,ResolutionCode

-- Existing Pattern -- 
SELECT
	ML.id
	,ISNULL(ML.InitialLearningID, 0) AS InitialLearningID
	,ISNULL(ML.TowerID, 0) AS TowerID
	,ISNULL(TD.TowerName, '') AS TowerName
	
	,TicketPattern
	,OverridenPatternTotalCount
	,ISNULL(ML.MLDebtClassificationID, 0) AS MLDebtClassificationID
	,ISNULL(AFM.[DebtClassificationName], '') AS MLDebtClassificationName
	,ISNULL(MLResidualFlagID, 0) AS MLResidualFlagID
	,ISNULL(AFMM.[ResidualDebtName], '') AS MLResidualFlagName
	,ISNULL(MLAvoidableFlagID, 0) AS MLAvoidableFlagID
	,ISNULL(AFMF.[AvoidableFlagName], '') AS MLAvoidableFlagName
	,ISNULL(MLCauseCodeID, 0) AS MLCauseCodeID
	,ISNULL(DCC.[CauseCode], '') AS MLCauseCodeName
	,MLAccuracy AS MLAccuracy
	,TicketOccurence
	,ISNULL(AnalystResolutionCodeID, 0) AS AnalystResolutionCodeID
	,ISNULL(DRC1.[ResolutionCode], '') AS AnalystResolutionCodeName
	,ISNULL(analystCauseCodeid, 0) AS AnalystCauseCodeID
	,ISNULL(DCC2.[causecode], '') AS AnalystCauseCodeName
	,ISNULL(analystdebtclassificationid, 0) AS AnalystDebtClassificationID
	,ISNULL(AFM1.DebtClassificationName, '') AS AnalystDebtClassificationName
	,ISNULL(AnalystAvoidableFlagID, 0) AS AnalystAvoidableFlagID
	,ISNULL(AFMF2.AvoidableFlagName, '') AS AnalystAvoidableFlagName
	,ISNULL(SMEComments, '') AS SMEComments
	,ISNULL(smeresidualflagid, 0) AS SMEResidualFlagID
	,ISNULL(AFMF5.[ResidualDebtName], '') AS SMEResidualFlagName
	,ISNULL(SMEDebtClassificationID, 0) AS SMEDebtClassificationID
	,ISNULL(AFM3.DebtClassificationName, '') AS SMEDebtClassificationName
	,ISNULL(SMEAvoidableFlagID, 0) AS SMEAvoidableFlagID
	,AFMF4.AvoidableFlagName AS SMEAvoidableFlagName
	,ISNULL(SMECauseCodeID, 0) AS SMECauseCodeID
	,ISNULL(IsApprovedOrMute, 0) AS IsApprovedOrMute
	,DCC1.[causecode] AS SMECauseCodeName
	,ISNULL(MLResolutionCode, '') AS MLResolutionCodeID
	,DRC.ResolutionCode AS MLResolutionCodeName
	,ISNULL(ML.SubPattern, '') AS SubPattern
	,ISNULL(Ml.AdditionalPattern, '') AS AdditionalPattern
	,ISNULL(ML.AdditionalSubPattern, '') AS AdditionalSubPattern
	,ISNULL(ML.ISMLSignoff, 0) AS ISMLSignoff
	,ISNULL(@IsRegenerated, 0) AS IsRegenerated INTO #TEMPEXT
FROM AVL.ML_TRN_MLPatternValidationInfra(NOLOCK) ML
JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDD
	ON PDD.ProjectID = @ProjectID
	--AND PDD.ISMLSignoff = 1
	JOIN AVL.InfraTowerProjectMapping TPM ON TPM.ProjectID=ML.ProjectID AND TPM.IsDeleted=0 AND TPM.IsEnabled=1 AND TPM.TowerID=ML.TowerID
JOIN AVL.InfraTowerDetailsTransaction TD ON TD.InfraTowerTransactionID=TPM.TowerID AND TD.CustomerID=@CustomerID AND TD.IsDeleted=0
LEFT JOIN [AVL].DEBT_MAS_DebtClassificationInfra AFM
	ON ML.MLDebtClassificationID = AFM.[debtclassificationid]
LEFT JOIN [AVL].[Debt_MAS_ResidualDebt] AFMM
	ON ML.MLResidualflagid = AFMM.[Residualdebtid]
LEFT JOIN [AVL].[Debt_MAS_AvoidableFlag] AFMF
	ON ML.MLAvoidableFlagID = AFMF.[avoidableflagid]
LEFT JOIN [AVL].[DEBT_MAP_CauseCode](NOLOCK) DCC
	ON ML.MLCauseCodeID = DCC.causeid
	AND DCC.ProjectID = @ProjectID
	AND DCC.IsDeleted = 0
LEFT JOIN [AVL].[debt_map_causecode](NOLOCK) DCC2
	ON ML.analystcausecodeid = DCC2.[causeid]
	AND DCC2.ProjectID = @ProjectID
	AND DCC2.IsDeleted = 0
LEFT JOIN [AVL].[debt_map_ResolutionCode](NOLOCK) DRC
	ON DRC.resolutionid = ML.MLResolutionCode
	AND DRC.ProjectID = @ProjectID
	AND DRC.IsDeleted = 0
LEFT JOIN [AVL].[debt_map_ResolutionCode](NOLOCK) DRC1
	ON ML.AnalystResolutionCodeID = DRC1.[resolutionid]
	AND DRC1.ProjectID = @ProjectID
	AND DRC1.IsDeleted = 0
LEFT JOIN [AVL].DEBT_MAS_DebtClassificationInfra AFM1
	ON ML.analystdebtclassificationid = AFM1.[debtclassificationid]
LEFT JOIN [AVL].[debt_mas_avoidableflag] AFMF2
	ON ML.AnalystAvoidableFlagID = AFMF2.[avoidableflagid]
LEFT JOIN [AVL].DEBT_MAS_DebtClassificationInfra AFM3
	ON ML.SMEDebtClassificationID = AFM3.[debtclassificationid]
LEFT JOIN [AVL].[debt_mas_avoidableflag] AFMF4
	ON ML.SMEAvoidableFlagID = AFMF4.[avoidableflagid]
LEFT JOIN [AVL].[debt_mas_residualdebt] AFMF5
	ON ML.smeresidualflagid = AFMF5.[residualdebtid]
LEFT JOIN [AVL].[debt_map_causecode](NOLOCK) DCC1
	ON ML.SMECauseCodeID = DCC1.[causeid]
	AND DCC1.ProjectID = @ProjectID
	AND DCC1.IsDeleted = 0
WHERE ML.ProjectID = @ProjectID
AND ML.IsDeleted = 0
AND ML.id IN (SELECT
		tickid
	FROM #TEMPMAXIDS)
AND TicketPattern <> '0'
AND (ML.MLCauseCodeID IS NOT NULL
OR ML.MLCauseCodeID <> 0)
AND (ML.MLResolutionCode IS NOT NULL
OR ML.MLResolutionCode <> 0)
AND (ML.MLDebtClassificationID IS NOT NULL
OR ML.MLDebtClassificationID <> 0)
AND (ML.MLAvoidableFlagID IS NOT NULL
OR ML.MLAvoidableFlagID <> 0)
AND (ML.MLResidualFlagID IS NOT NULL
OR ML.MLResidualFlagID <> 0)
AND TD.CustomerID = @CustomerID
--AND AM.isactive = 1
--AND ML.ISMLSignoff = 1
and
ML.InitialLearningID<>@LatestID

DECLARE @RowCount INT
DECLARE @ApproveCount INT
DECLARE @MuteCOunt INT

SET @RowCount = (SELECT
		COUNT(*)
	FROM #TEMPEXT)
SET @ApproveCount = (SELECT
		COUNT(*)
	FROM #TEMPEXT
	WHERE IsApprovedOrMute = 1)
SET @MuteCOunt = (SELECT
		COUNT(*)
	FROM #TEMPEXT
	WHERE IsApprovedOrMute = 2)

IF (@RowCount = @ApproveCount) BEGIN
SELECT
	*
	,1 AS IsApproved
FROM #TEMPEXT
END ELSE IF (@RowCount = @MuteCOunt) BEGIN
SELECT
	*
	,2 AS IsApproved
FROM #TEMPEXT
END ELSE BEGIN
SELECT
	*
	,0 AS IsApproved
FROM #TEMPEXT
END

COMMIT TRAN
END TRY BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()

ROLLBACK TRAN

--INSERT Error     
EXEC Avl_inserterror	'Ml_getviewallpattern '
						,@ErrorMessage
						,@ProjectID
						,0
END CATCH
END
