

--[AVL].[GetTicketDetailsForApprovalUnfreeze]  7097,'06/03/2020','06/03/2020','674078'
CREATE PROCEDURE [AVL].[GetTicketDetailsForApprovalUnfreeze] 
@CustomerID INT,@FromDate DATE , @ToDate DATE,@SubmitterId VARCHAR(100) ,
@TsApproverId VARCHAR(100)
AS  
BEGIN  
 BEGIN TRANSACTION;  
 BEGIN TRY  
 SET NOCOUNT ON  
  
 SELECT  TD.WorkItemDetailsId ,Linked_ParentID,WorkTypeMapId,WorkItem_Id,Project_Id  
 INTO #WorkItems FROM ADM.TM_TRN_WorkItemTimesheetDetail TD With (NOLOCK)  
  INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK)  TS   ON TD.TimesheetId=TS.TimesheetId   
  AND TS.TimesheetDate>=@FromDate AND  TS.TimesheetDate<=@ToDate AND TD.IsDeleted=0   
  INNER JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK)  WD ON TD.WorkItemDetailsId=WD.WorkItemDetailsId  
  INNER JOIN AVL.Customer(NOLOCK)  C ON TS.CustomerID=C.CustomerID AND C.CustomerID=@CustomerID    
  INNER JOIN AVL.MAS_ProjectMaster(NOLOCK)  PM ON PM.CustomerID=C.CustomerID   
  AND TS.ProjectID=PM.ProjectID and  PM.IsDeleted=0  
  INNER JOIN AVL.MAS_LoginMaster(NOLOCK)  LM ON LM.CustomerID=@CustomerID   
  AND LM.EmployeeID=@SubmitterId AND TS.SubmitterId=LM.UserID AND PM.ProjectID=LM.ProjectID and LM.IsDeleted=0    
  
   
 SELECT DISTINCT WD.WorkItemDetailsId,WT.WorkTypeMapId,WD.WorkItem_Id,WT.WorkTypeId,WD.Linked_ParentID AS Parent1,  
 ISNULL(WD.WorkItemDetailsId,0) AS Parent1ID,  
 WD1.Linked_ParentID AS Parent2,  
 ISNULL(WD1.WorkItemDetailsId,0)  AS Parent2ID,  
 WD2.Linked_ParentID AS Parent3,  
 ISNULL(WD2.WorkItemDetailsId,0)  AS Parent3ID,  
 NULL AS IDsWithApplication,NULL AS IsAppAvailable  
 INTO #Temp  
 FROM ADM.ALM_TRN_WorkItem_Details(NOLOCK) WD  
 LEFT JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK) WD1 ON WD.Linked_ParentID=WD1.WorkItem_Id  
 LEFT JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK) WD2 ON WD1.Linked_ParentID=WD2.WorkItem_Id  
 INNER JOIN [PP].[ALM_MAP_WorkType](NOLOCK) WT ON WD.WorkTypeMapId=WT.WorkTypeMapId   
 INNER JOIN  #WorkItems WI ON WI.WorkItem_Id = WD.WorkItem_Id  
 AND WI.Project_Id = WT.ProjectId  
 ORDER BY WorkTypeId ASC  
   
 UPDATE #Temp SET IDsWithApplication=WorkItemDetailsId,IsAppAvailable=1 WHERE WorkTypeId=1  
 UPDATE #Temp SET IDsWithApplication=Parent1ID,IsAppAvailable=1 WHERE WorkTypeId=2  
  
 UPDATE WT SET WT.IsAppAvailable=1,IDsWithApplication=WT.Parent1ID  
 FROM #Temp WT  
 INNER JOIN ADM.ALM_TRN_WorkItem_ApplicationMapping WA ON WT.Parent1ID=WA.WorkItemDetailsId  
 WHERE WT.WorkTypeId NOT IN(1,2) AND ISNULL(WT.IsAppAvailable,0) !=1  
   
 UPDATE WT SET WT.IsAppAvailable=1,IDsWithApplication=WT.Parent2ID  
 FROM #Temp WT  
 INNER JOIN ADM.ALM_TRN_WorkItem_ApplicationMapping WA ON WT.Parent2ID=WA.WorkItemDetailsId  
 WHERE WT.WorkTypeId NOT IN(1,2) AND ISNULL(WT.IsAppAvailable,0) !=1  
   
 SELECT T.WorkItem_Id,AD.ApplicationName INTO #TempApplication  
 FROM #Temp  T With (NOLOCK)  
 INNER JOIN ADM.ALM_TRN_WorkItem_ApplicationMapping WI (NOLOCK) ON T.IDsWithApplication=WI.WorkItemDetailsId  
 INNER JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) ON WI.Application_Id=AD.ApplicationID  
  
 SELECT  E.WorkItem_Id,STUFF((SELECT  ',' + ApplicationName  
            FROM #TempApplication EE With (NOLOCK)  
            WHERE  EE.WorkItem_Id=E.WorkItem_Id  
            ORDER BY WorkItem_Id  
        FOR XML PATH('')), 1, 1, '') AS ApplicationName INTO #WorkItemApplication   
 FROM #TempApplication E  
 GROUP BY E.WorkItem_Id  
 DROP TABLE #Temp  
  
    
  SELECT    
  DISTINCT      
  TD.TicketID       AS TicketId,    
  ISNULL(TTD.TicketDescription,'')    AS Description,    
  ISNULL(SM.ServiceName,'')      AS Service,   
  CASE WHEN TD.IsNonTicket=0 THEN ISNULL(AM.ActivityName,'')  
  WHEN TD.IsNonTicket=1 THEN ISNULL(NA.NonTicketedActivity,'')  
  END AS Activity,  
  --ISNULL(AM.ActivityName,'')   AS Activity,    
  ISNULL(TT.TicketType,'')      AS TicketType,     
  0         AS ITSMEffort,    
  TD.Hours       AS EffortTillDate,    
  0         AS MarkAsDataEntry,    
  --ISNULL(PM.EsaProjectID,'')       AS ProjectID,    
  ISNULL(TD.Remarks,'')    AS Remarks,    
    ISNULL(APP.ApplicationName,'')     AS ApplicationName,  
  TS.TimesheetDate     AS TimesheetDate,
  DC.DebtClassificationName           AS DebtClassification,    
  CC.CauseCode                        AS CauseCode,    
  RC.ResolutionCode                   AS ResolutionCode,    
  AF.AvoidableFlagName                AS AvoidableFlag,    
  RD.ResidualDebtName                 AS ResidualDebt,    
  C.CustomerId      AS CustomerId,      
  ISNULL(CASE WHEN  C.IsCognizant=0 THEN 0 ELSE 1 END,0)   AS IsCognizant,    
  ISNULL(C.IsEffortConfigured,0)  AS IsEfforTracked,    
  ISNULL(C.IsITSMEffortConfigured,0) AS IsITSMLinked,    
  ISNULL(CASE WHEN PM.IsDebtEnabled='Y' THEN 1 ELSE 0 END,0)   AS IsDebtEnabled,    
  ISNULL(C.IsEffortTrackActivityWise,1)         AS IsAcitivityTracked,    
  ISNULL(CASE WHEN PM.IsMainspringConfigured='Y' THEN 1 ELSE 0 END,0) AS IsMainSpringConfigured,    
  ISNULL(PM.EsaProjectID,'') AS ProjectId,  
  '' AS Tower,  
  'T' AS Type  
    
  FROM     
    
  AVL.TM_TRN_TimesheetDetail TD With (NOLOCK)   
  INNER JOIN AVL.TM_PRJ_Timesheet TS (NOLOCK)  ON TD.TimesheetId=TS.TimesheetId AND TS.TimesheetDate>=@FromDate AND  TS.TimesheetDate<=@ToDate AND TD.IsDeleted=0   
  INNER JOIN AVL.Customer C (NOLOCK) ON TS.CustomerID=C.CustomerID AND C.CustomerID=@CustomerID    
  INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON PM.CustomerID=C.CustomerID and  PM.IsDeleted=0  
  INNER JOIN AVL.MAS_LoginMaster LM (NOLOCK) ON LM.CustomerID=@CustomerID AND LM.EmployeeID=@SubmitterId AND TS.SubmitterId=LM.UserID AND PM.ProjectID=LM.ProjectID and LM.IsDeleted=0   
  LEFT JOIN AVL.TK_TRN_TicketDetail TTD (NOLOCK)  ON TTD.TicketID = TD.TicketID AND TTD.TimeTickerID=TD.TimeTickerID AND TTD.ApplicationID=TD.ApplicationID     
  LEFT JOIN AVL.DEBT_MAS_DebtClassification DC (NOLOCK) ON TTD.DebtClassificationMapID=DC.DebtClassificationID    
  LEFT JOIN AVL.DEBT_MAP_CauseCode CC (NOLOCK) ON TTD.CauseCodeMapID=CC.CauseID    
  LEFT JOIN AVL.DEBT_MAP_ResolutionCode RC (NOLOCK) ON TTD.ResolutionCodeMapID=RC.ResolutionID    
  LEFT JOIN AVL.DEBT_MAS_AvoidableFlag AF (NOLOCK) ON TTD.AvoidableFlag=AF.AvoidableFlagID    
  LEFT JOIN AVL.DEBT_MAS_ResidualDebt RD (NOLOCK) ON TTD.ResidualDebtMapID=RD.ResidualDebtID    
  LEFT JOIN AVL.TK_MAS_DARTTicketStatus DTS (NOLOCK) ON DTS.DARTStatusID=TS.StatusId AND DTS.IsDeleted=0  
  LEFT JOIN AVL.APP_MAS_ApplicationDetails APP (NOLOCK) ON APP.ApplicationID=TD.ApplicationID    
  LEFT JOIN AVL.TK_MAS_Service SM (NOLOCK)  ON SM.ServiceID = TD.ServiceId    
  LEFT JOIN AVL.TK_MAP_TicketTypeMapping TT (NOLOCK)   ON TT.TicketTypeMappingID=TD.TicketTypeMapID    
  LEFT JOIN AVL.TK_MAS_ServiceActivityMapping  AM (NOLOCK)  ON TD.ServiceId=AM.ServiceID AND TD.ActivityId=AM.ActivityID AND AM.IsDeleted=0  
  LEFT JOIN AVL.MAS_NonDeliveryActivity NA (NOLOCK) ON NA.ID=TD.ActivityId  
  
  
  UNION  
  
  SELECT    
  DISTINCT      
  TD.TicketID       AS TicketId,    
  ISNULL(TTD.TicketDescription,'')    AS Description,    
  ''     AS Service,   
  CASE WHEN TD.IsNonTicket=0 THEN ISNULL(AM.InfraTaskName,'')  
  WHEN TD.IsNonTicket=1 THEN ISNULL(NA.NonTicketedActivity,'')  
  END AS Activity,  
  --ISNULL(AM.ActivityName,'')   AS Activity,    
  ISNULL(TT.TicketType,'')      AS TicketType,     
  0         AS ITSMEffort,    
  TD.Hours       AS EffortTillDate,    
  0         AS MarkAsDataEntry,    
  --ISNULL(PM.EsaProjectID,'')       AS ProjectID,    
  ISNULL(TD.Remarks,'')    AS Remarks,    
  ''     AS ApplicationName,    
  TS.TimesheetDate     AS TimesheetDate,    
  DC.DebtClassificationName           AS DebtClassification,    
  CC.CauseCode                        AS CauseCode,    
  RC.ResolutionCode                   AS ResolutionCode,    
  AF.AvoidableFlagName                AS AvoidableFlag,    
  RD.ResidualDebtName                 AS ResidualDebt,    
  C.CustomerId      AS CustomerId,      
  ISNULL(CASE WHEN  C.IsCognizant=0 THEN 0 ELSE 1 END,0)   AS IsCognizant,    
  ISNULL(C.IsEffortConfigured,0)  AS IsEfforTracked,    
  ISNULL(C.IsITSMEffortConfigured,0) AS IsITSMLinked,    
  ISNULL(CASE WHEN PM.IsDebtEnabled='Y' THEN 1 ELSE 0 END,0)   AS IsDebtEnabled,    
  ISNULL(C.IsEffortTrackActivityWise,1)         AS IsAcitivityTracked,    
  ISNULL(CASE WHEN PM.IsMainspringConfigured='Y' THEN 1 ELSE 0 END,0) AS IsMainSpringConfigured,    
  ISNULL(PM.EsaProjectID,'') AS ProjectId,  
  TM.TowerName AS Tower,  
  'T' AS Type  
    
    
  FROM     
    
  AVL.TM_TRN_InfraTimesheetDetail TD With (NOLOCK)    
  INNER JOIN AVL.TM_PRJ_Timesheet TS (NOLOCK)   ON TD.TimesheetId=TS.TimesheetId AND TS.TimesheetDate>=@FromDate AND  TS.TimesheetDate<=@ToDate AND TD.IsDeleted=0   
  INNER JOIN AVL.Customer C (NOLOCK) ON TS.CustomerID=C.CustomerID AND C.CustomerID=@CustomerID    
  INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON PM.CustomerID=C.CustomerID and  PM.IsDeleted=0  
  INNER JOIN AVL.MAS_LoginMaster LM (NOLOCK) ON LM.CustomerID=@CustomerID AND LM.EmployeeID=@SubmitterId AND TS.SubmitterId=LM.UserID AND PM.ProjectID=LM.ProjectID and LM.IsDeleted=0 
  LEFT JOIN AVL.TK_TRN_InfraTicketDetail TTD (NOLOCK)  ON TTD.TicketID = TD.TicketID AND TTD.TimeTickerID=TD.TimeTickerID AND TTD.TowerID=TD.TowerID     
  LEFT JOIN AVL.DEBT_MAS_DebtClassification DC (NOLOCK) ON TTD.DebtClassificationMapID=DC.DebtClassificationID    
  LEFT JOIN AVL.DEBT_MAP_CauseCode CC (NOLOCK) ON TTD.CauseCodeMapID=CC.CauseID    
  LEFT JOIN AVL.DEBT_MAP_ResolutionCode RC (NOLOCK) ON TTD.ResolutionCodeMapID=RC.ResolutionID    
  LEFT JOIN AVL.DEBT_MAS_AvoidableFlag AF (NOLOCK) ON TTD.AvoidableFlag=AF.AvoidableFlagID    
  LEFT JOIN AVL.DEBT_MAS_ResidualDebt RD (NOLOCK) ON TTD.ResidualDebtMapID=RD.ResidualDebtID    
  LEFT JOIN AVL.TK_MAS_DARTTicketStatus DTS (NOLOCK) ON DTS.DARTStatusID=TS.StatusId AND DTS.IsDeleted=0  
  LEFT JOIN AVL.InfraTowerDetailsTransaction TM  (NOLOCK)ON TM.InfraTowerTransactionID=TD.TowerID and TM.CustomerID=@CustomerID  
  --LEFT JOIN AVL.TK_MAS_Service SM  ON SM.ServiceID = TD.ServiceId    
  LEFT JOIN AVL.TK_MAP_TicketTypeMapping TT (NOLOCK)   ON TT.TicketTypeMappingID=TD.TicketTypeMapID    
  LEFT JOIN AVL.InfraTaskTransaction  AM (NOLOCK)  ON TD.TaskId=AM.InfraTransactionTaskID AND AM.IsDeleted=0  
  LEFT JOIN AVL.MAS_NonDeliveryActivity NA (NOLOCK) ON NA.ID=TD.TaskId  
    
  UNION  
  
    SELECT    
  DISTINCT      
  --WD.WorkItem_Id       AS TicketId,    
  CASE WHEN ISNULL(TD.IsNonTicket,0)=1 THEN 'NonDelivery'  
  ELSE WD.WorkItem_Id  
  END AS TicketId,  
  ISNULL(WD.WorkItem_Title,'')    AS Description,    
  ISNULL(SM.ServiceName,'')      AS Service,   
  CASE WHEN TD.IsNonTicket=0 THEN ISNULL(AM.ActivityName,'')  
  WHEN TD.IsNonTicket=1 THEN ISNULL(NA.NonTicketedActivity,'')  
  END AS Activity,  
  ''      AS TicketType,     
  0         AS ITSMEffort,    
  TD.Hours       AS EffortTillDate,    
  0         AS MarkAsDataEntry,    
  ISNULL(TD.Remarks,'')    AS Remarks,    
  ISNULL(WI.ApplicationName,'') AS  ApplicationName,  
  -- TO CHANGE ISNULL(APP.ApplicationName,'')     AS ApplicationName,    
  TS.TimesheetDate     AS TimesheetDate,    
  ''           AS DebtClassification,    
  ''                        AS CauseCode,    
  ''                  AS ResolutionCode,    
  ''                AS AvoidableFlag,    
  ''                 AS ResidualDebt,    
  C.CustomerId      AS CustomerId,      
  ISNULL(CASE WHEN  C.IsCognizant=0 THEN 0 ELSE 1 END,0)   AS IsCognizant,    
  ISNULL(C.IsEffortConfigured,0)  AS IsEfforTracked,    
  ISNULL(C.IsITSMEffortConfigured,0) AS IsITSMLinked,    
  ISNULL(CASE WHEN PM.IsDebtEnabled='Y' THEN 1 ELSE 0 END,0)   AS IsDebtEnabled,    
  ISNULL(C.IsEffortTrackActivityWise,1)         AS IsAcitivityTracked,    
  ISNULL(CASE WHEN PM.IsMainspringConfigured='Y' THEN 1 ELSE 0 END,0) AS IsMainSpringConfigured,    
  ISNULL(PM.EsaProjectID,'') AS ProjectId,  
  '' AS Tower,  
  'W' AS Type  
    FROM ADM.TM_TRN_WorkItemTimesheetDetail TD With (NOLOCK)    
  INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK)  TS   ON TD.TimesheetId=TS.TimesheetId AND TS.TimesheetDate>=@FromDate AND  TS.TimesheetDate<=@ToDate AND TD.IsDeleted=0   
  LEFT JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK)  WD ON TD.WorkItemDetailsId=WD.WorkItemDetailsId  
  INNER JOIN AVL.Customer(NOLOCK)  C ON TS.CustomerID=C.CustomerID AND C.CustomerID=@CustomerID    
  INNER JOIN AVL.MAS_ProjectMaster(NOLOCK)  PM ON PM.CustomerID=C.CustomerID AND TS.ProjectID=PM.ProjectID and  PM.IsDeleted=0  
  INNER JOIN AVL.MAS_LoginMaster(NOLOCK)  LM ON LM.CustomerID=@CustomerID AND LM.EmployeeID=@SubmitterId AND TS.SubmitterId=LM.UserID AND PM.ProjectID=LM.ProjectID and LM.IsDeleted=0   
  LEFT JOIN AVL.MAS_NonDeliveryActivity(NOLOCK)  NA ON NA.ID=TD.ActivityId  
  LEFT JOIN AVL.TK_MAS_Service(NOLOCK)  SM  ON SM.ServiceID = TD.ServiceId    
   LEFT JOIN AVL.TK_MAS_ServiceActivityMapping(NOLOCK)   AM  ON TD.ServiceId=AM.ServiceID   
   AND TD.ActivityId=AM.ActivityID AND AM.IsDeleted=0  
  LEFT JOIN #WorkItemApplication WI ON WI.WorkItem_Id=WD.WorkItem_Id  
  
  
  SET NOCOUNT OFF
 END TRY  
 BEGIN CATCH  
  SELECT   
   ERROR_NUMBER() AS ErrorNumber  
   ,ERROR_SEVERITY() AS ErrorSeverity  
   ,ERROR_STATE() AS ErrorState  
   ,ERROR_PROCEDURE() AS ErrorProcedure  
   ,ERROR_LINE() AS ErrorLine  
   ,ERROR_MESSAGE() AS ErrorMessage;  
  
  IF @@TRANCOUNT > 0  
   ROLLBACK TRANSACTION;  
 END CATCH;  
  
 IF @@TRANCOUNT > 0  
  COMMIT TRANSACTION;  
END
