-- =========================================================================================
-- Author      : Shobana
-- Create date : 3 Dec 2019
-- Description : Procedure to Get ML Pre requisite Details               
-- Test        : [ML].[GetPrerequisiteDetails] 10569,1
-- Revision    : 11 March 2020
-- Revised By  : 683989
-- =========================================================================================
CREATE PROCEDURE [ML].[GetPrerequisiteDetails] --9829,1
(
	@ID BIGINT, --ProjectID
	@IsRegenerate BIT
)
AS
BEGIN
  BEGIN TRY
     SET NOCOUNT ON; 
	 DECLARE @IsDelete INT = 0 ;
	 DECLARE @IsMLSignOffDate DATETIME;
	 DECLARE @MaxDate DATETIME;
	 DECLARE @MinDate DATETIME;
	 DECLARE @Count AS  INT;
	 DECLARE @LearningID AS INT;
	 DECLARE @MLID AS INT;
	 DECLARE @IsMLSignOff AS BIT = 0 ;
	 DECLARE @LearnIDML BIGINT;
	 DECLARE @RegenerateFromDate DATETIME;

			
	 		
	SET @LearningID = (CASE WHEN @IsRegenerate = 0 THEN ( SELECT TOP 1 ID FROM   ML.ConfigurationProgress (NOLOCK)
																		WHERE  projectid = @ID
																		AND IsDeleted = 0 ORDER  BY ID DESC )
										ELSE ( SELECT ID FROM   ML.ConfigurationProgress (NOLOCK)
																		WHERE  projectid = @ID AND IsDeleted = 0 
																		AND ISNULL(IsMLSentOrReceived,'')<> 'Received' )
										END
										)
				

	 SELECT  @IsMLSignOff = CASE WHEN ISNULL(MLSignOffDate,'') <> '' THEN 1 ELSE 0 END 
	 FROM [AVL].[MAS_ProjectDebtDetails](NOLOCK)
	 WHERE ProjectID=@ID AND IsDeleted = @IsDelete
	 AND  GETDATE() >= MLSignOffDate

	 SELECT  @Count=count(ID),
	 @MaxDate=max(ToDate),@MinDate=min(FromDate) FROM ML.ConfigurationProgress(NOLOCK) 
	 WHERE ProjectID=@ID AND IsDeleted=@IsDelete 
	 	 	 
     SET @LearnIDML = ( CASE WHEN  @Count>= 2 THEN
					  (SELECT TOP 1 ID FROM   ML.ConfigurationProgress(NOLOCK)
									   WHERE  projectid = @ID 
									   AND IsDeleted = 0 
									   AND IsMLSentOrReceived='Received' 
					   ORDER  BY ID DESC) END)

	 SET @RegenerateFromDate = (CASE WHEN @Count>=2 THEN (Select CONVERT(DATE,MIN(CreatedDate)) 
								FROM ML.TRN_PatternValidation(NOLOCK)
								WHERE ProjectID=@ID and InitialLearningID=@LearnIDML) END)

	 

	 	
	    IF (@IsRegenerate=0)
		BEGIN
			SELECT DISTINCT @LearningID AS ID,IsOptionalField,DebtAttributeId AS DebtAttribute,@MinDate AS FromDate,
			@MaxDate AS ToDate,IsTicketDescriptionOpted,@IsMLSignOff AS IsMLSignOff, ISNULL(IsSamplingSkipped,0) AS IsSamplingSkipped
			FROM ML.ConfigurationProgress(NOLOCK)
			WHERE ProjectId = @ID AND Isdeleted = @IsDelete
		
			
		END
		ELSE
		BEGIN

			SELECT DISTINCT @LearningID as ID,IsOptionalField,
				   DebtAttributeId AS DebtAttribute,
				   CASE WHEN @count >= 2 THEN CONVERT(DATE,@RegenerateFromDate) 								 
				   ELSE CONVERT(DATE,PD.MLSignOffDate) END AS FromDate,
				   CONVERT(DATE,GETDATE()) AS ToDate,
				   IsTicketDescriptionOpted,
				   @IsMLSignOff AS IsMLSignOff,
				   ISNULL(IsSamplingSkipped,0) AS IsSamplingSkipped
			FROM ML.ConfigurationProgress(NOLOCK) MC
			JOIN [AVL].[MAS_ProjectDebtDetails](NOLOCK) PD
				ON PD.ProjectID=MC.ProjectID AND PD.IsDeleted = @IsDelete
				WHERE MC.ProjectId = @ID 
				AND MC.Isdeleted = @IsDelete         	

		END
	SET NOCOUNT OFF
   END TRY
	BEGIN CATCH
       
		DECLARE @ErrorMessage VARCHAR(MAX);
		
		-- Log the error message
		SELECT @ErrorMessage = ERROR_MESSAGE()
		              
   END CATCH

END
