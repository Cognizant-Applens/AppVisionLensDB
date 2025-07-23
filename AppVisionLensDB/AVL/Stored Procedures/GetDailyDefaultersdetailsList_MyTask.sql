/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROC [AVL].[GetDailyDefaultersdetailsList_MyTask]  
  
AS  
  
BEGIN
SET NOCOUNT ON;
  
BEGIN TRY 
  
PRINT 'BEGIN';  
  
DECLARE @date DATETIME  
  
DECLARE @prevdate DATE  
  
DECLARE @count INT  
  
DECLARE @dates DATE  
  
DECLARE @daynumber INT  
  
SET @daynumber = (SELECT DATEPART(dw,GETDATE()))  
  
IF(@daynumber = 2 OR @daynumber =3)  
  
BEGIN  
  
 SET @date = (SELECT GETDATE()-4)  
  
 SET @count=4  
  
END  
  
ELSE IF(@daynumber = 4 OR @daynumber = 5 OR @daynumber = 6 OR @daynumber = 7 OR @daynumber = 1)  
  
BEGIN  
  
 SET @date = (SELECT GETDATE()-2)  
  
 SET @count=2  
  
END  
  
SELECT CONVERT(varchar, @date, 106) AS subjectdate  
  
SET @dates=(SELECT CAST(@date AS DATE))  
  
DECLARE @nowdate DATE  
  
SET @nowdate=DATEADD(DAY, 1 - DATEPART(weekday, GETDATE()), CAST(GETDATE() AS DATE))  
  
IF(DATENAME(dw,@nowdate)='sunday')  
  
BEGIN  
  
SET @nowdate=DATEADD(DAY, -1 - DATEPART(weekday, GETDATE()), CAST(GETDATE() as date))  
  
END  
  
else if(DATENAME(dw,@nowdate)='saturday')  
  
BEGIN  
  
SET @nowdate=DATEADD(DAY, 0 - DATEPART(weekday, GETDATE()), CAST(GETDATE() as date))  
  
END  
  
SET @nowdate=@date  
  
SET @prevdate=DATEADD(DAY, -28 - DATEPART(weekday, @nowdate), CAST(@nowdate as date))      --(select @date -(30+ @count))  
  
SET @prevdate=DATEADD(DAY,-30, @nowdate)   
  
declare @lastbusinessday DATETIME  
  
SET @lastbusinessday = dbo.workday(@nowdate,-30)  
  
SET @prevdate=@lastbusinessday  
  
PRINT @prevdate   
  
PRINT @nowdate  
  
PRINT datename(dw,@nowdate)  
  
  
  
--new code  
  
DECLARE @configdays AS INT=1  
  
DECLARE @hundred AS INT=100  
  
  
  
  
  
  
DECLARE @eligiblecustomertasks AS TABLE  
  
( customerid BIGINT)  
  
  
  
DECLARE @configtable AS TABLE  
  
(  
  
configvalue  DECIMAL(5,2),  
  
mailerrequired  INT  
  
)  
  
  
INSERT INTO @configtable  
  
SELECT mdc.configvalue,mdc.mailerrequired FROM avl.map_defaultmailerconfig mdc (NOLOCK)   
  
------------------- getting configured projects  
  
DECLARE @validprojects AS TABLE  
  
(  
  
projectid BIGINT not null,  
  
customerid BIGINT not null  
  
)  
  
  
  
INSERT INTO @validprojects  
  
SELECT DISTINCT pm.projectid,pm.customerid FROM  avl.mas_projectmaster pm (NOLOCK)  
  
JOIN avl.customer c (NOLOCK) ON c.customerid=pm.customerid AND c.isdeleted=0 AND c.isdaily=1 AND c.iseffortconfigured=1  
  
JOIN avmdart_migratedprojectsinfo d (NOLOCK) ON d.esaprojectid=pm.esaprojectid AND d.operationaldate IS NOT NULL  
  
WHERE pm.ismigratedfromdart=1 AND pm.isdeleted=0 AND pm.isesaproject=1  
  
  
  
UNION  
  
SELECT DISTINCT pm.projectid,pm.customerid  FROM avl.mas_projectmaster pm (NOLOCK)  
  
JOIN avl.customer c (NOLOCK) ON c.customerid=pm.customerid AND c.isdeleted=0 AND c.isdaily=1 AND c.iseffortconfigured=1  
  
JOIN avl.prj_configurationprogress cp (NOLOCK) ON cp.projectid=pm.projectid AND cp.screenid=2 AND cp.itsmscreenid=(CASE WHEN c.iscognizant=1 THEN 11 ELSE 9 END) AND cp.completionpercentage=100 AND cp.isdeleted=0  
  
