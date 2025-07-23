/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/



-- ============================================= 
-- Author:    627384 
-- Create date: 11-FEB-2019 
-- Description:   SP for Initial Learning 
-- [dbo][ML_FinalTicketDetailsforcallingML] 202 
-- =============================================  
CREATE PROC [dbo].[ML_FinalTicketDetailsforcallingMLInfra] --202 
  @ProjectID NVARCHAR(100) 
AS 
  BEGIN
 
      BEGIN TRY 
          --get the valid ticket detail for senting sampling or ml 
          DECLARE @CountForTicketValidates INT
 
          DECLARE @countforoptnull INT
 
          DECLARE @OptionalFieldID INT;
 
          DECLARE @PresenceOfOptional BIT;
 
          DECLARE @IsNoiseSkipAndContinue BIT;
 
          DECLARE @IsRegeneratedML BIT, 
                  @InitID          BIGINT;

 --Get the Flag for MultiLingual enabled for the project
DECLARE @IsMultiLingualEnabled int = 0

SET @IsMultiLingualEnabled = (SELECT ISNULL(PM.IsMultilingualEnabled,0) FROM AVL.MAS_ProjectMaster PM
WHERE PM.ProjectID = @ProjectID
AND PM.IsDeleted = 0)


SELECT MLT.ID,MLT.TimeTickerID,MLT.TicketDescription,MLT.IsTicketDescriptionUpdated,MLT.ResolutionRemarks,MLT.TicketSummary,MLT.Category,MLT.Comments,
MLT.IsCategoryUpdated,MLT.IsCommentsUpdated,MLT.IsTicketSummaryUpdated,MLT.IsFlexField1Updated,
MLT.IsFlexField2Updated,MLT.IsFlexField3Updated,MLT.IsFlexField4Updated,MLT.IsTypeUpdated,T.TicketID
INTO
#tmpMultilingualTranslatedValues 
FROM [AVL].TK_TRN_Multilingual_TranslatedInfraTicketDetails MLT
JOIN AVL.TK_TRN_TicketDetail T ON MLT.TimeTickerID= T.TimeTickerID 
AND T.ProjectID = @ProjectID
AND T.IsDeleted = 0

---------------------------------------------------------------------------------------

SET @IsRegeneratedML = (SELECT TOP 1
		ISNULL(IsRegenerated, 0)
	FROM AVL.ML_PRJ_InitialLearningStateInfra
	WHERE ProjectID = @ProjectID
	ORDER BY ID DESC)
SET @InitID = (SELECT TOP 1
		ID
	FROM AVL.ML_PRJ_InitialLearningStateInfra
	WHERE ProjectID = @ProjectID
	ORDER BY ID DESC)
SET @OptionalFieldID = (SELECT TOP 1
		OptionalFieldID
	FROM AVL.ML_MAP_OptionalProjMappingInfra
	WHERE ProjectId = @ProjectID
	AND IsDeleted = 0)

SELECT
	@IsNoiseSkipAndContinue = IsNoiseSkipped
FROM AVL.ML_PRJ_InitialLearningStateInfra
WHERE ProjectID = @ProjectID
AND IsDeleted = 0
AND IsNoiseEliminationSentorReceived = 'Received'

SET @CountForTicketValidates = (SELECT
		COUNT(DISTINCT TD.TicketID)
	FROM AVL.ML_TRN_TicketValidationInfra TD
	LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails RAG
		ON RAG.InitialLearningID = @InitID
		AND RAG.TowerID = TD.TowerID
		AND RAG.IsDeleted = 0
		AND RAG.ProjectID = TD.ProjectID

	WHERE TD.projectid = @ProjectID
	AND (@IsRegeneratedML = 0
	OR (@IsRegeneratedML = 1
	AND RAG.ID IS NOT NULL))

	AND TD.IsDeleted = 0)
SET @countforoptnull = (SELECT
		COUNT(DISTINCT TicketID)
	FROM AVL.ML_TRN_TicketValidationInfra TD
	LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails RAG
		ON RAG.InitialLearningID = @InitID
		AND RAG.TowerID = TD.TowerID
		AND RAG.IsDeleted = 0
		AND RAG.ProjectID = TD.ProjectID

	WHERE TD.ProjectID = @ProjectID
	AND TD.IsDeleted = 0
	AND (@IsRegeneratedML = 0
	OR (@IsRegeneratedML = 1
	AND RAG.ID IS NOT NULL))
	AND (TD.optionalfieldproj = ''
	OR TD.optionalfieldproj IS NULL))

