

          
            
CREATE   PROCEDURE [RLE].[SyncRHMSRoleHierarchyLevelMasters]              
AS              
BEGIN              
 SET XACT_ABORT ON;                
              
 DECLARE @Date datetime = GetDate();              
 DECLARE @UserName varchar(100) = 'System';              
 DECLARE @JobName VARCHAR(100)= 'RHMS Role hierarchy Level Master Sync';              
 DECLARE @JobStatusSuccess VARCHAR(100)='Success';              
 DECLARE @JobStatusFail VARCHAR(100)='Failed';              
 DECLARE @JobStatusInProgress VARCHAR(100)='InProgress';           
 DECLARE @LOBCluster VARCHAR(5)='LOB';          
 DECLARE @PortfolioCluster VARCHAR(20)='Portfolio';          
 DECLARE @AppGroupCluster VARCHAR(20)='App Group';          
 DECLARE @LastSuccessDate datetime;              
 DECLARE @JobId int;              
 DECLARE @JobStatusId int;              
 SELECT @JobId = JobID FROM MAS.JobMaster WHERE JobName = @JobName;     
     
         
 DECLARE @MailSubject NVARCHAR(500);          
 DECLARE @MailBody  NVARCHAR(MAX);            
 DECLARE @MailContent NVARCHAR(500);        
 DECLARE @ScriptName  NVARCHAR(100)        
              
 SELECT @LastSuccessDate =MAX(StartDateTime) FROM MAS.JobStatus WHERE JobId = @JobId AND JobStatus = @JobStatusSuccess AND IsDeleted = 0;              
              
 INSERT INTO MAS.JobStatus (JobId, StartDateTime, EndDateTime, JobStatus, JobRunDate, IsDeleted, CreatedBy, CreatedDate)               
        VALUES(@JobId, @Date, @Date, @JobStatusInProgress, @Date, 0, @UserName, @Date);              
 SET @JobStatusId= SCOPE_IDENTITY();              
              
 BEGIN TRY              
 BEGIN TRANSACTION              
    /* Market data merge from gateway table*/              
  MERGE MAS.Markets AS T              
  USING (SELECT rm.MarketId, rm.MarketName, rm.ActiveFlag, rm.LastUpdatedDateTime                 
    FROM [$(AVMCOEESADB)].[dbo].[RHMSMarket] rm              
    LEFT JOIN MAS.Markets m on rm.MarketId = m.ESAMarketID              
    WHERE rm.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR m.MarketID IS NULL) THEN rm.LastUpdatedDateTime ELSE @LastSuccessDate END)              
   ) AS S               
  ON T.ESAMarketID = S.MarketId              
  WHEN NOT MATCHED BY TARGET              
   AND S.ActiveFlag = 1              
  THEN INSERT (MarketName, ESAMarketID, CreatedBy, CreatedDate)              
   VALUES (S.MarketName, S.MarketId, @UserName, @Date)              
  WHEN MATCHED               
  THEN UPDATE              
   SET T.MarketName = S.MarketName,              
    T.IsDeleted = (CASE WHEN S.ActiveFlag = 0 THEN 1 ELSE 0 END),              
    T.ModifiedBy = @UserName,              
    T.ModifiedDate = @Date;              
              
  /* Market Unit data merge from gateway table*/              
  MERGE MAS.MarketUnits AS T              
  USING (SELECT mu.GlobalMarketId, mu.GlobalMarketName, mar.MarketID, (CASE WHEN (mu.ActiveFlag=1 AND mar.IsDeleted=0) THEN 1 ELSE 0 END) As ActiveFlag, mu.LastUpdatedDateTime,mar.IsDeleted              
    FROM [$(AVMCOEESADB)].[dbo].[RHMSMarketUnit] mu              
    LEFT JOIN [$(AVMCOEESADB)].[dbo].[RHMSCustomerBUHierarchyMapping] map ON mu.GlobalMarketId = map.GroupId AND map.ActiveFlag = 1              
    LEFT JOIN [$(AVMCOEESADB)].[dbo].[RHMSMarket] m ON map.MarketID = m.MarketId               
    LEFT JOIN MAS.Markets mar ON m.MarketId = mar.ESAMarketID              
    LEFT JOIN MAS.MarketUnits amu ON mu.GlobalMarketId = amu.ESAMarketUnitID              
    WHERE map.BusinessId IS NULL    
       AND (mu.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR amu.MarketUnitID IS NULL) THEN mu.LastUpdatedDateTime ELSE @LastSuccessDate END)              
    OR map.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR amu.MarketUnitID IS NULL) THEN map.LastUpdatedDateTime ELSE @LastSuccessDate END)              
    OR mar.ModifiedDate > @LastSuccessDate)               
    ) AS S           
  ON T.ESAMarketUnitID = S.GlobalMarketId               
  WHEN NOT MATCHED BY TARGET              
   AND S.ActiveFlag = 1 AND S.MarketID IS NOT NULL              
  THEN INSERT (MarketUnitName, MarketID, ESAMarketUnitID, CreatedBy, CreatedDate)              
   VALUES (S.GlobalMarketName, S.MarketID, S.GlobalMarketId, @UserName, @Date)               
  WHEN MATCHED               
  THEN UPDATE              
   SET T.MarketUnitName = S.GlobalMarketName,              
    T.IsDeleted = (CASE WHEN (S.ActiveFlag = 0 )THEN 1 ELSE 0 END),              
    T.ModifiedBy = @UserName,              
    T.ModifiedDate = @Date;              
              
  /* Business Unit data merge from gateway table*/        
  MERGE MAS.BusinessUnits AS T              
  USING (SELECT DISTINCT rbu.BusinessId, rbu.BusinessName, rmu.MarketUnitID, (CASE WHEN (rbu.ActiveFlag=1 AND rmu.IsDeleted=0) THEN 1 ELSE 0 END)as ActiveFlag, rbu.LastUpdatedDateTime              
   FROM [$(AVMCOEESADB)].[dbo].[RHMSBusinessUnit] rbu              
   LEFT JOIN [$(AVMCOEESADB)].[dbo].[RHMSCustomerBUHierarchyMapping] map on rbu.BusinessId = map.BusinessId AND map.ActiveFlag = 1              
   LEFT JOIN [$(AVMCOEESADB)].[dbo].[RHMSMarketUnit] mu on map.GroupId = mu.GlobalMarketId               
   LEFT JOIN MAS.MarketUnits rmu on mu.GlobalMarketId = rmu.ESAMarketUnitID              
   LEFT JOIN MAS.BusinessUnits bu on rbu.BusinessId = bu.ESABusinessUnitID              
   Where map.Sbu1Id is null  
    AND (rbu.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR bu.BusinessUnitID IS NULL) THEN rbu.LastUpdatedDateTime ELSE @LastSuccessDate END)              
    OR map.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR bu.BusinessUnitID IS NULL) THEN map.LastUpdatedDateTime ELSE @LastSuccessDate END)              
    OR rmu.ModifiedDate > @LastSuccessDate)              
   ) AS S               
  ON T.ESABusinessUnitID = S.BusinessId               
  WHEN NOT MATCHED BY TARGET              
  AND S.ActiveFlag = 1 AND S.MarketUnitID is NOT NULL              
  THEN INSERT (BusinessUnitName, ESABusinessUnitID, MarketUnitID, CreatedBy, CreatedDate)              
  VALUES (S.BusinessName, S.BusinessId, S.MarketUnitID, @UserName, @Date)               
  WHEN MATCHED               
  THEN UPDATE              
  SET T.BusinessUnitName = S.BusinessName,              
   T.IsDeleted = (CASE WHEN S.ActiveFlag = 0 THEN 1 ELSE 0 END),              
   T.ModifiedBy = @UserName,              
   T.ModifiedDate = @Date;              
              
  /* Sub Business Unit 1 data merge from gateway table*/              
  MERGE MAS.SubBusinessUnits1 AS T              
  USING (              
   Select distinct sbu.Sbu1Name, sbu.Sbu1Id, bu.BusinessUnitID,(CASE WHEN (sbu.ActiveFlag=1 AND bu.IsDeleted=0) THEN 1 ELSE 0 END) AS ActiveFlag , sbu.LastUpdatedDateTime              
   FROM [$(AVMCOEESADB)].[dbo].[RHMSSubBusinessUnit1] sbu              
   LEFT JOIN [$(AVMCOEESADB)].[dbo].[RHMSCustomerBUHierarchyMapping] map on map.Sbu1Id = sbu.Sbu1Id AND map.ActiveFlag = 1 AND ISNULL(map.MarketID,'') <> ''              
   LEFT JOIN [$(AVMCOEESADB)].[dbo].[RHMSBusinessUnit] rbu on map.BusinessId = rbu.BusinessId              
   LEFT JOIN MAS.BusinessUnits bu on rbu.BusinessId = bu.ESABusinessUnitID              
   LEFT JOIN MAS.SubBusinessUnits1 sbu1 on sbu.Sbu1Id = sbu1.ESASBU1ID              
   WHERE map.[Sbu2Id] is NULL   
    AND (sbu.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR sbu1.SBU1ID IS NULL) THEN sbu.LastUpdatedDateTime ELSE @LastSuccessDate END)              
    OR map.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR sbu1.SBU1ID IS NULL) THEN map.LastUpdatedDateTime ELSE @LastSuccessDate END)              
    OR bu.ModifiedDate > @LastSuccessDate)              
  ) AS S               
  ON T.ESASBU1ID = S.Sbu1Id               
  WHEN NOT MATCHED BY TARGET              
  AND S.ActiveFlag = 1 AND S.BusinessUnitID is NOT NULL              
  THEN INSERT (SBU1Name, ESASBU1ID, BusinessUnitID, CreatedBy, CreatedDate)              
  VALUES (S.Sbu1Name, S.Sbu1Id, S.BusinessUnitID, @UserName, @Date)               
  WHEN MATCHED               
  THEN UPDATE              
  SET T.SBU1Name = S.Sbu1Name,              
   T.IsDeleted = (CASE WHEN S.ActiveFlag = 0 THEN 1 ELSE 0 END),              
   T.ModifiedBy = @UserName,              
   T.ModifiedDate = @Date;              
              
  /* Sub Business Unit 1 data merge from gateway table*/              
  MERGE MAS.SubBusinessUnits2 AS T          
  USING (              
   SELECT distinct sbu.Sbu2Name, sbu.Sbu2Id, sbu1.SBU1ID, (CASE WHEN (sbu.ActiveFlag=1 AND sbu1.IsDeleted=0) THEN 1 ELSE 0 END) AS ActiveFlag, sbu.LastUpdatedDateTime              
   FROM [$(AVMCOEESADB)].[dbo].[RHMSSubBusinessUnit2] sbu              
   LEFT JOIN [$(AVMCOEESADB)].[dbo].[RHMSCustomerBUHierarchyMapping] map on map.Sbu2Id = sbu.Sbu2Id AND map.ActiveFlag = 1 AND ISNULL(map.MarketID,'') <> ''              
   LEFT JOIN MAS.SubBusinessUnits1 sbu1 on map.Sbu1Id = sbu1.ESASBU1ID              
   LEFT JOIN MAS.SubBusinessUnits2 sbu2 on sbu.Sbu2Id = sbu2.ESASBU2ID              
   WHERE  (sbu.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR sbu2.SBU2ID IS NULL) THEN sbu.LastUpdatedDateTime ELSE @LastSuccessDate END)              
    OR map.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR sbu2.SBU2ID IS NULL) THEN map.LastUpdatedDateTime ELSE @LastSuccessDate END)              
    OR sbu1.ModifiedDate > @LastSuccessDate)    
  ) AS S               
  ON T.ESASBU2ID = S.Sbu2Id               
  WHEN NOT MATCHED BY TARGET              
  AND S.ActiveFlag = 1 AND S.Sbu1Id is NOT NULL              
  THEN INSERT (SBU2Name, ESASBU2ID, SBU1ID, CreatedBy, CreatedDate)              
  VALUES (S.Sbu2Name, S.Sbu2Id, S.SBU1ID, @UserName, @Date)               
  WHEN MATCHED               
  THEN UPDATE              
  SET T.SBU2Name = S.Sbu2Name,              
   T.IsDeleted = (CASE WHEN S.ActiveFlag = 0 THEN 1 ELSE 0 END),              
   T.ModifiedBy = @UserName,              
   T.ModifiedDate = @Date;       
             
  /*Industry Segment data merge from gateway table*/              
  MERGE MAS.IndustrySegments AS T              
   USING (SELECT ins.IndustrySegmentId,ins.IndustrySegmentName,ins.ActiveFlag  FROM [$(AVMCOEESADB)].[dbo].[RHMSIndustrySegment] ins              
    LEFT JOIN MAS.IndustrySegments ains ON ains.ESAIndustrySegmentId=ins.IndustrySegmentId              
    WHERE  ins.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR ains.IndustrySegmentId IS NULL) THEN ins.LastUpdatedDateTime ELSE @LastSuccessDate END )              
    ) AS S              
   ON T.ESAIndustrySegmentId = S.IndustrySegmentId              
   WHEN NOT MATCHED BY TARGET              
   AND S.ActiveFlag = 1              
   THEN INSERT (IndustrySegmentName, ESAIndustrySegmentId, CreatedBy, CreatedDate)              
   VALUES (S.IndustrySegmentName, S.IndustrySegmentId, @UserName, @Date)              
   WHEN MATCHED              
   THEN UPDATE              
     SET T.IndustrySegmentName = S.IndustrySegmentName,              
      T.IsDeleted = (CASE WHEN S.ActiveFlag = 0 THEN 1 ELSE 0 END),              
      T.ModifiedBy = @UserName,              
         T.ModifiedDate = @Date;              
              
  /* Vertical data merge from gateway table */              
   MERGE MAS.Verticals AS T              
   USING (SELECT rv.VerticalName,rv.VerticalID,rv.LOBId,(CASE WHEN (rv.ActiveFlag=1 AND ins.IsDeleted=0) THEN 1 ELSE 0 END) AS ActiveFlag,               
    ins.IndustrySegmentId               
    FROM [$(AVMCOEESADB)].[dbo].[RHMSVertical] rv              
    INNER JOIN [$(AVMCOEESADB)].[dbo].[RHMSVerticalHierarchyMapping] map ON map.VerticalId=rv.VerticalId and  map.ActiveFlag=1 and map.SubVerticalId is null              
    INNER JOIN MAS.IndustrySegments ins ON ins.ESAIndustrySegmentId = map.IndustrySegmentId              
    LEFT JOIN MAS.Verticals v ON v.ESAVerticalID=rv.VerticalID              
    WHERE  (rv.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR v.VerticalID IS NULL) THEN rv.LastUpdatedDateTime ELSE @LastSuccessDate END )              
    OR map.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR v.VerticalID IS NULL  OR v.IndustrySegmentId IS NULL) THEN map.LastUpdatedDateTime ELSE @LastSuccessDate END)              
    OR ins.ModifiedDate > @LastSuccessDate)              
    ) AS S              
   ON T.ESAVerticalID = S.VerticalID              
   WHEN NOT MATCHED BY TARGET              
   AND S.ActiveFlag = 1              
   THEN INSERT (VerticalName, ESAVerticalID, LOBID,CreatedBy, CreatedDate, IndustrySegmentId)              
   VALUES (S.VerticalName, S.VerticalID,s.LOBId, @UserName, @Date, S.IndustrySegmentId)              
   WHEN MATCHED              
   THEN UPDATE              
     SET T.VerticalName = S.VerticalName,              
      T.LOBID=S.LOBID,              
      T.IsDeleted = (CASE WHEN S.ActiveFlag = 0 THEN 1 ELSE 0 END),              
      T.ModifiedBy = @UserName,              
         T.ModifiedDate = @Date,              
      T.IndustrySegmentId = S.IndustrySegmentId;              
              
  /* SubVertical data merge from gateway table */              
  MERGE MAS.SubVerticals AS T              
  USING (SELECT rsv.SubVerticalId,rsv.SubVerticalName,v.VerticalID,(CASE WHEN (rsv.ActiveFlag=1 AND v.IsDeleted=0) THEN 1 ELSE 0 END) AS ActiveFlag               
      from [$(AVMCOEESADB)].[dbo].[RHMSSubVertical] rsv              
      INNER JOIN [$(AVMCOEESADB)].[dbo].[RHMSVerticalHierarchyMapping] map               
      ON map.SubVerticalId=rsv.SubVerticalId and  map.ActiveFlag=1              
      INNER JOIN MAS.Verticals v              
      ON v.ESAVerticalID=map.VerticalId               
      LEFT  JOIN MAS.SubVerticals sv               
      ON sv.ESASubVerticalID=rsv.SubVerticalID              
      WHERE  (rsv.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR sv.SubVerticalID IS NULL) THEN rsv.LastUpdatedDateTime ELSE @LastSuccessDate END)              
      OR map.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR sv.SubVerticalID IS NULL) THEN map.LastUpdatedDateTime ELSE @LastSuccessDate END)              
      OR v.ModifiedDate > @LastSuccessDate)               
      ) AS S              
     ON T.ESASubVerticalID = S.SubVerticalID              
  WHEN NOT MATCHED BY TARGET               
    AND S.ActiveFlag = 1             
  THEN INSERT (SubVerticalName, ESASubVerticalID,VerticalID, CreatedBy, CreatedDate)              
  VALUES (S.SubVerticalName, S.SubVerticalID,S.VerticalID, @UserName, @Date)              
  WHEN MATCHED              
  THEN UPDATE              
    SET T.SubVerticalName = S.SubVerticalName,              
     T.VerticalID=S.VerticalID,               
     T.IsDeleted = (CASE WHEN S.ActiveFlag = 0 THEN 1 ELSE 0 END),              
     T.ModifiedBy =@UserName,              
     T.ModifiedDate = @Date;               
              
  /* Parent Customer data merge from gateway table*/              
  MERGE MAS.ParentCustomers AS T              
  USING (              
   SELECT rpc.Financial_Ultimate_Customer_Id__C, rpc.[Name], rpc.Marked_For_Delete__C  FROM [$(AVMCOEESADB)].[dbo].[RHMSParentCustomer] rpc              
   LEFT JOIN MAS.ParentCustomers pc on rpc.Financial_Ultimate_Customer_Id__C = ESAParentCustomerID              
   WHERE rpc.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR pc.ParentCustomerID IS NULL) THEN rpc.LastUpdatedDateTime ELSE @LastSuccessDate END)              
   ) AS S               
  ON T.ESAParentCustomerID = S.Financial_Ultimate_Customer_Id__C               
  WHEN NOT MATCHED BY TARGET              
  AND S.Marked_For_Delete__C = 0              
  THEN INSERT (ParentCustomerName, ESAParentCustomerID, CreatedBy, CreatedDate)              
  VALUES (S.[Name], S.Financial_Ultimate_Customer_Id__C, @UserName, @Date)               
  WHEN MATCHED               
  THEN UPDATE              
  SET T.ParentCustomerName = S.[Name],              
   T.IsDeleted = Marked_For_Delete__C,              
   T.ModifiedBy = @UserName,              
   T.ModifiedDate = @Date;       
              
              
  /* Customer data merge from gateway table*/              
  MERGE AVL.Customer AS T              
  USING (SELECT RTRIM(LTRIM(ra.Name)) Name, RTRIM(LTRIM(ra.Peoplesoft_Customer_Id__C)) Peoplesoft_Customer_Id__C,             
  pc.ParentCustomerID, bu.BusinessUnitID, sbu1.SBU1ID, sbu2.SBU2ID, v.VerticalID, sv.SubVerticalID,              
  (CASE WHEN (ra.Crm_Status__C='Active' AND bu.IsDeleted=0 AND v.IsDeleted=0 AND ISNULL(pc.IsDeleted,0)=0 AND ISNULL(sv.IsDeleted,0)=0 AND ISNULL(sbu2.IsDeleted,0)=0) THEN 1 ELSE 0 END) As ActiveFlag, ra.LastUpdatedDateTime               
   FROM [$(AVMCOEESADB)].[dbo].[RHMSAccount] ra            
   --INNER JOIN MAS.SubBusinessUnits1 sbu1 on ra.SBU1_Id__c = sbu1.ESASBU1ID              
   INNER JOIN MAS.BusinessUnits bu on bu.ESABusinessUnitID = ra.BU_Id__c              
   INNER JOIN MAS.Verticals v on ra.RHMS_Vertical_Id__c = v.ESAVerticalID            
   LEFT JOIN MAS.SubBusinessUnits1 sbu1 on ra.SBU1_Id__c = sbu1.ESASBU1ID and sbu1.IsDeleted=0             
   LEFT JOIN MAS.ParentCustomers pc on ra.Financial_Ultimate_Customer_Id__C= pc.ESAParentCustomerID              
   LEFT JOIN MAS.SubBusinessUnits2 sbu2 on ra.SBU2_Id__c = sbu2.ESASBU2ID              
   LEFT JOIN MAS.SubVerticals sv on ra.Sub_vertical_Id__c = sv.ESASubVerticalID              
   LEFT JOIN AVL.Customer c on ra.Peoplesoft_Customer_Id__C = c.ESA_AccountID              
   WHERE (ra.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR c.CustomerID IS NULL) THEN ra.LastUpdatedDateTime ELSE @LastSuccessDate END)              
       OR v.ModifiedDate  > @LastSuccessDate              
       OR pc.ModifiedDate  > @LastSuccessDate              
       OR bu.ModifiedDate   > @LastSuccessDate              
       OR sbu1.ModifiedDate   > @LastSuccessDate              
       OR sbu2.ModifiedDate  > @LastSuccessDate              
       OR sv.ModifiedDate  > @LastSuccessDate)              
   ) AS S               
  ON T.ESA_AccountID = S.Peoplesoft_Customer_Id__C               
  WHEN NOT MATCHED BY TARGET              
   AND S.ActiveFlag = 1              
  THEN INSERT (CustomerName, ESA_AccountID, ParentCustomerID, BusinessUnitID, SBU1ID, SBU2ID, VerticalID, SubVerticalID, CreatedBy, CreatedDate,              
   IsDeleted, IsCognizant, isDaily)              
   VALUES (S.[Name], S.Peoplesoft_Customer_Id__C, S.ParentCustomerID, S.BusinessUnitID, S.SBU1ID, S.SBU2ID, S.VerticalID, S.SubVerticalID,              
   @UserName, @Date, 0, 1, 0)               
  WHEN MATCHED               
  THEN UPDATE              
   SET T.CustomerName = S.[Name],              
    T.ParentCustomerID = S.ParentCustomerID,              
    T.BusinessUnitID = S.BusinessUnitID,              
    T.SBU1ID = S.SBU1ID,              
    T.SBU2ID = S.SBU2ID,              
    T.VerticalID = S.VerticalID,              
    T.SubVerticalID = S.SubVerticalID,              
    T.IsDeleted = (CASE WHEN S.ActiveFlag = 1 THEN 0 ELSE 1 END),              
    T.ModifiedBy = @UserName,              
    T.ModifiedDate = @Date;              
              
 /* Practice table Data Merge from Gateway table  */              
  MERGE MAS.Practices AS T              
  USING (SELECT rp.Horizontal_Code,rp.HorizontalDesc,rp.Status FROM  [$(AVMCOEESADB)].[dbo].[RHMSPractice] rp              
      LEFT JOIN MAS.Practices p ON p.ESAHorizontalCode=rp.Horizontal_Code               
      WHERE rp.LastUpdatedDateTime >= (CASE WHEN (@LastSuccessDate IS NULL OR p.PracticeID IS NULL) THEN rp.LastUpdatedDateTime ELSE @LastSuccessDate END)              
     )AS S   
  ON T.ESAHorizontalCode = S.Horizontal_Code              
  WHEN NOT MATCHED BY TARGET              
  AND S.Status = 'A'              
  THEN INSERT (PracticeName, ESAHorizontalCode, CreatedBy, CreatedDate)              
  VALUES (S.HorizontalDesc, S.Horizontal_Code, @USerName, @Date)              
  WHEN MATCHED              
  THEN UPDATE              
    SET T.PracticeName = S.HorizontalDesc,              
     T.IsDeleted = (CASE WHEN S.Status = 'I' THEN 1 ELSE 0 END),              
     T.ModifiedBy =  @USerName,              
     T.ModifiedDate = @Date;              
              
  /* Projects Data merge from Gateway table */              
  MERGE AVL.MAS_projectMaster AS T              
  USING (SELECT distinct RTRIM(LTRIM(proj.Project_ID)) Project_ID,RTRIM(LTRIM(proj.Project_Name)) Project_Name,proj.Status,proj.Project_Start_Date,            
   proj.Project_End_Date, cust.CustomerID,cust.IsDeleted,              
      proj.Account_Manager_ID,Proj.DeliveryManagerId,Project_Category,Sub_Category,Project_Owner              
      ,pm.PROJECT_MANAGER, proj.Bill_Type              
                    
         FROM  [$(AVMCOEESADB)].[dbo].[RHMSProject] Proj              
        INNER JOIN AVL.Customer cust              
         ON cust.Esa_AccountId = proj.Customer_ID               
   LEFT JOIN [$(AVMCOEESADB)].[dbo].[RHMSprojectManager] pm               
         ON pm.PROJECT_ID = Proj.Project_ID               
        LEFT JOIN AVL.MAS_projectMaster pro               
         ON pro.ESAProjectID = proj.Project_ID               
      ) AS S              
   ON T.ESAProjectID = S.Project_ID              
  WHEN NOT MATCHED BY TARGET              
       AND S.Status = 'A' AND s.IsDeleted = 0              
  THEN INSERT ( ESAProjectID, ProjectName,ProjectStartDate,ProjectEndDate,CustomerID,              
      AccountManagerID,DeliveryManagerID,              
      ProjectCategory,SubCategory,ProjectOwner,CreatedBy,CreateDate,ProjectManagerID, BillType,              
      IsDeleted, IsESAProject, IsCoginzant)              
              
    VALUES ( S.Project_ID, S.Project_Name,S.Project_Start_Date,S.Project_End_Date,S.CustomerID,              
      S.Account_Manager_ID,S.DeliveryManagerId,              
      S.Project_Category,S.Sub_Category,S.Project_Owner,@UserName, @Date,S.PROJECT_MANAGER, S.Bill_Type, 0, 1, 1)              
  WHEN MATCHED              
  THEN UPDATE              
    SET T.ProjectName = S.Project_Name,              
     T.ProjectStartDate = S.Project_Start_Date,              
     T.ProjectEndDate = S.Project_End_Date,              
     T.BillType = S.Bill_Type,              
     --T.CustomerID = S.CustomerID,    //Commented as part of CustomerID issue fix for ProjectID --CustomerID will not be updated going forward          
     T.AccountManagerID = S.Account_Manager_ID,              
     T.ProjectManagerID = S.PROJECT_MANAGER,              
     T.DeliveryManagerID = S.DeliveryManagerID,              
     T.ProjectOwner = S.Project_Owner,              
     T.ProjectCategory = S.Project_Category,              
     T.SubCategory = S.Sub_Category,              
     T.IsDeleted = (CASE WHEN (S.Status = 'A' AND S.IsDeleted = 0) THEN 0 ELSE 1 END),              
     T.ModifiedBy = @UserName,              
     T.ModifiedDate = @Date;              
              
  /* ProjectPracticeMapping table data merge from Gateway */              
  --MERGE MAS.ProjectPracticeMapping AS T              
  --USING (SELECT practice.PracticeID,Project.ProjectID,practice.IsDeleted as PracticeDeletedFlag,project.IsDeleted as projectDeletedFlag               
  --from  [$(AVMCOEESADB)].[dbo].[RHMSPracticeProjectMapping] map              
  --    INNER JOIN MAS.Practices practice              
  --    ON Practice.ESAHorizontalCode=map.Practiceid              
  --    INNER JOIN AVL.MAS_projectMaster project              
  --    ON project.ESAProjectID=map.Projectid               
  --    ) AS S              
  --    ON T.PracticeID = S.PracticeID and T.ProjectID = S.ProjectID              
  --WHEN NOT MATCHED BY TARGET              
  --  AND S.PracticeDeletedFlag = 0 and S.ProjectDeletedFlag=0              
  --THEN INSERT (PracticeID,ProjectID, CreatedBy, CreatedDate)              
  --  VALUES (S.PracticeID, S.ProjectID,@UserName, @Date)              
  --WHEN NOT MATCHED BY SOURCE              
  --  AND T.IsDeleted=0              
  --THEN UPDATE               
  --  SET T.IsDeleted = 1,              
  --   T.ModifiedBy = @UserName,              
  --   T.ModifiedDate = @Date              
  --WHEN MATCHED              
  --  AND T.IsDeleted <> (CASE WHEN (S.ProjectDeletedFlag = 0 and S.PracticeDeletedFlag=0) THEN 0 ELSE 1 END)              
  --THEN UPDATE              
  --  SET               
  --  T.IsDeleted = (CASE WHEN (S.ProjectDeletedFlag = 0 and S.PracticeDeletedFlag=0) THEN 0 ELSE 1 END),              
  --  T.ModifiedBy = @UserName,              
  --  T.ModifiedDate = @Date;               
      /* Dynamic ProjectPracticeMapping table data merge from Mainspring, OPL and CRS Gateway - Updated Version*/              
   TRUNCATE TABLE MAS.PROJECTPRACTICEMAPPING          
          
 Insert into MAS.PROJECTPRACTICEMAPPING          
 Select DISTINCT  MAS.PROJECTID,   CASE WHEN ms.PROJECTOwningUnit IS NOT NULL THEN PR.PRACTICEID           
  ELSE           
 CASE           
 WHEN (OPL.[Project_Owning_Unit] IS NOT NULL AND OPL.[Project_Owning_Unit]!='NULL') THEN PR.PRACTICEID           
 ELSE CASE WHEN CRS.PRACTICEID IS NOT NULL THEN PR.PRACTICEID           
  ELSE 0 END--NO Practice Availability for a Project          
 END           
  END AS PRACTICEID , 0 as IsDeleted, 'System' as CreatedBy,GetDate() as CreatedDate,NULL,NULL          
   FROM AVL.MAS_PROJECTMASTER MAS             
  LEFT JOIN MS.ProjectRegistrationDetails MS ON  MS.ESAPROJECTID=MAS.ESAPROJECTID          
  LEFT JOIN [dbo].[OPLMasterdata] OPL ON [OPL].[ESA_Project_ID] =MAS.ESAPROJECTID           
  LEFT JOIN [$(AVMCOEESADB)].[dbo].[RHMSPracticeProjectMapping] CRS ON CRS.PROJECTID=MAS.ESAPROJECTID          
  JOIN MAS.PRACTICES PR ON PR.ESAHORIZONTALCODE=CRS.PRACTICEID OR PR.PRACTICENAME=MS.PROJECTOWNINGUNIT OR PR.PRACTICENAME=OPL.[Project_Owning_Unit]          
   AND PR.ISDELETED=0          
  WHERE MAS.ISDELETED=0 ORDER BY MAS.PROJECTID           
          
  /* Truncate and Load RLE.MasterHierarchy*/              
  IF EXISTS (SELECT TOP 1 1              
   FROM    MAS.Markets m              
   JOIN MAS.MarketUnits mu ON m.MarketID = mu.MarketID AND mu.IsDeleted = 0              
   JOIN MAS.BusinessUnits bu ON mu.MarketUnitID = bu.MarketUnitID AND bu.IsDeleted = 0              
   JOIN MAS.SubBusinessUnits1 sbu1 ON bu.BusinessUnitID = sbu1.BusinessUnitID AND sbu1.IsDeleted = 0              
   JOIN AVL.Customer cu ON cu.SBU1ID = sbu1.SBU1ID  AND cu.IsDeleted = 0              
   JOIN MAS.Verticals v ON cu.VerticalID = v.VerticalID AND v.IsDeleted = 0              
   JOIN MAS.IndustrySegments ins ON ins.IndustrySegmentId = v.IndustrySegmentId AND ins.IsDeleted = 0              
   LEFT JOIN MAS.SubBusinessUnits2 sbu2 ON cu.SBU2ID = sbu2.SBU2ID AND sbu2.IsDeleted = 0                              
   LEFT JOIN MAS.ParentCustomers pcu ON cu.ParentCustomerID = pcu.ParentCustomerID AND pcu.IsDeleted = 0              
   LEFT JOIN MAS.SubVerticals sv ON cu.SubVerticalID = sv.SubVerticalID AND sv.IsDeleted = 0              
   LEFT JOIN AVL.MAS_projectMaster p ON cu.CustomerID = p.CustomerID AND p.IsDeleted = 0              
   LEFT JOIN MAS.ProjectPracticeMapping ppm ON p.ProjectID = ppm.ProjectID AND ppm.IsDeleted = 0              
   LEFT JOIN MAS.Practices pc ON ppm.PracticeID = pc.PracticeID AND pc.IsDeleted = 0              
   WHERE   M.IsDeleted = 0 )              
  BEGIN              
   TRUNCATE TABLE RLE.MasterHierarchy              
              
   INSERT INTO RLE.MasterHierarchy              
   SELECT DISTINCT m.MarketID, m.MarketName, mu.MarketUnitID, mu.MarketUnitName,               
 bu.BusinessUnitID, bu.BusinessUnitName,               
   sbu1.SBU1ID, sbu1.SBU1Name, sbu2.SBU2ID, sbu2.SBU2Name,              
   v.VerticalID, v.VerticalName,sv.SubVerticalID, sv.SubVerticalName,              
   pcu.ParentCustomerID, pcu.ParentCustomerName, cu.CustomerID, cu.CustomerName,              
   cu.ESA_AccountId ESACustomerID,pc.PracticeID,pc.PracticeName,              
   p.ProjectID, p.ProjectName, p.ESAProjectID, ins.IndustrySegmentId, ins.IndustrySegmentName              
   FROM    MAS.Markets m              
   JOIN MAS.MarketUnits mu ON m.MarketID = mu.MarketID AND mu.IsDeleted = 0              
   JOIN MAS.BusinessUnits bu ON mu.MarketUnitID = bu.MarketUnitID AND bu.IsDeleted = 0              
   --JOIN MAS.SubBusinessUnits1 sbu1 ON bu.BusinessUnitID = sbu1.BusinessUnitID AND sbu1.IsDeleted = 0              
   JOIN AVL.Customer cu ON cu.BusinessUnitID = bu.BusinessUnitID  AND cu.IsDeleted = 0              
   JOIN MAS.Verticals v ON cu.VerticalID = v.VerticalID AND v.IsDeleted = 0              
   JOIN MAS.IndustrySegments ins ON ins.IndustrySegmentId = v.IndustrySegmentId AND ins.IsDeleted = 0           
   LEFT JOIN MAS.SubBusinessUnits1 sbu1 ON cu.SBU1ID = sbu1.SBU1ID AND sbu1.IsDeleted = 0              
   LEFT JOIN MAS.SubBusinessUnits2 sbu2 ON cu.SBU2ID = sbu2.SBU2ID AND sbu2.IsDeleted = 0                              
   LEFT JOIN MAS.ParentCustomers pcu ON cu.ParentCustomerID = pcu.ParentCustomerID AND pcu.IsDeleted = 0              
   LEFT JOIN MAS.SubVerticals sv ON cu.SubVerticalID = sv.SubVerticalID AND sv.IsDeleted = 0              
   LEFT JOIN AVL.MAS_projectMaster p ON cu.CustomerID = p.CustomerID AND p.IsDeleted = 0              
   LEFT JOIN MAS.ProjectPracticeMapping ppm ON p.ProjectID = ppm.ProjectID AND ppm.IsDeleted = 0             
   LEFT JOIN MAS.Practices pc ON ppm.PracticeID = pc.PracticeID AND pc.IsDeleted = 0              
   WHERE M.IsDeleted = 0              
              
  END              
              
