 --============================================= 
-- Author:    627384 
-- Create date: 11-FEB-2019 
-- Description:   SP for Initial Learning 
-- [ML].[Infra_SaveInitialLearningState]   10337,'01/01/2019','12/12/2019','471742',NULL,NULL,'NoiseEliminationUpd'
-- =============================================  
CREATE PROC [ML].[Infra_SaveInitialLearningState] ( @ProjectID        INT, 
                                               @StartDate        DATETIME=NULL, 
                                               @EndDate          DATETIME=NULL, 
                                               @UserID           NVARCHAR(20)=NULL, 
                                               @IsSMTicket       BIT=NULL, 
                                               @IsDARTTicket     BIT=NULL,                                                 
                                               @choice           NVARCHAR(100),
											   @IsRegenerate     BIT=0 ) 
AS 
  BEGIN 
  SET NOCOUNT ON
      BEGIN TRY 
          BEGIN TRAN          
 
          DECLARE @LatestID INT = 0
		  DECLARE @IniLearningID INT = 0

		  SET @IniLearningID = (CASE   
          WHEN @IsRegenerate = 0 THEN ( SELECT TOP 1 ID FROM   ML.InfraConfigurationProgress(NOLOCK)  
                  WHERE  projectid = @ProjectID   
                  AND IsDeleted = 0 ORDER  BY ID ASC )  
          ELSE ( SELECT ID FROM   ML.InfraConfigurationProgress(NOLOCK)   
                  WHERE  projectid = @ProjectID AND IsDeleted = 0   
                  AND ISNULL(IsMLSentOrReceived,'') <>'Received' )  
          END  
          )   
 

          --Latest initial Learning id of the project 
          IF( EXISTS (SELECT
						ProjectID
						FROM [ML].InfraConfigurationProgress(NOLOCK)	WHERE projectid = @ProjectID
						AND IsDeleted = 0 AND ID=@IniLearningID	GROUP BY projectid	HAVING COUNT(ID) > 1)
) BEGIN
SET @LatestID = (SELECT TOP 1
		ID
	FROM [ML].InfraConfigurationProgress(NOLOCK)
	WHERE projectid = @ProjectID
	AND IsDeleted = 0 AND ID=@IniLearningID
	ORDER BY id DESC)
END

 IF (@choice = 'NoiseEliminationUpd') BEGIN
--IsNoiseEliminationSentorReceived updation as Sent once ml is submitted to ml team 
IF (@LatestID = 0) 
BEGIN
UPDATE [ML].InfraConfigurationProgress
SET	[FromDate] = @StartDate
	,[ToDate] = @EndDate
	,IsNoiseEliminationSentorReceived = 'Sent'
	,ModifiedBy = @UserID
	,ModifiedDate = GETDATE()
WHERE ProjectID = @ProjectID
AND [IsDeleted] = 0
AND ID = @IniLearningID

SELECT	
	IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus	
	,[FromDate]
	,ToDate	
	,IsNoiseEliminationSentorReceived AS NoiseEliminationSent
	,IsMLSentOrReceived AS MLSentOrReceivedStatus
	,IsSamplingSkipped AS IsSamplingSkipped
	
FROM [ML].InfraConfigurationProgress(NOLOCK)
WHERE ProjectID = @ProjectID
AND ID IS NOT NULL
AND IsDeleted = 0
AND ID = @IniLearningID
END 
ELSE IF (@LatestID > 0)
UPDATE [ML].InfraConfigurationProgress
SET	[FromDate] = @StartDate
	,[ToDate] = @EndDate
	,IsNoiseEliminationSentorReceived = 'Sent'
	,ModifiedBy = @UserID
	,ModifiedDate = GETDATE()
WHERE ProjectID = @ProjectID
AND [IsDeleted] = 0
AND ID = @LatestID

SELECT	
	IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus
	,[FromDate]
	,[ToDate]		
	,IsNoiseEliminationSentorReceived AS NoiseEliminationSent
	,IsMLSentOrReceived AS MLSentOrReceivedStatus
	,IsSamplingSkipped AS IsSamplingSkipped
	
FROM [ML].[InfraConfigurationProgress](NOLOCK) IT

