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

-- USERID    USER      MODIFIED DATE   REASON
-- 687591    MENAKA   29-5-2019        Included MultiLingual code
-- =============================================    
CREATE PROCEDURE [dbo].[ML_GetSamplingDetailsForML]  
  @ProjectID NVARCHAR(50) 
AS 
  BEGIN
SET NOCOUNT ON;
BEGIN TRY
DECLARE @CountForTicketValidates INT;

DECLARE @countforoptnull INT;

DECLARE @OptionalFieldID INT;

DECLARE @PresenceOfOptional BIT;

DECLARE @IsNoiseSkipAndContinue BIT;

DECLARE @IsRegenerated INT = 0;

DECLARE @LatestID INT = 0
DECLARE @StartDate DATETIME,@EndDate DATETIME
SELECT TOP 1 @StartDate=StartDate,@EndDate=EndDate from AVL.ML_PRJ_InitialLearningState WHERE ProjectID=@ProjectID AND IsDeleted=0 ORDER BY ID DESC

--Get the Flag for MultiLingual enabled for the project
DECLARE @IsMultiLingualEnabled int = 0

SET @IsMultiLingualEnabled = (SELECT ISNULL(PM.IsMultilingualEnabled,0) FROM AVL.MAS_ProjectMaster PM
WHERE PM.ProjectID = @ProjectID
AND PM.IsDeleted = 0)
--------------------------------------------------------------
SELECT
	TicketID
	,ApplicationID
	,DebtClassificationMapID
	,AvoidableFlag
	,ResidualDebtMapID
	,CauseCodeMapID
	,ResolutionCodeMapID INTO #tmpml
FROM avl.TK_TRN_TICKETDETAIL(NOLOCK)
WHERE Projectid = @ProjectID
AND Isdeleted = 0
AND Dartstatusid = 8
AND Closeddate BETWEEN @StartDate AND @EndDate

--after sampling getting the ticket details for sending ml    
--optional field id   
SET @OptionalFieldID = (SELECT TOP 1
		Optionalfieldid
	FROM avl.ML_MAP_OPTIONALPROJMAPPING(NOLOCK)
	WHERE Projectid = @ProjectID
	AND Isactive = 1)
--Latest  transaction id for initial learning   
SET @LatestID = (SELECT TOP 1
		Id
	FROM [AVL].[ML_PRJ_INITIALLEARNINGSTATE]
	WHERE Projectid = @ProjectID
	AND Isdeleted = 0
	ORDER BY Id DESC)

PRINT @LatestID

--IsRegenerated flag for latest transaction id   
SET @IsRegenerated = (SELECT TOP 1
		ISNULL(Isregenerated, 0)
	FROM [AVL].[ML_PRJ_INITIALLEARNINGSTATE](NOLOCK)
	WHERE Projectid = @ProjectID
	AND Id = @LatestID)

--get isnoiseskipped flag to check whether noise elimination is skipped or not ,if it is skipped then we will sent blank excel for desc and optional noise words
SELECT
	@IsNoiseSkipAndContinue = Isnoiseskipped
FROM avl.ML_PRJ_INITIALLEARNINGSTATE
WHERE Projectid = @ProjectID
AND Isdeleted = 0
AND Isnoiseeliminationsentorreceived = 'Recieved'

SET @CountForTicketValidates = (SELECT
		COUNT(Ticketid)
	FROM avl.ML_TRN_TICKETVALIDATION(NOLOCK) TD
	LEFT JOIN AVL.ML_TRN_RegeneratedApplicationDetails(NOLOCK) RAG
		ON RAG.InitialLearningID = @LatestID
		AND RAG.ApplicationID = TD.ApplicationID
		AND RAG.IsDeleted = 0
		AND RAG.ProjectID = TD.ProjectID
	WHERE TD.projectid = @ProjectID
	AND (@IsRegenerated = 0
	OR (@IsRegenerated = 1
	AND RAG.ID IS NOT NULL))
	AND TD.IsDeleted = 0)
SET @countforoptnull = (SELECT
		COUNT(Ticketid)
	FROM avl.ML_TRN_TICKETVALIDATION(NOLOCK) TD
	LEFT JOIN AVL.ML_TRN_RegeneratedApplicationDetails(NOLOCK) RAG
		ON RAG.InitialLearningID = @LatestID
		AND RAG.ApplicationID = TD.ApplicationID
		AND RAG.IsDeleted = 0
		AND RAG.ProjectID = TD.ProjectID
	WHERE TD.ProjectID = @ProjectID
	AND TD.IsDeleted = 0
	AND (@IsRegenerated = 0
	OR (@IsRegenerated = 1
	AND RAG.ID IS NOT NULL))
	AND (TD.optionalfieldproj = ''
	OR TD.optionalfieldproj IS NULL))

