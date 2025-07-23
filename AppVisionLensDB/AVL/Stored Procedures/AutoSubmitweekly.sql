/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[AutoSubmitweekly]
AS
BEGIN
BEGIN TRY


BEGIN TRAN



DECLARE @PreviousWeekDate datetime
declare @StartDate date
declare @EndDate date

set @PreviousWeekDate= GETDATE()-7
set @StartDate=dateadd(day, datediff(day, -1, @PreviousWeekDate) /7*7, -1)
set @EndDate= dateadd(day, datediff(day, 5, @PreviousWeekDate-1) /7*7 + 7, 5)

CREATE TABLE #MandateHours
(
EmployeeId NVARCHAR(50),
submitterId NVARCHAR(50),
CustomerId BIGINT,
MandatoryHours DECIMAL(6,2),
TimesheetId BIGINT,
TimesheetDate DATE
)

CREATE TABLE #InvalidTimesheets
(
EmployeeId NVARCHAR(50),
submitterId NVARCHAR(50),
CustomerId BIGINT,
MandatoryHours DECIMAL(6,2),
TimesheetId BIGINT,
TimesheetDate DATE
)

CREATE TABLE #AppInfraHours
(
CustomerId BIGINT,
EmployeeId NVARCHAR(50),
[Hours] DECIMAL(6,2)
)

CREATE TABLE #TotalHours
(
CustomerId BIGINT,
EmployeeId NVARCHAR(50),
[Hours] DECIMAL(6,2)
)


SELECT TS.CustomerID,TS.SubmitterId,TS.TimesheetId,TS.TimesheetDate,TS.StatusId INTO #TMP FROM AVL.TM_PRJ_Timesheet(NOLOCK) TS 
INNER JOIN AVL.Customer(NOLOCK) C ON C.CustomerID=TS.CustomerID AND ISNULL(C.IsDaily,0)=0
WHERE TS.StatusId=1
AND TS.TimesheetDate BETWEEN @StartDate and @EndDate

--select '#tmp',* from #tmp

------------filter attribute updated tickets-------

------***APP***----------

SELECT EmployeeID,SubmitterId,CustomerID,MandatoryHours,TimesheetId,TimesheetDate INTO #MandateHoursApp FROM(
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate FROM AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A ON LM.UserID=A.SubmitterId
JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) B ON A.TimesheetId=B.TimesheetId AND B.IsDeleted=0
JOIN AVL.TK_TRN_TicketDetail(NOLOCK) C ON B.TimeTickerID=C.TimeTickerID AND B.ProjectId=C.ProjectID AND C.IsAttributeUpdated=1
UNION
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate FROM AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A ON LM.UserID=A.SubmitterId AND LM.CustomerID=A.CustomerID
JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) B ON A.TimesheetId=b.TimesheetId AND B.IsNonTicket=1
)a

------***INFRA***----------

SELECT EmployeeID,SubmitterId,CustomerID,MandatoryHours,TimesheetId,TimesheetDate INTO #MandateHoursInfra FROM(
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate FROM AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A ON LM.UserID=A.SubmitterId
JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) B ON A.TimesheetId=B.TimesheetId AND B.IsDeleted=0
JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) C ON B.TimeTickerID=C.TimeTickerID AND B.ProjectId=C.ProjectID AND C.IsAttributeUpdated=1
UNION
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate FROM AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A ON LM.UserID=A.SubmitterId AND LM.CustomerID=A.CustomerID
JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) B ON A.TimesheetId=b.TimesheetId AND B.IsNonTicket=1
)b
------***Work Items***----------

SELECT EmployeeID,SubmitterId,CustomerID,MandatoryHours,TimesheetId,TimesheetDate INTO #MandateHoursWorkItems FROM(
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate FROM AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A ON LM.UserID=A.SubmitterId
JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) B ON A.TimesheetId=B.TimesheetId AND B.IsDeleted=0 
UNION
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate FROM AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A ON LM.UserID=A.SubmitterId AND LM.CustomerID=A.CustomerID
JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) B ON A.TimesheetId=b.TimesheetId AND B.IsNonTicket=1
)b



--------non attribute updated tickets--------------

