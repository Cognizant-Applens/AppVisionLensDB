/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [MS].[Mainspring_GetBaseMeasureForProjectSpecificMetrics]    
(  
@ProjectID  BIGINT,  
@StartDate  nvarchar(30),  
@EndDate  nvarchar(30)  
)    
AS    
BEGIN   
SET NOCOUNT ON;
--SELECT EsaProjectID,SUM(Hours) AS BaseMeasure  FROM [AppVisionLensOffline].[RPT].[TM_TRN_TimesheetDetail](nolock)   
--WHERE ProjectID = @ProjectID AND ServiceID IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)   
--AND TimesheetDate BETWEEN @StartDate AND @EndDate  
--GROUP BY EsaProjectID  
  
  
DECLARE @EsaProjectID VARCHAR(100);  
  
set @EsaProjectID=(select TOP 1 EsaProjectID from AVL.MAS_ProjectMaster(NOLOCK)   
     WHERE ProjectID=@ProjectID AND ISNULL(IsDeleted,0)=0)  
  
  -- Get timesheet for the particular dates
SELECT * INTO #AVL_TM_PRJ_Timesheet FROM AVL.TM_PRJ_Timesheet WITH(NOLOCK)  WHERE ProjectID=@ProjectID  
AND TimesheetDate BETWEEN @StartDate AND @EndDate  
  
  -- Get timesheet details for the Timesheets
SELECT * INTO #AVL_TM_TRN_TimesheetDetail FROM AVL.TM_TRN_TimesheetDetail WITH(NOLOCK) WHERE TimesheetId IN(  
SELECT  TIMESHEETID from #AVL_TM_PRJ_Timesheet) AND IsDeleted=0  
  
  -- Get Holiday and Compoff timesheet details
  select * INTO #NonDeliveryTimesheetDetail from #AVL_TM_TRN_TimesheetDetail WITH(NOLOCK) where  TimesheetId IN(  
SELECT  TIMESHEETID from #AVL_TM_PRJ_Timesheet  WITH(NOLOCK)) AND IsDeleted=0  and (ServiceId in (0) and ActivityId in (1,9))
  
  -- delete the Holiday and Compoff timesheet details in #AVL_TM_TRN_TimesheetDetail table

  DELETE FROM #AVL_TM_TRN_TimesheetDetail WHERE TimeSheetDetailId IN (
  SELECT TimeSheetDetailId FROM #NonDeliveryTimesheetDetail  WITH(NOLOCK)
  )

  -- Service id filter is commented. We have to calculate all services

SELECT @EsaProjectID AS EsaProjectID,SUM(TD.Hours) AS BaseMeasure FROM #AVL_TM_PRJ_Timesheet T   WITH(NOLOCK)
INNER JOIN #AVL_TM_TRN_TimesheetDetail TD  WITH(NOLOCK)
ON T.TimesheetId=TD.TimesheetId WHERE T.ProjectID=@ProjectID  
AND TD.IsDeleted=0 
--AND  
--TD.ServiceID IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)   
AND T.TimesheetDate BETWEEN @StartDate AND @EndDate  
GROUP BY T.ProjectID  
  SET NOCOUNT OFF;
  
End  
  
  
--SELECT * FROM [MS].[TRN_ProjectStaging_MonthlyBaseMeasure_LoadFactor]  
  