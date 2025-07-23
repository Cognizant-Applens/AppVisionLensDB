CREATE PROCEDURE [ML].[IsNoiseWordsAvailable]    
@ProjectID BIGINT        
AS         
BEGIN        
  BEGIN TRY        
 SET NOCOUNT ON;        
 Declare @NoiseWords BIGINT;        
 Declare @Result BIT;          
  Set @NoiseWords = (Select Count(*)        
  from [ML].[TRN_StopWords]        
  where ProjectID = @ProjectID And IsActive = 1 AND IsDeleted = 0)           
   If (@NoiseWords > 0)        
    BEGIN        
    SET @Result = 1        
    END        
   Else        
    BEGIN        
    SET @Result = 0        
   Select @Result        
 END        
 Select @Result        
 SET NOCOUNT OFF;        
  END TRY        
  BEGIN CATCH        
        DECLARE @ErrorMessage VARCHAR(MAX);        
  SELECT @ErrorMessage = ERROR_MESSAGE()        
  --INSERT Error            
  EXEC AVL_InsertError '[ML].[IsNoiseWordsAvailable]', @ErrorMessage,null        
  END CATCH         
END
