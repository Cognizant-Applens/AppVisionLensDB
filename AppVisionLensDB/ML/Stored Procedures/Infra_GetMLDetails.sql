-- ============================================================================   
-- Author:           458788   
-- Create date:      15/07/2020  
-- Description:      SP for Infra -Initial Learning Details
-- Test:             EXEC [ML].[Infra_GetMLDetails] 40514,0  
-- ============================================================================  
CREATE PROCEDURE [ML].[Infra_GetMLDetails] --10569 ,0 
  @ProjectID BIGINT=NULL  ,
  @IsRegenerate BIT = NULL  

AS   
  BEGIN   
      BEGIN TRY  
	  SET NOCOUNT ON;
  DECLARE @ErrorMessage NVARCHAR(MAX);   
  DECLARE @TransactionID INT   
  DECLARE @LatestID INT=0   
  DECLARE @IsMLProcessingRequired NVARCHAR(MAX);   
  DECLARE @IsSamplingProcessingRequired NVARCHAR(MAX);   
  DECLARE @MLJobId NVARCHAR(MAX);   
  DECLARE @NoiseEliminationJobId NVARCHAR(MAX);   
  DECLARE @SamplingJobId NVARCHAR(MAX);   
  DECLARE @MLBaseCount BIGINT;  
  DECLARE @IsSamplingSentOrReceived NVARCHAR(10);   
  DECLARE @IsMLSentOrReceived NVARCHAR(10);   
  DECLARE @IsNoiseEliminationSentorReceived NVARCHAR(10);  
  DECLARE @ValidDebtFields DECIMAL(18, 2);        
  DECLARE @TotalTickets DECIMAL(18, 2);   
  DECLARE @ValidTDescription DECIMAL(18, 2);   
  DECLARE @ValidOptional DECIMAL(18, 2);   
  DECLARE @IsAutoClassified NVARCHAR(10);   
  DECLARE @OptionalFieldID SMALLINT;  
  DECLARE @IsTicketDescriptionOpted BIT;    
  DECLARE @TickDesc nvarchar(50);  
  DECLARE @FromDate Date;  
  DECLARE @ToDate Date;  
  DECLARE @IsTranslateRequired int;  
  DECLARE @IsSamplingSkipped bit;  
  DECLARE @RuleCreateDate Date;  
  DECLARE @MLSignOffDate Date;  
  DECLARE @ConfigurationProgressID INT;  
  DECLARE @DebtAttributeId bigint; 
  DECLARE @IsSendOrReceivedState nvarchar(10);
  DECLARE @IsDebtCompletePrepulate bit = 0;
    
  SET @ConfigurationProgressID = (CASE   
          WHEN @IsRegenerate = 0 THEN ( SELECT TOP 1 ID FROM   ML.InfraConfigurationProgress (NOLOCK) 
                  WHERE  projectid = @ProjectID   
                  AND IsDeleted = 0 ORDER  BY ID ASC )  
          ELSE ( SELECT ID FROM   ML.InfraConfigurationProgress(NOLOCK)   
                  WHERE  projectid = @ProjectID AND IsDeleted = 0   
                  AND ISNULL(IsMLSentOrReceived,'') <>'Received' )  
          END  
          )  
		  
  SET @IsSendOrReceivedState = (SELECT TOP 1 IsSamplingSentOrReceived 
		FROM ML.InfraConfigurationProgress(NOLOCK)
		WHERE ProjectID=@ProjectID
		AND IsMLSentOrReceived='Received'
		AND IsSamplingSentOrReceived='Received')
  
  SET @IsAutoClassified = (SELECT ISNULL(IsAutoClassifiedInfra, 'N') AS IsAutoClassified   
                                   FROM   [AVL].[MAS_PROJECTDEBTDETAILS](NOLOCK)
                                   WHERE  ProjectID = @ProjectID   
                                          AND IsDeleted = 0)  
  
           --Getting the latest initial learning id   
  SET @LatestID = (SELECT TOP 1 ID   
                           FROM   ML.InfraConfigurationProgress (NOLOCK)
                           WHERE  projectid = @ProjectID   
                                  AND IsDeleted = 0 AND ID = @ConfigurationProgressID  
                           ORDER  BY id DESC)  

  SET @FromDate = (SELECT TOP 1 FromDate  
                           FROM   ML.InfraConfigurationProgress(NOLOCK)
                           WHERE  projectid = @ProjectID   
                                  AND IsDeleted = 0   
          AND ID = @LatestID)   
  
  SET @ToDate = (SELECT TOP 1 ToDate   
                           FROM   ML.InfraConfigurationProgress(NOLOCK)  
                           WHERE  projectid = @ProjectID   
                                  AND IsDeleted = 0   
          AND ID = @LatestID)   
  
  SET @DebtAttributeId = (SELECT TOP 1 DebtAttributeId   
      FROM   ML.InfraConfigurationProgress  (NOLOCK)
                           WHERE  projectid = @ProjectID   
                                  AND IsDeleted = 0   
          AND ID = @LatestID)   
  
  SET @OptionalFieldID = (SELECT TOP 1 IsOptionalField   
FROM   ML.InfraConfigurationProgress (NOLOCK) 
          WHERE  projectid = @ProjectID   
           AND IsDeleted = 0   
          ORDER  BY id DESC)   
  
  SET @TotalTickets=(SELECT COUNT(DISTINCT TicketID)   
        FROM   ML.InfraTicketValidation(NOLOCK)   
        WHERE  ProjectID = @ProjectID AND IsDeleted=0
		AND InitialLearningID = @LatestID);  
  
  SET @ValidDebtFields=(SELECT COUNT(DISTINCT TicketID)   
                                FROM   ML.InfraTicketValidation(NOLOCK)   
                                WHERE  ProjectID = @ProjectID AND IsDeleted=0  
                                        AND DebtClassificationId IS NOT NULL AND DebtClassificationId <> 0  
                                        AND AvoidableFlagID IS NOT NULL AND AvoidableFlagID <> 0  
                                        AND CauseCodeID IS NOT NULL AND CauseCodeID <> 0  
                                        AND ResolutionCodeID IS NOT NULL AND ResolutionCodeID <> 0  
                                        AND ResidualDebtId IS NOT NULL AND ResidualDebtId <> 0
										AND InitialLearningID = @LatestID)  
  SET @ValidTDescription=(SELECT COUNT(DISTINCT TicketID)   
                                FROM   ML.InfraTicketValidation(NOLOCK)   
                                WHERE  ProjectID = @ProjectID 
								AND InitialLearningID = @LatestID
								AND IsDeleted=0  
   AND TicketDescription IS NOT NULL   
                                        AND TicketDescription <> '');   
        SET @ValidOptional=(SELECT COUNT(DISTINCT TicketID)   
        FROM   ML.InfraTicketValidation(NOLOCK)   
        WHERE  ProjectID = @ProjectID  
		AND InitialLearningID = @LatestID
          AND OptionalField IS NOT NULL   
          AND OptionalField <> ''   
          AND IsDeleted = 0);   
  --To get the mljobid/samplingjobid/noiseeliminationjobid for that project(present transaction)         
  SET @TransactionID=(SELECT TOP 1 ID   
       FROM   ML.InfraTRN_MLJobStatus(NOLOCK) 
       WHERE  ProjectID = @ProjectID   
       ORDER  BY ID DESC)   
    
  SET @MLBaseCount=(SELECT COUNT(DISTINCT TicketID) from ML.InfraBaseDetails(NOLOCK) where ProjectID=@ProjectID and Isdeleted=0)  
  SET @IsMLProcessingRequired=(SELECT 'Y'   
          FROM   ML.InfraTRN_MLJobStatus(NOLOCK) 
          WHERE  ProjectID = @ProjectID   
           /*AND ( IsDARTProcessed = 'N'   
             OR IsDARTProcessed IS NULL )   */   
           AND JobType = 'ML'   
           AND id = @TransactionID   
           AND InitialLearningID = @LatestID)   
  SET @IsSamplingProcessingRequired=(SELECT 'Y'   
           FROM   ML.InfraTRN_MLJobStatus(NOLOCK) 
           WHERE  ProjectID = @ProjectID   
             /*AND ( IsDARTProcessed = 'N'   
             OR IsDARTProcessed IS NULL )   */
             AND JobType = 'Sampling'   
             AND id = @TransactionID   
             AND InitialLearningID = @LatestID)  
               
  SET @MLJobId=(SELECT JobIdFromML   
      FROM   ML.InfraTRN_MLJobStatus(NOLOCK)
      WHERE  ProjectID = @ProjectID   
        AND @MLBaseCount=0
		/*(( IsDARTProcessed = 'N'   
         OR IsDARTProcessed IS NULL ) OR @MLBaseCount=0 )  */
        AND JobType = 'ML'   
        AND id = @TransactionID   
        AND InitialLearningID = @LatestID)   
  SET @NoiseEliminationJobId=(SELECT JobIdFromML   
         FROM   ML.InfraTRN_MLJobStatus(NOLOCK)
         WHERE  ProjectID = @ProjectID   
           /*AND ( IsDARTProcessed = 'N'   
             OR IsDARTProcessed IS NULL )   */
           AND JobType = 'NoiseEl'   
           AND id = @TransactionID   
           AND InitialLearningID = @LatestID)   
  SET @SamplingJobId=(SELECT JobIdFromML   
   FROM   ML.InfraTRN_MLJobStatus(NOLOCK)   
       WHERE  ProjectID = @ProjectID   
         /*AND ( IsDARTProcessed = 'N'   
             OR IsDARTProcessed IS NULL )   */ 
         AND JobType = 'Sampling'   
         AND id = @TransactionID   
         AND InitialLearningID = @LatestID)   
  
       SET @IsMLSentOrReceived= (SELECT TOP 1 IsMLSentOrReceived  
       FROM   [ML].InfraConfigurationProgress(NOLOCK)   
                               WHERE  ProjectID = @ProjectID   
                                      AND ID = @LatestID   
                                      AND ( IsDeleted = 0   
                                             OR IsDeleted IS NULL) )   
        SET @IsSamplingSentOrReceived=(CASE WHEN ISNULL(@IsSendOrReceivedState,'') = 'Received' 
	                                   AND @IsRegenerate = 0 THEN @IsSendOrReceivedState
	                                   ELSE (SELECT TOP 1 IsSamplingSentOrReceived  
                                       FROM   [ML].InfraConfigurationProgress(NOLOCK)  
                                       WHERE  ProjectID = @ProjectID                                       
                                       AND ID = @LatestID   
                                        AND ( IsDeleted = 0   
                                            OR IsDeleted IS NULL )   
                                        ORDER  BY ID DESC) END)  
        SET @IsNoiseEliminationSentorReceived=(SELECT TOP 1 IsNoiseEliminationSentorReceived  
                                        FROM   [ML].InfraConfigurationProgress (NOLOCK) 
WHERE  ProjectID = @ProjectID                                               
                                            AND ID = @LatestID   
                                            AND ( IsDeleted = 0   
                                                    OR IsDeleted IS NULL )   
                                        ORDER  BY ID DESC)   
  
  SET @IsSamplingSkipped=(SELECT TOP 1 IsSamplingSkipped  
                                        FROM   [ML].InfraConfigurationProgress(NOLOCK) 
                                        WHERE  ProjectID = @ProjectID                                               
                                            AND ID = @LatestID   
                                            AND ( IsDeleted = 0   
                                                    OR IsDeleted IS NULL )   
                                        ORDER  BY ID DESC)                         
    
  
        SET @IsTicketDescriptionOpted=(select TOP 1 IsTicketDescriptionOpted from ML.InfraConfigurationProgress(NOLOCK) where ProjectID=@ProjectID AND IsDeleted = 0)  
  
  IF(@IsTicketDescriptionOpted IS NOT NULL)  
  BEGIN  
   SET @IsTicketDescriptionOpted  = @IsTicketDescriptionOpted  
  END  
  ELSE  
  BEGIN  
   SET @TickDesc=(SELECT ServiceDartColumn FROM [AVL].[ITSM_PRJ_SSISColumnMapping](NOLOCK) WHERE ServiceDartColumn LIKE '%Ticket Description%' AND   
   ProjectID=@ProjectID AND IsDeleted=0)  
  
   SET @IsTicketDescriptionOpted=CASE WHEN @TickDesc IS NOT NULL THEN 1  
                 ELSE 0  
        END  
  
   SET @IsTicketDescriptionOpted = @IsTicketDescriptionOpted --AS 'IsTicketDescEnabled'  
  END  
  
  IF(@TotalTickets = 0)  
  BEGIN  
   SET @TotalTickets = -1;  
  END    
    
  SET @MLSignOffDate = (SELECT MAX(MLSignOffDateInfra)FROM AVL.MAS_ProjectDebtDetails(NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 0)  
  SET @RuleCreateDate = (SELECT MIN(CreatedDate) FROM ML.InfraTRN_PatternValidation(NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 0)  

  IF(ISNULL(@IsSamplingSentOrReceived,'N') = 'Sent' AND ISNULL(@IsMLSentOrReceived,'N') = 'N'
		AND EXISTS(SELECT TOP 1 ID FROM [ML].InfraTRN_TicketsAfterSampling(NOLOCK) WHERE ProjectID = @ProjectID AND InitialLearningId = @LatestID   
                                            AND DebtClassifiedBy = 4 AND (IsDeleted = 0 OR IsDeleted IS NULL))
		AND NOT EXISTS(SELECT TOP 1 ID FROM [ML].InfraTRN_TicketsAfterSampling(NOLOCK) WHERE ProjectID = @ProjectID AND InitialLearningId = @LatestID   
                                            AND DebtClassifiedBy = 2 AND (IsDeleted = 0 OR IsDeleted IS NULL)))
	BEGIN		
		UPDATE td 
		SET td.DebtClassificationMapID = sd.DebtClassificationID,
		td.AvoidableFlag = sd.AvoidableFlagID,
		td.ResidualDebtMapID = sd.ResidualDebtID,
		td.CauseCodeMapID = sd.CauseCodeID,
		td.ResolutionCodeMapID = sd.ResolutionCodeID
		FROM
		AVL.TK_TRN_InfraTicketDetail td
		join ML.InfraTRN_TicketsAfterSampling sd on td.TicketID = sd.ticketid
		and td.ProjectID = sd.projectid
		WHERE td.ProjectID = @ProjectID and sd.DebtClassifiedBy = 4
		and td.IsDeleted = 0 and sd.IsDeleted = 0 

		SET @IsDebtCompletePrepulate = 1;
	END
  
  SELECT ISNULL(@IsAutoClassified,'N')    AS IsAutoClassified,     
   ISNULL(@LatestID,0)        AS InitialLearningId,  
   @FromDate          AS FromDate,  
   @ToDate           AS ToDate,  
   ISNULL(@OptionalFieldID,0)      AS OptionalField,  
   CASE WHEN ( ( @ValidTDescription / @TotalTickets) * 100 ) >= 80 THEN 'Y' ELSE 'N' END AS TicketDescriptionMet,  
   CASE WHEN ( ( @ValidOptional / @TotalTickets) * 100 ) >= 80 THEN 'Y' ELSE 'N' END AS OptionalFieldMet,  
   CASE WHEN ( ( @ValidDebtFields / @TotalTickets) * 100 ) >= 80 THEN 'Y' ELSE 'N' END AS DebtMet,  
   ISNULL(@IsNoiseEliminationSentorReceived,'N') AS NoiseEliminationSentReceived,   
   @NoiseEliminationJobId        AS NoiseEliminationJobId,  
   ISNULL(@IsSamplingSentOrReceived,'N')      AS SamplingSentReceived,     
   @SamplingJobId         AS SamplingJobId,   
   ISNULL(@IsSamplingProcessingRequired,'N')  AS IsSamplingProcessingRequired,   
   ISNULL(@IsMLSentOrReceived,'N')     AS MLSentReceived,   
   @MLJobId          AS MLJobId,   
   ISNULL(@IsMLProcessingRequired,'N')    AS IsMLProcessingRequired,  
   ISNULL(@IsTicketDescriptionOpted,1)             AS IsTicketDescriptionOpted,  
   ISNULL(@IsSamplingSkipped,0)     AS IsSamplingSkipped,  
   @RuleCreateDate         AS MlDate,  
   @MLSignOffDate         AS MLSignOffDate,  
   CASE WHEN @TotalTickets >= 1000   
    THEN 'Y'  
    ELSE 'N' END        AS TicketCountMet,  
    @DebtAttributeId       AS DebtAttributeId,
	@IsDebtCompletePrepulate AS IsDebtCompletePrepulate

	SET NOCOUNT OFF;
   END TRY   
  
   BEGIN CATCH   
          DECLARE @ErrorMessage1 VARCHAR(MAX);   
  
          SELECT @ErrorMessage1 = ERROR_MESSAGE()   
  
          --INSERT Error       
          EXEC AVL_INSERTERROR   
            '[ML].[Infra_GetMLDetails]',   
            @ErrorMessage1,   
            @ProjectID,   
            0   
      END CATCH   
  END