/* Business Cluster Data merge from AVL.Customer table */              
            
      /* 1. LOB Cluster*/            
MERGE AVL.BusinessCluster AS T            
USING AVL.Customer S ON T.CustomerID = S.CustomerID AND T.BusinessClusterName = @LOBCluster          
WHEN NOT MATCHED   BY TARGET AND S.IsDeleted=0           
THEN INSERT             
(              
        [BusinessClusterName],              
        [ParentBusinessClusterID],              
        [IsHavingSubBusinesss],              
        [IsDeleted],              
        [CustomerID],              
        [CreatedBy],              
        [CreatedDate]              
)            
VALUES(@LOBCluster, NULL, 1, 0, S.CustomerID, @UserName,@Date);            
            
      /* 2. Portfolio Cluster*/            
MERGE AVL.BusinessCluster AS T            
USING (Select C.CustomerID,BusinessClusterId,C.IsDeleted from AVL.Customer C             
       INNER JOIN AVL.BusinessCluster BC ON C.CustomerID = BC.CustomerID AND BC.BusinessClusterName = @LOBCluster          
)AS S ON T.CustomerID = S.CustomerID AND T.ParentBusinessClusterID = S.BusinessClusterId AND T.BusinessClusterName = @PortfolioCluster          
WHEN NOT MATCHED  BY TARGET AND S.IsDeleted=0          
THEN INSERT             
 (              
        [BusinessClusterName],              
        [ParentBusinessClusterID],              
        [IsHavingSubBusinesss],              
        [IsDeleted],              
        [CustomerID],              
        [CreatedBy],              
        [CreatedDate]              
       )              
       VALUES(@PortfolioCluster, S.BusinessClusterId, 1, 0, S.CustomerID, @UserName, @Date);            
            
   /* 3. App Group Cluster*/            