--join avl.prj_configurationprogress cp on cp.projectid=pm.projectid and cp.screenid=2 and cp.itsmscreenid=11 and cp.completionpercentage=100 and cp.isdeleted=0  
  
JOIN avl.prj_configurationprogress cp1 (NOLOCK) ON cp1.projectid=pm.projectid AND cp1.screenid=4  AND cp1.completionpercentage=100 AND cp1.isdeleted=0  
  
WHERE (pm.ismigratedfromdart=2 or pm.ismigratedfromdart is null) AND pm.isdeleted=0 AND pm.isesaproject=1  
  
  
  
PRINT 'PROJECTS';  
  
SELECT userid,lm.customerid,employeeid,employeename,employeeemail   
  
INTO #mas_loginmastertasks   
  
FROM avl.mas_loginmaster lm (NOLOCK)  
  
INNER JOIN @validprojects p ON p.projectid=lm.projectid  
  
INNER JOIN avl.customer c (NOLOCK) ON c.customerid=p.customerid AND c.isdaily=1 AND c.isdeleted=0 AND c.iseffortconfigured=1  
  
AND lm.isdeleted=0 AND lm.ticketingmoduleenabled=1 AND lm.mandatoryhours>0  
  
PRINT 'LOGINMASTER TASKS';  
  
CREATE TABLE #resulttabletasks  
  
(  
  
timesheethours DECIMAL(5,2),  
  
timesheetdate DATE,  
  
employeeid NVARCHAR(10),  
  
employeename NVARCHAR(MAX),  
  
employee NVARCHAR(MAX),  
  
employeeemail NVARCHAR(MAX),  
  
esa_accountid BIGINT,  
  
customername NVARCHAR(MAX),  
  
customer NVARCHAR(MAX),  
  
customerid BIGINT  
  
)  
  
CREATE TABLE #buildresulttabletasks  
(  
  
timesheethours DECIMAL(5,2),  
  
timesheetdate DATE,  
  
employeeud NVARCHAR(10),  
  
esa_accountid BIGINT,  
  
customername NVARCHAR(MAX),  
  
customer NVARCHAR(MAX),  
  
customerid BIGINT,  
  
statusid INT,  
  
submitterid INT  
  
)  
  
SELECT * INTO #avldates FROM avl.getdates(dbo.workday(@nowdate,-30),@nowdate) dt  
  
INSERT INTO #buildresulttabletasks  
SELECT   
  
DISTINCT  
  
ISNULL(SUM(tsd.hours),0) hours,  
  
dt.date,  
  
lm.employeeid,  
  
(CASE WHEN c.esa_accountid IS NULL THEN 0 ELSE c.esa_accountid END),  
  
c.customername,  
  
c.customername+'('+CONVERT(VARCHAR(30),(CASE WHEN c.esa_accountid IS NULL THEN c.customerid ELSE c.esa_accountid END))+')' AS customer,  
  
c.customerid,  
  
ts.statusid,  
  
ts.submitterid  
  
 FROM #avldates dt (NOLOCK)   
  
INNER JOIN avl.customer c (NOLOCK) ON  c.isdaily=1 AND c.isdeleted=0 AND c.iseffortconfigured=1  
  
INNER JOIN #mas_loginmastertasks lm ON c.customerid=lm.customerid   
  
LEFT JOIN avl.tm_prj_timesheet ts (nolock) ON dt.date=ts.timesheetdate   AND ts.submitterid=lm.userid  
  
LEFT JOIN avl.tm_trn_timesheetdetail tsd (NOLOCK) ON tsd.timesheetid=ts.timesheetid AND lm.userid=ts.submitterid  
  
  
AND ts.timesheetdate BETWEEN @prevdate AND @nowdate   
  
LEFT JOIN avmdart_migratedprojectsinfo mpi (NOLOCK)  ON c.esa_accountid=mpi.esaaccountid AND operationaldate IS NULL  
WHERE mpi.esaaccountid IS NULL  
  
GROUP BY  
  
c.esa_accountid,  
  
c.customername,  
  
dt.date,  
  
c.customerid,  
  
lm.employeeid,  
  
ts.statusid,  
  
ts.submitterid  
  
ORDER BY dt.date DESC;  
  
  
 PRINT 'Intermediate';  
  
  
INSERT INTO #resulttabletasks  
  
SELECT   
  
DISTINCT  
  
b.timesheethours,  
  
b.timesheetdate,  
  
lm.employeeid,  
  
lm.employeename,  
  
lm.employeename+'('+CONVERT(VARCHAR(30),lm.employeeid)+')' AS employee,  
  
lm.employeeemail,  
  
(CASE WHEN b.esa_accountid IS NULL THEN 0 ELSE b.esa_accountid END),  
  
b.customername,  
  
b.customer,  
  
b.customerid  
  
FROM #buildresulttabletasks b (NOLOCK)  INNER JOIN  #mas_loginmastertasks lm  
  
