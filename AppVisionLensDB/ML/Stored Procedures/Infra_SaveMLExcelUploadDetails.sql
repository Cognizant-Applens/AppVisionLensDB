-- =========================================================================================
-- Author      : 587567
-- Create date : 07/16/2020
-- Description : Procedure to save ML Pre requisite Details               
-- Test        : [ML].[Infra_SaveMLExcelUploadDetails]  
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [ML].[Infra_SaveMLExcelUploadDetails]
(
	@ID BIGINT, --ProjectID
	@UserID  VARCHAR(50),
    @TVP_lstMLTicketDetails  [ML].[TicketDetails] READONLY
)
AS
BEGIN
  BEGIN TRY
	BEGIN TRAN
     SET NOCOUNT ON;

		DECLARE @Result BIT;
		DECLARE @InitialID BIGINT;
		CREATE TABLE #TranslateTickets
		(
			TicketID nvarchar(50) NOT NULL,
			TimeTickerID BIGINT NOT NULL,
			IsTicketDescriptionUpdated BIT NULL,
			IsResolutionRemarksUpdated BIT NULL,
		)


		SET @InitialID= (SELECT TOP 1 ISNULL(ID, 0)
					FROM   [ML].[infraConfigurationProgress](NOLOCK) 
					WHERE  ProjectID = @ID 
							AND IsDeleted = 0 
					ORDER  BY ID DESC)
		
		IF EXISTS(SELECT TOP 1 TicketID FROM @TVP_lstMLTicketDetails WHERE IsTicketDescriptionUpdated = 1 OR IsResolutionRemarksUpdated =1)
		BEGIN
			
			INSERT INTO #TranslateTickets
			SELECT ITD.TicketID, TD.TimeTickerID, ITD.IsTicketDescriptionUpdated, ITD.IsResolutionRemarksUpdated
			FROM @TVP_lstMLTicketDetails ITD JOIN AVL.TK_TRN_InfraTicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.TicketID
			AND TD.ProjectID=@ID AND TD.IsDeleted=0 AND (ITD.IsTicketDescriptionUpdated = 1 OR ITD.IsResolutionRemarksUpdated =1);


			MERGE [AVL].[TK_TRN_Multilingual_TranslatedInfraTicketDetails] AS TARGET
			USING #TranslateTickets AS SOURCE
			ON (Target.TimeTickerID=SOURCE.TimeTickerID)
			WHEN MATCHED  
			THEN 
			UPDATE SET TARGET.IsTicketDescriptionUpdated=(CASE WHEN SOURCE.IsTicketDescriptionUpdated = 1 THEN 1 ELSE TARGET.IsTicketDescriptionUpdated END),			
			TARGET.IsResolutionRemarksUpdated=(CASE WHEN SOURCE.IsResolutionRemarksUpdated = 1 THEN 1 ELSE TARGET.IsResolutionRemarksUpdated END),			
			TARGET.ModifiedBy=@UserID,
			TARGET.ModifiedDate=GETDATE(),
			TARGET.TicketCreatedType = 4,
			TARGET.ReferenceID = @InitialID
			WHEN NOT MATCHED BY TARGET 
			THEN 
			INSERT (TimeTickerID,IsTicketDescriptionUpdated,IsResolutionRemarksUpdated,IsTicketSummaryUpdated,
			IsCommentsUpdated,Isdeleted,CreatedBy,CreatedDate,TicketCreatedType,ReferenceID ) 
			VALUES (SOURCE.TimeTickerID,SOURCE.IsTicketDescriptionUpdated,SOURCE.IsResolutionRemarksUpdated,
			null,null,0,@UserID,GETDATE(),4,@InitialID);
		END
	 
		UPDATE TV 
		SET 
		TV.TicketDescription = MTD.TicketDescription,
		TV.ModifiedBy = @UserID,
		TV.ModifiedDate = GETDATE()
		FROM [ML].[InfraTicketValidation] TV
		JOIN @TVP_lstMLTicketDetails MTD
		ON MTD.TicketID = TV.TicketID 
		WHERE TV.ProjectID = @ID 
		AND (TV.TicketDescription IS NULL OR TV.TicketDescription = '') 

		UPDATE TV 
		SET 
		TV.OptionalField = MTD.ResolutionRemarks,
		TV.ModifiedBy =  @UserID,
		TV.ModifiedDate = GETDATE()
		FROM [ML].[InfraTicketValidation] TV
		JOIN @TVP_lstMLTicketDetails MTD
		ON MTD.TicketID = TV.TicketID 
		WHERE TV.ProjectID =  @ID 
		AND (TV.OptionalField IS NULL OR TV.OptionalField = '')

		UPDATE TD 
		SET 
		TD.TicketDescription = ISNULL(MTD.TicketDescription,td.TicketDescription),
		TD.ModifiedBy = @UserID,
		TD.ModifiedDate = GETDATE(),
		TD.LastUpdatedDate = GETDATE()
		FROM AVL.TK_TRN_InfraTicketDetail TD
		JOIN @TVP_lstMLTicketDetails MTD
		ON MTD.TicketID = TD.TicketID 
		WHERE TD.ProjectID = @ID
		AND (TD.TicketDescription IS NULL OR TD.TicketDescription = '' ) 

		UPDATE TD 
		SET 
		TD.ResolutionRemarks = MTD.ResolutionRemarks,
		TD.ModifiedBy = @UserID,
		TD.ModifiedDate = GETDATE(),
		TD.LastUpdatedDate = GETDATE()
		FROM AVL.TK_TRN_InfraTicketDetail TD
		JOIN @TVP_lstMLTicketDetails MTD
		ON MTD.TicketID = TD.TicketID 
		WHERE TD.ProjectID = @ID
		AND (TD.ResolutionRemarks IS NULL OR TD.ResolutionRemarks = '')
  
		SET @Result = 1
		SELECT @Result as Result

    SET NOCOUNT OFF
	COMMIT TRAN
  END TRY
	BEGIN CATCH
       
	    SET @Result = 0
	    SELECT @Result as Result
		DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[ML].[Infra_SaveMLExcelUploadDetails]', 
            @ErrorMessage, 
            @ID, 
            0 
		              
    END CATCH

END
