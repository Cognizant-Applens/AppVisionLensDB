/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[Effort_SaveEffortEntrySetup] 
(
	@ProjectID				NVARCHAR(MAX),
	@CustomerID				NVARCHAR(MAX),
	@IsEffortConfigured		NVARCHAR(MAX),
	@IsEffortTrackActivityWise NVARCHAR(5),
	@IsDaily				NVARCHAR(MAX) = NULL,
	@TimezoneId				NVARCHAR(MAX),
	@SDTicketFormat			NVARCHAR(MAX),
	@Defaultermail			NVARCHAR(MAX) = NULL,
	@TotalValue				INT,
	@UserID					NVARCHAR(50),
	@IsmanualOrAuto			NVARCHAR(10),
	@SharePath				NVARCHAR(MAX),
	@ALMTimeZoneId			NVARCHAR(MAX),
	@TicketSharePathUsers	NVARCHAR(MAX)
)
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @WorkProfilerConfigTileID SMALLINT = 11
 DECLARE @IsCognizant INT
 SELECT @IsCognizant = IsCognizant FROM AVL.Customer (NOLOCK) WHERE CustomerID = @CustomerID AND IsDeleted = 0
 
 IF (@IsDaily = '')
 BEGIN
	SET @IsDaily = NULL;
 END

 BEGIN TRY  

	BEGIN TRAN

	UPDATE AVL.Customer 
	SET IsEffortConfigured	= @IsEffortConfigured,
		IsEffortTrackActivityWise = CASE WHEN @IsEffortTrackActivityWise = 'TRUE' THEN 1 ELSE 0 END,
		IsDaily				= @IsDaily, 
		TimezoneId			= @TimezoneId,
		ModifiedDate		= GETDATE(),
		ModifiedBy			= @UserID, 
		SDTicketFormat		= @SDTicketFormat,
		Defaultermail		= CASE WHEN @Defaultermail = 'Y' THEN 1 ELSE 0 END	
	WHERE CustomerID = @CustomerID AND IsDeleted = 0  

	DECLARE @Percentage INT

	IF @IsCognizant = 1
	BEGIN

		SET @Percentage = (@TotalValue * 100) / 10
	END
	ELSE
	BEGIN 
	
		SET @Percentage = (@TotalValue * 100) / 9

	END

	IF (@IsCognizant = 1)
	BEGIN

		IF EXISTS (SELECT ProjectID FROM AVL.PRJ_ConfigurationProgress (NOLOCK) WHERE ProjectID = @ProjectID AND ScreenID = 4 AND IsDeleted = 0)
		BEGIN

			UPDATE AVL.PRJ_ConfigurationProgress 
			SET CompletionPercentage = @Percentage, ModifiedBy = @UserID, ModifiedDate = GETDATE()
			WHERE ProjectID = @ProjectID AND ScreenID = 4 AND IsDeleted = 0

		END
		ELSE
		BEGIN

			INSERT INTO AVL.PRJ_ConfigurationProgress
			(
				CustomerID, ProjectID, ScreenID, ITSMScreenId, CompletionPercentage, IsDeleted, CreatedBy,
				CreatedDate, ModifiedBy, ModifiedDate, IsSeverity, IsDefaultPriority
			)
			values 
			(
				@CustomerID, @ProjectID, 4, NULL, @Percentage, 0, @UserID, GETDATE(), NULL, NULL, NULL, NULL
			)

		END