WHERE it.ProjectID = @ProjectID
AND IT.ID IS NOT NULL
AND it.IsDeleted = 0
AND IT.ID = @LatestID
END 

ELSE IF(@choice = 'SamplingSent')
BEGIN

	IF (@LatestID = 0) 
BEGIN
UPDATE [ML].InfraConfigurationProgress
SET	[FromDate] = @StartDate
	,[ToDate] = @EndDate
	,IsSamplingSentOrReceived = 'Sent'
	,ModifiedBy = @UserID
	,ModifiedDate = GETDATE()
WHERE ProjectID = @ProjectID
AND [IsDeleted] = 0
AND ID = @IniLearningID

SELECT	
	IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus	
	,[FromDate]
	,ToDate	
	,IsNoiseEliminationSentorReceived AS NoiseEliminationSent
	,IsMLSentOrReceived AS MLSentOrReceivedStatus
	,IsSamplingSkipped AS IsSamplingSkipped
	
FROM [ML].InfraConfigurationProgress(NOLOCK)
WHERE ProjectID = @ProjectID
AND ID IS NOT NULL
AND IsDeleted = 0
AND ID = @IniLearningID
END 
ELSE IF (@LatestID > 0)
UPDATE [ML].InfraConfigurationProgress
SET	[FromDate] = @StartDate
	,[ToDate] = @EndDate
	,IsSamplingSentOrReceived = 'Sent'
	,ModifiedBy = @UserID
	,ModifiedDate = GETDATE()
WHERE ProjectID = @ProjectID
AND [IsDeleted] = 0
AND ID = @LatestID

SELECT	
	IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus
	,[FromDate]
	,[ToDate]		
	,IsNoiseEliminationSentorReceived AS NoiseEliminationSent
	,IsMLSentOrReceived AS MLSentOrReceivedStatus
	,IsSamplingSkipped AS IsSamplingSkipped
	
FROM [ML].InfraConfigurationProgress(NOLOCK) IT

WHERE it.ProjectID = @ProjectID
AND IT.ID IS NOT NULL
AND it.IsDeleted = 0
AND IT.ID = @LatestID
END
ELSE IF(@choice = 'MLSent')
BEGIN

	IF (@LatestID = 0) 
BEGIN
UPDATE [ML].InfraConfigurationProgress
SET	[FromDate] = @StartDate
	,[ToDate] = @EndDate
	,IsMLSentOrReceived = 'Sent'
	,ModifiedBy = @UserID
	,ModifiedDate = GETDATE()
WHERE ProjectID = @ProjectID
AND [IsDeleted] = 0
AND ID = @IniLearningID

SELECT	
	IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus	
	,[FromDate]
	,ToDate	
	,IsNoiseEliminationSentorReceived AS NoiseEliminationSent
	,IsMLSentOrReceived AS MLSentOrReceivedStatus
	,IsSamplingSkipped AS IsSamplingSkipped
	
FROM [ML].InfraConfigurationProgress(NOLOCK)
WHERE ProjectID = @ProjectID
AND ID IS NOT NULL
AND IsDeleted = 0
AND ID = @IniLearningID
END 
ELSE IF (@LatestID > 0)
UPDATE [ML].InfraConfigurationProgress
SET	[FromDate] = @StartDate
	,[ToDate] = @EndDate
	,IsMLSentOrReceived = 'Sent'
	,ModifiedBy = @UserID
	,ModifiedDate = GETDATE()
WHERE ProjectID = @ProjectID
AND [IsDeleted] = 0
AND ID = @LatestID

SELECT	
	IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus
	,[FromDate]
	,[ToDate]		
	,IsNoiseEliminationSentorReceived AS NoiseEliminationSent
	,IsMLSentOrReceived AS MLSentOrReceivedStatus
	,IsSamplingSkipped AS IsSamplingSkipped
	
FROM [ML].InfraConfigurationProgress(NOLOCK) IT

