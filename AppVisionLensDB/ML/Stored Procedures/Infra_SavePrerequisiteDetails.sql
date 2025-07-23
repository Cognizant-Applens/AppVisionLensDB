/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ML].[Infra_SavePrerequisiteDetails] 
(
	@ID BIGINT, --ProjectID
	@IsOptionalField BIT,
	@DebtAttribute INT,
	@FromDate DATETIME,
	@ToDate DATETIME,
	@UserID NVARCHAR(10),
	@IsTicketDescMapped BIT,
	@IsRegenerate BIT
)
AS
BEGIN
  BEGIN TRY
     BEGIN TRAN
     SET NOCOUNT ON;
	 DECLARE @Result BIT;
	 DECLARE @Count BIGINT;
	 DECLARE @LearingID BIGINT;
	 DECLARE @LearnIDML BIGINT;
	 DECLARE @RegenerateFromDate DATETIME;

	 SELECT @Count=COUNT(ID) FROM ML.InfraConfigurationProgress(NOLOCK) WHERE ProjectID=@ID AND IsDeleted= 0
	 
	 
	

	 SET @LearingID =(case when @IsRegenerate=0 then (SELECT TOP 1 ID FROM   ML.InfraConfigurationProgress
																		WHERE  projectid = @ID 
																		AND IsDeleted = 0																		
																		ORDER  BY ID DESC )	
					  else (SELECT TOP 1 ID FROM   ML.InfraConfigurationProgress
																		WHERE  projectid = @ID 
																		AND IsDeleted = 0 AND ISNULL(IsMLSentOrReceived,'') <> 'Received'																		
																		ORDER  BY ID ASC) END)
						

     SET @LearnIDML = ( CASE WHEN  @Count>2 THEN
							(SELECT TOP 1 ID FROM   ML.InfraConfigurationProgress
																		WHERE  projectid = @ID 
																		AND IsDeleted = 0 
																		AND ISNULL(IsMLSentOrReceived,'') ='Received' 
																		ORDER  BY ID DESC) END)

	 SET @RegenerateFromDate = (CASE WHEN @Count>2 THEN (Select CONVERT(DATE,MIN(CreatedDate)) FROM ML.InfraTRN_PatternValidation(NOLOCK)
							  WHERE ProjectID=@ID and InitialLearningID=@LearnIDML)
							  ELSE CONVERT(DATE,@FromDate) END)


	 MERGE ML.InfraConfigurationProgress  as ILC
	 USING (VALUES (@ID,@IsOptionalField,@DebtAttribute,convert(date, @RegenerateFromDate),convert(date,@ToDate),@UserID,@IsTicketDescMapped))
	 as ILCC(ProjectId,IsOptionalField,DebtAttributeId,FromDate,ToDate,UserID,IsTicketDescMapped)
	 ON ILCC.ProjectId = ILC.ProjectId AND ILC.ID = isnull(@LearingID,'')
		WHEN MATCHED    THEN 
	    UPDATE
		SET ILC.IsOptionalField =  ILCC.IsOptionalField,
		ILC.DebtAttributeId = ILCC.DebtAttributeId,
		ILC.FromDate = ILCC.FromDate,
	    ILC.ToDate = ILCC.ToDate,
		ILC.ModifiedBy =ILCC.UserID,
		ILC.ModifiedDate = GetDate(),
		ILC.IsTicketDescriptionOpted=ILCC.IsTicketDescMapped
				
		WHEN NOT MATCHED BY TARGET THEN
			  
		INSERT 
		(ProjectID,FromDate,ToDate,IsOptionalField,DebtAttributeId,IsNoiseEliminationSentorReceived
		,IsNoiseSkipped,IsSamplingSentOrReceived,IsSamplingInProgress,IsMLSentOrReceived
		,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,IsTicketDescriptionOpted)
		VALUES(ILCC.ProjectId,@RegenerateFromDate,CONVERT(DATE,@ToDate),ILCC.IsOptionalField,ILCC.DebtAttributeId,NULL,NULL,NULL,NULL,NULL,0,'SYSTEM',GETDATE(),NULL,NULL,ILCC.IsTicketDescMapped);
  
        SET @Result = 1
		SELECT @Result AS Result

   COMMIT TRAN
  END TRY
	BEGIN CATCH

	    SET @Result =0
		SELECT @Result AS Result
		DECLARE @ErrorMessage VARCHAR(MAX);
		ROLLBACK TRAN
		-- Log the error message
		SELECT @ErrorMessage = ERROR_MESSAGE()
		              
   END CATCH

END
