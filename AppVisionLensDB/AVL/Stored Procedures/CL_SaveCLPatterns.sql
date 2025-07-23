/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[CL_SaveCLPatterns]   
(
	@ProjectID VARCHAR(1000), 
	@EmployeeID VARCHAR(1000),  
	@IsCLSignOff BIT,  
	@EffectiveDate DateTime,  
	@IsSave BIT,  
	@CLPatterns AS [AVL].[CL_CLSavePatterns] READONLY  
)
AS  
BEGIN  
BEGIN TRY  
BEGIN TRAN  
 -- SET NOCOUNT ON added to prevent extra result sets from   
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
 UPDATE  
     CL  
  SET  
    CL.MLResidualFlagID=PAT.ResidualID,  
    CL.MLDebtClassificationID=PAT.DebtID,  
    CL.MLAvoidableFlagID=PAT.AvoidableFlagID,  
    CL.IsApprovedOrMute=PAT.ApprovedOrMuted,  
    CL.ModifiedBy=@EmployeeID,  
    CL.ModifiedDate=GETDATE(),  
    CL.IsCLSignOff=PAT.IsCLSignOff  
    
  FROM   
   [AVL].[CL_TRN_PatternValidation] CL  
  JOIN  
   @CLPatterns PAT  
  ON
   CL.ID = PAT.OldContID AND PAT.IsDebtChanged=1   
   AND CL.IsDeleted=0 

 UPDATE  
     CL  
  SET  
    CL.IsApprovedOrMute=PAT.ApprovedOrMuted,  
    CL.ModifiedBy=@EmployeeID,  
    CL.ModifiedDate=GETDATE(),  
    CL.IsCLSignOff=PAT.IsCLSignOff  
    
  FROM   
   [AVL].[CL_TRN_PatternValidation] CL  
  JOIN  
   @CLPatterns PAT  
  ON   
   PAT.OldContID=CL.ID AND PAT.IsDebtChanged=0 AND PAT.NewContID=0 AND CL.IsDeleted=0;  
  
  
  
 UPDATE  
     CL  
  SET  
   CL.IsDefaultRuleSelected=1,  
    CL.IsApprovedOrMute=PAT.ApprovedOrMuted,  
    CL.ModifiedBy=@EmployeeID,  
    CL.ModifiedDate=GETDATE(),  
    CL.IsCLSignOff=PAT.IsCLSignOff  
    
  FROM   
   [AVL].[CL_TRN_PatternValidation] CL  
  JOIN  
   @CLPatterns PAT  
  ON   
   PAT.NewContID=CL.ID AND PAT.IsDebtChanged=0 AND CL.IsDeleted=0 AND PAT.NewContID>0;  
  
 UPDATE  
     CL  
  SET  
   CL.IsDefaultRuleSelected=0,  
    CL.IsApprovedOrMute=0,  
    CL.ModifiedBy=@EmployeeID,  
    CL.ModifiedDate=GETDATE(),  
    CL.IsCLSignOff=PAT.IsCLSignOff  
    
  FROM   
   [AVL].[CL_TRN_PatternValidation] CL  
  JOIN  
   @CLPatterns PAT  
  ON   
   PAT.OldContID=CL.ID AND PAT.NewContID<>0  AND PAT.IsDebtChanged=0 AND CL.IsDeleted=0;  
  
--- For Submit  
  
