    
    
    
CREATE PROCEDURE [ML].[Noise_SaveAppInfraTags]       
 -- Add the parameters for the stored procedure here      
 @userId NVARCHAR(100),       
 @ProjectID bigint,      
 @TagValues [ML].[TVP_NoiseAdditionTags]  Readonly      
    
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 --set NOCOUNT OFF - to get the number of rows affected    
 SET NOCOUNT OFF;      
 -- Insert statements for procedure here      
 BEGIN TRY      
 DECLARE @SupportTypeValue VARCHAR(2);    
 SET @SupportTypeValue=(SELECT DISTINCT SupportType FROM @TagValues);    
 SELECT * INTO #TEMPT FROM @TagValues;    
 UPDATE T SET T.ApplicationID=CASE WHEN T.ApplicationName<>''     
         THEN IIF(LOWER(T.ApplicationName)='all',0, A.ApplicationID)END     
         FROM #TEMPT AS T    
       JOIN [AVL].[APP_MAS_ApplicationDetails] AS A ON T.ApplicationName=A.ApplicationName    
       JOIN [AVL].[APP_MAP_ApplicationProjectMapping] AS APM ON A.ApplicationId=APM.ApplicationId WHERE    
       APM.ProjectId=@ProjectID AND APM.isdeleted = 0    
 UPDATE T SET T.TowerId=CASE WHEN T.TowerName<>''    
       THEN IIF(LOWER(T.TowerName)='all',0,TDT.InfraTowerTransactionID) END    
       FROM #TEMPT AS T JOIN    
       (SELECT distinct TD.InfraTowerTransactionID,TD.TowerName FROM AVL.InfraTowerProjectMapping IT     
       JOIN AVL.InfraTowerDetailsTransaction TD     
       ON IT.TowerID=TD.InfraTowerTransactionID AND IT.IsDeleted=0 AND TD.IsDeleted=0    
       AND IT.IsEnabled=1      
       WHERE IT.ProjectID=@ProjectID) AS TDT ON T.TowerName=TDT.TowerName    
    
       UPDATE TRN SET TRN.ModifiedBy=@userId,    
       TRN.ModifiedDate=getdate(),    
       TRN.IsActive=TAG.IsActive,    
       TRN.Frequency=IIF(TRN.IsUserCreated=0,TRN.Frequency,TAG.Frequency),    
       TRN.IsAppInfra = 1,    
       TRN.OptionalFieldNoiseWord=TAG.OptionalFieldNoiseWord,     
       TRN.OptionalFieldFrequency=IIF(TRN.IsUserCreated=0,TRN.OptionalFieldFrequency,TAG.OptionalFieldFrequency),    
       TRN.IsActiveResolution=TAG.IsActiveResolution from [ML].[TRN_AppInfraNoiseWords] TRN    
       inner join #TEMPT TAG on TRN.ProjectID=@ProjectID AND ((TRN.ApplicationId=TAG.ApplicationID) OR (TRN.ApplicationId IS NULL AND TAG.ApplicationID=0))    
       AND ((TRN.TowerId=TAG.TowerId) OR (TRN.TowerId IS NULL AND TAG.TowerId=0)) AND (isnull(TRN.TicketDescNoiseWord,'') =isnull(TAG.NoiseWords,'') and isnull(TRN.OptionalFieldNoiseWord,'')=isnull(TAG.OptionalFieldNoiseWord,''))    
           
        DELETE TAG from #TEMPT TAG     
       inner join [ML].[TRN_AppInfraNoiseWords] TRN on TRN.ProjectID=@ProjectID AND ((TRN.ApplicationId=TAG.ApplicationID) OR (TRN.ApplicationId IS NULL AND TAG.ApplicationID=0))    
       AND ((TRN.TowerId=TAG.TowerId) OR (TRN.TowerId IS NULL AND TAG.TowerId=0)) AND (isnull(TRN.TicketDescNoiseWord,'') =isnull(TAG.NoiseWords,'') and isnull(TRN.OptionalFieldNoiseWord,'')=isnull(TAG.OptionalFieldNoiseWord,''))    
   INSERT  into [ML].[TRN_AppInfraNoiseWords]      
    ([ProjectID],      
    [TowerId],      
    [ApplicationID],      
    [TicketDescNoiseWord],      
    [Frequency],      
    [IsUserCreated],      
    [IsDeleted],      
    [IsActive],      
    [CreatedBy],      
    [CreatedDate],      
    [IsAppInfra],    
       [OptionalFieldNoiseWord] ,    
             [OptionalFieldFrequency] ,    
             [IsActiveResolution] )      
    select @ProjectID,IIF(TAG.TowerId=0,NULL,TAG.TowerId),IIF(TAG.ApplicationID=0,NULL,TAG.ApplicationID),TAG.NoiseWords,TAG.Frequency,1,0,TAG.IsActive,@userId,getdate(),      
      @SupportTypeValue,    
      TAG.OptionalFieldNoiseWord,    
      TAG.OptionalFieldFrequency,    
      TAG.IsActiveResolution   from #TEMPT TAG    
           
END TRY      
BEGIN CATCH      
DECLARE @ErrorMessage VARCHAR(MAX);       
   SELECT @ErrorMessage = Error_message()           
   --INSERT Error           
   EXEC Avl_inserterror       
   '[ML].[TVP_NoiseAdditionTags]',       
   @ErrorMessage,       
   @ProjectID,       
   0       
END CATCH          END
