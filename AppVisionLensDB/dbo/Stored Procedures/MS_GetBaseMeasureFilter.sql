/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--exec [dbo].[MS_GetBaseMeasureFilter] 22413,'','','reporting period basemeasure',1
CREATE PROCEDURE [dbo].[MS_GetBaseMeasureFilter]
	@ProjectID BIGINT,
	@FrequencyID INT=NULL,
	@ServiceIDs VARCHAR(500)=NULL,
	@RequiredFilterType VARCHAR(50), -- 'frequency', 'reporting period', 'services', 'metrics', 'mainspring availability'
	@ServiceFilter INT
AS
BEGIN
SET NOCOUNT ON;

IF (@RequiredFilterType='frequency')
	BEGIN
		SELECT	FrequencyID	,FrequencyName
		FROM MS.MAS_Frequency_Master (NOLOCK)
		WHERE IsDeleted = 0
	END
ELSE IF (@RequiredFilterType='reporting period basemeasure')
	BEGIN
		--SELECT JobID AS RowIndex,ReportingPeriod AS ReportPeriodID, ReportingPeriodDESC AS ReportPeriod , FrequencyID 
		--FROM MS.TRN_MonthlyJobStatus WHERE JobStatus IN(2,3) ORDER BY JobID DESC
		SELECT JobID AS RowIndex,ReportingPeriod AS ReportPeriodID, ReportingPeriodDESC AS ReportPeriod , FrequencyID 
		FROM MS.TRN_MonthlyJobStatus (NOLOCK) WHERE JobStatus IN(2,3) ORDER BY JobID DESC
	END
ELSE IF (@RequiredFilterType='reporting period')
	BEGIN
		--SELECT TOP 6 JobID AS RowIndex,ReportingPeriod AS ReportPeriodID, ReportingPeriodDESC AS ReportPeriod , FrequencyID FROM MS.TRN_MonthlyJobStatus WHERE JobStatus IN(2,3,4,5) ORDER BY JobID DESC
			SELECT TOP 6 JobID AS RowIndex,ReportingPeriod AS ReportPeriodID, ReportingPeriodDESC AS ReportPeriod , FrequencyID 
			FROM MS.TRN_MonthlyJobStatus (NOLOCK) WHERE JobStatus IN(2,3,4,5) ORDER BY JobID DESC
		

	END
ELSE IF (@RequiredFilterType='services')
	BEGIN
	IF(@ServiceFilter = 1)
	BEGIN
	SELECT DISTINCT
			SM.ServiceID
			,SM.ServiceName
		FROM AVL.MAS_ProjectMaster PM (NOLOCK)
		INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSAM (NOLOCK)
			ON PM.ProjectID = PSAM.ProjectID
		INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM (NOLOCK)
			ON  PSAM.ServiceMapID =SAM.ServiceMappingID
		INNER JOIN AVL.TK_MAS_Service SM (NOLOCK)
			ON SM.ServiceID = SAM.ServiceID
			AND SM.ServiceType = 4  
		WHERE   PSAM.IsMainspringData='Y' AND PSAM.IsDeleted=0 AND PM.ProjectID = @ProjectID 
		AND ISNULL(PSAM.IsHidden,0) <> 1
	END
	ELSE
	BEGIN
		SELECT DISTINCT
			SM.ServiceID
			,SM.ServiceName
		FROM AVL.MAS_ProjectMaster PM (NOLOCK)
		INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSAM (NOLOCK)
			ON PM.ProjectID = PSAM.ProjectID
		INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM (NOLOCK)
			ON  PSAM.ServiceMapID =SAM.ServiceMappingID
		INNER JOIN AVL.TK_MAS_Service SM (NOLOCK)
			ON SM.ServiceID = SAM.ServiceID
			AND SM.ServiceType = 4  
		WHERE   PSAM.IsMainspringData='Y' AND PSAM.IsDeleted=0 AND PM.ProjectID = @ProjectID
	END
		
	END
ELSE IF (@RequiredFilterType='metrics')
	BEGIN
		--IF (@ServiceIDs IS NULL)
		--BEGIN
			SELECT DISTINCT MMM.MetricID, MMM.MetricName, MUM.UOM_DESC, MUM.UOM_DataType,MSMBMSMM.ServiceID FROM MS.MAS_Metric_Master MMM (NOLOCK)
			INNER JOIN MS.MAS_UOM_Master MUM (NOLOCK) ON MMM.UOMID=MUM.UOMID
			INNER JOIN MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping MSMBMSMM  (NOLOCK)ON MMM.MetricID=MSMBMSMM.MetricID
			INNER JOIN MS.MAP_ProjectStage_Mapping MPSM (NOLOCK) ON
			MPSM.ServiceMetricBasemeasureMapID=MSMBMSMM.ServiceMetricBaseMeasureMapID
			WHERE MMM.FrequencyID=@FrequencyID AND MMM.IsDeleted=0 AND MPSM.ProjectID=@ProjectID

		--END
		--ELSE
		--BEGIN
		--	SELECT DISTINCT MMM.MetricID, MMM.MetricName, MUM.UOM_DESC, MUM.UOM_DataType,MSMBMSMM.ServiceID FROM MAS.Mainspring_Metric_Master MMM
		--	INNER JOIN MAS.Mainspring_UOM_Master MUM ON MMM.UOMID=MUM.UOMID
		--	INNER JOIN MAP.Mainspring_ServiceMetricBaseMeasureForStandardMetric_Mapping MSMBMSMM ON MMM.MetricID=MSMBMSMM.MetricID
		--	WHERE MMM.FrequencyID=@FrequencyID AND MMM.IsDeleted=0 AND MSMBMSMM.ServiceID IN (SELECT * FROM dbo.Split(@ServiceIDs, ','))
		--END
	END
ELSE IF (@RequiredFilterType='mainspring availability')
	BEGIN
	
	DECLARE @MainspringConfigured VARCHAR(10)
	DECLARE @SUPPORTCATEGORYCount INT
	DECLARE @IsODCRestricted VARCHAR(10)

	select @MainspringConfigured=IsMainSpringConfigured from AVL.MAS_ProjectMaster (NOLOCK)where ProjectID = @ProjectID
	select @IsODCRestricted=ISNULL(IsODCRestricted,'N') from AVL.MAS_ProjectMaster (NOLOCK) where ProjectID = @ProjectID
	select @SUPPORTCATEGORYCount=COUNT(SCM.ESAProjectID) from MS.MAP_ProjectSUPPORTCATEGORY_Mapping SCM(NOLOCK)
	INNER JOIN avl.MAS_ProjectMaster PM (NOLOCK) ON PM.EsaProjectID=SCM.ESAProjectID
	WHERE
	PM.ProjectID=@ProjectID
	
	SELECT @MainspringConfigured AS MainspringConfigured
	, @SUPPORTCATEGORYCount AS SupportCategoryCount,@IsODCRestricted AS IsODCRestricted
	
	END	
	Set NOCOUNT OFF;
END
