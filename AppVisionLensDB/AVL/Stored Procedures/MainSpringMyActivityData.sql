/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [AVL].[MainSpringMyActivityData]
AS
BEGIN
BEGIN TRY


	SET NOCOUNT ON;  
	DECLARE @ReportPeriodId NVARCHAR(50);
	SET @ReportPeriodId = (SELECT  CONCAT(FORMAT(GetDate(), 'MM')-1,FORMAT(GetDate(), 'yyyy'))) ;
	SELECT ProjectId, ReportPeriodId, 0 as TotalCount, 0 as CompletedCount
	INTO #basemeasure
	FROM MS.TRN_BaseMeasureUserDefinedData (NOLOCK)
	WHERE ReportPeriodId = @ReportPeriodId
	GROUP BY ReportPeriodId,ProjectId

	SELECT bm.ProjectId,bm.ReportPeriodid,Count(bm.ReportPeriodid) as totalcount
	INTO #bmtotalcount
	FROM #basemeasure bm
	JOIN MS.TRN_BaseMeasureUserDefinedData(NOLOCK) bmu
	ON bmu.ReportPeriodid = bm.ReportPeriodid and bmu.projectId = bm.projectId
	GROUP BY bm.ProjectId,bm.ReportPeriodid

	UPDATE bm SET bm.TotalCount = bmu.totalcount
	FROM #basemeasure bm
	JOIN #bmtotalcount bmu
	ON bmu.ReportPeriodid = bm.ReportPeriodid and bmu.projectId = bm.projectId

	SELECT bm.ProjectId,bm.ReportPeriodid,Count(bm.ReportPeriodid) as completedcount
	INTO #bmcompletedcount
	FROM #basemeasure bm
	JOIN MS.TRN_BaseMeasureUserDefinedData(nolock) bmu
	ON bmu.ReportPeriodid = bm.ReportPeriodid and bmu.projectId = bm.projectId
	WHERE Isnull(BaseMeasureValue,'')<>''
	GROUP BY bm.ProjectId,bm.ReportPeriodid

	UPDATE bm SET bm.CompletedCount = bmu.CompletedCount
	FROM #basemeasure bm
	JOIN #bmcompletedcount bmu
	ON bmu.ReportPeriodid = bm.ReportPeriodid AND bmu.projectId = bm.projectId

	SELECT *,TotalCount-CompletedCount AS [Difference] 
	INTO #finaldata
	FROM #basemeasure

	SELECT PM.ProjectId,fd.ReportPeriodId,
	   'Base measures has not been submitted for ' + ReportingPeriodDESC + ' for following project '+
	   RTRIM(PM.ESAProjectID) + '-' + PM.ProjectName   
		 +' .Please click here to review and submit the base measures for metric computation'  
		   AS 'TaskDetails', LM.HcmSupervisorId 
	FROM #finaldata  fd
	JOIN [MS].[TRN_MonthlyJobStatus] (NOLOCK) MJS
	ON MJS.ReportingPeriod = fd.ReportPeriodId
	JOIN AVL.Mas_ProjectMaster (NOLOCK) PM
	ON PM.ProjectId = FD.ProjectId and PM.Isdeleted = 0
	JOIN AVL.MAS_LoginMaster (NOLOCK) LM
	ON LM.ProjectId = PM.ProjectId AND LM.Isdeleted = 0
	WHERE [Difference] <> 0 

SET NOCOUNT OFF;
 END TRY  

   BEGIN CATCH  

              DECLARE @ErrorMessage VARCHAR(MAX);
              SELECT @ErrorMessage = ERROR_MESSAGE() 
              EXEC AVL_InsertError '[AVL].[MainSpringMyActivityData]', @ErrorMessage, 0, 0

              RETURN @@ERROR
       
   END CATCH 
END
