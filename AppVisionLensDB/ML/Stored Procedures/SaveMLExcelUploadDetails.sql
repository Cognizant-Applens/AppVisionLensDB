/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : Shobana
-- Create date : 9 Dec 2019
-- Description : Procedure to save ML Pre requisite Details               
-- Test        : [ML].[SaveMLExcelUploadDetails]  
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [ML].[SaveMLExcelUploadDetails]
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
			TicketID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
			TimeTickerID BIGINT NOT NULL,
			IsTicketDescriptionUpdated BIT NULL,
			IsResolutionRemarksUpdated BIT NULL,
		)


		SET @InitialID= (SELECT TOP 1 ISNULL(ID, 0)
					FROM   [ML].[ConfigurationProgress](NOLOCK) 
					WHERE  ProjectID = @ID 
							AND IsDeleted = 0 
					ORDER  BY ID DESC)
		
		IF EXISTS(SELECT TOP 1 TicketID FROM @TVP_lstMLTicketDetails WHERE IsTicketDescriptionUpdated = 1 OR IsResolutionRemarksUpdated =1)
		BEGIN
			
			INSERT INTO #TranslateTickets
			SELECT ITD.TicketID, TD.TimeTickerID, ITD.IsTicketDescriptionUpdated, ITD.IsResolutionRemarksUpdated
			FROM @TVP_lstMLTicketDetails ITD JOIN AVL.TK_TRN_TicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.TicketID
			AND TD.ProjectID=@ID AND TD.IsDeleted=0 AND (ITD.IsTicketDescriptionUpdated = 1 OR ITD.IsResolutionRemarksUpdated =1);


			MERGE [AVL].[TK_TRN_Multilingual_TranslatedTicketDetails] AS TARGET
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
		FROM [ML].[TicketValidation] TV
		JOIN @TVP_lstMLTicketDetails MTD
		ON MTD.TicketID = TV.TicketID 
		WHERE TV.ProjectID = @ID 
		AND (TV.TicketDescription IS NULL OR TV.TicketDescription = '') 

		UPDATE TV 
		SET 
		TV.OptionalField = MTD.ResolutionRemarks,
		TV.ModifiedBy =  @UserID,
		TV.ModifiedDate = GETDATE()
		FROM [ML].[TicketValidation] TV
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
		FROM AVL.TK_TRN_TicketDetail TD
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
		FROM AVL.TK_TRN_TicketDetail TD
		JOIN @TVP_lstMLTicketDetails MTD
		ON MTD.TicketID = TD.TicketID 
		WHERE TD.ProjectID = @ID
		AND (TD.ResolutionRemarks IS NULL OR TD.ResolutionRemarks = '')
  
		SET @Result = 1
		SELECT @Result as Result
    
	COMMIT TRAN
  END TRY
	BEGIN CATCH
       
	    SET @Result = 0
	    SELECT @Result as Result
		DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            'ML.GetValidateTickets', 
            @ErrorMessage, 
            @ID, 
            0 
		              
    END CATCH

END