IF ((@CountForTicketValidates = @countforoptnull
AND @OptionalFieldID <> 4)
OR @OptionalFieldID = 4) BEGIN
PRINT 4

SET @PresenceOfOptional = 0

--if optional field is not present  
SELECT DISTINCT
	DM.BUName AS DepartmentName
	,DAM.CustomerName AS AccountName
	,PM.EsaProjectID
	,TV.TicketID
	, CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(MLT.TicketDescription,'') != ''  THEN MLT.TicketDescription ELSE TV.TicketDescription END AS TicketDescription 
	 ,IOT.HierarchyName AS TowerHierarchy1
	,ITT.HierarchyName AS TowerHierarchy2
	,'' AS TechnologyName 
	,ITDT.TowerName AS Tower
	,AM.DebtClassificationName AS [DebtClassification]
	,AM1.AvoidableFlagName AS [AvoidableFlag]
	,AM2.[ResidualDebtName] AS [ResidualDebt]
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode] 
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode]
FROM AVL.ML_TRN_TicketValidationInfra TV
JOIN AVL.ML_PRJ_InitialLearningStateInfra ILS
	ON TV.ProjectID = ILS.ProjectID
	AND ILS.ID = @InitID
LEFT JOIN [AVL].[DEBT_MAS_DebtClassificationInfra] AM
	ON TV.DebtClassificationId = AM.DebtClassificationID
LEFT JOIN AVL.DEBT_MAS_AvoidableFlag AM1
	ON TV.AvoidableFlagID = AM1.AvoidableFlagID
LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] AM2
	ON TV.ResidualDebtID = AM2.ResidualDebtID
LEFT JOIN [AVL].[DEBT_MAP_CauseCode] AM3
	ON TV.CauseCodeID = AM3.CAUSEID
	AND TV.ProjectID = AM3.ProjectID
	AND AM3.IsDeleted = 0
LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] AM4
	ON TV.ResolutionCodeID = AM4.RESOLUTIONID
	AND TV.ProjectID = AM4.ProjectID
	AND AM3.IsDeleted = 0
LEFT JOIN [AVL].InfraTowerDetailsTransaction(NOLOCK) ITDT
	ON TV.TowerID = ITDT.InfraTowerTransactionID 
INNER JOIN AVL.InfraHierarchyMappingTransaction(NOLOCK) IHT
    ON IHT.CustomerID=ITDT.CustomerID 
	AND IHT.InfraTransMappingID=ITDT.InfraTransMappingID
	AND ISNULL(IHT.IsDeleted,0)=0  
INNER JOIN  AVL.InfraHierarchyOneTransaction(NOLOCK) IOT
    ON IHT.CustomerID=IOT.CustomerID 
    AND IHT.HierarchyOneTransactionID=IOT.HierarchyOneTransactionID 
	AND IOT.IsDeleted=0
INNER JOIN AVL.InfraHierarchyTwoTransaction(NOLOCK) ITT 
    ON IHT.CustomerID=ITT.CustomerID 
    AND IHT.HierarchyTwoTransactionID=ITT.HierarchyTwoTransactionID 
	AND ITT.IsDeleted=0 
INNER JOIN AVL.InfraTowerProjectMapping(NOLOCK) IPM  
    ON ITDT.InfraTowerTransactionID=IPM.TowerID
LEFT JOIN [AVL].[MAS_PROJECTMASTER] PM
	ON TV.ProjectID = PM.ProjectID
LEFT JOIN [AVL].[CUSTOMER] DAM
	ON PM.CustomerID = DAM.CustomerID
	AND DAM.IsDeleted = 0
LEFT JOIN [AVL].[BUSINESSUNIT] DM
	ON DAM.BUID = DM.BUID
	AND DM.IsDeleted = 0
LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails REG
	ON REG.InitialLearningID = @InitID
	AND REG.IsDeleted = 0
	AND REG.TowerID = TV.TowerID
	AND REG.ProjectID = TV.ProjectID
	LEFT JOIN #tmpMultilingualTranslatedValues MLT
                    ON  MLT.TicketID = TV.TicketID
WHERE ILS.IsDeleted = 0
AND TV.IsDeleted = 0
AND ILS.ProjectID = @ProjectID
AND ILS.IsNoiseEliminationSentorReceived = 'Received'
AND ((@IsRegeneratedML = 1
AND REG.ID IS NOT NULL)
OR (@IsRegeneratedML = 0))--if it transaction id is regenertaed or not ,if yes then that application details will only be selected