IF (@IsRegenerated = 0) BEGIN
--if it is not regenerated then every application in ticketvalidation table is considered   
IF ((@CountForTicketValidates = @countforoptnull
AND @OptionalFieldID <> 4)
OR @OptionalFieldID = 4) BEGIN
SET @PresenceOfOptional = 0

--optional field is not  present   
PRINT @PresenceOfOptional

--sampled tickets from ticketsaftersampling table for that specific projectid    
SELECT
	DM.Buname AS DepartmentName
	,DAM.Customername AS AccountName
	,PM.EsaProjectID
	,A.TicketID
	
	,AMR.ApplicationName
	,AT.ApplicationTypename
	,MT.Primarytechnologyname AS TechnologyName
	,
	AM.Debtclassificationname AS [DebtClassification]
	,AM1.Avoidableflagname AS [AvoidableFlag]
	,AM2.[Residualdebtname] AS [ResidualDebt]
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode] 
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode] ,A.Desc_Base_WorkPattern,
	A.Desc_Sub_WorkPattern,A.Res_Base_WorkPattern,A.Res_Sub_WorkPattern
FROM avl.ML_TRN_TICKETSAFTERSAMPLING(nolock) A
JOIN #tmpml(nolock) TD
	ON A.Projectid = @ProjectID
	AND A.Initiallearningid = @LatestID
	AND TD.Ticketid = A.Ticketid
	AND A.Isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION](nolock)
AM
	ON TD.Debtclassificationmapid =
	AM.Debtclassificationid
LEFT JOIN avl.DEBT_MAS_AVOIDABLEFLAG(nolock) AM1
	ON TD.Avoidableflag = AM1.Avoidableflagid
LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT](nolock) AM2
	ON TD.Residualdebtmapid = AM2.Residualdebtid
LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE](nolock) AM3
	ON TD.Causecodemapid = AM3.Causeid
	AND A.Projectid = AM3.Projectid
	AND AM3.Projectid = @ProjectID
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE](nolock)
AM4
	ON TD.Resolutioncodemapid = AM4.Resolutionid
	AND AM4.Projectid = @ProjectID
	AND A.Projectid = AM4.Projectid
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[APP_MAS_APPLICATIONDETAILS](nolock)
AMR
	ON A.Applicationid = AMR.Applicationid
LEFT JOIN [AVL].[APP_MAS_OWNERSHIPDETAILS](nolock)
AT
	ON AMR.Codeownership = AT.Applicationtypeid
LEFT JOIN [AVL].[APP_MAS_PRIMARYTECHNOLOGY](nolock)
MT
	ON AMR.Primarytechnologyid =
	MT.Primarytechnologyid
LEFT JOIN [AVL].[MAS_PROJECTMASTER](nolock) PM
	ON A.Projectid = PM.Projectid
LEFT JOIN [AVL].[CUSTOMER](nolock) DAM
	ON PM.Customerid = DAM.Customerid
	AND DAM.Isdeleted = 0
LEFT JOIN [AVL].[BUSINESSUNIT](nolock) DM
	ON DAM.Buid = DM.Buid
	AND DM.Isdeleted = 0
WHERE A.Projectid = @ProjectID
AND A.Isdeleted = 0
AND A.Desc_base_workpattern <> '0' UNION
--Tickets with all debt fields filled from ticketvalidation table for that specific projectid which is not present in sampling ticket table
SELECT
	DM.Buname AS DepartmentName
	,DAM.Customername AS AccountName
	,PM.EsaProjectID
	,TV.TicketID
	,AMR.ApplicationName
	,AT.ApplicationTypename
	,MT.Primarytechnologyname AS TechnologyName
	,
	AM.Debtclassificationname AS [DebtClassification]
	,AM1.Avoidableflagname AS [AvoidableFlag]
	,AM2.[Residualdebtname] AS [ResidualDebt]
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode] 
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode] ,
	'' AS Desc_Base_WorkPattern,
	'' AS Desc_Sub_WorkPattern,'' AS Res_Base_WorkPattern,'' AS Res_Sub_WorkPattern
FROM avl.ML_TRN_TICKETVALIDATION(nolock) TV
JOIN #tmpml(nolock) TD ON TV.TicketID=TD.TicketID AND TV.ProjectID=@ProjectID
LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] AM
	ON TV.Debtclassificationid =
	AM.Debtclassificationid
	AND TV.Projectid = @ProjectID
	AND TV.Isdeleted = 0
LEFT JOIN avl.DEBT_MAS_AVOIDABLEFLAG AM1
	ON TV.Avoidableflagid = AM1.Avoidableflagid
LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] AM2
	ON TV.Residualdebtid = AM2.Residualdebtid
