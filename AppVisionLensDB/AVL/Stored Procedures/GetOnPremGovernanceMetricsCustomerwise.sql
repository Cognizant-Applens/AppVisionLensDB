CREATE PROCEDURE [AVL].[GetOnPremGovernanceMetricsCustomerwise](
@CustId BIGINT  
)
AS
BEGIN

BEGIN TRY
BEGIN TRAN
CREATE TABLE #OnPremGovernanceMetrics(
[Account ID] BIGINT NOT NULL,
[Account Name] NVARCHAR(50) NULL,
[Project ID] NVARCHAR(50) NOT NULL,
[Project Name] NVARCHAR(50) NULL,
[Month] NVARCHAR(50) NOT NULL,
[Year] SMALLINT NOT NULL,
[Count of tickets which were classified with all the Debt fields] INT NULL,
[Count of tickets eligible for Debt classification] INT NULL,
[Count of tickets which were auto classified using ML/DD] INT NULL,
[Count of BoT tickets available for the project] INT NULL,
[Count of Partially Automated Tickets available for the project] INT NULL,
[Count of Automated Tickets Closed for the project] INT NULL,
[Count of Healing Tickets Closed for the project] INT NULL,
[Sum of Efforts available for the child tickets which are tagged to all the Automation tickets available for the project] DECIMAL(18,2) NULL,
[Total Number of Completed Months from Automation ticket open date] INT NULL,
[Sum of Efforts available for the child tickets which are tagged to all the Healing tickets available for the project] DECIMAL(18,2) NULL,
[Count of child tickets available for all the Healing tickets available for the project] INT NULL,
[Total Number of Completed Months from Healing ticket open date] INT NULL,
[Count of tickets with Debt classification as Operational] INT NULL,
[Count of tickets with Debt classification as Knowledge] INT NULL,
[Count of tickets with Debt classification as Functional] INT NULL,
[Count of tickets with Debt classification as Technical] INT NULL,
[Count of tickets with Debt classification as Environmental] INT NULL,
[Count of Residual Tickets] INT NULL,
[Total Automation tickets created] INT NULL,
[Total Healing tickets created] INT NULL,
[Total Automation ticket In progress] INT NULL,
[Total Healing ticket In progress] INT NULL,
[Total Dormant Automation Tickets closed] INT NULL,
[Total Dormant Healing Tickets Closed] INT NULL,
[Total Cancelled Automation Tickets] INT NULL,
[Total Cancelled Healing Tickets] INT NULL,
[Count of Avoidable Incidents] INT NULL,
[Count of Un - Avoidable Incidents] INT NULL,
)

DECLARE @CurrentMonth INT;
SET @CurrentMonth = (SELECT DATEPART(MONTH, GETDATE()));

DECLARE @CurrentYear INT;
SET @CurrentYear = (SELECT DATEPART(YEAR, GETDATE()));

DECLARE @CountofProjects INT;
SET @CountofProjects = (SELECT  DISTINCT COUNT(ProjectId) 
FROM AVL.Customer (NOLOCK) C
JOIN AVL.MAS_ProjectMaster(NOLOCK)  PM
ON PM.CustomerID = C.CustomerID AND C.IsDeleted = 0 AND PM.IsDeleted = 0
WHERE PM.CustomerId = @CustId);

SELECT  DISTINCT C.CustomerID AS [Account ID],C.CustomerName AS [Account Name],
PM.EsaProjectID AS [Project ID],PM.ProjectName AS [Project Name] 
INTO #ProjectList
FROM AVL.Customer(NOLOCK) C
JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
ON PM.CustomerID = C.CustomerID AND C.IsDeleted = 0 AND PM.IsDeleted = 0
WHERE PM.CustomerId = @CustId

DECLARE @CounterProject INT ;
SET @CounterProject = 1;

WHILE (@CounterProject <= @CountofProjects)
BEGIN
DECLARE @ProjectId NVARCHAR(50);
SET @ProjectId = (SELECT TOP 1 [Project ID] from #ProjectList(NOLOCK))
DECLARE @ProjectName NVARCHAR(50);
SET @ProjectName = (SELECT DISTINCT [Project Name] from #ProjectList(NOLOCK) WHERE [Project ID] = @ProjectId)
DECLARE @CustomerId BIGINT;
SET @CustomerId = (SELECT DISTINCT [Account ID] from #ProjectList(NOLOCK) WHERE [Project ID] = @ProjectId)
DECLARE @CustomerName  NVARCHAR(50);
SET @CustomerName = (SELECT DISTINCT [Account Name] from #ProjectList(NOLOCK) WHERE [Project ID] = @ProjectId)
DECLARE @Counter INT ;
SET @Counter = 1;
WHILE ( @Counter <= @CurrentMonth - 1)
BEGIN
    INSERT INTO #OnPremGovernanceMetrics values (@CustomerId,@CustomerName,@ProjectId,@ProjectName,@Counter,@CurrentYear,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    SET @Counter  = @Counter  + 1
END
     DELETE FROM #ProjectList WHERE [Project ID] = @ProjectId
     SET @CounterProject  = @CounterProject  + 1
END

CREATE TABLE #AllDebtClassifiedTicketCount(
ProjectId BIGINT,
[Month] TINYINT,
AllDebtClassifiedTicketCount INT
)
CREATE TABLE #EligibleTicketCountForDebtClassification(
ProjectId BIGINT,
[Month] TINYINT,
EligibleTicketCountForDebtClassification INT
)

CREATE TABLE #AutoClassifiedUsingML_DDTicketCount(
ProjectId BIGINT,
[Month] TINYINT,
AutoClassifiedUsingML_DDTicketCount INT
)

Declare @STARTDATE DATETIME
DECLARE @ENDDATE DATETIME
SET @ENDDATE= DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1) + '23:59:59'    
SET @STARTDATE = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)

--Count of tickets which were classified with all the Debt fields
INSERT INTO #AllDebtClassifiedTicketCount(
ProjectId,
[Month] ,
AllDebtClassifiedTicketCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,
COUNT(TimeTickerID) AS [AllDebtClassifiedTicketCount]
FROM AVL.TK_trn_ticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE
AND ISNULL(CauseCodeMapID,0) <> 0 AND ISNULL(ResolutionCodeMapID,0) <> 0 AND ISNULL(DebtClassificationMapID,0) <> 0 AND ISNULL(AvoidableFlag,0) <> 0
AND ISNULL(ResidualDebtMapID,0) <> 0 AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND  PP.AttributeValueID in (2)
GROUP BY TD.ProjectID,FORMAT(TD.Closeddate,'MM')

