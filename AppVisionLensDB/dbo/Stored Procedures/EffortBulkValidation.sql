/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROC [dbo].[EffortBulkValidation]       
@TvpEffortUpload as TVP_InputTableTVP readonly,
@EmployeeID nvarchar(50)
AS      
BEGIN      
BEGIN TRY      
BEGIN TRAN    
DECLARE @TICKETIDALREADYEXISTS AS VARCHAR(1000)='ID is mandatory and it should already been uploaded in Work Profiler. ';      
DECLARE @TICKETIDALREADYEXISTSCUST AS VARCHAR(1000)='Ticket ID not exists for the project. Upload the tickets via bulk or create ticket manually for successful effort upload ';     
DECLARE @UserNotMappedMsg AS VARCHAR(1000)='User Not Configured for the ProjectID ';     
DECLARE @UserNotMappedCognizantMsg AS VARCHAR(1000)='Cognizant ID is mandatory and the user should be part of User Management for the respective project ';     
DECLARE @LeadMsg AS VARCHAR(1000)='Efforts can be uploaded only for yourself. For effort upload for another associate please reach out to you Lead';
DECLARE @ServiceNotConfiguredProject AS VARCHAR(1000)='Service Name is mandatory and should have only 1 of the values configured in AppLens. Ticket should have always mapped with AVM services and Work Item should only accept AD services ';   
DECLARE @TicketTypeServiceNotConfig AS VARCHAR(1000)='Service Name captured for this ticket is not relevant to its ticket type.Configure this service against a Ticket Type in AppLens Configuration ';      
DECLARE @TSHours AS VARCHAR(1000)='Timesheet has more than 24 hours of effort for the associate in a same day ';      
DECLARE @ActivityNotConfigForService AS VARCHAR(1000)='Activity Name is mandatory and should have only 1 of the project specific values configured in AppLens corresponding to the captured Service Name ';      
DECLARE @ActivityNotConfigForNonDelivery AS VARCHAR(1000)='For NonDelivery, the activity should be from the following list: "Leave/Holiday, Organization Activity, Meeting, Idle, Team building, Training, Comp Off and Others"';      
DECLARE @TimeSheetApproved AS VARCHAR(1000)='TimeSheet is already approved ';      
DECLARE @TimeSheetSubmitted AS VARCHAR(1000)='TimeSheet is already submitted ';      
DECLARE @TicketTypeForCustomer AS VARCHAR(1000)='Ticket Type captured for this ticket has not been configured. Configure the Ticket type in3rd step of  ITSM Configuration module ';      
DECLARE @Duplicate AS VARCHAR(1000) = 'ID has the Duplicate Entry' ;    
DECLARE @GracePeriodMessageCog AS NVARCHAR(1000) ='Service Name cannot be modified, as the ticket(s) are already met with the Grace period defined under Debt Control';    
DECLARE @GracePeriodMessageCus AS NVARCHAR(1000) ='Ticket Type cannot be modified, as the ticket(s) are already met with the Grace period defined under Debt Control';    
DECLARE @AHMessageCog AS NVARCHAR(1000)='Service Name cannot be modified, as these ticket(s) are already tagged to an A/H/K tickets.';    
DECLARE @AHMessageCus AS NVARCHAR(1000)='Ticket Type cannot be modified, as the ticket(s) are already tagged to an A/H/K tickets.';    
DECLARE @SuggestedActivity AS NVARCHAR(1000)='Suggested activity have the content which is not valid, refer read me sheet.';    
DECLARE @ServiceEffectivedate AS NVARCHAR(1000) = 'Timesheet cannot be submitted for Services that are no more effective '    
DECLARE @efforttrackforworkitem AS NVARCHAR(1000) = 'Efforts can be captured only for the work items, for which Effort tracking is marked as "Yes" under ALM configuration'    
DECLARE @Iscognizant as bit,@Projectid bigint;     
DECLARE @isapplensasALM  as bit;    
DECLARE @IsEffortTrackActivityWise as bit;  
DECLARE @TaskMapped AS NVARCHAR(1000) = 'Task is mandatory and captured Task should be configured under App/Infra Inventory - > Task Mapping section for the technology tower which the ticket is mapped';  
    
CREATE table  #InputTable     
(      
ID INT IDENTITY(1,1),      
TicketID NVARCHAR(MAX),    
TrackID NVARCHAR(MAX),      
ServiceName VARCHAR(MAX),      
ActivityName VARCHAR(MAX),    
SuggestedActivity NVARCHAR(50) NULL,    
Remarks NVARCHAR(max) NULL,    
TicketType VARCHAR(MAX),      
Hours DECIMAL(6,2),      
CognizantID VARCHAR(MAX),      
IsCognizant BIT,      
TimeSheetDate DATE,      
ProjectID BIGINT,      
WeekNumber INT,      
ServiceID INT,      
ActivityID INT,      
IsDeleted BIT DEFAULT 0,    
[Type] VARCHAR(10)    
)      
      
    
INSERT INTO #InputTable      
(TicketID,TrackID,ServiceName,ActivityName,SuggestedActivity,Remarks,TicketType,Hours,CognizantID,TimeSheetDate,ProjectID,IsDeleted,IsCognizant,[Type])      
      