MERGE AVL.BusinessCluster AS T            
USING (Select C.CustomerID,BusinessClusterId,C.Isdeleted from AVL.Customer C             
       INNER JOIN AVL.BusinessCluster BC ON C.CustomerID = BC.CustomerID AND BC.BusinessClusterName = @PortfolioCluster          
)AS S ON T.CustomerID = S.CustomerID AND T.ParentBusinessClusterID = S.BusinessClusterId AND T.BusinessClusterName = @AppGroupCluster              
WHEN NOT MATCHED  BY TARGET AND S.IsDeleted=0          
THEN INSERT             
 (              
        [BusinessClusterName],              
        [ParentBusinessClusterID],              
        [IsHavingSubBusinesss],              
        [IsDeleted],              
        [CustomerID],              
        [CreatedBy],              
        [CreatedDate]              
       )              
       VALUES(@AppGroupCluster, S.BusinessClusterId, 0, 0, S.CustomerID, @UserName, @Date);            
            
/* ConfigurationProgress Data merge from AVL.Customer table */              
MERGE AVL.PRJ_ConfigurationProgress T            
USING  AVL.Customer S ON T.CustomerID = S.CustomerID AND T.ScreenID = 1          
WHEN NOT MATCHED BY TARGET AND S.IsDeleted=0          
THEN INSERT          (              
        CustomerID,              
        ScreenID,              
        CompletionPercentage,              
        IsDeleted,              
        CreatedBy,              
        CreatedDate)              
       VALUES (S.CustomerID, 1, 25, 0, @UserName, @Date);            
  COMMIT TRANSACTION              
              
  UPDATE MAS.JobStatus Set JobStatus = @JobStatusSuccess, EndDateTime = GETDATE() WHERE ID = @JobStatusId      
      
 SELECT @MailSubject = CONCAT(@@servername, ':  RHMS_Role_hierarchy_Level_Master_Sync Job Success Notification')           
          
