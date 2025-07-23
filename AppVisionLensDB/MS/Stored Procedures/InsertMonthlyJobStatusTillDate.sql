/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- Description:	Job for Insert Mainspriing_MonthlyJobStatusTillDate Table
-- =============================================
--exec [MS].[InsertMonthlyJobStatusTillDate] 7
CREATE PROCEDURE [MS].[InsertMonthlyJobStatusTillDate]-- 8
@MonthlyJobDay INT
AS
BEGIN
SET NOCOUNT ON;
	IF EXISTS(SELECT FrequencyID, FrequencyName FROM MS.MAS_Frequency_Master
			  WHERE IsDeleted=0 AND FrequencyID IN (4))
	BEGIN
		DECLARE @CurrentDate DATETIME
		DECLARE @CurrentDay INT
		DECLARE @CurrentMonth INT
		DECLARE @CurrentYear INT
		DECLARE @ReportMonth1 VARCHAR(50)
		DECLARE @ReportSelectedMonth1 INT
		
		SELECT @CurrentDate = GETDATE()
		SELECT	@CurrentDay = DAY(@CurrentDate)
		SELECT @CurrentDay AS CurrentDay
		SELECT	@CurrentMonth = MONTH(@CurrentDate)
		SELECT	@CurrentYear = YEAR(@CurrentDate)
		--Current month in text
		SELECT	@ReportMonth1 = DATENAME(MONTH, DATEADD(MONTH, @CurrentMonth, 0) - 1)
		SELECT @ReportMonth1 AS ReportMonth1
		SET @ReportSelectedMonth1 = @CurrentMonth
		
		--Inserting the frequency id,with name and job status id
		SELECT	4 AS FrequencyID ,CONVERT(VARCHAR(4), @ReportSelectedMonth1) + CONVERT(VARCHAR(4), @CurrentYear) AS ReportPeriodID
		,@ReportMonth1 + ' ' + CONVERT(VARCHAR(4), @CurrentYear) AS ReportPeriod,1 AS JobStatusID
		INTO #InsertMonthlyJobStatusTillDate
		SELECT * FROM #InsertMonthlyJobStatusTillDate

		--Check if same DATE Is present in daily table
		IF NOT EXISTS(SELECT Job1.JobID FROM MS.TRN_MonthlyJobStatusTillDate Job1
		INNER JOIN #InsertMonthlyJobStatusTillDate JobTemp1 ON Job1.FrequencyID=JobTemp1.FrequencyID AND Job1.ReportingPeriod=JobTemp1.ReportPeriodID
		WHERE CONVERT(NVARCHAR,Job1.CreatedDate, 106)= CONVERT(NVARCHAR, getdate(), 106))
			BEGIN
				INSERT INTO MS.TRN_MonthlyJobStatusTillDate(FrequencyID, ReportingPeriod, ReportingPeriodDESC, JobStatus, CreatedDate)
				SELECT FrequencyID,ReportPeriodID,ReportPeriod,JobStatusID,GETDATE() FROM #InsertMonthlyJobStatusTillDate
			END

		-- to get the nth working day
		DECLARE @CurrentDay1 DATE
		DECLARE @ResultDay date
		SET @CurrentDay1 = (SELECT CONVERT(DATE,GETDATE()))
		--SELECT @CurrentDay = DAY(GETDATE())
		DECLARE @StartDate DATE
		--Getting the first day of current month
		SET @StartDate = (SELECT   CONVERT(date,  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())  , 0)))
		
		SELECT @StartDate AS StartDate
		CREATE TABLE #EFFORTDATES
		(
		SNO INT IDENTITY(1,1),
		DATETODAY DATE,
		NAME VARCHAR(50)
		)
		;WITH MYCTE AS
		(
			SELECT CAST(@StartDate AS DATETIME) DATEVALUE
			UNION ALL
			SELECT  DATEVALUE + 1
			FROM    MYCTE   
			WHERE   DATEVALUE + 1 <= GETDATE()
		)
		--Inserting all the days from day 1 to current day 
		INSERT INTO #EFFORTDATES
		SELECT  CONVERT(DATE,DATEVALUE) AS DATETODAY , DATENAME(W,DATEVALUE) AS NAME
		FROM    MYCTE 
		OPTION (MAXRECURSION 0)
		SELECT * FROM #EFFORTDATES
		--Selecting the sent day from job based on config
		SET @CurrentDay1 = (
		SELECT A.DATETODAY FROM 
		(SELECT DATETODAY , ROW_NUMBER() OVER(ORDER BY SNO) AS RNK FROM #EFFORTDATES ) AS A WHERE A.RNK = @MonthlyJobDay
		)
	SELECT @CurrentDay1 AS CurrentDay1

		DECLARE @Jobday INT
		set @Jobday = day(@CurrentDay1)
		select @Jobday
		--Checking whether current date is equal to job day and inserting into monthly table
		IF (@CurrentDay=@Jobday)
			BEGIN
				IF NOT EXISTS(SELECT Job1.JobID FROM MS.TRN_MonthlyJobStatus Job1
				INNER JOIN #InsertMonthlyJobStatusTillDate JobTemp1 ON Job1.FrequencyID=JobTemp1.FrequencyID AND Job1.ReportingPeriod=JobTemp1.ReportPeriodID)
					BEGIN
						INSERT INTO MS.TRN_MonthlyJobStatus(FrequencyID, ReportingPeriod, ReportingPeriodDESC, JobStatus, CreatedDate)
						SELECT FrequencyID,ReportPeriodID,ReportPeriod,JobStatusID,GETDATE() FROM #InsertMonthlyJobStatusTillDate
					END
			END
		DROP TABLE #InsertMonthlyJobStatusTillDate
	END
END



