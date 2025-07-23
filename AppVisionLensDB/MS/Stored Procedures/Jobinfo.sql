/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- Description:Get the job list of recent
-- =============================================

--EXEC [MS].[Jobinfo]
CREATE PROCEDURE [MS].[Jobinfo]
@Flag INT=0,
@JobId INT=0


AS
BEGIN

	SET NOCOUNT ON;
	--Get the top row with job started id
	IF @Flag=0
		BEGIN
			SELECT TOP(1) JobID,JobStatus,ReportingPeriod,FrequencyID,CONVERT(date,CreatedDate) as Jobdate 
			FROM MS.TRN_MonthlyJobStatusTillDate
			WHERE JobStatus NOT IN(4) and  JobStatus = 1
			ORDER BY JobID DESC
		END
	ELSE IF @Flag=1
		BEGIN
			--make as progress
			UPDATE  MS.TRN_MonthlyJobStatusTillDate SET JobStatus=3
			WHERE JobID=@JobId and JobStatus = 1
		END
	--job status as Success
	ELSE IF @Flag=2
		BEGIN
			--if in progress make as success
			UPDATE  MS.TRN_MonthlyJobStatusTillDate SET JobStatus=4
			WHERE JobID=@JobId and JobStatus = 3
			--if in start make as pending
			UPDATE  MS.TRN_MonthlyJobStatusTillDate SET JobStatus=2
			WHERE  JobStatus = 1
		END
		--Exception in job
	ELSE IF @Flag=3
		BEGIN
			UPDATE  MS.TRN_MonthlyJobStatusTillDate SET JobStatus=5
			WHERE JobID=@JobId
		END
	ELSE IF @Flag=4
		BEGIN
		--get the in progress status
			SELECT TOP(1) JobID,JobStatus,ReportingPeriod,FrequencyID,CONVERT(date,CreatedDate) as Jobdate 
			FROM MS.TRN_MonthlyJobStatusTillDate
		WHERE JobStatus NOT IN(4) and  JobStatus = 3
		END
	SET NOCOUNT OFF;  
END