select TicketID,TrackID,ServiceName,ActivityName,SuggestedActivity,Remarks,TicketType,Hours,CognizantID,TimeSheetDate,ProjectID,0,IsCognizant,[Type]     
FROM   @TvpEffortUpload     
    
 set @Iscognizant=( select top 1 IsCognizant from  #InputTable)      
 set @Projectid=( select top 1 ProjectID from  #InputTable)      
 set @IsEffortTrackActivityWise=(SELECT top 1 ISNULL(c.IsEffortTrackActivityWise,1)     
        from AVL.MAS_ProjectMaster pm(NOLOCK) join avl.Customer c(NOLOCK)     
         on c.CustomerID=pm.CustomerID where pm.IsDeleted=0 and c.IsDeleted=0     
         and pm.ProjectID=@Projectid)
         	DECLARE @IsLead bit;
		 IF EXISTS (SELECT 1 FROM AVL.MAS_LoginMaster(NOLOCK) WHERE ProjectId = @ProjectId AND IsDeleted = 0
		AND (TSApproverID = @EmployeeID OR HcmSupervisorID = @EmployeeID OR @EmployeeId = 'Sharepath'))
		BEGIN
		SET @IsLead = 1;
		END
		ELSE
		BEGIN
		SET @IsLead = 0;
		END
DECLARE @ErrorTable AS TABLE      
(      
InputRecordID INT ,      
TicketID NVARCHAR(MAX),    
ServiceName VARCHAR(MAX),      
ActivityName VARCHAR(MAX),      
TicketType VARCHAR(MAX),      
Hours DECIMAL(6,2),      
CognizantID VARCHAR(MAX),      
TimeSheetDate DATE,      
ProjectID BIGINT,      
Remarks VARCHAR(MAX),      
IsCognizant BIT,    
[Type] VARCHAR (10)    
)      
     
--Update the Ticket Type      
UPDATE IT       
SET IT.TicketType= CASE WHEN C.IsCognizant=1 THEN  TD.TicketTypeMapID ELSE ISNULL(tm.TicketTypeMappingID,0) END      
FROM #InputTable IT JOIN AVL.TK_TRN_TicketDetail TD       
ON TD.TicketID=IT.TicketID and TD.ProjectID=IT.ProjectID      
join avl.MAS_ProjectMaster pm(NOLOCK) on pm.ProjectID=it.ProjectID and pm.IsDeleted=0      
JOIN AVL.Customer C(NOLOCK) ON C.CustomerID=PM.CustomerID AND C.IsDeleted=0      
LEFT JOIN AVL.TK_MAP_TicketTypeMapping TM(NOLOCK) ON TM.ProjectID=IT.Projectid and tm.tickettype=it.TicketType      
and C.isCognizant=0 AND PM.ProjectID=@Projectid     
where IT.[Type] = 'T'     
    
--select  * from  #InputTable    
      
UPDATE IT       
SET IT.ActivityName = IT.TicketType,IT.TicketType=''     
from #InputTable IT      
where IT.TicketID = 'NONDELIVERY' AND ISNULL(IT.IsCognizant,0)=0      
    
      
--Update the WeekNumber      
if(@Iscognizant=1)      
BEGIN     
 INSERT INTO @ErrorTable       
 (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 SELECT itr.ID, ITR.TicketID,ITR.TicketType,itr.ServiceName,ITR.ActivityName,ITR.Hours,ITR.CognizantID,ITR.TimeSheetDate      
 ,ITR.ProjectID,@TICKETIDALREADYEXISTS,itr.IsCognizant,itr.[Type] from #InputTable IT JOIN AVL.TK_TRN_TicketDetail TD       
 ON TD.TicketID=IT.TicketID AND TD.ProjectID=IT.ProjectID      
 AND TD.IsDeleted=0      
 RIGHT JOIN #InputTable ITR ON ITR.ID=IT.ID AND IT.ProjectID=ITR.ProjectID   AND TD.ProjectID=@Projectid      
 WHERE IT.ID IS NULL AND ITR.[Type]='T'     
  
--new block  
 INSERT INTO @ErrorTable       
 (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 SELECT itr.ID, ITR.TicketID,ITR.TicketType,itr.ServiceName,ITR.ActivityName,ITR.Hours,ITR.CognizantID,ITR.TimeSheetDate      
 ,ITR.ProjectID,@TICKETIDALREADYEXISTS,itr.IsCognizant,itr.[Type] from #InputTable IT JOIN AVL.TK_TRN_InfraTicketDetail TD       
 ON TD.TicketID=IT.TicketID AND TD.ProjectID=IT.ProjectID      
 AND TD.IsDeleted=0      
 RIGHT JOIN #InputTable ITR ON ITR.ID=IT.ID AND IT.ProjectID=ITR.ProjectID   AND TD.ProjectID=@Projectid      
 WHERE IT.ID IS NULL AND ITR.[Type]='I'   
--ends  
END  
ELSE    
BEGIN    
 INSERT INTO @ErrorTable       
 (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 SELECT itr.ID, ITR.TicketID,ITR.TicketType,itr.ServiceName,ITR.ActivityName,ITR.Hours,ITR.CognizantID,ITR.TimeSheetDate      
 ,ITR.ProjectID,@TICKETIDALREADYEXISTSCUST,itr.IsCognizant,itr.[Type] from #InputTable IT JOIN AVL.TK_TRN_TicketDetail TD       
 ON TD.TicketID=IT.TicketID AND TD.ProjectID=IT.ProjectID      
 AND TD.IsDeleted=0      
 RIGHT JOIN #InputTable ITR ON ITR.ID=IT.ID AND IT.ProjectID=ITR.ProjectID   AND TD.ProjectID=@Projectid      
 WHERE IT.ID IS NULL AND ITR.TicketID !='NONDELIVERY'     
END    
    
INSERT INTO @ErrorTable       
(InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
SELECT itr.ID, ITR.TicketID,ITR.TicketType,itr.ServiceName,ITR.ActivityName,ITR.Hours,ITR.CognizantID,ITR.TimeSheetDate      
,ITR.ProjectID,@TICKETIDALREADYEXISTS,itr.IsCognizant,itr.[Type] from #InputTable IT JOIN ADM.ALM_TRN_WorkItem_Details TD       
ON TD.WorkItem_Id=IT.TicketID AND TD.Project_Id=IT.ProjectID      
AND TD.IsDeleted=0      
RIGHT JOIN #InputTable ITR ON ITR.ID=IT.ID AND IT.ProjectID=ITR.ProjectID    AND TD.Project_Id=@Projectid      
WHERE IT.ID IS NULL AND ITR.[Type]='W'    
    
    
 IF @IsEffortTrackActivityWise = 0    
 BEGIN    
 INSERT INTO @ErrorTable       
 (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 SELECT itr.ID, ITR.TicketID,ITR.TicketType,itr.ServiceName,ITR.ActivityName,ITR.Hours,ITR.CognizantID,ITR.TimeSheetDate      
 ,ITR.ProjectID,@Duplicate,itr.IsCognizant,[Type] from  #InputTable ITR INNER JOIN     
 (select  TicketID,ServiceName, CognizantID, TimeSheetDate,COUNT(TicketID) AS DuplicateCount from #InputTable     
 where [Type] != 'ND'      
 GROUP by TicketID, ServiceName, CognizantID, TimeSheetDate    
 HAVING count(TicketID) > 1) AS InputTemp on ITR.TicketID = InputTemp.TicketID and ITR.ServiceName = InputTemp.ServiceName    
 and ITR.CognizantID = InputTemp.CognizantID and ITR.TimeSheetDate = InputTemp.TimeSheetDate     
 END    
if(@Iscognizant=1)      
BEGIN   
IF(@IsLead = 0)
BEGIN
 SELECT DISTINCT      
 B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
 ,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
 ,B.CognizantID AS CognizantID      
 ,@LeadMsg AS Remarks      
 ,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,b.[Type]      
 INTO #TempForInactives     
   FROM #InputTable IT INNER JOIN AVL.MAS_LoginMaster LM (NOLOCK)      
 ON TRIM(IT.CognizantID) = TRIM(@EmployeeID)  AND LM.ProjectID=IT.ProjectID   AND IT.ProjectID=@Projectid    
 RIGHT JOIN #InputTable B ON B.ID=IT.ID      
 WHERE IT.id is NULL   
      
 MERGE @ErrorTable AS EUP      
 USING #TempForInactives as tmp      
 ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
 WHEN MATCHED THEN      
 UPDATE SET EUP.Remarks = EUP.Remarks+TMP.Remarks      
  WHEN NOT MATCHED THEN      
 INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 VALUES      
  (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,    
  tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,@LeadMsg,tmp.IsCognizant,tmp.[Type]); 

END
ELSE
BEGIN
 SELECT DISTINCT      
 B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
 ,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
 ,B.CognizantID AS CognizantID      
 ,@UserNotMappedCognizantMsg AS Remarks      
 ,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,b.[Type]      
 INTO #TempForInactive      
   FROM #InputTable IT INNER JOIN AVL.MAS_LoginMaster LM (NOLOCK)      
 ON TRIM(LM.EmployeeID) = TRIM(IT.CognizantID) AND LM.ProjectID=IT.ProjectID   AND IT.ProjectID=@Projectid    
 RIGHT JOIN #InputTable B ON B.ID=IT.ID      
 WHERE IT.id is NULL      
      
 -- 1 Valid User validation      
      
 MERGE @ErrorTable AS EUP      
      
 USING #TempForInactive as tmp      
      
 ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
 WHEN MATCHED THEN      
 UPDATE SET EUP.Remarks = EUP.Remarks+TMP.Remarks      
         
         
  WHEN NOT MATCHED THEN      
      
 INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 VALUES      
  (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,    
  tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,@UserNotMappedCognizantMsg,tmp.IsCognizant,tmp.[Type]);      
END     
END
ELSE    
BEGIN     
     
     
 SELECT DISTINCT      
 B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
 ,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
 ,B.CognizantID AS CognizantID      
 ,@UserNotMappedMsg AS Remarks      
 ,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,b.[Type]      
 INTO #TempForInactiveCUST      
   FROM #InputTable IT INNER JOIN AVL.MAS_LoginMaster LM (NOLOCK)      
 ON TRIM(LM.EmployeeID) = TRIM(IT.CognizantID) AND LM.ProjectID=IT.ProjectID      
 RIGHT JOIN #InputTable B ON B.ID=IT.ID      
 WHERE IT.id is NULL      
      
    
 -- 1.1 Valid User validation      
      
 MERGE @ErrorTable AS EUP      
      
 USING #TempForInactiveCUST as tmp      
      
 ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
 WHEN MATCHED THEN      
 UPDATE SET EUP.Remarks = EUP.Remarks+TMP.Remarks      
   
         
  WHEN NOT MATCHED THEN      
      
 INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 VALUES      
  (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,@UserNotMappedMsg,tmp.IsCognizant,tmp.[Type]);     
    
    
END    
      
     
-- 2 Ticket ID Already Exists      
DECLARE @CustomerID varchar(max) = (select top 1 CustomerID from AVL.MAS_ProjectMaster(NOLOCK)     
         where ProjectID = @Projectid)      
         
      
DECLARE @TM_PRJ_TimesheetTemp As table      
(      
CustomerID BIGINT NULL,      
TimeSheetDate DATE NULL,      
ProjectID BIGINT NULL,      
SubmitterID BIGINT NULL,      
EmployeeID NVARCHAR(100) NULL,      
StatusID INT NULL,      
ISDaily INT NULL,      
StartDate DATE NULL,      
EndDate DATE NULL      
)      
    
INSERT INTO @TM_PRJ_TimesheetTemp      
select DISTINCT lm.CustomerID,IT.TimeSheetDate,LM.ProjectID,lm.UserID,it.CognizantID,'','',      
DATEADD(DAY, 1 - DATEPART(WEEKDAY, IT.timesheetdate), CAST(IT.timesheetdate AS DATE)) [Week_Start_Date],      
DATEADD(DAY, 7 - DATEPART(WEEKDAY,IT.timesheetdate), CAST(IT.timesheetdate AS DATE)) [Week_End_Date]      
    
from #InputTable IT       
right JOIN AVL.MAS_LoginMaster (NOLOCK)  LM ON TRIM(LM.EmployeeID)=TRIM(IT.CognizantID) AND IT.ProjectID=LM.ProjectID      
INNER JOIN AVL.MAS_LoginMaster (NOLOCK)  LM1 ON TRIM(LM1.EmployeeID)=TRIM(IT.CognizantID)   
where lm.CustomerID = @CustomerID    
      
    
    
update TP set TP.ISDaily = Isnull(TM.IsDaily,0) from @TM_PRJ_TimesheetTemp  TP      
join AVL.Customer(NOLOCK) TM on tm.CustomerID = TP.CustomerID       
    
    
SELECT  T.CustomerID,T.TimesheetDate,T.SubmitterId,T.StatusId INTO #Timesheet     
from #InputTable IT       
INNER JOIN AVL.MAS_LoginMaster (NOLOCK)  LM1 ON TRIM(LM1.EmployeeID)=TRIM(IT.CognizantID)    
inner JOIN AVL.TM_PRJ_Timesheet T ON LM1.CustomerID=T.CustomerID AND LM1.UserID=T.SubmitterId    
INNER JOIN @TM_PRJ_TimesheetTemp TT ON IT.CognizantID=TT.EmployeeID     
where lm1.CustomerID = @CustomerID    
AND TT.StartDate <= T.TimesheetDate   AND   TT.EndDate >= T.TimesheetDate    
    
update A set A.StatusID =C.StatusId FROM @TM_PRJ_TimesheetTemp A      
INNER JOIN avl.MAS_LoginMaster B (NOLOCK)     
ON A.CustomerID=B.CustomerID AND TRIM(A.EmployeeID)=TRIM(B.EmployeeID)      
INNER JOIN #Timesheet C(NOLOCK) ON C.CustomerID=A.CustomerID      
AND C.CustomerID=B.CustomerID      
AND A.StartDate <= C.TimesheetDate   AND   A.EndDate >= C.TimesheetDate AND B.UserID=C.SubmitterId AND B.UserID=C.SubmitterId      
AND B.UserID=C.SubmitterId      
WHERE C.StatusId IN(2,3) and A.ISDaily = 0       
      
    
      
UPDATE A set A.StatusID =C.StatusId FROM @TM_PRJ_TimesheetTemp A      
INNER JOIN avl.MAS_LoginMaster B  (NOLOCK)     
ON A.CustomerID=B.CustomerID AND TRIM(A.EmployeeID)=TRIM(B.EmployeeID)      
INNER JOIN #Timesheet C(NOLOCK) ON C.CustomerID=A.CustomerID      
AND C.CustomerID=B.CustomerID      
AND A.TimeSheetDate=C.TimesheetDate      
AND B.UserID=C.SubmitterId      
WHERE C.StatusId IN(2,3) and A.ISDaily = 1      
    
    
update  IT set IT.ActivityID = NDA.ID      
from #InputTable IT      
join AVL.MAS_NonDeliveryActivity NDA(NOLOCK) on NDA.NonTicketedActivity = IT.ActivityName      
where NDA.IsActive = 1 and IT.TicketID = 'NONDELIVERY'      
    
----SuggestedActivity    
create table #ExcludedWord    
(    
Name nvarchar(50),    
)    
insert into #ExcludedWord    
select ExcludedWordName AS Name  from MAS.ExcludedWords(NOLOCK) where IsDeleted =0    
    
insert INTO #ExcludedWord    
select NonTicketedActivity AS Name from avl.MAS_NonDeliveryActivity(NOLOCK) where IsActive =1    
    
    
SELECT DISTINCT B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
,B.CognizantID AS CognizantID      
,@SuggestedActivity AS Remarks      
,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,b.[Type]    
INTO #SuggestedActivity    
FROM  #InputTable B      
JOIN #ExcludedWord EW ON EW.Name = B.SuggestedActivity    
where B.TicketID = 'NONDELIVERY' and B.ActivityID = 8    
    
drop table #ExcludedWord    
     
MERGE @ErrorTable AS EUP      
      
USING #SuggestedActivity as tmp      
      
ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
      
WHEN MATCHED THEN      
UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
WHEN NOT MATCHED THEN      
      
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
VALUES      
(tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);      
     
----Day Validation       
select distinct B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
,B.CognizantID AS CognizantID      
,CASE when ts.StatusId=2 THEN @TimeSheetSubmitted+ ' For '+cast(TS.TimesheetDate as NVARCHAR(max))      
WHEN TS.StatusId=3 THEN @TimeSheetApproved+ ' FOR '+cast(TS.TimesheetDate as NVARCHAR(max)) END AS Remarks       
,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,b.[Type]     
into #TempForTimeSheetDate      
FROM        
#InputTable B      
join @TM_PRJ_TimesheetTemp TS on ts.TimesheetDate = b.TimeSheetDate  AND TS.EmployeeID=B.CognizantID    
WHERE TS.StatusID in (2,3) and TS.ISDaily = 1       
      
MERGE @ErrorTable AS EUP      
      
USING #TempForTimeSheetDate as tmp      
      
ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
      
WHEN MATCHED THEN      
UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
 WHEN NOT MATCHED THEN      
      
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);      
      
      
 --- Week Validation       
select distinct B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
,B.CognizantID AS CognizantID     
,CASE when ts.StatusId=2 THEN @TimeSheetSubmitted+ 'For Week '+cast(TS.StartDate as NVARCHAR(max)) + ' TO '+cast(TS.EndDate as NVARCHAR(max))      
WHEN TS.StatusId=3 THEN @TimeSheetApproved+ 'FOR Week '+cast(TS.TimesheetDate as NVARCHAR(max))  + ' TO '+cast(TS.EndDate as NVARCHAR(max)) END AS Remarks       
,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,B.[Type]       
into #TempForTimeSheetDateForWeek      
FROM        
#InputTable B      
join @TM_PRJ_TimesheetTemp TS on B.TimesheetDate >= TS.StartDate AND B.TimesheetDate <= TS.EndDate      
 AND B.CognizantID=TS.EmployeeID    
WHERE TS.StatusID in (2,3) and TS.ISDaily = 0        
      
      
MERGE @ErrorTable AS EUP      
      
USING #TempForTimeSheetDateForWeek as tmp      
      
ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
      
WHEN MATCHED THEN      
UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
 WHEN NOT MATCHED THEN      
      
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);      
      
 --Task validation for Infra   
 IF(@Iscognizant = 1)  
 BEGIN  
 SELECT     
 ID,TicketID,TrackID,ServiceName,ActivityName,SuggestedActivity,Remarks,TicketType,Hours,CognizantID,TimeSheetDate,ProjectID,IsDeleted,IsCognizant,[Type]    
 INTO #TicketInfraFilter    
 FROM #InputTable (NOLOCK)    
 WHERE [Type] ='I'  
  
 SELECT  DISTINCT IHMT.CustomerID,IPM.ProjectID,ITDT.InfraTowerTransactionID,ITDT.TowerName,ITT.InfraTransactionTaskID,  
 ITT.InfraTaskName,ITMT.SupportLevelID AS ServiceLevelID  
 INTO #TaskTemp  
 FROM  AVL.InfraHierarchyMappingTransaction(NOLOCK) IHMT  
 INNER JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) ITDT   
 ON IHMT.CustomerID = ITDT.CustomerID AND IHMT.InfraTransMappingID = ITDT.InfraTransMappingID  
 INNER JOIN AVL.InfraTaskMappingTransaction(NOLOCK) ITMT   
 ON ITDT.CustomerID = ITMT.CustomerID AND IHMT.HierarchyTwoTransactionID = ITMT.TechnologyTowerID AND ITMT.IsEnabled = 1  
 INNER JOIN AVL.InfraTaskTransaction(NOLOCK) ITT   
 ON ITT.CustomerID = ITMT.CustomerID AND ITT.InfraTransactionTaskID = ITMT.InfraTransactionTaskID  
 INNER JOIN AVL.InfraHierarchyThreeTransaction(NOLOCK) HTT   
 ON IHMT.CustomerID = HTT.CustomerID AND HTT.HierarchyThreeTransactionID = IHMT.HierarchyThreeTransactionID  
 INNER JOIN AVL.InfraTowerProjectMapping(NOLOCK) IPM   
 ON IPM.TowerID = ITDT.InfraTowerTransactionID  
 INNER JOIN #TicketInfraFilter(NOLOCK) TIF   
 ON TIF.ProjectId = IPM.ProjectID AND IPM.IsEnabled = 1  
  
 SELECT DISTINCT      
 B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
    ,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
 ,B.CognizantID AS CognizantID      
 ,@TaskMapped AS Remarks      
 ,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,B.[Type]     
 INTO #TempForInactiveTask  
 FROM #TicketInfraFilter(NOLOCK) IT  
 INNER JOIN #TaskTemp(NOLOCK) TT  
 ON TT.ProjectID = IT.ProjectID AND TT.InfraTaskName = IT.ActivityName  
 INNER JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD   
 ON TD.TicketID = IT.TicketID AND TD.ProjectID = IT.ProjectId   
 AND TT.InfraTowerTransactionID = TD.TowerID  
 RIGHT JOIN #TicketInfraFilter(NOLOCK) B ON IT.ID = B.ID AND IT.ProjectID=B.ProjectID       
 WHERE IT.ID IS NULL   
   
 MERGE @ErrorTable AS EUP      
 USING #TempForInactiveTask as tmp      
 ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
 WHEN MATCHED THEN      
 UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
 WHEN NOT MATCHED THEN      
 INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,  
 CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,  
 tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);    
 END  
   
   
-- Activity Validation for Non Delivery       
      
SELECT       
DISTINCT      
 B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
,B.CognizantID AS CognizantID      
,@ActivityNotConfigForNonDelivery AS Remarks      
,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,b.[Type]      
INTO #TempForNONInactiveActivity      
from #InputTable  IT      
JOIN AVL.MAS_NonDeliveryActivity ND (NOLOCK)  on ND.id = IT.ActivityID and ND.IsActive = 1      
RIGHT JOIN #InputTable B ON B.ID=IT.ID and b.ProjectID = IT.ProjectID      
where it.ID is NULL AND  B.TicketID = 'NONDELIVERY'      
      
MERGE @ErrorTable AS EUP      
      
USING #TempForNONInactiveActivity as tmp      
      
ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
WHEN MATCHED THEN      
UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
 WHEN NOT MATCHED THEN      
      
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);      
      
-- 3 Service Validation  FOR TICKET     
if(@Iscognizant=1)      
BEGIN      
    
 select     
 ID,TicketID,TrackID,ServiceName,ActivityName,SuggestedActivity,Remarks,TicketType,Hours,CognizantID,TimeSheetDate,ProjectID,IsDeleted,IsCognizant,[Type]    
 into #TicketFilter    
 from #InputTable     
 where [Type] ='T'    
    
    
SELECT DISTINCT      
B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
,B.CognizantID AS CognizantID      
,@ServiceNotConfiguredProject AS Remarks      
,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,B.[Type]     
INTO #TempForInactiveService      
 FROM        
#TicketFilter IT       
INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM  (NOLOCK)      
ON SAM.ServiceName=IT.ServiceName       
INNER JOIN AVL.TK_MAS_Service SA (NOLOCK)    
ON SA.ServiceID = SAM.ServiceID AND SA.ScopeID IN (2,3)      
INNER JOIN  AVL.TK_PRJ_ProjectServiceActivityMapping PSAM  (NOLOCK)     
ON SAM.ServiceMappingID=PSAM.ServiceMapID      
AND PSAM.ProjectID=IT.ProjectID AND PSAM.ProjectID=@ProjectID    
AND SAM.IsDeleted=0 AND PSAM.IsDeleted=0      
RIGHT JOIN #TicketFilter B ON IT.ID = B.ID AND IT.ProjectID=B.ProjectID       
WHERE IT.ID IS NULL     
    
    
MERGE @ErrorTable AS EUP      
      
USING #TempForInactiveService as tmp      
      
ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
WHEN MATCHED THEN      
UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
 WHEN NOT MATCHED THEN      
      
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);      
     
    
    
 select  ID,TicketID,TrackID,ServiceName,ActivityName,SuggestedActivity,Remarks,TicketType,Hours,CognizantID,TimeSheetDate,ProjectID,IsDeleted,IsCognizant,[Type]    
 into #WorkItemFilter    
 from #InputTable     
 where [Type] ='W'    
    
SET  @isapplensasALM = (select ISNULL(IsApplensAsALM,1) from pp.ScopeOfWork(NOLOCK) where ProjectID = @Projectid AND Isdeleted = 0)    
    
IF(@isapplensasALM = 0)    
BEGIN    
 -- Effortbased on workitemtype for workitem only     
 SELECT DISTINCT      
 B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
 ,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
 ,B.CognizantID AS CognizantID      
 ,@efforttrackforworkitem AS Remarks      
 ,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,B.[Type]      
 INTO #TempForWorkitemtype    
  FROM        
 #WorkItemFilter IT  (NOLOCK)     
 INNER JOIN ADM.ALM_TRN_WorkItem_Details WD(NOLOCK)     
 ON WD.WorkItem_Id = IT.TicketID AND WD.Project_Id = IT.ProjectID    
 INNER JOIN PP.ALM_MAP_WorkType WT(NOLOCK)     
 ON WT.WorkTypeMapId = WD.WorkTypeMapId AND WD.IsDeleted = 0 AND WT.Isdeleted = 0    
 RIGHT JOIN #WorkItemFilter B ON IT.ID = B.ID AND IT.ProjectID=B.ProjectID      
 WHERE WT.IsEffortTracking = 0    
     
 MERGE @ErrorTable AS EUP      
      
 USING #TempForWorkitemtype as tmp      
      
 ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
 WHEN MATCHED THEN      
 UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
  WHEN NOT MATCHED THEN      
      
 INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 VALUES      
  (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);          
END    

ELSE
 BEGIN
	SELECT WD.WorkItemDetailsId,WT.WorkTypeMapId,WD.WorkItem_Id,WT.WorkTypeId,WD.Linked_ParentID AS Parent1,
	ISNULL(WD.WorkItemDetailsId,0) AS Parent1ID,
	WD1.Linked_ParentID AS Parent2,
	ISNULL(WD1.WorkItemDetailsId,0)  AS Parent2ID,
	WD2.Linked_ParentID AS Parent3,
	ISNULL(WD2.WorkItemDetailsId,0)  AS Parent3ID,
	NULL AS IDsWithApplication,NULL AS IsAppAvailable,
	WD.Project_Id
	INTO #Temp
	FROM ADM.ALM_TRN_WorkItem_Details(NOLOCK) WD
	LEFT JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK) WD1 ON WD.Linked_ParentID=WD1.WorkItem_Id AND WD.Project_Id =WD1.Project_Id AND WD.Isdeleted = 0 AND WD1.Isdeleted = 0
	LEFT JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK) WD2 ON WD1.Linked_ParentID=WD2.WorkItem_Id AND WD1.Project_Id =WD2.Project_Id AND WD2.Isdeleted = 0
	INNER JOIN [PP].[ALM_MAP_WorkType](NOLOCK) WT ON WD.WorkTypeMapId=WT.WorkTypeMapId AND WT.IsDeleted = 0
	INNER JOIN #WorkItemFilter(NOLOCK) CT ON CT.TicketID = WD.WorkItem_Id AND CT.ProjectID = WD.Project_Id
	ORDER BY WorkTypeId ASC
	
	UPDATE #Temp SET IDsWithApplication=WorkItemDetailsId,IsAppAvailable=1 WHERE WorkTypeId=1
	UPDATE #Temp SET IDsWithApplication=Parent1ID,IsAppAvailable=1 WHERE WorkTypeId=2

	UPDATE WT SET WT.IsAppAvailable=1,IDsWithApplication=WT.Parent1ID
	FROM #Temp WT
	INNER JOIN ADM.ALM_TRN_WorkItem_ApplicationMapping(NOLOCK) WA ON WT.Parent1ID=WA.WorkItemDetailsId AND WA.Isdeleted = 0
	WHERE WT.WorkTypeId NOT IN(1,2) AND ISNULL(WT.IsAppAvailable,0) !=1 
	
	UPDATE WT SET WT.IsAppAvailable=1,IDsWithApplication=WT.Parent2ID
	FROM #Temp WT
	INNER JOIN ADM.ALM_TRN_WorkItem_ApplicationMapping(NOLOCK) WA ON WT.Parent2ID=WA.WorkItemDetailsId AND WA.IsDeleted = 0 
	WHERE WT.WorkTypeId NOT IN(1,2) AND ISNULL(WT.IsAppAvailable,0) !=1


	SELECT  DISTINCT GW.ProjectId,TP.WorkItemDetailsId,TP.WorkItem_Id,WorkTypeId,AMAP.Application_Id as ApplicationID,GW.IsEffortTracking
	INTO #TempWorkItem
	from #Temp TP (NOLOCK)
	join ADM.ALM_TRN_WorkItem_ApplicationMapping AMAP ON
	AMAP.WorkItemDetailsId = TP.IDsWithApplication
	JOIN ADM.ALMApplicationDetails(NOLOCK) AAD ON
	AAD.ApplicationID = AMAP.Application_Id AND AAD.Isdeleted = 0
	join [PP].[ALM_MAP_GenericWorkItemConfig] (NOLOCK) GW 
	ON GW.ProjectId = TP.Project_Id AND AAD.ExecutionMethod = GW.ExecutionId AND TP.WorkTypeId = GW.WorkItemTypeId
	AND GW.Isdeleted = 0


    SELECT DISTINCT      
    B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
    ,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
    ,B.CognizantID AS CognizantID      
    ,@efforttrackforworkitem AS Remarks      
    ,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,B.[Type]  
    INTO #TempForWorkitemtypeALM
    FROM        
    #WorkItemFilter IT  (NOLOCK)  
    INNER JOIN  #TempWorkItem TW (NOLOCK)  
    ON IT.TicketID = TW.WorkItem_Id AND IT.ProjectId = TW.ProjectId
    RIGHT JOIN #WorkItemFilter B ON IT.ID = B.ID AND IT.ProjectID=B.ProjectID 
    WHERE TW.IsEffortTracking = 0

    MERGE @ErrorTable AS EUP      
    USING #TempForWorkitemtypeALM as tmp      
    ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
    WHEN MATCHED THEN      
    UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
    WHEN NOT MATCHED THEN      
    INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
    VALUES      
    (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);        
    END
    
    
