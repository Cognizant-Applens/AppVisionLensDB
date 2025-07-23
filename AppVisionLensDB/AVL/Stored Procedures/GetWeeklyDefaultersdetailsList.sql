/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/



CREATE proc [AVL].[GetWeeklyDefaultersdetailsList]
AS
BEGIN
DECLARE @DATE DATEtime
DECLARE @PrevDate DATE
declare @Count int
Declare @Week1StartDate datetime
declare @Week1EndDate datetime

Declare @Week2StartDate datetime
declare @Week2EndDate datetime

Declare @Week3StartDate datetime
declare @Week3EndDate datetime

Declare @Week4StartDate datetime
declare @Week4EndDate datetime

DECLARE @DAYNumber INT
Declare @week int

SET @DAYNumber =(SELECT DATEPART(dw,GETDATE()))--Get the weekday Number
set @week=1
DECLARE @at DATETIME
set @at=(SELECT getdate())
set @DAYNumber=4
IF(@DAYNumber = 4)
BEGIN
declare @date1 datetime
declare @date2 datetime
declare @date3 datetime
declare @date4 datetime
declare @date5 datetime
declare @date6 datetime
declare @date7 datetime
declare @date8 datetime
declare @date9 datetime
declare @date10 datetime
declare @datedup1 datetime
set @date9=DATEADD(DAY, 2 - DATEPART(WEEKDAY, @at), CAST(@at AS DATE))  
set @date10=DATEADD(DAY, 6 - DATEPART(WEEKDAY, @at), CAST(@at AS DATE))
set @datedup1=dateadd(day,datediff(day,2,@date9),0)
set @Week4StartDate=DATEADD(DAY, 2 - DATEPART(WEEKDAY,@datedup1), CAST(@datedup1 AS DATE))  
set @Week4EndDate=DATEADD(DAY, 6 - DATEPART(WEEKDAY, @datedup1), CAST(@datedup1 AS DATE)) 
set @datedup1=dateadd(day,datediff(day,2,@Week4StartDate),0)
set @Week3StartDate=DATEADD(DAY, 2 - DATEPART(WEEKDAY,@datedup1), CAST(@datedup1 AS DATE))  
set @Week3EndDate=DATEADD(DAY, 6 - DATEPART(WEEKDAY, @datedup1), CAST(@datedup1 AS DATE)) 
set @datedup1=dateadd(day,datediff(day,2,@Week3StartDate),0)
set @Week2StartDate=DATEADD(DAY, 2 - DATEPART(WEEKDAY,@datedup1), CAST(@datedup1 AS DATE))  
set @Week2EndDate=DATEADD(DAY, 6 - DATEPART(WEEKDAY, @datedup1), CAST(@datedup1 AS DATE)) 
set @datedup1=dateadd(day,datediff(day,2,@Week2StartDate),0)
set @Week1StartDate=DATEADD(DAY, 2 - DATEPART(WEEKDAY,@datedup1), CAST(@datedup1 AS DATE))  
set @Week1EndDate=DATEADD(DAY, 6 - DATEPART(WEEKDAY, @datedup1), CAST(@datedup1 AS DATE)) 
END
--select @Week4EndDate
--select @Week1StartDate
select (convert(varchar, @Week4StartDate, 106))  as Date1,(convert(varchar, @Week4EndDate, 106)) as Date2

--New Code
DECLARE @ConfigDays AS INT=1
DECLARE @HUNDRED AS INT=100



DECLARE @EligibleCustomer AS TABLE
( CustomerID BIGINT,Configcal BIGINT)



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
join AVL.Customer C on C.CustomerID=PM.CustomerID and C.IsDeleted=0 and C.IsDaily<>1 and C.IsEffortConfigured=1
join AVMDART_MigratedProjectsInfo D on D.ESAProjectID=Pm.EsaProjectID and D.OperationalDate is not null 
where pm.IsMigratedFromDART=1 and PM.IsDeleted=0 and PM.IsESAProject=1 
AND (PM.IsODCRestricted<>'Y' OR PM.IsODCRestricted IS NULL)
UNION
select DISTINCT PM.ProjectID,Pm.CustomerID  from AVL.MAS_ProjectMaster PM 
join AVL.Customer C on C.CustomerID=PM.CustomerID and C.IsDeleted=0 and C.IsDaily<>1  and C.IsEffortConfigured=1
join AVL.PRJ_ConfigurationProgress CP on CP.ProjectID=PM.ProjectID and CP.ScreenID=2 and CP.ITSMScreenId=(CASE WHEN C.IsCognizant=1 THEN 11 ELSE 9 END) and CP.CompletionPercentage=100 and CP.IsDeleted=0
join AVL.PRJ_ConfigurationProgress CP1 on CP1.ProjectID=PM.ProjectID and CP1.ScreenID=4  and CP1.CompletionPercentage=100 and cp1.IsDeleted=0
WHERE (pm.IsMigratedFromDART=2 or pm.IsMigratedFromDART is null) and PM.IsDeleted=0 and PM.IsESAProject=1 AND (PM.IsODCRestricted<>'Y' OR PM.IsODCRestricted IS NULL)


------------------------------

SELECT UserID,LM.CustomerID,EmployeeID,EmployeeName,EmployeeEmail 
INTO #MAS_LoginMaster 
FROM AVL.MAS_LoginMaster LM
inner join @Validprojects P on P.ProjectID=LM.ProjectID 
INNER JOIN AVL.Customer C On C.CustomerID=P.CustomerID AND C.IsDaily<>1 and c.Defaultermail=1 AND C.IsDeleted=0 and C.IsEffortConfigured=1
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
EmployeeID NVARCHAR(10),
ESA_AccountID BIGINT,
CustomerName NVARCHAR(MAX),
Customer NVARCHAR(MAX),
CustomerID BIGINT,
StatusID INT,
SubmitterID INT
)