ON  lm.employeeid=b.employeeud  
  
WHERE (b.submitterid IS NULL OR b.statusid NOT IN (2,3))  
  
  
PRINT 'RESULT TABLE TASKS';  
  
  
  
INSERT INTO @eligiblecustomertasks (customerid)  
  
SELECT  defaultertable.customerid  FROM   
  
(SELECT customerid,COUNT(DISTINCT employeeid) AS defaulters FROM #resulttabletasks (NOLOCK)  GROUP BY customerid) AS defaultertable  
  
INNER JOIN   
  
(SELECT lm.customerid,COUNT(DISTINCT lm.employeeid) AS activeuser FROM #mas_loginmastertasks lm (NOLOCK) INNER JOIN  #resulttabletasks r ON r.customerid=lm.customerid GROUP BY lm.customerid)  
  
AS activeusertable  
  
ON defaultertable.customerid=activeusertable.customerid  
  
  
PRINT 'CUSTOMER TASKS';  
  
  
SELECT r.timesheethours AS hours,r.timesheetdate AS tsdate,r.employeeid,r.employeename,r.employee,r.employeeemail,r.customerid AS customerid,r.customername,r.customer   
  
 ,CASE WHEN DATEPART(dw, r.timesheetdate )= 6   
  
  THEN DATEADD(dd,3,r.timesheetdate) ELSE DATEADD(dd,1,r.timesheetdate) END AS 'duedate',esa_accountid as'esaid' INTO #timesheettempdaily FROM #resulttabletasks r (NOLOCK)  INNER JOIN @eligiblecustomertasks e ON r.customerid=e.customerid    
  
ORDER BY r.timesheetdate DESC  
  
  
PRINT '#TEMP TASKS';  
  
  
SELECT min(duedate) AS 'duedate',employeeid,customerid INTO #maxduedate FROM #timesheettempdaily (NOLOCK)  GROUP BY employeeid,customerid;  
  
  
  
  
  
PRINT 'Defaulter Concept Completed';  
  
  
  
DECLARE @taskname VARCHAR(500),@taskurl VARCHAR(MAX),@taskapplication VARCHAR(500),@taskstatus VARCHAR(100),@tasktype as VARCHAR(100) ;  
DECLARE @taskid INT=4;  
SELECT @taskname=taskname FROM dbo.taskmaster (NOLOCK)  WHERE taskid=@taskid;  
SELECT @taskurl=taskurl FROM dbo.taskurl (NOLOCK)  WHERE taskid=@taskid AND IsDeleted=0;  
SELECT @taskapplication=applicationname FROM dbo.taskapplication (NOLOCK)  WHERE taskid=@taskid AND IsDeleted=0;  
SELECT @taskstatus=status FROM dbo.taskstatus (NOLOCK)  WHERE taskstatusid=2 AND IsDeleted=0;  
SELECT @tasktype=tasktype FROM dbo.tasktype (NOLOCK)  WHERE tasktypeid=2 AND IsDeleted=0;  
  
PRINT 'Variables are set';  
  
SELECT t.employeeid AS'userid',@taskid AS 'taskid',@taskname AS 'taskname',@taskurl AS 'taskurl',  
  
'You have not submitted the timesheet for the period of '+CONVERT(VARCHAR(1000),COUNT(DISTINCT(t.tsdate)))+' day(s) for the Account : '+CASE WHEN t.esaid=0 THEN '' +customername ELSE CONVERT(VARCHAR(MAX),t.esaid) +' -  ' +customername END  
  
AS 'taskdetails',@taskapplication AS 'applicatioN',@taskstatus AS 'status',  
  
GETDATE() AS 'refreshedtime','system' as 'createdby', getdate() as 'createdtime',null as 'modifiedby',null as 'modifiedtime',  
  
@tasktype AS 'tasktype',NULL AS 'expirydate','N' AS 'read',m.duedate AS 'duedate',0 AS 'expiryafterread',  
  
t.customerid AS 'accountid'  
  
 FROM #timesheettempdaily t (NOLOCK) JOIN  #maxduedate m (NOLOCK) ON t.customerid=m.customerid AND t.employeeid=m.employeeid  
  
  
 GROUP BY t.employeeid,t.customerid,customername,m.duedate,t.esaid;  
  
  PRINT 'END';  
  
  
  
  
    
  
END TRY  
  
BEGIN CATCH  
  
  
  
 DECLARE @ErrorMessage VARCHAR(MAX);  
  
  
  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  
  
 --INSERT Error  
  
  
  
 EXEC AVL_InsertError 'AVL.GetDailyDefaultersdetailsList_MyTask',@ErrorMessage,0,0  
  
     
  
END CATCH 
SET NOCOUNT OFF;
END
