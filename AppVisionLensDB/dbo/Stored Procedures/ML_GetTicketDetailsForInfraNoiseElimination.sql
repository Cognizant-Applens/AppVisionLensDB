
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
-- Author:    627129 
-- Create date: 1-AUG-2019 
-- Description:   To get the Infra ticket details for noise elimination 
-- [dbo].[ML_GetTicketDetailsForInfraNoiseElimination]  
-- =============================================  


CREATE PROCEDURE [dbo].[ML_GetTicketDetailsForInfraNoiseElimination]
  @ProjectID NVARCHAR(200), 
  @UserID    NVARCHAR(max) 
AS 
  BEGIN
 
      BEGIN TRY 
          BEGIN TRAN
 

          DECLARE @CountForTicketValidates INT
 
          DECLARE @countforoptnull INT
 
          DECLARE @OptionalFieldID INT;
 
          DECLARE @PresenceOfOptional BIT;
 
          DECLARE @IsRegenerated BIT, 
                  @InitialID     BIGINT
 
	      DECLARE @BUName VARCHAR(1000);
 
          DECLARE @DepartmentAccountID VARCHAR(max);
 
          DECLARE @DepartmentID VARCHAR(max);
 
          DECLARE @AccountName VARCHAR(max);
 
          DECLARE @ProjectName VARCHAR(max);
 
          DECLARE @InitialLearningId INT;
 
	      DECLARE @tableHTML VARCHAR(max);
 
          DECLARE @EmailProjectName VARCHAR(max);
 
          DECLARE @Subjecttext VARCHAR(max);
 
          DECLARE @MailingToList VARCHAR(max);
 
          DECLARE @UserName VARCHAR(max);
 
		  DECLARE @IsAssociateID INT

--latest initial learning transaction id for project and Isregenerated flag 
SELECT TOP 1
	@IsRegenerated = ISNULL(IsRegenerated, 0)
	,@InitialID = ID
FROM AVL.ML_PRJ_InitialLearningStateInfra(NOLOCK)
WHERE ProjectID = @ProjectID
AND IsDeleted = 0
ORDER BY ID DESC

--Get the Flag for MultiLingual enabled for the project
DECLARE @IsMultiLingualEnabled int = 0

SET @IsMultiLingualEnabled = (SELECT ISNULL(PM.IsMultilingualEnabled,0) FROM AVL.MAS_ProjectMaster(NOLOCK) PM
WHERE PM.ProjectID = @ProjectID
AND PM.IsDeleted = 0)


SELECT MLT.ID,MLT.TimeTickerID,MLT.TicketDescription,MLT.ResolutionRemarks,MLT.TicketSummary,MLT.Category,MLT.Comments,
MLT.IsCategoryUpdated,MLT.IsTicketDescriptionUpdated,MLT.IsCommentsUpdated,MLT.IsTicketSummaryUpdated,MLT.IsFlexField1Updated,
MLT.IsFlexField2Updated,MLT.IsFlexField3Updated,MLT.IsFlexField4Updated,MLT.IsTypeUpdated,T.TicketID
INTO #tmpMultilingualTranslatedValues 
FROM AVL.TK_TRN_Multilingual_TranslatedInfraTicketDetails(NOLOCK) MLT
JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) T ON MLT.TimeTickerID= T.TimeTickerID 
AND T.ProjectID = @ProjectID
AND T.IsDeleted = 0

--Optional field id for the existing transaction id 
SET @OptionalFieldID = (SELECT TOP 1
		optionalfieldid
	FROM AVL.ML_MAP_OptionalProjMappingInfra
	WHERE ProjectID = @ProjectID
	AND IsDeleted = 0)

	
--count for total ticket 
SET @CountForTicketValidates = (SELECT
		COUNT(DISTINCT TicketID)
	FROM AVL.ML_TRN_TicketValidationInfra(NOLOCK) TD
	LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails(NOLOCK) RAG
		ON RAG.InitialLearningID = @InitialID
		AND RAG.TowerID = TD.TowerID
		AND RAG.IsDeleted = 0
		AND RAG.ProjectID = TD.ProjectID

	WHERE TD.projectid = @ProjectID
	AND (@IsRegenerated = 0
	OR (@IsRegenerated = 1
	AND RAG.ID IS NOT NULL))
	AND TD.IsDeleted = 0)
