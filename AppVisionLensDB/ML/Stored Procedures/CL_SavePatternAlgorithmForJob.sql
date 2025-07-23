/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
CREATE PROCEDURE [ML].[CL_SavePatternAlgorithmForJob]  
@ProjectID BIGINT,  
@TVP_lstMLJobPattern ML.TVP_CLJobPattern READONLY  
AS  
BEGIN  
-- SET NOCOUNT ON added to prevent extra result sets from  
-- interfering with SELECT statements.  
SET NOCOUNT ON;  
BEGIN TRY  
BEGIN TRAN  
DECLARE @ContLearningID INT,  
  @CustomerID INT=0,  
  @JobStatus INT=4,  
  @StartDate DATETIME,  
  @EndDate DATETIME,  
  @IsDeleted INT = 0,  
  @IsTicketDescOpt bit,  
  @DebtAttribute TINYINT;  
  
  CREATE TABLE #JobPattern  
  (  
   [TicketPattern] [nvarchar](1000) NULL,  
   [AdditionalPattern] [nvarchar](1000) NULL,  
   [TicketSubPattern] [nvarchar](1000) NULL,  
   [AdditionalSubPattern] [nvarchar](1000) NULL,  
   [SMEApproval] [nvarchar](500) NULL,  
   ContLearningID INT NULL,  
   ProjectID BIGINT NULL,  
   ApplicationID BIGINT NULL,  
   ApplicationTypeID INT NULL,  
   TechnologyID INT NULL,  
   MLResidualFlagID INT NULL,  
   MLDebtClassificationID INT NULL,  
   MLAvoidableFlagID INT NULL,  
   MLResolutionCodeID INT NULL,  
   MLCauseCodeID INT NULL,  
   MLAccuracy DECIMAL(18,2) NULL,  
   TicketOccurence INT NULL,  
   AnalystResidualFlagID INT NULL,  
   AnalystResolutionCodeID INT NULL,  
   AnalystCauseCodeID INT NULL,  
   AnalystDebtClassificationID INT NULL,  
   AnalystAvoidableFlagID INT NULL,  
   ApplicationName nVARCHAR(2000) NULL,  
   ApplicationTypeName nVARCHAR(1000) NULL,  
   TechnologyName nVARCHAR(2000) NULL,  
   AnalystDebtClassificationName nVARCHAR(2000) NULL,  
   AnalystAvoidableFlagName nVARCHAR(50) NULL,  
   AnalystResidualDebtName nVARCHAR(50) NULL,  
   AnalystCauseCodeName nVARCHAR(2000) NULL,  
   AnalystResolutionCodeName nVARCHAR(2000) NULL,  
   MLResidualFlagName nVARCHAR(2000) NULL,  
   MLDebtClassificationName nVARCHAR(50) NULL,  
   MLAvoidableFlagName nVARCHAR(50) NULL,  
   MLCauseCodeName nVARCHAR(2000) NULL,  
   MLResolutionCode nvarchar(2000) NULL,  
   Classifiedby nvarchar(2000) NULL  
  )  
  
  
  CREATE TABLE #MLOverriddenPatterns(  
   TicketID nVARCHAR(50) NOT NULL,  
   ProjectID BIGINT NULL,  
   ApplicationID BIGINT NULL,  
   ApplicationTypeID INT NULL,  
   TechnologyID INT NULL,  
   TicketPattern nVARCHAR(2000) NULL,  
   TicketSubPattern nVARCHAR(2000) NULL,  
   AdditionalPattern nVARCHAR(2000) NULL,  
   AdditionalSubPattern nVARCHAR(2000) NULL,  
   RuleID BIGINT NULL,  
   ResidualDebtMapID INT NULL,  
   DebtClassificationMapID INT NULL,  
   AvoidableFlag INT NULL,  
   MLCauseCodeID INT NULL,  
   MLResolutionCodeID INT NULL,  
   AnalystResidualFlagID INT NULL,  
   AnalystResolutionCodeID INT NULL,  
   AnalystCauseCodeID INT NULL,  
   AnalystDebtClassificationID INT NULL,  
   AnalystAvoidableFlagID INT NULL,  
   SMEComments nVARCHAR(4000) NULL,  
   SMEResidualFlagID INT NULL,  
   SMEDebtClassificationID INT NULL,  
   SMEAvoidableFlagID INT NULL,  
   SMECauseCodeID INT NULL  
  )  
  
  CREATE TABLE #AllPatterns(  
  ID BIGINT NULL,  
  ProjectID BIGINT NULL,  
  ApplicationID BIGINT NULL,      
  TicketPattern nVARCHAR(2000) NULL,  
  SubPattern nVARCHAR(2000) NULL,  
  AdditionalPattern nVARCHAR(2000) NULL,  
  AdditionalSubPattern nVARCHAR(2000) NULL,  
  MLResolutionCode INT NULL,  
  MLCauseCodeID INT NULL,  
  TicketOccurence INT NULL,  
  TotalOccurance INT NULL,  
  Accuracy DECIMAL(18,2) NULL  
 )  
    
  
  SET @IsTicketDescOpt = (SELECT TOP 1 IsTicketDescriptionOpted FROM ML.ConfigurationProgress WHERE ProjectID=@ProjectID AND IsDeleted=0  
        ORDER BY ID ASC)  
  
  SET @DebtAttribute = (SELECT TOP 1 DebtAttributeId FROM ML.ConfigurationProgress WHERE ProjectID=@ProjectID AND IsDeleted=0  
        ORDER BY ID ASC)  
  
  SET @ContLearningID=(SELECT TOP 1 ContLearningID FROM ML.CL_PRJ_ContLearningState(NOLOCK)  
        WHERE ProjectID=@ProjectID and IsDeleted=0 ORDER BY ContLearningID DESC)  
              
  SET @CustomerID=(SELECT top 1 CustomerID FROM [AVL].[MAS_ProjectMaster](NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0)  
  
  SELECT @StartDate = PJD.StartDateTime,@EndDate = PJD.JobDate FROM ML.CL_PRJ_ContLearningState(NOLOCK) PCS  
  JOIN ML.CL_ProjectJobDetails(NOLOCK) PJD ON PJD.ID = PCS.ProjectJobID  
  WHERE PCS.ProjectID=@ProjectID and PCS.IsDeleted=0 AND PJD.IsDeleted = 0 ORDER BY ContLearningID DESC  
  
  INSERT INTO #JobPattern  
  (ContLearningID,ProjectID,ApplicationName,ApplicationTypeName,  
  TechnologyName,TicketPattern,MLAccuracy,AnalystDebtClassificationName,AnalystAvoidableFlagName,AnalystCauseCodeName,AnalystResolutionCodeName,  
  MLResidualFlagName,MLDebtClassificationName,MLAvoidableFlagName,TicketOccurence,  
  MLCauseCodeName,SMEApproval,MLResolutionCode,TicketSubPattern,AdditionalPattern,AdditionalSubPattern)  
  
  SELECT @ContLearningID,@ProjectID,ApplicationName,ApplicationType,  
  Technology,Desc_Base_WorkPattern,MLRuleAccuracy,MLDebtClassification,MLAvoidableFlag,CauseCode,ResolutionCode,  
  MLResidualDebt,MLDebtClassification,MLAvoidableFlag,TicketOccurence,  
  CauseCode,SMEApproval,ResolutionCode,[Desc_Sub_WorkPattern],[Res_Base_WorkPattern],[Res_Sub_WorkPattern]   
  FROM @TVP_lstMLJobPattern  
  
  ---- Debt Classification  Analyst                               
  UPDATE  JP                                  
  SET     JP.AnalystDebtClassificationID =X3.DebtClassificationID                                  
  FROM    #JobPattern JP                                 
  JOIN [AVL].[DEBT_MAS_DebtClassification] X3 ON                                   
  JP.AnalystDebtClassificationName= X3.DebtClassificationName                                 
   
  ---- Debt Classification ML                            
  UPDATE  JP                                  
  SET     JP.MLDebtClassificationID =x3.DebtClassificationID                                
  FROM    #JobPattern JP                                 
  JOIN [AVL].[DEBT_MAS_DebtClassification] X3 ON                                  
  JP.MLDebtClassificationName=X3.DebtClassificationName           
    
  UPDATE #JobPattern SET AnalystAvoidableFlagName='Yes' WHERE AnalystAvoidableFlagName='Avoidable' OR AnalystAvoidableFlagName='avoidable'  
  UPDATE #JobPattern SET AnalystAvoidableFlagName='No' WHERE AnalystAvoidableFlagName='UnAvoidable' OR AnalystAvoidableFlagName='Unavoidable'  
    
  UPDATE #JobPattern SET MLAvoidableFlagName='Yes' WHERE MLAvoidableFlagName='Avoidable' OR AnalystAvoidableFlagName='avoidable'  
  UPDATE #JobPattern SET MLAvoidableFlagName='No' WHERE MLAvoidableFlagName='UnAvoidable' OR AnalystAvoidableFlagName='Unavoidable'  
  ---- Avoidable Flag      Analyst                               
  UPDATE  JP                                  
  SET     JP.AnalystAvoidableFlagID =X3.[AvoidableFlagID]                                  
  FROM    #JobPattern JP                                 
  JOIN AVL.DEBT_MAS_AvoidableFlag X3 on                                     
  JP.AnalystAvoidableFlagName= X3.[AvoidableFlagName]                              
   
  ---- Avoidable Flag     ML                            
  UPDATE  JP                                  
  SET     JP.MLAvoidableFlagID =X3.[AvoidableFlagID]                                   
  FROM    #JobPattern JP                                 
  JOIN AVL.DEBT_MAS_AvoidableFlag X3 on                                 
  JP.MLAvoidableFlagName= X3.[AvoidableFlagName]        
  ---- Residual Debt     ML                            
  UPDATE  JP   
  SET     JP.MLResidualFlagID =X3.[ResidualDebtID]      
  FROM    #JobPattern JP                            
  JOIN [AVL].[DEBT_MAS_ResidualDebt] X3 on                
  JP.MLResidualFlagName= X3.[ResidualDebtName]   
    
  ---- Residual Debt    analyst                            
  UPDATE  JP                
  SET     JP.AnalystResidualFlagID =X3.[ResidualDebtID]                                   
  FROM    #JobPattern JP                                 
  JOIN [AVL].[DEBT_MAS_ResidualDebt] X3 on                 
  JP.AnalystResidualDebtName= X3.[ResidualDebtName]          
      
  ---Cause Code  --ML  
  UPDATE  JP SET JP.MLCauseCodeID=DCC.CauseID           
  FROM #JobPattern JP        
  JOIN  [AVL].[DEBT_MAP_CauseCode] DCC ON  JP.MLCauseCodeName=DCC.CauseCode and                            
  DCC.IsDeleted=0                              
  WHERE DCC.ProjectID = @ProjectID  
    
  UPDATE  JP SET JP.AnalystCauseCodeID=DCC.CauseID           
  FROM #JobPattern JP                                
  JOIN [AVL].[DEBT_MAP_CauseCode]  DCC ON  JP.AnalystCauseCodeName=DCC.CauseCode and                            
  DCC.IsDeleted=0                              
  WHERE DCC.ProjectID = @ProjectID  
       
  ---Resolution Code  --ML  
  UPDATE  JP SET JP.AnalystResolutionCodeID=DRC.ResolutionID           
  FROM #JobPattern JP                                
  JOIN [AVL].[DEBT_MAP_ResolutionCode]  DRC ON  JP.AnalystResolutionCodeName=DRC.ResolutionCode and                            
  DRC.IsDeleted=0                              
  WHERE DRC.ProjectID = @ProjectID  
  
  ---Resolution Code  --ML  
  UPDATE  JP SET JP.MLResolutionCodeID=DRC.ResolutionID           
  FROM #JobPattern JP                                
  JOIN [AVL].[DEBT_MAP_ResolutionCode]  DRC ON  JP.MLResolutionCode=DRC.ResolutionCode and                            
  DRC.IsDeleted=0                              
  WHERE DRC.ProjectID = @ProjectID  
  
  SELECT A.ApplicationID,A.ApplicationName,A.ApplicationTypeId,A.ApplicationTypename,  
  A.PrimaryTechnologyID,A.PrimaryTechnologyName INTO #AppInfo  FROM    
  (select AM.ApplicationID,AM.ApplicationName,AT.ApplicationTypeId,AT.ApplicationTypename,  
  MT.PrimaryTechnologyID,MT.PrimaryTechnologyName  
  FROM  [AVL].[APP_MAS_ApplicationDetails] AM   
  INNER JOIN AVL.BusinessClusterMapping BCM  
  ON AM.SubBusinessClusterMapID=BCM.BusinessClusterMapID AND BCM.IsDeleted=0 AND BCM.CustomerID=@CustomerID  
  LEFT JOIN [AVL].[APP_MAS_OwnershipDetails] AT ON AM.CodeOwnership=AT.ApplicationTypeID AND AT.IsDeleted=0  
  LEFT JOIN [AVL].[APP_MAS_PrimaryTechnology] MT ON AM.PrimaryTechnologyID=MT.PrimaryTechnologyID AND MT.IsDeleted=0  
  WHERE AM.APPLICATIONID IS NOT NULL AND AM.APPLICATIONNAME  IS NOT NULL AND AM.IsActive=1 AND BCM.CustomerID=@CustomerID  
  ) AS A       
           
  UPDATE  JP                                  
  SET     JP.ApplicationID =AI.ApplicationID                                 
  FROM    #JobPattern JP                                 
  INNER JOIN #AppInfo AI ON AI.ApplicationName=JP.ApplicationName                            
  UPDATE  JP                                  
  SET     JP.ApplicationTypeID =AI.ApplicationTypeId                                 
  FROM    #JobPattern JP                                 
  INNER JOIN #AppInfo AI ON AI.ApplicationTypename  =JP.ApplicationTypeName    
  UPDATE  JP                                  
  SET     JP.TechnologyID =AI.PrimaryTechnologyID                                
  FROM    #JobPattern JP                                 
  INNER JOIN #AppInfo AI ON AI.PrimaryTechnologyName=JP.TechnologyName                
  
  UPDATE #JobPattern SET ContLearningID=@ContLearningID  
  
  IF EXISTS(SELECT 1 FROM #JobPattern)  
  BEGIN   
  
   MERGE ML.CL_TRN_PatternValidation AS TARGET  
   USING #JobPattern AS SOURCE  
   ON (TARGET.ApplicationID=SOURCE.ApplicationID AND TARGET.TicketPattern=SOURCE.TicketPattern AND ISNULL(TARGET.TicketSubPattern,'0')=ISNULL(SOURCE.TicketSubPattern,'0')   
   AND ISNULL(TARGET.AdditionalPattern,'0')=ISNULL(SOURCE.AdditionalPattern,'0') AND ISNULL(TARGET.AdditionalSubPattern,'0')=ISNULL(SOURCE.AdditionalSubPattern,'0')   
   AND ISNULL(TARGET.MLCauseCodeID,0)=ISNULL(SOURCE.MLCauseCodeID,0) AND ISNULL(TARGET.MLResolutionCodeID,0)=ISNULL(SOURCE.MLResolutionCodeID,0) AND   
   ISNULL(TARGET.MLResidualFlagID,0) = ISNULL(SOURCE.MLResidualFlagID,0)  
   AND ISNULL(TARGET.MLDebtClassificationID,0)=ISNULL(SOURCE.MLDebtClassificationID,0) AND   
   ISNULL(TARGET.MLAvoidableFlagID,0)=ISNULL(SOURCE.MLAvoidableFlagID,0) AND TARGET.IsDeleted=0 AND TARGET.ProjectID=@ProjectID AND SOURCE.ProjectID=@ProjectID   
   )  
   WHEN NOT MATCHED BY TARGET AND    
   ((@DebtAttribute = 1 AND SOURCE.MLDebtClassificationID IS NOT NULL AND SOURCE.MLAvoidableFlagID IS NOT NULL AND SOURCE.MLResidualFlagID IS NOT NULL) OR  
   (@DebtAttribute = 2 AND SOURCE.MLCauseCodeID IS NOT NULL AND SOURCE.MLResolutionCodeID IS NOT NULL AND  
   SOURCE.MLDebtClassificationID IS NOT NULL AND SOURCE.MLAvoidableFlagID IS NOT NULL AND SOURCE.MLResidualFlagID IS NOT NULL))  
     
   THEN   
   INSERT (ContLearningID,ProjectID, ApplicationID,ApplicationTypeID, TechnologyID, TicketPattern,  
   TicketSubPattern, AdditionalPattern,AdditionalSubPattern, PatternsOrigin,IsApprovedPatternsConflict, ILRuleID,  
   IsDefaultRuleSelected, MLResidualFlagID, MLDebtClassificationID , MLAvoidableFlagID , MLCauseCodeID , MLAccuracy,  
   MLResolutionCodeID,  TicketOccurence, AnalystResidualFlagID , AnalystResolutionCodeID , AnalystCauseCodeID, AnalystDebtClassificationID,  
   AnalystAvoidableFlagID , SMEComments,IsDeleted, CreatedBy,CreatedDate)  
   VALUES(@ContLearningID,@ProjectID,SOURCE.ApplicationID,SOURCE.ApplicationTypeID,SOURCE.TechnologyID,SOURCE.TicketPattern,  
   SOURCE.TicketSubPattern,SOURCE.AdditionalPattern,SOURCE.AdditionalSubPattern,'CL',NULL,NULL,NULL,SOURCE.MLResidualFlagID,  
   SOURCE.MLDebtClassificationID,SOURCE.MLAvoidableFlagID,SOURCE.MLCauseCodeID,SOURCE.MLAccuracy,SOURCE.MLResolutionCodeID,  
   SOURCE.TicketOccurence,SOURCE.AnalystResidualFlagID,SOURCE.AnalystResolutionCodeID,SOURCE.AnalystCauseCodeID,  
   SOURCE.AnalystDebtClassificationID,SOURCE.AnalystAvoidableFlagID,SOURCE.SMEApproval,0,'System',GETDATE())  
   WHEN MATCHED AND TARGET.IsDeleted=0  
   AND   
   ((@DebtAttribute = 1 AND SOURCE.MLDebtClassificationID IS NOT NULL AND SOURCE.MLAvoidableFlagID IS NOT NULL AND SOURCE.MLResidualFlagID IS NOT NULL) OR  
   (@DebtAttribute = 2 AND SOURCE.MLCauseCodeID IS NOT NULL AND SOURCE.MLResolutionCodeID IS NOT NULL AND  
   SOURCE.MLDebtClassificationID IS NOT NULL AND SOURCE.MLAvoidableFlagID IS NOT NULL AND SOURCE.MLResidualFlagID IS NOT NULL))  
   AND  
   ((@DebtAttribute = 1 AND TARGET.MLDebtClassificationID IS NOT NULL AND TARGET.MLAvoidableFlagID IS NOT NULL AND TARGET.MLResidualFlagID IS NOT NULL) OR  
    (@DebtAttribute = 2 AND TARGET.MLCauseCodeID IS NOT NULL AND TARGET.MLResolutionCodeID IS NOT NULL AND   
    TARGET.MLDebtClassificationID IS NOT NULL AND TARGET.MLAvoidableFlagID IS NOT NULL AND TARGET.MLResidualFlagID IS NOT NULL))  
   THEN  
   UPDATE SET TARGET.TicketOccurence = TARGET.TicketOccurence+SOURCE.TicketOccurence,  
   TARGET.ModifiedBy='System',  
   TARGET.ModifiedDate=GETDATE();  
  
   MERGE ML.TicketValidation AS TARGET    
     USING ML.CL_TRN_TicketValidation AS SOURCE     
      ON     
      SOURCE.TicketID = TARGET.TicketID and SOURCE.ProjectID = TARGET.ProjectID and  
      SOURCE.IsDeleted = 0 AND  TARGET.IsDeleted = 0   
      and TARGET.ProjectID = @ProjectID  
     WHEN  NOT MATCHED  BY TARGET AND (SOURCE.ProjectID = @ProjectID)  
     THEN     
      INSERT     
      (    
         ProjectID, TicketID, TicketDescription, ApplicationID, DebtClassificationID, AvoidableFlagID, ResidualDebtID, CauseCodeID,    
         ResolutionCodeID, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted, OptionalField,TicketSourceFrom,  
         TicketDescriptionBasePattern,TicketDescriptionSubPattern,ResolutionRemarksBasePattern,ResolutionRemarksSubPattern,InitialLearningID  
      )     
      VALUES    
      (    
         @ProjectID, SOURCE.TicketID, SOURCE.TicketDescription, SOURCE.ApplicationID, SOURCE.DebtClassificationID,    
         SOURCE.AvoidableFlagID, SOURCE.ResidualDebtID, SOURCE.CauseCodeID, SOURCE.ResolutionCodeID, 'System', GETDATE(), NULL, NULL, 0,SOURCE.OptionalFieldProj,'CL',  
         TicketDescriptionBasePattern,TicketDescriptionSubPattern,ResolutionRemarksBasePattern,ResolutionRemarksSubPattern,NULL  
      );   
                         
   UPDATE CTV    
   SET CTV.IsDeleted = 1 FROM ML.CL_TRN_TicketValidation CTV    
   INNER JOIN ML.TicketValidation MTV ON MTV.ProjectID = CTV.ProjectID AND MTV.TicketID = CTV.TicketID AND MTV.IsDeleted = @IsDeleted    
   WHERE CTV.ProjectID =  @ProjectID AND CTV.IsDeleted = @IsDeleted AND CONVERT(DATE, MTV.CreatedDate) = CONVERT(DATE,GETDATE())    
      
   MERGE [ML].[TRN_PatternValidation] AS TARGET    
      USING ML.CL_TRN_PatternValidation AS SOURCE     
       ON   TARGET.ProjectID = SOURCE.ProjectID AND     
          TARGET.ApplicationID = SOURCE.ApplicationID AND ISNULL(TARGET.TicketPattern,0) = ISNULL(SOURCE.TicketPattern,0) AND     
         ISNULL(TARGET.additionalPattern,0) = ISNULL(SOURCE.AdditionalPattern,0) AND ISNULL(TARGET.subPattern,0) = ISNULL(SOURCE.TicketSubPattern,0)  AND     
         ISNULL(TARGET.additionalSubPattern,0) = ISNULL(SOURCE.AdditionalSubPattern,0) AND TARGET.MLCauseCodeID = SOURCE.MLCauseCodeID AND     
         TARGET.MLResolutionCode = SOURCE.MLResolutionCodeID AND TARGET.MLDebtClassificationID = SOURCE.MLDebtClassificationID AND     
         TARGET.MLAvoidableFlagID = SOURCE.MLAvoidableFlagID AND TARGET.MLResidualFlagID = SOURCE.MLResidualFlagID AND TARGET.IsDeleted = @IsDeleted  AND SOURCE.IsDeleted = @IsDeleted    
         AND SOURCE.PatternsOrigin='CL'  
         AND SOURCE.ProjectID = @ProjectID  
         AND TARGET.ProjectID = @ProjectID  
        WHEN MATCHED  AND (SOURCE.ProjectID = @ProjectID AND TARGET.ProjectID = @ProjectID)  
        THEN     
  
         UPDATE SET     
         --TARGET.MLAccuracy = SOURCE.MLAccuracy,    
         TARGET.TicketOccurence = TARGET.TicketOccurence + SOURCE.TicketOccurence,    
         --TARGET.IsApprovedOrMute = SOURCE.IsApprovedOrMute,    
         TARGET.ContinuousLearningID = SOURCE.ContLearningID,    
         TARGET.ModifiedBy = 'System',    
         TARGET.ModifiedDate = GETDATE()   
        WHEN NOT MATCHED   BY TARGET AND (SOURCE.ProjectID = @ProjectID)  
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
            SOURCE.SMEAvoidableFlagID, SOURCE.SMECauseCodeID, SOURCE.IsApprovedOrMute, 'System', GETDATE(), NULL, NULL, 0,    
            NULL, NULL, NULL, NULL, SOURCE.MLResolutionCodeID, SOURCE.TicketSubPattern, ISNULL(SOURCE.AdditionalPattern,'0'), ISNULL(SOURCE.AdditionalSubPattern,'0'),    
            0, 0, 1, SOURCE.ContLearningID    
           );    
    
   
       -- Insert the tickets which are not present in IL Base Details table from CL Base Details table (New Learnings)    
       MERGE ML.BaseDetails AS TARGET    
       USING ML.CL_BaseDetails AS SOURCE     
        ON TARGET.ProjectID = @ProjectID AND SOURCE.ProjectID = @ProjectID AND TARGET.ProjectID = SOURCE.ProjectID    
           AND TARGET.TicketID = SOURCE.TicketID  AND TARGET.IsDeleted = @IsDeleted  AND SOURCE.IsDeleted = @IsDeleted        
           AND SOURCE.ContLearningId = @ContLearningID  
      WHEN MATCHED  AND (SOURCE.ProjectID = @ProjectID AND TARGET.ProjectID = @ProjectID)  
      THEN                
  
         UPDATE SET           
         TARGET.ApplicationName =  SOURCE.ApplicationName,    
         TARGET.DebtClassification = SOURCE.DebtClassification,   
         TARGET.AvoidableFlag = SOURCE.AvoidableFlag,   
         TARGET.ResidualDebt = SOURCE.ResidualDebt,   
         TARGET.CauseCode = SOURCE.CauseCode,   
         TARGET.ResolutionCode = SOURCE.ResolutionCode,   
         TARGET.TicketDescriptionPattern = SOURCE.TicketDescriptionPattern,   
         TARGET.TicketDescriptionSubPattern = SOURCE.TicketDescriptionSubPattern,   
         TARGET.OptionalFieldpattern = SOURCE.OptionalFieldpattern,   
         TARGET.OptionalFieldSubPattern = SOURCE.OptionalFieldSubPattern,   
         TARGET.ContinuousLearningID = SOURCE.ContLearningID,   
         TARGET.ModifiedBy = 'System',    
         TARGET.ModifiedDate = GETDATE()   
        
      WHEN NOT MATCHED   BY TARGET AND (SOURCE.ProjectID = @ProjectID)  
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
            'System', GETDATE()    
           );    
    
    UPDATE CBS    
    SET CBS.Isdeleted = 1 FROM ML.CL_BaseDetails CBS     
    INNER JOIN ML.BaseDetails MBS    
    ON MBS.TicketID = CBS.TicketID AND MBS.ProjectID = CBS.ProjectID     
    AND MBS.ContinuousLearningID = CBS.ContLearningID AND MBS.Isdeleted = @IsDeleted    
    WHERE CBS.ProjectID = @ProjectID AND CBS.IsDeleted = @IsDeleted    
    AND CONVERT(DATE, MBS.CreatedDate) = CONVERT(DATE,GETDATE())    
           
        -- After moving the CL Approved and Muted patterns to Initial Learning Pattern Validation table, make those     
        -- patterns Is Deleted in CL Pattern Validation table                        
    
     UPDATE CTPV    
        SET CTPV.IsDeleted = 1    
     FROM ML.CL_TRN_PatternValidation CTPV    
        JOIN [ML].[TRN_PatternValidation] CPVTEMP    
            ON  CPVTEMP.ProjectID = CTPV.ProjectID AND CPVTEMP.ApplicationID = CTPV.ApplicationID AND     
             ISNULL(CPVTEMP.TicketPattern,0) = ISNULL(CTPV.TicketPattern,0) AND ISNULL(CPVTEMP.AdditionalPattern,0) = ISNULL(CTPV.AdditionalPattern,0) AND      
             ISNULL(CPVTEMP.SubPattern,0) = ISNULL(CTPV.TicketSubPattern,0) AND ISNULL(CPVTEMP.AdditionalSubPattern,0) = ISNULL(CTPV.AdditionalSubPattern,0) AND      
             CPVTEMP.MLCauseCodeID = CTPV.MLCauseCodeID AND CPVTEMP.MLResolutionCode = CTPV.MLResolutionCodeID AND CTPV.IsDeleted = 0     
           WHERE CTPV.ProjectID = @ProjectID      
  
   --Get ML overrriden ticket's patterns  
   INSERT INTO #MLOverriddenPatterns(TicketID,ProjectID,ApplicationID,ApplicationTypeID,TechnologyID,TicketPattern,  
    TicketSubPattern,AdditionalPattern,AdditionalSubPattern,RuleID,  
    ResidualDebtMapID,DebtClassificationMapID,AvoidableFlag,MLCauseCodeID,MLResolutionCodeID,  
    AnalystResidualFlagID,AnalystResolutionCodeID,AnalystCauseCodeID,AnalystDebtClassificationID,  
    AnalystAvoidableFlagID,SMEComments,SMEResidualFlagID,SMEDebtClassificationID,SMEAvoidableFlagID,  
    SMECauseCodeID)  
   SELECT DISTINCT TD.TicketID,TD.ProjectID,CPT.ApplicationID,CPT.ApplicationTypeID,CPT.TechnologyID,CPT.TicketPattern,  
    CPT.subPattern,CPT.AdditionalPattern,CPT.AdditionalSubPattern,TR.RuleID,  
    TD.ResidualDebtMapID,TD.DebtClassificationMapID,TD.AvoidableFlag,TD.CauseCodeMapID,TD.ResolutionCodeMapID,  
    CPT.AnalystResidualFlagID,CPT.AnalystResolutionCodeID,CPT.AnalystCauseCodeID,CPT.AnalystDebtClassificationID,  
    CPT.AnalystAvoidableFlagID,CPT.SMEComments,CPT.SMEResidualFlagID,CPT.SMEDebtClassificationID,CPT.SMEAvoidableFlagID,  
    CPT.SMECauseCodeID  
    FROM avl.TK_TRN_TicketDetail(NOLOCK) TD  
   JOIN AVL.TK_TRN_TicketDetail_RuleID(NOLOCK) TR ON TR.TimeTickerID = TD.TimeTickerID  
   JOIN [ML].[TRN_PatternValidation](NOLOCK) CPT ON CPT.ID = TR.RuleID AND CPT.IsDeleted = 0  
   WHERE TD.ProjectID = @ProjectID AND  CPT.ProjectID = @ProjectID AND  
   TD.DebtClassificationMode = 2 AND TD.IsDeleted = 0   
   AND TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL AND TD.ResidualDebtMapID IS NOT NULL  
   AND TD.LastUpdatedDate >= @StartDate AND TD.LastUpdatedDate <= @EndDate  
           
       
   UPDATE MPV  
   SET MPV.TicketOccurence = MPV.TicketOccurence + MRV.OverRiddenCount  
   ,MPV.MLOverriddenId =  MRV.RuleID    
   FROM ML.TRN_PatternValidation MPV  
   JOIN   
   (  
    SELECT ProjectID,ApplicationID,MLCauseCodeID,MLResolutionCodeID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,  
      TicketPattern,TicketSubPattern,additionalPattern,additionalSubPattern,RuleID,COUNT(*) AS OverRiddenCount FROM #MLOverriddenPatterns  
    GROUP BY ProjectID,ApplicationID,MLCauseCodeID,MLResolutionCodeID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,  
      TicketPattern,TicketSubPattern,additionalPattern,additionalSubPattern,RuleID  
   )MRV   
   ON MRV.ApplicationID = MPV.ApplicationID  
   AND ISNULL(MRV.TicketPattern,0) = ISNULL(MPV.TicketPattern,0)   
   AND  ISNULL(MRV.TicketSubPattern,0) = ISNULL(MPV.subPattern,0)  
   AND   ISNULL(MRV.AdditionalPattern,0) = ISNULL(MPV.additionalPattern,0) AND  
       ISNULL(MRV.AdditionalSubPattern,0) = ISNULL(MPV.additionalSubPattern,0)   
        AND MRV.MLCauseCodeID = MPV.MLCauseCodeID   
        AND MRV.MLResolutionCodeID = MPV.MLResolutionCode    
        AND MRV.DebtClassificationMapID = MPV.MLDebtClassificationID   
     AND MRV.AvoidableFlag = MPV.MLAvoidableFlagID AND MRV.ResidualDebtMapID  = MPV.MLResidualFlagID          
     AND MRV.ProjectID = MPV.ProjectID  
     AND MPV.IsDeleted = 0  
  
    
  
   SELECT a.* INTO #NewMLOverriddenPatterns from  
   (  
    SELECT ProjectID,ApplicationID,MLCauseCodeID,MLResolutionCodeID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,  
       TicketPattern,TicketSubPattern,additionalPattern,additionalSubPattern  
       from #MLOverriddenPatterns  
       except  
       SELECT ProjectID,ApplicationID,MLCauseCodeID,MLResolutionCode,MLDebtClassificationID,MLAvoidableFlagID,MLResidualFlagID,  
       TicketPattern,subPattern,additionalPattern,additionalSubPattern  
       from ML.TRN_PatternValidation  
   )  
   as a  
  
        
   INSERT INTO ML.TRN_PatternValidation(ProjectID, ApplicationID,ApplicationTypeID, TechnologyID, TicketPattern,  
   MLResidualFlagID, MLDebtClassificationID , MLAvoidableFlagID , MLCauseCodeID , MLAccuracy,  
   TicketOccurence, AnalystResidualFlagID , AnalystResolutionCodeID , AnalystCauseCodeID, AnalystDebtClassificationID,  
   AnalystAvoidableFlagID , SMEComments,SMEResidualFlagID,SMEDebtClassificationID ,SMEAvoidableFlagID, SMECauseCodeID,  
   IsApprovedOrMute,Classifiedby, MLResolutionCode, SubPattern, AdditionalPattern,AdditionalSubPattern,ContinuousLearningID,  
   IsDeleted, CreatedBy,CreatedDate, MLOverriddenId,IsMlSignoff)  
   SELECT DISTINCT @ProjectID,MRPO.ApplicationID,ApplicationTypeID,TechnologyID,MRPO.TicketPattern,  
   MRPO.ResidualDebtMapID,MRPO.DebtClassificationMapID,MRPO.AvoidableFlag,MRPO.MLCauseCodeID,NULL,  
   MRPO.CountOfPattern,AnalystResidualFlagID,AnalystResolutionCodeID,AnalystCauseCodeID,AnalystDebtClassificationID,  
   AnalystAvoidableFlagID,SMEComments,SMEResidualFlagID,SMEDebtClassificationID,SMEAvoidableFlagID,SMECauseCodeID,  
   0,NULL,MRPO.MLResolutionCodeID,MRPO.TicketSubPattern,MRPO.AdditionalPattern,MRPO.AdditionalSubPattern,@ContLearningID,  
   0,'System',GETDATE(),RuleID,1  
    FROM   
   #MLOverriddenPatterns MRP  
   JOIN  
   (  
    SELECT ProjectID,ApplicationID,MLCauseCodeID,MLResolutionCodeID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,  
      TicketPattern,TicketSubPattern,additionalPattern,additionalSubPattern, COUNT(*) AS CountOfPattern  
      FROM   
      #NewMLOverriddenPatterns  
      GROUP BY  
      ProjectID,ApplicationID,MLCauseCodeID,MLResolutionCodeID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,  
      TicketPattern,TicketSubPattern,additionalPattern,additionalSubPattern  
   ) MRPO   
   ON MRPO.ApplicationID = MRP.ApplicationID  
   AND ISNULL(MRPO.TicketPattern,0) = ISNULL(MRP.TicketPattern,0)   
   AND  ISNULL(MRPO.TicketSubPattern,0) = ISNULL(MRP.TicketSubPattern,0)  
   AND   ISNULL(MRPO.AdditionalPattern,0) = ISNULL(MRP.additionalPattern,0) AND  
       ISNULL(MRPO.AdditionalSubPattern,0) = ISNULL(MRP.additionalSubPattern,0)   
        AND MRPO.MLCauseCodeID = MRP.MLCauseCodeID   
        AND MRPO.MLResolutionCodeID = MRP.MLResolutionCodeID    
        AND MRPO.DebtClassificationMapID = MRP.DebtClassificationMapID   
     AND MRPO.AvoidableFlag = MRP.AvoidableFlag   
     AND MRPO.ResidualDebtMapID  = MRP.ResidualDebtMapID        
     AND MRPO.ProjectID = MRP.ProjectID  
  
     
   INSERT INTO ML.BaseDetails  
   SELECT null,MLO.ProjectID,MLO.TicketID,AI.ApplicationName,DC.DebtClassificationName,MA.AvoidableFlagName,RD.ResidualDebtName, MCP.CauseCode,MRP.ResolutionCode,  
   MLO.TicketPattern,MLO.TicketSubPattern,MLO.AdditionalPattern,MLO.AdditionalSubPattern,  
   0,@ContLearningID,'SYSTEM',GETDATE(),NULL,NULL FROM  #MLOverriddenPatterns MLO  
   JOIN [AVL].[DEBT_MAS_DebtClassification](NOLOCK) DC ON DC.DebtClassificationID = MLO.DebtClassificationMapID  
   JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) MA ON MA.AvoidableFlagID = MLO.AvoidableFlag  
   JOIN [AVL].[DEBT_MAS_ResidualDebt](NOLOCK) RD ON RD.ResidualDebtID = MLO.ResidualDebtMapID  
   JOIN [AVL].[DEBT_MAP_CauseCode](NOLOCK) MCP ON MCP.CauseID = MLO.MLCauseCodeID AND MCP.ProjectID = MLO.ProjectID AND MCP.IsDeleted=0  
   JOIN [AVL].[DEBT_MAP_ResolutionCode](NOLOCK) MRP ON MRP.ResolutionID = MLO.MLResolutionCodeID AND MRP.ProjectID = MLO.ProjectID AND MRP.IsDeleted=0  
   JOIN #AppInfo AI ON AI.ApplicationID = MLO.ApplicationID   
  
   INSERT INTO ML.TicketValidation  
   SELECT ProjectID,TicketID,'', ApplicationID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,  
   MLCauseCodeID,MLResolutionCodeID,'','SYSTEM',GETDATE(),NULL,NULL,0,'CL',  
   CASE WHEN @IsTicketDescOpt = 1 THEN '0' ELSE TicketPattern END,  
   CASE WHEN @IsTicketDescOpt = 1 THEN '0' ELSE TicketSubPattern END,  
   CASE WHEN @IsTicketDescOpt = 1 THEN '0' ELSE AdditionalPattern END,  
   CASE WHEN @IsTicketDescOpt = 1 THEN '0' ELSE AdditionalSubPattern END,  
   NULL,  
   NULL  
   FROM #MLOverriddenPatterns  
  
  
   --Get All patterns for find total occurance  
   INSERT INTO #AllPatterns  
  (ID,ProjectID,ApplicationID,TicketPattern,SubPattern,AdditionalPattern,AdditionalSubPattern,  
  MLResolutionCode,MLCauseCodeID,TicketOccurence)  
  SELECT ID,ProjectID,ApplicationID,TicketPattern,SubPattern,AdditionalPattern,AdditionalSubPattern,  
  MLResolutionCode,MLCauseCodeID,TicketOccurence  
  FROM [ML].[TRN_PatternValidation](NOLOCK) WHERE ProjectID=@ProjectID AND   
  IsDeleted=0 AND (ISNULL(TicketPattern,'0') <> '0')  
  AND (ApplicationID IS NOT NULL AND ISNULL(ApplicationID,0)<>0)   
  AND (MLCauseCodeID IS NOT NULL AND ISNULL(MLCauseCodeID,0)<>0)   
  AND (MLResolutionCode IS NOT NULL AND ISNULL(MLResolutionCode,0)<>0)  
  AND (MLDebtClassificationID IS NOT NULL AND ISNULL(MLDebtClassificationID,0)<>0)  
  AND (MLAvoidableFlagID IS NOT NULL AND ISNULL(MLAvoidableFlagID,0)<>0)  
  AND (MLResidualFlagID IS NOT NULL AND ISNULL(MLResidualFlagID,0)<>0)  
  AND TicketOccurence <> 0  
  
  --Calculate and update total occurance each rule by overall tickets count  
  IF(@DebtAttribute = 1)  
  BEGIN  
   UPDATE X SET X.TotalOccurance = Y.TotalOccurance  
   FROM #AllPatterns X  
   INNER JOIN (SELECT ProjectID,[ApplicationID],TicketPattern,SubPattern,AdditionalPattern,AdditionalSubPattern,  
   MLCauseCodeID,MLResolutionCode,SUM(TicketOccurence)   
   AS TotalOccurance FROM #AllPatterns GROUP BY ProjectID,[ApplicationID],  
   TicketPattern,subPattern,AdditionalPattern,AdditionalSubPattern,  
   MLCauseCodeID,MLResolutionCode) Y  
   ON X.ProjectID = Y.ProjectID  
   AND X.[ApplicationID] = Y.[ApplicationID]   
   AND X.TicketPattern=Y.TicketPattern   
   AND X.subPattern=Y.subPattern      
   AND X.AdditionalPattern=Y.AdditionalPattern   
   AND X.AdditionalSubPattern=Y.AdditionalSubPattern  
   AND X.MLCauseCodeID=Y.MLCauseCodeID  
   AND X.MLResolutionCode=Y.MLResolutionCode;  
  END  
  ELSE IF(@DebtAttribute = 2)  
  BEGIN  
   UPDATE X SET X.TotalOccurance = Y.TotalOccurance  
   FROM #AllPatterns X  
   INNER JOIN (SELECT ProjectID,[ApplicationID],TicketPattern,SubPattern,  
   AdditionalPattern,AdditionalSubPattern,SUM(TicketOccurence)   
   AS TotalOccurance FROM #AllPatterns GROUP BY ProjectID,[ApplicationID],  
   TicketPattern,subPattern,AdditionalPattern,AdditionalSubPattern) Y  
   ON X.ProjectID = Y.ProjectID  
   AND X.[ApplicationID] = Y.[ApplicationID]   
   AND X.TicketPattern=Y.TicketPattern   
   AND X.subPattern=Y.subPattern      
   AND X.AdditionalPattern=Y.AdditionalPattern   
   AND X.AdditionalSubPattern=Y.AdditionalSubPattern  
  END  
  --Calculate and update accuracy for each rule  
  UPDATE X SET X.Accuracy = X.TicketOccurence * 100.0 / X.TotalOccurance  
  FROM #AllPatterns X;  
  
  --Update Pattern Validation table  
  UPDATE Q SET Q.MLAccuracy=C.Accuracy FROM [ML].[TRN_PatternValidation] Q JOIN #AllPatterns C ON  
  C.ID=Q.ID AND Q.ProjectID=C.ProjectID;  
  
  END  
  
--Update Job status completed  
 UPDATE ML.CL_PRJ_ContLearningState SET PresentStatus = @JobStatus WHERE ProjectID = @ProjectID AND ContLearningID = @ContLearningID AND IsDeleted = 0;  
COMMIT TRAN  
END TRY    
BEGIN CATCH    
  ROLLBACK TRAN  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  DECLARE @ErrorLine VARCHAR(MAX);  
    SELECT @ErrorLine=ERROR_LINE()  
  SELECT @ErrorMessage = ERROR_MESSAGE()+' ErrorLine:'+@ErrorLine  
  
  
  --INSERT Error      
  EXEC AVL_InsertError 'ML.CL_SavePatternAlgorithmForJob', @ErrorMessage, @ProjectID ,0  
    
 END CATCH    
END
