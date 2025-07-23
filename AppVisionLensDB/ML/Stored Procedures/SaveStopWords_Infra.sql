CREATE PROCEDURE [ML].[SaveStopWords_Infra]                           
@userId NVARCHAR(100)                            
,@ProjectID BIGINT                            
,@TVPNoiseWords [ML].[TVP_StopWordsDetails] Readonly           
,@SelectedId INT        
AS                            
BEGIN       
BEGIN TRY                                 
  BEGIN TRAN    
 SET NOCOUNT OFF;                            
                 
   DECLARE @IsApp  INT  =2                   
 -- Insert statements for procedure here                            
 SELECT *                            
 INTO #AppInfraDetailsTemp                            
 FROM @TVPNoiseWords;                            
                            
    UPDATE #AppInfraDetailsTemp SET TowerId=NULL WHERE (TowerId=0)            
           
    DELETE FROM [ML].[TRN_StopWords]                            
    WHERE ProjectID = @ProjectID AND IsActive=1 AND IsAppInfra=2          
   AND ((@SelectedId =0 AND TowerId IS NULL ) OR  (@SelectedId <> 0 AND TowerId =@SelectedId))         
          
          
     UPDATE SW SET IsActive=1,ModifiedBy=@userId,ModifiedDate=GetDate()          
  FROM [ML].[TRN_StopWords] SW         
  INNER JOIN #AppInfraDetailsTemp T          
  ON SW.StopWords= T.StopWords    
  --and SW.TowerId=T.TowerId      
    AND SW.StopWordKey=T.StopWordKey   
     Where  ProjectId=@ProjectId AND SW.IsActive=0    
  AND  (( @SelectedId =0 AND SW.TowerId IS NULL) OR  (@SelectedId <>0 AND SW.TowerId =@SelectedId))  
          
  DELETE T FROM #AppInfraDetailsTemp T         
  INNER JOIN [ML].[TRN_StopWords] SW           
  ON  T.StopWords= SW.StopWords   
  AND  SW.StopWordKey=T.StopWordKey          
  Where  ProjectId=@ProjectId --AND SW.IsActive=0           
  AND SW.ModifiedBy IS NOT NULL       
        
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
  ,@IsApp                            
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
    EXEC AVL_InsertError '[ML].[SaveStopWords_Infra]',                      
    @ErrorMessage,                      
    @ProjectId,                      
    0                      
 END CATCH                      
    SET NOCOUNT OFF;                      
 END
