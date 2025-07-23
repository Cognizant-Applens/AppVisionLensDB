/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
 
CREATE PROCEDURE [AVL].[Effort_GetEffortWeekWiseChart] --19100 --2495  
 @EmployeeID VARCHAR(100),  
 @Customer bigint = null,  
 @TSSartDate  Date = null,  
 @TSEndDate Date = null  
AS    
BEGIN 
SET NOCOUNT ON;
BEGIN TRY    
 CREATE TABLE #TicketedEffortTemp  
 (  
 TimesheetDate DATE NULL,  
 Effort DECIMAL(5,2) NULL,  
 NonEffort DECIMAL(5,2) NULL  
 )  
 CREATE TABLE #NonTicketedEffortTemp  
 (  
 TimesheetDate DATE NULL,  
 Effort DECIMAL(5,2) NULL,  
 NonEffort DECIMAL(5,2) NULL  
 )  
   
  
 INSERT INTO #TicketedEffortTemp  
 SELECT  PT.TimesheetDate  AS TimesheetDate, SUM(TD.Hours) AS Effort,NULL AS NonEffort   
 FROM AVL.TM_PRJ_Timesheet(NOLOCK) PT  
 INNER JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) TD ON PT.TimesheetId=TD.TimesheetId AND PT.ProjectID = TD.ProjectId AND ISNULL(TD.IsDeleted,0)=0  
 INNER JOIN [AVL].[MAS_LoginMaster](NOLOCK) LM ON PT.SubmitterId=LM.UserID  AND PT.ProjectID = LM.ProjectID AND LM.IsDeleted=0  
 INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0  
 INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=C.CustomerID and PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0   
 WHERE LM.EmployeeID = @EmployeeID AND (TD.IsNonTicket IS NULL OR TD.IsNonTicket = 0)  
  AND TimesheetDate >= @TSSartDate AND TimesheetDate <= @TSEndDate AND LM.CustomerID = @Customer  
 GROUP BY PT.TimesheetDate  
   
 INSERT INTO #TicketedEffortTemp  
 SELECT  PT.TimesheetDate  AS TimesheetDate, SUM(TD.Hours) AS Effort,NULL AS NonEffort   
 FROM AVL.TM_PRJ_Timesheet(NOLOCK) PT  
 INNER JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) TD ON PT.TimesheetId=TD.TimesheetId AND PT.ProjectID = TD.ProjectId  AND ISNULL(TD.IsDeleted,0)=0  
 INNER JOIN [AVL].[MAS_LoginMaster](NOLOCK) LM ON PT.SubmitterId=LM.UserID AND PT.ProjectID = LM.ProjectID and  LM.IsDeleted=0  
 INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0  
 INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=C.CustomerID and PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0  
  
 WHERE LM.EmployeeID = @EmployeeID AND (TD.IsNonTicket IS NULL OR TD.IsNonTicket = 0)  
  AND TimesheetDate >= @TSSartDate AND TimesheetDate <= @TSEndDate AND LM.CustomerID = @Customer  
 GROUP BY PT.TimesheetDate  
  
 INSERT INTO #NonTicketedEffortTemp  
 SELECT  PT.TimesheetDate  AS TimesheetDate,NULL AS Effort ,SUM(TD.Hours) AS NonEffort   
 FROM AVL.TM_PRJ_Timesheet(NOLOCK) PT  
 INNER JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) TD ON PT.TimesheetId=TD.TimesheetId AND PT.ProjectID = TD.ProjectId AND ISNULL(TD.IsDeleted,0)=0  
 INNER JOIN [AVL].[MAS_LoginMaster](NOLOCK) LM ON PT.SubmitterId=LM.UserID AND PT.ProjectID = LM.ProjectID and LM.IsDeleted=0  
 INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0  
 INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=C.CustomerID and PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0  
  
 WHERE LM.EmployeeID = @EmployeeID AND TD.IsNonTicket = 1  
  AND TimesheetDate >= @TSSartDate AND TimesheetDate <= @TSEndDate AND LM.CustomerID = @Customer  
 GROUP BY PT.TimesheetDate  
  
 INSERT INTO #NonTicketedEffortTemp  
 SELECT  PT.TimesheetDate  AS TimesheetDate,NULL AS Effort ,SUM(TD.Hours) AS NonEffort   
 FROM AVL.TM_PRJ_Timesheet(NOLOCK) PT  
 INNER JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) TD ON PT.TimesheetId=TD.TimesheetId AND PT.ProjectID = TD.ProjectId  AND ISNULL(TD.IsDeleted,0)=0  
 INNER JOIN [AVL].[MAS_LoginMaster](NOLOCK) LM ON PT.SubmitterId=LM.UserID AND PT.ProjectID = LM.ProjectID AND LM.IsDeleted=0  
 INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0  
 INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=C.CustomerID and PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0  
   WHERE LM.EmployeeID = @EmployeeID AND TD.IsNonTicket = 1  
  AND TimesheetDate >= @TSSartDate AND TimesheetDate <= @TSEndDate AND LM.CustomerID = @Customer  
 GROUP BY PT.TimesheetDate  
   
 INSERT INTO #TicketedEffortTemp  
 SELECT  PT.TimesheetDate  AS TimesheetDate,SUM(WITD.Hours) AS Effort ,NULL AS NonEffort   
 FROM AVL.TM_PRJ_Timesheet(NOLOCK) PT  
 INNER JOIN [ADM].[TM_TRN_WorkItemTimesheetDetail](NOLOCK) WITD ON PT.TimesheetId=WITD.TimesheetId AND ISNULL(WITD.IsDeleted,0)=0  
 INNER JOIN [AVL].[MAS_LoginMaster](NOLOCK) LM ON PT.SubmitterId=LM.UserID AND PT.ProjectID = LM.ProjectID and LM.IsDeleted=0  
 INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0  
 INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=C.CustomerID and PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0  
  
 WHERE LM.EmployeeID = @EmployeeID AND (WITD.IsNonTicket IS NULL OR WITD.IsNonTicket = 0)  
  AND TimesheetDate >= @TSSartDate AND TimesheetDate <= @TSEndDate AND LM.CustomerID = @Customer  
 GROUP BY PT.TimesheetDate  
  
 INSERT INTO #NonTicketedEffortTemp  
 SELECT  PT.TimesheetDate  AS TimesheetDate,NULL AS Effort ,SUM(WITD.Hours) AS NonEffort   
 FROM AVL.TM_PRJ_Timesheet(NOLOCK) PT  
 INNER JOIN [ADM].[TM_TRN_WorkItemTimesheetDetail](NOLOCK) WITD ON PT.TimesheetId=WITD.TimesheetId AND ISNULL(WITD.IsDeleted,0)=0  
 INNER JOIN [AVL].[MAS_LoginMaster](NOLOCK) LM ON PT.SubmitterId=LM.UserID AND PT.ProjectID = LM.ProjectID and LM.IsDeleted=0  
 INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0  
 INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=C.CustomerID and PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0  
  
 WHERE LM.EmployeeID = @EmployeeID AND  WITD.IsNonTicket = 1  
  AND TimesheetDate >= @TSSartDate AND TimesheetDate <= @TSEndDate AND LM.CustomerID = @Customer  
 GROUP BY PT.TimesheetDate  
  
 select A.TimesheetDate, sum(A.Effort) AS Effort,sum(A.NonEffort) as NonEffort  FROM(  
 select TimesheetDate,SUM(Effort) AS Effort,SUM(NonEffort) AS NonEffort from #TicketedEffortTemp(NOLOCK)  
 group by TimesheetDate  
 UNION  
 select TimesheetDate,SUM(Effort) AS Effort,SUM(NonEffort) AS NonEffort  from #NonTicketedEffortTemp(NOLOCK)  
 group by TimesheetDate  
  ) AS A  
  Group by TimesheetDate  
 order by A.TimesheetDate  
  
 IF OBJECT_ID('tempdb..#TicketedEffortTemp', 'U') IS NOT NULL  
 BEGIN  
  DROP TABLE #TicketedEffortTemp  
 END  
 IF OBJECT_ID('tempdb..#NonTicketedEffortTemp', 'U') IS NOT NULL  
 BEGIN  
  DROP TABLE #NonTicketedEffortTemp  
 END   
  
  
END TRY    
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[Effort_GetEffortWeekWiseChart]', @ErrorMessage, @EmployeeID,0  
    
 END CATCH   
 SET NOCOUNT OFF;
END
