CREATE PROCEDURE [ML].[GetRulesFilters]   
  @ProjectID BIGINT   
AS   
  BEGIN  
   
 BEGIN TRY   
 SET NOCOUNT ON
      DECLARE @Isdelete INT=0
 BEGIN  
 
  
  SELECT  CauseID,CauseCode FROM AVL.DEBT_MAP_CauseCode(NOLOCK)   
  WHERE ProjectID = @ProjectID  
  AND IsDeleted = @Isdelete  ORDER BY CauseCode ASC
  
  --SELECT ResolutionCodeID,ResolutionCodeName FROM AVL.DEBT_MAS_ResolutionCode(NOLOCK)  
  
  SELECT ResolutionID,ResolutionCode FROM AVL.DEBT_MAP_ResolutionCode(NOLOCK)  
  WHERE ProjectID = @ProjectID  
  AND IsDeleted = @Isdelete  ORDER BY ResolutionCode ASC
  
  SELECT DebtClassificationID,DebtClassificationName FROM [AVL].[DEBT_MAS_DebtClassification](NOLOCK)  
  WHERE IsDeleted = @Isdelete  
  
  SELECT AvoidableFlagID,AvoidableFlagName FROM AVL.DEBT_MAS_AvoidableFlag(NOLOCK)  
  WHERE IsDeleted = @Isdelete  
       
  SELECT ResidualDebtID,ResidualDebtName FROM AVL.DEBT_MAS_ResidualDebt(NOLOCK)  
  WHERE IsDeleted = @Isdelete  
  
 END
 END TRY   
  
 BEGIN CATCH  
 DECLARE @ErrorMessage VARCHAR(MAX);  
  
 SELECT  
  @ErrorMessage = ERROR_MESSAGE()  
  
 --INSERT Error        
 EXEC AVL_INSERTERROR '[ML].[GetRulesFilters]'  
       ,@ErrorMessage  
       ,@ProjectID  
       ,0  
 END CATCH  
 SET NOCOUNT OFF
 END
