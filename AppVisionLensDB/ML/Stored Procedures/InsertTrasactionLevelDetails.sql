
--EXEC ML.InsertTrasactionLevelDetails 'IL_Clustering_Services',1266,'Started',0
CREATE PROCEDURE [ML].[InsertTrasactionLevelDetails]
(@JobName NVARCHAR(200),
@TransactionId BIGINT,
@Status NVARCHAR(200),
@Id BIGINT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
DECLARE @JobId BIGINT = (SELECT JobId FROM MAS.JobMaster(NOLOCK) where JobName=@JobName AND IsDeleted = 0)
IF(@Status = 'Started')
BEGIN
INSERT INTO dbo.[TrackDetails] VALUES(@JobId,GETDATE(),NULL,@TransactionId,@Status,0,0,@JobName,GETDATE(),NULL,NULL)
SET @Id = (SELECT TOP 1 Id FROM dbo.[TrackDetails](NOLOCK) where JobId = @JobId AND IsDeleted = 0 ORDER BY CreatedDate Desc)
SELECT @Id as Id,@Status as JobStatus, 0 AS MailerCompleted
END
ELSE IF(@Status = 'Success')
BEGIN
UPDATE dbo.[TrackDetails] SET JobEndTime = GetDate(),JobStatus = @Status, Modifiedby = @JobName, ModifiedDate = GetDate() WHERE Id = @Id
SELECT @Id as Id,@Status as JobStatus, 1 AS MailerCompleted
END
ELSE
BEGIN
UPDATE dbo.[TrackDetails] SET JobStatus = @Status, Modifiedby = @JobName, ModifiedDate = GetDate() WHERE Id = @Id
SELECT @Id as Id,@Status as JobStatus, 1 AS MailerCompleted
END

END