----***APP***-------
INSERT INTO #InvalidTimesheets 
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate FROM AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A ON LM.UserID=A.SubmitterId
JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) B ON A.TimesheetId=B.TimesheetId AND B.IsDeleted=0
JOIN AVL.TK_TRN_TicketDetail(NOLOCK) C ON B.TimeTickerID=C.TimeTickerID AND B.ProjectId=C.ProjectID AND ISNULL(C.IsAttributeUpdated,0)=0

----***INFRA***-----
INSERT INTO #InvalidTimesheets 
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate FROM AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A ON LM.UserID=A.SubmitterId
JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) B ON A.TimesheetId=B.TimesheetId AND B.IsDeleted=0
JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) C ON B.TimeTickerID=C.TimeTickerID AND B.ProjectId=C.ProjectID AND ISNULL(C.IsAttributeUpdated,0)=0

INSERT INTO #MandateHours
SELECT EmployeeID,SubmitterId,CustomerID,MandatoryHours,TimesheetId,TimesheetDate FROM #MandateHoursApp
UNION
SELECT EmployeeID,SubmitterId,CustomerID,MandatoryHours,TimesheetId,TimesheetDate FROM #MandateHoursInfra
UNION
SELECT EmployeeID,SubmitterId,CustomerID,MandatoryHours,TimesheetId,TimesheetDate FROM #MandateHoursWorkItems

DELETE A from #MandateHours A
JOIN #InvalidTimesheets B ON A.CustomerID=B.CustomerID AND A.EmployeeID=B.EmployeeID




--select '#MandateHours',* from #MandateHours

------sum of hours------------------
--***APP***-----
INSERT INTO #AppInfraHours 
SELECT A.CustomerID,A.EmployeeID,SUM(B.Hours) AS [Hours] FROM 
#MandateHoursApp A JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) B ON A.TimesheetId=B.TimesheetId 
GROUP BY A.CustomerId,A.EmployeeId

---SELECT '#AppInfraHours1',* FROM #AppInfraHours

---***INFRA***---
INSERT INTO #AppInfraHours
SELECT A.CustomerID,A.EmployeeID,SUM(B.Hours) AS [Hours] FROM 
#MandateHoursInfra A JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) B ON A.TimesheetId=B.TimesheetId 
GROUP BY A.CustomerId,A.EmployeeId

---***Work Item***---
INSERT INTO #AppInfraHours
SELECT A.CustomerID,A.EmployeeID,SUM(B.Hours) AS [Hours] FROM 
#MandateHoursWorkItems A JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) B ON A.TimesheetId=B.TimesheetId  
AND ISNULL(B.IsDeleted,0)=0
GROUP BY A.CustomerId,A.EmployeeId

--SELECT '#AppInfraHours2',* FROM #AppInfraHours

INSERT INTO #TotalHours
SELECT CustomerId,EmployeeId,SUM(Hours) FROM #AppInfraHours
GROUP BY CustomerId,EmployeeId


--select '#TotalHours',* from #TotalHours 

------valid tickets to update--------

SELECT A.TimesheetId,A.EmployeeID,A.TimesheetDate,B.[Hours] INTO #FinalTemp FROM #MandateHours A
JOIN #TotalHours B ON A.EmployeeID=B.EmployeeID AND A.CustomerID=B.CustomerID
WHERE B.[Hours]>=(A.MandatoryHours*5)

--select '#FinalTemp',* from #FinalTemp

--------------------------------------

--select * from avl.tm_prj_timesheet where timesheetid in(select timesheetid from #finaltemp)

UPDATE AVL.TM_PRJ_Timesheet SET StatusId=2,IsAutosubmit=1,ModifiedDateTime=GETDATE(),ModifiedBy='applens' 
WHERE TimesheetId IN(SELECT TimesheetId FROM #FinalTemp)

DROP TABLE #TMP
DROP TABLE #MandateHoursApp
DROP TABLE #MandateHoursInfra
DROP TABLE #MandateHoursWorkItems
DROP TABLE #InvalidTimesheets
DROP TABLE #AppInfraHours
DROP TABLE #TotalHours
DROP TABLE #FinalTemp
DROP TABLE #MandateHours




		

		
COMMIT TRAN
		
END TRY
BEGIN CATCH

	ROLLBACK TRAN

	DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()

	--INSERT Error

	EXEC AVL_InsertError 'AVL.AutoSubmitWeekly',@ErrorMessage,0,0
			
END CATCH
END
