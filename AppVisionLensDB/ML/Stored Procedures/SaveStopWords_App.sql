CREATE PROCEDURE [ML].[SaveStopWords_App]                           
@userId NVARCHAR(100)                              
,@ProjectID BIGINT                              
,@TVPNoiseWords [ML].[TVP_StopWordsDetails] Readonly           
,@SelectedId INT          
AS                              
BEGIN     
BEGIN TRY                                   
  BEGIN TRAN                              
 SET NOCOUNT OFF;            
           
          
   DECLARE @IsApp  INT  =1                       
 -- Insert statements for procedure here                              
 SELECT *                              
 INTO #AppInfraDetailsTemp                              
 FROM @TVPNoiseWords;             
                         
               
 UPDATE #AppInfraDetailsTemp SET ApplicationID=NULL WHERE (ApplicationID=0)          
          
DELETE FROM [ML].[TRN_StopWords]  WHERE ProjectID = @ProjectID AND IsActive=1 AND IsAppInfra=1          
 AND (( @SelectedId =0 AND ApplicationId IS NULL) OR  (@SelectedId <>0 AND ApplicationId =@SelectedId))            
          
          
  -- Activate system generated using UI          
 UPDATE SW SET IsActive=1,ModifiedBy=@userId,ModifiedDate=GetDate()            
   FROM [ML].[TRN_StopWords] SW           
   INNER JOIN #AppInfraDetailsTemp T  ON SW.StopWords= T.StopWords      
   AND SW.StopWordKey=T.StopWordKey    
   Where  ProjectId=@ProjectId AND SW.IsActive=0          
    AND  (( @SelectedId =0 AND SW.ApplicationId IS NULL) OR  (@SelectedId <>0 AND SW.ApplicationId =@SelectedId))     
            
   DELETE T FROM #AppInfraDetailsTemp T           
   INNER JOIN [ML].[TRN_StopWords] SW  ON T.StopWords= SW.StopWords            
   --AND  (( @SelectedId =0 AND SW.ApplicationId IS NULL) OR  (@SelectedId <>0 AND T.ApplicationId =SW.ApplicationId))    
   AND  SW.StopWordKey=T.StopWordKey     
   Where  ProjectId=@ProjectId --AND SW.IsActive=0    
   AND SW.ModifiedBy IS NOT NULL  
  -- AND  (( @SelectedId =0 AND T.ApplicationId IS NULL) OR  (@SelectedId <>0 AND T.ApplicationId =@SelectedId))          
                         
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
    EXEC AVL_InsertError '[ML].[SaveStopWords_App]',                        
    @ErrorMessage,                        
    @ProjectId,                        
    0                        
 END CATCH                        
    SET NOCOUNT OFF;                        
 END
