/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================= 
-- Author:    471742 
-- Create date:
-- Description:   SP for Initial Learning 
-- =============================================  
CREATE PROCEDURE [AVL].[ML_SaveInitialLearningStateInfra] 
	@ProjectID        BIGINT, 
	@StartDate        DATETIME=NULL, 
	@EndDate          DATETIME=NULL, 
	@UserID           NVARCHAR(50)=NULL, 
	@OptFieldsForProj INT, 
	@choice           NVARCHAR(100) 
AS 
  BEGIN
      BEGIN TRY 
		
          DECLARE @mlstatus NVARCHAR(500)
          DECLARE @LatestID INT = 0
          IF( EXISTS (SELECT ProjectID FROM [AVL].ML_PRJ_InitialLearningStateInfra WHERE projectid = @ProjectID
						AND IsDeleted = 0 )) 
		BEGIN
			SET @LatestID = (SELECT TOP 1 ID
							FROM [AVL].ML_PRJ_InitialLearningStateInfra WHERE projectid = @ProjectID
							AND IsDeleted = 0 ORDER BY id DESC)
		END

IF (@choice = 'MLUpdation') 
BEGIN
--IsMLSentorReceived updation as Sent once ml is submitted to ml team 
IF (@LatestID = 0) 
	BEGIN
		UPDATE AVL.ML_PRJ_InitialLearningStateInfra
		SET	[StartDate] = @StartDate,[EndDate] = @EndDate,[IsMLSentOrReceived] = 'Sent'
		,[SentBy] = @UserID,[SentOn] = GETDATE(),ModifiedBy = @UserID,ModifiedDate = GETDATE()
		WHERE ProjectID = @ProjectID AND [IsDeleted] = 0

		SELECT TOP 1 [IsMLSentOrReceived] AS MLStatus,IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus
		,IsSamplingInProgress AS SamplingInProgressStatus
		,[StartDate],[EndDate],IsSDTicket,IsDartTicket,ISNULL(IT.IsRegenerated, 0) AS IsRegenerated
		,NULL AS FromDate,NULL AS Todate
		FROM AVL.ML_PRJ_InitialLearningStateInfra IT
		WHERE IT.ProjectID = @ProjectID AND IT.ID IS NOT NULL AND it.IsDeleted = 0
	END 
ELSE IF (@LatestID > 0) 
	BEGIN
		UPDATE AVL.ML_PRJ_InitialLearningStateInfra SET	[StartDate] = @StartDate,[EndDate] = @EndDate
		,[IsMLSentOrReceived] = 'Sent',[SentBy] = @UserID,[SentOn] = GETDATE()
		,ModifiedBy = @UserID,ModifiedDate = GETDATE()
		WHERE ProjectID = @ProjectID AND [IsDeleted] = 0 AND ID = @LatestID

		SELECT TOP 1 [IsMLSentOrReceived] AS MLStatus,IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus
		,IsSamplingInProgress AS SamplingInProgressStatus,[StartDate],[EndDate],IsSDTicket,IsDartTicket
		,ISNULL(IT.IsRegenerated, 0) AS IsRegenerated,Reg.FromDate,Reg.Todate
		FROM AVL.ML_PRJ_InitialLearningStateInfra IT
		LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails Reg ON Reg.InitialLearningID = it.ID
		AND reg.IsDeleted = 0 AND Reg.ProjectID = it.ProjectID AND Reg.[IsDeleted] = 0
		WHERE it.ProjectID = @ProjectID AND IT.ID IS NOT NULL AND it.IsDeleted = 0 AND IT.ID = @LatestID
	END