INSERT INTO #AllDebtClassifiedTicketCount(
ProjectId,
[Month] ,
AllDebtClassifiedTicketCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [AllDebtClassifiedTicketCount]
FROM AVL.TK_trn_infraticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE
AND ISNULL(CauseCodeMapID,0) <> 0 AND ISNULL(ResolutionCodeMapID,0) <> 0 AND ISNULL(DebtClassificationMapID,0) <> 0 AND ISNULL(AvoidableFlag,0) <> 0
AND ISNULL(ResidualDebtMapID,0) <> 0 AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND  PP.AttributeValueID in (3)
GROUP BY TD.ProjectID,FORMAT(TD.Closeddate,'MM')

SELECT ProjectId,[Month],SUM(AllDebtClassifiedTicketCount) AS AllDebtClassifiedTicketCount
INTO #AllDebtClassifiedTicketCounts
FROM  #AllDebtClassifiedTicketCount
GROUP BY ProjectId,[Month]


UPDATE OG SET OG.[Count of tickets which were classified with all the Debt fields] = ADCTC.AllDebtClassifiedTicketCount
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #AllDebtClassifiedTicketCounts ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]


--Count of tickets eligible for Debt classification
INSERT INTO #EligibleTicketCountForDebtClassification(
ProjectId,
[Month] ,
EligibleTicketCountForDebtClassification)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [EligibleTicketCountForDebtClassification]
FROM AVL.TK_trn_ticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND
ISNULL(MT.DebtConsidered,'N') = 'Y'  AND  PP.AttributeValueID in (2)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

INSERT INTO #EligibleTicketCountForDebtClassification(
ProjectId,
[Month] ,
EligibleTicketCountForDebtClassification)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [EligibleTicketCountForDebtClassification]
FROM AVL.TK_trn_infraticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE
AND ISNULL(MT.DebtConsidered,'N') = 'Y'  AND  PP.AttributeValueID in (3)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

SELECT ProjectId,[Month],SUM(EligibleTicketCountForDebtClassification) AS EligibleTicketCountForDebtClassification
INTO #EligibleTicketCountsForDebtClassification
FROM  #EligibleTicketCountForDebtClassification
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Count of tickets eligible for Debt classification] = ADCTC.EligibleTicketCountForDebtClassification
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #EligibleTicketCountsForDebtClassification ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Auto Debt classification%
--Count of tickets which were auto classified using ML/DD
INSERT INTO #AutoClassifiedUsingML_DDTicketCount(
ProjectId,
[Month] ,
AutoClassifiedUsingML_DDTicketCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [AutoClassifiedUsingML_DDTicketCount]
FROM AVL.TK_trn_ticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE
AND ISNULL(CauseCodeMapID,0) <> 0 AND ISNULL(ResolutionCodeMapID,0) <> 0 AND ISNULL(DebtClassificationMapID,0) <> 0 AND ISNULL(AvoidableFlag,0) <> 0
AND ISNULL(ResidualDebtMapID,0) <> 0 AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND TD.DebtClassificationMode IN (1,3) AND PP.AttributeValueID in (2)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

INSERT INTO #AutoClassifiedUsingML_DDTicketCount(
ProjectId,
[Month] ,
AutoClassifiedUsingML_DDTicketCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [AutoClassifiedUsingML_DDTicketCount]
FROM AVL.TK_trn_infraticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE
AND ISNULL(CauseCodeMapID,0) <> 0 AND ISNULL(ResolutionCodeMapID,0) <> 0 AND ISNULL(DebtClassificationMapID,0) <> 0 AND ISNULL(AvoidableFlag,0) <> 0
AND ISNULL(ResidualDebtMapID,0) <> 0 AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND TD.DebtClassificationMode IN (1,3) AND PP.AttributeValueID in (3)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

SELECT ProjectId,[Month],SUM(AutoClassifiedUsingML_DDTicketCount) AS AutoClassifiedUsingML_DDTicketCount
INTO #AutoClassifiedUsingML_DDTicketCounts
FROM  #AutoClassifiedUsingML_DDTicketCount
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Count of tickets which were auto classified using ML/DD] = ADCTC.AutoClassifiedUsingML_DDTicketCount
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #AutoClassifiedUsingML_DDTicketCounts ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]


--Full automated tickets (BoT)
CREATE TABLE #B0TFullAutomatedticketsCount(
ProjectId BIGINT,
[Month] TINYINT,
B0TFullAutomatedticketsCount INT
)

INSERT INTO #B0TFullAutomatedticketsCount(
ProjectId,
[Month] ,
B0TFullAutomatedticketsCount)
SELECT ProjectID,FORMAT(Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [B0TFullAutomatedticketsCount]
FROM AVL.TK_trn_botticketdetail (NOLOCK)
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE
GROUP BY ProjectID,FORMAT(Closeddate,'MM')



UPDATE OG SET OG.[Count of BoT tickets available for the project] = ADCTC.B0TFullAutomatedticketsCount
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #B0TFullAutomatedticketsCount ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Partial automated tickets (BoT) 
CREATE TABLE #B0TPartialAutomatedticketsCount(
ProjectId BIGINT,
[Month] TINYINT,
B0TPartialAutomatedticketsCount INT
)

INSERT INTO #B0TPartialAutomatedticketsCount(
ProjectId,
[Month] ,
B0TPartialAutomatedticketsCount)
SELECT ProjectID,FORMAT(Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [B0TPartialAutomatedticketsCount]
FROM AVL.TK_trn_botticketdetail (NOLOCK)
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND ispartiallyautomated=1
GROUP BY ProjectID,FORMAT(Closeddate,'MM')

UPDATE OG SET OG.[Count of Partially Automated Tickets available for the project] = ADCTC.B0TPartialAutomatedticketsCount
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #B0TPartialAutomatedticketsCount ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--17--Operational Debt 1
CREATE TABLE #OperationalDebtCount(
ProjectId BIGINT,
[Month] TINYINT,
OperationalDebtCount INT
)

INSERT INTO #OperationalDebtCount(
ProjectId,
[Month] ,
OperationalDebtCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [OperationalDebtCount]
FROM AVL.TK_trn_ticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND TD.DebtClassificationMapID=1
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (2)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

INSERT INTO #OperationalDebtCount(
ProjectId,
[Month] ,
OperationalDebtCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [OperationalDebtCount]
FROM AVL.TK_trn_infraticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND TD.DebtClassificationMapID=1
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (3)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

