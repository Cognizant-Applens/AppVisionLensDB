/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[MS].[GETMONTHLYJOB_DATE] 9
CREATE PROCEDURE [MS].[GETMONTHLYJOB_DATE] --22
@ReportMonthlyConfigDay INT
AS
BEGIN
	DECLARE @CurrentDay DATE
	DECLARE @ResultDay date
	SET @CurrentDay = (SELECT CONVERT(DATE,GETDATE()))
	DECLARE @StartDate DATE
	--MONTH START DAY
	SET @StartDate = (SELECT   CONVERT(date,  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())  , 0)))

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

		--FROM FIRST DAY OF MONTH TO CURRENT DAY
		INSERT INTO #EFFORTDATES
		SELECT  CONVERT(DATE,DATEVALUE) AS DATETODAY , DATENAME(W,DATEVALUE) AS NAME
		FROM    MYCTE 
		OPTION (MAXRECURSION 0)
		--SELECT * FROM #EFFORTDATES

		SET @CurrentDay = (
						SELECT A.DATETODAY FROM 
						(SELECT DATETODAY , ROW_NUMBER() OVER(ORDER BY SNO) AS RNK FROM #EFFORTDATES ) 
						 AS A WHERE A.RNK = @ReportMonthlyConfigDay
						)
	--IF CURRENT DAY MATCHES THE REPORTING CONFIG DAY
	IF(@CurrentDay= CONVERT(date,GETDATE()))
		BEGIN
			SELECT 1 as count1
		END
	ELSE
		BEGIN
			SELECT 0 as count1
		END

	select B.RNK from 
	(SELECT DATETODAY,  ROW_NUMBER() OVER(ORDER BY SNO) AS RNK FROM #EFFORTDATES ) as B 
	where B.DATETODAY = convert(date,getdate())

END






