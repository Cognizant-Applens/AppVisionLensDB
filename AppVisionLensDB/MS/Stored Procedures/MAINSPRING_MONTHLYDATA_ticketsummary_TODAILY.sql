/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [MS].[MAINSPRING_MONTHLYDATA_ticketsummary_TODAILY]
AS
BEGIN
	
		DECLARE @StartDate DATE
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
		
			INSERT INTO #EFFORTDATES
			SELECT  CONVERT(DATE,DATEVALUE) AS DATETODAY , DATENAME(W,DATEVALUE) AS NAME
			FROM    MYCTE 
			OPTION (MAXRECURSION 0)
			DELETE FROM #EFFORTDATES WHERE NAME IN ('Saturday','Sunday')
			
			declare @Today INT
			set @Today = (select B.RNK from (
							SELECT DATETODAY,  ROW_NUMBER() OVER(ORDER BY SNO) AS RNK FROM #EFFORTDATES ) as B where B.DATETODAY = convert(date,getdate()
									))
				IF (@Today = 1)
				BEGIN
					INSERT INTO MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary_SnapshotMONTHLYDATA
					SELECT * FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary
					
					TRUNCATE TABLE MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary
				END
				ELSE
				BEGIN
					INSERT INTO  MS.TRN_ProjectStaging_TillDateBaseMeasure_TicketSummary_SnapshotDAILYDATAPUSH
					SELECT * FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary
					
					
					TRUNCATE TABLE MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary
				END
	

END





