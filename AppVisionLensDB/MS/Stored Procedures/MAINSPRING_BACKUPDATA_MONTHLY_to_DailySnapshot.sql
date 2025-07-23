/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- EXEC [MS].[MAINSPRING_BACKUPDATA_MONTHLY_to_DailySnapshot]
CREATE PROCEDURE [MS].[MAINSPRING_BACKUPDATA_MONTHLY_to_DailySnapshot]
AS
BEGIN
BEGIN TRY
		-- to get first working day
		
	DECLARE @StartDate DATE
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
	
		INSERT INTO #EFFORTDATES
		SELECT  CONVERT(DATE,DATEVALUE) AS DATETODAY , DATENAME(W,DATEVALUE) AS NAME
		FROM    MYCTE 
		OPTION (MAXRECURSION 0)
		DELETE FROM #EFFORTDATES WHERE NAME IN ('Saturday','Sunday')
		
		declare @Today INT
		set @Today = (select B.RNK from (
							SELECT DATETODAY,  ROW_NUMBER() OVER(ORDER BY SNO) AS RNK FROM #EFFORTDATES ) as B 
							where B.DATETODAY = convert(date,getdate()
							))
		--To check the working day number of the current date(but not the final job run)
			
		IF (@Today = 1)
		BEGIN
				--If first working day, take a snapshot to monthly
				INSERT INTO MS.TRN_ProjectStaging_MonthlyBaseMeasure_SnapshotMONTHLYDATAPUSH
				SELECT * FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure
				
				TRUNCATE TABLE MS.TRN_ProjectStaging_MonthlyBaseMeasure

				INSERT INTO MS.TRN_ProjectStaging_MonthlyBaseMeasure_SnapshotMONTHLYDATAPUSH
				SELECT * FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure_LoadFactor
				
				TRUNCATE TABLE MS.TRN_ProjectStaging_MonthlyBaseMeasure_LoadFactor


		END
		ELSE
		BEGIN
				--If not first day,2nd,3rd days, and not final job run
				INSERT INTO MS.[TRN_ProjectStaging_TillDateBaseMeasure_DAILYDATAPUSH]
				SELECT * FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure
				
				TRUNCATE TABLE MS.TRN_ProjectStaging_MonthlyBaseMeasure


				INSERT INTO [MS].[TRN_ProjectStaging_TillDateBaseMeasure_DAILYDATAPUSH]
				SELECT * FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure_LoadFactor
				
				TRUNCATE TABLE MS.TRN_ProjectStaging_MonthlyBaseMeasure_LoadFactor

		END
END TRY  
BEGIN CATCH  
		
    DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT; 

    SELECT @ErrorMessage = ERROR_MESSAGE()
    SELECT @ErrorSeverity = ERROR_SEVERITY()
    SELECT @ErrorState =  ERROR_STATE()

	--INSERT Error    
	EXEC AVL_InsertError '[MS].[MAINSPRING_BACKUPDATA_MONTHLY_to_DailySnapshot]', @ErrorMessage, 0,0
                                
    -- Use RAISERROR inside the CATCH block to return error  
    -- information about the original error that caused  
    -- execution to jump to the CATCH block.  
    RAISERROR (@ErrorMessage, -- Message text.  
                                        @ErrorSeverity, -- Severity.  
                                        @ErrorState -- State.  
                                        );     
	END CATCH  
END


