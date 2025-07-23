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

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [MS].[MonthlyJOB_Phase2]

	

AS

BEGIN

	

	EXEC [MS].[DailyMetricFeed_Phase2]



DECLARE @StartDate DATE
DECLARE @runDate DATE
SET @StartDate = (SELECT    CONVERT(date,  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())  , 0)))

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
        WHERE   DATEVALUE + 1 <= DATEADD(m, DATEDIFF(m, 0, getdate()) + 1, 0)-1
      )
      
            INSERT INTO #EFFORTDATES
            SELECT  CONVERT(DATE,DATEVALUE) AS DATETODAY , DATENAME(W,DATEVALUE) AS NAME
            FROM    MYCTE 
            OPTION (MAXRECURSION 0)
            DELETE FROM #EFFORTDATES WHERE NAME IN ('Saturday','Sunday')




SELECT top 1 @rundate= DATETODAY FROM #EFFORTDATES ORDER BY SNO DESC 
--select @rundate
DROP TABLE #EFFORTDATES

If (CONVERT(DATE,@rundate)= CONVERT(DATE,getdate()))
	BEGIN

	--Step 1--Move Monthly Data to the respective table

				Truncate table [MS].[MAP_ProjectStage_Mapping_Monthly]

				Truncate table  [MS].[MAP_TicketSummary_Stage_Mapping_Monthly]

				Truncate table MS.[MetricstagingMonthlyDump_Outbound]

				Truncate table MS.[MetricMasterMonthlyDump_Ticketsummary_Outbound]
				-- Newly added Loadfactor Begin
				Truncate table MS.MetricstagingMonthlyDump_Outbound_ProjectSpecific

				Truncate table MS.MetricMasterMonthlyDump_Ticketsummary_Outbound_ProjectSpecific

				--Newly added Loadfactor End

				Insert INTO [MS].[MAP_ProjectStage_Mapping_Monthly]

				select * from [MS].[MAP_ProjectStage_Mapping] --where ESAProjectID in('1000019604','1000020649','1000160760')


				--select * from [MS].[MAP_TicketSummary_Stage_Mapping_Monthly]

				Insert INTO [MS].[MAP_TicketSummary_Stage_Mapping_Monthly]

				Select * from  [MS].[MAP_TicketSummary_Stage_Mapping] --where ESAProjectID in('1000019604','1000020649','1000160760')--where esaProjectID='1000107417' 

			-- Newly added Loadfactor Begin

				INSERT INTO  MS.[MetricstagingMonthlyDump_Outbound_ProjectSpecific]

				select * FROM MS.MPS_STAGING_TABLE_EFORM_VIEW Where  DN_MANDATORY in('Standard','Custom')
				 AND DN_METRICNAME='Load Factor'

				INSERT INTO   MS.[MetricMasterMonthlyDump_Ticketsummary_Outbound_ProjectSpecific]

				select * FROM MS.MPS_STAGING_TABLE_EFORM_VIEW Where  DN_MANDATORY in('Ticket Summary') 
				AND DN_METRICNAME='Load Factor'

				-- Newly added Loadfactor End




				INSERT INTO  MS.[MetricstagingMonthlyDump_Outbound]

				select * FROM [MS].[MPS_STAGING_TABLE_EFORM_VIEW] Where  DN_MANDATORY in('Standard','Custom')
				 AND DN_METRICNAME <>'Load Factor'


				INSERT INTO   MS.[MetricMasterMonthlyDump_Ticketsummary_Outbound]

				select * FROM [MS].[MPS_STAGING_TABLE_EFORM_VIEW] Where  DN_MANDATORY in('Ticket Summary')
				AND DN_METRICNAME <>'Load Factor'

				UPDATE MS.[MetricstagingMonthlyDump_Outbound]

				SET DN_METRICNAME = REPLACE(DN_METRICNAME,CHAR(160),CHAR(32))

				WHERE DN_METRICNAME like('%' +  CHAR(160) +'%')



				UPDATE MS.[MetricMasterMonthlyDump_Ticketsummary_Outbound]

				SET DN_METRICNAME = REPLACE(DN_METRICNAME,CHAR(160),CHAR(32))

				WHERE DN_METRICNAME like('%' +  CHAR(160) +'%')





				



	END

	Update [MS].[MAP_ProjectStage_Mapping]

				set IsDeleted=1

				where UniqueName not in(

				Select distinct DN_UNIQUEKEY

				from  [MS].[MetricstagingDailyDump]

				WHERE DN_MANDATORY in('Custom','Standard'))



				--Select distinct * from  [MS].[MetricstagingDailyDump] WHERE DN_MANDATORY in('Custom','Standard')

				--select * from Mainspring_MetricMasterDailyDump

				Update [MS].[MAP_TicketSummary_Stage_Mapping]

				set IsDeleted=1

				where UniqueName not in(

				Select  DN_UNIQUEKEY

				from  [MS].[MetricMasterDailyDump_Ticketsummary]

				WHERE DN_MANDATORY in('Ticket Summary'))


END



