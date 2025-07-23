CREATE PROCEDURE [ML].[Infra_GetITSMTicketDescDetails] --10337,0
(
@ID BIGINT,
@IsRegenerate BIT
)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		DECLARE @IsTicketDescEnabled BIT
		DECLARE @TickDesc nvarchar(50)
		DECLARE @LearningID BIT
				
		SET @LearningID = (CASE		WHEN @IsRegenerate = 0 THEN ( SELECT TOP 1 ID FROM   ML.InfraConfigurationProgress(NOLOCK)
																		WHERE  projectid = @ID 
																		AND IsDeleted = 0 ORDER  BY ID ASC )
										ELSE ( SELECT ID FROM   ML.InfraConfigurationProgress (NOLOCK)
																		WHERE  projectid = @ID AND IsDeleted = 0 
																		AND ISNULL(IsMLSentOrReceived,'')<> 'Received' )
										END	)

        SET @IsTicketDescEnabled=(SELECT TOP 1 IsTicketDescriptionOpted FROM ML.InfraConfigurationProgress(NOLOCK) 
								WHERE ProjectID=@ID AND IsDeleted = 0 AND ID=@LearningID
								ORDER BY ID ASC)

		IF(@IsTicketDescEnabled IS NOT NULL)
		BEGIN
			SET @IsTicketDescEnabled  = @IsTicketDescEnabled
		END
		ELSE
		BEGIN
			SET @TickDesc=(SELECT ServiceDartColumn FROM [AVL].[ITSM_PRJ_SSISColumnMapping](NOLOCK) WHERE ServiceDartColumn LIKE '%Ticket Description%' AND 
			ProjectID=@ID AND IsDeleted=0)			

			SET @IsTicketDescEnabled=CASE WHEN @TickDesc IS NOT NULL THEN 1
		               ELSE 0
					   END

			SET @IsTicketDescEnabled = @IsTicketDescEnabled --AS 'IsTicketDescEnabled'
		END
		
			

			SELECT @IsTicketDescEnabled AS IsTicketDescEnabled
		
	SET NOCOUNT OFF

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError 'ML.Infra_GetITSMTicketDescDetails', @ErrorMessage, @ID,0

	END CATCH
END
