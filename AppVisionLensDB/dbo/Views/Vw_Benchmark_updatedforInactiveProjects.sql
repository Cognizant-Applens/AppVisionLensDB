CREATE VIEW [dbo].[Vw_Benchmark_updatedforInactiveProjects] AS         
SELECT DISTINCT CONVERT (SMALLINT,0) AS org            
,CONVERT(NVARCHAR(50),REPLACE(TTTD.TicketID, CHAR(9), '')) AS TicketID            
,CONVERT(NVARCHAR(50),REPLACE(OwnBu.BusinessUnitName, CHAR(9), '')) AS [BUNAME]            
,OwnBu.BusinessUnitID AS BU            
,AC.BusinessUnitID AS BUnitID            
,bu.MarketUnitID AS MDU            
,mu.MarketUnitName             
,m.MarketName            
--,CONVERT(NVARCHAR(50),REPLACE(TktDtl.[CustomerName], CHAR(9), '')) [CustomerName]           
,CONVERT(NVARCHAR(50),REPLACE(AC.[CustomerName], CHAR(9), '')) AS [CustomerName]            
,CONVERT(NVARCHAR(50),REPLACE(AC.[CustomerName], CHAR(9), '')) AS [ACCOUNT_NAME]            
,AC.ESA_AccountId AS [ACCOUNT_ID]            
,AC.ESA_AccountId AS [Customer_ID]            
,PltAcct.[Customer_Id] AS ParentCustomerID            
,PltAcct.[BenchStrategic_Id] AS AccountType            
,AMPM.ESAProjectID            
,AMLM.EmployeeID            
,TktDtl.IsPartiallyAutomated            
,--CONVERT(NVARCHAR(50),REPLACE(TktDtl.[ServiceName], CHAR(9), '')) [ServiceName]            
CONVERT(NVARCHAR(50),REPLACE(ser.[ServiceName], CHAR(9), '')) AS [ServiceName]            
,TktDtl.ServiceID AS ServiceID            
,SerType.[ServiceTypeName]            
,SerLvl.[ServiceLevelName]            
,[SerType].[ServiceTypeID]            
,SerLvl.[ServiceLevelID]            
,GMSPrj.[Billability_Type]        
,BillType.[BenchBillabilityType_Id] AS ContractType            
,CONVERT(NVARCHAR(100),REPLACE(AppDtl.[PrimaryTechnologyName], CHAR(9), '')) AS [PrimaryTechnologyName]            
,AppDtl.[PrimaryTechnologyID]        
,AppDtl.ApplicationTypename ApplicationTypename        
,AppDtl.BusinessCriticalityName BusinessCriticalityName        
,TechGrp.[BenchTech_Id] Technology            
,AppDtl.[ApplicationCommisionDate]            
,DATEDIFF(YEAR,AppDtl.[ApplicationCommisionDate],GETDATE()) AS Agediff            
,AppAgeCat.BenchAppAgeID AS ApplicationAge            
,SAPCls.[SAPClassification_Id] AS SAPClassification            
,CONVERT(NVARCHAR(50),REPLACE(AppDtl.[RegulatoryCompliantName], CHAR(9), '')) AS [RegulatoryCompliantName]            
,AppDtl.[RegulatoryCompliantID] AS RegularityCompliance        
,AppDtl.[ApplicationName] AS ApplicationName        
,CONVERT(NVARCHAR(50),REPLACE(AppDtl.[HostedEnvironmentName], CHAR(9), '')) AS [HostedEnvironmentName]            
,AppHostGroup.[BenchAppHostGroup_Id] AS ApplicationCategory            
--,CONVERT(nvarchar(50),REPLACE(TktDtl.[ApplensStandardPriorityName], CHAR(9), '')) AS [Priority]            
--,CONVERT(nvarchar(50),REPLACE(ATMPM.[PriorityName], CHAR(9), '')) AS [Priority]        
,ATMPM.[PriorityName]        
--,TktDtl.EffortTillDate [EffortTillDate]          
,TTTD.Hours as [Hours]      
,TktDtl.[TicketCreateDate]            
,TktDtl.[OpenDateTime]            
,TktDtl.[Closeddate]            
,TktDtl.DARTStatusID        
,TktDtl.CompletedDateTime        
,TMDTSID.DARTStatusName        
,ATPTS.TimesheetDate        
,GMSAssoc.Dept_Name            
,GeoMap.[BenchGeo_Id] AS AssociateGeography            
,DeptGrp.[BenchDept_Id] AS AssociateDept            
,AMPM.ProjectStartDate AS [Project_Start_Date]            
,AMPM.ProjectEndDate AS [Project_End_Date]            
,CC.CauseCode          
,RC.ResolutionCode          
,MTSM.TimesheetStatus          
--From [dbo].[vw_TK_TRN_TicketDetail] TktDtl WITH (NOLOCK)            
--Inner JOIN [AVL].[TK_TRN_TicketDetail] AVLTKTTRN WITH (NOLOCK)            
--on  AVLTKTTRN.TimeTickerID   = TktDtl.TimeTickerID            
FROM [AVL].[TM_TRN_TimesheetDetail] TTTD WITH (NOLOCK)            
LEFT JOIN [AVL].[TK_TRN_TicketDetail] TktDtl WITH (NOLOCK) ON TktDtl.TimeTickerID = TTTD.TimeTickerID        
LEFT JOIN AVL.TM_PRJ_Timesheet ATPTS WITH (NOLOCK) ON TTTD.TimesheetId=ATPTS.TimesheetId          
LEFT JOIN avl.MAS_LoginMaster AMLM WITH (NOLOCK) ON ATPTS.SubmitterId=AMLM.UserID          
LEFT JOIN avl.MAS_ProjectMaster AMPM WITH (NOLOCK) ON TTTD.ProjectId=AMPM.ProjectID          
LEFT JOIN avl.Customer AC  WITH (NOLOCK) ON AC.CustomerID=AMPM.CustomerID          
LEFT JOIN [AVL].[TK_MAP_PriorityMapping] ATMPM WITH (NOLOCK) ON TktDtl.PriorityMapID=ATMPM.PriorityIDMapID          
--LEFT OUTER JOIN [$(AppVisionLens)].[dbo].[vw_GMSPMO_Project] GMSPrj WITH (NOLOCK)            
LEFT JOIN [dbo].[GMSPMO_ProjectBill] GMSPrj WITH (NOLOCK) ON GMSPrj.Project_ID   = AMPM.ESAProjectID             
--LEFT JOIN [dbo].[AVM_Project_list] AVMPrj WITH (NOLOCK)        
LEFT JOIN dbo.OPLMasterdata_Benchmark AVMPrj WITH (NOLOCK) ON AVMPrj.[esa_project_id] = AMPM.EsaProjectId        
LEFT JOIN MAS.MarketUnits mku WITH (NOLOCK) ON AVMPrj.Market_Unit=mku.MarketUnitName        
LEFT JOIN [MAS].[BusinessUnits] OwnBu WITH (NOLOCK) ON mku.MarketUnitId=OwnBu.MarketUnitId        
--AVMPrj.[PracticeOwnerId] = OwnBu.[BusinessUnitID]          
AND OwnBu.IsDeleted = 0            
--and OwnBu.IsHorizontal = 'Y'              
--LEFT JOIN avl.Customer cus             
--on cus.[ESA_AccountID] = GMSPrj.[ACCOUNT_ID]            
LEFT JOIN [MAS].[BusinessUnits] bu ON bu.BusinessUnitID = AC.BusinessUnitID -- New Business Unit Table            
LEFT JOIN [MAS].MarketUnits mu ON mu.MarketUnitID = bu.MarketUnitID            
LEFT JOIN MAS.Markets m ON m.MarketID = mu.MarketID            
LEFT JOIN [dbo].[VW_Applens_AccountLevelApplicationDetails] AccApp WITH (NOLOCK) ON AccApp.ESA_AccountID = AC.ESA_AccountId AND AccApp.ApplicationID = TktDtl.ApplicationID            
LEFT JOIN [dbo].[VW_Applens_ApplicationAttributes] AppDtl WITH (NOLOCK) ON AppDtl.ESA_AccountID = AccApp.ESA_AccountID AND AppDtl.ApplicationID = AccApp.ApplicationID            
LEFT join [dbo].[GMSPMO_AssociateLatAssi] GMSAssoc with (NOLocK)            
--(Select Associate_ID,Project_ID,Dept_Name, Max(AssignmentEndDate) MaxAssigDate            
--from [$(AppVisionLens)].[dbo].[vw_GMSPMO_Associate] WITH (NOLOCK)            
--Group By Associate_ID,Project_ID,Dept_Name) as GMSAssoc             
ON AMLM.EmployeeID = GMSAssoc.Associate_ID AND AMPM.ESAProjectID = GMSAssoc.Project_ID            
LEFT JOIN [BM].[map_Bench_AppAge] AppAgeCat WITH (NOLOCK) ON AppAgeCat.[AppAge] = DATEDIFF(YEAR,AppDtl.[ApplicationCommisionDate],GETDATE())            
--Left outer join [$(AppVisionLens)].[ESA].[BUParentAccounts] PrntAcc WITH (NOLOCK)            
--on PrntAcc.[ESA_AccountID] = GMSPrj.[Customer_ID]            
LEFT JOIN [BM].[map_Bench_StragicAccount] PltAcct WITH (NOLOCK) ON PltAcct.[Customer_Id] = AC.Esa_AccountId            
--Left outer join [BM].[map_Bench_StragicAccount] PltAcct WITH (NOLOCK)            
--on PltAcct.[Customer_Id] = PrntAcc.[ParentCustomerID]            
LEFT JOIN [BM].[map_Bench_Billability] BillType WITH (NOLOCK) ON BillType.[Billability_Type] = GMSPrj.[Billability_Type]         
LEFT JOIN [BM].[map_AppHost] AppHostGroup WITH (NOLOCK) ON AppHostGroup.[HostedEnvironment_Id] = AppDtl.[HostedEnvironmentID]            
LEFT JOIN [BM].[map_Bench_Dept] DeptGrp WITH (NOLOCK) ON DeptGrp.[Department] = GMSAssoc.Dept_Name            
LEFT JOIN [BM].[map_Bench_Tech] TechGrp  WITH (NOLOCK) ON TechGrp.[PrimaryTechnology_Id] = AppDtl.[PrimaryTechnologyID]        
LEFT JOIN [BM].[Map_Bench_SAPClassification] SAPCls WITH (NOLOCK) ON SAPCls.[Application_name] = AppDtl.[ApplicationName]            
LEFT JOIN [BM].[Prism_Associate_Loc] Loc WITH (NOLOCK) ON Loc.[ProjectID] = AMPM.ESAProjectID AND Loc.[AssociateID] = AMLM.EmployeeID            
LEFT JOIN [BM].[map_Geo] GeoMap WITH (NOLOCK) ON GeoMap.[Country] = Loc.[LocationGroupname]            
LEFT JOIN [AVL].[TK_MAS_Service] Ser WITH (NOLOCK) ON Ser.ServiceID = TktDtl.ServiceID            
LEFT JOIN [AVL].[TK_MAS_ServiceType] SerType WITH (NOLOCK) ON SerType.[ServiceTypeID] = Ser.[ServiceType]            
LEFT JOIN [AVL].[MAS_ServiceLevel] SerLvl WITH (NOLOCK) ON SerLvl.[ServiceLevelID] = Ser.ServiceLevelID            
LEFT JOIN [AVL].[DEBT_MAP_CauseCode](NOLOCK) CC on TktDtl.CauseCodeMapID=CC.CauseID          
LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode](NOLOCK) RC on TktDtl.ResolutionCodeMapID=RC.ResolutionID          
LEFT JOIN AVL.MAS_TimesheetStatus(NOLOCK) MTSM on ATPTS.StatusId=MTSM.TimesheetStatusid          
LEFT JOIN [AVL].[TK_MAS_DARTTicketStatus](NOLOCK) TMDTSID on TktDtl.DARTStatusID=TMDTSID.DARTStatusID 