/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[GetWeeklyDefaultersdetailsList_MyTask]  
AS  
BEGIN 
SET NOCOUNT ON; 
BEGIN TRY  
    
   
DECLARE @date DATETIME  
DECLARE @prevdate date  
DECLARE @count INT  
DECLARE @week1startdate DATETIME  
DECLARE @week1enddate DATETIME  
  
DECLARE @week2startdate DATETIME  
DECLARE @week2enddate DATETIME  
  
DECLARE @week3startdate DATETIME  
DECLARE @week3enddate DATETIME  
  
DECLARE @week4startdate DATETIME  
DECLARE @week4enddate DATETIME  
  
DECLARE @daynumber INT  
DECLARE @week INT  
  
SET @daynumber =(SELECT DATEPART(dw,GETDATE()))--get the weekday number  
SET @week=1  
DECLARE @at DATETIME  
SET @at=(SELECT GETDATE())  
SET @daynumber=4  
IF(@daynumber = 4)  
BEGIN  
DECLARE @date1 DATETIME  
DECLARE @date2 DATETIME  
DECLARE @date3 DATETIME  
DECLARE @date4 DATETIME  
DECLARE @date5 DATETIME  
DECLARE @date6 DATETIME  
DECLARE @date7 DATETIME  
DECLARE @date8 DATETIME  
DECLARE @date9 DATETIME  
DECLARE @date10 DATETIME  
DECLARE @datedup1 DATETIME  
SET @date9=DATEADD(DAY, 2 - DATEPART(WEEKDAY, @at), CAST(@at AS DATE))    
SET @date10=DATEADD(DAY, 6 - DATEPART(WEEKDAY, @at), CAST(@at AS DATE))  
SET @datedup1=DATEADD(DAY,DATEDIFF(DAY,2,@date9),0)  
SET @week4startdate=DATEADD(DAY, 2 - DATEPART(WEEKDAY,@datedup1), CAST(@datedup1 AS DATE))    
SET @week4enddate=DATEADD(DAY, 6 - DATEPART(WEEKDAY, @datedup1), CAST(@datedup1 AS DATE))   
SET @datedup1=DATEADD(DAY,DATEDIFF(DAY,2,@week4startdate),0)  
SET @week3startdate=DATEADD(DAY, 2 - DATEPART(WEEKDAY,@datedup1), CAST(@datedup1 AS DATE))    
SET @week3enddate=DATEADD(DAY, 6 - DATEPART(WEEKDAY, @datedup1), CAST(@datedup1 AS DATE))   
SET @datedup1=DATEADD(DAY,DATEDIFF(DAY,2,@week3startdate),0)  
SET @week2startdate=DATEADD(DAY, 2 - DATEPART(WEEKDAY,@datedup1), CAST(@datedup1 AS DATE))    
SET @week2enddate=DATEADD(DAY, 6 - DATEPART(WEEKDAY, @datedup1), CAST(@datedup1 AS DATE))   
SET @datedup1=DATEADD(DAY,DATEDIFF(DAY,2,@week2startdate),0)  
SET @week1startdate=DATEADD(DAY, 2 - DATEPART(WEEKDAY,@datedup1), CAST(@datedup1 AS DATE))    
SET @week1enddate=DATEADD(DAY, 6 - DATEPART(WEEKDAY, @datedup1), CAST(@datedup1 AS DATE))   
END  
--select @week4enddate  
--select @week1startdate  
SELECT (CONVERT(VARCHAR, @week4startdate, 106))  AS date1,(CONVERT(VARCHAR, @week4enddate, 106)) AS date2  
  
--new code  
DECLARE @configdays AS INT=1  
DECLARE @hundred AS INT=100  
  
  
DECLARE @eligiblecustomertasks AS table  
( customerid BIGINT,configcal BIGINT)  
  
  
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
JOIN avl.customer c (NOLOCK) ON c.customerid=pm.customerid AND c.isdeleted=0 AND c.isdaily<>1 AND c.iseffortconfigured=1  
JOIN avmdart_migratedprojectsinfo d (NOLOCK) ON d.esaprojectid=pm.esaprojectid AND d.operationaldate IS NOT NULL   
WHERE pm.ismigratedfromdart=1 AND pm.isdeleted=0 AND pm.isesaproject=1  
  
UNION  
  
