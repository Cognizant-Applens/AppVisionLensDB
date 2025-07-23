CREATE PROCEDURE [ML].[SaveTicketWorkPatternUploadDetails]
(
	@ProjectID BIGINT, --ProjectID
	@UserID  NVARCHAR(50),
	@IsRegenerate BIT=0,
    @TVP_lstTicketWorkPatternDetails  [ML].[TicketWorkPatternDetails]  READONLY
)
AS
BEGIN
  BEGIN TRY
	BEGIN TRAN
     SET NOCOUNT ON;

	 DECLARE @Result BIT;
	 DECLARE @MLConfigID BIGINT;
	 DECLARE @RowCount BIGINT;
	 DECLARE @ValidDebtFields DECIMAL(18, 2);      
	 DECLARE @TotalTickets DECIMAL(18, 2);
	 DECLARE @DebtMet NVARCHAR(2);


	 SET @MLConfigID = (CASE 
				  WHEN @IsRegenerate = 0 THEN ( SELECT TOP 1 ID FROM   ML.ConfigurationProgress(NOLOCK)
												 WHERE  projectid = @ProjectID 
												 AND IsDeleted = 0 ORDER  BY ID asc )
					ELSE ( SELECT max(ID) FROM   ML.ConfigurationProgress(NOLOCK)
						   WHERE  projectid = @ProjectID AND IsDeleted = 0 and ISNULL(IsMLSentOrReceived,'') <>'Received'
						 )
	               END
				  ) 


	 --SET @MLConfigID=(SELECT ID FROM ML.ConfigurationProgress WHERE ProjectID=@ProjectID
		--			  AND IsDeleted=0)
	
	 
	UPDATE TD
	SET TD.TicketDescriptionBasePattern=LWP.TicketDescriptionBasePattern,
	TD.TicketDescriptionSubPattern=LWP.TicketDescriptionSubPattern,
	TD.ResolutionRemarksBasePattern=LWP.ResolutionRemarksBasePattern,
	TD.ResolutionRemarksSubPattern=LWP.ResolutionRemarksSubPattern,
	TD.LastUpdatedDate=GETDATE(),
	TD.ModifiedDate=GETDATE()
	FROM @TVP_lstTicketWorkPatternDetails LWP 
	INNER JOIN [AVL].[TK_TRN_TicketDetail] TD ON LWP.TicketID=TD.TicketID
	WHERE TD.ProjectID=@ProjectID AND IsDeleted = 0


	SELECT @RowCount = @@ROWCOUNT
	IF(@RowCount > 0)
	BEGIN
		INSERT INTO ML.TicketValidation(
					 ProjectID, 
                     TicketID,  
                     ApplicationID, 
                     DebtClassificationID, 
                     AvoidableFlagID, 
                     ResidualDebtID, 
                     CauseCodeID, 
                     ResolutionCodeID, 
                     CreatedBy, 
                     CreatedDate,
					 ModifiedBy,
					 ModifiedDate,
                     IsDeleted, 
                     OptionalField,
					 TicketSourceFrom,
					 TicketDescriptionBasePattern,
					 TicketDescriptionSubPattern,
					 ResolutionRemarksBasePattern,
					 ResolutionRemarksSubPattern,
					 InitialLearningID
					 ) 
		SELECT @ProjectID,LWP.TicketID,TD.ApplicationID,TD.DebtClassificationMapID,TD.AvoidableFlag,TD.ResidualDebtMapID,
		TD.CauseCodeMapID,TD.ResolutionCodeMapID,@UserID,GETDATE(),NULL,NULL,0,NULL,'ML',
		LWP.TicketDescriptionBasePattern,ISNULL(LWP.TicketDescriptionSubPattern,'0'),ISNULL(LWP.ResolutionRemarksBasePattern,'0'),
		ISNULL(LWP.ResolutionRemarksSubPattern,'0'),
		@MLConfigID
		FROM @TVP_lstTicketWorkPatternDetails LWP 
		INNER JOIN [AVL].[TK_TRN_TicketDetail](NOLOCK) TD ON LWP.TicketID=TD.TicketID
		WHERE TD.ProjectID=@ProjectID AND
		ISNULL(LWP.TicketDescriptionBasePattern,'0') <> '0'
	
		SET @TotalTickets=(SELECT COUNT(DISTINCT TicketID) 
								FROM   ML.TicketValidation(NOLOCK) 
								WHERE  ProjectID = @ProjectID AND IsDeleted=0 AND InitialLearningID=@MLConfigID);
		SET @ValidDebtFields=(SELECT COUNT(DISTINCT TicketID) 
                                FROM   ML.TicketValidation(NOLOCK) 
                                WHERE  ProjectID = @ProjectID AND IsDeleted=0
                                        AND DebtClassificationId IS NOT NULL AND DebtClassificationId <> 0
                                        AND AvoidableFlagID IS NOT NULL AND AvoidableFlagID <> 0
                                        AND CauseCodeID IS NOT NULL AND CauseCodeID <> 0
                                        AND ResolutionCodeID IS NOT NULL AND ResolutionCodeID <> 0
                                        AND ResidualDebtId IS NOT NULL AND ResidualDebtId <> 0
										AND InitialLearningID=@MLConfigID)
		
		SET @DebtMet = CASE WHEN ( ( @ValidDebtFields / @TotalTickets) * 100 ) >= 80 THEN 'Y' ELSE 'N' END

		UPDATE ML.ConfigurationProgress SET IsWorkPatternUploadCompleted = '1'
		, IsNoiseEliminationSentorReceived = 'Received',
		IsSamplingSentOrReceived = CASE WHEN @DebtMet = 'Y' THEN 'Received' ELSE IsSamplingSentOrReceived END,
		IsSamplingSkipped = CASE WHEN @DebtMet = 'Y' THEN 1 ELSE IsSamplingSkipped END
		WHERE ProjectID = @ProjectID AND IsDeleted = 0 AND ID= @MLConfigID		
		SET @Result = 1
		 SELECT @Result as Result
	END
	ELSE
	BEGIN
		SET @Result = 0
	    SELECT @Result as Result
	END
	COMMIT TRAN
  END TRY
	BEGIN CATCH
       
	    SET @Result = 0
	    SELECT @Result as Result
		DECLARE @ErrorMessage VARCHAR(MAX);
		
		ROLLBACK TRAN
		-- Log the error message
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[ML].[SaveTicketWorkPatternUploadDetails]', @ErrorMessage, @UserID,0          
    END CATCH
	SET NOCOUNT OFF

END