--count of tickets with optional field as null or empty 
SET @Countforoptnull = (SELECT
		COUNT(TicketID)
	FROM AVL.ML_TRN_TicketValidationInfra(NOLOCK) TD
	LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails(NOLOCK) RAG
		ON RAG.InitialLearningID = @InitialID
		AND RAG.TowerID = TD.TowerID
		AND RAG.IsDeleted = 0
		AND RAG.ProjectID = TD.ProjectID

	WHERE TD.ProjectID = @ProjectID
	AND TD.IsDeleted = 0
	AND (@IsRegenerated = 0
	OR (@IsRegenerated = 1
	AND RAG.ID IS NOT NULL))
	AND (TD.optionalfieldproj = ''
	OR TD.optionalfieldproj IS NULL))

--if (count of total=count of optional field empty or null  provided that it has optional field in this transaction) or optional field is not selected for that recent transaction
-- following block will be executed 

IF ((@CountForTicketValidates = @Countforoptnull
AND @OptionalFieldID <> 4)
OR @OptionalFieldID = 4 ) BEGIN
SET @PresenceOfOptional = 0


SELECT
DISTINCT
	DM.BUName AS DepartmentName
	,DAM.CustomerName AS AccountName
	,PM.EsaProjectID
	,TV.TicketID
	,TV.TicketDescription AS TicketDescription
	,ITDT.TowerName
	,IOT.HierarchyName AS Hierarchy1Name
	,ITT.HierarchyName AS Hierarchy2Name
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode]
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode]
FROM AVL.ML_TRN_TicketValidationInfra(NOLOCK) TV
JOIN AVL.ML_PRJ_InitialLearningStateInfra(NOLOCK) ILS
	ON TV.ProjectID = ILS.ProjectID
LEFT JOIN [AVL].[DEBT_MAS_DebtClassificationInfra](NOLOCK) AM
	ON TV.DebtClassificationID = AM.DebtClassificationID
LEFT JOIN avl.DEBT_MAS_AvoidableFlag(NOLOCK) AM1
	ON TV.AvoidableFlagID = AM1.AvoidableFlagID
LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt](NOLOCK) AM2
	ON TV.ResidualDebtID = AM2.ResidualDebtID
LEFT JOIN [AVL].[DEBT_MAP_CauseCode](NOLOCK) AM3
	ON TV.CauseCodeID = AM3.CauseID
	AND TV.ProjectID = AM3.ProjectID
	AND AM3.IsDeleted = 0
LEFT JOIN [AVL].[Debt_MAP_ResolutionCode](NOLOCK) AM4
	ON TV.ResolutionCodeID = AM4.ResolutionID
	AND TV.ProjectID = AM4.ProjectID
	AND AM3.IsDeleted = 0
LEFT JOIN [AVL].InfraTowerDetailsTransaction(NOLOCK) ITDT
	ON TV.TowerID = ITDT.InfraTowerTransactionID 
LEFT JOIN AVL.InfraHierarchyMappingTransaction(NOLOCK) IHT
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
LEFT JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM
	ON TV.ProjectID = PM.ProjectID
LEFT JOIN [AVL].[Customer](NOLOCK) DAM
	ON PM.CustomerID = DAM.CustomerID
	AND DAM.IsDeleted = 0
LEFT JOIN [AVL].[BusinessUnit] DM
	ON DAM.BUID = DM.BUID
	AND DM.IsDeleted = 0
LEFT JOIN avl.ML_TRN_RegeneratedTowerDetails REG
	ON REG.InitialLearningID = @InitialID
	AND REG.IsDeleted = 0
	AND REG.TowerID = TV.TowerID
	AND IPM.ProjectID = @ProjectID
	LEFT JOIN #tmpMultilingualTranslatedValues MLT
                    ON MLT.TicketID = TV.TicketID
WHERE ILS.IsDeleted = 0
AND TV.IsDeleted = 0
AND ILS.ProjectID = @ProjectID
AND ((@IsRegenerated = 1
AND REG.id IS NOT NULL)
OR (@IsRegenerated = 0))--regenerated transaction id or not 
--AND ILS.IsNoiseEliminationSentorReceived IS NULL
 AND ISNULL(MLT.IsTicketDescriptionUpdated,0)  = 0
 
END

ELSE IF (@OptionalFieldID <> 4)--else if it's optional field is selected and both counts are not equal then optional field text is sent
BEGIN
SET @PresenceOfOptional = 1


SELECT
DISTINCT
	DM.BUName AS DepartmentName
	,DAM.CustomerName AS AccountName
	,PM.EsaProjectID
	,TV.TicketID
	,TV.TicketDescription  AS TicketDescription
	,ITDT.TowerName
	,IOT.HierarchyName AS Hierarchy1Name
	,ITT.HierarchyName AS Hierarchy2Name
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM3.MCauseCode,'') != '' THEN AM3.MCauseCode ELSE AM3.CauseCode END AS [CauseCode]
	,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(AM4.MResolutionCode,'') != '' THEN AM4.MResolutionCode ELSE AM4.ResolutionCode END AS [ResolutionCode]
	,TV.OptionalFieldProj AS AdditionalText
