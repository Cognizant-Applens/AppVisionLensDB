/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE proc [AVL].[sp_GetLeadReportees]  --EXEC [AVL].[sp_GetLeadReportees] '694563',7097,'2020-08-07','2020-08-07'  
   @EmployeeId VARCHAR(MAX),                       
   @CustomerId INT,    
 @StartDate DATE,    
 @EndDate DATE    
 AS                           
    BEGIN  
	BEGIN TRY
    SET NOCOUNT ON;    
   DECLARE @MinDate DATE = CONVERT(DATE,@StartDate),    
  @MaxDate DATE = CONVERT(DATE,@EndDate);    
  DECLARE @IsDaily AS BIT = 0;    
  SET @IsDaily = (SELECT IsDaily FROM AVL.CUSTOMER(NOLOCK) WHERE CustomerId = @CustomerId and Isdeleted = 0);
  DECLARE @MandatoryHours DECIMAL(5,2)=8;  
  
  DECLARE @IsCognizant BIT;
SELECT @IsCognizant = ISNULL(IsCognizant,0) 
FROM AVL.Customer WITH (NOLOCK)
WHERE CustomerID = @CustomerId AND IsDeleted = 0  
   
    
	DECLARE @UserIds AS TABLE    
  (    
   UserId VARCHAR(10)    
  )    

  DECLARE @DateValue AS TABLE    
  (    
  DateValue DATE   
     
  )  
  
  ;WITH MYCTE AS
	(
		SELECT CAST(@MinDate AS DATETIME) DATEVALUE
		UNION ALL
		SELECT  DATEVALUE + 1
		FROM    MYCTE   
		WHERE   DATEVALUE + 1 <= @MaxDate
	) 
	INSERT INTO @DateValue(DateValue)
	(SELECT DATEVALUE AS Date FROM MYCTE)


	DECLARE @ReporteeDetailsComputed  AS TABLE    
  (    
  TimesheetDate DATE,
  EmployeeName VARCHAR(250),
  EmployeeId VARCHAR(10), 
  status int,
  statusid int,
  Hours DECIMAL(5,2),
  MandatoryHours DECIMAL(5,2)
  )  
  	DECLARE @ReporteeDetails AS TABLE    
  (    
  TimesheetDate DATE,
  EmployeeName VARCHAR(250),
  EmployeeId VARCHAR(10), 
  status int,
  statusid int,
  Hours DECIMAL(5,2)
  ) 
   declare @DateValue1  as table 
  (    
 TimesheetDate DATE,
  EmployeeName VARCHAR(250),
  EmployeeId VARCHAR(10),
  status int,
  statusid int    
  ) 

  -- INSERT INTO @UserIds    
  --  SELECT DISTINCT(EmployeeID) AS EmployeeId     
  --FROM AVL.MAS_LoginMaster(NOLOCK)   lm  
  --JOIN AVL.PRJ_ConfigurationProgress cp ON lm.ProjectID=cp.ProjectID  
  --WHERE LM.CustomerID=@CustomerId AND (tsapproverid=@EmployeeId OR ((TSApproverID is null or TSApproverID='NULL' OR TSApproverID='') AND HcmSupervisorID=@EmployeeId)) AND lm.IsDeleted=0    
  --AND cp.ScreenID='2' and cp.ITSMScreenId='11' and cp.CompletionPercentage='100' 

     INSERT INTO @UserIds    
    SELECT DISTINCT(EmployeeID) AS EmployeeId     
  FROM AVL.MAS_LoginMaster(NOLOCK)   lm  
 LEFT JOIN AVL.PRJ_ConfigurationProgress (NOLOCK) cp  ON lm.ProjectID=cp.ProjectID  and cp.isdeleted = 0 
  LEFT JOIN PP.ScopeOfWork(NOLOCK) SW   
  ON SW.ProjectID = LM.ProjectID AND ISNULL(SW.IsDeleted,0) = 0  
  LEFT JOIN PP.ProjectAttributeValues(NOLOCK) PAV  
    ON PAV.ProjectID = LM.ProjectID AND PAV.IsDeleted = 0  
  LEFT JOIN PP.ProjectProfilingTileProgress (NOLOCK) PTP  
    ON PTP.ProjectID = LM.ProjectID AND PTP.IsDeleted = 0  
	WHERE LM.CustomerID=@CustomerId AND (tsapproverid=@EmployeeId OR ((TSApproverID is null or TSApproverID='NULL' OR TSApproverID='') AND HcmSupervisorID=@EmployeeId)) AND lm.IsDeleted=0    
  --AND ((cp.ScreenID='2' and cp.ITSMScreenId='11' and cp.CompletionPercentage='100' ) or( PAV.AttributeValueID IN(1,4)   
 --AND PTP.TileID = 5 AND PTP.TileProgressPercentage = 100) )
 AND ((@IsCognizant = 1 AND (cp.ScreenID='2' and cp.ITSMScreenId='11' and cp.CompletionPercentage='100') or( PAV.AttributeValueID IN(1,4)  
 AND PTP.TileID = 5 AND PTP.TileProgressPercentage = 100))
 OR (@IsCognizant = 0 AND cp.ScreenID='2' and cp.ITSMScreenId='10' and cp.CompletionPercentage='100'))




   ;WITH MYCTE AS  
 (  
  SELECT CAST(@MinDate AS DATETIME) DATEVALUE  
  UNION ALL  
  SELECT  DATEVALUE + 1  
  FROM    MYCTE     
  WHERE   DATEVALUE + 1 <= @MaxDate  
 )   
 INSERT INTO @DateValue1(TimesheetDate,EmployeeId)  
 Select Date,u.UserId from(SELECT DATEVALUE AS Date FROM MYCTE)a    
 CROSS JOIN @UserIds u  

 UPDATE DV    
  SET DV.EmployeeName=LM.EmployeeName    
  FROM @DateValue1 DV INNER JOIN AVL.MAS_LoginMaster(NOLOCK) LM    
  ON DV.EmployeeId=LM.EmployeeID  and CustomerID=@CustomerId AND LM.IsDeleted=0


  insert into @ReporteeDetailsComputed (EmployeeId,EmployeeName,TimeSheetDate,status,StatusID,Hours,MandatoryHours)
  select lm.EmployeeID,lm.EmployeeName,a.TimesheetDate,
  --case when (SUM(ISNULL(b.[Hours],0))-ISNULL(LM.MandatoryHours,0))<0 
  --or ISNULL(a.StatusId  ,0)  in('4') then 0 else 1 end as status,
  NULL AS status,
  ISNULL(a.StatusId  ,0) AS StatusId,
  ISNULL(b.[Hours],0) AS Hours,ISNULL(LM.MandatoryHours,0) AS MandatoryHours
  from avl.MAS_LoginMaster(NOLOCK)  lm  
  inner join avl.TM_PRJ_Timesheet(NOLOCK)  a on lm.UserID=a.SubmitterId AND lm.ProjectID = a.ProjectID 
   left join avl.TM_TRN_TimesheetDetail(NOLOCK)  b on a.TimesheetId=b.TimesheetId AND a.ProjectID = b.ProjectId and b.IsDeleted = 0
   where lm.TSApproverID=@EmployeeId and lm.IsDeleted='0' and lm.CustomerID=@CustomerId 
   and a.TimesheetDate in (select DateValue from @DateValue)
  and lm.EmployeeID in(select EmployeeID from @DateValue1) 
   and [Hours]<>'0'

   --group by lm.EmployeeID,lm.EmployeeName,b.Hours
   --,lm.ProjectID,a.TimesheetDate,a.StatusId,b.Hours

    insert into @ReporteeDetailsComputed (EmployeeId,EmployeeName,TimeSheetDate,status,StatusID,Hours,MandatoryHours)
   select lm.EmployeeID,lm.EmployeeName,a.TimesheetDate,NULL AS status,
  --case when (SUM(ISNULL(b.[Hours],0))-ISNULL(LM.MandatoryHours,0))<0 
  --or ISNULL(a.StatusId  ,0)  in('4') then 0 else 1 end as status,
  ISNULL(a.StatusId  ,0)AS StatusId,
  ISNULL(b.[Hours],0) AS Hours,ISNULL(LM.MandatoryHours,0) AS MandatoryHours
  from avl.MAS_LoginMaster(NOLOCK)  lm  
  inner join avl.TM_PRJ_Timesheet(NOLOCK)  a on lm.UserID=a.SubmitterId  AND lm.ProjectID = a.ProjectID  
   left join AVL.TM_TRN_InfraTimesheetDetail(NOLOCK)  b on a.TimesheetId=b.TimesheetId AND a.ProjectID = b.ProjectId and b.IsDeleted = 0
   where lm.TSApproverID=@EmployeeId and lm.IsDeleted='0' and lm.CustomerID=@CustomerId 
   and a.TimesheetDate in (select datevalue from @DateValue)
   and lm.EmployeeID in(select EmployeeID from @DateValue1) and Hours <>'0'
   --group by lm.EmployeeID,lm.EmployeeName
   --,lm.ProjectID,a.TimesheetDate,a.StatusId,b.Hours

       INSERT INTO @ReporteeDetailsComputed (EmployeeId,EmployeeName,TimeSheetDate,status,StatusID,Hours,MandatoryHours)
   SELECT lm.EmployeeID,lm.EmployeeName,a.TimesheetDate,
  --CASE WHEN (SUM(ISNULL(b.[Hours],0))-ISNULL(LM.MandatoryHours,0))<0 
  --or ISNULL(a.StatusId  ,0)  in('4') then 0 else 1 END AS status,
  NULL AS status,
  ISNULL(a.StatusId  ,0) AS StatusId,
  ISNULL(b.[Hours],0) AS Hours,ISNULL(LM.MandatoryHours,0) AS MandatoryHours
  FROM avl.MAS_LoginMaster(NOLOCK)  lm  
  INNER JOIN avl.TM_PRJ_Timesheet(NOLOCK)  a ON lm.UserID=a.SubmitterId   and lm.ProjectID = a.ProjectID
   LEFT JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) b ON a.TimesheetId=b.TimesheetId and b.IsDeleted = 0
   INNER JOIN @DateValue DV ON DV.DateValue=a.TimesheetDate
   INNER JOIN @DateValue1 DV1 ON DV1.EmployeeID=LM.EmployeeID
   WHERE lm.TSApproverID=@EmployeeId and lm.IsDeleted='0' and lm.CustomerID=@CustomerId 
   AND a.TimesheetDate IN (SELECT datevalue FROM @DateValue)
   AND lm.EmployeeID IN(SELECT EmployeeID FROM @DateValue1) AND Hours <>'0'
   --GROUP BY lm.EmployeeID,lm.EmployeeName
   --,lm.ProjectID,a.TimesheetDate,a.StatusId,b.Hours

   INSERT INTO @ReporteeDetails
    (EmployeeId,EmployeeName,TimeSheetDate,status,StatusID)
   SELECT   RD.EmployeeID,RD.EmployeeName
   ,RD.TimesheetDate,
   CASE WHEN (SUM(ISNULL(RD.[Hours],0))-ISNULL(RD.MandatoryHours,0))<0 
  or ISNULL(RD.StatusId  ,0)  in('4') then 0 else 1 END AS Status,StatusID
  FROM @ReporteeDetailsComputed RD
   GROUP BY RD.EmployeeID,RD.EmployeeName
   ,RD.TimesheetDate,RD.StatusId,RD.MandatoryHours

   update a set a.status=b.status from @DateValue1 a 
   join @ReporteeDetails b on a.EmployeeId=b.EmployeeId and a.TimesheetDate=b.TimesheetDate 

   
	update @DateValue1 set status=0 where status is null 

	select TimesheetDate,EmployeeName,EmployeeId,status,statusid into #notdefaulter from @DateValue1 where status='1'
	select TimesheetDate,EmployeeName,EmployeeId,status,statusid into #defaulter from @DateValue1 where status='0'

	delete from #notdefaulter where EmployeeId in (select EmployeeId from #defaulter)

  CREATE TABLE #final  
  (  
  EmployeeID NVARCHAR(50) NULL,  
  EmployeeName NVARCHAR(1000) NULL,  
  IsDefaulter NVARCHAR(10)  
  ) 
  
  IF @IsDaily = 1
  BEGIN 

   insert into #final SELECT DISTINCT EmployeeId,EmployeeName,'false' IsDefaulter FROM #notdefaulter
  insert into #final SELECT DISTINCT EmployeeId,EmployeeName,'true' IsDefaulter FROM #defaulter 
  --where EmployeeId not in(select EmployeeId from @DateValue1 )

  SELECT DISTINCT EmployeeId,EmployeeName,IsDefaulter FROM #final
  end
  else
  begin

 	declare @ReporteeDetailsWeekly as table    
  (    
  TimesheetDate DATE,
  EmployeeName VARCHAR(250),
  EmployeeId VARCHAR(10),
  hours int,
  status int,
  statusid int  
  )  

   insert into @ReporteeDetailsWeekly (EmployeeId,EmployeeName,TimeSheetDate,hours,status,StatusID)
  select lm.EmployeeID,lm.EmployeeName,a.TimesheetDate,SUM(ISNULL(b.[Hours],0)),
  case when (SUM(ISNULL(b.[Hours],0))-ISNULL(LM.MandatoryHours,0))<0 or ISNULL(a.StatusId  ,0)  in('4') then 0 else 1 end as status,
  ISNULL(a.StatusId  ,0) from avl.MAS_LoginMaster(NOLOCK) lm   
   inner join avl.TM_PRJ_Timesheet(NOLOCK) a on lm.UserID=a.SubmitterId and lm.ProjectID = a.ProjectID 
   left join avl.TM_TRN_TimesheetDetail(NOLOCK) b on a.TimesheetId=b.TimesheetId and a.ProjectID = b.ProjectId 
   where lm.TSApproverID=@EmployeeId and lm.IsDeleted='0' and lm.CustomerID=@CustomerId 
   and a.TimesheetDate in (select DateValue from @DateValue)
  and lm.EmployeeID in(select EmployeeID from @DateValue1) 
   and [Hours]<>'0' AND ISNULL(b.IsDeleted,0) =0
   group by lm.EmployeeID,lm.EmployeeName
   ,lm.ProjectID,a.TimesheetDate,a.StatusId,MandatoryHours--,Hours
   

   insert into @ReporteeDetailsWeekly (EmployeeId,EmployeeName,TimeSheetDate,hours,status,StatusID)
   select lm.EmployeeID,lm.EmployeeName,a.TimesheetDate,SUM(ISNULL(b.[Hours],0)),
  case when (SUM(ISNULL(b.[Hours],0))-ISNULL(LM.MandatoryHours,0))<0 or ISNULL(a.StatusId  ,0)  in('4') then 0 else 1 end as status,
  ISNULL(a.StatusId  ,0) from avl.MAS_LoginMaster(NOLOCK) lm   
   inner join avl.TM_PRJ_Timesheet(NOLOCK) a on lm.UserID=a.SubmitterId  and lm.ProjectID = a.ProjectID
   left join AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) b 
   on a.TimesheetId=b.TimesheetId and a.ProjectID = b.ProjectId
   where lm.TSApproverID=@EmployeeId and lm.IsDeleted='0' and lm.CustomerID=@CustomerId 
   and a.TimesheetDate in (select datevalue from @DateValue)
   and lm.EmployeeID in(select EmployeeID from @DateValue1) and Hours <>'0'
   AND ISNULL(b.IsDeleted,0) =0
   group by lm.EmployeeID,lm.EmployeeName
   ,lm.ProjectID,a.TimesheetDate,a.StatusId,MandatoryHours

   
   INSERT INTO @ReporteeDetailsWeekly (EmployeeId,EmployeeName,TimeSheetDate,hours,status,StatusID)
   SELECT lm.EmployeeID,lm.EmployeeName,a.TimesheetDate,SUM(ISNULL(b.[Hours],0)),
  CASE WHEN (SUM(ISNULL(b.[Hours],0))-ISNULL(LM.MandatoryHours,0))<0 or ISNULL(a.StatusId  ,0)  in('4') 
  THEN 0 ELSE 1 END AS status,
  ISNULL(a.StatusId  ,0) FROM AVL.MAS_LoginMaster(NOLOCK) lm  
  INNER JOIN avl.TM_PRJ_Timesheet(NOLOCK) a ON lm.UserID=a.SubmitterId  and lm.ProjectID = a.ProjectID
  INNER JOIN @DateValue DV ON a.TimesheetDate=DV.DateValue
  INNER JOIN @DateValue1 DV1 ON lm.EmployeeID=DV1.EmployeeId
  LEFT JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) b ON a.TimesheetId=b.TimesheetId 
   WHERE lm.TSApproverID=@EmployeeId and lm.IsDeleted='0' AND lm.CustomerID=@CustomerId 
   and Hours <>'0' AND ISNULL(b.IsDeleted,0) =0
   --AND a.TimesheetDate IN (SELECT datevalue FROM @DateValue)
   --AND lm.EmployeeID IN(SELECT EmployeeID FROM @DateValue1) 
   GROUP BY lm.EmployeeID,lm.EmployeeName
   ,lm.ProjectID,a.TimesheetDate,a.StatusId,MandatoryHours


    create table #temp1
   (EmployeeId VARCHAR(10),
   EmployeeName varchar(250),
  hours int,status int)

     create table #temp
   (EmployeeId VARCHAR(10),
    EmployeeName varchar(250),
  hours int,status int)

  insert into #temp1(Employeeid,EmployeeName,hours)
  select EmployeeId,EmployeeName,sum(hours) from @ReporteeDetailsWeekly group by EmployeeId,EmployeeName

  insert into #temp(EmployeeId,EmployeeName,hours)
   select distinct EmployeeID,EmployeeName,MandatoryHours from avl.MAS_LoginMaster(NOLOCK) where EmployeeID in(select EmployeeID from @ReporteeDetailsWeekly) and CustomerID=@CustomerId
   update #temp set hours=(hours*5) from #temp

   --select * from #temp
   --select * from #temp1

   update a set status='1' from #temp1 a join #temp b on a.EmployeeId=b.EmployeeId and a.EmployeeName=b.EmployeeName  where a.hours>=b.hours

  select EmployeeId,EmployeeName,hours,statusid into #temp2 from @ReporteeDetailsWeekly 

  update a set status='0'from #temp1 a join #temp2 b on a.EmployeeId=b.EmployeeId and a.EmployeeName=b.EmployeeName  where b.statusid in(1,4)

   CREATE TABLE #final1  
  (  
  EmployeeID NVARCHAR(50) NULL,  
  EmployeeName NVARCHAR(1000) NULL,  
  IsDefaulter NVARCHAR(10)  
  ) 

   insert into #final1 SELECT DISTINCT EmployeeId,EmployeeName,'false' IsDefaulter FROM #temp1 where status=1
  insert into #final1 SELECT DISTINCT EmployeeId,EmployeeName,'true' IsDefaulter FROM @DateValue1 where EmployeeId not in(select employeeid from #temp1 where status=1)
 
  SELECT DISTINCT EmployeeId,EmployeeName,IsDefaulter FROM #final1

 end
 	IF OBJECT_ID('tempdb..#notdefaulter', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #notdefaulter
	END	
	IF OBJECT_ID('tempdb..#defaulter', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #defaulter
	END
	 	IF OBJECT_ID('tempdb..#final', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #final
	END	
	IF OBJECT_ID('tempdb..#temp1', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #temp1
	END
	IF OBJECT_ID('tempdb..#temp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #temp
	END
SET NOCOUNT OFF;

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[sp_GetLeadReportees]', @ErrorMessage, 0,0
		
	END CATCH  
	end
