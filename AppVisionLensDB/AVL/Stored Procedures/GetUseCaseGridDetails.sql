/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetUseCaseGridDetails] 
@BU NVARCHAR(MAX)='',
@AccountName NVARCHAR(MAX)='',
@Technology NVARCHAR(MAX)='',
@SupportLevel NVARCHAR(MAX)='',
@Tags nvarchar(max)=''
AS
BEGIN
      BEGIN TRY 
		SET NOCOUNT ON;



CREATE TABLE #TempBU
(
BUID VARCHAR(500)
)

INSERT INTO #TempBU
SELECT * FROM dbo.Split(@BU,'~')

DECLARE @BUFlag BIT

SET @BUFlag = (SELECT COUNT(BUID) FROM #TempBU ) 


CREATE TABLE #TempAccount
(
AccountID VARCHAR(500)
)

INSERT INTO #TempAccount
SELECT * FROM dbo.Split(@AccountName,'~')

DECLARE @AccountFlag BIT

SET @AccountFlag = (SELECT COUNT(AccountID) FROM #TempAccount ) 

CREATE TABLE #TempTechnology
(
TechID VARCHAR(500)
)

INSERT INTO #TempTechnology
SELECT * FROM dbo.Split(@Technology,'~')

DECLARE @TechFlag BIT

SET @TechFlag = (SELECT COUNT(TechID) FROM #TempTechnology) 

CREATE TABLE #TempSupportLevel
(
SupportLevelID VARCHAR(500)
)

INSERT INTO #TempSupportLevel
SELECT * FROM dbo.Split(@SupportLevel,'~')

DECLARE @SupportLevelFlag BIT

SET @SupportLevelFlag = (SELECT COUNT(SupportLevelID) FROM #TempSupportLevel) 


CREATE TABLE #TempTags
(
ID INT IDENTITY(1,1),
TagsID VARCHAR(500)
)

INSERT INTO #TempTags
SELECT * FROM dbo.Split(@Tags,'~')

DECLARE @TagsCount BIT

SET @TagsCount = (SELECT COUNT(TagsID) FROM #TempTags)


DECLARE @TotalCount INT

SET @TotalCount = (SELECT COUNT(UseCaseDetailID) FROM AVL.Effort_UseCaseDetails)
/*UsecaseDetails union with Effort_UsecaseDetails*/
DECLARE @NewUCTotalCount INT
set @NewUCTotalCount=(select count(Id) from AVL.UseCaseDetails  UC WHERE UseCaseStatusId=2)
set @TotalCount=@TotalCount+@NewUCTotalCount;

SELECT COUNT(USECASEDETAILID) AS UseCaseDetailCount,UseCaseDetailID INTO #UseCaseSolutionMapped FROM AVL.Effort_UseCaseDetails EU With (NOLOCK)
INNER JOIN AVL.DEBT_UseCaseSolutionIdentificationDetails  D  (NOLOCK) ON D.UseCaseSolutionMapId = EU.UseCaseDetailID AND D.IsMappedSolution = 1
GROUP BY UseCaseDetailID

SELECT COUNT(UC.Id) AS UseCaseDetailCount,UC.Id as UseCaseDetailID INTO #NewUseCaseSolutionMapped FROM AVL.UseCaseDetails UC With  (NOLOCK)
INNER JOIN AVL.DEBT_UseCaseSolutionIdentificationDetails  D  (NOLOCK) ON D.UseCaseSolutionMapId = UC.Id AND D.IsMappedSolution = 1
GROUP BY UC.Id


SELECT DISTINCT SUM(ActiveChildCount) AS ActiveChildCount,IsMappedSolution,UseCaseSolutionMapId INTO #ActiveChildCount FROM
(SELECT DISTINCT COUNT(NC.ProjectPatternMapID) AS ActiveChildCount, IsMappedSolution,u.UseCaseSolutionMapId AS UseCaseSolutionMapId 
FROM AVL.DEBT_TRN_HealTicketDetails H With  (NOLOCK) 
INNER JOIN AVL.DEBT_UseCaseSolutionIdentificationDetails U  (NOLOCK) ON U.HealingTicketID = H.HealingTicketID AND IsMappedSolution = 1 
INNER JOIN AVL.DEBT_PRJ_NonDebtParentChild NC  (NOLOCK) ON H.HealingTicketID = NC.HealingTicketID
WHERE ManualNonDebt = 1 and mapstatus = 1 
GROUP BY IsMappedSolution,u.UseCaseSolutionMapId

UNION

SELECT DISTINCT COUNT(PC.ProjectPatternMapID) AS ActiveChildCount,IsMappedSolution,u.UseCaseSolutionMapId AS UseCaseSolutionMapId 
FROM AVL.DEBT_TRN_HealTicketDetails H With  (NOLOCK) 
INNER JOIN AVL.DEBT_UseCaseSolutionIdentificationDetails U  (NOLOCK) ON U.HealingTicketID = H.HealingTicketID AND IsMappedSolution = 1
INNER JOIN avl.DEBT_PRJ_HealParentChild  PC  (NOLOCK) ON PC.ProjectPatternMapID = H.ProjectPatternMapID 
AND MapStatus = 1 WHERE ISNULL(ManualNonDebt,0) = 0 
GROUP BY IsMappedSolution,u.UseCaseSolutionMapId) AS ActiveChildCount

GROUP BY IsMappedSolution,UseCaseSolutionMapId 

/****UsecaseDetails ***/
SELECT	UC.UseCaseId,
		@TotalCount as TotalCount
		,UC.Id as UseCaseDetailID
		,UC.UseCaseTitle
		,AD.ApplicationName
		,PT.PrimaryTechnologyName as Technology
		,UC.ToolName
		,CAT.ServiceName as Category
		,cast (UC.AutomationFeasibility as nvarchar(30)) AutomationFeasibility
		,BU.BUName as SBUName
		,UC.Id 
		,UC.CustomerID,UC.ReferenceID,UC.ApplicationID,UC.TechnologyID
		,UC.BusinessProcessID,UC.SubBusinessProcessID
		,UC.ServiceID
		,UC.UseCaseStatusId		
		,cast (UC.OverAllEffortSpent as nvarchar(30)) OverAllEffortSpent
		,UC.CreatedBy
		,ISNULL(D.UseCaseDetailCount,0)AS UseCaseDetailCount
		,ISNULL(A.ActiveChildCount,0) AS NoOfTicketAutomated
		,COUNT(UC.Id) AS CountUseCaseDetailID
		,ISNULL(CAST(CAST(SUM(UR.Rating) AS FLOAT)/CAST(COUNT(UR.UseCaseDetailID) AS FLOAT) AS NUMERIC(18,1)),0) AS Rating
		,BPM.BusinessProcessName as BusinessProcess
		,MP.BusinessProcessName as SubBusinessProcess
		,'' AverageNoofOccurrences
		,CUS.CustomerName as AccountName

			INTO #UnionUCList FROM AVL.UseCaseDetails UC With  (NOLOCK)
			LEFT JOIN AVL.APP_MAS_ApplicationDetails AD  (NOLOCK) on UC.ApplicationID=AD.ApplicationID
			LEFT JOIN AVL.APP_MAS_PrimaryTechnology PT  (NOLOCK) on UC.TechnologyID=PT.PrimaryTechnologyID
			LEFT JOIN AVL.Effort_UseCaseRatings UR  (NOLOCK) ON UR.UseCaseDetailID = UC.Id 
			LEFT JOIN BusinessOutCome.MAS.BusinessProcessMaster BPM  (NOLOCK) ON BPM.BusinessProcessId=UC.BusinessProcessID
			LEFT JOIN BusinessOutCome.mas.BusinessProcessMaster MP  (NOLOCK) ON mp.BusinessProcessId = UC.SubBusinessProcessID 
			JOIN ESA.BusinessUnits BU  (NOLOCK) ON UC.BUID=BU.BUID
			JOIN AVL.Customer CUS  (NOLOCK) ON CUS.CustomerID=UC.CustomerID
			JOIN avl.TK_MAS_Service CAT  (NOLOCK) ON CAT.ServiceID=UC.ServiceID
			LEFT JOIN #NewUseCaseSolutionMapped D  (NOLOCK) ON d.UseCaseDetailID = UC.Id 
			LEFT JOIN #ActiveChildCount A  (NOLOCK) ON A.UseCaseSolutionMapId = UC.Id 
			WHERE UseCaseStatusId=2
		group by 
		UC.UseCaseId
		,UC.Id 
		,UC.UseCaseTitle
		,AD.ApplicationName
		,PT.PrimaryTechnologyName
		,UC.ToolName
		,CAT.ServiceName 
		,AutomationFeasibility
		,BU.BUName
		,UC.Id 
		,UC.CustomerID,UC.ReferenceID,UC.ApplicationID,UC.TechnologyID
		,UC.BusinessProcessID,UC.SubBusinessProcessID
		,UC.ServiceID
		,UC.UseCaseStatusId		
		,OverAllEffortSpent
		,UC.CreatedBy
		,D.UseCaseDetailCount
		,BPM.BusinessProcessName 
		,MP.BusinessProcessName
		,CUS.CustomerName 
		,A.ActiveChildCount
SELECT COMBINED_RECORDS.*
INTO #Effort_UseCaseDetails
FROM
(
SELECT 
		UC.UseCaseId as UseCaseID
		,UC.TotalCount
		,UC.Id as UseCaseDetailID
		
		,UC.UseCaseTitle as UseCaseTitle
		,UC.ApplicationName
		,UC.Technology
		,x.SupportType as SupportLevel
		,UC.ToolName as ToolName
		,UC.Category
		,UC.AutomationFeasibility as AutomationFeasibility
		,z.ToolsClassification as ToolClassification
		,y.Tag as Tags
		,UC.BusinessProcess as BusinessProcess
		,UC.SubBusinessProcess as SubBusinessProcess
		,UC.OverAllEffortSpent as OverallEffortSpent
		,UC.AverageNoofOccurrences as AverageNoofOccurrences
		,UC.SBUName as SBUName
		,UC.AccountName as AccountName
		,cast (UC.ReferenceID as varchar(10)) as ReferenceID
		,UC.CreatedBy as CreatedBy
		,'' AS ApprovedBy
		,ISNULL(UC.UseCaseDetailCount,0) AS NoOfItemsUsed
		,ISNULL(UC.NoOfTicketAutomated,0) AS NoOfTicketAutomated
		,UC.CountUseCaseDetailID
		,UC.Rating as Rating

				FROM #UnionUCList UC
				CROSS APPLY
				(
					SELECT STUFF	(
						( 
							SELECT ',' +sl.ServiceLevelName FROM AVL.UseCaseSolutionTypeDetail ST With  (NOLOCK)
							JOIN AVL.MAS_ServiceLevel sl  (NOLOCK) on st.SolutionTypeID=sl.ServiceLevelID
							WHERE ST.UseCaseDetailId=UC.Id
							FOR XML PATH('') 
						)
					,1,1,'') as SupportType
				) as X
				CROSS APPLY
				(
					SELECT STUFF	(
						( 
							SELECT ',' +ST.Tag FROM AVL.UseCaseTagDetail ST With (NOLOCK)
							WHERE ST.UseCaseDetailId=UC.Id
							FOR XML PATH('') 
						)
					,1,1,'') as Tag
				) as Y
				CROSS APPLY
				(
					SELECT STUFF	(
						( 
							SELECT ',' +sl.SolutionTypeName FROM AVL.UseCaseServiceLevelDetails ST With (NOLOCK) 
							JOIN AVL.TK_MAS_SolutionType sl (NOLOCK) on st.ServiceLevelID=sl.SolutionTypeID
							WHERE ST.UseCaseDetailId=UC.Id
							FOR XML PATH('') 
						)
					,1,1,'') as ToolsClassification
				) as Z
			WHERE

((SBUName IN(SELECT BUID FROM #TempBU With (NOLOCK)) or @BUFlag=0) AND 
(AccountName IN(SELECT AccountID FROM #TempAccount With (NOLOCK)) or @AccountFlag=0) AND 
(Technology IN(SELECT TechID FROM #TempTechnology With (NOLOCK) ) or  @TechFlag=0 )AND  
(SupportType IN(SELECT SupportLevelID FROM #TempSupportLevel With (NOLOCK)) or @SupportLevelFlag= 0))


union

SELECT EU.UseCaseID AS UseCaseID,
@TotalCount AS TotalCount,
eu.UseCaseDetailID ,
UseCaseTitle,
ApplicationName,
Technology,
SupportLevel,
ToolName,
Category,
AutomationFeasibility,
ToolClassification,
Tags,
BusinessProcess,
SubBusinessProcess,
OverallEffortSpent,
AverageNoofOccurrences,
SBUName,
AccountName,
ReferenceID,
EU.CreatedBy,
'' AS ApprovedBy,
ISNULL(UseCaseDetailCount,0) AS NoOfItemsUsed,
ISNULL(A.ActiveChildCount,0) AS NoOfTicketAutomated,
COUNT(UR.UseCaseDetailID) AS CountUseCaseDetailID,
ISNULL(CAST(CAST(SUM(RATING) AS FLOAT)/CAST(COUNT(UR.UseCaseDetailID) AS FLOAT) AS NUMERIC(18,1)),0) AS Rating
FROM AVL.Effort_UseCaseDetails EU With  (NOLOCK)
LEFT JOIN AVL.Effort_UseCaseRatings UR  (NOLOCK) ON UR.UseCaseDetailID = EU.UseCaseDetailID 
LEFT JOIN #UseCaseSolutionMapped D  (NOLOCK) ON d.UseCaseDetailID = EU.UseCaseDetailID 
LEFT JOIN #ActiveChildCount A  (NOLOCK) ON A.UseCaseSolutionMapId = EU.UseCaseDetailID  

WHERE

((SBUName IN(SELECT BUID FROM #TempBU With  (NOLOCK)) or @BUFlag=0) AND 
(AccountName IN(SELECT AccountID FROM #TempAccount With  (NOLOCK)) or @AccountFlag=0) AND 
(Technology IN(SELECT TechID FROM #TempTechnology With  (NOLOCK) ) or  @TechFlag=0 )AND  
(SupportLevel IN(SELECT SupportLevelID FROM #TempSupportLevel With  (NOLOCK)) or @SupportLevelFlag= 0))
GROUP BY EU.UseCaseID,eu.UseCaseDetailID,UseCaseTitle,ApplicationName,Technology,SupportLevel,ToolName,AutomationFeasibility
,ToolClassification,Tags,BusinessProcess,

SubBusinessProcess
,OverallEffortSpent
,AverageNoofOccurrences,SBUName,AccountName,ReferenceID,eu.CreatedBy,Category,A.ActiveChildCount,UseCaseDetailCount


)COMBINED_RECORDS ORDER BY Rating DESC


IF(@TagsCount>0)
BEGIN

;with CTE(Tag)
as
(
	SELECT '%'+(SELECT TagsID FROM #TempTags WHERE ID=1)+'%'
	UNION ALL
	SELECT '%'+(SELECT TagsID FROM #TempTags WHERE ID=2)+'%'
	UNION ALL
	SELECT '%'+(SELECT TagsID FROM #TempTags WHERE ID=3)+'%'
	
)
SELECT 
UseCaseID,
TotalCount,
UseCaseDetailID ,
UseCaseTitle,
ApplicationName,
Technology,
SupportLevel,
ToolName,
Category,
AutomationFeasibility,
ToolClassification,
Tags,
BusinessProcess,
SubBusinessProcess,
OverallEffortSpent,
AverageNoofOccurrences,
SBUName,
AccountName,
ReferenceID,
CreatedBy,
ApprovedBy,
NoOfItemsUsed,
NoOfTicketAutomated,
CountUseCaseDetailID,
Rating
FROM #Effort_UseCaseDetails U With  (NOLOCK)
where exists ((select Tag from CTE With  (NOLOCK) where U.UseCaseID LIKE Tag 
OR U.UseCaseTitle LIKE Tag
OR U.ApplicationName LIKE Tag
OR U.ToolName LIKE Tag
OR U.Technology LIKE Tag
OR U.SupportLevel LIKE Tag
))

END
ELSE
BEGIN
SELECT 
UseCaseID,
TotalCount,
UseCaseDetailID ,
UseCaseTitle,
ApplicationName,
Technology,
SupportLevel,
ToolName,
Category,
AutomationFeasibility,
ToolClassification,
Tags,
BusinessProcess,
SubBusinessProcess,
OverallEffortSpent,
AverageNoofOccurrences,
SBUName,
AccountName,
ReferenceID,
CreatedBy,
ApprovedBy,
NoOfItemsUsed,
NoOfTicketAutomated,
CountUseCaseDetailID,
Rating
FROM #Effort_UseCaseDetails
END
SET NOCOUNT OFF

      END TRY
	  BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = ERROR_MESSAGE()   
          EXEC AVL_INSERTERROR 'AVL.GetUseCaseGridDetails',  @ErrorMessage,  0 
      END CATCH 
END
