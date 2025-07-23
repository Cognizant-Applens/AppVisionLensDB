/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
 CREATE PROCEDURE [AVL].[ApproveUnfreezeBindGrid]     
 @FromDate DATE=null,    
 @ToDate DATE=null,    
 @CustomerId BIGINT=null,  
 @DropDownFlag INT=NULL,  
 @EmployeeIdTVP AVL.TVP_Assigness_GetTimeSheetData READONLY  
 AS    
    
 BEGIN    
 SET NOCOUNT OFF;    
    
   --INSERT INTO [AVL].[TVP_Assigness_GetTimeSheetData] (EmployeeID) (SELECT EmployeeID FROM @Ids) --select *  From [AVL].[TVP_Assigness_GetTimeSheetData]  
    
    IF OBJECT_ID('tempdb..#MAS_LoginMaster', 'U') IS NOT NULL  
  BEGIN  
      DROP TABLE #MAS_LoginMaster  
  END  
       
 IF OBJECT_ID('tempdb..#TM_PRJ_Timesheet', 'U') IS NOT NULL  
 BEGIN  
      DROP TABLE #TM_PRJ_Timesheet  
 END  
  
 IF OBJECT_ID('tempdb..#TM_TRN_TimesheetDetail', 'U') IS NOT NULL  
 BEGIN  
      DROP TABLE #TM_TRN_TimesheetDetail  
 END  
   
 DECLARE @MinDate DATE = CONVERT(DATE,@FromDate),    
   @MaxDate DATE = CONVERT(DATE,@ToDate);  
       
 DECLARE @NotNumber VARCHAR(2) ='NA'  
  
