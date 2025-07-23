/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ML].[CL_SaveInfraPatternAlgorithmForJob]
@ProjectID BIGINT,
@TVP_lstInfraJobPattern ML.TVP_InfraCLJobPattern READONLY
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
			TowerID BIGINT NULL,
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
			TowerName nVARCHAR(2000) NULL,
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
			TowerID BIGINT NULL,
			TicketPattern nVARCHAR(2000) NULL,
			TicketSubPattern nVARCHAR(2000) NULL,
			AdditionalPattern nVARCHAR(2000) NULL,
			AdditionalSubPattern nVARCHAR(2000) NULL,
			RuleID BIGINT NULL,
			ResidualDebtMapID INT NULL,
			DebtClassificationMapID INT NULL,
			AvoidableFlag INT NULL,
			MLCauseCodeID INT NULL,
			MLResolutionCodeID INT NULL

		)

		CREATE TABLE #AllPatterns(
		ID BIGINT NULL,
		ProjectID BIGINT NULL,
		TowerID BIGINT NULL,				
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
		

		SET @IsTicketDescOpt = (SELECT TOP 1 IsTicketDescriptionOpted FROM ML.InfraconfigurationProgress WHERE ProjectID=@ProjectID AND IsDeleted=0
								ORDER BY ID ASC)

		SET @DebtAttribute = (SELECT TOP 1 DebtAttributeId FROM ML.InfraconfigurationProgress WHERE ProjectID=@ProjectID AND IsDeleted=0
								ORDER BY ID ASC)

		SET @ContLearningID=(SELECT TOP 1 ContLearningID FROM ML.CL_PRJ_InfraContLearningState(NOLOCK)
								WHERE ProjectID=@ProjectID and IsDeleted=0 ORDER BY ContLearningID DESC)
										
											
		SET @CustomerID=(SELECT top 1 CustomerID FROM [AVL].[MAS_ProjectMaster](NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0)

		SELECT @StartDate = PJD.StartDateTime,@EndDate = PJD.JobDate FROM ML.CL_PRJ_InfraContLearningState(NOLOCK) PCS
		JOIN ML.CL_InfraProjectJobDetails(NOLOCK) PJD ON PJD.ID = PCS.ProjectJobID
		WHERE PCS.ProjectID=@ProjectID and PCS.IsDeleted=0 AND PJD.IsDeleted = 0 ORDER BY ContLearningID DESC

		INSERT INTO #JobPattern
		(ContLearningID,ProjectID,TowerName,
		TicketPattern,MLAccuracy,AnalystDebtClassificationName,AnalystAvoidableFlagName,AnalystCauseCodeName,AnalystResolutionCodeName,
		MLResidualFlagName,MLDebtClassificationName,MLAvoidableFlagName,TicketOccurence,
		MLCauseCodeName,SMEApproval,MLResolutionCode,TicketSubPattern,AdditionalPattern,AdditionalSubPattern)

		SELECT @ContLearningID,@ProjectID,TowerName,
		Desc_Base_WorkPattern,MLRuleAccuracy,MLDebtClassification,MLAvoidableFlag,CauseCode,ResolutionCode,
		MLResidualDebt,MLDebtClassification,MLAvoidableFlag,TicketOccurence,
		CauseCode,SMEApproval,ResolutionCode,[Desc_Sub_WorkPattern],[Res_Base_WorkPattern],[Res_Sub_WorkPattern] 
		FROM @TVP_lstInfraJobPattern

		---- Debt Classification  Analyst                             
		UPDATE  JP                                
		SET     JP.AnalystDebtClassificationID =X3.DebtClassificationID                                
		FROM    #JobPattern JP                               
		JOIN [AVL].[DEBT_MAS_DebtClassificationInfra] X3 ON                                 
		JP.AnalystDebtClassificationName= X3.DebtClassificationName                               
 
		---- Debt Classification ML                          
		UPDATE  JP                                
		SET     JP.MLDebtClassificationID =x3.DebtClassificationID                              
		FROM    #JobPattern JP                               
		JOIN [AVL].[DEBT_MAS_DebtClassificationInfra] X3 ON                                
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

		
		SELECT A.TowerID,A.TowerName INTO #AppInfo FROM  
		(select IPM.TowerID,AMR.TowerName
		FROM AVL.InfraTowerDetailsTransaction(NOLOCK) AMR
		INNER JOIN AVL.InfraHierarchyMappingTransaction(NOLOCK) IHT
			ON IHT.CustomerID=AMR.CustomerID
			AND IHT.InfraTransMappingID=AMR.InfraTransMappingID
			AND ISNULL(IHT.IsDeleted,0)=0  
		INNER JOIN  AVL.InfraHierarchyOneTransaction(NOLOCK) IOT
			ON IHT.CustomerID=IOT.CustomerID 
			AND IHT.HierarchyOneTransactionID=IOT.HierarchyOneTransactionID 
			AND IOT.IsDeleted=0
		INNER JOIN AVL.InfraHierarchyTwoTransaction(NOLOCK) ITT 
			ON IHT.CustomerID=ITT.CustomerID 
			AND IHT.HierarchyTwoTransactionID=ITT.HierarchyTwoTransactionID 
			AND ITT.IsDeleted=0 
		INNER JOIN AVL.InfraTowerProjectMapping(NOLOCK) IPM  
			ON AMR.InfraTowerTransactionID=IPM.TowerID AND IPM.IsEnabled = 1 AND IPM.IsDeleted = 0 AND IPM.ProjectID = @ProjectID
		) AS A 

         
		UPDATE  JP                                
		SET     JP.TowerID =AI.TowerID                               
		FROM    #JobPattern JP                               
		INNER JOIN #AppInfo AI ON AI.TowerName=JP.TowerName                        

		UPDATE #JobPattern SET ContLearningID=@ContLearningID

		IF EXISTS(SELECT 11 FROM #JobPattern)
		BEGIN	

			MERGE ML.CL_TRN_InfraPatternValidation AS TARGET
			USING #JobPattern AS SOURCE
			ON (

			TARGET.TowerID=SOURCE.TowerID
			AND TARGET.TicketPattern=SOURCE.TicketPattern AND ISNULL(TARGET.TicketSubPattern,'0')=ISNULL(SOURCE.TicketSubPattern,'0') 
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
			INSERT (ContLearningID,ProjectID, 
			TowerID,
			TicketPattern,
			TicketSubPattern, AdditionalPattern,AdditionalSubPattern, PatternsOrigin,IsApprovedPatternsConflict, ILRuleID,
			IsDefaultRuleSelected, MLResidualFlagID, MLDebtClassificationID , MLAvoidableFlagID , MLCauseCodeID , MLAccuracy,
			MLResolutionCodeID,  TicketOccurence, AnalystResidualFlagID , AnalystResolutionCodeID , AnalystCauseCodeID, AnalystDebtClassificationID,
			AnalystAvoidableFlagID , SMEComments,IsDeleted, CreatedBy,CreatedDate)
			VALUES(@ContLearningID,@ProjectID,
			SOURCE.TowerID,
			SOURCE.TicketPattern,
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

			MERGE ML.InfraTicketValidation AS TARGET  
					USING ML.CL_TRN_InfraTicketValidation AS SOURCE   
						ON   
						SOURCE.TicketID = TARGET.TicketID and SOURCE.ProjectID = TARGET.ProjectID and
						SOURCE.IsDeleted = 0 AND  TARGET.IsDeleted = 0 
						and TARGET.ProjectID = @ProjectID
					WHEN  NOT MATCHED  BY TARGET AND (SOURCE.ProjectID = @ProjectID)
					THEN   
						INSERT   
						(  
									ProjectID, TicketID, TicketDescription,TowerID, 
									DebtClassificationID, AvoidableFlagID, ResidualDebtID, CauseCodeID,  
									ResolutionCodeID, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted, OptionalField,TicketSourceFrom,
									TicketDescriptionBasePattern,TicketDescriptionSubPattern,ResolutionRemarksBasePattern,ResolutionRemarksSubPattern
						)   
						VALUES  
						(  
									@ProjectID, SOURCE.TicketID, SOURCE.TicketDescription, SOURCE.TowerID,
									SOURCE.DebtClassificationID,  
									SOURCE.AvoidableFlagID, SOURCE.ResidualDebtID, SOURCE.CauseCodeID, SOURCE.ResolutionCodeID, 'System', GETDATE(), NULL, NULL, 0,SOURCE.OptionalFieldProj,'CL',
									TicketDescriptionBasePattern,TicketDescriptionSubPattern,ResolutionRemarksBasePattern,ResolutionRemarksSubPattern
						); 
                       
			UPDATE CTV  
			SET CTV.IsDeleted = 1 FROM ML.CL_TRN_InfraTicketValidation CTV  
			INNER JOIN ML.InfraTicketValidation MTV ON MTV.ProjectID = CTV.ProjectID AND MTV.TicketID = CTV.TicketID AND MTV.IsDeleted = @IsDeleted  
			WHERE CTV.ProjectID =  @ProjectID AND CTV.IsDeleted = @IsDeleted AND CONVERT(DATE, MTV.CreatedDate) = CONVERT(DATE,GETDATE())  
				
			MERGE [ML].[InfraTRN_PatternValidation] AS TARGET  
					 USING ML.CL_TRN_InfraPatternValidation AS SOURCE   
							ON   TARGET.ProjectID = SOURCE.ProjectID AND   
									TARGET.TowerID = SOURCE.TowerID
								  AND ISNULL(TARGET.TicketPattern,0) = ISNULL(SOURCE.TicketPattern,0) AND   
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
								 TARGET.TicketOccurence = TARGET.TicketOccurence + SOURCE.TicketOccurence,   
								 TARGET.ContinuousLearningID = SOURCE.ContLearningID,  
								 TARGET.ModifiedBy = 'System',  
								 TARGET.ModifiedDate = GETDATE() 
						  WHEN NOT MATCHED   BY TARGET AND (SOURCE.ProjectID = @ProjectID)
						  THEN          
								   INSERT   
								   (  
										  InitialLearningID, ProjectID, TowerID,									
										  TicketPattern, MLResidualFlagID,  
										  MLDebtClassificationID, MLAvoidableFlagID, MLCauseCodeID, MLAccuracy, TicketOccurence, 
										  IsApprovedOrMute, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted,  
										  ReasonForResidual, ExpectedCompDate, MLResolutionCode, subPattern, additionalPattern, additionalSubPattern,  
										  OverridenPatternCount, OverridenPatternTotalCount, IsMLSignOff, ContinuousLearningID  
								   )  
								   VALUES   
								   (  
										  NULL, @ProjectID, SOURCE.TowerID, 
										  SOURCE.TicketPattern, SOURCE.MLResidualFlagID,  
										  SOURCE.MLDebtClassificationID, SOURCE.MLAvoidableFlagID, SOURCE.MLCauseCodeID, SOURCE.MLAccuracy, SOURCE.TicketOccurence,  										 
										  SOURCE.IsApprovedOrMute, 'System', GETDATE(), NULL, NULL, 0,  
										  NULL, NULL, SOURCE.MLResolutionCodeID, SOURCE.TicketSubPattern, ISNULL(SOURCE.AdditionalPattern,'0'), ISNULL(SOURCE.AdditionalSubPattern,'0'),  
										  0, 0, 1, SOURCE.ContLearningID  
								   );  
  

								
						 -- Insert the tickets which are not present in IL Base Details table from CL Base Details table (New Learnings)  
						 MERGE ML.InfraBaseDetails AS TARGET  
						 USING ML.CL_InfraBaseDetails AS SOURCE   
							 ON TARGET.ProjectID = @ProjectID AND SOURCE.ProjectID = @ProjectID AND TARGET.ProjectID = SOURCE.ProjectID  
								   AND TARGET.TicketID = SOURCE.TicketID  AND TARGET.IsDeleted = @IsDeleted  AND SOURCE.IsDeleted = @IsDeleted                  
						WHEN MATCHED  AND (SOURCE.ProjectID = @ProjectID AND TARGET.ProjectID = @ProjectID)
						THEN										    

								 UPDATE SET	
								 TARGET.TowerName =  SOURCE.TowerName,  
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
										  InitialLearningID, ProjectID, TicketID,TowerName,
										  DebtClassification, AvoidableFlag, ResidualDebt,  
										  CauseCode, ResolutionCode, TicketDescriptionPattern, TicketDescriptionSubPattern, OptionalFieldpattern,  
										  OptionalFieldSubPattern, IsDeleted, ContinuousLearningID,  
										  CreatedBy,CreatedDate  
								 )   
								   VALUES   
								   (  
										  NULL, @ProjectID, SOURCE.TicketID, SOURCE.TowerName,
										  SOURCE.DebtClassification, SOURCE.AvoidableFlag,  
										  SOURCE.ResidualDebt, SOURCE.CauseCode, SOURCE.ResolutionCode, SOURCE.TicketDescriptionPattern,  
										  SOURCE.TicketDescriptionSubPattern, SOURCE.OptionalFieldpattern, SOURCE.OptionalFieldSubPattern, 0, SOURCE.ContLearningID,  
										  'System', GETDATE()  
								   );  
  
			 UPDATE CBS  
			 SET CBS.Isdeleted = 1 FROM ML.CL_InfraBaseDetails CBS   
			 INNER JOIN ML.InfraBaseDetails MBS  
			 ON MBS.TicketID = CBS.TicketID AND MBS.ProjectID = CBS.ProjectID   
			 AND MBS.ContinuousLearningID = CBS.ContLearningID AND MBS.Isdeleted = @IsDeleted  
			 WHERE CBS.ProjectID = @ProjectID AND CBS.IsDeleted = @IsDeleted  
			 AND CONVERT(DATE, MBS.CreatedDate) = CONVERT(DATE,GETDATE())  
         
							 -- After moving the CL Approved and Muted patterns to Initial Learning Pattern Validation table, make those   
							 -- patterns Is Deleted in CL Pattern Validation table                      
  
			  UPDATE CTPV  
							 SET CTPV.IsDeleted = 1  
			  FROM ML.CL_TRN_InfraPatternValidation CTPV  
							 JOIN [ML].[InfraTRN_PatternValidation] CPVTEMP  
										  ON  CPVTEMP.ProjectID = CTPV.ProjectID AND CPVTEMP.TowerID = CTPV.TowerID AND 
												 --CPVTEMP.ApplicationID = CTPV.ApplicationID AND   
												 ISNULL(CPVTEMP.TicketPattern,0) = ISNULL(CTPV.TicketPattern,0) AND ISNULL(CPVTEMP.AdditionalPattern,0) = ISNULL(CTPV.AdditionalPattern,0) AND    
												 ISNULL(CPVTEMP.SubPattern,0) = ISNULL(CTPV.TicketSubPattern,0) AND ISNULL(CPVTEMP.AdditionalSubPattern,0) = ISNULL(CTPV.AdditionalSubPattern,0) AND    
												 CPVTEMP.MLCauseCodeID = CTPV.MLCauseCodeID AND CPVTEMP.MLResolutionCode = CTPV.MLResolutionCodeID AND CTPV.IsDeleted = 0   
								   WHERE CTPV.ProjectID = @ProjectID 			

			--Get ML overrriden ticket's patterns
			INSERT INTO #MLOverriddenPatterns(TicketID,ProjectID,TowerID,
			 TicketPattern,
			 TicketSubPattern,AdditionalPattern,AdditionalSubPattern,RuleID,
			 ResidualDebtMapID,DebtClassificationMapID,AvoidableFlag,MLCauseCodeID,MLResolutionCodeID
			 )
			SELECT DISTINCT TD.TicketID,TD.ProjectID,CPT.TowerID,
			 CPT.TicketPattern,
			 CPT.subPattern,CPT.AdditionalPattern,CPT.AdditionalSubPattern,TR.RuleID,
			 TD.ResidualDebtMapID,TD.DebtClassificationMapID,TD.AvoidableFlag,TD.CauseCodeMapID,TD.ResolutionCodeMapID
			 FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD
			JOIN AVL.TK_TRN_InfraTicketDetail_RuleID(NOLOCK) TR ON TR.TimeTickerID = TD.TimeTickerID
			JOIN [ML].[InfraTRN_PatternValidation](NOLOCK) CPT ON CPT.ID = TR.RuleID AND CPT.IsDeleted = 0
			WHERE TD.ProjectID = @ProjectID AND  CPT.ProjectID = @ProjectID AND
			TD.DebtClassificationMode = 2 AND TD.IsDeleted = 0 
			AND TD.DebtClassificationMapID IS NOT NULL AND TD.AvoidableFlag IS NOT NULL AND TD.ResidualDebtMapID IS NOT NULL
			AND TD.LastUpdatedDate >= @StartDate AND TD.LastUpdatedDate <= @EndDate
									
					
			UPDATE MPV
			SET MPV.TicketOccurence = MPV.TicketOccurence + MRV.OverRiddenCount
			,MPV.MLOverriddenId =  MRV.RuleID  
			FROM ML.InfraTRN_PatternValidation MPV
			JOIN 
			(
				SELECT ProjectID,TowerID,MLCauseCodeID,MLResolutionCodeID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,
						TicketPattern,TicketSubPattern,additionalPattern,additionalSubPattern,RuleID,COUNT(*) AS OverRiddenCount FROM #MLOverriddenPatterns
				GROUP BY ProjectID,TowerID,MLCauseCodeID,MLResolutionCodeID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,
						TicketPattern,TicketSubPattern,additionalPattern,additionalSubPattern,RuleID
			)MRV 
			ON MRV.TowerID = MPV.TowerID
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
						
			INSERT INTO ML.InfraTRN_PatternValidation(ProjectID, TowerID, TicketPattern,
			MLResidualFlagID, MLDebtClassificationID , MLAvoidableFlagID , MLCauseCodeID , MLAccuracy,
			TicketOccurence,IsApprovedOrMute, MLResolutionCode, SubPattern, AdditionalPattern,AdditionalSubPattern,ContinuousLearningID,
			IsDeleted, CreatedBy,CreatedDate, MLOverriddenId,IsMlSignoff)
			SELECT DISTINCT @ProjectID,MRPO.TowerID,MRPO.TicketPattern,
			MRPO.ResidualDebtMapID,MRPO.DebtClassificationMapID,MRPO.AvoidableFlag,MRPO.MLCauseCodeID,NULL,
			1,0,MRPO.MLResolutionCodeID,MRPO.TicketSubPattern,MRPO.AdditionalPattern,MRPO.AdditionalSubPattern,@ContLearningID,
			0,'System',GETDATE(),RuleID,1
			 FROM 
			#MLOverriddenPatterns MRP
			JOIN
			(
				SELECT ProjectID,TowerID,MLCauseCodeID,MLResolutionCodeID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,
						TicketPattern,TicketSubPattern,additionalPattern,additionalSubPattern
						FROM 
						#MLOverriddenPatterns
						GROUP BY
						ProjectID,TowerID,MLCauseCodeID,MLResolutionCodeID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,
						TicketPattern,TicketSubPattern,additionalPattern,additionalSubPattern
			) MRPO 
			ON MRPO.TowerID = MRP.TowerID
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

			
			INSERT INTO ML.InfraBaseDetails
			SELECT null,MLO.ProjectID,MLO.TicketID,AI.TowerName,DC.DebtClassificationName,MA.AvoidableFlagName,RD.ResidualDebtName, MCP.CauseCode,MRP.ResolutionCode,
			MLO.TicketPattern,MLO.TicketSubPattern,MLO.AdditionalPattern,MLO.AdditionalSubPattern,
			0,@ContLearningID,'SYSTEM',GETDATE(),NULL,NULL FROM  #MLOverriddenPatterns MLO
			JOIN [AVL].[DEBT_MAS_DebtClassificationInfra](NOLOCK) DC ON DC.DebtClassificationID = MLO.DebtClassificationMapID
			JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) MA ON MA.AvoidableFlagID = MLO.AvoidableFlag
			JOIN [AVL].[DEBT_MAS_ResidualDebt](NOLOCK) RD ON RD.ResidualDebtID = MLO.ResidualDebtMapID
			JOIN [AVL].[DEBT_MAP_CauseCode](NOLOCK) MCP ON MCP.CauseID = MLO.MLCauseCodeID AND MCP.ProjectID = MLO.ProjectID AND MCP.IsDeleted=0
			JOIN [AVL].[DEBT_MAP_ResolutionCode](NOLOCK) MRP ON MRP.ResolutionID = MLO.MLResolutionCodeID AND MRP.ProjectID = MLO.ProjectID AND MRP.IsDeleted=0
			JOIN #AppInfo AI ON AI.TowerID = MLO.TowerID 

			INSERT INTO ML.InfraTicketValidation
			SELECT ProjectID,TicketID,'', TowerID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID,
			MLCauseCodeID,MLResolutionCodeID,'','SYSTEM',GETDATE(),NULL,NULL,0,'CL',
			CASE WHEN @IsTicketDescOpt = 1 THEN '0' ELSE TicketPattern END,
			CASE WHEN @IsTicketDescOpt = 1 THEN '0' ELSE TicketSubPattern END,
			CASE WHEN @IsTicketDescOpt = 1 THEN '0' ELSE AdditionalPattern END,
			CASE WHEN @IsTicketDescOpt = 1 THEN '0' ELSE AdditionalSubPattern END,null,null
			FROM #MLOverriddenPatterns

			
			--Get All patterns for find total occurance
			INSERT INTO #AllPatterns
		(ID,ProjectID,TowerID,TicketPattern,SubPattern,AdditionalPattern,AdditionalSubPattern,
		MLResolutionCode,MLCauseCodeID,TicketOccurence)
		SELECT ID,ProjectID,TowerID,TicketPattern,SubPattern,AdditionalPattern,AdditionalSubPattern,
		MLResolutionCode,MLCauseCodeID,TicketOccurence
		FROM [ML].[InfraTRN_PatternValidation](NOLOCK) WHERE ProjectID=@ProjectID AND 
		IsDeleted=0 AND (ISNULL(TicketPattern,'0') <> '0')
		AND (TowerID IS NOT NULL AND ISNULL(TowerID,0)<>0) 
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
			INNER JOIN (SELECT ProjectID,TowerID,TicketPattern,SubPattern,AdditionalPattern,AdditionalSubPattern,
			MLCauseCodeID,MLResolutionCode,SUM(TicketOccurence) 
			AS TotalOccurance FROM #AllPatterns GROUP BY ProjectID,TowerID,
			TicketPattern,subPattern,AdditionalPattern,AdditionalSubPattern,
			MLCauseCodeID,MLResolutionCode) Y
			ON X.ProjectID = Y.ProjectID
			AND X.TowerID = Y.TowerID 
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
			INNER JOIN (SELECT ProjectID,TowerID,TicketPattern,SubPattern,
			AdditionalPattern,AdditionalSubPattern,SUM(TicketOccurence) 
			AS TotalOccurance FROM #AllPatterns GROUP BY ProjectID,TowerID,
			TicketPattern,subPattern,AdditionalPattern,AdditionalSubPattern) Y
			ON X.ProjectID = Y.ProjectID
			AND X.TowerID = Y.TowerID 
			AND X.TicketPattern=Y.TicketPattern 
			AND X.subPattern=Y.subPattern 			
			AND X.AdditionalPattern=Y.AdditionalPattern 
			AND X.AdditionalSubPattern=Y.AdditionalSubPattern
		END
		--Calculate and update accuracy for each rule
		UPDATE X SET X.Accuracy = X.TicketOccurence * 100.0 / X.TotalOccurance
		FROM #AllPatterns X;

		--Update Pattern Validation table
		UPDATE Q SET Q.MLAccuracy=C.Accuracy FROM [ML].[InfraTRN_PatternValidation] Q JOIN #AllPatterns C ON
		C.ID=Q.ID AND Q.ProjectID=C.ProjectID;

		END

--Update Job status completed
 UPDATE ML.CL_PRJ_InfraContLearningState SET PresentStatus = @JobStatus WHERE ProjectID = @ProjectID AND ContLearningID = @ContLearningID AND IsDeleted = 0;

--select @JobStatus from ML.CL_PRJ_InfraContLearningState WHERE ProjectID = @ProjectID AND ContLearningID = @ContLearningID AND IsDeleted = 0;
COMMIT TRAN
END TRY  
BEGIN CATCH  
		ROLLBACK TRAN
		DECLARE @ErrorMessage VARCHAR(MAX);
		DECLARE @ErrorLine VARCHAR(MAX);
				SELECT @ErrorLine=ERROR_LINE()
		SELECT @ErrorMessage = ERROR_MESSAGE()+' ErrorLine:'+@ErrorLine


		--INSERT Error    
		EXEC AVL_InsertError 'ML.CL_SaveInfraPatternAlgorithmForJob', @ErrorMessage, @ProjectID ,0
		
	END CATCH  
END