-- 3 Service Validation  FOR WORKITEM     
SELECT DISTINCT      
B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
,B.CognizantID AS CognizantID      
,@ServiceNotConfiguredProject AS Remarks      
,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,B.[Type]      
INTO #TempForInactiveServiceWORKITEM      
 FROM        
#WorkItemFilter IT       
INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM  (NOLOCK)      
ON SAM.ServiceName=IT.ServiceName       
INNER JOIN AVL.TK_MAS_Service SA (NOLOCK)    
ON SA.ServiceID = SAM.ServiceID AND SA.ScopeID IN (1,3)      
INNER JOIN  AVL.TK_PRJ_ProjectServiceActivityMapping PSAM  (NOLOCK)     
ON SAM.ServiceMappingID=PSAM.ServiceMapID      
AND PSAM.ProjectID=IT.ProjectID       
AND SAM.IsDeleted=0 AND PSAM.IsDeleted=0    AND PSAM.ProjectID=@ProjectID    
RIGHT JOIN #WorkItemFilter B ON IT.ID = B.ID AND IT.ProjectID=B.ProjectID       
WHERE IT.ID IS NULL     
      
MERGE @ErrorTable AS EUP      
      
USING #TempForInactiveServiceWORKITEM as tmp      
      
ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
WHEN MATCHED THEN      
UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
 WHEN NOT MATCHED THEN      
      
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);      
       
