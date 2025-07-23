
CREATE VIEW [dbo].[Vw_Benchmark] AS 
SELECT     
 convert (smallint,0) as org    
,Convert(nvarchar(50), REPLACE(TktDtl.TicketID, char(9), '')) TicketID    
,convert(nvarchar(50),REPLACE(OwnBu.BusinessUnitName, char(9), '')) [BUNAME]    
,OwnBu.BusinessUnitID BU    
,cus.BusinessUnitID BUnitID    
,bu.MarketUnitID MDU    
,mu.MarketUnitName    
,m.MarketName    
--,convert(nvarchar(50),REPLACE(TktDtl.[CustomerName], char(9), '')) [CustomerName]   
,convert(nvarchar(50),REPLACE(AC.[CustomerName], char(9), '')) [CustomerName]    
,convert(nvarchar(80),REPLACE(GMSPrj.[ACCOUNT_NAME], char(9), '')) [ACCOUNT_NAME]    
,GMSPrj.[ACCOUNT_ID]    
,GMSPrj.[Customer_ID]    
,PltAcct.[Customer_Id] as ParentCustomerID    
,PltAcct.[BenchStrategic_Id] AccountType    
,AMPM.ESAProjectID    
,AMLM.EmployeeID    
,TktDtl.IsPartiallyAutomated    
,--convert(nvarchar(50),REPLACE(TktDtl.[ServiceName], char(9), '')) [ServiceName]    
convert(nvarchar(50),REPLACE(ser.[ServiceName], char(9), '')) [ServiceName]    
,TktDtl.ServiceID ServiceID    
,SerType.[ServiceTypeName]    
,SerLvl.[ServiceLevelName]    
,[SerType].[ServiceTypeID]    
,SerLvl.[ServiceLevelID]    
,GMSPrj.[Billability_Type]    
,BillType.[BenchBillabilityType_Id] ContractType    
,convert(nvarchar(100),REPLACE(AppDtl.[PrimaryTechnologyName], char(9), '')) [PrimaryTechnologyName]    
,AppDtl.[PrimaryTechnologyID]
,AppDtl.ApplicationTypename ApplicationTypename
,AppDtl.BusinessCriticalityName BusinessCriticalityName
,TechGrp.[BenchTech_Id] Technology    
,AppDtl.[ApplicationCommisionDate]    
,Datediff(year,AppDtl.[ApplicationCommisionDate],getdate()) Agediff    
,AppAgeCat.BenchAppAgeID ApplicationAge    
,SAPCls.[SAPClassification_Id] SAPClassification    
,convert(nvarchar(50),REPLACE(AppDtl.[RegulatoryCompliantName], char(9), ''))[RegulatoryCompliantName]    
,AppDtl.[RegulatoryCompliantID] RegularityCompliance
,AppDtl.[ApplicationName] ApplicationName
,convert(nvarchar(50),REPLACE(AppDtl.[HostedEnvironmentName], char(9), '')) [HostedEnvironmentName]    
,AppHostGroup.[BenchAppHostGroup_Id] ApplicationCategory    
--,convert(nvarchar(50),REPLACE(TktDtl.[ApplensStandardPriorityName], char(9), '')) [Priority]    
--,convert(nvarchar(50),REPLACE(ATMPM.[PriorityName], char(9), '')) [Priority]
,ATMPM.[PriorityName]
,TktDtl.EffortTillDate [EffortTillDate]    
,TktDtl.[TicketCreateDate]    
,TktDtl.[OpenDateTime]    
,TktDtl.[Closeddate]    
,TktDtl.DARTStatusID
,TktDtl.CompletedDateTime
,TMDTSID.DARTStatusName
,ATPTS.TimesheetDate
,GMSAssoc.Dept_Name    
,GeoMap.[BenchGeo_Id] as AssociateGeography    
,DeptGrp.[BenchDept_Id] AssociateDept    
,GMSPrj.[Project_Start_Date]    
,GMSPrj.[Project_End_Date]    
,CC.CauseCode  
,RC.ResolutionCode  
,MTSM.TimesheetStatus  
    --From [dbo].[vw_TK_TRN_TicketDetail] TktDtl WITH (NOLOCK)    
    --Inner JOIN [AVL].[TK_TRN_TicketDetail] AVLTKTTRN WITH (NOLOCK)    
    --  on  AVLTKTTRN.TimeTickerID   = TktDtl.TimeTickerID    
    From [AVL].[TM_TRN_TimesheetDetail] TTTD WITH (NOLOCK)    
    LEFT JOIN [AVL].[TK_TRN_TicketDetail] TktDtl WITH (NOLOCK)    
      on  TktDtl.TimeTickerID = TTTD.TimeTickerID
 LEFT JOIN AVL.TM_PRJ_Timesheet ATPTS WITH (NOLOCK) on TTTD.TimesheetId=ATPTS.TimesheetId  
 LEFT JOIN avl.MAS_LoginMaster AMLM WITH (NOLOCK) on ATPTS.SubmitterId=AMLM.UserID  
 LEFT JOIN avl.MAS_ProjectMaster AMPM WITH (NOLOCK) on TTTD.ProjectId=AMPM.ProjectID  
 LEFT JOIN avl.Customer AC  WITH (NOLOCK) on AC.CustomerID=AMPM.CustomerID  
 LEFT JOIN [AVL].[TK_MAP_PriorityMapping] ATMPM WITH (NOLOCK) on TktDtl.PriorityMapID=ATMPM.PriorityIDMapID  