INNER JOIN [AVL].[DEBT_MAP_CAUSECODE] AM3
	ON TV.Causecodeid = AM3.Causeid
	AND TV.Projectid = AM3.Projectid
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] AM4
	ON TV.Resolutioncodeid = AM4.Resolutionid
	AND TV.Projectid = AM4.Projectid
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[APP_MAS_APPLICATIONDETAILS] AMR
	ON TV.Applicationid = AMR.Applicationid
LEFT JOIN [AVL].[APP_MAS_OWNERSHIPDETAILS] AT
	ON AMR.Codeownership = AT.Applicationtypeid
LEFT JOIN [AVL].[APP_MAS_PRIMARYTECHNOLOGY] MT
	ON AMR.Primarytechnologyid =
	MT.Primarytechnologyid
LEFT JOIN [AVL].[MAS_PROJECTMASTER] PM
	ON TV.Projectid = PM.Projectid
LEFT JOIN [AVL].[CUSTOMER] DAM
	ON PM.Customerid = DAM.Customerid
	AND DAM.Isdeleted = 0
LEFT JOIN [AVL].[BUSINESSUNIT] DM
	ON DAM.Buid = DM.Buid
	AND DM.Isdeleted = 0
WHERE TV.Projectid = @ProjectID
AND TV.Isdeleted = 0
AND NOT EXISTS (SELECT
		Ticketid
	FROM avl.ML_TRN_TICKETSAFTERSAMPLING TS
	WHERE TS.Ticketid = TV.Ticketid
	AND TS.Projectid = TV.Projectid
	AND TV.Projectid = @ProjectID
	AND TV.Isdeleted = 0)
AND (TV.Causecodeid IS NOT NULL
OR TV.Causecodeid <> 0)
AND (TV.Resolutioncodeid IS NOT NULL
OR TV.Resolutioncodeid <> 0)
AND (TV.Debtclassificationid IS NOT NULL
OR TV.Debtclassificationid <> 0)
AND (TV.Avoidableflagid IS NOT NULL
OR TV.Avoidableflagid <> 0)
AND (TV.Residualdebtid IS NOT NULL
OR TV.Residualdebtid <> 0)

IF (@IsNoiseSkipAndContinue = 1) BEGIN
--if it skipped then noise words are sent as empty   
--Ticketdesc   
SELECT
	'' AS Word

--optional field   
SELECT
	'' AS Word
END ELSE BEGIN
--if it is not skipped then tdesc words are sent ,optional words are not sent as presence of optional field=0
SELECT
	Ticketdescnoiseword AS Word
FROM avl.ML_TICKETDESCNOISEWORDS
WHERE Projectid = @ProjectID
AND Isactive = 0

SELECT
	'' AS Word
END
END ELSE IF (@OptionalFieldID <> 4) BEGIN
SET @PresenceOfOptional = 1

PRINT @PresenceOfOptional

--Optional field is sent   
SELECT
	DM.Buname AS DepartmentName
	,DAM.Customername AS AccountName
	,PM.EsaProjectID
	,TV.TicketID
	,AMR.ApplicationName
	,AT.ApplicationTypename
	,MT.Primarytechnologyname AS TechnologyName
	,
	AM.Debtclassificationname AS [DebtClassification]
	,AM1.Avoidableflagname AS [AvoidableFlag]
	,AM2.[Residualdebtname] AS [ResidualDebt]
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode] 
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode] 
	,
	TV.Desc_Base_WorkPattern,
	TV.Desc_Sub_WorkPattern,TV.Res_Base_WorkPattern,TV.Res_Sub_WorkPattern
FROM avl.ML_TRN_TICKETSAFTERSAMPLING(nolock) TV
JOIN #tmpml TD
	ON TV.Projectid = @ProjectID
	AND TV.Initiallearningid = @LatestID
	AND TD.Ticketid = TV.Ticketid
	AND TD.Applicationid = TV.Applicationid
LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION](nolock)
AM
	ON TD.Debtclassificationmapid =
	AM.Debtclassificationid
LEFT JOIN avl.DEBT_MAS_AVOIDABLEFLAG(nolock) AM1
	ON TD.Avoidableflag = AM1.Avoidableflagid
LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT](nolock) AM2
	ON TD.Residualdebtmapid = AM2.Residualdebtid
LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE](nolock) AM3
	ON TD.Causecodemapid = AM3.Causeid
	AND AM3.Projectid = @ProjectID
	AND TV.Projectid = AM3.Projectid
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE](nolock)
AM4
	ON TD.Resolutioncodemapid = AM4.Resolutionid
	AND AM4.Projectid = @ProjectID
	AND TV.Projectid = AM4.Projectid
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[APP_MAS_APPLICATIONDETAILS](nolock)
AMR
	ON TV.Applicationid = AMR.Applicationid