DECLARE @HoursContainer AS TABLE
(
EmployeeID  NVARCHAR(10),
WeekNumber INT,
CustomerID BIGINT,
TimeSheetHours DECIMAL(5,2)
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
 FROM AVL.GetDates(dbo.WorkDay(@Week4EndDate,-30),@Week4EndDate) DT
INNER JOIN AVL.Customer C ON  c.IsDaily<>1 AND C.IsDeleted=0 and C.IsEffortConfigured=1
INNER JOIN #MAS_LoginMaster LM ON C.CustomerID=LM.CustomerID 
INNER JOIN @ConfigTABLE Conf ON Conf.MailerRequired=1
LEFT JOIN AVL.TM_PRJ_Timesheet TS (NOLOCK) ON DT.Date=TS.TimesheetDate   AND Ts.SubmitterId=LM.UserID
LEFT JOIN AVL.TM_TRN_TimesheetDetail TSD ON TSD.TimesheetId=TS.TimesheetId --AND LM.UserID=TS.SubmitterId
AND TS.TimesheetDate>=@Week1StartDate  AND ts.TimesheetDate <=@Week4EndDate
WHERE 
C.CustomerID not in
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

-- Push the Hours for each employee for each date to a @HoursContainer table
INSERT INTO @HoursContainer
(EmployeeID, WeekNumber,CustomerID,TimeSheetHours)
SELECT DISTINCT EmployeeID,DATEPART(WK,TimeSheetDate) WeekNumber,CustomerID,SUM(TimeSheetHours)
FROM @BuildResultTable 
GROUP BY EmployeeID,DATEPART(WK,TimeSheetDate) ,CustomerID

--Eliminate the valid users from the above table @BuildResultTable

DELETE FROM BRT
FROM @BuildResultTable BRT INNER JOIN (
SELECT EmployeeID,TimeSheetDate,CustomerID FROM @BuildResultTable where StatusID IN (2,3) AND SubmitterID IS NOT NULL
) AS ValidUsers
ON BRT.CustomerID=ValidUsers.CustomerID
AND BRT.TimeSheetDate=ValidUsers.TimeSheetDate
AND BRT.EmployeeID=ValidUsers.EmployeeID



DELETE FROM BRT
FROM @BuildResultTable BRT INNER JOIN (
SELECT EmployeeID,TimeSheetDate,CustomerID FROM @BuildResultTable where TimeSheetDate<@Week1StartDate
) AS ValidUsers
ON BRT.CustomerID=ValidUsers.CustomerID
AND BRT.TimeSheetDate=ValidUsers.TimeSheetDate
AND BRT.EmployeeID=ValidUsers.EmployeeID



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
--nullif(B.ESA_AccountID,B.CustomerID),
B.CustomerName,
B.Customer,
B.CustomerID
FROM @BuildResultTable B INNER JOIN  #MAS_LoginMaster LM
ON  LM.employeeID=B.EmployeeID
WHERE (B.SubmitterID IS NULL OR B.StatusID NOT IN (2,3))



INSERT INTO @EligibleCustomer (CustomerID,Configcal)
SELECT  DefaulterTable.CustomerID,((DefaulterTable.Defaulters)*@HUNDRED)/(ActiveUserTable.ActiveUser*@ConfigDays)  FROM 
(SELECT CustomerID,COUNT(DISTINCT EmployeeID) AS Defaulters FROM @ResultTable GROUP BY CustomerID) AS DefaulterTable
INNER JOIN 
(SELECT LM.CustomerID,COUNT(DISTINCT LM.EmployeeID) AS ActiveUser FROM #MAS_LoginMaster LM (NOLOCK) INNER JOIN @ResultTable R On R.CustomerID=LM.CustomerID GROUP BY LM.CustomerID)
AS ActiveUserTable
ON DefaulterTable.CustomerID=ActiveUserTable.CustomerID
WHERE ((DefaulterTable.Defaulters)*@HUNDRED)/(ActiveUserTable.ActiveUser*@ConfigDays) >
(SELECT ConfigValue from @ConfigTABLE)


SELECT
DISTINCT
 HC.TimeSheetHours AS Hours,
WeeknumberDates.DateLabel as TSDate, 
R.EmployeeID,
EmployeeName,
Employee,
EmployeeEmail, 
ESA_AccountID as CustomerID,
CustomerName,
Customer,
HC.WeekNumber 
FROM @ResultTable R INNER JOIN @EligibleCustomer E On R.CustomerID=E.CustomerID
INNER join (SELECT  DISTINCT
CONVERT(VARCHAR(20), DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar(5),YEAR(GETDATE()))) + (DATEPART(WK,Date) -1), 6),106)
+' - ' + 
CONVERT(VARCHAR(20), DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar(5),YEAR(GETDATE()))) + (DATEPART(WK,Date) -1), 5),106) AS DateLabel,
DATEPART(WK,Date) weeknumber
FROM AVL.GetDates(@Week1StartDate,@Week4EndDate)) WeeknumberDates 
on WeeknumberDates.weeknumber=DatePart(week,R.TimeSheetDate) 
INNER JOIN @HoursContainer HC On HC.EmployeeID=R.EmployeeID
AND HC.WeekNumber=WeeknumberDates.weeknumber
AND HC.CustomerID=R.CustomerID 
--where R.ESA_AccountID=1220780
--GROUP BY WeeknumberDates.DateLabel, R.EmployeeID,EmployeeName,Employee,EmployeeEmail, ESA_AccountID,CustomerName,Customer,R.CustomerID,HC.WeekNumber

END