-- Service name for the effectivdate chek     
    
select     
ServProjMapID    
,ServiceMapID    
,ProjectID    
,IsDeleted    
,CreatedDateTime    
,CreatedBY    
,ModifiedDateTime    
,ModifiedBY    
,IsHidden    
,ISNULL(EffectiveDate,GETDATE()) AS EffectiveDate    
,IsMainspringData    
INTO #EffectiveService    
from AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) where ProjectID = @Projectid    
    
    
SELECT DISTINCT      
B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
,B.CognizantID AS CognizantID      
,@ServiceEffectivedate AS Remarks      
,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,B.[Type]    
INTO #TempForInactiveServiceticketdatecheck     
 FROM        
#TicketFilter B    
INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM  (NOLOCK)      
ON SAM.ServiceName=B.ServiceName  and SAM.ActivityName = B.ActivityName    
INNER JOIN AVL.TK_MAS_Service SA (NOLOCK)    
ON SA.ServiceID = SAM.ServiceID    
INNER JOIN  #EffectiveService  PSAM  (NOLOCK)     
ON SAM.ServiceMappingID=PSAM.ServiceMapID and PSAM.ProjectID = @Projectid and convert(date,EffectiveDate) <  convert(date,B.TimeSheetDate)    
    
      
MERGE @ErrorTable AS EUP      
      