END 
ELSE IF (@choice = 'NoiseEliminationUpd') 
	BEGIN
	--IsNoiseEliminationSentorReceived updation as Sent once ml is submitted to ml team 
	IF (@LatestID = 0) 
		BEGIN
			UPDATE AVL.ML_PRJ_InitialLearningStateInfra
			SET	[StartDate] = @StartDate,[EndDate] = @EndDate,IsNoiseEliminationSentorReceived = 'Sent'
			,ModifiedBy = @UserID,ModifiedDate = GETDATE()
			WHERE ProjectID = @ProjectID AND [IsDeleted] = 0

			SELECT [IsMLSentOrReceived] AS MLStatus,IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus
			,IsSamplingInProgress AS SamplingInProgressStatus,[StartDate],[EndDate]
			,IsSDTicket,IsDartTicket,IsNoiseEliminationSentorReceived AS NoiseEliminationSent,
			ISNULL(IsRegenerated, 0) AS IsRegenerated,NULL AS FromDate,NULL AS Todate
			FROM AVL.ML_PRJ_InitialLearningStateInfra
			WHERE ProjectID = @ProjectID AND ID IS NOT NULL AND IsDeleted = 0
		END 
	ELSE IF (@LatestID > 0) 
		UPDATE AVL.ML_PRJ_InitialLearningStateInfra
		SET	[StartDate] = @StartDate,[EndDate] = @EndDate,IsNoiseEliminationSentorReceived = 'Sent'
		,ModifiedBy = @UserID,ModifiedDate = GETDATE()
		WHERE ProjectID = @ProjectID AND [IsDeleted] = 0 AND ID = @LatestID

		SELECT
		[IsMLSentOrReceived] AS MLStatus,IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus
		,IsSamplingInProgress AS SamplingInProgressStatus,[StartDate],[EndDate],IsSDTicket,IsDartTicket
		,IsNoiseEliminationSentorReceived AS NoiseEliminationSent,ISNULL(IsRegenerated, 0) AS IsRegenerated
		,Reg.FromDate,Reg.Todate
		FROM AVL.ML_PRJ_InitialLearningStateInfra IT
		LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails Reg
		ON Reg.InitialLearningID = it.ID AND reg.IsDeleted = 0 AND Reg.ProjectID = it.ProjectID AND Reg.[IsDeleted] = 0
		WHERE it.ProjectID = @ProjectID AND IT.ID IS NOT NULL AND it.IsDeleted = 0 AND IT.ID = @LatestID
	END 
ELSE IF (@choice = 'SaveML') 
	BEGIN
	--to delete the latest transaction if it has completed ml and insert new transaction or update the transaction if it is not completed
	IF EXISTS (SELECT ProjectID FROM AVL.ML_PRJ_InitialLearningStateInfra WHERE ProjectID = @ProjectID) 
	BEGIN
	SET @mlstatus = (SELECT TOP 1 ISNULL([IsMLSentOrReceived],IsSamplingSentOrReceived)
					FROM AVL.ML_PRJ_InitialLearningStateInfra WHERE ProjectID = @ProjectID
					AND IsDeleted = 0 ORDER BY id DESC)

	IF (@mlstatus = 'Received') 
		BEGIN
			DECLARE @IsRegenerated BIT = (SELECT TOP 1 ISNULL(IsRegenerated, 0)
				FROM AVL.ML_PRJ_InitialLearningStateInfra WHERE ProjectID = @ProjectID AND IsDeleted = 0 AND ID = @LatestID)
			UPDATE AVL.ML_PRJ_InitialLearningStateInfra
			SET IsDeleted = 1 WHERE ProjectID = @ProjectID AND ID = @LatestID AND ([IsMLSentOrReceived] = 'Received')

			INSERT INTO AVL.ML_PRJ_InitialLearningStateInfra ([ProjectID],
			[StartDate],[EndDate],[IsSDTicket],[IsDartTicket],[CreatedBy],[CreatedDate],[IsDeleted], IsRegenerated)
				VALUES (@ProjectID, @StartDate, @EndDate, 1, 1, @UserID, GETDATE(), 0, @IsRegenerated)

			DECLARE @InitialLearningID BIGINT;
			SET @InitialLearningID = (SELECT TOP 1 ID FROM AVL.ML_PRJ_InitialLearningStateInfra
				WHERE ProjectID = @PROJECTID AND IsDeleted = 0 ORDER BY ID DESC)
			UPDATE AVL.ML_TRN_RegeneratedTowerDetails SET InitialLearningID = @InitialLearningID
			WHERE InitialLearningID = @LatestId AND @IsRegenerated = 1

			UPDATE AVL.MAS_ProjectDebtDetails
			SET	IsMLSignOffInfra = NULL,MLSignOffDateInfra = NULL,MLSignOffUserIdInfra = NULL
			WHERE ProjectID = @ProjectID AND IsDeleted = 0 AND @IsRegenerated = 0

		END 
	ELSE 
		BEGIN
		IF (@LatestID = 0) 
			BEGIN
				UPDATE AVL.ML_PRJ_InitialLearningStateInfra
				SET	[StartDate] = @StartDate,[EndDate] = @EndDate,ModifiedBy = @UserID,ModifiedDate = GETDATE()
					WHERE ProjectID = @ProjectID AND [IsDeleted] = 0
				END 
				ELSE IF (@LatestID > 0) 
				UPDATE AVL.ML_PRJ_InitialLearningStateInfra
				SET	[StartDate] = @StartDate,[EndDate] = @EndDate,ModifiedBy = @UserID,ModifiedDate = GETDATE()	
				WHERE ProjectID = @ProjectID AND [IsDeleted] = 0 AND ID = @LatestID
			END
		END 
		ELSE 
			BEGIN
				IF NOT EXISTS (SELECT ProjectID FROM AVL.ML_PRJ_InitialLearningStateInfra WHERE ProjectID = @ProjectID) 
				BEGIN
				INSERT INTO AVL.ML_PRJ_InitialLearningStateInfra ([ProjectID],
				[StartDate],[EndDate],[IsSDTicket],[IsDartTicket],[CreatedBy],[CreatedDate],[IsDeleted])
				VALUES (@ProjectID, @StartDate, @EndDate, 1, 1, @UserID, GETDATE(), 0)

				UPDATE AVL.MAS_PROJECTDEBTDETAILS
				SET	IsMLSignOff = NULL,MLSignOffDate = NULL,MLSignOffUserId = NULL
				WHERE ProjectID = @ProjectID AND IsDeleted = 0
			END
		END

	IF EXISTS (SELECT ProjectId FROM AVL.ML_MAP_OptionalProjMappingInfra WHERE ProjectID = @ProjectID) 
		BEGIN
			UPDATE AVL.ML_MAP_OptionalProjMappingInfra
			SET OptionalFieldID =CASE
										WHEN @OptFieldsForProj = 0 THEN 4
										ELSE @OptFieldsForProj
									END
			WHERE ProjectId = @ProjectID AND IsDeleted = 0
		END 
	ELSE 
		BEGIN
		INSERT INTO AVL.ML_MAP_OptionalProjMappingInfra (ProjectId,OptionalFieldID,IsDeleted,CreatedBy,CreatedDate)
			SELECT
				@ProjectID,CASE
					WHEN @OptFieldsForProj = 0 THEN 4
					ELSE @OptFieldsForProj
				END
				,0,@UserID,GETDATE()
		END
	END 
