CREATE PROCEDURE [ML].[MLProjectMigration]
AS
BEGIN
BEGIN TRY 
  BEGIN TRAN 
     
	 UPDATE AVL.ML_PRJ_InitialLearningState  SET OptionalFieldupl=0 WHERE OptionalFieldupl = 'O'

	----INSERT ConfigurationProgress_Migration
	INSERT INTO  [ML].[ConfigurationProgress]
		(			
		 ProjectID
		,FromDate
		,ToDate
		,IsOptionalField
		,DebtAttributeId
		,IsNoiseEliminationSentorReceived
		,IsNoiseSkipped
		,IsSamplingSentOrReceived
		,IsSamplingInProgress
		,IsMLSentOrReceived
		,IsDeleted
		,CreatedBy
		,CreatedDate
		,ModifiedBy
		,ModifiedDate
		,IsTicketDescriptionOpted
		)
	SELECT 	
		 ICP.ProjectID
		,ICP.StartDate
		,ICP.EndDate
		,convert(nvarchar,isnull(ICP.OptionalFieldupl,0)) 
		,1
		,ICP.IsNoiseEliminationSentorReceived
		,ICP.IsNoiseSkipped
		,ICP.IsSamplingSentOrReceived
		,ICP.IsSamplingInProgress
		,ICP.IsMLSentOrReceived
		,ICP.IsDeleted
		,ICP.CreatedBy
		,ICP.CreatedDate
		,ICP.ModifiedBy
		,ICP.ModifiedDate
		,1
	FROM AVL.ML_PRJ_InitialLearningState ICP
	LEFT JOIN ML.ConfigurationProgress(NOLOCK)ICPM
	ON ICPM.ProjectID=ICP.ProjectID	
	WHERE ICPM.ProjectID IS NULL

	---Base Details


	INSERT INTO  [ML].[BaseDetails]
		(			
		     InitialLearningID
			,ProjectID
			,TicketID
			,ApplicationName
			,DebtClassification
			,AvoidableFlag
			,ResidualDebt
			,CauseCode
			,ResolutionCode
			,TicketDescriptionPattern
			,TicketDescriptionSubPattern
			,OptionalFieldpattern
			,OptionalFieldSubPattern
			,Isdeleted
			,ContinuousLearningID
			,CreatedBy
			,CreatedDate
			,ModifiedBy
			,ModifiedDate

		)
		SELECT DISTINCT	
		     MB.InitialLearningID
			,MB.ProjectID
			,MB.TicketID
			,MB.ApplicationName
			,MB.DebtClassification
			,MB.AvoidableFlag
			,MB.ResidualDebt
			,MB.CauseCode
			,MB.ResolutionCode
			,MB.TicketDescriptionPattern
			,MB.TicketDescriptionSubPattern
			,MB.OptionalFieldpattern
			,MB.OptionalFieldSubPattern
			,MB.Isdeleted
			,MB.ContinuousLearningID
			,MB.CreatedBy
			,MB.CreatedDate
			,MB.ModifiedBy
			,MB.ModifiedDate
		FROM [dbo].[ML_MLBaseDetails](NOLOCK) MB
		LEFT JOIN ML.BaseDetails(NOLOCK)MBM
		ON MBM.ProjectID=MB.ProjectID		
		WHERE MBM.ProjectID IS NULL

		---OptionalFieldNoiseWord

		INSERT INTO [ML].[OptionalFieldNoiseWords]
			(			
		     ProjectID
			,OptionalFieldNoiseWord
			,Frequency
			,IsActive
			,CreatedDate
			,CreatedBy
			)
		SELECT 	
		     OFN.ProjectID
			,OFN.OptionalFieldNoiseWord
			,OFN.Frequency
			,OFN.IsActive
			,OFN.CreatedDate
			,OFN.CreatedBy
		FROM [AVL].[ML_OptionalFieldNoiseWords] OFN
		LEFT JOIN ML.OptionalFieldNoiseWords(NOLOCK)OFNM
		ON OFNM.ProjectID=OFN.ProjectID		
		WHERE OFNM.ProjectID IS NULL

		---OptionalFieldNoiseWordTemp

		INSERT INTO [ML].[OptionalFieldNoiseWords_Dump]
			(			
		     ProjectID
			,OptionalFieldNoiseWord
			,Frequency
			,IsActive
			,CreatedDate
			,CreatedBy
			)
		SELECT 	
		     OFN.ProjectID
			,OFN.OptionalFieldNoiseWord
			,OFN.Frequency
			,OFN.IsActive
			,OFN.CreatedDate
			,OFN.CreatedBy
		FROM [AVL].[ML_OptionalFieldNoiseWords_Dump] OFN
		LEFT JOIN ML.OptionalFieldNoiseWords_Dump(NOLOCK)OFNM
		ON OFNM.ProjectID=OFN.ProjectID		
		WHERE OFNM.ProjectID IS NULL

		--TicketDescNoiseWord

		INSERT INTO [ML].[TicketDescNoiseWords]
			(			
		     ProjectID
			,TicketDescNoiseWord
			,Frequency
			,IsActive
			,CreatedDate
			,CreatedBy
			)
		SELECT 	
		     TFN.ProjectID
			,TFN.TicketDescNoiseWord
			,TFN.Frequency
			,TFN.IsActive
			,TFN.CreatedDate
			,TFN.CreatedBy
		FROM [AVL].[ML_TicketDescNoiseWords] TFN
		LEFT JOIN ML.TicketDescNoiseWords (NOLOCK) OFNM
		ON TFN.ProjectID=OFNM.ProjectID	
		WHERE OFNM.ProjectID IS NULL

		--

		--TicketDescNoiseWord

		INSERT INTO [ML].[TicketDescNoiseWords_Dump]
			(			
		     ProjectID
			,TicketDescNoiseWord
			,Frequency
			,IsActive
			,CreatedDate
			,CreatedBy
			)
		SELECT 	
		     TFN.ProjectID
			,TFN.TicketDescNoiseWord
			,TFN.Frequency
			,TFN.IsActive
			,TFN.CreatedDate
			,TFN.CreatedBy
		FROM [AVL].[ML_TicketDescNoiseWords_Dump]  TFN
		LEFT JOIN ML.TicketDescNoiseWords_Dump (NOLOCK) OFNM
		ON TFN.ProjectID=OFNM.ProjectID		
		WHERE OFNM.ProjectID IS NULL

		----TicketValidation

		INSERT INTO [ML].[TicketValidation]
		(			
		     ProjectID
			,TicketID
			,TicketDescription
			,ApplicationID
			,DebtClassificationID
			,AvoidableFlagID
			,ResidualDebtID
			,CauseCodeID
			,ResolutionCodeID
			,OptionalField
			,CreatedBy
			,CreatedDate
			,ModifiedBy
			,ModifiedDate
			,IsDeleted
			,TicketSourceFrom
		)
	 SELECT 
			
		     TV.ProjectID
			,TV.TicketID
			,TV.TicketDescription
			,TV.ApplicationID
			,TV.DebtClassificationID
			,TV.AvoidableFlagID
			,TV.ResidualDebtID
			,TV.CauseCodeID
			,TV.ResolutionCodeID
			,TV.OptionalFieldProj
			,TV.CreatedBy
			,TV.CreatedDate
			,TV.ModifiedBy
			,TV.ModifiedDate
			,TV.IsDeleted
			,TV.TicketSourceFrom
	FROM [AVL].[ML_TRN_TicketValidation](NOLOCK) TV
	LEFT JOIN ML.TicketValidation(NOLOCK)TVM
	ON TVM.ProjectID=TV.ProjectID	
	WHERE TVM.ProjectID IS NULL AND TV.TicketSourceFrom='ML'

	--MLSamplingJobStatus
	INSERT INTO [ML].[TRN_MLSamplingJobStatus]
		(			
		    ProjectID
			,InitialLearningID
			,JobIdFromML
			,FileName
			,DataPath
			,DARTJobStatus
			,InitiatedBy
			,JobMessage
			,JobType
			,CreatedOn
			,CreatedBy
			,ModifiedOn
			,ModifiedBy
			,IsDARTProcessed
			,MLSamplingStatus
			,RetryCount
			,IsDeleted

		)
		SELECT 	
		     TMS.ProjectID
			,TMS.InitialLearningID
			,TMS.JobIdFromML
			,TMS.FileName
			,TMS.DataPath
			,TMS.DARTJobStatus
			,TMS.InitiatedBy
			,TMS.JobMessage
			,TMS.JobType
			,TMS.CreatedOn
			,TMS.CreatedBy
			,TMS.ModifiedOn
			,TMS.ModifiedBy
			,TMS.IsDARTProcessed
			,TMS.MLSamplingStatus
			,TMS.RetryCount
			,TMS.IsDeleted
		FROM [AVL].[ML_TRN_MLSamplingJobStatus] TMS
		LEFT JOIN ML.TRN_MLSamplingJobStatus(NOLOCK)TMSM
		ON TMSM.ProjectID=TMS.ProjectID		
		WHERE TMSM.ProjectID IS NULL

		----TRN_PatternValidation MLOverriddenId collumn not in old

		INSERT INTO [ML].[TRN_PatternValidation]
		(			
		     InitialLearningID
			,ProjectID
			,ApplicationID
			,ApplicationTypeID
			,TechnologyID
			,TicketPattern
			,MLResidualFlagID
			,MLDebtClassificationID
			,MLAvoidableFlagID
			,MLCauseCodeID
			,MLAccuracy
			,TicketOccurence
			,AnalystResidualFlagID
			,AnalystResolutionCodeID
			,AnalystCauseCodeID
			,AnalystDebtClassificationID
			,AnalystAvoidableFlagID
			,SMEComments
			,SMEResidualFlagID
			,SMEDebtClassificationID
			,SMEAvoidableFlagID
			,SMECauseCodeID
			,IsApprovedOrMute
			,Classifiedby
			,SMEResolutionCodeID
			,ReasonForResidual
			,ExpectedCompDate
			,MLResolutionCode
			,subPattern
			,additionalPattern
			,additionalSubPattern
			,OverridenPatternCount
			,OverridenPatternTotalCount
			,IsMLSignOff
			,ContinuousLearningID
			,IsDeleted
			,CreatedBy
			,CreatedDate
			,ModifiedBy
			,ModifiedDate
		)
		SELECT 	
		     TPV.InitialLearningID
			,TPV.ProjectID
			,TPV.ApplicationID
			,TPV.ApplicationTypeID
			,TPV.TechnologyID
			,TPV.TicketPattern
			,TPV.MLResidualFlagID
			,TPV.MLDebtClassificationID
			,TPV.MLAvoidableFlagID
			,TPV.MLCauseCodeID
			,TPV.MLAccuracy
			,TPV.TicketOccurence
			,TPV.AnalystResidualFlagID
			,TPV.AnalystResolutionCodeID
			,TPV.AnalystCauseCodeID
			,TPV.AnalystDebtClassificationID
			,TPV.AnalystAvoidableFlagID
			,TPV.SMEComments
			,TPV.SMEResidualFlagID
			,TPV.SMEDebtClassificationID
			,TPV.SMEAvoidableFlagID
			,TPV.SMECauseCodeID
			,TPV.IsApprovedOrMute
			,TPV.Classifiedby
			,TPV.SMEResolutionCodeID
			,TPV.ReasonForResidual
			,TPV.ExpectedCompDate
			,TPV.MLResolutionCode
			,TPV.subPattern
			,TPV.additionalPattern
			,TPV.additionalSubPattern
			,TPV.OverridenPatternCount
			,TPV.OverridenPatternTotalCount
			,TPV.IsMLSignOff
			,TPV.ContinuousLearningID
			,TPV.IsDeleted
			,TPV.CreatedBy
			,TPV.CreatedDate
			,TPV.ModifiedBy
			,TPV.ModifiedDate
		FROM [AVL].[ML_TRN_MLPatternValidation] TPV
		LEFT JOIN ML.TRN_PatternValidation(NOLOCK)TPVM
		ON TPVM.ProjectID=TPV.ProjectID		
		WHERE TPVM.ProjectID IS NULL

		----
		INSERT INTO  [ML].[TRN_TicketsAfterSampling]
		(			
		     InitialLearningId
			,ProjectID
			,TicketID
			,TicketDescription
			,ApplicationID
			,ApplicationType
			,TechnologyID
			,DebtClassificationID
			,AvoidableFlagID
			,ResidualDebtID
			,CauseCodeID
			,ResolutionCodeID
			,CreatedBy
			,CreatedDate
			,ModifiedBy
			,ModifiedDate
			,IsDeleted
			,TicketPattern
			,AdditionalText
			,Desc_Base_WorkPattern
			,Desc_Sub_WorkPattern
			,Res_Base_WorkPattern
			,Res_Sub_WorkPattern
			,IsDebtFilled
			)
		SELECT 	
		     TPV.InitialLearningId
			,TPV.ProjectID
			,TPV.TicketID
			,TPV.TicketDescription
			,TPV.ApplicationID
			,TPV.ApplicationType
			,TPV.TechnologyID
			,TPV.DebtClassificationID
			,TPV.AvoidableFlagID
			,TPV.ResidualDebtID
			,TPV.CauseCodeID
			,TPV.ResolutionCodeID
			,TPV.CreatedBy
			,TPV.CreatedDate
			,TPV.ModifiedBy
			,TPV.ModifiedDate
			,TPV.IsDeleted
			,TPV.TicketPattern
			,TPV.AdditionalText
			,TPV.Desc_Base_WorkPattern
			,TPV.Desc_Sub_WorkPattern
			,TPV.Res_Base_WorkPattern
			,TPV.Res_Sub_WorkPattern
			,0
		FROM [AVL].[ML_TRN_TicketsAfterSampling] TPV
		LEFT JOIN ML.TRN_TicketsAfterSampling(NOLOCK)TPVM
		ON TPVM.ProjectID=TPV.ProjectID		
		WHERE TPVM.ProjectID IS NULL


COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            'ML.MLProjectMigration', 
            @ErrorMessage, 
            ''
      END CATCH 
  END
