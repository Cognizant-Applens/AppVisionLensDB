CREATE PROCEDURE [ML].[SaveStopWordsUpload_Infra]                          
 -- Add the parameters for the stored procedure here                          
 @userId NVARCHAR(100)                          
 ,@ProjectID BIGINT                          
 ,@TVPNoiseWords [ML].[TVP_StopWordsDetails] Readonly       
AS                          
BEGIN     
BEGIN TRY                                 
  BEGIN TRAN   
 SET NOCOUNT OFF;      
       
 DECLARE @IsAppInfra INT = 2      
                          
 -- Insert statements for procedure here                          
 SELECT *                          
 INTO #AppInfraDetailsTemp                          
 FROM @TVPNoiseWords;        
      
   UPDATE T                          
    SET T.TowerId =TDT.InfraTowerTransactionID                         
                            
    FROM #AppInfraDetailsTemp AS T                          
    JOIN (                          
     SELECT DISTINCT TD.InfraTowerTransactionID                          
   ,TD.TowerName                          
     FROM AVL.InfraTowerProjectMapping IT                          
     JOIN AVL.InfraTowerDetailsTransaction TD ON IT.TowerID = TD.InfraTowerTransactionID                          
   AND IT.IsDeleted = 0                          
   AND TD.IsDeleted = 0                          
   AND IT.IsEnabled = 1                          
     WHERE IT.ProjectID = @ProjectID                          
     ) AS TDT ON T.TowerName = TDT.TowerName          
     WHERE (T.TowerId=0 and Lower(T.TowerName)<>'all')        
        
     UPDATE #AppInfraDetailsTemp SET TowerId=NULL WHERE (TowerId=0 AND Lower(TowerName)='all')       
          
    DELETE                          
    FROM [ML].[TRN_StopWords]                          
    WHERE ProjectID = @ProjectID  AND IsAppInfra = @IsAppInfra       
                      
 INSERT INTO [ML].[TRN_StopWords] (                          
  [ProjectId]                          
  ,[ApplicationId]                          
  ,[TowerId]                          
  ,[StopWordKey]                          
  ,[StopWords]                          
  ,[Frequency]                          
  ,[IsActive]                          
  ,[IsAppInfra]                          
  ,[IsDeleted]                         
  ,[CreatedBy]                          
  )                          
 SELECT @ProjectID                          
  ,IIF(TAG.ApplicationID = 0, NULL, TAG.ApplicationID)                          
  ,IIF(TAG.TowerId = 0, NULL, TAG.TowerId)                          
  --,TAG.[StopWordKey]                          
  ,TAG.StopWordKey                         
  ,TAG.StopWords                          
  ,TAG.Frequency                          
  ,TAG.IsActive                          
  ,@IsAppInfra                          
  ,0                          
  ,@userId                          
 FROM #AppInfraDetailsTemp TAG         
       
                     
DROP TABLE #AppInfraDetailsTemp        
COMMIT TRAN             
                      
 END TRY                      
 BEGIN CATCH                      
    DECLARE @ErrorMessage VARCHAR(MAX);                      
    SELECT @ErrorMessage=ERROR_MESSAGE()             
    ROLLBACK TRAN            
    EXEC AVL_InsertError '[ML].[SaveStopWordsUpload_Infra]',                      
    @ErrorMessage,                      
    @ProjectId,                      
    0                      
 END CATCH                      
    SET NOCOUNT OFF;                      
 END
