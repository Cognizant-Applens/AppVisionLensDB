
CREATE PROCEDURE [ML].[GetJobStatusServices]  -- 28,'Success' ,'2'                    
@JobStatusId BIGINT,
@JobStatus VARCHAR(50),
@IsMailToUser VARCHAR(10)

AS                              
BEGIN    
	IF(@IsMailToUser ='1')
	BEGIN
	SELECT JM.JobName,JS.JobStatus,JS.StartDateTime,JS.EndDateTime,JS.Remarks
	FROM MAS.JobStatus JS (NOLOCK) JOIN MAS.jobmaster JM (NOLOCK) ON JM.JobId = JS.JobId
	WHERE JS.Id=@JobStatusId
	END
	ELSE
	BEGIN
    SELECT JM.JobName,JS.JobStatus,JS.JobStartTime AS StartDateTime,JS.JobEndTime AS EndDateTime, '' AS Remarks
	FROM TrackDetails JS (NOLOCK) JOIN MAS.jobmaster JM (NOLOCK) ON JM.JobId = JS.JobId
	WHERE JS.Id=@JobStatusId

	END
END