SELECT ProjectId,[Month],SUM(OperationalDebtCount) AS OperationalDebtCount
INTO #OperationalDebtCounts
FROM  #OperationalDebtCount
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Count of tickets with Debt classification as Operational] = ADCTC.OperationalDebtCount
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #OperationalDebtCounts ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Knowledge Debt 4
CREATE TABLE #KnowledgeDebtCount(
ProjectId BIGINT,
[Month] TINYINT,
KnowledgeDebtCount INT
)

INSERT INTO #KnowledgeDebtCount(
ProjectId,
[Month] ,
KnowledgeDebtCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [KnowledgeDebtCount]
FROM AVL.TK_trn_ticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND TD.DebtClassificationMapID=4
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (2)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

INSERT INTO #KnowledgeDebtCount(
ProjectId,
[Month] ,
KnowledgeDebtCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [KnowledgeDebtCount]
FROM AVL.TK_trn_infraticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND TD.DebtClassificationMapID=4
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (3)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

SELECT ProjectId,[Month],SUM(KnowledgeDebtCount) AS KnowledgeDebtCount
INTO #KnowledgeDebtCounts
FROM  #KnowledgeDebtCount
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Count of tickets with Debt classification as Knowledge] = ADCTC.KnowledgeDebtCount
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #KnowledgeDebtCounts ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Functional Debt 3
CREATE TABLE #FunctionalDebtCount(
ProjectId BIGINT,
[Month] TINYINT,
FunctionalDebtCount INT
)

INSERT INTO #FunctionalDebtCount(
ProjectId,
[Month] ,
FunctionalDebtCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [FunctionalDebtCount]
FROM AVL.TK_trn_ticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND TD.DebtClassificationMapID=3 AND PP.AttributeValueID in (2)
AND ISNULL(MT.DebtConsidered,'N') = 'Y'
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

UPDATE OG SET OG.[Count of tickets with Debt classification as Functional] = ADCTC.FunctionalDebtCount
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #FunctionalDebtCount ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Technical Debt 2
CREATE TABLE #TechnicalDebtCount(
ProjectId BIGINT,
[Month] TINYINT,
TechnicalDebtCount INT
)

INSERT INTO #TechnicalDebtCount(
ProjectId,
[Month] ,
TechnicalDebtCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [TechnicalDebtCount]
FROM AVL.TK_trn_ticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND TD.DebtClassificationMapID=2
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (2)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

INSERT INTO #TechnicalDebtCount(
ProjectId,
[Month] ,
TechnicalDebtCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [TechnicalDebtCount]
FROM AVL.TK_trn_infraticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND TD.DebtClassificationMapID=2
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (3)
GROUP BY TD.ProjectID,FORMAT(TD.Closeddate,'MM')

SELECT ProjectId,[Month],SUM(TechnicalDebtCount) AS  TechnicalDebtCount
INTO #TechnicalDebtCounts
FROM  #TechnicalDebtCount
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Count of tickets with Debt classification as Technical] = ADCTC.TechnicalDebtCount
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #TechnicalDebtCounts ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Environmental Debt 3
CREATE TABLE #EnvironmentalDebtCount(
ProjectId BIGINT,
[Month] TINYINT,
EnvironmentalDebtCount INT
)

INSERT INTO #EnvironmentalDebtCount(
ProjectId,
[Month] ,
EnvironmentalDebtCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [EnvironmentalDebtCount]
FROM AVL.TK_trn_infraticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND TD.DebtClassificationMapID=3
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (3)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

SELECT ProjectId,[Month],SUM(EnvironmentalDebtCount) AS EnvironmentalDebtCount
INTO #EnvironmentalDebtCounts
FROM  #EnvironmentalDebtCount
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Count of tickets with Debt classification as Environmental] = ADCTC.EnvironmentalDebtCount
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #EnvironmentalDebtCounts ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]
------------------------------------

---Count of Residual Tickets
CREATE TABLE #ResidualTicketsCount(
ProjectId BIGINT,
[Month] TINYINT,
ResidualTicketsCount INT
)

INSERT INTO #ResidualTicketsCount(
ProjectId,
[Month] ,
ResidualTicketsCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [ResidualTicketsCount]
FROM AVL.TK_trn_ticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND ISNULL(TD.ResidualDebtMapID,0)=1
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (2)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

INSERT INTO #ResidualTicketsCount(
ProjectId,
[Month] ,
ResidualTicketsCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [ResidualTicketsCount]
FROM AVL.TK_trn_infraticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND ISNULL(TD.ResidualDebtMapID,0)=1
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (3)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

SELECT ProjectId,[Month],SUM(ResidualTicketsCount) AS ResidualTicketsCount
INTO #ResidualTicketsCounts
FROM  #ResidualTicketsCount
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Count of Residual Tickets] = ADCTC.ResidualTicketsCount
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #ResidualTicketsCounts ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--31.Avoidable %---
CREATE TABLE #AvoidablePercentCount(
ProjectId BIGINT,
[Month] TINYINT,
AvoidablePercentCount INT
)

INSERT INTO #AvoidablePercentCount(
ProjectId,
[Month] ,
AvoidablePercentCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [AvoidablePercentCount]
FROM AVL.TK_trn_ticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND TD.AvoidableFlag=2
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (2)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM') 

INSERT INTO #AvoidablePercentCount(
ProjectId,
[Month] ,
AvoidablePercentCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [AvoidablePercentCount]
FROM AVL.TK_trn_infraticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND TD.AvoidableFlag=2
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (3)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

SELECT ProjectId,[Month],SUM(AvoidablePercentCount) AS AvoidablePercentCount
INTO #AvoidablePercentCounts
FROM  #AvoidablePercentCount
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Count of Avoidable Incidents] = ADCTC.AvoidablePercentCount
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #AvoidablePercentCounts ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Un Avoidable %
CREATE TABLE #UNAvoidablePercentCount(
ProjectId BIGINT,
[Month] TINYINT,
UNAvoidablePercentCount INT
)

INSERT INTO #UNAvoidablePercentCount(
ProjectId,
[Month] ,
UNAvoidablePercentCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [UNAvoidablePercentCount]
FROM AVL.TK_trn_ticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND TD.AvoidableFlag=3
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (2)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