SET @MailContent = 'RHMS_Role_hierarchy_Level_Master_Sync job has been completed successfully.'            
        
SELECT @MailBody =  [dbo].[fn_FmtEmailBody_Message](@MailContent)        
        
EXEC [AVL].[SendDBEmail] @To='AVMDARTL2@cognizant.com',
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody
               
 END TRY              
 BEGIN CATCH              
  Print 'Error'              
  IF (XACT_STATE()) = -1                
  BEGIN                
   ROLLBACK TRANSACTION;                
  END;                
  IF (XACT_STATE()) = 1                
  BEGIN                
   COMMIT TRANSACTION;                   
  END;              
  UPDATE MAS.JobStatus Set JobStatus = @JobStatusFail, EndDateTime = GETDATE() WHERE ID = @JobStatusId              
              
  DECLARE @HostName NVARCHAR(50);              
  DECLARE @Associate NVARCHAR(50);              
  DECLARE @ErrorCode NVARCHAR(50);              
  DECLARE @ErrorMessage NVARCHAR(MAX);              
  DECLARE @ModuleName VARCHAR(30)='RoleAPI';              
  DECLARE @DbName VARCHAR(30)='AppVisionLens';              
  DECLARE @getdate  DATETIME=GETDATE();              
  DECLARE @DbObjName VARCHAR(50)=(OBJECT_NAME(@@PROCID));              
  SET @HostName=(SELECT HOST_NAME());              
  SET @Associate=(SELECT SUSER_NAME());              
  SET @ErrorCode=(SELECT ERROR_NUMBER());              
  SET @ErrorMessage=(SELECT ERROR_MESSAGE());              
              
              
  EXEC AppVisionLensLogging.[dbo].[InsertLog] 'Critical','ERROR',@HostName,@Associate,@getdate,NULL,'SQL',              
             @ModuleName,@JobName,@DbName,@DbObjName,@@SPID,@ErrorCode,@ErrorMessage,              
             @JobStatusFail,NULL,NULL         
        
DECLARE @MailSubject_NoData NVARCHAR(500);          
DECLARE @MailBody_NoData NVARCHAR(MAX);            
DECLARE @MailContent_NoData NVARCHAR(500);        
        
SELECT @MailSubject_NoData = CONCAT(@@servername, ':  RHMS_Role_hierarchy_Level_Master_Sync Job Notification')           
        
SET @MailContent_NoData = 'RHMS_Role_hierarchy_Level_Master_Sync job failed and data did not refresh'        
        
SELECT @MailBody_NoData =  [dbo].[fn_FmtEmailBody_Message](@MailContent_NoData)        
        
EXEC [AVL].[SendDBEmail] @To='AVMDARTL2@cognizant.com',
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody          
        
    
    
    
 END CATCH              
END 

