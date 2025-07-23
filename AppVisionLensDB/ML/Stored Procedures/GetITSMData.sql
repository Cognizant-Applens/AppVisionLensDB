CREATE PROCEDURE [ML].[GetITSMData]     
@ProjectID NVARCHAR(50)    
    
AS     
BEGIN    
  BEGIN TRY    
 SET NOCOUNT ON;    
    select DebtEnablementDate from [AVL].[MAS_ProjectDebtDetails] (NOLOCK) WHERE ProjectID = @ProjectID    
 SELECT A.ProjectColumn,     
 PFM.FieldMappingId,    
 PFM.ITSMColumn,    
 PFM.FieldKey    
 FROM [AVL].[ITSM_PRJ_SSISColumnMapping] A (NOLOCK)    
 INNER JOIN MAS.ML_Prerequisite_FieldMapping PFM (NOLOCK)    
 ON PFM.ITSMColumn = A.ServiceDartColumn      
 WHERE A.ProjectID = @ProjectID  
 and PFM.IsDeleted = 0  
     
 SET NOCOUNT OFF;    
  END TRY    
  BEGIN CATCH    
        DECLARE @ErrorMessage VARCHAR(MAX);    
  SELECT @ErrorMessage = ERROR_MESSAGE()    
  --INSERT Error        
  EXEC AVL_InsertError '[ML].[GetITSMData]', @ErrorMessage,@ProjectID    
  END CATCH     
END