INSERT INTO #UNAvoidablePercentCount(
ProjectId,
[Month] ,
UNAvoidablePercentCount)
SELECT TD.ProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,COUNT(TimeTickerID) AS [UNAvoidablePercentCount]
FROM AVL.TK_trn_infraticketdetail (NOLOCK) TD
JOIN AVL.[TK_MAP_TicketTypeMapping] (NOLOCK) MT
ON TD.TicketTypeMapID = MT.TicketTypeMappingID AND TD.IsDeleted=0 AND MT.IsDeleted=0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = TD.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE DARTSTATUSID = 8 AND Closeddate BETWEEN @STARTDATE AND @ENDDATE AND TD.AvoidableFlag=3
AND ISNULL(MT.DebtConsidered,'N') = 'Y' AND PP.AttributeValueID in (3)
GROUP BY TD.ProjectID ,FORMAT(TD.Closeddate,'MM')

SELECT ProjectId,[Month],SUM(UNAvoidablePercentCount) AS UNAvoidablePercentCount
INTO #UNAvoidablePercentCounts
FROM  #UNAvoidablePercentCount
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Count of Un - Avoidable Incidents] = ADCTC.UNAvoidablePercentCount
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #UNAvoidablePercentCounts ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Total Automation tickets created
CREATE TABLE #TotalAutomationticketsCreated(
ProjectId BIGINT,
[Month] TINYINT,
TotalAutomationticketsCreated INT
)

INSERT INTO #TotalAutomationticketsCreated(
ProjectId,
[Month] ,
TotalAutomationticketsCreated)
SELECT HPC.ProjectID,FORMAT(TD.CreatedDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'A' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate AND PP.AttributevalueId in (2)
GROUP BY HPC.ProjectID,FORMAT(TD.CreatedDate,'MM')

INSERT INTO #TotalAutomationticketsCreated(
ProjectId,
[Month] ,
TotalAutomationticketsCreated)
SELECT HPC.ProjectId,FORMAT(TD.CreatedDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'A' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate AND PP.AttributevalueId in (3)
GROUP BY HPC.ProjectId,FORMAT(TD.CreatedDate,'MM')

SELECT ProjectId,[Month],SUM(TotalAutomationticketsCreated) AS TotalAutomationticketsCreated
INTO #TotalAutomationticketsCreatedd
FROM  #TotalAutomationticketsCreated
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Total Automation tickets created] = ADCTC.TotalAutomationticketsCreated
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #TotalAutomationticketsCreatedd ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Total Healing tickets created
CREATE TABLE #TotalHealingticketsCreated(
ProjectId BIGINT,
[Month] TINYINT,
TotalHealingticketsCreated INT
)

INSERT INTO #TotalHealingticketsCreated(
ProjectId,
[Month] ,
TotalHealingticketsCreated)
SELECT HPC.ProjectID,FORMAT(TD.CreatedDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'H' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate AND PP.AttributeValueID IN (2)
GROUP BY HPC.ProjectID,FORMAT(TD.CreatedDate,'MM')

INSERT INTO #TotalHealingticketsCreated(
ProjectId,
[Month] ,
TotalHealingticketsCreated)
SELECT HPC.ProjectID,FORMAT(TD.CreatedDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'H' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate AND PP.AttributeValueID IN (3)
GROUP BY HPC.ProjectID,FORMAT(TD.CreatedDate,'MM')

SELECT ProjectId,[Month],SUM(TotalHealingticketsCreated) AS TotalHealingticketsCreated
INTO #TotalHealingticketsCreatedd
FROM  #TotalHealingticketsCreated
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Total Healing tickets created] = ADCTC.TotalHealingticketsCreated
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #TotalHealingticketsCreatedd ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Total Automation ticket In progress
CREATE TABLE #TotalAutomationticketsInprogress(
ProjectId BIGINT,
[Month] TINYINT,
TotalAutomationticketsInprogress INT
)

INSERT INTO #TotalAutomationticketsInprogress(
ProjectId,
[Month] ,
TotalAutomationticketsInprogress)
SELECT HPC.ProjectId,FORMAT(TD.CreatedDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'A' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate AND TD.DartStatusId NOT IN(5,6,7,8,9,12) AND PP.AttributeValueID in (2)
GROUP BY HPC.ProjectId,FORMAT(TD.CreatedDate,'MM')



INSERT INTO #TotalAutomationticketsInprogress(
ProjectId,
[Month] ,
TotalAutomationticketsInprogress)
SELECT HPC.ProjectId,FORMAT(TD.CreatedDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'A' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate AND TD.DartStatusId NOT IN(5,6,7,8,9,12) AND PP.AttributeValueID in (3)
GROUP BY HPC.ProjectId,FORMAT(TD.CreatedDate,'MM')

SELECT ProjectId,[Month],SUM(TotalAutomationticketsInprogress) AS TotalAutomationticketsInprogress
INTO #TotalAutomationticketsInprogresss
FROM  #TotalAutomationticketsInprogress
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Total Automation ticket In progress] = ADCTC.TotalAutomationticketsInprogress
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #TotalAutomationticketsInprogresss ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Total Healing ticket In progress
CREATE TABLE #TotalHealingticketsInprogress(
ProjectId BIGINT,
[Month] TINYINT,
TotalHealingticketsInprogress INT
)

INSERT INTO #TotalHealingticketsInprogress(
ProjectId,
[Month] ,
TotalHealingticketsInprogress)
SELECT HPC.ProjectID,FORMAT(TD.CreatedDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'H' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate AND TD.DartStatusId NOT IN(5,6,7,8,9,12) AND PP.AttributeValueId in (2)
GROUP BY HPC.ProjectID,FORMAT(TD.CreatedDate,'MM')

INSERT INTO #TotalHealingticketsInprogress(
ProjectId,
[Month] ,
TotalHealingticketsInprogress)
SELECT HPC.ProjectID,FORMAT(TD.CreatedDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'H' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate AND TD.DartStatusId NOT IN(5,6,7,8,9,12) AND PP.AttributeValueId in (3)
GROUP BY HPC.ProjectID,FORMAT(TD.CreatedDate,'MM')

SELECT ProjectId,[Month],SUM(TotalHealingticketsInprogress) AS TotalHealingticketsInprogress
INTO  #TotalHealingticketsInprogresss
FROM  #TotalHealingticketsInprogress
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Total Healing ticket In progress] = ADCTC.TotalHealingticketsInprogress
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #TotalHealingticketsInprogresss ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Total Cancelled Automation Tickets
CREATE TABLE #TotalCancelledAutomationTickets(
ProjectId BIGINT,
[Month] TINYINT,
TotalCancelledAutomationTickets INT
)

