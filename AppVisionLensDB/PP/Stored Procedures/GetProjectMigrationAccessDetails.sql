  CREATE Procedure PP.GetProjectMigrationAccessDetails         
  @LevelId nvarchar(100)='',        
  @AccessLevel varchar(20)=''        
  as        
  BEGIN         
  If(@AccessLevel='BU')        
  BEGIN        
        
  SELECT DISTINCT BU.BUID as Id,BU.BUName as Name                
   FROM AVL.BusinessUnit(NOLOCK) BU                    
   WHERE  IsDeleted=0   ORDER BY BU.BUName     
  END        
        
  IF(@AccessLevel='AccountLevel')        
        
  BEGIN        
        
  SELECT DISTINCT trim(C.ESA_AccountID) as Id,C.CustomerName as Name         
  FROM AVL.Customer(NOLOCK) C             
   Inner JOIn AVL.BusinessUnit(NOLOCK) BU ON C.BUID=BU.BUID AND BU.IsDeleted=0          
   WHERE  C.IsDeleted=0 and BU.Isdeleted=0 and BU.BUID=@LevelId  AND C.ESA_AccountID IS NOT NULL      
     ORDER BY C.CustomerName      
  END        
        
  IF(@AccessLevel='AllProjectLevel')        
   BEGIN        
        
  SELECT DISTINCT Trim(PM.ESAProjectID) AS ID,PM.ProjectName  AS [Name]         
    FROM AVL.MAS_ProjectMaster(NOLOCK) PM           
    INNER JOIN AVL.Customer(NOLOCK) C ON PM.CustomerID=C.CustomerID AND C.IsDeleted=0                
    INNER JOIN AVL.BusinessUnit(NOLOCK) BU ON C.BUID=BU.BUID AND BU.IsDeleted=0           
   WHERE  C.IsDeleted=0 and BU.Isdeleted=0 and C.ESA_AccountID=@LevelId        
    ORDER BY PM.ProjectName        
  END        
        
        
  IF(@AccessLevel='ActiveProjectLevel')        
    BEGIN        
        
  SELECT DISTINCT trim(PM.ESAProjectID) AS ID,PM.ProjectName  AS [Name]         
    FROM AVL.MAS_ProjectMaster(NOLOCK) PM           
    INNER JOIN AVL.Customer(NOLOCK) C ON PM.CustomerID=C.CustomerID AND C.IsDeleted=0                
    INNER JOIN AVL.BusinessUnit(NOLOCK) BU ON C.BUID=BU.BUID AND BU.IsDeleted=0           
   WHERE  C.IsDeleted=0 and BU.Isdeleted=0 and PM.Isdeleted=0 and C.ESA_AccountID=@LevelId        
    ORDER BY PM.ProjectName     
 END        
        
        
  END