IF (@IsNoiseSkipAndContinue = 1) BEGIN
--noise elimination skipped means both noise words will be sent empt table
SELECT
	'' AS Word--Ticket desc 

SELECT
	'' AS Word--Optional noise words it is empty because it is not defined or it is null throughout  
END ELSE BEGIN
SELECT
	TicketDescNoiseWord AS Word
FROM AVL.ML_TICKETDESCNOISEWORDS
WHERE ProjectID = @ProjectID
AND IsActive = 0

SELECT
	'' AS Word--it is empty because it is not defined or it is null throughout evenif optional field is configured 
END
END ELSE IF (@OptionalFieldID <> 4) BEGIN
SET @PresenceOfOptional = 1

--optional field is present , then additional text data is sent  
SELECT DISTINCT
	DM.BUName AS DepartmentName
	,DAM.CustomerName AS AccountName
	,PM.EsaProjectID
	,TV.TicketID
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(MLT.TicketDescription,'') != ''  THEN MLT.TicketDescription ELSE TV.TicketDescription END AS TicketDescription 
	 ,IOT.HierarchyName AS TowerHierarchy1
	,ITT.HierarchyName AS TowerHierarchy2
	,'' AS TechnologyName 
	,ITDT.TowerName AS Tower
	,AM.DebtClassificationName AS [DebtClassification]
	,AM1.AvoidableFlagName AS [AvoidableFlag]
	,AM2.[ResidualDebtName] AS [ResidualDebt]
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode] 
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode]
	,TV.OptionalFieldProj AS AdditionalText
FROM AVL.ML_TRN_TicketValidationInfra TV
JOIN AVL.ML_PRJ_InitialLearningStateInfra ILS
	ON TV.ProjectID = ILS.ProjectID
	AND ILS.ID = @InitID
LEFT JOIN [AVL].[DEBT_MAS_DebtClassificationInfra] AM
	ON TV.DebtClassificationId = AM.DebtClassificationID
LEFT JOIN AVL.DEBT_MAS_AVOIDABLEFLAG AM1
	ON TV.AvoidableFlagID = AM1.AvoidableFlagID
LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] AM2
	ON TV.ResidualDebtID = AM2.ResidualDebtID
LEFT JOIN [AVL].[DEBT_MAP_CauseCode] AM3
	ON TV.CauseCodeID = AM3.CAUSEID
	AND TV.ProjectID = AM3.ProjectID
	AND AM3.IsDeleted = 0
LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] AM4
	ON TV.ResolutionCodeID = AM4.RESOLUTIONID
	AND TV.ProjectID = AM4.ProjectID
	AND AM3.IsDeleted = 0
LEFT JOIN [AVL].InfraTowerDetailsTransaction(NOLOCK) ITDT
	ON TV.TowerID = ITDT.InfraTowerTransactionID 
INNER JOIN AVL.InfraHierarchyMappingTransaction(NOLOCK) IHT
    ON IHT.CustomerID=ITDT.CustomerID 
	AND IHT.InfraTransMappingID=ITDT.InfraTransMappingID
	AND ISNULL(IHT.IsDeleted,0)=0  
INNER JOIN  AVL.InfraHierarchyOneTransaction(NOLOCK) IOT
    ON IHT.CustomerID=IOT.CustomerID 
    AND IHT.HierarchyOneTransactionID=IOT.HierarchyOneTransactionID 
	AND IOT.IsDeleted=0
INNER JOIN AVL.InfraHierarchyTwoTransaction(NOLOCK) ITT 
    ON IHT.CustomerID=ITT.CustomerID 
    AND IHT.HierarchyTwoTransactionID=ITT.HierarchyTwoTransactionID 
	AND ITT.IsDeleted=0 
INNER JOIN AVL.InfraTowerProjectMapping(NOLOCK) IPM  
    ON ITDT.InfraTowerTransactionID=IPM.TowerID
LEFT JOIN [AVL].[MAS_PROJECTMASTER] PM
	ON TV.ProjectID = PM.ProjectID
LEFT JOIN [AVL].[CUSTOMER] DAM
	ON PM.CustomerID = DAM.CustomerID
	AND DAM.IsDeleted = 0
LEFT JOIN [AVL].[BUSINESSUNIT] DM
	ON DAM.BUID = DM.BUID
	AND DM.IsDeleted = 0
LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails REG
	ON REG.InitialLearningID = @InitID
	AND REG.IsDeleted = 0
	AND REG.TowerID = TV.TowerID
	AND REG.ProjectID = TV.ProjectID
	LEFT JOIN #tmpMultilingualTranslatedValues MLT
                    ON  MLT.TicketID = TV.TicketID
WHERE ILS.IsDeleted = 0
AND TV.IsDeleted = 0
AND ILS.ProjectID = @ProjectID
AND ILS.IsNoiseEliminationSentorReceived = 'Received'
AND ((@IsRegeneratedML = 1
AND REG.ID IS NOT NULL)
OR (@IsRegeneratedML = 0))

IF (@IsNoiseSkipAndContinue = 1) BEGIN
SELECT
	'' AS Word

SELECT
	'' AS Word
END ELSE BEGIN
SELECT
	TicketDescNoiseWord AS Word
FROM AVL.ML_TicketDescNoiseWordsInfra
WHERE ProjectID = @ProjectID
AND IsDeleted = 1

SELECT
	OptionalFieldNoiseWord AS Word
FROM AVL.ML_OptionalFieldNoiseWordsInfra
WHERE ProjectID = @ProjectID
AND IsDeleted = 1
END
END

DECLARE @BUName VARCHAR(1000);
DECLARE @DepartmentAccountID VARCHAR(MAX);
DECLARE @DepartmentID VARCHAR(MAX);
DECLARE @AccountName VARCHAR(MAX);
DECLARE @ProjectName VARCHAR(MAX);
DECLARE @InitialLearningId INT;

SET @ProjectName = (SELECT
		ProjectName
	FROM [AVL].[MAS_PROJECTMASTER]
	WHERE ProjectID = @ProjectID
	AND IsDeleted = 0)
SET @DepartmentAccountID = (SELECT
		CustomerID
	FROM [AVL].[MAS_PROJECTMASTER]
	WHERE ProjectID = @ProjectID
	AND IsDeleted = 0)
SET @AccountName = (SELECT
		CustomerName
	FROM [AVL].[CUSTOMER]
	WHERE CustomerID = @DepartmentAccountID
	AND IsDeleted = 0)
SET @DepartmentID = (SELECT
		BUID
	FROM [AVL].[CUSTOMER]
	WHERE CustomerID = @DepartmentAccountID
	AND IsDeleted = 0)
SET @BUName = (SELECT
		BUName
	FROM [AVL].[BUSINESSUNIT]
	WHERE BUID = @DepartmentID
	AND IsDeleted = 0)

PRINT @BUName

PRINT @AccountName

PRINT @ProjectName

SET @InitialLearningId = (SELECT TOP 1
		ID
	FROM AVL.ML_PRJ_InitialLearningStateInfra
	WHERE ProjectID = @ProjectID
	AND IsNoiseEliminationSentorReceived = 'Received'
	ORDER BY ID DESC)

DECLARE @BUtext NVARCHAR(128) = @BUName

SET @BUName = (SELECT
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@BUtext, '-', ''), '@', ''), '#', ''), '$', ''), '/', ''), ',', ''), '.', ''), '*', ''), '%', ''
		))

DECLARE @Acctext NVARCHAR(128) = @AccountName

SET @AccountName = (SELECT
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Acctext, '-', ''), '@', ''), '#', ''), '$', ''), '/', ''), ',', ''), '.', ''), '*', ''),
		'%'
		, ''
		))

DECLARE @Prjtext NVARCHAR(128) = @ProjectName

SET @ProjectName = (SELECT
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Prjtext, '-', ''), '@', ''), '#', ''), '$', ''), '/', ''), ',', ''), '.', ''), '*', ''),
		'%'
		, ''
		))

--buname,accname,projectname,initial learning     
SELECT
	REPLACE(@BUName, ' ', '_') AS BUName
	,REPLACE(@AccountName, ' ', '_') AS AccountName
	,REPLACE(@ProjectName, ' ', '_') AS ProjectName
	,@InitialLearningId AS InitialLearningId
	,@OptionalFieldID AS OptionalFieldID
	,@PresenceOfOptional AS 'PresenceOfOptional'
END TRY BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()

--INSERT Error     
EXEC AVL_INSERTERROR	'[dbo].[ML_FinalTicketDetailsforcallingML] '
						,@ErrorMessage
						,@ProjectID
						,0
END CATCH
END