USING #TempForInactiveServiceticketdatecheck as tmp      
      
ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
WHEN MATCHED THEN      
UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
 WHEN NOT MATCHED THEN      
      
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);      
        
      
------ Service name for the effectivdatecheck for work item    
    
     
SELECT DISTINCT      
B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
,B.CognizantID AS CognizantID      
,@ServiceEffectivedate AS Remarks      
,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,B.[Type]      
INTO #TempForInactiveServiceticketdatecheckworkitem     
 FROM        
#WorkItemFilter B       
INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM  (NOLOCK)      
ON SAM.ServiceName=B.ServiceName  and SAM.ActivityName = B.ActivityName    
INNER JOIN AVL.TK_MAS_Service SA (NOLOCK)    
ON SA.ServiceID = SAM.ServiceID    
INNER JOIN  #EffectiveService  PSAM  (NOLOCK)     
ON SAM.ServiceMappingID=PSAM.ServiceMapID and PSAM.ProjectID = @Projectid and convert(date,EffectiveDate) <  convert(date,B.TimeSheetDate)    
    
      
MERGE @ErrorTable AS EUP      
      
USING #TempForInactiveServiceticketdatecheckworkitem as tmp      
      
ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
WHEN MATCHED THEN      
UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
 WHEN NOT MATCHED THEN      
      
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);      
        
        
    
    
-- 4. Ticket Type Service Mapping      
SELECT       
DISTINCT   B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
,B.CognizantID AS CognizantID      
,@TicketTypeServiceNotConfig AS Remarks      
,B.ProjectID as 'ProjectID',B.IsCognizant AS IsCognizant,b.[Type]      
INTO #TempForInactiveTicketType      
 FROM        
#TicketFilter IT       
INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM  (NOLOCK)      
ON SAM.ServiceName=IT.ServiceName      
INNER JOIN  AVL.TK_PRJ_ProjectServiceActivityMapping PSAM  (NOLOCK)       
ON SAM.ServiceMappingID=PSAM.ServiceMapID      
AND PSAM.ProjectID=IT.ProjectID       
AND SAM.IsDeleted=0 AND PSAM.IsDeleted=0      
INNER JOIN AVL.TK_MAP_TicketTypeServiceMapping TTSM  (NOLOCK)  ON      
TTSM.ServiceID=SAM.ServiceID AND TTSM.ProjectID=PSAM.ProjectID  AND IT.ProjectID=IT.ProjectID      
AND IT.TicketType=TTSM.TicketTypeMappingID and TTSM.IsDeleted=0      
RIGHT JOIN #TicketFilter B ON B.ID=IT.ID AND IT.ProjectID=B.ProjectID      
where it.ID is NULL      
      
SELECT DISTINCT ServiceID,ServiceName INTO #ServiceList     
FROM AVL.TK_MAS_ServiceActivityMapping WHERE ISNULL(IsDeleted,0)=0    
      
MERGE @ErrorTable AS EUP      
      
USING #TempForInactiveTicketType as tmp      
      
ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
WHEN MATCHED THEN      
UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
 WHEN NOT MATCHED THEN      
      
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
VALUES      
(tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);      
      
 SELECT DISTINCT IT.ID AS InputRecord, IT.TicketID,IT.TicketType,IT.ServiceName,IT.ActivityName,IT.Hours,IT.CognizantID,IT.TimeSheetDate      
 ,IT.ProjectID,@GracePeriodMessageCog AS Remarks,IT.IsCognizant,IT.[Type]     
 INTO #GracePeriodMetTickets    
 FROM #InputTable IT     
 INNER JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON IT.ProjectID=TD.ProjectID  AND IT.TicketID=TD.TicketID AND  TD.IsDeleted=0      
 INNER JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDB ON IT.ProjectID=PDB.ProjectID     
 INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PDB.ProjectID=PM.ProjectID AND ISNULL(PM.IsDebtEnabled,'N')='Y' AND IT.ProjectID=@Projectid    
 LEFT JOIN #ServiceList MAS ON TD.ServiceID=MAS.ServiceID     
 WHERE (TD.DARTStatusID = 8 AND TD.Closeddate IS NOT NULL AND GETDATE() > (ISNULL(PDB.GracePeriod,365) +TD.Closeddate)    
 OR    
 (TD.DARTStatusID = 9 AND TD.CompletedDateTime IS NOT NULL AND GETDATE() > (ISNULL(PDB.GracePeriod,365) +TD.CompletedDateTime)    
 )) AND IT.ServiceName != MAS.ServiceName AND ISNULL(TD.ServiceID,0) != 0 AND IT.[Type] in ('T','ND')    
     
 MERGE @ErrorTable AS EUP      
 USING #GracePeriodMetTickets as tmp      
 ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
 WHEN MATCHED THEN      
 UPDATE SET EUP.Remarks = EUP.Remarks +','+TMP.Remarks      
 WHEN NOT MATCHED THEN      
 INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,    
 tmp.ProjectID,@GracePeriodMessageCog,tmp.IsCognizant,tmp.[Type]);      
    
    
