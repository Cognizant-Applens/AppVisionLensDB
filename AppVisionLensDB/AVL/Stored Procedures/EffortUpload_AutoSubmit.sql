/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


-- ============================================================================    
-- Author:      Dhivya         
-- Create date:      jan 7 2019    
-- Description:   submits the timesheet    
-- AppVisionLens     
-- EXEC [AVL].[EffortUpload_AutoSubmit] 7097    
    
-- ============================================================================     
CREATE PROCEDURE [AVL].[EffortUpload_AutoSubmit]    
@CustomerID bigint=null    
    
as      
begin      
begin try      
        
 begin tran    
  
 Declare @StartDateTime datetime = GETDATE()  
 DECLARE @JobName VARCHAR(50) = 'EffortUpload AutoSubmit'  
 DECLARE @JobID INT = (select JobID FROM MAS.JobMaster WHERE JobName =@JobName )  
 DECLARE @Success VARCHAR(10) ='Success'  
 DECLARE @Failed VARCHAR(10) ='Failed'  
 DECLARE @Rows VARCHAR(10)    
  
 Select DISTINCT PM.CustomerID       
 into #Customer      
 from AVL.EffortUploadConfiguration EC      
 join AVL.MAS_ProjectMaster PM on PM.ProjectID = EC.ProjectID    
  
  
        
 SELECT * INTO #LoginMaster FROM AVL.MAS_LoginMaster(NOLOCK) where CustomerID in (select CustomerID from #Customer)      
 AND IsDeleted=0      
  CREATE TABLE  #effortuploadautosubmit       
  (      
  ID BIGINT NOT NULL IDENTITY(1,1),   
  [CustomerID] BIGINT NULL,      
  [ProjectID] BIGINT NULL,      
  [EmployeeID] NVARCHAR(50) NULL,      
  [SubmitterID] BIGINT NULL,      
  [TimeSheetDate] DATE NULL,       
  [IsProcessed] BIT NULL,       
  [IsDeleted] BIT NULL,      
  [CreatedBy] NVARCHAR(MAX) NULL,      
  [CreatedDate] DATETIME NULL,      
  [ModifiedBy]   NVARCHAR(MAX) NULL,      
  [ModifiedDate] DATETIME NULL,      
 )      
        
  CREATE TABLE  #effortuploadautosubmitTemp       
  (      
  ID BIGINT NOT NULL IDENTITY(1,1),      
  [CustomerID] BIGINT NULL,      
  [ProjectID] BIGINT NULL,      
  [EmployeeID] NVARCHAR(50) NULL,      
  [SubmitterID] BIGINT NULL,      
  [TimeSheetDate] DATE NULL,       
  [IsProcessed] BIT NULL,       
  [IsDeleted] BIT NULL,      
  [CreatedBy] NVARCHAR(MAX) NULL,      
  [CreatedDate] DATETIME NULL,      
  [ModifiedBy]   NVARCHAR(MAX) NULL,      
  [ModifiedDate] DATETIME NULL,      
 )       
 --Retrieving the to process records      
  INSERT into #effortuploadautosubmit       
  select DISTINCT CustomerID,ProjectID,NULL,SubmitterID,TimeSheetDate,IsProcessed,IsDeleted,      
  CreatedBy,CreatedDate,ModifiedBy,ModifiedDate from  [avl].[effortuploadautosubmit]       
  where isnull(isprocessed,0)=0 and CustomerID in (select CustomerID from #Customer)      
     
  SET @Rows = (select  count(CustomerID) from  [avl].[effortuploadautosubmit]       
  where isnull(isprocessed,0)=0 and CustomerID in (select CustomerID from #Customer))  
  
  
 --Updating the employee id      
  UPDATE EUA SET EUA.EmployeeID=LM.EmployeeID FROM #effortuploadautosubmit EUA      
  INNER JOIN  #LoginMaster LM ON EUA.CustomerID=LM.CustomerID      
  AND EUA.ProjectID=LM.ProjectID AND EUA.SubmitterID=LM.UserID      
        
  --Check for projects other than submitted project      
  SELECT CustomerID, ProjectID,EmployeeID,USERID        
  INTO #ToInsertToTemp FROM #LoginMaster       
  WHERE CustomerID in (select CustomerID from #Customer)       
  AND EmployeeID IN(      
  SELECT EmployeeID  FROM #effortuploadautosubmit) AND USERID NOT IN(      
  SELECT SUBMITTERID FROM #effortuploadautosubmit)      
      
  --Other project for the same customer      
  INSERT INTO #effortuploadautosubmitTemp      
  SELECT DISTINCT tt.CustomerID,TT.ProjectID,TT.EmployeeID,TT.USERID,ES.TimeSheetDate,ES.IsProcessed,ES.IsDeleted,      
  ES.CreatedBy,ES.CreatedDate,ES.ModifiedBy,ES.ModifiedDate FROM #ToInsertToTemp TT      
  INNER JOIN #effortuploadautosubmit ES ON TT.EmployeeID=ES.EmployeeID      
    
  INSERT INTO #effortuploadautosubmit      
  SELECT DISTINCT tt.CustomerID,TT.ProjectID,TT.EmployeeID,TT.SubmitterID,tt.TimeSheetDate,tt.IsProcessed,tt.IsDeleted,      
  tt.CreatedBy,tt.CreatedDate,tt.ModifiedBy,tt.ModifiedDate   
  FROM #effortuploadautosubmitTemp tt    
    
  --select * into #effortuploadautosubmit from  [avl].[effortuploadautosubmit]       
  --where isnull(isprocessed,0)=0 and CustomerID=@CustomerID      
      
  SELECT DISTINCT PRO.CustomerID,PRO.SubmitterID,tab.TimeSheetDate INTO #CustomerUserDates FROM #effortuploadautosubmit PRO     
CROSS APPLY    
(SELECT CustomerID,TimeSheetDate FROM #effortuploadautosubmit AS EMP WHERE PRO.CustomerID=EMP.CustomerID)Tab   
  
  SELECT distinct ts.customerid,ts.submitterid,ts.timesheetid,ts.timesheetdate,ts.statusid      
  into #tmpdaily       
   from #effortuploadautosubmit eua       
  inner join avl.tm_prj_timesheet(nolock) ts on eua.customerid=ts.customerid and eua.projectid=ts.projectid and eua.submitterid=ts.submitterid      
  INNER JOIN #CustomerUserDates cud ON cud.CustomerID=ts.CustomerID AND cud.SubmitterID=ts.SubmitterId AND cud.TimeSheetDate=ts.TimesheetDate      
  inner join avl.customer(nolock) c on eua.customerid=c.customerid and c.isdaily=1      
  where ts.statusid not in(2,3)      
  ------------filter attribute updated tickets-------      
  CREATE TABLE #mandatehoursdaily      
  (      
  EmployeeID NVARCHAR(100),      
  SubmitterId BIGINT NULL,      
  CustomerId BIGINT NULL,      
  MandatoryHours DECIMAL(6,2),      
  TimeSheetID BIGINT NULL,      
  TimeSheetDate DATE NULL,      
  IsValid INT NULL      
  )      
      
      
      
  INSERT INTO #mandatehoursdaily      
  select employeeid,a.submitterid,a.customerid,Isnull(lm.mandatoryhours,0),a.timesheetid,a.timesheetdate,NULL from avl.mas_loginmaster(nolock) lm      
  join #tmpdaily a on lm.userid=a.submitterid and lm.customerid=a.customerid      
  join avl.tm_trn_timesheetdetail(nolock) b on a.timesheetid=b.timesheetid       
  join avl.tk_trn_ticketdetail(nolock) c on b.timetickerid=c.timetickerid and b.projectid=c.projectid and c.isattributeupdated=1      
  union      
  select employeeid,a.submitterid,a.customerid,lm.mandatoryhours,a.timesheetid,a.timesheetdate,NULL from avl.mas_loginmaster(nolock) lm      
  join #tmpdaily a on lm.userid=a.submitterid and lm.customerid=a.customerid      
  join avl.tm_trn_timesheetdetail(nolock) b on a.timesheetid=b.timesheetid and b.isnonticket=1     
    union      
  select employeeid,a.submitterid,a.customerid,lm.mandatoryhours,a.timesheetid,a.timesheetdate,NULL from avl.mas_loginmaster(nolock) lm      
  join #tmpdaily a on lm.userid=a.submitterid and lm.customerid=a.customerid      
 left join avl.tm_trn_timesheetdetail(nolock) b on a.timesheetid=b.timesheetid       
  LEFT JOIN avl.tk_trn_ticketdetail(nolock) c on b.timetickerid=c.timetickerid and b.projectid=c.projectid and c.isattributeupdated=1      
    where b.TimesheetId IS NULL  
    
  -- New block  
  UNION  
  SELECT EmployeeId,A.SubmitterId,A.CustomerId,ISNULL(LM.MandatoryHours,0),  
  A.TimeSheetId,A.TimeSheetDate,NULL   
  FROM AVL.MAS_LoginMaster(NOLOCK) LM      
  JOIN #tmpdaily(NOLOCK) A   
 ON LM.UserId=A.SubmitterId AND LM.CustomerId = A.CustomerId      
  JOIN AVL.TM_TRN_InfraTimeSheetDetail(NOLOCK) B   
 ON A.TimeSheetId = B.TimeSheetId       
  JOIN AVL.TK_TRN_Infraticketdetail(NOLOCK) C   
 ON B.TimeTickerId = C.TimeTickerId AND B.ProjectId = C.ProjectId AND c.IsAttributeUpdated = 1    
   
  UNION    
    
  SELECT EmployeeId,A.SubmitterId,A.CustomerId,LM.MandatoryHours,A.TimesheetId,A.TimeSheetDate,NULL   
  FROM AVL.MAS_LoginMaster(NOLOCK) LM      
  JOIN #tmpdaily(NOLOCK) A   
 ON LM.UserId = A.SubmitterId AND LM.CustomerId = A.CustomerId      
  JOIN AVL.TM_TRN_InfraTimeSheetDetail(NOLOCK) b   
 ON A.TimeSheetId = B.TimeSheetId AND B.IsNonTicket = 1     
  
  UNION     
    
  SELECT EmployeeId,A.SubmitterId,A.CustomerId,LM.MandatoryHours,A.TimesheetId,A.TimeSheetDate,NULL    
  FROM AVL.MAS_LoginMaster(NOLOCK) LM          
  JOIN #tmpdaily(NOLOCK) A   
 ON LM.UserId = A.SubmitterId AND LM.CustomerId = A.CustomerId     
  LEFT JOIN avl.tm_trn_InfraTimeSheetDetail(NOLOCK) B   
 ON A.TimeSheetId = B.TimeSheetId       
  LEFT JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) C   
 ON B.TimeTickerId = C.TimeTickerId AND B.ProjectId = C.ProjectId AND C.IsAttributeUpdated = 1      
  WHERE B.TimesheetId IS NULL  
--end  
  
 UNION  
 SELECT DISTINCT employeeid,a.submitterid,a.customerid,ISNULL(LM.mandatoryhours,0),a.timesheetid,a.timesheetdate,NULL FROM   
 AVL.mas_loginmaster(NOLOCK) LM      
  INNER JOIN #tmpdaily a on lm.userid=a.submitterid and lm.customerid=a.customerid      
  INNER JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) b on a.timesheetid=b.timesheetid       
  INNER JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK) c on b.WorkItemDetailsId=c.WorkItemDetailsId   
  UNION      
  SELECT DISTINCT employeeid,a.submitterid,a.customerid,lm.mandatoryhours,a.timesheetid,a.timesheetdate,NULL from AVL.mas_loginmaster(NOLOCK) LM      
  INNER JOIN #tmpdaily a on lm.userid=a.submitterid and lm.customerid=a.customerid      
  INNER JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) b on a.timesheetid=b.timesheetid and b.isnonticket=1   
  
  
  
  --------non attribute updated tickets--------------      
  CREATE TABLE #invalidtimesheets      
  (      
  EmployeeID NVARCHAR(100),      
  SubmitterId BIGINT NULL,      
  CustomerId BIGINT NULL,      
  MandatoryHours DECIMAL(6,2),      
  TimeSheetID BIGINT NULL,      
  TimeSheetDate DATE NULL,      
  IsValid INT NULL      
  )      
      
  INSERT INTO #invalidtimesheets      
  select employeeid,a.submitterid,a.customerid,Isnull(lm.mandatoryhours,0),a.timesheetid,a.timesheetdate,NULL from avl.mas_loginmaster(nolock) lm      
  join #tmpdaily a on lm.userid=a.submitterid and lm.customerid=a.customerid      
  join avl.tm_trn_timesheetdetail(nolock) b on a.timesheetid=b.timesheetid       
  join avl.tk_trn_ticketdetail(nolock) c on b.timetickerid=c.timetickerid and b.projectid=c.projectid       
  and isnull(c.isattributeupdated,0)=0    
    
  --new block  
  INSERT INTO #invalidtimesheets  
  SELECT EmployeeId,A.SubmitterId,A.CustomerId,ISNULL(LM.MandatoryHours,0),A.TimesheetId,A.TimesheetDate,NULL   
  FROM AVL.MAS_LoginMaster(NOLOCK) LM      
  JOIN #tmpdaily(NOLOCK) A   
 ON LM.UserId = A.SubmitterId AND LM.CustomerId = A.CustomerId      
  JOIN AVL.TM_TRN_Infratimesheetdetail(NOLOCK) B   
 ON A.TimesheetId = B.TimesheetId       
  JOIN AVL.TK_TRN_Infraticketdetail(NOLOCK) C   
 ON B.TimeTickerId = C.TimeTickerId AND B.ProjectId = C.ProjectId AND ISNULL(C.isattributeupdated,0) = 0    
  --ends  
      
  --If a single record is taken as invalid timesheet , then for other project also, timesheet gets invalid      
  UPDATE #invalidtimesheets SET IsValid=0      
      
  UPDATE MD SET MD.IsValid=0 FROM #mandatehoursdaily MD      
  LEFT JOIN #invalidtimesheets IT      
  ON MD.EmployeeID=IT.EmployeeID AND MD.CustomerID=IT.CustomerID      
  AND MD.TimeSheetDate=IT.TimeSheetDate WHERE IT.IsValid=0      
      
      
      
  delete from #mandatehoursdaily where Isvalid=0      
 CREATE TABLE #totalhoursdailyTickets  
 (      
  CustomerId BIGINT NULL,    
  EmployeeID NVARCHAR(100),   
  TimeSheetDate DATE NULL,   
  MandatoryHours DECIMAL(6,2)    
 )  
  CREATE TABLE #totalhoursdaily  
 (      
  CustomerId BIGINT NULL,    
  EmployeeID NVARCHAR(100),   
  TimeSheetDate DATE NULL,   
  MandatoryHours DECIMAL(6,2)    
 )  
  
  ------sum of hours------------------      
  
  INSERT into #totalhoursdailyTickets  
  select DISTINCT a.customerid,a.employeeid,a.timesheetdate,sum(b.hours) as [hours]  from    
  #mandatehoursdaily a join avl.tm_trn_timesheetdetail(nolock) b on a.timesheetid=b.timesheetid      
  group by a.customerid,a.employeeid,a.timesheetdate   
  
 --newly added  
    INSERT into #totalhoursdailyTickets  
 SELECT DISTINCT A.CustomerId,A.EmployeeId,A.TimeSheetDate,SUM(B.hours) AS [hours]    
 FROM #mandatehoursdaily(NOLOCK) A   
 JOIN AVL.TM_TRN_InfraTimeSheetDetail(NOLOCK) B ON A.TimeSheetId = B.TimeSheetId      
 GROUP BY A.CustomerId,A.EmployeeId,A.TimeSheetDate   
 --end  
  
    INSERT into #totalhoursdailyTickets  
  select DISTINCT a.customerid,a.employeeid,a.timesheetdate,sum(b.hours) as [hours]  from       
  #mandatehoursdaily a join ADM.TM_TRN_WorkItemTimesheetDetail(nolock) b on a.timesheetid=b.timesheetid      
  group by a.customerid,a.employeeid,a.timesheetdate    
  
  INSERT into #totalhoursdaily   
  SELECT DISTINCT customerid,employeeid,timesheetdate,SUM(MandatoryHours) FROM #totalhoursdailyTickets  
  GROUP BY customerid,employeeid,timesheetdate  
  ------valid tickets to update--------      
  select a.timesheetid,a.employeeid,a.timesheetdate,b.MandatoryHours into #finaltempdaily from #mandatehoursdaily a      
  join #totalhoursdaily b on a.employeeid=b.employeeid and a.customerid=b.customerid      
  and a.timesheetdate=b.timesheetdate      
  where b.MandatoryHours>=a.mandatoryhours     
   
   
  update avl.tm_prj_timesheet set statusid=2,isautosubmit=1,modifieddatetime=getdate(),modifiedby='EffortBulkUpload'      
  where timesheetid in(select timesheetid from #finaltempdaily)      
      
  --Code Block for Weekly      
  CREATE TABLE #tmpweekly      
  (      
  EmployeeID NVARCHAR(100) NULL,      
  customerid BIGINT NULL,      
  submitterid  BIGINT NULL,      
  timesheetid  BIGINT NULL,      
  timesheetdate DATE NULL,      
  statusid  INT NULL,      
  IsValid INT NULL      
  )      
  CREATE TABLE #Alldates      
  (      
  EmployeeID NVARCHAR(100) NULL,      
  customerid BIGINT NULL,      
  submitterid  BIGINT NULL,      
  timesheetid  BIGINT NULL,      
  Week_Start_Date DATE NULL,      
  Week_End_Date DATE NULL,      
  timesheetdate DATE NULL,      
  statusid  INT NULL,      
  IsValid INT NULL      
  )      
      
  --weekly auto submit      
  INSERT into #tmpweekly       
  select eua.EmployeeID,ts.customerid,ts.submitterid,ts.timesheetid,ts.timesheetdate,ts.statusid,NULL      
   from #effortuploadautosubmit eua       
  inner join avl.tm_prj_timesheet(nolock) ts on eua.customerid=ts.customerid       
  and eua.projectid=ts.projectid and eua.submitterid=ts.submitterid      
  and eua.timesheetdate=ts.timesheetdate    
   INNER JOIN #CustomerUserDates cud ON cud.CustomerID=ts.CustomerID AND cud.SubmitterID=ts.SubmitterId AND cud.TimeSheetDate=ts.TimesheetDate  
  inner join avl.customer(nolock) c on eua.customerid=c.customerid and ISNULL(c.isdaily,0)=0      
  where ts.statusid not in(2,3)      
      
      
  --Retrieves the start date and end date of the line items      
  INSERT  INTO #Alldates      
  select eua.EmployeeID,ts.customerid,ts.submitterid,ts.timesheetid,      
  DATEADD(DAY, 2 - DATEPART(WEEKDAY, ts.timesheetdate), CAST(ts.timesheetdate AS DATE)) [Week_Start_Date],      
  DATEADD(DAY, 8 - DATEPART(WEEKDAY,ts.timesheetdate), CAST(ts.timesheetdate AS DATE)) [Week_End_Date] ,      
  ts.timesheetdate,ts.statusid,NULL      
  from #effortuploadautosubmit eua       
  inner join avl.tm_prj_timesheet(nolock) ts on eua.customerid=ts.customerid and eua.projectid=ts.projectid       
  and eua.submitterid=ts.submitterid      
  and eua.timesheetdate=ts.timesheetdate   
  INNER JOIN #CustomerUserDates cud ON cud.CustomerID=ts.CustomerID AND cud.SubmitterID=ts.SubmitterId AND cud.TimeSheetDate=ts.TimesheetDate  
  inner join avl.customer(nolock) c on eua.customerid=c.customerid and ISNULL(c.isdaily,0)=0      
  where ts.statusid not in(2,3)      
      
  --Makes an entry, for all the dates by customer and submitter id      
  INSERT INTO #tmpweekly      
  SELECT AD.EmployeeID,PS.CustomerID,PS.SubmitterId,PS.TimesheetId,PS.TimesheetDate,PS.StatusId,NULL      
  FROM avl.tm_prj_timesheet(nolock) PS      
  INNER JOIN #Alldates AD ON PS.CustomerID=AD.CustomerID      
  AND PS.SubmitterId=AD.SubmitterId       
  WHERE PS.TimesheetDate >= AD.Week_Start_Date AND PS.TimesheetDate <= AD.Week_End_Date      
  EXCEPT      
  SELECT EmployeeID,CustomerID,SubmitterId,TimesheetId,TimesheetDate,StatusId,NULL      
  FROM #tmpweekly      
      
  ------------filter attribute updated tickets-------      
  SELECT * INTO #mandatehoursweekly FROM(      
  SELECT DISTINCT lm.employeeid,a.submitterid,a.customerid,lm.mandatoryhours,a.timesheetid,a.timesheetdate from avl.mas_loginmaster(nolock) lm      
  join #tmpweekly a on lm.userid=a.submitterid and lm.customerid=a.customerid      
  join avl.tm_trn_timesheetdetail(nolock) b on a.timesheetid=b.timesheetid       
  join avl.tk_trn_ticketdetail(nolock) c on b.timetickerid=c.timetickerid and b.projectid=c.projectid and c.isattributeupdated=1      
  UNION      
  select DISTINCT lm.employeeid,a.submitterid,a.customerid,lm.mandatoryhours,a.timesheetid,a.timesheetdate from avl.mas_loginmaster(nolock) lm      
  join #tmpweekly a on lm.userid=a.submitterid and lm.customerid=a.customerid      
  join avl.tm_trn_timesheetdetail(nolock) b on a.timesheetid=b.timesheetid and b.isnonticket=1      
  UNION  
  SELECT DISTINCT lm.employeeid,a.submitterid,a.customerid,lm.mandatoryhours,a.timesheetid,a.timesheetdate from avl.mas_loginmaster(nolock) lm      
  join #tmpweekly a on lm.userid=a.submitterid and lm.customerid=a.customerid      
  LEFT JOIN avl.tm_trn_timesheetdetail(nolock) b on a.timesheetid=b.timesheetid       
  LEFT JOIN avl.tk_trn_ticketdetail(nolock) c on b.timetickerid=c.timetickerid and b.projectid=c.projectid and c.isattributeupdated=1     
  WHERE b.TimesheetId IS null  
  UNION  
  --new block  
  SELECT DISTINCT LM.EmployeeId,A.SubmitterId,A.CustomerId,LM.MandatoryHours,A.TimesheetId,A.TimesheetDate   
  FROM AVL.MAS_LoginMaster(NOLOCK) LM      
  JOIN #tmpweekly(NOLOCK) A   
 ON LM.UserId = A.SubmitterId and LM.CustomerId = A.CustomerId      
  JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) B   
 ON A.TimesheetId = B.TimesheetId       
  JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) C   
 ON B.TimeTickerId = C.TimeTickerId AND B.ProjectId = C.ProjectId AND C.IsAttributeUpdated = 1      
    
  UNION  
    
  SELECT DISTINCT LM.EmployeeId,A.SubmitterId,A.CustomerId,LM.MandatoryHours,A.TimesheetId,A.TimeSheetDate   
  FROM AVL.MAS_LoginMaster (NOLOCK) LM      
  JOIN #tmpweekly (NOLOCK) A   
 ON LM.UserId = A.SubmitterId AND LM.CustomerId = A.CustomerId      
  JOIN AVL.TM_TRN_InfraTimeSheetDetail (NOLOCK) B   
 ON A.TimeSheetId = B.TimeSheetId AND B.IsNonTicket = 1     
   
  UNION  
  
  SELECT DISTINCT LM.EmployeeId,A.SubmitterId,A.CustomerId,LM.MandatoryHours,A.TimeSheetId,A.TimeSheetDate   
  FROM AVL.MAS_LoginMaster(NOLOCK) LM      
  JOIN #tmpweekly(NOLOCK) A   
  ON LM.UserId = A.SubmitterId AND LM.CustomerId = A.CustomerId      
  LEFT JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) B   
  ON A.TimeSheetId = B.TimeSheetId       
  LEFT JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) C   
  ON B.TimeTickerId = C.TimeTickerId AND B.ProjectId = C.ProjectId AND C.IsAttributeUpdated = 1     
  WHERE B.TimesheetId IS NULL  
  
  UNION  
  --ends  
  SELECT DISTINCT employeeid,a.submitterid,a.customerid,ISNULL(LM.mandatoryhours,0),a.timesheetid,a.timesheetdate FROM   
 AVL.mas_loginmaster(NOLOCK) LM      
  INNER JOIN #tmpdaily a on lm.userid=a.submitterid and lm.customerid=a.customerid      
  INNER JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) b on a.timesheetid=b.timesheetid       
  INNER JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK) c on b.WorkItemDetailsId=c.WorkItemDetailsId   
  UNION      
  SELECT DISTINCT employeeid,a.submitterid,a.customerid,lm.mandatoryhours,a.timesheetid,a.timesheetdate from AVL.mas_loginmaster(NOLOCK) LM      
  INNER JOIN #tmpdaily a on lm.userid=a.submitterid and lm.customerid=a.customerid      
  INNER JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) b on a.timesheetid=b.timesheetid and b.isnonticket=1   
  )a      
      
      
  CREATE TABLE #invalidtimesheetsweekly      
  (      
  employeeid NVARCHAR(100) NULL,      
  submitterid BIGINT NULL,      
  customerid BIGINT NULL,      
  timesheetid BIGINT NULL,      
  timesheetdate DATE NULL      
  )      
      
  --------non attribute updated tickets--------------      
  INSERT into #invalidtimesheetsweekly       
  select Lm.employeeid,a.submitterid,a.customerid,a.timesheetid,a.timesheetdate       
  from avl.mas_loginmaster(nolock) lm      
  join #tmpweekly a on lm.userid=a.submitterid and lm.customerid=a.customerid      
  join avl.tm_trn_timesheetdetail(nolock) b on a.timesheetid=b.timesheetid       
  join avl.tk_trn_ticketdetail(nolock) c on b.timetickerid=c.timetickerid and b.projectid=c.projectid       
  and isnull(c.isattributeupdated,0)=0 AND b.IsDeleted=0      
      
  --new block   
  INSERT INTO #invalidtimesheetsweekly       
  SELECT LM.EmployeeId,A.SubmitterId,A.CustomerId,A.TimeSheetId,A.TimeSheetDate       
  FROM AVL.MAS_LoginMaster(NOLOCK) LM      
  JOIN #tmpweekly(NOLOCK) A   
 ON LM.UserId = A.SubmitterId AND LM.CustomerId = A.CustomerId      
  JOIN AVL.TM_TRN_Infratimesheetdetail(NOLOCK) B   
 ON A.TimesheetId = B.TimesheetId       
  JOIN AVL.TK_TRN_Infraticketdetail(NOLOCK) C   
 ON B.TimeTickerId = C.TimeTickerId AND B.ProjectId = C.ProjectId       
  AND ISNULL(C.IsAttributeUpdated,0) = 0 AND B.IsDeleted = 0   
  --ends  
      
  --TO UPDATE ALL DATES BASED ON INVALID TIMESHEETS      
  UPDATE AD SET AD.ISvALID=0 FROM #Alldates AD      
  INNER JOIN #invalidtimesheetsweekly TE ON AD.EmployeeID=TE.EmployeeID AND AD.CustomerID=TE.CustomerID      
  AND AD.Submitterid=TE.Submitterid      
  AND  ad.Week_Start_Date  <= te.TimeSheetDate  AND   AD.Week_End_Date >= TE.TimeSheetDate       
      
      
      
  --This delete has to be made for the entire week      
  --IF one is not valid entire week timesheet is invalid      
  UPDATE TW       
  SET TW.Isvalid=0      
  FROM #tmpweekly TW      
  INNER JOIN #Alldates AD ON TW.EmployeeID=AD.EmployeeID AND TW.customerid=AD.customerid      
  AND TW.submitterid=AD.submitterid AND TW.timesheetdate = AD.timesheetdate      
  AND TW.timesheetdate = AD.timesheetdate WHERE AD.IsValid=0      
      
  CREATE TABLE #TempWeeklyAlldates      
  (      
  employeeid NVARCHAR(100) NULL,      
  customerid BIGINT NULL,      
  submitterid BIGINT NULL,      
  timesheetid BIGINT NULL,      
  timesheetdate DATE NULL,      
  StatusId INT NULL,      
  [Week_Start_Date] DATE NULL,      
  [Week_End_Date] DATE NULL,      
  IsValid INT NULL,      
  )      
  INSERT INTO #TempWeeklyAlldates      
  SELECT distinct  TW.employeeid,TW.customerid,TW.submitterid,TW.Timesheetid,TW.timesheetdate,      
  TW.StatusId,      
  DATEADD(DAY, 2 - DATEPART(WEEKDAY, TW.timesheetdate), CAST(TW.timesheetdate AS DATE)) [Week_Start_Date],      
  DATEADD(DAY, 8 - DATEPART(WEEKDAY,TW.timesheetdate), CAST(TW.timesheetdate AS DATE)) [Week_End_Date],      
  null      
   FROM #tmpweekly TW      
   INNER JOIN #Alldates AD ON TW.EmployeeID=AD.EmployeeID AND TW.CustomerID=AD.CustomerID      
   AND TW.SubmitterID=AD.SubmitterID  AND [Week_Start_Date] =AD.[Week_Start_Date]      
   AND [Week_End_Date]=AD.[Week_End_Date]      
      
   UPDATE TAD SET TAD.IsValid=0 from #TempWeeklyAlldates TAD      
   INNER JOIN #Alldates AD ON TAD.EmployeeID=AD.EmployeeID AND TAD.CustomerID=AD.CustomerID      
   AND TAD.SubmitterID=AD.SubmitterID -- AND TAD.TimeSheetID=AD.TimeSheetID      
     AND TAD.[Week_Start_Date] =AD.[Week_Start_Date]      
   AND TAD.[Week_End_Date]=AD.[Week_End_Date] AND AD.ISvALID=0      
      
  DELETE A FROM #mandatehoursweekly A       
  INNER JOIN #TempWeeklyAlldates B ON   a.customerid=b.customerid and a.employeeid=b.employeeid      
  AND a.Timesheetid=b.Timesheetid WHERE B.IsValid=0      
      
      
      
      
  ------sum of hours------------------      
  SELECT TW.customerid,TW.employeeid,PT.TimesheetDate,B.Hours,      
  DATEADD(DAY, 2 - DATEPART(WEEKDAY, PT.timesheetdate), CAST(PT.timesheetdate AS DATE)) [Week_Start_Date],      
  DATEADD(DAY, 8 - DATEPART(WEEKDAY,PT.timesheetdate), CAST(PT.timesheetdate AS DATE)) [Week_End_Date]      
  INTO #HoursTemp      
  FROM #mandatehoursweekly TW      
  INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) PT      
  ON TW.Timesheetid=PT.TimesheetId      
  join avl.tm_trn_timesheetdetail(nolock) b on TW.timesheetid=b.timesheetid AND ISNULL(B.IsDeleted,0)=0      
      
 --new block  
  SELECT TW.CustomerId,TW.EmployeeId,PT.TimesheetDate,B.Hours,      
  DATEADD(DAY, 2 - DATEPART(WEEKDAY, PT.timesheetdate), CAST(PT.timesheetdate AS DATE)) [Week_Start_Date],      
  DATEADD(DAY, 8 - DATEPART(WEEKDAY,PT.timesheetdate), CAST(PT.timesheetdate AS DATE)) [Week_End_Date]      
  INTO #HoursTempInfra      
  FROM #mandatehoursweekly(NOLOCK) TW      
  INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) PT      
 ON TW.Timesheetid=PT.TimesheetId      
  INNER JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) B  
 ON TW.timesheetid=B.TimesheetId AND ISNULL(B.IsDeleted,0)=0    
 --ends  
  
 SELECT TW.customerid,TW.employeeid,PT.TimesheetDate,B.Hours,      
  DATEADD(DAY, 2 - DATEPART(WEEKDAY, PT.timesheetdate), CAST(PT.timesheetdate AS DATE)) [Week_Start_Date],      
  DATEADD(DAY, 8 - DATEPART(WEEKDAY,PT.timesheetdate), CAST(PT.timesheetdate AS DATE)) [Week_End_Date]      
  INTO #HoursTempWorkItem     
  FROM #mandatehoursweekly TW      
  INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) PT      
  ON TW.Timesheetid=PT.TimesheetId      
  join ADM.TM_TRN_WorkItemTimesheetDetail(nolock) b on TW.timesheetid=b.timesheetid AND ISNULL(B.IsDeleted,0)=0    
  
  CREATE TABLE #totalhoursweeklyAll  
  (  
          
  customerid BIGINT NULL,   
  employeeid NVARCHAR(100) NULL,    
  [Week_Start_Date] DATE NULL,      
  [Week_End_Date] DATE NULL,      
   Hours DECIMAL(18,2) NULL  
    
  )  
  INSERT INTO  #totalhoursweeklyAll  
  select HT.customerid,HT.employeeid,[Week_Start_Date],[Week_End_Date],sum(HT.hours) as [hours]      
   from       
   #HoursTemp HT      
   group by HT.customerid,HT.employeeid,HT.[Week_Start_Date],HT.[Week_End_Date]     
     
   --new block  
   INSERT INTO  #totalhoursweeklyAll  
   SELECT HT.customerid,HT.employeeid,[Week_Start_Date],[Week_End_Date],sum(HT.hours) AS [hours]      
   FROM       
   #HoursTempInfra HT      
   GROUP BY HT.customerid,HT.employeeid,HT.[Week_Start_Date],HT.[Week_End_Date]     
   --ends  
      
 INSERT INTO  #totalhoursweeklyAll  
   select HT.customerid,HT.employeeid,[Week_Start_Date],[Week_End_Date],sum(HT.hours) as [hours]      
    from  #HoursTempWorkItem HT      
   group by HT.customerid,HT.employeeid,HT.[Week_Start_Date],HT.[Week_End_Date]      
  
   SELECT HT.customerid,HT.employeeid,[Week_Start_Date],[Week_End_Date],sum(HT.hours) as [hours]    
   INTO #totalhoursweekly FROM #totalhoursweeklyAll HT  
    group by HT.customerid,HT.employeeid,HT.[Week_Start_Date],HT.[Week_End_Date]   
  
     
  ------valid tickets to update--------      
  SELECT EmployeeId,SubmitterID,CustomerId,MandatoryHours,TimesheetId,Timesheetdate,      
   DATEADD(DAY, 2 - DATEPART(WEEKDAY, timesheetdate), CAST(timesheetdate AS DATE)) [Week_Start_Date],      
  DATEADD(DAY, 8 - DATEPART(WEEKDAY,timesheetdate), CAST(timesheetdate AS DATE)) [Week_End_Date]      
   INTO #mandatehoursweeklyTemp      
    FROM #mandatehoursweekly      
      
      
  select a.timesheetid,a.employeeid,a.timesheetdate,b.[hours] into #finaltempweekly from #mandatehoursweeklyTemp a      
  join #totalhoursweekly b on a.employeeid=b.employeeid and a.customerid=b.customerid      
  AND A.[Week_End_Date]=B.[Week_End_Date] AND A.[Week_Start_Date]=B.[Week_Start_Date]      
  where b.[hours]>=(a.mandatoryhours*5)      
      
  update avl.tm_prj_timesheet set statusid=2,isautosubmit=1,modifieddatetime=getdate(),modifiedby='EffortBulkUpload'       
  where timesheetid in(select timesheetid from #finaltempweekly)      
      
      
  update eu set eu.isprocessed=1      
  from  avl.effortuploadautosubmit eu      
  inner join #effortuploadautosubmit es on eu.id=es.id      
  INNER join AVL.TM_PRJ_Timesheet TS on TS.ProjectID = eu.ProjectID and TS.CustomerID = eu.CustomerID and TS.SubmitterId = eu.SubmitterID and TS.TimesheetDate = eu.TimeSheetDate      
  where TS.StatusId in (2,3)      
      
       
      
drop table #mandatehoursweekly      
  drop table #totalhoursweekly      
  drop table #finaltempweekly      
      
      
  drop table #mandatehoursdaily      
  drop table #totalhoursdaily      
  drop table #finaltempdaily      
    
  --Job Ststus   
      
INSERT INTO MAS.JobStatus  
(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)  
VALUES(@JobID,@StartDateTime,GETDATE(),@Success,GETDATE(),0,@JobName,GETDATE(),@Rows,0,0)  
  
   
      
        
commit tran      
        
end try      
begin catch      
    
 ROLLBACK TRAN      
      
 DECLARE @ErrorMessage VARCHAR(MAX);      
      
 SELECT @ErrorMessage = ERROR_MESSAGE()      
 INSERT INTO MAS.JobStatus  
(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)  
VALUES(@JobID,GETDATE(),GETDATE(),@Failed,GETDATE(),0,@JobName,GETDATE(),0,0,0)  
      
 --INSERT Error      
      
 EXEC AVL_InsertError 'AVL.EffortUpload_AutoSubmit',@ErrorMessage,0,0      
         
end catch      
end 

