/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE proc [AVL].[GetDailyDefaultersdetailsList]
AS
BEGIN
DECLARE @DATE DATEtime
DECLARE @PrevDate DATE
declare @Count int
Declare @DATES date
DECLARE @DAYNumber INT
SET @DAYNumber = (SELECT DATEPART(dw,GETDATE()))

IF(@DAYNumber = 2 OR @DAYNumber =3)
BEGIN
	SET @DATE = (SELECT getdate()-4)
	set @Count=4
END
ELSE IF(@DAYNumber = 4 OR @DAYNumber = 5 OR @DAYNumber = 6)
BEGIN
	SET @DATE = (SELECT getdate()-2)
	set @Count=2
END
SELECT convert(varchar, @DATE, 106) as SubjectDate
set @DATES=(select cast(@DATE as DATE))
DECLARE @NOWDATE DATE
SET @NOWDATE=DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE))
IF(datename(dw,@NOWDATE)='SUNDAY')
BEGIN
SET @NOWDATE=DATEADD(DAY, -1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE))
END
ELSE IF(datename(dw,@NOWDATE)='SATURDAY')
BEGIN
SET @NOWDATE=DATEADD(DAY, 0 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE))
END
set @NOWDATE=@DATE
SET @PrevDate=DATEADD(DAY, -28 - DATEPART(WEEKDAY, @NOWDATE), CAST(@NOWDATE AS DATE))      --(SELECT @DATE -(30+ @Count))
SET @PrevDate=DATEADD(day,-30, @NOWDATE) 
DECLARE @LastBusinessDay Datetime
SEt @LastBusinessDay = dbo.WorkDay(@NOWDATE,-30)
set @PrevDate=@LastBusinessDay
PRINT @PrevDate 
PRINT @NOWDATE
PRINT datename(dw,@NOWDATE)

--New Code
DECLARE @ConfigDays AS INT=1
DECLARE @HUNDRED AS INT=100

DECLARE @EligibleCustomer AS TABLE
( CustomerID BIGINT)

DECLARE @ConfigTABLE AS Table
(
ConfigValue  DECIMAL(5,2),
MailerRequired  INT
)


INSERT INTO @ConfigTABLE
SELECT MDC.ConfigValue,MDC.MailerRequired FROM AVL.MAP_DefaultMailerConfig MDC 
------------------- Getting Configured Projects
DECLARE @Validprojects as table
(
ProjectID bigint not null,
CustomerID bigint not null
)

INSERT into @Validprojects
select DISTINCT PM.ProjectID,PM.CustomerID from  AVL.MAS_ProjectMaster PM  
join AVL.Customer C on C.CustomerID=PM.CustomerID and C.IsDeleted=0 and C.IsDaily=1 and c.IsEffortConfigured=1
join AVMDART_MigratedProjectsInfo D on D.ESAProjectID=Pm.EsaProjectID and D.OperationalDate is not null 
where pm.IsMigratedFromDART=1 and PM.IsDeleted=0 and PM.IsESAProject=1
AND (PM.IsODCRestricted<>'Y' OR PM.IsODCRestricted IS NULL)
UNION
select DISTINCT PM.ProjectID,Pm.CustomerID  from AVL.MAS_ProjectMaster PM 
join AVL.Customer C on C.CustomerID=PM.CustomerID and C.IsDeleted=0 and C.IsDaily=1 and c.IsEffortConfigured=1
join AVL.PRJ_ConfigurationProgress CP on CP.ProjectID=PM.ProjectID and CP.ScreenID=2 and CP.ITSMScreenId=(CASE WHEN C.IsCognizant=1 THEN 11 ELSE 9 END) and CP.CompletionPercentage=100 and CP.IsDeleted=0
--join AVL.PRJ_ConfigurationProgress CP on CP.ProjectID=PM.ProjectID and CP.ScreenID=2 and CP.ITSMScreenId=11 and CP.CompletionPercentage=100 and CP.IsDeleted=0
join AVL.PRJ_ConfigurationProgress CP1 on CP1.ProjectID=PM.ProjectID and CP1.ScreenID=4  and CP1.CompletionPercentage=100 and cp1.IsDeleted=0
WHERE (pm.IsMigratedFromDART=2 or pm.IsMigratedFromDART is null) and PM.IsDeleted=0 and PM.IsESAProject=1 AND (PM.IsODCRestricted<>'Y' OR PM.IsODCRestricted IS NULL)
-----------------------------

--DROP TABLE #MAS_LoginMaster
SELECT UserID,LM.CustomerID,EmployeeID,EmployeeName,EmployeeEmail 
INTO #MAS_LoginMaster 
FROM AVL.MAS_LoginMaster LM
INNER join @Validprojects P on P.ProjectID=LM.ProjectID
INNER JOIN AVL.Customer C On C.CustomerID=P.CustomerID AND C.IsDaily=1 and c.Defaultermail=1 AND C.IsDeleted=0 and c.IsEffortConfigured=1
AND lM.IsDeleted=0 AND LM.TicketingModuleEnabled=1 and LM.MandatoryHours>0

