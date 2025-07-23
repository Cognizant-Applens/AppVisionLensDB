CREATE PROCEDURE [ML].[SaveStopWordsUpload_App]                          
 -- Add the parameters for the stored procedure here                          
 @userId NVARCHAR(100)                          
 ,@ProjectID BIGINT                          
 ,@TVPNoiseWords [ML].[TVP_StopWordsDetails] Readonly       
AS                          
BEGIN      
BEGIN TRY                                 
  BEGIN TRAN    
 SET NOCOUNT OFF;                          
                          
 -- Insert statements for procedure here                          
 SELECT *                          
 INTO #AppInfraDetailsTemp                          
 FROM @TVPNoiseWords;        
      
  UPDATE T                          
    SET T.ApplicationID =A.ApplicationID            
    FROM #AppInfraDetailsTemp AS T                          
    JOIN [AVL].[APP_MAS_ApplicationDetails] AS A ON T.ApplicationName = A.ApplicationName                          
    JOIN [AVL].[APP_MAP_ApplicationProjectMapping] AS APM ON A.ApplicationId = APM.ApplicationId                          
    WHERE APM.ProjectId = @ProjectID   and (T.ApplicationID=0 and Lower(T.ApplicationName)<>'all')                 
     AND APM.isdeleted = 0        
      
UPDATE #AppInfraDetailsTemp SET ApplicationID=NULL WHERE (ApplicationID=0 AND Lower(ApplicationName)='all')         
      
    DELETE                          
    FROM [ML].[TRN_StopWords]                          
    WHERE ProjectID = @ProjectID        
                 
        
          
        
                      
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
  ,TAG.[StopWordKey]                        
  ,TAG.StopWords                          
  ,TAG.Frequency                          
  ,TAG.IsActive                          
  ,1                          
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
    EXEC AVL_InsertError '[ML].[SaveStopWordsUpload_App]',                      
    @ErrorMessage,                      
    @ProjectId,                      
    0                      
 END CATCH                      
    SET NOCOUNT OFF;                      
 END