INSERT INTO #TotalCancelledAutomationTickets(
ProjectId,
[Month] ,
TotalCancelledAutomationTickets)
SELECT HPC.ProjectID,FORMAT(TD.CreatedDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'A' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate AND TD.DartStatusId = 5 AND PP.AttributeValueID in (2)
GROUP BY HPC.ProjectID,FORMAT(TD.CreatedDate,'MM')

INSERT INTO #TotalCancelledAutomationTickets(
ProjectId,
[Month] ,
TotalCancelledAutomationTickets)
SELECT HPC.ProjectID,FORMAT(TD.CreatedDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'A' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate AND TD.DartStatusId = 5 AND PP.AttributeValueID in (3)
GROUP BY HPC.ProjectID,FORMAT(TD.CreatedDate,'MM')

SELECT ProjectId,[Month],SUM(TotalCancelledAutomationTickets) AS TotalCancelledAutomationTickets
INTO  #TotalCancelledAutomationTicketss
FROM  #TotalCancelledAutomationTickets
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Total Cancelled Automation Tickets] = ADCTC.TotalCancelledAutomationTickets
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #TotalCancelledAutomationTicketss ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Total Cancelled Healing Tickets
CREATE TABLE #TotalCancelledHealingTickets(
ProjectId BIGINT,
[Month] TINYINT,
TotalCancelledHealingTickets INT
)

INSERT INTO #TotalCancelledHealingTickets(
ProjectId,
[Month] ,
TotalCancelledHealingTickets)
SELECT HPC.ProjectID,FORMAT(TD.CreatedDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'H' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate AND TD.DartStatusId = 5 AND PP.AttributeValueId in (2)
GROUP BY HPC.ProjectId,FORMAT(TD.CreatedDate,'MM')

INSERT INTO #TotalCancelledHealingTickets(
ProjectId,
[Month] ,
TotalCancelledHealingTickets)
SELECT HPC.ProjectId,FORMAT(TD.CreatedDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'H' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate AND TD.DartStatusId = 5 AND PP.AttributeValueId in (3)
GROUP BY HPC.ProjectId,FORMAT(TD.CreatedDate,'MM')

SELECT ProjectId,[Month],SUM(TotalCancelledHealingTickets) AS TotalCancelledHealingTickets
INTO  #TotalCancelledHealingTicketss
FROM  #TotalCancelledHealingTickets
GROUP BY ProjectId,[Month]

UPDATE OG SET OG.[Total Cancelled Healing Tickets] = ADCTC.TotalCancelledHealingTickets
FROM #OnPremGovernanceMetrics OG
JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
ON PM.EsaProjectID = OG.[Project ID] AND PM.IsDeleted = 0
JOIN #TotalCancelledHealingTicketss ADCTC 
ON ADCTC.ProjectId = PM.ProjectID AND ADCTC.[Month] = OG.[Month]

--Total Dormant Automation Tickets closed
CREATE TABLE #TotalDormantAutomationTicketsclosed(
ProjectId BIGINT,
[Month] TINYINT,
TotalDormantAutomationTicketsclosed INT
)

INSERT INTO #TotalDormantAutomationTicketsclosed(
ProjectId,
[Month] ,
TotalDormantAutomationTicketsclosed)
SELECT EsaProjectID,FORMAT(TD.MarkAsDormantDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPC.ProjectId AND PM.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'A' AND TD.MarkAsDormantDate BETWEEN @StartDate AND @EndDate AND TD.DartStatusId = 8 AND MarkAsDormant = 1 AND PP.AttributeValueID IN(2)
GROUP BY EsaProjectID,FORMAT(TD.MarkAsDormantDate,'MM')

INSERT INTO #TotalDormantAutomationTicketsclosed(
ProjectId,
[Month] ,
TotalDormantAutomationTicketsclosed)
SELECT EsaProjectID,FORMAT(IHEDD.MarkAsDormantDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketEfffortDormantDetails](NOLOCK) IHEDD
ON IHEDD.HealingId = TD.Id and IHEDD.IsDeleted = 0
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPC.ProjectId AND PM.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'A' AND IHEDD.MarkAsDormantDate BETWEEN @StartDate AND @EndDate AND TD.DartStatusId = 8 AND MarkAsDormant = 1 
AND PP.AttributeValueID IN(3)
GROUP BY EsaProjectID,FORMAT(IHEDD.MarkAsDormantDate,'MM')

SELECT ProjectId,[Month],SUM(TotalDormantAutomationTicketsclosed) AS TotalDormantAutomationTicketsclosed
INTO #TotalDormantAutomationTicketsclosedd
FROM  #TotalDormantAutomationTicketsclosed
GROUP BY ProjectId,[Month]

update #OnPremGovernanceMetrics set [Total Dormant Automation Tickets closed] = CAT.TotalDormantAutomationTicketsclosed
from #OnPremGovernanceMetrics as OPG
Inner join #TotalDormantAutomationTicketsclosedd as CAT on CAT.ProjectId = OPG.[Project ID] and CAT.[Month]=OPG.[Month]

--Total Dormant Healing Tickets closed
CREATE TABLE #TotalDormantHealingTicketsclosed(
ProjectId BIGINT,
[Month] TINYINT,
TotalDormantHealingTicketsclosed INT
)

INSERT INTO #TotalDormantHealingTicketsclosed(
ProjectId,
[Month] ,
TotalDormantHealingTicketsclosed)
SELECT EsaProjectID,FORMAT(TD.MarkAsDormantDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPC.ProjectId AND PM.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
WHERE TicketType = 'H' AND TD.MarkAsDormantDate BETWEEN @StartDate AND @EndDate AND PP.AttributeValueId in (2)
AND TD.DartStatusId = 8 AND MarkasDormant = 1
GROUP BY EsaProjectID,FORMAT(TD.MarkAsDormantDate,'MM')

INSERT INTO #TotalDormantHealingTicketsclosed(
ProjectId,
[Month] ,
TotalDormantHealingTicketsclosed)
SELECT EsaProjectID,FORMAT(IHEDD.MarkAsDormantDate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPC.ProjectId AND PM.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketEfffortDormantDetails](NOLOCK) IHEDD
ON IHEDD.HealingId = TD.Id and IHEDD.IsDeleted = 0
WHERE TicketType = 'H' AND IHEDD.MarkAsDormantDate BETWEEN @StartDate AND @EndDate AND PP.AttributeValueId in (3)
AND TD.DartStatusId = 8 AND MarkasDormant = 1
GROUP BY EsaProjectID,FORMAT(IHEDD.MarkAsDormantDate,'MM')