LEFT JOIN [AVL].[APP_MAS_OWNERSHIPDETAILS](nolock)
AT
	ON AMR.Codeownership = AT.Applicationtypeid
LEFT JOIN [AVL].[APP_MAS_PRIMARYTECHNOLOGY](nolock)
MT
	ON AMR.Primarytechnologyid =
	MT.Primarytechnologyid
LEFT JOIN [AVL].[MAS_PROJECTMASTER](nolock) PM
	ON TV.Projectid = PM.Projectid
LEFT JOIN [AVL].[CUSTOMER](nolock) DAM
	ON PM.Customerid = DAM.Customerid
	AND DAM.Isdeleted = 0
LEFT JOIN [AVL].[BUSINESSUNIT](nolock) DM
	ON DAM.Buid = DM.Buid
	AND DM.Isdeleted = 0
WHERE TV.Projectid = @ProjectID
AND TV.Isdeleted = 0
AND TV.Desc_base_workpattern <> '0' UNION SELECT
	DM.Buname AS DepartmentName
	,DAM.Customername AS AccountName
	,PM.Esaprojectid
	,TV.TicketID
	,AMR.ApplicationName
	,AT.ApplicationTypename
	,MT.Primarytechnologyname AS TechnologyName
	,
	AM.Debtclassificationname AS [DebtClassification]
	,AM1.Avoidableflagname AS [AvoidableFlag]
	,AM2.[Residualdebtname] AS [ResidualDebt]
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode] 
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode] 
	,
	'' AS  Desc_Base_WorkPattern,
	'' AS Desc_Sub_WorkPattern,'' AS Res_Base_WorkPattern,'' AS Res_Sub_WorkPattern
FROM avl.ML_TRN_TICKETVALIDATION TV
JOIN #tmpml(nolock) TD ON TV.TicketID=TD.TicketID AND TV.ProjectID=@ProjectID
LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] AM
	ON TV.Debtclassificationid =
	AM.Debtclassificationid
	AND TV.Projectid = @ProjectID
	AND TV.Isdeleted = 0
LEFT JOIN avl.DEBT_MAS_AVOIDABLEFLAG AM1
	ON TV.Avoidableflagid = AM1.Avoidableflagid
LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] AM2
	ON TV.Residualdebtid = AM2.Residualdebtid
LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE] AM3
	ON TV.Causecodeid = AM3.Causeid
	AND TV.Projectid = AM3.Projectid
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] AM4
	ON TV.Resolutioncodeid = AM4.Resolutionid
	AND TV.Projectid = AM4.Projectid
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[APP_MAS_APPLICATIONDETAILS] AMR
	ON TV.Applicationid = AMR.Applicationid
LEFT JOIN [AVL].[APP_MAS_OWNERSHIPDETAILS] AT
	ON AMR.Codeownership = AT.Applicationtypeid
LEFT JOIN [AVL].[APP_MAS_PRIMARYTECHNOLOGY] MT
	ON AMR.Primarytechnologyid =
	MT.Primarytechnologyid
LEFT JOIN [AVL].[MAS_PROJECTMASTER] PM
	ON TV.Projectid = PM.Projectid
LEFT JOIN [AVL].[CUSTOMER] DAM
	ON PM.Customerid = DAM.Customerid
	AND DAM.Isdeleted = 0
LEFT JOIN [AVL].[BUSINESSUNIT] DM
	ON DAM.Buid = DM.Buid
	AND DM.Isdeleted = 0
WHERE TV.Projectid = @ProjectID
AND TV.Isdeleted = 0
AND NOT EXISTS (SELECT
		Ticketid
	FROM avl.ML_TRN_TICKETSAFTERSAMPLING TS
	WHERE TS.Ticketid = TV.Ticketid
	AND TS.Projectid = TV.Projectid
	AND TV.Projectid = @ProjectID
	AND TV.Isdeleted = 0)
AND (TV.Causecodeid IS NOT NULL
OR TV.Causecodeid <> 0)
AND (TV.Resolutioncodeid IS NOT NULL
OR TV.Resolutioncodeid <> 0)
AND (TV.Debtclassificationid IS NOT NULL
OR TV.Debtclassificationid <> 0)
AND (TV.Avoidableflagid IS NOT NULL
OR TV.Avoidableflagid <> 0)
AND (TV.Residualdebtid IS NOT NULL
OR TV.Residualdebtid <> 0)

IF (@IsNoiseSkipAndContinue = 1) BEGIN
SELECT
	'' AS Word

SELECT
	'' AS Word
END ELSE BEGIN
-- optional field noise words is also sent  only excluded words   
SELECT
	Ticketdescnoiseword AS Word
