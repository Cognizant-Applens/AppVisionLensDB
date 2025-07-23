-- =============================================                
-- Author:  Janani                
-- Create date: 03-11-2022                
-- Description: Stop Words for Download Excel                
-- =============================================                
CREATE PROCEDURE [ML].[GetStopWords] --237653,-1,1                
 -- Add the parameters for the stored procedure here                
  @ProjectId BIGINT                    
 ,@downloadMode INT                 
 ,@UIorExcel INT                
AS                
BEGIN                
IF @UIorExcel=0 --For Excel Download                
BEGIN                
 -- SET NOCOUNT ON added to prevent extra result sets from                
 -- interfering with SELECT statements.                
 SET NOCOUNT ON;                
                
  IF @downloadMode = 1 -- App Support                                       
  BEGIN                 
                
   SELECT 'All' AS 'Application Name',StopWords AS 'Stop Word for Issue Description',Frequency,SW.IsActive AS 'IsStop*' FROM ML.TRN_StopWords SW                   
    WHERE SW.projectID = @ProjectId AND IsDeleted=0 AND StopWordKey='SW001' AND IsAppInfra=1                
 AND ApplicationId IS NULL and TowerId IS NULL                
 Union                
   SELECT AD.ApplicationName AS 'Application Name',StopWords AS 'Stop Word for Issue Description',Frequency,SW.IsActive AS 'IsStop*' FROM ML.TRN_StopWords SW                
 JOIN [AVL].[APP_MAS_ApplicationDetails] AD ON SW.ApplicationID = AD.ApplicationID                    
    WHERE SW.projectID = @ProjectId and IsDeleted=0 AND StopWordKey='SW001' AND IsAppInfra=1                
                
               
 SELECT 'All' AS 'Application Name',StopWords AS 'Stop Word for Resolution Provided',Frequency AS 'Frequency' ,SW.IsActive AS 'IsStop*'               
 FROM ML.TRN_StopWords SW                   
    WHERE SW.projectID = @ProjectId AND IsDeleted=0 AND StopWordKey='SW002' AND IsAppInfra=1                
 AND ApplicationId IS NULL and TowerId IS NULL                
 Union                 
 SELECT AD.ApplicationName AS 'Application Name',StopWords AS 'Stop Word for Resolution Provided',Frequency AS 'Frequency',SW.IsActive AS 'IsStop*'                 
 FROM ML.TRN_StopWords SW JOIN [AVL].[APP_MAS_ApplicationDetails] AD ON SW.ApplicationID = AD.ApplicationID                    
    WHERE SW.projectID = @ProjectId AND SW.IsDeleted=0 AND StopWordKey='SW002' AND IsAppInfra=1                
                
   Select Name from(SELECT 1 as 'SortOrder', 'All' AS 'Name'                 
    Union                
   SELECT  2 as 'SortOrder', AD.ApplicationName AS 'Name'                    
   FROM [AVL].[APP_MAP_ApplicationProjectMapping] APM                    
   JOIN [AVL].[APP_MAS_ApplicationDetails] AD ON APM.ApplicationID = AD.ApplicationID                    
   WHERE APM.projectID = @ProjectId                    
    AND APM.isdeleted = 0) A                
 ORDER BY SortOrder                
  END                
  ELSE -- Infra Support                  
  BEGIN                 
    SELECT 'All' AS 'Tower Name',StopWords AS 'Stop Word for Issue Description',Frequency,IsActive AS 'IsStop*' FROM ML.TRN_StopWords SW                   
    WHERE SW.projectID = @ProjectId and IsDeleted=0 and StopWordKey='SW001' and IsAppInfra=2                
 AND TowerId IS NULL AND TowerId IS NULL                
 Union                
   SELECT TD.TowerName AS 'Tower Name',StopWords AS 'Stop Word for Issue Description',Frequency,IsActive AS 'IsStop*' FROM ML.TRN_StopWords SW                
    JOIN AVL.InfraTowerDetailsTransaction TD ON SW.TowerID = TD.InfraTowerTransactionID                 
 WHERE SW.projectID = @ProjectId AND SW.IsDeleted=0 AND StopWordKey='SW001' AND IsAppInfra=2                
                
               
 SELECT 'All' AS 'Tower Name',StopWords AS 'Stop Word for Resolution Provided',Frequency AS 'Frequency',IsActive AS 'IsStop*'  FROM ML.TRN_StopWords SW                   
    WHERE SW.projectID = @ProjectId AND IsDeleted=0 AND StopWordKey='SW002' AND IsAppInfra=2                
 AND TowerId IS NULL and TowerId IS NULL               
 UNION                 
 SELECT TD.TowerName AS 'Tower Name',StopWords AS 'Stop Word for Resolution Provided',Frequency AS 'Frequency',IsActive AS 'IsStop*'                 
 FROM ML.TRN_StopWords SW JOIN AVL.InfraTowerDetailsTransaction TD ON SW.TowerID = TD.InfraTowerTransactionID                   
    WHERE SW.projectID = @ProjectId and SW.IsDeleted=0 and StopWordKey='SW002' and IsAppInfra=2                
                
                
     Select Name FROM(SELECT 1 as 'SortOrder','All' AS 'Name'                 
   UNION                
     SELECT 2 AS 'SortOrder',TD.TowerName AS 'Name'                    
   FROM AVL.InfraTowerProjectMapping IT                            
     JOIN AVL.InfraTowerDetailsTransaction TD ON IT.TowerID = TD.InfraTowerTransactionID                            
   AND IT.IsDeleted = 0                            
   AND TD.IsDeleted = 0                            
   AND IT.IsEnabled = 1                            
     WHERE IT.ProjectID = @ProjectID  ) A                
 ORDER BY SortOrder                
  END                
                
   SELECT TOP (1) FromDate                    
    ,ToDate                    
   FROM [ML].[TRN_MLTransaction]                    
   WHERE ProjectId = @ProjectId                    
   ORDER BY CreatedDate DESC                  
                
                
END                
ELse IF @UIorExcel=1 --For UI download                
 BEGIN                        
 BEGIN TRY                  
   BEGIN TRAN                 
  -- SET NOCOUNT ON added to prevent extra result sets from                          
  -- interfering with SELECT statements.                          
  SET NOCOUNT ON;                          
                          
  -- Insert statements for procedure here                          
  SELECT ISNULL(TowerId,0) TowerId,                        
 ISNULL(ApplicationId,0) ApplicationId , StopWordKey,                      
 StopWords,                      
 IsAppInfra                        
 FROM [ML].[TRN_StopWords]  WHERE ProjectID=@ProjectId And IsActive=1                      
    COMMIT TRAN                 
                          
 END TRY                          
 BEGIN CATCH                          
    DECLARE @ErrorMessage VARCHAR(MAX);                          
    SELECT @ErrorMessage=ERROR_MESSAGE()                 
    ROLLBACK TRAN                
    EXEC AVL_InsertError '[ML].[GetStopWords]',                          
    @ErrorMessage,                          
    @ProjectId,                          
    0                          
 END CATCH                          
    SET NOCOUNT OFF;                          
 END                 
END