SELECT ProjectId,[Month],SUM(TotalDormantHealingTicketsclosed)	AS TotalDormantHealingTicketsclosed
INTO #TotalDormantHealingTicketsclosedd
FROM  #TotalDormantHealingTicketsclosed
GROUP BY ProjectId,[Month]

update #OnPremGovernanceMetrics set [Total Dormant Healing Tickets Closed] = CAT.TotalDormantHealingTicketsclosed
from #OnPremGovernanceMetrics as OPG
Inner join #TotalDormantHealingTicketsclosedd as CAT on CAT.ProjectId = OPG.[Project ID] and CAT.[Month]=OPG.[Month]


--Count of Automated Tickets which are Closed for the project
CREATE TABLE #CountAutomatedTicket(
ProjectId BIGINT,
[Month] TINYINT,
AutomatedTicketCount INT
)
--APP
INSERT INTO #CountAutomatedTicket(
ProjectId,
[Month] ,
AutomatedTicketCount)
SELECT PM.EsaProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,count(DISTINCT TD.HealingTicketID) as AutomatedTicketCount 
FROM  AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN AVL.TK_TRN_TicketDetail TiD (NOLOCK) ON
TiD.TicketID = TD.HealingTicketID AND TiD.ProjectID = HPC.ProjectID AND TiD.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPC.ProjectId AND PM.IsDeleted = 0
WHERE TicketType = 'A' AND TD.ClosedDate BETWEEN @STARTDATE AND @ENDDATE AND TD.DartStatusId = 8  AND  PP.AttributeValueID in (2)
AND Tid.AssignedTo IS NOT null
GROUP BY PM.EsaProjectID,FORMAT(TD.Closeddate,'MM')
--INFRA
INSERT INTO #CountAutomatedTicket(
ProjectId,
[Month] ,
AutomatedTicketCount)
SELECT PM.EsaProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID) as AutomatedTicketCount
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN AVL.TK_TRN_InfraTicketDetail TiD (NOLOCK) ON
TiD.TicketID = TD.HealingTicketID AND TiD.ProjectID = HPC.ProjectID AND TiD.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPC.ProjectId
WHERE TicketType = 'A' AND TD.ClosedDate BETWEEN @STARTDATE AND @ENDDATE AND TD.DartStatusId = 8  AND  PP.AttributeValueID in (3)
AND Tid.AssignedTo IS NOT null
GROUP BY PM.EsaProjectID,FORMAT(TD.Closeddate,'MM')

select ProjectId,[Month],sum(AutomatedTicketCount) as ATicketCount 
into #CountAutomatedTickets
from #CountAutomatedTicket
group by ProjectId,[Month]

update #OnPremGovernanceMetrics set [Count of Automated Tickets Closed for the project] = CAT.ATicketCount
from #OnPremGovernanceMetrics as OPG
Inner join #CountAutomatedTickets as CAT on CAT.ProjectId = OPG.[Project ID] and CAT.[Month]=OPG.[Month]


--Count of Healing Tickets which are Closed for the project
--APP
CREATE TABLE #CountHealingTicket(
ProjectId BIGINT,
[Month] TINYINT,
HealingTicketCount INT
)

INSERT INTO #CountHealingTicket(
ProjectId,
[Month] ,
HealingTicketCount)
SELECT PM.EsaProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,count( DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN AVL.TK_TRN_TicketDetail TiD (NOLOCK) ON
TiD.TicketID = TD.HealingTicketID AND TiD.ProjectID = HPC.ProjectID AND TiD.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPC.ProjectId  AND PM.IsDeleted = 0
WHERE TicketType = 'H' AND TD.ClosedDate BETWEEN @STARTDATE AND @ENDDATE AND TiD.DartStatusId = 8 AND  PP.AttributeValueID in (2)
AND Tid.AssignedTo IS NOT null
--AND Tid.Closedby <> null
GROUP BY PM.EsaProjectID,FORMAT(TD.Closeddate,'MM')
--INFRA 
INSERT INTO #CountHealingTicket(
ProjectId,
[Month] ,
HealingTicketCount)
SELECT PM.EsaProjectID,FORMAT(TD.Closeddate,'MM') AS T_Month,count(DISTINCT TD.HealingTicketID)
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPC
ON TD.ProjectPatternMapID=HPC.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0
JOIN AVL.TK_TRN_InfraTicketDetail TiD (NOLOCK) ON
TiD.TicketID = TD.HealingTicketID AND TiD.ProjectID = HPC.ProjectID AND TiD.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPC.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPC.ProjectId  AND PM.IsDeleted = 0
WHERE TicketType = 'H' AND TD.ClosedDate BETWEEN @STARTDATE AND @ENDDATE AND TiD.DartStatusId = 8 AND  PP.AttributeValueID in (3)
AND Tid.AssignedTo IS NOT null
--AND Tid.Closedby <> null
GROUP BY PM.EsaProjectID,FORMAT(TD.Closeddate,'MM')

select ProjectId,[Month],sum(HealingTicketCount) as HTicketCount 
into #CountHealingTickets
from #CountHealingTicket
group by ProjectId,[Month]

update #OnPremGovernanceMetrics set [Count of Healing Tickets Closed for the project] = SOEFAT.HTicketCount
from #OnPremGovernanceMetrics as OPG
Inner join #CountHealingTickets as SOEFAT on SOEFAT.ProjectId = OPG.[Project ID] and SOEFAT.[Month]=OPG.[Month]