---------AH Met Tickets----------    
SELECT DISTINCT IT.ID AS InputRecord, IT.TicketID,IT.TicketType,IT.ServiceName,IT.ActivityName,IT.[Hours],IT.CognizantID,IT.TimeSheetDate      
,IT.ProjectID,@AHMessageCog AS Remarks,IT.IsCognizant,IT.[Type]     
INTO #AHTicketRejectionCog    
FROM #InputTable IT     
INNER JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON IT.ProjectID=TD.ProjectID  AND IT.TicketID=TD.TicketID AND TD.IsDeleted=0    
INNER JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic(nolock) HPP on TD.ProjectID=HPP.ProjectID  
INNER JOIN AVL.DEBT_TRN_HealTicketDetails(nolock) HTD on HPP.ProjectPatternMapID=HTD.ProjectPatternMapID   
INNER JOIN AVL.DEBT_PRJ_HealParentChild(NOLOCK) HPD ON HTD.ProjectPatternMapID=HPD.ProjectPatternMapID --TD.ProjectID=HPD.ProjectID    
AND TD.TicketID=HPD.DARTTicketID AND HPD.MapStatus=1 -- HPD.MapStatus='Active'   
AND ISNULL(HPD.IsDeleted,0)!=1 AND HTD.HealingTicketID!=CONVERT(NVARCHAR,0) -- HPD.HealingTicketID!=CONVERT(NVARCHAR,0)  
  
  
  
LEFT JOIN #ServiceList MAS ON TD.ServiceID=MAS.ServiceID     
WHERE ((TD.DARTStatusID=8 AND TD.Closeddate IS NOT NULL) OR (TD.DARTStatusID=9 AND TD.CompletedDateTime IS NOT NULL))    
AND IT.ServiceName != MAS.ServiceName AND ISNULL(TD.ServiceID,0) != 0 AND IT.[Type] in ('T','ND')    
     
MERGE @ErrorTable AS EUP    
USING #AHTicketRejectionCog AS AH    
ON AH.InputRecord=EUP.InputRecordID AND AH.ProjectID=EUP.ProjectID     
WHEN MATCHED THEN     
UPDATE SET EUP.Remarks=EUP.Remarks+','+AH.Remarks    
WHEN NOT MATCHED THEN    
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 VALUES      
 (AH.InputRecord,AH.TicketID,AH.TicketType,AH.ServiceName,AH.ActivityName,AH.Hours,AH.CognizantID,AH.TimeSheetDate,    
 AH.ProjectID,@AHMessageCog,AH.IsCognizant,AH.[Type]);     
    
    
END     
    
if(@IsEffortTrackActivityWise=1)      
BEGIN      
---ActivityName-------------------    
SELECT       
DISTINCT  B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
,B.CognizantID AS CognizantID    
,@ActivityNotConfigForService AS Remarks      
,B.ProjectID as 'ProjectID',B.IsCognizant as IsCognizant,B.[Type]     
INTO #TempForInactiveActivity      
 FROM        
#InputTable IT       
INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM  (NOLOCK)      
ON SAM.ServiceName=IT.ServiceName AND SAM.ActivityName=IT.ActivityName       
INNER JOIN  AVL.TK_PRJ_ProjectServiceActivityMapping PSAM  (NOLOCK)       
ON SAM.ServiceMappingID=PSAM.ServiceMapID        
AND PSAM.ProjectID=IT.ProjectID       
AND SAM.IsDeleted=0 AND PSAM.IsDeleted=0   
RIGHT JOIN #InputTable B ON B.ID=IT.ID AND IT.ProjectID=B.ProjectID      
where IT.ID IS NULL  AND B.TicketID != 'NONDELIVERY'  and b.IsCognizant = 1   
--new code  
AND (B.[Type] = 'T' OR B.[Type] = 'W')  
  
  
      
      
MERGE @ErrorTable AS EUP      
      
USING #TempForInactiveActivity as tmp      
      
ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
   
WHEN MATCHED THEN      
UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
 WHEN NOT MATCHED THEN      
      
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);      
 --SELECT * from @ErrorTable      
      
      
END      
---TicketType Mapping for customer      
IF(@Iscognizant=0)      
BEGIN    
select     
ID      
,TicketID     
,TrackID     
,ServiceName      
,ActivityName     
,SuggestedActivity     
,Remarks     
,TicketType       
,Hours     
,CognizantID     
,IsCognizant     
,TimeSheetDate    
,ProjectID     
,WeekNumber    
,ServiceID     
,ActivityID    
,IsDeleted     
,[Type]    
INTO #nonTicket    
FROM #InputTable where TicketID != 'NONDELIVERY'    
    
    
SELECT       
DISTINCT   B.ID as 'InputRecord',B.TicketID as TicketID,B.TicketType AS TicketType      
,B.ServiceName AS ServiceName,B.ActivityName AS ActivityName,B.Hours AS Hours,B.TimeSheetDate AS TimeSheetDate      
,B.CognizantID AS CognizantID      
,@TicketTypeForCustomer AS Remarks      
,B.ProjectID as 'ProjectID',B.IsCognizant AS IsCognizant, B.[Type]      
INTO #TempForInactiveTicketTypeCust      
 FROM        
#nonTicket IT       
JOIN AVL.TK_MAP_TicketTypeMapping TM  (NOLOCK)  ON cast(TM.TicketTypeMappingID as NVARCHAR(max))=IT.TicketType  AND IT.ProjectID=TM.ProjectID       
RIGHT JOIN #nonTicket B ON B.ID=IT.ID       
WHERE IT.ID IS NULL     
      
      
MERGE @ErrorTable AS EUP      
      
USING #TempForInactiveTicketTypeCust as tmp      
      
ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID       
      
WHEN MATCHED THEN      
UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
 WHEN NOT MATCHED THEN      
      
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,tmp.[Type]);      
     
  --Grace Period Scenario for Customer Projects    
  SELECT DISTINCT IT.ID AS InputRecord, IT.TicketID,IT.TicketType,IT.ServiceName,IT.ActivityName,IT.Hours,IT.CognizantID,IT.TimeSheetDate      
 ,IT.ProjectID,@GracePeriodMessageCus AS Remarks,IT.IsCognizant,IT.[Type]    
 INTO #GracePeriodMetTicketsCustomer    
 FROM #InputTable IT     
 INNER JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON IT.ProjectID=TD.ProjectID AND IT.TicketID=TD.TicketID AND     
 ISNULL(TD.IsDeleted,0)=0      
 INNER JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDB ON IT.ProjectID=PDB.ProjectID     
 INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PDB.ProjectID=PM.ProjectID AND ISNULL(PM.IsDebtEnabled,'N')='Y'    
 INNER JOIN AVL.TK_MAP_TicketTypeMapping (NOLOCK) TM   ON IT.ProjectID=TM.ProjectID    
 AND IT.TicketType=CAST(TM.TicketTypeMappingID AS VARCHAR(MAX))    
 WHERE (TD.DARTStatusID = 8 AND TD.Closeddate IS NOT NULL AND GETDATE() > (ISNULL(PDB.GracePeriod,365) +TD.Closeddate)    
 OR    
 (TD.DARTStatusID = 9 AND TD.CompletedDateTime IS NOT NULL AND GETDATE() > (ISNULL(PDB.GracePeriod,365) +TD.CompletedDateTime)    
 )) AND CAST(TD.TicketTypeMapID AS VARCHAR(MAX)) != IT.TicketType AND ISNULL(TD.TicketTypeMapID,0) != 0  AND IT.[Type] in ('T','ND')    
     
 MERGE @ErrorTable AS EUP      
 USING #GracePeriodMetTicketsCustomer as tmp      
 ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
 WHEN MATCHED THEN      
 UPDATE SET EUP.Remarks = EUP.Remarks +','+TMP.Remarks      
 WHEN NOT MATCHED THEN      
 INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,    
 tmp.ProjectID,@GracePeriodMessageCus,tmp.IsCognizant,[Type]);    
    
---------AH Met Tickets-----------    
SELECT DISTINCT IT.ID AS InputRecord, IT.TicketID,IT.TicketType,IT.ServiceName,IT.ActivityName,IT.[Hours],IT.CognizantID,IT.TimeSheetDate      
,IT.ProjectID,@AHMessageCus AS Remarks,IT.IsCognizant,IT.[Type]     
INTO #AHTicketRejectionCus    
FROM #InputTable IT     
INNER JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON IT.ProjectID=TD.ProjectID  AND IT.TicketID=TD.TicketID AND TD.IsDeleted=0    
INNER JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic(nolock) HPP on TD.ProjectID=HPP.ProjectID  
INNER JOIN AVL.DEBT_TRN_HealTicketDetails(nolock) HTD on HPP.ProjectPatternMapID=HTD.ProjectPatternMapID   
INNER JOIN AVL.DEBT_PRJ_HealParentChild(NOLOCK) HPD ON  HTD.ProjectPatternMapID=HPD.ProjectPatternMapID  --TD.ProjectID=HPD.ProjectID    
AND TD.TicketID=HPD.DARTTicketID AND HPD.MapStatus=1  --'Active'   
AND ISNULL(HPD.IsDeleted,0)!=1 AND  HTD.HealingTicketID!='0'   --HPD.HealingTicketID!='0'    
INNER JOIN AVL.TK_MAP_TicketTypeMapping (NOLOCK) TM   ON IT.ProjectID=TM.ProjectID     
AND IT.TicketType=CAST(TM.TicketTypeMappingID AS VARCHAR(MAX))    
WHERE ((TD.DARTStatusID=8 AND TD.Closeddate IS NOT NULL) OR (TD.DARTStatusID=9 AND TD.CompletedDateTime IS NOT NULL))    
AND CAST(TD.TicketTypeMapID AS VARCHAR(MAX))!= IT.TicketType AND ISNULL(TD.TicketTypeMapID,0) != 0  AND IT.[Type] in ('T','ND')    
     