DECLARE @ResultTable AS TABLE
(
TimeSheetHours DECIMAL(5,2),
TimeSheetDate DATE,
EmployeeID NVARCHAR(10),
EmployeeName NVARCHAR(MAX),
Employee NVARCHAR(MAX),
EmployeeEmail NVARCHAR(MAX),
ESA_AccountID BIGINT,
CustomerName NVARCHAR(MAX),
Customer NVARCHAR(MAX),
CustomerID BIGINT
)
DECLARE @BuildResultTable AS TABLE
(
TimeSheetHours DECIMAL(5,2),
TimeSheetDate DATE,
EmployeeUD NVARCHAR(10),
ESA_AccountID BIGINT,
CustomerName NVARCHAR(MAX),
Customer NVARCHAR(MAX),
CustomerID BIGINT,
StatusID INT,
SubmitterID INT
)



INSERT INTO @BuildResultTable
SELECT 
DISTINCT
ISNULL(SUM(TSD.Hours),0) Hours,
DT.date,
LM.EmployeeID,
(CASE WHEN C.ESA_AccountID IS NULL THEN C.CustomerID ELSE C.ESA_AccountID END),
C.CustomerName,
C.CustomerName+'('+CONVERT(VARCHAR(30),(CASE WHEN C.ESA_AccountID IS NULL THEN C.CustomerID ELSE C.ESA_AccountID END))+')' as Customer,
C.CustomerID,
TS.StatusId,
TS.SubmitterId
 FROM AVL.GetDates(dbo.WorkDay(@NOWDATE,-30),@NOWDATE) DT
INNER JOIN AVL.Customer C ON  c.IsDaily=1 AND C.IsDeleted=0 and c.IsEffortConfigured=1
INNER JOIN #MAS_LoginMaster LM ON C.CustomerID=LM.CustomerID 
INNER JOIN @ConfigTABLE Conf ON Conf.MailerRequired=1
LEFT JOIN AVL.TM_PRJ_Timesheet TS (NOLOCK) ON DT.Date=TS.TimesheetDate   AND Ts.SubmitterId=LM.UserID
LEFT JOIN AVL.TM_TRN_TimesheetDetail TSD ON TSD.TimesheetId=TS.TimesheetId AND LM.UserID=TS.SubmitterId
AND TS.TimesheetDate>=@PrevDate  AND ts.TimesheetDate <=@NOWDATE
WHERE  C.CustomerID not in
(select C.ESA_AccountID from AVMDART_MigratedProjectsInfo (nolock) MPI 	join AVL.Customer C on C.ESA_AccountID=MPI.ESAAccountID
WHERE operationaldate is null )
GROUP BY
C.ESA_AccountID,
C.CustomerName,
DT.date,
C.CustomerID,
LM.EmployeeID,
TS.StatusId,
TS.SubmitterId
ORDER BY DT.Date DESC


--SELECT  DISTINCT EmployeeUD FROM @BuildResultTable where SubmitterID IS NULL -- Pure Defaulters who are not having any record
--UNION
--SELECT  DISTINCT EmployeeUD FROM @BuildResultTable where StatusID NOT IN (2,3) -- Pure Defaulters once again, not having proper status but having entries

INSERT INTO @ResultTable
SELECT 
DISTINCT
B.TimeSheetHours,
B.TimeSheetDate,
LM.EmployeeID,
LM.EmployeeName,
LM.EmployeeName+'('+CONVERT(VARCHAR(30),LM.EmployeeID)+')' as Employee,
LM.EmployeeEmail,
(CASE WHEN B.ESA_AccountID IS NULL THEN B.CustomerID ELSE B.ESA_AccountID END),
B.CustomerName,
B.Customer,
B.CustomerID
FROM @BuildResultTable B INNER JOIN  #MAS_LoginMaster LM
ON  LM.employeeID=B.EmployeeUD
WHERE (B.SubmitterID IS NULL OR B.StatusID NOT IN (2,3))


INSERT INTO @EligibleCustomer (CustomerID)
SELECT  DefaulterTable.CustomerID  FROM 
(SELECT CustomerID,COUNT(DISTINCT EmployeeID) AS Defaulters FROM @ResultTable GROUP BY CustomerID) AS DefaulterTable
INNER JOIN 
(SELECT LM.CustomerID,COUNT(DISTINCT LM.EmployeeID) AS ActiveUser FROM #MAS_LoginMaster LM (NOLOCK) INNER JOIN @ResultTable R On R.CustomerID=LM.CustomerID GROUP BY LM.CustomerID)
AS ActiveUserTable
ON DefaulterTable.CustomerID=ActiveUserTable.CustomerID
WHERE ((DefaulterTable.Defaulters)*@HUNDRED)/(ActiveUserTable.ActiveUser*@ConfigDays) >
(SELECT ConfigValue from @ConfigTABLE)

--SELECT SUM(TimeSheetHours) AS TimeSheetHours,DatePart(week,TimeSheetDate) TimeSheetDate, EmployeeID,EmployeeName,Employee,EmployeeEmail, ESA_AccountID,CustomerName,Customer,CustomerID
--FROM @ResultTable
--GROUP BY DatePart(week,TimeSheetDate), EmployeeID,EmployeeName,Employee,EmployeeEmail, ESA_AccountID,CustomerName,Customer,CustomerID

SELECT R.TimeSheetHours as Hours,convert(varchar,R.TimeSheetDate,6) as TSDate,R.EmployeeID,R.EmployeeName,R.Employee,R.EmployeeEmail,R.ESA_AccountID as CustomerID,R.CustomerName,R.Customer 
FROM @ResultTable R INNER JOIN @EligibleCustomer E On R.CustomerID=E.CustomerID  
--where R.ESA_AccountID=1230511
ORDER BY R.TimeSheetDate DESC


END