SELECT DISTINCT pm.projectid,pm.customerid  FROM avl.mas_projectmaster pm (NOLOCK)  
JOIN avl.customer c (NOLOCK)  ON c.customerid=pm.customerid AND c.isdeleted=0 AND c.isdaily<>1  AND c.iseffortconfigured=1  
JOIN avl.prj_configurationprogress cp (NOLOCK) ON cp.projectid=pm.projectid AND cp.screenid=2 AND cp.itsmscreenid=(CASE WHEN c.iscognizant=1 THEN 11 else 9 end) AND cp.completionpercentage=100 AND cp.isdeleted=0  
JOIN avl.prj_configurationprogress cp1 (NOLOCK) ON cp1.projectid=pm.projectid AND cp1.screenid=4  AND cp1.completionpercentage=100 AND cp1.isdeleted=0  
WHERE (pm.ismigratedfromdart=2 or pm.ismigratedfromdart IS NULL) AND pm.isdeleted=0 AND pm.isesaproject=1  
  
  
SELECT userid,lm.customerid,employeeid,employeename,employeeemail   
INTO #mas_loginmastertasks   
FROM avl.mas_loginmaster lm (NOLOCK) 
INNER JOIN @validprojects p ON p.projectid=lm.projectid   
INNER JOIN avl.customer c (NOLOCK) ON c.customerid=p.customerid AND c.isdaily<>1  AND c.isdeleted=0 AND c.iseffortconfigured=1  
AND lm.isdeleted=0 AND lm.ticketingmoduleenabled=1 AND lm.mandatoryhours>0  
  
  
CREATE TABLE #resulttabletasks  
(  
timesheethours DECIMAL(5,2),  
timesheetdate DATE,  
employeeid NVARCHAR(10),  
employeename NVARCHAR(max),  
employee NVARCHAR(max),  
employeeemail NVARCHAR(max),  
esa_accountid BIGINT,  
customername NVARCHAR(max),  
customer NVARCHAR(max),  
customerid BIGINT  
)  
CREATE TABLE #buildresulttabletasks  
(  
timesheethours DECIMAL(5,2),  
timesheetdate DATE,  
employeeid NVARCHAR(10),  
esa_accountid BIGINT,  
customername NVARCHAR(max),  
customer NVARCHAR(max),  
customerid BIGINT,  
statusid INT,  
submitterid INT  
)  
  
  
DECLARE @hourscontainertasks AS TABLE  
(  
employeeid  NVARCHAR(10),  
weeknumber INT,  
customerid BIGINT,  
timesheethours DECIMAL(5,2)  
)  
  
SELECT * INTO #AVLDATES FROM avl.getdates(dbo.workday(@week4enddate,-30),@week4enddate);  
  
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
 FROM #AVLDATES dt  
INNER JOIN avl.customer c (NOLOCK)ON  c.isdaily<>1 AND c.isdeleted=0 AND c.iseffortconfigured=1  
INNER JOIN #mas_loginmastertasks lm (NOLOCK) ON c.customerid=lm.customerid   
LEFT JOIN avl.tm_prj_timesheet ts (NOLOCK) ON dt.date=ts.timesheetdate   AND ts.submitterid=lm.userid  
LEFT JOIN avl.tm_trn_timesheetdetail tsd (NOLOCK)ON tsd.timesheetid=ts.timesheetid --and lm.userid=ts.submitterid  
AND ts.timesheetdate BETWEEN @week1startdate  AND @week4enddate  
--WHERE NOT EXISTS  
  
--(SELECT c.esa_accountid FROM avmdart_migratedprojectsinfo (NOLOCK) mpi  JOIN avl.customer c ON c.esa_accountid=mpi.esaaccountid  
  
--WHERE operationaldate IS NULL)  
LEFT JOIN avmdart_migratedprojectsinfo mpi (NOLOCK) ON c.esa_accountid=mpi.esaaccountid AND operationaldate IS NULL  
WHERE mpi.esaaccountid IS NULL  
GROUP BY  
c.esa_accountid,  
c.customername,  
dt.date,  
c.customerid,  
lm.employeeid,  
ts.statusid,  
ts.submitterid  
ORDER BY dt.date DESC  
  
  
INSERT INTO @hourscontainertasks  
(employeeid, weeknumber,customerid,timesheethours)  
SELECT DISTINCT employeeid,datepart(wk,timesheetdate) weeknumber,customerid,sum(timesheethours)  
FROM #buildresulttabletasks   
GROUP BY employeeid,datepart(wk,timesheetdate) ,customerid  
  
--eliminate the valid users from the above table @buildresulttable  
  
  
DELETE FROM brt  
FROM #buildresulttabletasks brt INNER JOIN (  
SELECT employeeid,timesheetdate,customerid FROM #buildresulttabletasks WHERE statusid IN (2,3) AND submitterid IS NOT NULL  
) AS validusers  
ON brt.customerid=validusers.customerid  
AND brt.timesheetdate=validusers.timesheetdate  
AND brt.employeeid=validusers.employeeid  
  
  
  
  
  
DELETE FROM brt  
FROM #buildresulttabletasks brt INNER JOIN (  
SELECT employeeid,timesheetdate,customerid FROM #buildresulttabletasks WHERE timesheetdate<@week1startdate  
) AS validusers  
ON brt.customerid=validusers.customerid  
AND brt.timesheetdate=validusers.timesheetdate  
AND brt.employeeid=validusers.employeeid  
  
  
  
  
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
--nullif(b.esa_accountid,b.customerid),  
b.customername,  
b.customer,  
b.customerid  
FROM #buildresulttabletasks b (NOLOCK) INNER JOIN  #mas_loginmastertasks lm (NOLOCK) 
ON  lm.employeeid=b.employeeid  
WHERE (b.submitterid IS NULL OR b.statusid NOT IN (2,3))  
  
  
  