MERGE @ErrorTable AS EUP    
USING #AHTicketRejectionCus AS AH    
ON AH.InputRecord=EUP.InputRecordID AND AH.ProjectID=EUP.ProjectID     
WHEN MATCHED THEN     
UPDATE SET EUP.Remarks=EUP.Remarks+','+AH.Remarks    
WHEN NOT MATCHED THEN    
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
 VALUES      
 (AH.InputRecord,AH.TicketID,AH.TicketType,AH.ServiceName,AH.ActivityName,AH.Hours,AH.CognizantID,AH.TimeSheetDate,    
 AH.ProjectID,@AHMessageCus,AH.IsCognizant,AH.[Type]);     
    
     
     
 END      
       
SELECT DISTINCT LM.EmployeeID as CognizantID,TS.TimesheetDate ,TSD.Hours AS [Hours],TicketID AS TicketID     
INTO #TimesheetDetailsTemp     
FROM AVL.TM_TRN_TimesheetDetail TSD(NOLOCK)      
INNER JOIN AVL.TM_PRJ_Timesheet TS(NOLOCK) ON TSD.TimesheetId=TS.TimesheetId       
INNER JOIN AVL.MAS_LoginMaster LM(NOLOCK) ON LM.CustomerID = TS.CustomerID and LM.UserID = TS.SubmitterId      
INNER JOIN (SELECT DISTINCT CognizantID,TimeSheetDate ,ProjectID FROM #InputTable) IT ON TRIM(IT.CognizantID) = TRIM(LM.EmployeeID)     
 AND IT.TimeSheetDate=TS.TimesheetDate and LM.CustomerID=@CustomerID     
    
SELECT DISTINCT  IT.ID as 'InputRecord',IT.TicketID as TicketID,IT.TicketType AS TicketType      
,IT.ServiceName AS ServiceName,IT.ActivityName AS ActivityName,IT.Hours AS Hours,IT.TimeSheetDate AS TimeSheetDate      
,IT.CognizantID AS CognizantID      
,@TSHours AS Remarks      
,IT.ProjectID as 'ProjectID',IT.IsCognizant as IsCognizant,IT.[Type]      
INTO #TempForInactiveTS     
FROM #InputTable IT      
INNER JOIN      
(      
 SELECT A.CognizantID,A.TimesheetDate,SUM(A.Hours) Hours FROM       
 (      
SELECT CognizantID,TimesheetDate ,SUM(TSD.Hours) Hours FROM #TimesheetDetailsTemp TSD    
WHERE TSD.TicketID NOT IN  (SELECT DISTINCT TicketID FROM #InputTable where TicketID != 'NONDELIVERY')    
GROUP BY CognizantID,TSD.TimesheetDate      
UNION      
SELECT ITR.CognizantID,ITR.TimeSheetDate,SUM(case when itr.ID is NOT NULL THEN ITR.Hours else 0 END) Hours FROM #InputTable ITR LEFT JOIN @ErrorTable ET ON       
ET.InputRecordID=ITR.ID       
GROUP BY ITR.CognizantID,ITR.TimeSheetDate      
      
)A      
GROUP BY A.CognizantID,A.TimesheetDate      
HAVING SUM(A.Hours)>24      
) AS InvalidHoursTable      
On IT.CognizantID=InvalidHoursTable.CognizantID      
AND IT.TimeSheetDate=InvalidHoursTable.TimesheetDate      
      
    
    
     
MERGE @ErrorTable AS EUP      
      
USING #TempForInactiveTS as tmp      
      
ON tmp.InputRecord = EUP.InputRecordID and tmp.ProjectID = EUP.ProjectID      
      
WHEN MATCHED THEN      
UPDATE SET EUP.Remarks = EUP.Remarks+','+tmp.Remarks      
         
         
 WHEN NOT MATCHED THEN      
      
INSERT (InputRecordID,TicketID,TicketType,ServiceName,ActivityName,Hours,CognizantID,TimeSheetDate,ProjectID,Remarks,IsCognizant,[Type])      
VALUES      
 (tmp.InputRecord,tmp.TicketID,tmp.TicketType,tmp.ServiceName,tmp.ActivityName,tmp.Hours,tmp.CognizantID,tmp.TimeSheetDate,tmp.ProjectID,tmp.Remarks,tmp.IsCognizant,[Type]);      
      
 SELECT * FROM @ErrorTable     
 if(@IsEffortTrackActivityWise=1)      
 BEGIN      
 UPDATE IT set IT.ServiceID=SA.ServiceID,IT.ActivityID=  SA.ActivityID  from #InputTable IT       
 JOIN AVL.TK_MAS_ServiceActivityMapping SA (NOLOCK)  ON IT.ServiceName=SA.ServiceName AND  IT.ActivityName=SA.ActivityName       
 AND SA.IsDeleted=0      
 JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSA (NOLOCK)  ON PSA.ServiceMapID=SA.ServiceMappingID AND PSA.IsDeleted=0 AND IT.ProjectID=PSA.ProjectID      
  LEFT JOIN @ErrorTable ET ON ET.InputRecordID=IT.ID       
 WHERE ET.InputRecordID IS NULL   and IT.IsCognizant = 1   
 END      
ELSE      
BEGIN      
 UPDATE IT set IT.ServiceID=SA.ServiceID,IT.ActivityID= 0 from #InputTable IT       
 JOIN AVL.TK_MAS_ServiceActivityMapping SA (NOLOCK) ON IT.ServiceName=SA.ServiceName       
 AND SA.IsDeleted=0      
 JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSA  (NOLOCK) ON PSA.ServiceMapID=SA.ServiceMappingID AND PSA.IsDeleted=0 AND IT.ProjectID=PSA.ProjectID      
  LEFT JOIN @ErrorTable ET ON ET.InputRecordID=IT.ID       
 WHERE ET.InputRecordID IS NULL       
END      
   --Task Id generation  
IF(@Iscognizant = 1)  
   BEGIN  
    UPDATE IT set IT.ServiceID=0,IT.ActivityID=  SA.InfraTransactionTaskID    
 FROM #InputTable IT       
 JOIN #TaskTemp SA (NOLOCK)  ON IT.ActivityName=SA.InfraTaskName AND  IT.ProjectID=SA.ProjectID         
 LEFT JOIN @ErrorTable ET ON ET.InputRecordID=IT.ID       
 WHERE ET.InputRecordID IS NULL   and IT.IsCognizant = 1  AND IT.Type = 'I'   
 END  
    
 UPDATE IT set IT.IsDeleted=1 from #InputTable IT       
 LEFT JOIN @ErrorTable ET ON ET.InputRecordID=IT.ID       
 WHERE ET.InputRecordID IS NOT NULL      
    
    
SELECT * FROM #InputTable     
DECLARE @tvpForBulkInsert  [AVL].[TVP_SaveTimesheetDetails]      
      
      
 CREATE  TABLE #TickerSession_forTimesheer (      
       [SessionID] [bigint] IDENTITY(1,1) NOT NULL,      
       [UserID] [bigint] NULL,      
       [ProjectID] [bigint] NULL,      
       [TicketID] [nvarchar](100) NULL,     
       [TicketDesc] [nvarchar](max) NULL,      
       [TicketOpenDate] [datetime] NULL,      
       [ApplicationID] [bigint] NULL,      
       [ServiceID] [int] NULL,      
       [ActivityID] [int] NULL,      
       [TicketTypeMapID] [bigint] NULL,      
       [PriorityMapID] [bigint] NULL,      
       [TicketStatusMapID] [bigint] NULL,      
   [StartTime] [datetime] NULL,      
       [EndTime] [datetime] NULL,      
       [IsAuto] [bit] NULL,      
       [Hours] [int] NULL,      
       [Minutes] [int] NULL,      
       [Seconds] [int] NULL,      
       [IsProcessed] [int] NULL,      
       [EmployeeID] [nvarchar](50) NULL,      
       [RequestSource] [int] NULL,      
       [IsSDTicket] [bit] NULL,      
       [IsNonDelivery] [bit] NULL,      
       [NonDeliveryActivityType] [int] NULL,      
       [IsDeleted] [bit] NULL,      
       [CreatedOn] [datetime] NULL,      
       [CreatedBy] [nvarchar](50) NULL,      
       [ModifiedOn] [datetime] NULL,      
       [ModifiedBy] [nvarchar](50) NULL,      
       [TimeTickerID] [bigint] NULL,      
       [IsRunning] [bit] NULL,      
       [NonTicketDescription] [nvarchar](250) NULL,      
       [UserCreatedTimeDate] [datetime] NULL,      
       [Efforts] [decimal](7, 4) NULL,    
    [SuggestedActivity] [nvarchar](50) NULL,    
    [Remarks] [nvarchar](max) NULL,    
    [Type] [nvarchar](10) NULL    
)      
      
--EXEC AVL_InsertError '[dbo].[EffortBulkValidation] ', '#TickerSession_forTimesheer', 0,0      
      
       INSERT INTO #TickerSession_forTimesheer(UserID,ProjectID,TicketID,TicketDesc,TicketOpenDate,ApplicationID,ServiceID,ActivityID      
,TicketTypeMapID,PriorityMapID,TicketStatusMapID,EmployeeID,IsSDTicket,IsDeleted,TimeTickerID,Efforts,[CreatedOn],[UserCreatedTimeDate],SuggestedActivity,Remarks,[Type])      
       SELECT LM.UserID,ITR.ProjectID,ITR.TicketID,TD.TicketDescription,TD.OpenDateTime,      