--Added for TM change
		MERGE AVL.EffortUploadConfiguration AS EU
		USING (VALUES (@ProjectID)) AS s(ProjectID)
			ON eu.ProjectID = s.ProjectID
		WHEN MATCHED THEN  
		  UPDATE SET EU.SharePathName		= @SharePath,
					 EU.EffortUploadType	= @IsmanualOrAuto,
					 EU.ModifiedBy			= @UserID,
					 EU.ModifiedDate		= GETDATE(),
					 EU.IsActive			= CASE WHEN @IsmanualOrAuto = 'A' THEN 1 ELSE 0 END,
					 EU.IsMailEnabled		= @Defaultermail
		WHEN NOT MATCHED THEN 
		  INSERT
		  (
				ProjectID,
				SharePathName,
				EffortUploadType,
				IsActive,
				IsMailEnabled,
				CreatedBy,
				CreatedDate
		  )
		  VALUES
		  (
			@ProjectID,
			@SharePath,
			@IsmanualOrAuto,
			1,
			@Defaultermail,
			@UserID,
			GETDATE()
		  ); 

		MERGE PP.ScopeOfWork AS SC
		USING (VALUES (@ProjectID)) AS s(ProjectID)
			ON SC.ProjectID = s.ProjectID
		WHEN MATCHED THEN  
		  UPDATE SET SC.ALMTimeZoneId	= @ALMTimeZoneId,
					 SC.ModifiedBy		= @UserID,
					 SC.ModifiedDate	= GETDATE()
		WHEN NOT MATCHED THEN 
		  INSERT
		  (
				ProjectID,
				IsApplensAsALM,
				IsExternalALM,
				ALMToolID,
				ProjectTypeID,
				IsDeleted,
				CreatedBY,
				CreatedDate,
				ModifiedBy,
				ModifiedDate,
				IsSubmit,
				ALMTimeZoneId
		  )
		  VALUES
		  (
				 @ProjectID,
				 null,
				 null,
				 null,
				 null,
				 0,
				 @UserID,
				 GETDATE(),
				 null,
				 null,
				 null,
				 @ALMTimeZoneId
			); 
			
			IF EXISTS (SELECT TOP 1 1 FROM TicketUploadProjectConfiguration (NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 0)
			BEGIN
					
				UPDATE TicketUploadProjectConfiguration
				SET TicketSharePathUsers	= @TicketSharePathUsers,
					ModifiedBy				= @UserID,
					ModifiedDateTime		= GETDATE()
				WHERE ProjectID = @ProjectID AND IsDeleted = 0

			END
			ELSE
			BEGIN

				INSERT INTO TicketUploadProjectConfiguration
				(
					ProjectID,
					Ismailer,
					TicketSharePathUsers,
					IsDeleted,
					CreatedBy,
					CreatedDateTime
				) 
				VALUES
				(
					@ProjectID,
					NULL,
					@TicketSharePathUsers,
					0,
					@UserID,
					GETDATE()
				)

		    END
	END
	ELSE IF (@IsCognizant = 0)
	BEGIN

		IF EXISTS (SELECT CustomerID FROM AVL.PRJ_ConfigurationProgress (NOLOCK) WHERE CustomerID = @CustomerID AND ProjectID IS NULL AND ScreenID = 4 AND IsDeleted = 0)
		BEGIN

			UPDATE AVL.PRJ_ConfigurationProgress 
			SET CompletionPercentage = @Percentage,
				ModifiedBy			 = @UserID, 
				ModifiedDate		 = GETDATE()
			WHERE CustomerID = @CustomerID AND ProjectID IS NULL AND ScreenID = 4 AND IsDeleted = 0

		END
		ELSE
		BEGIN

			INSERT INTO AVL.PRJ_ConfigurationProgress
			(
				CustomerID, ProjectID, ScreenID, ITSMScreenId, CompletionPercentage, IsDeleted, 
				CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsSeverity, IsDefaultPriority
			)
			VALUES(@CustomerID, NULL, 4, NULL, @Percentage, 0, @UserID, GETDATE(), NULL, NULL, NULL, NULL)	
			
		END
		--Added for TM change -- Added for customer instance
		MERGE AVL.EffortUploadConfiguration AS EU
		USING (VALUES (@ProjectID)) AS s(ProjectID)
			ON eu.ProjectID = s.ProjectID
		WHEN MATCHED THEN  
		  UPDATE SET EU.SharePathName		= @SharePath,
					 EU.EffortUploadType	= @IsmanualOrAuto,
					 EU.ModifiedBy			= @UserID,
					 EU.ModifiedDate		= GETDATE(),
					 EU.IsActive			= CASE WHEN @IsmanualOrAuto = 'A' THEN 1 ELSE 0 END,
					 EU.IsMailEnabled		= @Defaultermail
		WHEN NOT MATCHED THEN 
		  INSERT
		  (
				ProjectID,
				SharePathName,
				EffortUploadType,
				IsActive,
				IsMailEnabled,
				CreatedBy,
				CreatedDate
		  )
		  VALUES
		  (
			@ProjectID,
			@SharePath,
			@IsmanualOrAuto,
			1,
			@Defaultermail,
			@UserID,
			GETDATE()
		  ); 

		MERGE PP.ScopeOfWork AS SC
		USING (VALUES (@ProjectID)) AS s(ProjectID)
			ON SC.ProjectID = s.ProjectID
		WHEN MATCHED THEN  
		  UPDATE SET SC.ALMTimeZoneId	= @ALMTimeZoneId,
					 SC.ModifiedBy		= @UserID,
					 SC.ModifiedDate	= GETDATE()
		WHEN NOT MATCHED THEN 
		  INSERT
		  (
				ProjectID,
				IsApplensAsALM,
				IsExternalALM,
				ALMToolID,
				ProjectTypeID,
				IsDeleted,
				CreatedBY,
				CreatedDate,
				ModifiedBy,
				ModifiedDate,
				IsSubmit,
				ALMTimeZoneId
		  )
		  VALUES
		  (
				 @ProjectID,
				 null,
				 null,
				 null,
				 null,
				 0,
				 @UserID,
				 GETDATE(),
				 null,
				 null,
				 null,
				 @ALMTimeZoneId
			); 
			
			IF EXISTS (SELECT TOP 1 1 FROM TicketUploadProjectConfiguration (NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 0)
			BEGIN
					
				UPDATE TicketUploadProjectConfiguration
				SET TicketSharePathUsers	= @TicketSharePathUsers,
					ModifiedBy				= @UserID,
					ModifiedDateTime		= GETDATE()
				WHERE ProjectID = @ProjectID AND IsDeleted = 0

			END
			ELSE
			BEGIN

				INSERT INTO TicketUploadProjectConfiguration
				(
					ProjectID,
					Ismailer,
					TicketSharePathUsers,
					IsDeleted,
					CreatedBy,
					CreatedDateTime
				) 
				VALUES
				(
					@ProjectID,
					NULL,
					@TicketSharePathUsers,
					0,
					@UserID,
					GETDATE()
				)
			END
	END

	-- Insert Work Profiler Configuration in Project Profiling Tile Progress table
	EXEC [PP].[SaveProjectProfilingTileProgress] @ProjectID, @WorkProfilerConfigTileID, @Percentage, @UserID

	SELECT 'Effort Entry Setup saved successfully' AS 'Result'

	COMMIT TRAN

 END TRY  
 BEGIN CATCH 
 
	DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
		
	ROLLBACK TRAN
		
	EXEC AVL_InsertError '[dbo].[Effort_SaveEffortEntrySetup] ', @ErrorMessage, 0,@CustomerID

 END CATCH  
 SET NOCOUNT OFF;

END