INSERT INTO @eligiblecustomertasks (customerid,configcal)  
SELECT  defaultertable.customerid,((defaultertable.defaulters)*@hundred)/(activeusertable.activeuser*@configdays)  FROM   
(SELECT customerid,COUNT(DISTINCT employeeid) AS defaulters FROM #resulttabletasks (NOLOCK) GROUP BY customerid) AS defaultertable  
INNER JOIN   
(SELECT lm.customerid,COUNT(DISTINCT lm.employeeid) AS activeuser FROM #mas_loginmastertasks lm (NOLOCK) INNER JOIN #resulttabletasks r ON r.customerid=lm.customerid GROUP BY lm.customerid)  
AS activeusertable  
ON defaultertable.customerid=activeusertable.customerid  
  
  
  
SELECT  
DISTINCT  
 hc.timesheethours AS hours,  
weeknumberdates.datelabel AS tsdate,   
r.employeeid,  
employeename,  
employee,  
employeeemail,   
r.customerid AS customerid,  
customername,  
customer,  
esa_accountid AS 'ESAID',  
hc.weeknumber,  
DATEADD(dd,7,DATEADD(WEEK,(hc.weeknumber-1), DATEADD(wk, DATEDIFF(wk,-1,DATEADD(yy, DATEDIFF(yy,0,CAST(yearend  AS VARCHAR(4))), 0)), 0)) ) AS 'duedate'  
 INTO #temptableweeklyts  
FROM #resulttabletasks r (NOLOCK) INNER JOIN @eligiblecustomertasks e ON r.customerid=e.customerid  
INNER JOIN (SELECT  DISTINCT  
CONVERT(VARCHAR(20), DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(VARCHAR(5),YEAR(min(date)))) + (DATEPART(wk,date) -1), 6),106)  
+' - ' +   
CONVERT(varchar(20), DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(VARCHAR(5),YEAR(MAX(date)))) + (DATEPART(wk,date) -1), 5),106) AS datelabel,  
DATEPART(wk,date) weeknumber,  
YEAR(MAX(date)) AS 'yearend'  
FROM avl.getdates(@week1startdate,@week4enddate)GROUP BY date) weeknumberdates   
ON weeknumberdates.weeknumber=DATEPART(week,r.timesheetdate)   
INNER JOIN @hourscontainertasks hc ON hc.employeeid=r.employeeid  
AND hc.weeknumber=weeknumberdates.weeknumber  
AND hc.customerid=r.customerid   
  
  
  
SELECT MIN(duedate) AS 'duedate',employeeid,customerid INTO #maxduedate FROM #temptableweeklyts (NOLOCK) GROUP BY employeeid,customerid;  
  
DECLARE @taskname VARCHAR(500),@taskurl VARCHAR(max),@taskapplication VARCHAR(500),@taskstatus VARCHAR(100),@tasktype AS VARCHAR(100) ;  
DECLARE @taskid INT=13;  
SELECT @taskname=taskname FROM dbo.taskmaster (NOLOCK) WHERE taskid=@taskid;  
SELECT @taskurl=taskurl FROM dbo.taskurl (NOLOCK) WHERE taskid=@taskid AND IsDeleted=0;  
SELECT @taskapplication=applicationname FROM dbo.taskapplication (NOLOCK) WHERE taskid=@taskid AND IsDeleted=0;  
SELECT @taskstatus=status FROM dbo.taskstatus (NOLOCK) WHERE taskstatusid=2 AND IsDeleted=0;  
SELECT @tasktype=tasktype FROM dbo.tasktype (NOLOCK) WHERE tasktypeid=2 AND IsDeleted=0;  
  
  
SELECT t.employeeid AS'userid',@taskid AS 'taskid',@taskname AS 'taskname',@taskurl AS 'taskurl',  
'You have not submitted the timesheet for the period of '+CONVERT(VARCHAR(1000),COUNT(DISTINCT(t.tsdate)))+' week(s) for the Account : '+CASE WHEN t.ESAID=0 THEN '' +customername ELSE CONVERT(VARCHAR(MAX),t.ESAID) +' -  ' +customername END  
AS 'taskdetails',@taskapplication AS 'applicatioN',@taskstatus AS 'status',  
GETDATE() AS 'refreshedtime','system' AS 'createdby', GETDATE() AS 'createdtime',NULL AS 'modifiedby',NULL AS 'modifiedtime',  
@tasktype AS 'tasktype',NULL AS 'expirydate',  
m.duedate AS 'duedate'  
,'N' AS 'read',0 AS 'expiryafterread',  
t.customerid AS 'accountid'  
FROM #temptableweeklyts t (NOLOCK) JOIN #maxduedate m (NOLOCK) ON t.employeeid=m.employeeid AND t.customerid=m.customerid  
GROUP BY t.employeeid,t.customerid,customername,m.duedate,t.ESAID;  
  
    
END TRY  
BEGIN CATCH  
  
 DECLARE @ErrorMessage VARCHAR(MAX);  
  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  
 --INSERT Error  
  
 EXEC AVL_InsertError 'AVL.GetWeeklyDefaultersdetailsList_MyTask',@ErrorMessage,0,0  
     
END CATCH 
SET NOCOUNT OFF;
END