--Sum of Efforts available for the child tickets which are tagged to all the Automation tickets available for the project
--APP
CREATE TABLE #SumofeffortforAutomationTicket(
ProjectId BIGINT,
[Month] TINYINT,
SumofEffort INT
)
INSERT INTO #SumofeffortforAutomationTicket(
ProjectId,
[Month] ,
SumofEffort)
SELECT PM.EsaProjectID,FORMAT(TD.OpenDate,'MM') AS T_Month,sum(HPC.EffortTillDate) as SumofEffort
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM
ON TD.ProjectPatternMapID=HPPM.ProjectPatternMapID
INNER JOIN AVL.DEBT_PRJ_HealParentChild (NOLOCK) HPC 
ON HPC.ProjectPatternMapID = HPPM.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0 AND HPPM.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPPM.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPPM.ProjectId  AND PM.IsDeleted = 0
WHERE TicketType = 'A' AND TD.OpenDate BETWEEN @StartDate AND @EndDate AND  PP.AttributeValueID in (2)
GROUP BY PM.EsaProjectID,FORMAT(TD.OpenDate,'MM')
--INFRA
INSERT INTO #SumofeffortforAutomationTicket(
ProjectId,
[Month] ,
SumofEffort)
SELECT PM.EsaProjectID,FORMAT(TD.OpenDate,'MM') AS T_Month,sum(HPC.EffortTillDate) as SumofEffort
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPPM
ON TD.ProjectPatternMapID=HPPM.ProjectPatternMapID
INNER JOIN AVL.DEBT_PRJ_InfraHealParentChild  (NOLOCK) HPC 
ON HPC.ProjectPatternMapID = HPPM.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0 AND HPPM.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPPM.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPPM.ProjectId AND PM.IsDeleted = 0
WHERE TicketType = 'A' AND TD.OpenDate BETWEEN @StartDate AND @EndDate AND  PP.AttributeValueID in (3)
GROUP BY PM.EsaProjectID,FORMAT(TD.OpenDate,'MM')

select ProjectId,[Month],SUM(SumofEffort) AS SumofeffortforATicketChild 
into #SumofeffortforAutomationTickets
from #SumofeffortforAutomationTicket 
group by ProjectId,[Month]


update #OnPremGovernanceMetrics set [Sum of Efforts available for the child tickets which are tagged to all the Automation tickets available for the project] = SOEFAT.SumofeffortforATicketChild
from #OnPremGovernanceMetrics as OPG
Inner join #SumofeffortforAutomationTickets as SOEFAT on SOEFAT.ProjectId = OPG.[Project ID] and SOEFAT.[Month]=OPG.[Month]

--Sum of Efforts available for the child tickets which are tagged to all the Healing tickets available for the project
CREATE TABLE #SumofeffortforHealingTicket(
ProjectId BIGINT,
[Month] TINYINT,
SumofEffort INT
)
--APP
INSERT INTO #SumofeffortforHealingTicket(
ProjectId,
[Month] ,
SumofEffort)
SELECT PM.EsaProjectID,FORMAT(TD.OpenDate,'MM') AS T_Month,sum(HPC.EffortTillDate)
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM
ON TD.ProjectPatternMapID=HPPM.ProjectPatternMapID
INNER JOIN AVL.DEBT_PRJ_HealParentChild (NOLOCK) HPC 
ON HPC.ProjectPatternMapID = HPPM.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0 AND HPPM.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPPM.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPPM.ProjectId AND PM.IsDeleted = 0
WHERE TicketType = 'H' AND TD.OpenDate BETWEEN @StartDate AND @EndDate AND  PP.AttributeValueID in (2)
GROUP BY PM.EsaProjectID,FORMAT(TD.OpenDate,'MM')
--INFRA
INSERT INTO #SumofeffortforHealingTicket(
ProjectId,
[Month] ,
SumofEffort)
SELECT PM.EsaProjectID,FORMAT(TD.OpenDate,'MM') AS T_Month,sum(HPC.EffortTillDate)
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic]  (NOLOCK) HPPM
ON TD.ProjectPatternMapID=HPPM.ProjectPatternMapID
INNER JOIN AVL.DEBT_PRJ_InfraHealParentChild (NOLOCK) HPC 
ON HPC.ProjectPatternMapID = HPPM.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0 AND HPPM.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPPM.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1 
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPPM.ProjectId AND PM.IsDeleted = 0
WHERE TicketType = 'H' AND TD.OpenDate BETWEEN @StartDate AND @EndDate AND  PP.AttributeValueID in (3)
GROUP BY PM.EsaProjectID,FORMAT(TD.OpenDate,'MM')

select ProjectId,[MONTH],sum(SumofEffort) AS SumofEffortforHTicketchild 
into #SumofeffortforHealingTickets
from #SumofeffortforHealingTicket 
group by ProjectId,[Month]

update #OnPremGovernanceMetrics set [Sum of Efforts available for the child tickets which are tagged to all the Healing tickets available for the project] = SOEFHT.SumofEffortforHTicketchild
from #OnPremGovernanceMetrics as OPG
Inner join #SumofeffortforHealingTickets as SOEFHT on SOEFHT.ProjectId = OPG.[Project ID] and SOEFHT.[Month]=OPG.[Month]

--Count of child tickets available for all the Healing tickets available for the project
CREATE TABLE #CountofchildHealingTicket(
ProjectId BIGINT,
[Month] TINYINT,
Countofticket INT
)
--APP
INSERT INTO #CountofchildHealingTicket(
ProjectId,
[Month] ,
Countofticket)
SELECT PM.EsaProjectID,FORMAT(TD.CreatedDate,'MM') AS T_Month,count(HPC.DARTTicketId)
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM
ON TD.ProjectPatternMapID=HPPM.ProjectPatternMapID
INNER JOIN AVL.DEBT_PRJ_HealParentChild (NOLOCK) HPC 
ON HPC.ProjectPatternMapID = HPPM.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0 AND HPPM.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPPM.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1 
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPPM.ProjectId AND PM.IsDeleted = 0
WHERE TicketType = 'H' AND TD.CreatedDate BETWEEN @StartDate AND @EndDate  AND  PP.AttributeValueID in (2)
GROUP BY PM.EsaProjectID,FORMAT(TD.CreatedDate,'MM')
--Infra
INSERT INTO #CountofchildHealingTicket(
ProjectId,
[Month] ,
Countofticket)
SELECT PM.EsaProjectID,FORMAT(TD.CreatedDate,'MM') AS T_Month,count(HPC.DARTTicketId)
FROM  AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN  [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPPM
ON TD.ProjectPatternMapID=HPPM.ProjectPatternMapID
INNER JOIN AVL.DEBT_PRJ_InfraHealParentChild (NOLOCK) HPC 
ON HPC.ProjectPatternMapID = HPPM.ProjectPatternMapID
AND ISNULL(TD.IsDeleted,0)=0 AND HPC.IsDeleted = 0 AND HPPM.IsDeleted = 0
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPPM.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1 
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPPM.ProjectId AND PM.IsDeleted = 0
WHERE TicketType = 'H' AND  PP.AttributeValueID in (3)
AND TD.CreatedDate between @StartDate AND @EndDate
and PM.IsDeleted = 0
GROUP BY PM.EsaProjectID,FORMAT(TD.CreatedDate,'MM')

select ProjectId,[MONTH],sum(Countofticket) AS CountofchildHTicket 
into #CountofchildHealingTickets
from #CountofchildHealingTicket 
group by ProjectId,[Month]

update #OnPremGovernanceMetrics set [Count of child tickets available for all the Healing tickets available for the project] = COCHT.CountofchildHTicket
from #OnPremGovernanceMetrics as OPG
Inner join #CountofchildHealingTickets as COCHT on COCHT.ProjectId = OPG.[Project ID] and COCHT.[Month]=OPG.[Month]

-- Total Number of Completed Months from Automation ticket open date
CREATE TABLE #TotalACompletedMonths(
ProjectId BIGINT,
[SMonth] TINYINT,
[LMonth] TINYINT
)

