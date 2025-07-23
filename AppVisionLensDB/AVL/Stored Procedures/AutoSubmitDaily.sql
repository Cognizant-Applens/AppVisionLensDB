/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[AutoSubmitDaily]
@DateToUpdate date=null
AS
BEGIN
BEGIN TRY


BEGIN TRAN

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
TimesheetDate DATE,
[Hours] DECIMAL(6,2)
)

CREATE TABLE #TotalHours
(
CustomerId BIGINT,
EmployeeId NVARCHAR(50),
TimesheetDate DATE,
[Hours] DECIMAL(6,2)
)



select TS.CustomerID,TS.SubmitterId,TS.TimesheetId,TS.TimesheetDate,TS.StatusId INTO #TMP FROM AVL.TM_PRJ_Timesheet(NOLOCK) TS
INNER JOIN AVL.Customer(NOLOCK) C on C.CustomerID=TS.CustomerID and C.IsDaily=1
WHERE TS.StatusId=1
AND TS.TimesheetDate=CONVERT(date,@DateToUpdate)

--select '#tmp',* from #tmp

------------filter attribute updated tickets-------

------***APP***----------
SELECT EmployeeID,SubmitterId,CustomerID,MandatoryHours,TimesheetId,TimesheetDate INTO #MandateHoursApp FROM(
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate from AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A ON LM.UserID=A.SubmitterId AND LM.CustomerID=A.CustomerID
JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) B ON A.TimesheetId=B.TimesheetId
JOIN AVL.TK_TRN_TicketDetail(NOLOCK) C ON B.TimeTickerID=C.TimeTickerID AND B.ProjectId=C.ProjectID AND C.IsAttributeUpdated=1
UNION
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate from AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A ON LM.UserID=A.SubmitterId AND LM.CustomerID=A.CustomerID
JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) B ON A.TimesheetId=B.TimesheetId AND B.IsNonTicket=1)a


------***INFRA***----------
SELECT EmployeeID,SubmitterId,CustomerID,MandatoryHours,TimesheetId,TimesheetDate INTO #MandateHoursInfra FROM(
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate FROM [AVL].[MAS_LoginMaster] LM 
JOIN #TMP A ON LM.UserID=A.SubmitterId AND LM.CustomerID=A.CustomerID
JOIN [AVL].[TM_TRN_InfraTimesheetDetail](NOLOCK) B on A.TimesheetId=B.TimesheetId 
JOIN [AVL].[TK_TRN_InfraTicketDetail](NOLOCK) C ON B.TimeTickerID=C.TimeTickerID AND B.ProjectId=C.ProjectID AND C.IsAttributeUpdated=1
UNION
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate from AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A on LM.UserID=A.SubmitterId AND LM.CustomerID=A.CustomerID
JOIN [AVL].[TM_TRN_InfraTimesheetDetail](NOLOCK) B on A.TimesheetId=B.TimesheetId and B.IsNonTicket=1)b

--Work Items
SELECT EmployeeID,SubmitterId,CustomerID,MandatoryHours,TimesheetId,TimesheetDate INTO #MandateHoursWorkItems FROM(
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate FROM [AVL].[MAS_LoginMaster](NOLOCK) LM 
JOIN #TMP A ON LM.UserID=A.SubmitterId AND LM.CustomerID=A.CustomerID
JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) B on A.TimesheetId=B.TimesheetId AND ISNULL(B.IsDeleted,0)=0
UNION
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate from AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A on LM.UserID=A.SubmitterId AND LM.CustomerID=A.CustomerID
JOIN [ADM].TM_TRN_WorkItemTimesheetDetail(NOLOCK) B on A.TimesheetId=B.TimesheetId and B.IsNonTicket=1 AND ISNULL(B.IsDeleted,0)=0)b

--------non attribute updated tickets--------------

----***APP***-------
INSERT INTO #InvalidTimesheets 
select LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate FROM AVL.MAS_LoginMaster(NOLOCK) LM
JOIN #TMP A ON LM.UserID=A.SubmitterId AND LM.CustomerID=A.CustomerID
JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) B ON A.TimesheetId=B.TimesheetId 
JOIN AVL.TK_TRN_TicketDetail(NOLOCK) C ON B.TimeTickerID=C.TimeTickerID AND B.ProjectId=C.ProjectID AND ISNULL(C.IsAttributeUpdated,0)=0