IF(@IsSave = 'false')  
BEGIN  
   
  -- Insert the tickets which are not present in IL Ticket Validation table from CL Ticket Validation table (New Learnings)  
                 MERGE AVL.ML_TRN_TicketValidation AS TARGET  
                 USING AVL.CL_TRN_TicketValidation AS SOURCE   
                     ON TARGET.ProjectID = @ProjectID AND SOURCE.ProjectID = @ProjectID AND   
                        TARGET.ProjectID = SOURCE.ProjectID AND TARGET.TicketID = SOURCE.TicketID AND   
                        TARGET.IsDeleted = 0 AND SOURCE.IsDeleted = 0  
                 WHEN NOT MATCHED   
                 THEN   
                        INSERT   
                        (  
                                  ProjectID, TicketID, TicketDescription, ApplicationID, DebtClassificationID, AvoidableFlagID, ResidualDebtID, CauseCodeID,  
                                  ResolutionCodeID, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted, OptionalFieldProj,TicketSourceFrom  
                        )   
                        VALUES  
                        (  
                                  @ProjectID, SOURCE.TicketID, SOURCE.TicketDescription, SOURCE.ApplicationID, SOURCE.DebtClassificationID,  
                                  SOURCE.AvoidableFlagID, SOURCE.ResidualDebtID, SOURCE.CauseCodeID, SOURCE.ResolutionCodeID, @EmployeeID, GETDATE(), NULL, NULL, 0,SOURCE.OptionalFieldProj,'CL'  
                        );  
                       
    UPDATE CTV  
    SET CTV.IsDeleted = 1 FROM AVL.CL_TRN_TicketValidation CTV  
    INNER JOIN AVL.ML_TRN_TicketValidation MTV ON MTV.ProjectID = CTV.ProjectID AND MTV.TicketID = CTV.TicketID AND MTV.IsDeleted = 0  
    WHERE CTV.ProjectID =  @ProjectID AND CTV.IsDeleted = 0 AND CONVERT(DATE, MTV.CreatedDate) = CONVERT(DATE,GETDATE())  
                  
         -- Get Approved or Muted tickets along with its combination of debt values from the Continual Learning Pattern Validation table and store it   
                     -- in temporary table.  
                     CREATE TABLE #CL_TRN_PatternValidation  
                     (  
                        [ContLearningID]                             [INT] NOT NULL,  
                        [ProjectID]                                  [BIGINT] NOT NULL,  
                        [ApplicationID]                              [BIGINT] NOT NULL,  
                        [ApplicationTypeID]                          [INT] NULL,  
                        [TechnologyID]                               [INT] NULL,  
                        [TicketPattern]                              [NVARCHAR](1000) NULL,  
                        [TicketSubPattern]                           [NVARCHAR](1000) NULL,  
                        [AdditionalPattern]                          [NVARCHAR](1000) NULL,  
                        [AdditionalSubPattern]                       [NVARCHAR](1000) NULL,  
                        [MLResidualFlagID]                           [INT] NULL,  
                        [MLDebtClassificationID]  [INT] NULL,  
                   [MLAvoidableFlagID]                          [INT] NULL,  
                        [MLCauseCodeID]                              [INT] NULL,  
                        [MLAccuracy]                                 [DECIMAL](18, 2) NULL,  
                        [TicketOccurence]                            [INT] NULL,  
                        [AnalystResidualFlagID]                      [INT] NULL,  
                        [AnalystResolutionCodeID]                    [INT] NULL,  
                        [AnalystCauseCodeID]                         [INT] NULL,  
                        [AnalystDebtClassificationID]              [INT] NULL,  
                        [AnalystAvoidableFlagID]                     [INT] NULL,  
                        [SMEComments]                                [NVARCHAR](4000) NULL,  
                        [SMEResidualFlagID]                          [INT] NULL,  
                        [SMEDebtClassificationID]                    [INT] NULL,  
                        [SMEAvoidableFlagID]                         [INT] NULL,  
                        [SMECauseCodeID]                             [INT] NULL,  
                        [IsApprovedOrMute]                           [INT] NULL,  
                        [MLResolutionCodeID]                         [INT] NULL  
                     )  
  
                     INSERT INTO #CL_TRN_PatternValidation  
                           SELECT  DISTINCT CLTPV.ContLearningID, CLTPV.ProjectID, CLTPV.ApplicationID, CLTPV.ApplicationTypeID, CLTPV.TechnologyID, ISNULL(CLTPV.TicketPattern,0),   
                                         ISNULL(CLTPV.TicketSubPattern,0), ISNULL(CLTPV.AdditionalPattern,0), ISNULL(CLTPV.AdditionalSubPattern,0), CLTPV.MLResidualFlagID,  
                                         CLTPV.MLDebtClassificationID, CLTPV.MLAvoidableFlagID, CLTPV.MLCauseCodeID, CLTPV.MLAccuracy, CLTPV.TicketOccurence,  
                                         CLTPV.AnalystResidualFlagID, CLTPV.AnalystResolutionCodeID, CLTPV.AnalystCauseCodeID, CLTPV.AnalystDebtClassificationID,  
                                         CLTPV.AnalystAvoidableFlagID, CLTPV.SMEComments, CLTPV.SMEResidualFlagID, CLTPV.SMEDebtClassificationID,  
                                         CLTPV.SMEAvoidableFlagID, CLTPV.SMECauseCodeID, CLTPV.IsApprovedOrMute, CLTPV.MLResolutionCodeID  
                           FROM AVL.CL_TRN_PatternValidation (NOLOCK) CLPV  
                           JOIN AVL.CL_TRN_PatternValidation (NOLOCK) CLTPV  
                                  ON  CLTPV.ProjectID = CLPV.ProjectID AND CLTPV.ApplicationID = CLPV.ApplicationID AND   
                                         ISNULL(CLTPV.TicketPattern,0) = ISNULL(CLPV.TicketPattern,0) AND ISNULL(CLTPV.AdditionalPattern,0) = ISNULL(CLPV.AdditionalPattern,0) AND    
                                 ISNULL(CLTPV.TicketSubPattern,0) = ISNULL(CLPV.TicketSubPattern,0) AND ISNULL(CLTPV.AdditionalSubPattern,0) = ISNULL(CLPV.AdditionalSubPattern,0) AND    
                                         CLTPV.MLCauseCodeID = CLPV.MLCauseCodeID AND CLTPV.MLResolutionCodeID = CLPV.MLResolutionCodeID AND CLTPV.IsDeleted = 0   
                           WHERE CLPV.ProjectID = @ProjectID AND ISNULL(CLPV.IsApprovedOrMute,0) <> 0 AND CLPV.IsDeleted = 0  
  
                     -- Sync Initial & Continuous Learning Pattern Validation tables  
                  MERGE AVL.ML_TRN_MLPatternValidation AS TARGET  
                  USING #CL_TRN_PatternValidation AS SOURCE   
                    ON TARGET.ProjectID = @ProjectID AND TARGET.ProjectID = SOURCE.ProjectID AND   
                          TARGET.ApplicationID = SOURCE.ApplicationID AND ISNULL(TARGET.TicketPattern,0) = SOURCE.TicketPattern AND   
                            ISNULL(TARGET.additionalPattern,0) = SOURCE.AdditionalPattern AND ISNULL(TARGET.subPattern,0) = SOURCE.TicketSubPattern  AND   
                            ISNULL(TARGET.additionalSubPattern,0) = SOURCE.AdditionalSubPattern AND TARGET.MLCauseCodeID = SOURCE.MLCauseCodeID AND   
                            TARGET.MLResolutionCode = SOURCE.MLResolutionCodeID AND TARGET.MLDebtClassificationID = SOURCE.MLDebtClassificationID AND   
                            TARGET.MLAvoidableFlagID = SOURCE.MLAvoidableFlagID AND TARGET.MLResidualFlagID = SOURCE.MLResidualFlagID AND TARGET.IsDeleted = 0  
                  WHEN MATCHED  
                  THEN   
  
                         UPDATE SET   
                         TARGET.MLAccuracy = SOURCE.MLAccuracy,  
                         TARGET.TicketOccurence = SOURCE.TicketOccurence,  
       TARGET.IsApprovedOrMute = SOURCE.IsApprovedOrMute,  
                         TARGET.ContinuousLearningID = SOURCE.ContLearningID,  
                         TARGET.ModifiedBy = @EmployeeID,  
                         TARGET.ModifiedDate = GETDATE()  
  
                  WHEN NOT MATCHED   
                  THEN   
       
                           INSERT   
                           (  
                                  InitialLearningID, ProjectID, ApplicationID, ApplicationTypeID, TechnologyID, TicketPattern, MLResidualFlagID,  
                                  MLDebtClassificationID, MLAvoidableFlagID, MLCauseCodeID, MLAccuracy, TicketOccurence, AnalystResidualFlagID, AnalystResolutionCodeID,  
                                  AnalystCauseCodeID, AnalystDebtClassificationID, AnalystAvoidableFlagID, SMEComments, SMEResidualFlagID, SMEDebtClassificationID,  
                                  SMEAvoidableFlagID, SMECauseCodeID, IsApprovedOrMute, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted,  
                                  Classifiedby, SMEResolutionCodeID, ReasonForResidual, ExpectedCompDate, MLResolutionCode, subPattern, additionalPattern, additionalSubPattern,  
                                  OverridenPatternCount, OverridenPatternTotalCount, IsMLSignOff, ContinuousLearningID  
                           )  
                           VALUES   
                           (  
                                  NULL, @ProjectID, SOURCE.ApplicationID, SOURCE.ApplicationTypeID, SOURCE.TechnologyID, SOURCE.TicketPattern, SOURCE.MLResidualFlagID,  
                                  SOURCE.MLDebtClassificationID, SOURCE.MLAvoidableFlagID, SOURCE.MLCauseCodeID, SOURCE.MLAccuracy, SOURCE.TicketOccurence,  
                                  SOURCE.AnalystResidualFlagID, SOURCE.AnalystResolutionCodeID, SOURCE.AnalystCauseCodeID, SOURCE.AnalystDebtClassificationID,  
                                  SOURCE.AnalystAvoidableFlagID, SOURCE.SMEComments, SOURCE.SMEResidualFlagID, SOURCE.SMEDebtClassificationID,  
                                  SOURCE.SMEAvoidableFlagID, SOURCE.SMECauseCodeID, SOURCE.IsApprovedOrMute, @EmployeeID, GETDATE(), NULL, NULL, 0,  
        NULL, NULL, NULL, NULL, SOURCE.MLResolutionCodeID, SOURCE.TicketSubPattern, SOURCE.AdditionalPattern, SOURCE.AdditionalSubPattern,  
                                  0, 0, NULL, SOURCE.ContLearningID  
                           );  
         
                
                 -- Insert the tickets which are not present in IL Base Details table from CL Base Details table (New Learnings)  
                 MERGE DBO.ML_MLBaseDetails AS TARGET  
                 USING   
                 (  
                         SELECT DISTINCT CLB.ContLearningID, CLB.ProjectID, CLB.TicketID, CLB.ApplicationName, ISNULL(CLB.TicketDescriptionPattern,0) AS TicketDescriptionPattern, ISNULL(CLB.TicketDescriptionSubPattern,0) AS TicketDescriptionSubPattern,  
                                  ISNULL(CLB.OptionalFieldpattern,0) AS OptionalFieldpattern, ISNULL(CLB.OptionalFieldSubPattern,0) AS OptionalFieldSubPattern, CLB.CauseCode, CLB.ResolutionCode, CLB.DebtClassification, CLB.AvoidableFlag,  
                                  CLB.ResidualDebt  
                         FROM AVL.CL_BaseDetails (NOLOCK) CLB  
       JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) APP  
                                  ON APP.ApplicationName = CLB.ApplicationName  
                         JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) PAM  
                                  ON PAM.ProjectID = CLB.ProjectID AND PAM.ApplicationID = APP.ApplicationID        
       JOIN AVL.DEBT_MAP_CauseCode MAC ON MAC.CauseCode = CLB.CauseCode AND MAC.ProjectID = CLB.ProjectID  
       JOIN AVL.DEBT_MAP_ResolutionCode MRC ON MRC.ResolutionCode = CLB.ResolutionCode AND MRC.ProjectID = CLB.ProjectID                        
                         JOIN #CL_TRN_PatternValidation CLPV   
                                  ON CLPV.ProjectID = CLB.ProjectID --AND APP.ApplicationID = CLB.ApplicationID  
                                         AND CLPV.TicketPattern = ISNULL(CLB.TicketDescriptionPattern,0) AND CLPV.TicketSubPattern = ISNULL(CLB.TicketDescriptionSubPattern,0)  
                                         AND CLPV.AdditionalPattern = ISNULL(CLB.OptionalFieldpattern,0) AND CLPV.AdditionalSubPattern = ISNULL(CLB.OptionalFieldSubPattern,0)  
                                         AND CLPV.MLCauseCodeID = MAC.CauseID AND CLPV.MLResolutionCodeID = MRC.ResolutionID  
                                         AND CLB.IsDeleted = 0  
                 )  
                 AS SOURCE   
                     ON TARGET.ProjectID = @ProjectID AND SOURCE.ProjectID = @ProjectID AND TARGET.ProjectID = SOURCE.ProjectID  
                           AND TARGET.TicketID = SOURCE.TicketID AND TARGET.ApplicationName = SOURCE.ApplicationName  
                           AND ISNULL(TARGET.TicketDescriptionPattern,0) = SOURCE.TicketDescriptionPattern   
                           AND ISNULL(TARGET.TicketDescriptionSubPattern,0)= SOURCE.TicketDescriptionSubPattern  
                           AND ISNULL(TARGET.OptionalFieldpattern,0) = SOURCE.OptionalFieldpattern AND ISNULL(TARGET.OptionalFieldSubPattern,0) = SOURCE.OptionalFieldSubPattern  
                           AND TARGET.CauseCode = SOURCE.CauseCode AND TARGET.ResolutionCode = SOURCE.ResolutionCode  
                           AND TARGET.DebtClassification = SOURCE.DebtClassification AND TARGET.AvoidableFlag = SOURCE.AvoidableFlag  
                      AND TARGET.ResidualDebt = SOURCE.ResidualDebt AND TARGET.IsDeleted = 0   
                  
                 WHEN NOT MATCHED   
                 THEN   
                   
                           INSERT   
                           (  
                                  InitialLearningID, ProjectID, TicketID, ApplicationName, DebtClassification, AvoidableFlag, ResidualDebt,  
                                  CauseCode, ResolutionCode, TicketDescriptionPattern, TicketDescriptionSubPattern, OptionalFieldpattern,  
                                  OptionalFieldSubPattern, IsDeleted, ContinuousLearningID,  
          CreatedBy,CreatedDate  
                           )   
                           VALUES   
              (  
                                  NULL, @ProjectID, SOURCE.TicketID, SOURCE.ApplicationName, SOURCE.DebtClassification, SOURCE.AvoidableFlag,  
                                  SOURCE.ResidualDebt, SOURCE.CauseCode, SOURCE.ResolutionCode, SOURCE.TicketDescriptionPattern,  
                                  SOURCE.TicketDescriptionSubPattern, SOURCE.OptionalFieldpattern, SOURCE.OptionalFieldSubPattern, 0, SOURCE.ContLearningID,  
          @EmployeeID, GETDATE()  
                           );  
  
     UPDATE CBS  
     SET CBS.Isdeleted = 1 FROM AVL.CL_BaseDetails CBS   
     INNER JOIN DBO.ML_MLBaseDetails MBS  
     ON MBS.TicketID = CBS.TicketID AND MBS.ProjectID = CBS.ProjectID   
     AND MBS.ContinuousLearningID = CBS.ContLearningID AND MBS.Isdeleted = 0  
     WHERE CBS.ProjectID = @ProjectID AND CBS.IsDeleted = 0 AND MBS.InitialLearningID IS NULL AND MBS.ContinuousLearningID IS NOT NULL  
     AND CONVERT(DATE, MBS.CreatedDate) = CONVERT(DATE,GETDATE())  
         
                     -- After moving the CL Approved and Muted patterns to Initial Learning Pattern Validation table, make those   
                     -- patterns Is Deleted in CL Pattern Validation table                      
  
      UPDATE CTPV  
                     SET CTPV.IsDeleted = 1  
      FROM AVL.CL_TRN_PatternValidation CTPV  
                     JOIN #CL_TRN_PatternValidation CPVTEMP  
                                  ON  CPVTEMP.ProjectID = CTPV.ProjectID AND CPVTEMP.ApplicationID = CTPV.ApplicationID AND   
                                         ISNULL(CPVTEMP.TicketPattern,0) = ISNULL(CTPV.TicketPattern,0) AND ISNULL(CPVTEMP.AdditionalPattern,0) = ISNULL(CTPV.AdditionalPattern,0) AND    
                                         ISNULL(CPVTEMP.TicketSubPattern,0) = ISNULL(CTPV.TicketSubPattern,0) AND ISNULL(CPVTEMP.AdditionalSubPattern,0) = ISNULL(CTPV.AdditionalSubPattern,0) AND    
                                         CPVTEMP.MLCauseCodeID = CTPV.MLCauseCodeID AND CPVTEMP.MLResolutionCodeID = CTPV.MLResolutionCodeID AND CTPV.IsDeleted = 0   
                           WHERE CTPV.ProjectID = @ProjectID  
  
      DROP TABLE #CL_TRN_PatternValidation  
  
END  
  
COMMIT TRAN  
END TRY  
BEGIN CATCH 

	 ROLLBACK TRAN  

	 DECLARE @ErrorMessage VARCHAR(MAX);  
     SELECT @ErrorMessage = ERROR_MESSAGE()  
 
	 --INSERT Error      
	 EXEC AVL_InsertError '[AVL].[CL_SaveCLPatterns]', @ErrorMessage, 0  

END CATCH  
END