FROM AVL.ML_TRN_TicketValidationInfra(NOLOCK) TV
JOIN AVL.ML_PRJ_InitialLearningStateInfra(NOLOCK) ILS
	ON TV.ProjectID = ILS.ProjectID
LEFT JOIN [AVL].[DEBT_MAS_DebtClassificationInfra](NOLOCK) AM
	ON TV.DebtClassificationID = AM.DebtClassificationID
LEFT JOIN AVL.Debt_MAS_Avoidableflag(NOLOCK) AM1
	ON TV.AvoidableFlagID = AM1.AvoidableFlagID
LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt](NOLOCK) AM2
	ON TV.ResidualDebtID = AM2.ResidualDebtID
LEFT JOIN [AVL].[Debt_MAP_CauseCode](NOLOCK) AM3
	ON TV.CauseCodeID = AM3.CauseID
	AND TV.ProjectID = AM3.ProjectID
	AND AM3.IsDeleted = 0
LEFT JOIN [AVL].[Debt_MAP_ResolutionCode](NOLOCK) AM4
	ON TV.ResolutionCodeID = AM4.ResolutionID
	AND TV.ProjectID = AM4.ProjectID
	AND AM3.IsDeleted = 0
LEFT JOIN [AVL].InfraTowerDetailsTransaction(NOLOCK) ITDT
	ON TV.TowerID = ITDT.InfraTowerTransactionID
LEFT JOIN AVL.InfraHierarchyMappingTransaction(NOLOCK) IHT
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
	AND IPM.ProjectID=ILS.ProjectID
LEFT JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM
	ON TV.ProjectID = PM.ProjectID
LEFT JOIN [AVL].[Customer](NOLOCK) DAM
	ON PM.CustomerID = DAM.CustomerID
	AND DAM.IsDeleted = 0
LEFT JOIN [AVL].[BusinessUnit](NOLOCK) DM
	ON DAM.BUID = DM.BUID
	AND DM.IsDeleted = 0
LEFT JOIN avl.ML_TRN_RegeneratedTowerDetails(NOLOCK) REG
	ON REG.InitiallearningID = @InitialID
	AND REG.IsDeleted = 0
	AND REG.TowerID = TV.TowerID
	AND REG.ProjectID = @ProjectID
	LEFT JOIN #tmpMultilingualTranslatedValues MLT
                    ON  MLT.TicketID = TV.TicketID
	WHERE ILS.IsDeleted = 0
AND TV.IsDeleted = 0
AND ILS.ProjectID = @ProjectID
AND ((@IsRegenerated = 1
AND REG.id IS NOT NULL)
OR (@IsRegenerated = 0))
--AND ILS.IsNoiseEliminationSentorReceived IS NULL
 AND ISNULL(MLT.IsTicketDescriptionUpdated,0)  = 0
END



SET @ProjectName = (SELECT
		ProjectName
	FROM [AVL].[MAS_ProjectMaster](NOLOCK)
	WHERE ProjectID = @ProjectID
	AND IsDeleted = 0)
SET @DepartmentAccountID = (SELECT
		CustomerID
	FROM [AVL].[MAS_ProjectMaster](NOLOCK)
	WHERE ProjectID = @ProjectID
	AND IsDeleted = 0)
SET @AccountName = (SELECT
		CustomerName
	FROM [AVL].[Customer](NOLOCK)
	WHERE CustomerID = @DepartmentAccountID
	AND IsDeleted = 0)
SET @DepartmentID = (SELECT
		BUID
	FROM [AVL].[Customer](NOLOCK)
	WHERE CustomerID = @DepartmentAccountID
	AND IsDeleted = 0)
SET @BUName = (SELECT
		buname
	FROM [AVL].[Businessunit](NOLOCK)
	WHERE BUID = @DepartmentID
	AND IsDeleted = 0)