ELSE IF (@choice = 'SamplingUpdation') 
	BEGIN
	--update IsSamplingSentOrReceived as Sent for latest transaction 
	IF (@LatestID = 0) BEGIN
	UPDATE AVL.ML_PRJ_InitialLearningStateInfra
	SET	[StartDate] = @StartDate,[EndDate] = @EndDate,IsSamplingSentOrReceived = 'Sent'
		,[SentBy] = @UserID,[SentOn] = GETDATE(),ModifiedBy = @UserID,ModifiedDate = GETDATE()
	WHERE ProjectID = @ProjectID
	AND [IsDeleted] = 0

	SELECT
		[IsMLSentOrReceived] AS MLStatus,IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus
		,IsSamplingInProgress AS SamplingInProgressStatus,[StartDate],[EndDate]
		,IsSDTicket,IsDartTicket,ISNULL(IsRegenerated, 0) AS IsRegenerated,NULL AS FromDate,NULL AS Todate
	FROM AVL.ML_PRJ_InitialLearningStateInfra IT
	WHERE it.ProjectID = @ProjectID AND IT.ID IS NOT NULL AND it.IsDeleted = 0
	END 
ELSE IF (@LatestID > 0) 
BEGIN
	UPDATE AVL.ML_PRJ_InitialLearningStateInfra
	SET	[StartDate] = @StartDate,IsSamplingSentOrReceived = 'Sent'
		,[SentBy] = @UserID,[SentOn] = GETDATE(),ModifiedBy = @UserID,ModifiedDate = GETDATE()
	WHERE ProjectID = @ProjectID AND [IsDeleted] = 0 AND ID = @LatestID

	SELECT
		[IsMLSentOrReceived] AS MLStatus,IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus
		,IsSamplingInProgress AS SamplingInProgressStatus,[StartDate],[EndDate],IsSDTicket,IsDartTicket
		,ISNULL(IsRegenerated, 0) AS IsRegenerated,Reg.FromDate,Reg.Todate
	FROM AVL.ML_PRJ_InitialLearningStateInfra IT
	LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails Reg
		ON Reg.InitialLearningID = it.ID AND reg.IsDeleted = 0 AND reg.ProjectID = @ProjectID
	WHERE it.ProjectID = @ProjectID AND IT.ID IS NOT NULL AND it.IsDeleted = 0 AND IT.ID = @LatestID
END
END

	  END TRY
	  BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()

		EXEC AVL_INSERTERROR	'[AVL].[ML_SaveInitialLearningStateInfra]',@ErrorMessage,@ProjectID,0
		END CATCH
	END