FROM avl.ML_TICKETDESCNOISEWORDS
WHERE Projectid = @ProjectID
AND Isactive = 0

SELECT
	Optionalfieldnoiseword AS Word
FROM avl.ML_OPTIONALFIELDNOISEWORDS
WHERE Projectid = @ProjectID
AND Isactive = 0
END
END
END ELSE IF (@IsRegenerated = 1) BEGIN
-- same for isregenerated trn id but only regenerted application ticket details will be sent   
IF ((@CountForTicketValidates = @countforoptnull
AND @OptionalFieldID <> 4)
OR @OptionalFieldID = 4) BEGIN
SET @PresenceOfOptional = 0

PRINT @PresenceOfOptional

SELECT
	DM.Buname AS DepartmentName
	,DAM.Customername AS AccountName
	,PM.EsaProjectID
	,A.TicketID
	
	,AMR.ApplicationName
	,AT.ApplicationTypename
	,MT.Primarytechnologyname AS TechnologyName
	,
	AM.Debtclassificationname AS [DebtClassification]
	,AM1.Avoidableflagname AS [AvoidableFlag]
	,AM2.[Residualdebtname] AS [ResidualDebt]
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode] 
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode] ,
	A.Desc_Base_WorkPattern,
	A.Desc_Sub_WorkPattern,A.Res_Base_WorkPattern,A.Res_Sub_WorkPattern
FROM avl.ML_TRN_TICKETSAFTERSAMPLING(nolock) A
JOIN #tmpml TD
	ON A.Projectid = @ProjectID
	AND A.Initiallearningid = @LatestID
	AND TD.Ticketid = A.Ticketid
	AND A.Isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] AM
	ON TD.Debtclassificationmapid =
	AM.Debtclassificationid
LEFT JOIN avl.DEBT_MAS_AVOIDABLEFLAG AM1
	ON TD.Avoidableflag = AM1.Avoidableflagid
LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] AM2
	ON TD.Residualdebtmapid = AM2.Residualdebtid
LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE] AM3
	ON TD.Causecodemapid = AM3.Causeid
	AND AM3.Projectid = @ProjectID
	AND A.Projectid = AM3.Projectid
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] AM4
	ON TD.Resolutioncodemapid = AM4.Resolutionid
	AND AM4.Projectid = @ProjectID
	AND A.Projectid = AM4.Projectid
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[APP_MAS_APPLICATIONDETAILS] AMR
	ON A.Applicationid = AMR.Applicationid
LEFT JOIN [AVL].[APP_MAS_OWNERSHIPDETAILS] AT
	ON AMR.Codeownership = AT.Applicationtypeid
LEFT JOIN [AVL].[APP_MAS_PRIMARYTECHNOLOGY] MT
	ON AMR.Primarytechnologyid =
	MT.Primarytechnologyid
LEFT JOIN [AVL].[MAS_PROJECTMASTER] PM
	ON A.Projectid = PM.Projectid
LEFT JOIN [AVL].[CUSTOMER] DAM
	ON PM.Customerid = DAM.Customerid
	AND DAM.Isdeleted = 0
LEFT JOIN [AVL].[BUSINESSUNIT] DM
	ON DAM.Buid = DM.Buid
	AND DM.Isdeleted = 0
INNER JOIN avl.ML_TRN_REGENERATEDAPPLICATIONDETAILS
rg
	ON rg.Projectid = A.Projectid
	AND rg.Isdeleted = 0
	AND rg.Initiallearningid = @LatestID
	AND rg.Applicationid = A.Applicationid
WHERE A.Projectid = @ProjectID
AND A.Isdeleted = 0
AND A.Desc_base_workpattern <> '0' UNION SELECT
	DM.Buname AS DepartmentName
	,DAM.Customername AS AccountName
	,PM.EsaProjectID
	,TV.TicketID
	
	,AMR.ApplicationName
	,AT.ApplicationTypename
	,MT.Primarytechnologyname AS TechnologyName
	,
	AM.Debtclassificationname AS [DebtClassification]
	,AM1.Avoidableflagname AS [AvoidableFlag]
	,AM2.[Residualdebtname] AS [ResidualDebt]
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode] 
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode] ,
	'' AS Desc_Base_WorkPattern,
	'' AS Desc_Sub_WorkPattern,'' AS Res_Base_WorkPattern,'' AS Res_Sub_WorkPattern
FROM avl.ML_TRN_TICKETVALIDATION(nolock) TV
JOIN #tmpml(nolock) TD ON TV.TicketID=TD.TicketID AND TV.ProjectID=@ProjectID
LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION](nolock)
AM
	ON TV.Debtclassificationid =
	AM.Debtclassificationid
	AND TV.Projectid = @ProjectID
	AND TV.Isdeleted = 0