SELECT DISTINCT TD.HealingTicketId,PM.EsaProjectID,FORMAT(TD.OpenDate,'MM') AS SMonth,FORMAT(@ENDDATE,'MM') AS LMonth
INTO #deviedfromAticket 
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM
ON TD.ProjectPatternMapID=HPPM.ProjectPatternMapID
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPPM.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM on PM.ProjectID = HPPM.ProjectId AND PM.IsDeleted = 0
WHERE TicketType = 'A' AND PP.AttributeValueID in (2)
and PM.IsDeleted = 0 and TD.OpenDate between @STARTDATE AND @ENDDATE 

INSERT INTO #TotalACompletedMonths(
ProjectId,
SMonth,
LMonth)
SELECT DISTINCT EsaProjectID,SMonth,LMonth 
FROM #deviedfromAticket
GROUP BY EsaProjectID,SMonth,LMonth 


SELECT DISTINCT TD.HealingTicketId,PM.EsaProjectID,FORMAT(TD.OpenDate,'MM') AS SMonth,FORMAT(@ENDDATE,'MM') AS LMonth
INTO #deviedfromAticketinfra 
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPPM
ON TD.ProjectPatternMapID=HPPM.ProjectPatternMapID
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPPM.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM on PM.ProjectID = HPPM.ProjectId AND PM.IsDeleted = 0
WHERE TicketType = 'A' AND PP.AttributeValueID in (3)
and PM.IsDeleted = 0 and TD.OpenDate between @STARTDATE AND @ENDDATE 

INSERT INTO #TotalACompletedMonths(
ProjectId,
SMonth,
LMonth)
SELECT DISTINCT EsaProjectID,SMonth,LMonth 
FROM #deviedfromAticketinfra
GROUP BY EsaProjectID,SMonth,LMonth 

select DISTINCT ProjectId,SMonth,SUM(LMonth - SMonth) AS CompletedMonthCounts 
into #TotalACompletedMonthss
from #TotalACompletedMonths 
group by ProjectId,SMonth

update #OnPremGovernanceMetrics set [Total Number of Completed Months from Automation ticket open date] = COCHT.CompletedMonthCounts
from #OnPremGovernanceMetrics as OPG
Inner join #TotalACompletedMonthss as COCHT on COCHT.ProjectId = OPG.[Project ID] and COCHT.[SMonth]=OPG.[Month]


-- Total Number of Completed Months from Healing ticket open date
CREATE TABLE #TotalHCompletedMonths(
ProjectId BIGINT,
[SMonth] TINYINT,
[LMonth] TINYINT
)


SELECT DISTINCT TD.HealingTicketId,PM.EsaProjectID,FORMAT(TD.OpenDate,'MM') AS SMonth,FORMAT(@ENDDATE,'MM') AS LMonth
INTO #deviedfromHticket 
FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM
ON TD.ProjectPatternMapID=HPPM.ProjectPatternMapID
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPPM.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM on PM.ProjectID = HPPM.ProjectId AND PM.IsDeleted = 0
WHERE TicketType = 'H' AND PP.AttributeValueID in (2)
and PM.IsDeleted = 0 and TD.OpenDate between @STARTDATE AND @ENDDATE 

INSERT INTO #TotalHCompletedMonths(
ProjectId,
SMonth,
LMonth)
SELECT DISTINCT EsaProjectID,SMonth,LMonth
FROM #deviedfromHticket
GROUP BY EsaProjectID,SMonth,LMonth


SELECT DISTINCT TD.HealingTicketId,PM.EsaProjectID,FORMAT(TD.OpenDate,'MM') AS SMonth,FORMAT(@ENDDATE,'MM') AS LMonth
INTO #deviedfromHticketinfra 
FROM AVL.DEBT_TRN_InfraHealTicketDetails(NOLOCK) TD
INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPPM
ON TD.ProjectPatternMapID=HPPM.ProjectPatternMapID
JOIN PP.ProjectAttributeValues(NOLOCK) PP
ON PP.ProjectID = HPPM.ProjectID AND PP.IsDeleted = 0 AND PP.AttributeID = 1
INNER JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = HPPM.ProjectId AND PM.IsDeleted = 0
WHERE TicketType = 'H' AND PP.AttributeValueID in (3)
and PM.IsDeleted = 0 and TD.OpenDate between @STARTDATE AND @ENDDATE 

INSERT INTO #TotalHCompletedMonths(
ProjectId,
SMonth,
LMonth)
SELECT DISTINCT EsaProjectID,SMonth,LMonth
FROM #deviedfromHticketinfra
GROUP BY EsaProjectID,SMonth,LMonth

select DISTINCT ProjectId,SMonth,sum(LMonth - SMonth) AS CompletedMonthCounts 
into #TotalHCompletedMonthss
from #TotalHCompletedMonths 
group by ProjectId,SMonth

update #OnPremGovernanceMetrics set [Total Number of Completed Months from Healing ticket open date] = COCHT.CompletedMonthCounts
from #OnPremGovernanceMetrics as OPG
Inner join #TotalHCompletedMonthss as COCHT on COCHT.ProjectId = OPG.[Project ID] and COCHT.[SMonth]=OPG.[Month]


UPDATE #OnPremGovernanceMetrics 
SET [Month]= LEFT(DateName(MONTH,DATEADD(mm,CAST([Month] AS tinyint),-1)),3)



SELECT * FROM #OnPremGovernanceMetrics ORDER BY [Account ID],[Project ID]
COMMIT TRAN
END TRY
BEGIN CATCH 
	DECLARE @ErrorMessage VARCHAR(4000);  
	SELECT @ErrorMessage = ERROR_MESSAGE()
ROLLBACK TRAN
	 --INSERT Error 
	EXEC AVL_InsertError '[AVL].[GetOnPremGovernanceMetricsCustomerwise]', @ErrorMessage ,0

END CATCH	

END
