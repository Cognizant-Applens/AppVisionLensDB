-- ============================================================================            
-- Author:           835658            
-- Create date:      28/07/2020          
-- Description:      To save manage Rules            
--[ML].[Infra_SaveMlRules]   10337          
-- ============================================================================            
CREATE PROCEDURE [ML].[Infra_SaveMlRules]             
@ProjectId BIGINT,            
@UserId nvarchar(20),            
@ApproveMuteRules [ML].[TVP_MlRuleData] READONLY            
AS            
BEGIN            
BEGIN TRY            
BEGIN TRAN             
UPDATE ml.Infratrn_patternvalidation SET IsApprovedOrMute = TML.IsApprovedorMute            
FROM @ApproveMuteRules TML INNER JOIN  ml.InfraTRN_PatternValidation ML             
ON TML.ID = ML.ID and ml.ProjectID = @ProjectId            
          
UPDATE ml.Infratrn_patternvalidation           
SET MLResolutionCode=TML.MLResolutionCodeID,          
 MLCauseCodeID=TML.MLCauseCodeID ,          
 MLAvoidableFlagID=TML.MLAvoidableFlagID,          
 MLDebtClassificationID=TML.MLDebtClassificationID,          
 MLResidualFlagID=TML.MLResidualFlagID,          
 ModifiedBy=TML.CreatedBy,          
 ModifiedDate=getdate()          
FROM @ApproveMuteRules TML INNER JOIN  ml.InfraTRN_PatternValidation ML             
ON TML.ID = ML.ID and ml.ProjectID = @ProjectId  and ML.CreatedBy !='' and ML.CreatedBy !='System'          
          
insert into  ml.infratrn_patternvalidation          
([IsApprovedorMute],          
 TowerID,          
 MLResolutionCode,          
 MLCauseCodeID ,          
 MLAvoidableFlagID,          
 MLDebtClassificationID,          
 MLResidualFlagID,          
 CreatedBy,          
 InitialLearningID,          
 TicketPattern,          
 subPattern,          
 additionalPattern,          
 additionalSubPattern,          
 ProjectID,          
 CreatedDate,          
 IsDeleted,          
 TicketOccurence,          
 MLAccuracy)          
select           
 [IsApprovedorMute],          
 ApplicationID,          
 MLResolutionCodeID,          
 MLCauseCodeID ,          
 MLAvoidableFlagID,          
 MLDebtClassificationID,          
 MLResidualFlagID,          
 CreatedBy,          
 InitialLearningID,          
 DescriptionBasePattern,          
 DescriptionSubPattern,          
 case when AdditionalBasePattern is not null and AdditionalBasePattern <> '' then AdditionalBasePattern else '0' end,          
 case when AdditionalSubPattern is not null and AdditionalSubPattern <> '' then AdditionalSubPattern else '0' end,           
 @ProjectId,          
 GETDATE(),          
 0,          
 0,          
 0          
 from @ApproveMuteRules where ID=0                
        
COMMIT TRAN             
END TRY             
BEGIN CATCH             
             
          DECLARE @ErrorMessage VARCHAR(max);             
            
          SELECT @ErrorMessage = Error_message()             
            
          ROLLBACK TRAN             
            
          --INSERT Error                 
          EXEC Avl_inserterror             
            '[ML].[Infra_SaveMlRules]',             
            @ErrorMessage,             
            @ProjectID,             
            0             
END CATCH             
END