TD.ApplicationID,ITR.ServiceID,ITR.ActivityID,ITR.TicketType,TD.PriorityMapID,TD.TicketStatusMapID,      
    ITR.CognizantID,TD.IsSDTicket,ITR.IsDeleted,TD.TimeTickerID,ITR.Hours,GETDATE(),ITR.TimeSheetDate,SuggestedActivity,ITR.Remarks,ITR.[Type]      
       from #InputTable ITR JOIN       
       AVL.TK_TRN_TicketDetail TD ON ITR.TicketID=TD.TicketID AND ITR.ProjectID=TD.ProjectID      
       AND TD.IsDeleted=0 AND ITR.IsDeleted=0      
       JOIN AVL.MAS_LoginMaster LM ON TRIM(LM.EmployeeID)=TRIM(ITR.CognizantID) AND ITR.ProjectID=LM.ProjectID       
    where  ITR.[Type] = 'T'      
    
    INSERT INTO #TickerSession_forTimesheer(UserID,ProjectID,TicketID,TicketDesc,TicketOpenDate,ApplicationID,ServiceID,ActivityID      
,TicketTypeMapID,PriorityMapID,TicketStatusMapID,EmployeeID,IsSDTicket,IsDeleted,TimeTickerID,Efforts,[CreatedOn],[UserCreatedTimeDate],SuggestedActivity,Remarks,[Type])      
       SELECT LM.UserID,ITR.ProjectID,ITR.TicketID,TD.WorkItem_Description,'' As OpenDateTime,      
null AS ApplicationID,ITR.ServiceID,ITR.ActivityID,ITR.TicketType,TD.PriorityMapID,TD.StatusMapId,      
    ITR.CognizantID,0 as IsSDTicket,ITR.IsDeleted,TD.WorkItemDetailsId,ITR.Hours,GETDATE(),ITR.TimeSheetDate,SuggestedActivity,ITR.Remarks,ITR.[Type]    
       from #InputTable ITR JOIN       
       adm.ALM_TRN_WorkItem_Details TD ON ITR.TicketID=TD.WorkItem_Id AND ITR.ProjectID=TD.Project_Id      
       AND TD.IsDeleted=0 AND ITR.IsDeleted=0      
       JOIN AVL.MAS_LoginMaster LM ON TRIM(LM.EmployeeID)=TRIM(ITR.CognizantID) AND ITR.ProjectID=LM.ProjectID       
    where  ITR.[Type] = 'W'    
     
    -- new code  
       INSERT INTO #TickerSession_forTimesheer(UserID,ProjectID,TicketID,TicketDesc,TicketOpenDate,ApplicationID,ServiceID,ActivityID      
    ,TicketTypeMapID,PriorityMapID,TicketStatusMapID,EmployeeID,IsSDTicket,IsDeleted,TimeTickerID,Efforts,[CreatedOn],[UserCreatedTimeDate],SuggestedActivity,Remarks,[Type])      
       SELECT LM.UserID,ITR.ProjectID,ITR.TicketID,TD.TicketDescription,TD.OpenDateTime,      
    TD.TowerID,ITR.ServiceID,ITR.ActivityID,ITR.TicketType,TD.PriorityMapID,TD.TicketStatusMapID,      
    ITR.CognizantID,TD.IsSDTicket,ITR.IsDeleted,TD.TimeTickerID,ITR.Hours,GETDATE(),ITR.TimeSheetDate,SuggestedActivity,ITR.Remarks,ITR.[Type]      
       FROM #InputTable(NOLOCK) ITR JOIN       
       AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD   
    ON ITR.TicketID=TD.TicketID AND ITR.ProjectID=TD.ProjectID      
       AND TD.IsDeleted=0 AND ITR.IsDeleted=0      
       JOIN AVL.MAS_LoginMaster(NOLOCK) LM   
    ON TRIM(LM.EmployeeID)=TRIM(ITR.CognizantID) AND ITR.ProjectID=LM.ProjectID       
    WHERE  ITR.[Type] = 'I'   
       --ends  
    
      
          INSERT INTO #TickerSession_forTimesheer(UserID,ProjectID,TicketID,TicketDesc,TicketOpenDate,ApplicationID,ServiceID,ActivityID      
,TicketTypeMapID,PriorityMapID,TicketStatusMapID,EmployeeID,IsSDTicket,IsNonDelivery,NonDeliveryActivityType,IsDeleted,TimeTickerID,Efforts,[CreatedOn],[UserCreatedTimeDate],SuggestedActivity,Remarks,[Type])      
       SELECT LM.UserID,ITR.ProjectID,ITR.TicketID,'','',--TD.TicketDescription,TD.OpenDateTime,      
'',--TD.ApplicationID,      
ITR.ServiceID,ITR.ActivityID,ITR.TicketType,'','',--TD.PriorityMapID,TD.TicketStatusMapID,      
    ITR.CognizantID,0,1,ITR.ActivityID,ITR.IsDeleted,'',ITR.Hours,GETDATE(),ITR.TimeSheetDate,ITR.SuggestedActivity,ITR.Remarks,ITR.[Type]     
       from #InputTable ITR JOIN       
    AVL.MAS_LoginMaster LM ON TRIM(LM.EmployeeID)=TRIM(ITR.CognizantID) AND ITR.ProjectID=LM.ProjectID       
    where  ITR.TicketID = 'NONDELIVERY' AND ITR.IsDeleted=0      
      
      
  
       INSERT INTO @tvpForBulkInsert(SessionID,UserID,ProjectID,TicketID,TicketDesc,TicketOpenDate,ApplicationID,ServiceID,ActivityID      
,TicketTypeMapID,PriorityMapID,TicketStatusMapID,EmployeeID,IsSDTicket,IsNonDelivery,NonDeliveryActivityType,IsDeleted,TimeTickerID,Efforts,[CreatedOn],[UserCreatedTimeDate],SuggestedActivity,NonTicketDescription,[Type])      
       SELECT SessionID,UserID,ProjectID,TicketID,TicketDesc,TicketOpenDate,ApplicationID,ServiceID,ActivityID      
,TicketTypeMapID,PriorityMapID,TicketStatusMapID,EmployeeID,IsSDTicket,IsNonDelivery,NonDeliveryActivityType,IsDeleted,TimeTickerID,Efforts,[CreatedOn],[UserCreatedTimeDate],SuggestedActivity,Remarks,[Type]      
       FROM #TickerSession_forTimesheer     

exec [AVL].[TimesheetSubmitAuto] @tvpForBulkInsert ,'EffortBulkUpload'          
    
 DROP table #InputTable    
 IF OBJECT_ID('tempdb..#GracePeriodMetTicketsCustomer', 'U') IS NOT NULL    
 BEGIN    
  DROP TABLE #GracePeriodMetTicketsCustomer    
 END    
 IF OBJECT_ID('tempdb..#GracePeriodMetTickets', 'U') IS NOT NULL    
 BEGIN    
  DROP TABLE #GracePeriodMetTickets    
 END    
  
   COMMIT TRAN    
END TRY        
 BEGIN CATCH        
  DECLARE @ErrorMessage VARCHAR(MAX);      
  SET @ErrorMessage = ERROR_MESSAGE()      
  ROLLBACK TRAN      
  EXEC AVL_InsertError '[dbo].[EffortBulkValidation] ', @ErrorMessage, 0,0      
        
 END CATCH        
      
      
END