DECLARE @UserIds AS TABLE    
(    
UserId VARCHAR(10),    
EmployeeID  VARCHAR(10)    
)    
 DECLARE @DateValue AS TABLE    
 (    
 DateValue DATE,  
 UserId VARCHAR(10),      
 EmployeeId VARCHAR(10),    
 EmployeeName VARCHAR(250)    
 )    
    
 DECLARE @MAS_TimesheetStatus AS TABLE    
 (    
 TimesheetStatusId INT,    
 TimesheetStatus VARCHAR(100)    
 )    
 /*DECLARE @Ids AS TABLE  
 (  
   EmployeeId VARCHAR(10)  
 )*/  
 DECLARE @TimesheetSummay as TABLE    
 (    
 EmployeeId VARCHAR(50),    
 EmployeeName VARCHAR(250),    
 SubmitterId VARCHAR(50),    
 TotalHours DECIMAL(5,2),   
 RejectionComments VARCHAR(1000)    
 )    
  
  
 DECLARE @TimesheetResultForTimesheetSeperation as TABLE    
  (  
 EmployeeId VARCHAR(50),    
 EmployeeName VARCHAR(250),    
 TimesheetDate DATE,    
 TotalHours DECIMAL(5,2),    
 TimesheetStatusId INT,    
 TimesheetId INT,    
 ProjectId INT    
  )  
    
    
 DECLARE @TimesheetResult as TABLE    
  (  
 EmployeeId VARCHAR(50),    
 EmployeeName VARCHAR(250),    
 TimesheetDate DATE,    
 TotalHours DECIMAL(5,2),    
 TimesheetStatusId INT,    
 TimesheetId INT,    
 ProjectId INT    
  )  
  
 DECLARE @UserTimeSheetStatus AS TABLE    
 (    
 EmployeeId VARCHAR(10),    
 TimesheetCount INT,    
 TimesheetDate DATE    
 )    
  
 /*  
 If(@SubmitterId <> '' AND @SubmitterId IS NOT NULL)  
 BEGIN  
 SET @AssingeeIds=@SubmitterId  
 END  
 ELSE  
 BEGIN  
 SET @AssingeeIds=@DefaulterId  
 END  
 */  
  
 SELECT UserID,TRIM(EmployeeID) AS EmployeeID,EmployeeName,CustomerID,IsDeleted INTO #MAS_LoginMaster FROM AVL.MAS_LoginMaster (NOLOCK) WHERE IsDeleted=0 AND CustomerID=@CustomerId;  
   
 /*INSERT INTO @Ids  
 SELECT Item FROM dbo.Split(@AssingeeIds, ',')  */  
    
 INSERT INTO @UserIds    
 SELECT DISTINCT LM.UserID,LM.EmployeeID   
 from #MAS_LoginMaster(NOLOCK) LM  ----AND EmployeeID IN(SELECT EmployeeId FROM @Ids) AND IsDeleted=0    
 JOIN @EmployeeIdTVP TP ON TP.EmployeeId = LM.EmployeeID  
 where LM.CustomerID=@CustomerId AND LM.IsDeleted=0  
    
    
 /*  
 INSERT INTO @DateValue(DateValue,UserId,EmployeeId)    
 Select Date,u.UserId,u.EmployeeID from(SELECT  TOP (DATEDIFF(DAY, @MinDate, @MaxDate) + 1)    
   Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @MinDate)    
 FROM    sys.all_objects a    
   CROSS JOIN sys.all_objects b)a    
 CROSS JOIN @UserIds u    
 */   
 ;WITH MYCTE AS  
 (  
  SELECT CAST(@MinDate AS DATETIME) DATEVALUE  
  UNION ALL  
  SELECT  DATEVALUE + 1  
  FROM    MYCTE     
  WHERE   DATEVALUE + 1 <= @MaxDate  
 )   
 INSERT INTO @DateValue(DateValue,UserId,EmployeeId)  
 Select Date,u.UserId,u.EmployeeID from(SELECT DATEVALUE AS Date FROM MYCTE)a    
 CROSS JOIN @UserIds u   
   
 SELECT T.TimesheetId,T.SubmitterId,T.TimesheetDate,T.StatusId,T.RejectionComments,  
 T.ProjectID INTO #TM_PRJ_Timesheet   
 FROM AVL.TM_PRJ_Timesheet (NOLOCK) T INNER JOIN #MAS_LoginMaster LM   
 ON LM.UserID=T.SubmitterId INNER JOIN @DateValue DV ON DV.DateValue = T.TimesheetDate AND T.SubmitterId=DV.UserId  
  
 CREATE TABLE #TM_TRN_TimesheetDetail  
 (   
 [TimesheetId] [bigint] NULL,  
 [IsNonTicket] [bit] NULL,    
 [Hours] [decimal](5, 2) NULL,  
 [Remarks] [nvarchar](max) NULL,  
 [ProjectId] [bigint] NULL,  
 [IsDeleted] [bit] NULL   
 )  
  
 --APP  
   
 INSERT INTO #TM_TRN_TimesheetDetail   
 SELECT TD.TimesheetId,TD.IsNonTicket,TD.[Hours],TD.Remarks,  
 TD.ProjectId,TD.IsDeleted FROM [AVL].[TM_TRN_TimesheetDetail](NOLOCK) TD INNER JOIN  
 #TM_PRJ_Timesheet T ON T.TimesheetId=TD.TimesheetId  
  
 --INFRA  
 INSERT INTO #TM_TRN_TimesheetDetail   
 SELECT TD.TimesheetId,TD.IsNonTicket,TD.[Hours],TD.Remarks,  
 TD.ProjectId,TD.IsDeleted FROM AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) TD INNER JOIN  
 #TM_PRJ_Timesheet T ON T.TimesheetId=TD.TimesheetId  
  
 INSERT INTO #TM_TRN_TimesheetDetail   
 SELECT TD.TimesheetId,  
 TD.IsNonTicket,TD.[Hours],TD.Remarks,  
 T.ProjectID,TD.IsDeleted FROM ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) TD INNER JOIN  
 #TM_PRJ_Timesheet T ON T.TimesheetId=TD.TimesheetId  
  
 INSERT INTO @MAS_TimesheetStatus(TimesheetStatusId,TimesheetStatus)    
 SELECT DISTINCT TimesheetStatusId,TimesheetStatus from AVL.MAS_TimesheetStatus (NOLOCK)   
 UNION     
 SELECT 0 as TimesheetStatusId ,@NotNumber as TimesheetStatus    
    
 INSERT INTO @UserTimeSheetStatus    
 (EmployeeId,TimesheetCount,TimesheetDate)    
 SELECT DISTINCT D.EmployeeId,COUNT(T.TimesheetId), D.DateValue FROM @DateValue D    
 LEFT JOIN #MAS_LoginMaster(NOLOCK) L ON L.EmployeeID=D.EmployeeId    
 AND L.CustomerID=@CustomerId AND L.IsDeleted=0    
 LEFT JOIN #TM_PRJ_Timesheet(NOLOCK) T     
 ON       
 T.TimesheetDate=D.DateValue AND T.SubmitterId=L.UserID    
 GROUP BY D.EmployeeId,D.DateValue,d.UserId    
    
 UPDATE DV    
 SET DV.EmployeeName=LM.EmployeeName    
 FROM @DateValue DV INNER JOIN #MAS_LoginMaster LM    
 ON DV.EmployeeId=LM.EmployeeID AND CustomerID=@CustomerId    
    
    
 INSERT INTO @TimesheetSummay    
 SELECT     
 DISTINCT    
 DV.EmployeeId ,    
 DV.EmployeeName,    
 DV.EmployeeId as SubmitterId,    
 ISNULL(sum(TD.Hours),0)'TotalHours',    
 T.RejectionComments     
 FROM @DateValue DV     
 INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON DV.EmployeeId=LM.EmployeeID     
 AND CustomerID=@CustomerId AND LM.IsDeleted=0    
 LEFT JOIN #TM_PRJ_Timesheet (NOLOCK)T ON LM.UserID=T.SubmitterId AND DV.DateValue = T.TimesheetDate  
 AND T.SubmitterId=DV.UserId     
    LEFT JOIN #TM_TRN_TimesheetDetail(NOLOCK) TD ON T.TimesheetId=TD.TimesheetId  AND TD.ISDELETED=0     
  AND CONVERT(DATE,T.TimesheetDate) BETWEEN   CONVERT(DATE,@FromDate) AND CONVERT(DATE,@ToDate)  
 LEFT JOIN AVL.MAS_TimesheetStatus TS ON T.StatusId=TS.TimesheetStatusId    
 AND CONVERT(DATE,T.TimesheetDate) BETWEEN  CONVERT(DATE,@FromDate) AND CONVERT(DATE,@ToDate)  
 INNER JOIN @EmployeeIdTVP EMP ON EMP.EmployeeID = LM.EmployeeID  
 GROUP BY     
 DV.EmployeeId,    
 DV.EmployeeName,    
 T.SubmitterId,    
 T.RejectionComments    
    
    
 -- Logic Here    
    
 INSERT INTO @TimesheetResultForTimesheetSeperation    
 (EmployeeId,EmployeeName,TimesheetDate,TotalHours,TimesheetStatusId,TimesheetId,ProjectId)    
 select DISTINCT     
 DV.EmployeeID,    
 DV.EmployeeName,    
 DV.DateValue AS TimesheetDate,    
 isnull(SUM(TD.Hours),0)'TotalHours',    
 ISNULL(MTS.TimesheetStatusId,'') AS TimesheetStatusId,    
 0 AS TimesheetId,    
 0 AS ProjectId    
 FROM @DateValue DV     
 INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON DV.EmployeeId=LM.EmployeeID    
 AND CustomerID=@CustomerId AND LM.IsDeleted=0    
 INNER JOIN #TM_PRJ_Timesheet(NOLOCK)  T ON LM.UserID=T.SubmitterId  AND DV.DateValue = T.TimesheetDate  
 AND DV.UserId=T.SubmitterId     
  AND CONVERT(DATE,T.TimesheetDate) BETWEEN CONVERT(DATE,@FromDate) AND CONVERT(DATE,@ToDate)  
 INNER JOIN AVL.MAS_TimesheetStatus(NOLOCK)  MTS ON MTS.TimesheetStatusId=T.StatusId    
 INNER JOIN @UserTimeSheetStatus UTS ON UTS.EmployeeId=DV.EmployeeId AND UTS.TimesheetCount>0 AND DV.DateValue=UTS.TimesheetDate    
 LEFT JOIN #TM_TRN_TimesheetDetail(NOLOCK) TD ON T.TimesheetId=TD.TimesheetId   AND TD.ISDELETED=0    
 GROUP BY     
 DV.EmployeeID,    
 DV.EmployeeName,    
 MTS.TimesheetStatusId,    
 DV.DateValue    
  
 UNION ALL     
 select DISTINCT     
 DV.EmployeeID,    
 DV.EmployeeName,    
 DV.DateValue AS TimesheetDate,    
 isnull(SUM(TD.Hours),0)'TotalHours',    
 ISNULL(MTS.TimesheetStatusId,'') AS TimesheetStatusId,    
 0 AS TimesheetId,    
 0 AS ProjectId    
 FROM @DateValue DV     
 INNER JOIN #MAS_LoginMaster(NOLOCK)  LM ON DV.EmployeeId=LM.EmployeeID    
 AND CustomerID=@CustomerId AND LM.IsDeleted=0    
 INNER JOIN @UserTimeSheetStatus UTS ON UTS.EmployeeId=DV.EmployeeId AND UTS.TimesheetCount=0 AND DV.DateValue=UTS.TimesheetDate    
 LEFT JOIN #TM_PRJ_Timesheet(NOLOCK)  T ON LM.UserID=T.SubmitterId  AND DV.DateValue = T.TimesheetDate   
 AND DV.UserId=T.SubmitterId    
 AND CONVERT(DATE,T.TimesheetDate) BETWEEN CONVERT(DATE,@FromDate) AND CONVERT(DATE,@ToDate)    
 LEFT JOIN #TM_TRN_TimesheetDetail(NOLOCK)  TD ON T.TimesheetId=TD.TimesheetId  AND TD.ISDELETED=0    
 LEFT JOIN AVL.MAS_TimesheetStatus(NOLOCK)  MTS ON MTS.TimesheetStatusId=T.StatusId    
 GROUP BY     
 DV.EmployeeID,    
 DV.EmployeeName,    
 MTS.TimesheetStatusId,    
 DV.DateValue    
   
 -- Logic Here    
    
  
  SELECT EmployeeId,EmployeeName,SubmitterId,SUM(TotalHours)  TotalHours,   
 ISNULL(RejectionComments,'') as RejectionComments FROM @TimesheetSummay    
 GROUP BY EmployeeId,EmployeeName,SubmitterId,ISNULL(RejectionComments,'')  
   
    
 INSERT INTO @TimesheetResult    
 (EmployeeId,EmployeeName,TimesheetDate, TotalHours,TimesheetStatusId,TimesheetId,ProjectId)    
 SELECT     
 DISTINCT    
 T.EmployeeId,    
 T.EmployeeName,    
 T.TimesheetDate,    
 SUM(T.TotalHours) TotalHours,    
 SUM(T.TimesheetStatusId) TimesheetStatusId,    
 SUM(TimesheetId) TimesheetId,    
 SUM(ProjectId) ProjectId    
  FROM     
 @TimesheetResultForTimesheetSeperation T    
 INNER JOIN @MAS_TimesheetStatus MTS1 ON MTS1.TimesheetStatusId=T.TimesheetStatusId    
 INNER JOIN @UserTimeSheetStatus UTS ON UTS.EmployeeId=T.EmployeeId    
 AND UTS.TimesheetCount=0 AND UTS.TimesheetDate=T.TimesheetDate    
 GROUP BY T.EmployeeId,    
 T.EmployeeName,    
 T.TimesheetDate    
 UNION ALL    
 SELECT     
 DISTINCT    
 T.EmployeeId,    
 T.EmployeeName,    
 T.TimesheetDate,    
 T.TotalHours,    
 T.TimesheetStatusId,    
 TimesheetId,    
 ProjectId    
  FROM     
 @TimesheetResultForTimesheetSeperation T    
 INNER JOIN @MAS_TimesheetStatus MTS1 ON MTS1.TimesheetStatusId=T.TimesheetStatusId    
 INNER JOIN @UserTimeSheetStatus UTS ON UTS.EmployeeId=T.EmployeeId     
 AND UTS.TimesheetCount>0 AND UTS.TimesheetDate=T.TimesheetDate    
    
   
  IF(@DropDownFlag=1)  
  BEGIN  
 SELECT      
 T.EmployeeId,    
 T.EmployeeName,    
 T.TimesheetDate,    
 T.TotalHours,    
 MTS1.TimesheetStatus,    
 T.TimesheetStatusId,    
 T.TimesheetId,    
 T.ProjectId    
 FROM @TimesheetResult  T INNER JOIN @MAS_TimesheetStatus MTS1 ON MTS1.TimesheetStatusId=T.TimesheetStatusId    
 ORDER BY T.TimesheetDate   
   END   
   ELSE  
   BEGIN  
 SELECT      
 T.EmployeeId,    
 T.EmployeeName,    
 T.TimesheetDate,    
 T.TotalHours,    
 MTS1.TimesheetStatus,    
 T.TimesheetStatusId,    
 T.TimesheetId,    
 T.ProjectId    
 FROM @TimesheetResult  T INNER JOIN @MAS_TimesheetStatus MTS1 ON MTS1.TimesheetStatusId=T.TimesheetStatusId    
 WHERE T.TimesheetStatusId IN(0,1,4)  
 ORDER BY T.TimesheetDate    
   END  
    
END  