WHERE it.ProjectID = @ProjectID
AND IT.ID IS NOT NULL
AND it.IsDeleted = 0
AND IT.ID = @LatestID
END
ELSE IF (@choice = 'Skip')
BEGIN
IF (@LatestID = 0) 
BEGIN
UPDATE [ML].InfraConfigurationProgress
SET	[FromDate] = @StartDate
	,[ToDate] = @EndDate
	,IsSamplingSkipped = 1
	,ModifiedBy = @UserID
	,ModifiedDate = GETDATE()
WHERE ProjectID = @ProjectID
AND [IsDeleted] = 0
AND ID = @IniLearningID

SELECT	
	IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus	
	,[FromDate]
	,ToDate	
	,IsNoiseEliminationSentorReceived AS NoiseEliminationSent
	,IsMLSentOrReceived AS MLSentOrReceivedStatus
	,IsSamplingSkipped AS IsSamplingSkipped
	
	
FROM [ML].InfraConfigurationProgress(NOLOCK)
WHERE ProjectID = @ProjectID
AND ID IS NOT NULL
AND IsDeleted = 0
AND ID = @IniLearningID
END 
ELSE IF (@LatestID > 0)
UPDATE [ML].InfraConfigurationProgress
SET	[FromDate] = @StartDate
	,[ToDate] = @EndDate
	,IsSamplingSkipped = 1
	,ModifiedBy = @UserID
	,ModifiedDate = GETDATE()
WHERE ProjectID = @ProjectID
AND [IsDeleted] = 0
AND ID = @LatestID

SELECT	
	IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus
	,[FromDate]
	,[ToDate]		
	,IsNoiseEliminationSentorReceived AS NoiseEliminationSent
	,IsMLSentOrReceived AS MLSentOrReceivedStatus
	,IsSamplingSkipped AS IsSamplingSkipped
	
FROM [ML].InfraConfigurationProgress(NOLOCK) IT

WHERE it.ProjectID = @ProjectID
AND IT.ID IS NOT NULL
AND it.IsDeleted = 0
AND IT.ID = @LatestID
END 
ELSE IF (@choice = 'NotSkipped')
BEGIN
IF (@LatestID = 0) 
BEGIN
UPDATE [ML].InfraConfigurationProgress
SET	[FromDate] = @StartDate
	,[ToDate] = @EndDate
	,IsSamplingSkipped = 0
	,ModifiedBy = @UserID
	,ModifiedDate = GETDATE()
WHERE ProjectID = @ProjectID
AND [IsDeleted] = 0
AND ID = @IniLearningID

SELECT	
	IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus	
	,[FromDate]
	,ToDate	
	,IsNoiseEliminationSentorReceived AS NoiseEliminationSent
	,IsMLSentOrReceived AS MLSentOrReceivedStatus
	,IsSamplingSkipped AS IsSamplingSkipped
	
	
FROM [ML].InfraConfigurationProgress(NOLOCK)
WHERE ProjectID = @ProjectID
AND ID IS NOT NULL
AND IsDeleted = 0
AND ID = @IniLearningID
END 
ELSE IF (@LatestID > 0)
UPDATE [ML].InfraConfigurationProgress
SET	[FromDate] = @StartDate
	,[ToDate] = @EndDate
	,IsSamplingSkipped = 0
	,ModifiedBy = @UserID
	,ModifiedDate = GETDATE()
WHERE ProjectID = @ProjectID
AND [IsDeleted] = 0
AND ID = @LatestID

SELECT	
	IsSamplingSentOrReceived AS SamplingSentOrReceivedStatus
	,[FromDate]
	,[ToDate]		
	,IsNoiseEliminationSentorReceived AS NoiseEliminationSent
	,IsMLSentOrReceived AS MLSentOrReceivedStatus
	,IsSamplingSkipped AS IsSamplingSkipped
	
FROM [ML].InfraConfigurationProgress(NOLOCK) IT

WHERE it.ProjectID = @ProjectID
AND IT.ID IS NOT NULL
AND it.IsDeleted = 0
AND IT.ID = @LatestID
END 

COMMIT TRAN
END TRY 
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()

ROLLBACK TRAN

--INSERT Error     
EXEC AVL_INSERTERROR	'[ML].[Infra_SaveInitialLearningState] '
						,@ErrorMessage
						,@ProjectID
						,0
END CATCH
SET NOCOUNT OFF
END