LEFT JOIN avl.DEBT_MAS_AVOIDABLEFLAG(nolock) AM1
	ON TV.Avoidableflagid = AM1.Avoidableflagid
LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT](nolock) AM2
	ON TV.Residualdebtid = AM2.Residualdebtid
INNER JOIN [AVL].[DEBT_MAP_CAUSECODE](nolock) AM3
	ON TV.Causecodeid = AM3.Causeid
	AND TV.Projectid = AM3.Projectid
	AND AM3.Projectid = @ProjectID
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE](nolock)
AM4
	ON TV.Resolutioncodeid = AM4.Resolutionid
	AND TV.Projectid = AM4.Projectid
	AND AM4.Projectid = @ProjectID
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[APP_MAS_APPLICATIONDETAILS](nolock)
AMR
	ON TV.Applicationid = AMR.Applicationid

LEFT JOIN [AVL].[APP_MAS_OWNERSHIPDETAILS](nolock)
AT
	ON AMR.Codeownership = AT.Applicationtypeid
LEFT JOIN [AVL].[APP_MAS_PRIMARYTECHNOLOGY](nolock)
MT
	ON AMR.Primarytechnologyid =
	MT.Primarytechnologyid
LEFT JOIN [AVL].[MAS_PROJECTMASTER](nolock) PM
	ON TV.Projectid = PM.Projectid
LEFT JOIN [AVL].[CUSTOMER](nolock) DAM
	ON PM.Customerid = DAM.Customerid
	AND DAM.Isdeleted = 0
LEFT JOIN [AVL].[BUSINESSUNIT](nolock) DM
	ON DAM.Buid = DM.Buid
	AND DM.Isdeleted = 0
INNER JOIN avl.ML_TRN_REGENERATEDAPPLICATIONDETAILS(nolock)
rg
	ON rg.Projectid = TV.Projectid
	AND rg.Isdeleted = 0
	AND rg.Initiallearningid = @LatestID
	AND rg.Applicationid = TV.Applicationid
WHERE TV.Projectid = @ProjectID
AND TV.Isdeleted = 0
AND NOT EXISTS (SELECT
		Ticketid
	FROM avl.ML_TRN_TICKETSAFTERSAMPLING TS
	WHERE TS.Ticketid = TV.Ticketid
	AND TS.Projectid = TV.Projectid
	AND TV.Projectid = @ProjectID
	AND TV.Isdeleted = 0)
AND (TV.Causecodeid IS NOT NULL
OR TV.Causecodeid <> 0)
AND (TV.Resolutioncodeid IS NOT NULL
OR TV.Resolutioncodeid <> 0)
AND (TV.Debtclassificationid IS NOT NULL
OR TV.Debtclassificationid <> 0)
AND (TV.Avoidableflagid IS NOT NULL
OR TV.Avoidableflagid <> 0)
AND (TV.Residualdebtid IS NOT NULL
OR TV.Residualdebtid <> 0)

IF (@IsNoiseSkipAndContinue = 1) BEGIN
SELECT
	'' AS Word

SELECT
	'' AS Word
END ELSE BEGIN
SELECT
	Ticketdescnoiseword AS Word
FROM avl.ML_TICKETDESCNOISEWORDS
WHERE Projectid = @ProjectID
AND Isactive = 0

SELECT
	'' AS Word
END
END ELSE IF (@OptionalFieldID <> 4) BEGIN
SET @PresenceOfOptional = 1

PRINT @PresenceOfOptional

SELECT
	DM.Buname AS DepartmentName
	,DAM.Customername AS AccountName
	,PM.EsaProjectID
	,TV.TicketID
	,AMR.ApplicationName
	,AT.ApplicationTypename
	,MT.Primarytechnologyname AS TechnologyName
	,
	AM.Debtclassificationname AS [DebtClassification]
	,AM1.Avoidableflagname AS [AvoidableFlag]
	,AM2.[Residualdebtname] AS [ResidualDebt]
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode] 
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode] 
	,
	TV.Desc_Base_WorkPattern,
	TV.Desc_Sub_WorkPattern,TV.Res_Base_WorkPattern,TV.Res_Sub_WorkPattern
FROM avl.ML_TRN_TICKETSAFTERSAMPLING(nolock) TV
JOIN #tmpml TD
	ON TV.Projectid = @ProjectID
	AND TV.Initiallearningid = @LatestID
	AND TD.Ticketid = TV.Ticketid
	AND TV.Isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] AM
	ON TD.Debtclassificationmapid =
	AM.Debtclassificationid
LEFT JOIN avl.DEBT_MAS_AVOIDABLEFLAG AM1
	ON TD.Avoidableflag = AM1.Avoidableflagid
LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] AM2
	ON TD.Residualdebtmapid = AM2.Residualdebtid
LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE] AM3
	ON TD.Causecodemapid = AM3.Causeid
	AND AM3.Projectid = @ProjectID
	AND TV.Projectid = AM3.Projectid
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] AM4
	ON TD.Resolutioncodemapid = AM4.Resolutionid
	AND AM4.Projectid = @ProjectID
	AND TV.Projectid = AM4.Projectid
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[APP_MAS_APPLICATIONDETAILS] AMR
	ON TV.Applicationid = AMR.Applicationid
LEFT JOIN [AVL].[APP_MAS_OWNERSHIPDETAILS] AT
	ON AMR.Codeownership = AT.Applicationtypeid
LEFT JOIN [AVL].[APP_MAS_PRIMARYTECHNOLOGY] MT
	ON AMR.Primarytechnologyid =
	MT.Primarytechnologyid
LEFT JOIN [AVL].[MAS_PROJECTMASTER] PM
	ON TV.Projectid = PM.Projectid
LEFT JOIN [AVL].[CUSTOMER] DAM
	ON PM.Customerid = DAM.Customerid
	AND DAM.Isdeleted = 0
LEFT JOIN [AVL].[BUSINESSUNIT] DM
	ON DAM.Buid = DM.Buid
	AND DM.Isdeleted = 0
INNER JOIN avl.ML_TRN_REGENERATEDAPPLICATIONDETAILS
rg
	ON rg.Projectid = TV.Projectid
	AND rg.Isdeleted = 0
	AND rg.Initiallearningid = @LatestID
	AND rg.Applicationid = TV.Applicationid
	AND rg.Projectid = @ProjectID
WHERE TV.Projectid = @ProjectID
AND TV.Isdeleted = 0
AND TV.Desc_base_workpattern <> '0' UNION SELECT
	DM.Buname AS DepartmentName
	,DAM.Customername AS AccountName
	,PM.EsaProjectID
	,TV.TicketID
	,AMR.ApplicationName
	,AT.Applicationtypename
	,MT.Primarytechnologyname AS TechnologyName
	,
	AM.Debtclassificationname AS [DebtClassification]
	,AM1.Avoidableflagname AS [AvoidableFlag]
	,AM2.[Residualdebtname] AS [ResidualDebt]
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode] 
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode] 
	,
	'' AS Desc_Base_WorkPattern,
	'' AS Desc_Sub_WorkPattern,'' AS Res_Base_WorkPattern,''  AS Res_Sub_WorkPattern
FROM avl.ML_TRN_TICKETVALIDATION TV
JOIN #tmpml(nolock) TD ON TV.TicketID=TD.TicketID AND TV.ProjectID=@ProjectID
LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] AM
	ON TV.Debtclassificationid =
	AM.Debtclassificationid
	AND TV.Isdeleted = 0
	AND TV.Projectid = @ProjectID
LEFT JOIN avl.DEBT_MAS_AVOIDABLEFLAG AM1
	ON TV.Avoidableflagid = AM1.Avoidableflagid
LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] AM2
	ON TV.Residualdebtid = AM2.Residualdebtid
LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE] AM3
	ON TV.Causecodeid = AM3.Causeid
	AND TV.Projectid = AM3.Projectid
	AND AM3.Projectid = @ProjectID
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] AM4
	ON TV.Resolutioncodeid = AM4.Resolutionid
	AND TV.Projectid = AM4.Projectid
	AND AM4.Projectid = @ProjectID
	AND AM3.Isdeleted = 0
LEFT JOIN [AVL].[APP_MAS_APPLICATIONDETAILS] AMR
	ON TV.Applicationid = AMR.Applicationid
LEFT JOIN [AVL].[APP_MAS_OWNERSHIPDETAILS] AT
	ON AMR.Codeownership = AT.Applicationtypeid
LEFT JOIN [AVL].[APP_MAS_PRIMARYTECHNOLOGY] MT
	ON AMR.Primarytechnologyid =
	MT.Primarytechnologyid
LEFT JOIN [AVL].[MAS_PROJECTMASTER] PM
	ON TV.Projectid = PM.Projectid
LEFT JOIN [AVL].[CUSTOMER] DAM
	ON PM.Customerid = DAM.Customerid
	AND DAM.Isdeleted = 0
LEFT JOIN [AVL].[BUSINESSUNIT] DM
	ON DAM.Buid = DM.Buid
	AND DM.Isdeleted = 0
INNER JOIN avl.ML_TRN_REGENERATEDAPPLICATIONDETAILS
rg
	ON rg.Projectid = TV.Projectid
	AND rg.Isdeleted = 0
	AND rg.Initiallearningid = @LatestID
	AND rg.Applicationid = TV.Applicationid
	AND rg.Projectid = @ProjectID