----***INFRA***-----
INSERT INTO #InvalidTimesheets
SELECT LM.EmployeeID,A.SubmitterId,A.CustomerID,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate FROM [AVL].[MAS_LoginMaster](NOLOCK) LM 
JOIN #TMP A ON LM.UserID=A.SubmitterId AND LM.CustomerID=A.CustomerID
JOIN [AVL].[TM_TRN_InfraTimesheetDetail](nolock) B ON A.timesheetid=B.timesheetid
JOIN [AVL].[TK_TRN_InfraTicketDetail](nolock) C ON B.TimeTickerID=C.TimeTickerID and B.ProjectId=C.ProjectID AND isnull(C.IsAttributeUpdated,0)=0

INSERT INTO #MandateHours
SELECT EmployeeID,SubmitterId,CustomerID,MandatoryHours,TimesheetId,TimesheetDate FROM #MandateHoursApp
UNION
SELECT EmployeeID,SubmitterId,CustomerID,MandatoryHours,TimesheetId,TimesheetDate FROM #MandateHoursInfra
UNION
SELECT EmployeeID,SubmitterId,CustomerID,MandatoryHours,TimesheetId,TimesheetDate FROM #MandateHoursWorkItems

DELETE A FROM #MandateHours A
JOIN #InvalidTimesheets b on A.customerid=B.customerid and A.employeeid=B.employeeid




--select '#mandatehours',* from #mandatehours

------sum of hours------------------

--***APP***-----
INSERT INTO #AppInfraHours
SELECT A.CustomerId,A.EmployeeId,A.TimesheetDate,SUM(B.hours) AS [hours] from 
#MandateHours A JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) B on A.timesheetid=B.timesheetid
GROUP BY A.CustomerId,A.EmployeeId,A.TimesheetDate

----***INFRA***---
INSERT INTO #AppInfraHours
SELECT A.CustomerId,A.EmployeeId,A.TimesheetDate,SUM(B.hours) AS [hours] from 
#MandateHours A JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) B on A.TimesheetId=B.TimesheetId
GROUP BY A.CustomerId,A.EmployeeId,A.TimesheetDate

--Work Items
INSERT INTO #AppInfraHours
SELECT A.CustomerId,A.EmployeeId,A.TimesheetDate,SUM(B.hours) AS [hours] from 
#MandateHours A JOIN [ADM].TM_TRN_WorkItemTimesheetDetail(NOLOCK) B on A.timesheetid=B.timesheetid
GROUP BY A.CustomerId,A.EmployeeId,A.TimesheetDate

INSERT INTO #TotalHours
SELECT CustomerId,EmployeeId,TimesheetDate,SUM(Hours) FROM #AppInfraHours
GROUP BY CustomerId,EmployeeId,TimesheetDate


--select '#totalhours',* from #totalhours 

------valid tickets to update--------

SELECT A.TimesheetId,A.EmployeeId,A.TimesheetDate,B.[hours] INTO #finaltemp FROM #MandateHours A
JOIN #TotalHours B ON A.EmployeeId=B.EmployeeId and A.CustomerId=B.CustomerId
AND A.TimesheetDate=B.TimesheetDate
WHERE B.[hours]>=A.MandatoryHours

--select '#finaltemp',* from #finaltemp

--select timesheetid,submitterid,customerid,timesheetdate,statusid from avl.tm_prj_timesheet(nolock) where timesheetid in(select timesheetid from #finaltemp)

UPDATE AVL.TM_PRJ_Timesheet SET StatusId=2,IsAutosubmit=1,ModifiedDateTime=GETDATE(),ModifiedBy='Applens'
WHERE TimesheetId IN(SELECT TimesheetId FROM #finaltemp)

DROP TABLE #MandateHours
DROP TABLE #InvalidTimesheets
DROP TABLE #TotalHours
DROP TABLE #AppInfraHours
DROP TABLE #finaltemp



		

		
COMMIT TRAN
		
END TRY
BEGIN CATCH

	ROLLBACK TRAN

	DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()

	--INSERT Error

	EXEC AVL_InsertError 'AVL.AutoSubmitDaily',@ErrorMessage,0,0
			
END CATCH
END
