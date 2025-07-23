CREATE PROCEDURE [ML].[CheckForDebtEligibleProject]     
@returnValue INT OUTPUT,    
@ProjectId BIGINT,    
@IsApp BIT    
AS              
BEGIN                     
BEGIN TRY       
   SET @returnValue = 0          
   IF(SELECT Count(*) FROM AVL.MAS_ProjectMaster WHERE ProjectID = @ProjectId AND IsDebtEnabled = 'Y' AND IsDeleted=0) > 0             
   BEGIN      
    IF @IsApp = 1  AND     
    (SELECT Count(*) FROM avl.mas_projectdebtdetails where projectid= @ProjectId AND IsDeleted = 0 AND IsAutoClassified ='Y') > 0    
    BEGIN    
  SET @returnValue =1;    
    END    
    IF @IsApp = 0  AND     
    (SELECT Count(*) FROM avl.mas_projectdebtdetails where projectid= @ProjectId AND IsDeleted = 0 AND  IsAutoClassifiedInfra ='Y') > 0    
    BEGIN    
  SET @returnValue =1;    
    END    
   END          
   return @returnValue             
END TRY                    
BEGIN CATCH                    
  DECLARE @ErrorMessage VARCHAR(MAX);                  
  SELECT @ErrorMessage = ERROR_MESSAGE()                 
                           
  EXEC AVL_InsertError '[ML].[CheckForDebtEligibleProject]', @ErrorMessage, 0,0                  
                    
 END CATCH                     
END