SET @InitialLearningId = (SELECT TOP 1
		ID
	FROM AVL.ML_PRJ_InitialLearningStateInfra(NOLOCK)
	WHERE ProjectID = @ProjectID
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

--BUName,AccountName,ProjectName,InitialLearningid,@OptionalFieldid         
SELECT
	REPLACE(@BUName, ' ', '_') AS BUName
	,REPLACE(@AccountName, ' ', '_') AS AccountName
	,REPLACE(@ProjectName, ' ', '_') AS ProjectName
	,@InitialLearningId AS InitialLearningId
	,@OptionalFieldID AS OptionalFieldID
	,@PresenceOfOptional AS 'PresenceOfOptional'

--=================================Mail Content==========================------ 
SELECT TOP 1
	EmployeeEmail
	,EmployeeName INTO #EmployeeData
FROM AVL.MAS_LoginMaster(nolock)
WHERE EmployeeID = @UserID
AND ProjectID = @ProjectID
AND IsDeleted = 0


SET @MailingToList = (SELECT
		EmployeeEmail
	FROM #EmployeeData)
SET @UserName = (SELECT
		EmployeeName
	FROM #EmployeeData)

SET @IsAssociateID = (SELECT
		c.IsCognizant
	FROM AVL.MAS_ProjectMaster PM
	JOIN AVL.Customer C
		ON C.Customerid = PM.customerid
	WHERE PM.ProjectID = @ProjectID
	AND PM.IsDeleted = 0
	AND c.IsDeleted = 0)

IF ((@IsAssociateID) = 1) BEGIN
SET @EmailProjectName = (SELECT DISTINCT
		CONCAT(PM.EsaProjectID, '-', PM.ProjectName)
	FROM AVL.MAS_ProjectMaster PM
	WHERE PM.ProjectID = @ProjectID)
END ELSE BEGIN
SET @EmailProjectName = (SELECT DISTINCT
		PM.ProjectName
	FROM AVL.MAS_ProjectMaster PM
	WHERE PM.ProjectID = @ProjectID)
END


SET @Subjecttext = 'Initial Learning Noise Elimination - Keywords Generated : '
+ @EmailProjectName


----------------------------------------- 
---------------mailer body---------------margin-left:170px; 
SET @tableHTML = '<html style="width:auto !important">'
+ '<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" style="text-align:center;width:840">'
+
'<table width="840" face="Times New Roman,serif" border="0" cellpadding="0" cellspacing="0" style="margin-left:60px;font-family:sans-serif;font-size:14px;font-weight:normal">'
+ '<tbody>' + '<tr>'
+ '<td valign="top" style="padding: 0;">'
+ '<div align="center" style="text-align: center;">'
+ '<table width="840" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">'
+ '<tbody>' + '<tr style="height:50px">'
+ '<td width="auto" valign="top" align="center">'
+ '<img src="\\ctsc01260327301\Banner\ApplensBanner.png" width="840" height="50" style="border-width: 0px;"/>'
+ '</td>' + '</tr>'
+ '<tr style="background-color:#F0F8FF">'
+ '<td valign="top" style="padding: 0;">'
+ '<div align="center" style="text-align: center;margin-left:50px">'
+ '<table width="840" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">'
+ '<tbody>' + '</br></BR>'
+ N'<left>  <font-weight:normal>  &nbsp;&nbsp;Dear ' + @UserName
+ ' ,' + '</BR>'
+ '&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp'
+ '</BR>'
+ '&nbsp;&nbsp;Keywords has been generated for Noise Elimination process. Request you to navigate to Ticketing Module - > Lead Self Service - > '
+ '</BR>'
+ '&nbsp;&nbsp;Initial Learning Review and exclude the unwanted words for pattern generation.'
+ '</font>   </Left>' + N'    <p align="left">    <font color="Black" Size = "2" font-weight=bold>    <b>&nbsp;&nbsp;Thanks & Regards,</b>   </font>    </BR>   &nbsp;&nbsp;Solution Zone Team 	   </BR>    </BR>     <p style="text-align: center;">  	  **This is an Auto Generated Mail. Please Do not reply to this Email** </p> </p>' + '</tbody>'
+ '</table>' + '</div>' + '</td>' + '</tr>'
+ '</tbody>' + '</table>' + '</div>' + '</td>'
+ '</tr>' + '</tbody>' + '</table>' + '</body>'
+ '</html>'


INSERT INTO dbo.EmailCollection
	SELECT
		@MailingToList
		,''
		,''
		,@Subjecttext
		,@tableHTML
		,0
		,2
		,GETDATE()
		,''

-----------------executing mail------------- 
EXEC [AVL].[SendDBEmail] @To=@MailingToList,
    @From='ApplensSupport@cognizant.com',
    @Subject =@Subjecttext,
    @Body = @tableHTML

--=================================Mail Content End===========================---------------------- 
COMMIT TRAN
END TRY BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()

ROLLBACK TRAN

--INSERT Error     
EXEC Avl_InsertError	'[dbo].[ML_GetTicketDetailsForNoiseElimination] '
						,@ErrorMessage
						,@ProjectID
						,0
END CATCH
END