WHERE TV.Projectid = @ProjectID
AND TV.Isdeleted = 0
AND NOT EXISTS (SELECT
		Ticketid
	FROM avl.ML_TRN_TICKETSAFTERSAMPLING TS
	WHERE TS.Ticketid = TV.Ticketid
	AND TS.Projectid = TV.Projectid
	AND TV.Projectid = @ProjectID
	AND TV.Isdeleted = 0)
AND (TV.Causecodeid IS NOT NULL
OR TV.Causecodeid <> 0)
AND (TV.Resolutioncodeid IS NOT NULL
OR TV.Resolutioncodeid <> 0)
AND (TV.Debtclassificationid IS NOT NULL
OR TV.Debtclassificationid <> 0)
AND (TV.Avoidableflagid IS NOT NULL
OR TV.Avoidableflagid <> 0)
AND (TV.Residualdebtid IS NOT NULL
OR TV.Residualdebtid <> 0)

IF (@IsNoiseSkipAndContinue = 1) BEGIN
SELECT
	'' AS Word

SELECT
	'' AS Word
END ELSE BEGIN
SELECT
	Ticketdescnoiseword AS Word
FROM avl.ML_TICKETDESCNOISEWORDS
WHERE Projectid = @ProjectID
AND Isactive = 0

SELECT
	Optionalfieldnoiseword AS Word
FROM avl.ML_OPTIONALFIELDNOISEWORDS
WHERE Projectid = @ProjectID
AND Isactive = 0
END
END
END

DECLARE @BUName NVARCHAR(1000);
DECLARE @DepartmentAccountID NVARCHAR(MAX);
DECLARE @DepartmentID NVARCHAR(MAX);
DECLARE @AccountName NVARCHAR(MAX);
DECLARE @ProjectName NVARCHAR(MAX);
DECLARE @InitialLearningId INT;

SET @ProjectName = (SELECT
		Projectname
	FROM [AVL].[MAS_PROJECTMASTER]
	WHERE Projectid = @ProjectID
	AND Isdeleted = 0)
SET @DepartmentAccountID = (SELECT
		Customerid
	FROM [AVL].[MAS_PROJECTMASTER]
	WHERE Projectid = @ProjectID
	AND Isdeleted = 0)
SET @AccountName = (SELECT
		Customername
	FROM [AVL].[CUSTOMER]
	WHERE Customerid = @DepartmentAccountID
	AND Isdeleted = 0)
SET @DepartmentID = (SELECT
		Buid
	FROM [AVL].[CUSTOMER]
	WHERE Customerid = @DepartmentAccountID
	AND Isdeleted = 0)
SET @BUName = (SELECT
		Buname
	FROM [AVL].[BUSINESSUNIT]
	WHERE Buid = @DepartmentID
	AND Isdeleted = 0)
SET @InitialLearningId = (SELECT TOP 1
		Id
	FROM avl.ML_PRJ_INITIALLEARNINGSTATE
	WHERE Projectid = @ProjectID
	AND Isnoiseeliminationsentorreceived
	=
	'Received'
	AND Issamplingsentorreceived =
	'Received'
	ORDER BY Id DESC)

DECLARE @BUtext NVARCHAR(128) = @BUName

SET @BUName = (SELECT
		REPLACE(REPLACE(REPLACE(REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		@BUtext,
		'-', ''),
		'@',
		'')
		,
		'#'
		,
		''
		),
		'$',
		'')
		,
		'/'
		,
		'')
		,
		',', '')
		, '.', ''), '*', ''), '%', ''))

DECLARE @Acctext NVARCHAR(128) = @AccountName

SET @AccountName = (SELECT
		REPLACE(REPLACE(REPLACE(REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		@Acctext,
		'-'
		,
		'')
		,
		'@'
		,
		'')
		,
		'#'
		,
		''),
		'$',
		''
		),
		'/'
		, ''), ',',
		''),
		'.',
		''), '*', ''), '%'
		, ''))

DECLARE @Prjtext NVARCHAR(128) = @ProjectName

SET @ProjectName = (SELECT
		REPLACE(REPLACE(REPLACE(REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		@Prjtext,
		'-'
		,
		'')
		,
		'@'
		,
		'')
		,
		'#'
		,
		''),
		'$',
		''
		),
		'/'
		, ''), ',',
		''),
		'.',
		''), '*', ''), '%'
		, ''))

-- bu name,acc name etc..         
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
EXEC AVL_INSERTERROR	' [dbo].[ML_GetSamplingDetailsForML] '
						,@ErrorMessage
						,@ProjectID
						,0
END CATCH
END
