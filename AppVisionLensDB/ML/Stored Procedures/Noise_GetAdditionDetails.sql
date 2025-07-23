      
        
CREATE PROCEDURE [ML].[Noise_GetAdditionDetails](@ProjectId BIGINT)          
AS        
BEGIN        
BEGIN TRY          
 -- SET NOCOUNT ON added to prevent extra result sets from          
 -- interfering with SELECT statements.          
 SET NOCOUNT ON;          
          
    -- Insert statements for procedure here          
 SELECT ISNULL(TowerId,0) TowerId,        
ISNULL(ApplicationId,0) ApplicationId ,        
TicketDescNoiseWord,      
OptionalFieldNoiseWord,      
IsAppInfra        
FROM [ML].[TRN_AppInfraNoiseWords]  WHERE ProjectID=@ProjectId AND IsUserCreated=1 AND IsActive=1       
      
          
   END TRY          
   BEGIN CATCH          
   DECLARE @ErrorMessage VARCHAR(MAX);          
   SELECT @ErrorMessage=ERROR_MESSAGE()          
   EXEC AVL_InsertError '[ML].[Noise_GetAdditionDetails]',          
   @ErrorMessage,          
   @ProjectId,          
   0          
   END CATCH          
   SET NOCOUNT OFF;          
END