--    LEFT OUTER JOIN [$(AppVisionLens)].[dbo].[vw_GMSPMO_Project] GMSPrj WITH (NOLOCK)    
    LEFT JOIN [dbo].[GMSPMO_ProjectBill] GMSPrj WITH (NOLOCK)    
      on  GMSPrj.Project_ID   = AMPM.ESAProjectID     
    --LEFT JOIN [dbo].[AVM_Project_list] AVMPrj WITH (NOLOCK)
	LEFT JOIN dbo.OPLMasterdata_Benchmark AVMPrj WITH (NOLOCK)
   on AVMPrj.[esa_project_id] = GMSPrj.Project_ID
   left join 
	MAS.MarketUnits mku WITH (NOLOCK) on AVMPrj.Market_Unit=mku.MarketUnitName
    LEFT JOIN [MAS].[BusinessUnits] OwnBu WITH (NOLOCK)    
   on mku.MarketUnitId=OwnBu.MarketUnitId
   --AVMPrj.[PracticeOwnerId] = OwnBu.[BusinessUnitID]  
   and OwnBu.IsDeleted = 0    
   --and OwnBu.IsHorizontal = 'Y'      
    LEFT JOIN avl.Customer cus     
   on cus.[ESA_AccountID] = GMSPrj.[ACCOUNT_ID]    
 LEFT JOIN [MAS].[BusinessUnits] bu     
   ON bu.BusinessUnitID = cus.BusinessUnitID -- New Business Unit Table    
    LEFT JOIN [MAS].MarketUnits mu     
   ON mu.MarketUnitID = bu.MarketUnitID    
    LEFT JOIN MAS.Markets m     
   ON m.MarketID = mu.MarketID    
    LEFT JOIN [dbo].[VW_Applens_AccountLevelApplicationDetails] AccApp WITH (NOLOCK)    
      on AccApp.ESA_AccountID = GMSPrj.ACCOUNT_ID    
     and AccApp.ApplicationID = TktDtl.ApplicationID    
    LEFT JOIN [dbo].[VW_Applens_ApplicationAttributes] AppDtl WITH (NOLOCK)    
       on AppDtl.ESA_AccountID = AccApp.ESA_AccountID    
     and AppDtl.ApplicationID = AccApp.ApplicationID    
  LEFT join [dbo].[GMSPMO_AssociateLatAssi] GMSAssoc with (NOLocK)    
--     (Select Associate_ID,Project_ID,Dept_Name, Max(AssignmentEndDate) MaxAssigDate    
--        from [$(AppVisionLens)].[dbo].[vw_GMSPMO_Associate] WITH (NOLOCK)    
--       Group By Associate_ID,Project_ID,Dept_Name) as GMSAssoc     
     on AMLM.EmployeeID = GMSAssoc.Associate_ID    
  and AMPM.ESAProjectID = GMSAssoc.Project_ID    
  Left join [BM].[map_Bench_AppAge] AppAgeCat WITH (NOLOCK)    
    on AppAgeCat.[AppAge] = Datediff(year,AppDtl.[ApplicationCommisionDate],getdate())    
--   Left outer join [$(AppVisionLens)].[ESA].[BUParentAccounts] PrntAcc WITH (NOLOCK)    
--     on PrntAcc.[ESA_AccountID] = GMSPrj.[Customer_ID]    
  Left join [BM].[map_Bench_StragicAccount] PltAcct WITH (NOLOCK)    
       on PltAcct.[Customer_Id] = GMSPrj.[Customer_ID]    
--     Left outer join [BM].[map_Bench_StragicAccount] PltAcct WITH (NOLOCK)    
--    on PltAcct.[Customer_Id] = PrntAcc.[ParentCustomerID]    
     Left join [BM].[map_Bench_Billability] BillType WITH (NOLOCK)    
    on BillType.[Billability_Type] = GMSPrj.[Billability_Type]    
     Left join [BM].[map_AppHost] AppHostGroup WITH (NOLOCK)    
    on AppHostGroup.[HostedEnvironment_Id] = AppDtl.[HostedEnvironmentID]    
  Left join [BM].[map_Bench_Dept] DeptGrp WITH (NOLOCK)    
    on DeptGrp.[Department] = GMSAssoc.Dept_Name    
  Left join [BM].[map_Bench_Tech] TechGrp  WITH (NOLOCK)    
    on TechGrp.[PrimaryTechnology_Id] = AppDtl.[PrimaryTechnologyID]    
     Left join [BM].[Map_Bench_SAPClassification] SAPCls WITH (NOLOCK)    
    on SAPCls.[Application_name] = AppDtl.[ApplicationName]    
     Left join [BM].[Prism_Associate_Loc] Loc WITH (NOLOCK)    
    on Loc.[ProjectID] = AMPM.ESAProjectID    
      and Loc.[AssociateID] = AMLM.EmployeeID    
     Left join [BM].[map_Geo] GeoMap WITH (NOLOCK)    
    on GeoMap.[Country] = Loc.[LocationGroupname]    
     Left join [AVL].[TK_MAS_Service] Ser WITH (NOLOCK)    
    on Ser.ServiceID = TktDtl.ServiceID    
     left join  [AVL].[TK_MAS_ServiceType] SerType WITH (NOLOCK)    
       on SerType.[ServiceTypeID] = Ser.[ServiceType]    
     left join [AVL].[MAS_ServiceLevel] SerLvl WITH (NOLOCK)    
       on SerLvl.[ServiceLevelID] = Ser.ServiceLevelID    
 left join [AVL].[DEBT_MAP_CauseCode](NOLOCK) CC on TktDtl.CauseCodeMapID=CC.CauseID  
 left join [AVL].[DEBT_MAP_ResolutionCode](NOLOCK) RC on TktDtl.ResolutionCodeMapID=RC.ResolutionID  
 left join  AVL.MAS_TimesheetStatus(NOLOCK) MTSM on ATPTS.StatusId=MTSM.TimesheetStatusid  
 left join [AVL].[TK_MAS_DARTTicketStatus](NOLOCK) TMDTSID on TktDtl.DARTStatusID=TMDTSID.DARTStatusID
   -- Where Ser.[IsDeleted] = 0    
    --  and SerLvl.IsDeleted = 0    
   --and Bu.IsDeleted = 0  

