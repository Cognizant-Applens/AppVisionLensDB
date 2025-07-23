/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--exec [MS].[GetTicketSummaryBaseMeasureFilter] @ProjectID='11489', @RequiredFilterType='frequency'
--exec [MS].[GetTicketSummaryBaseMeasureFilter] @ProjectID='19100', @RequiredFilterType='reporting period', @FrequencyID=4
--exec [MS].[GetTicketSummaryBaseMeasureFilter] @ProjectID='19100', @RequiredFilterType='services'
--exec [MS].[GetTicketSummaryBaseMeasureFilter] @ProjectID='11489', @RequiredFilterType='services', @ServiecFilter=0
--exec [MS].[GetTicketSummaryBaseMeasureFilter] @ProjectID='19100', @RequiredFilterType='mainspring availability'

CREATE PROCEDURE [MS].[GetTicketSummaryBaseMeasureFilter]
	@ProjectID INT,
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
		FROM MS.MAS_Frequency_Master
		WHERE IsDeleted = 0
	END
ELSE IF (@RequiredFilterType='reporting period basemeasure')
	BEGIN
		SELECT JobID AS RowIndex,ReportingPeriod AS ReportPeriodID, ReportingPeriodDESC AS ReportPeriod , FrequencyID FROM MS.TRN_MonthlyJobStatus WHERE JobStatus IN(2,3) ORDER BY JobID DESC
	END
ELSE IF (@RequiredFilterType='reporting period')
	BEGIN
		SELECT TOP 2 JobID AS RowIndex,ReportingPeriod AS ReportPeriodID, ReportingPeriodDESC AS ReportPeriod , FrequencyID FROM MS.TRN_MonthlyJobStatus WHERE JobStatus IN(2,3,4,5) ORDER BY JobID DESC
	END
ELSE IF (@RequiredFilterType='services')
	BEGIN
		IF(@ServiceFilter = 1)
		BEGIN
				SELECT DISTINCT
			SM.ServiceID
			,SM.ServiceName
		FROM AVL.MAS_ProjectMaster PM
		INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSAM
			ON PM.ProjectID = PSAM.ProjectID
		INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM
			ON  PSAM.ServiceMapID =SAM.ServiceMappingID
		INNER JOIN AVL.TK_MAS_Service SM
			ON SM.ServiceID = SAM.ServiceID
			AND SM.ServiceType = 4 AND PSAM.IsMainspringData='Y' AND SM.ServiceID IN(1,4,16,3,11)
		WHERE PM.ProjectID = @ProjectID AND PSAM.IsHidden <> 1
		END
		ELSE
		BEGIN
				SELECT DISTINCT
			SM.ServiceID
			,SM.ServiceName
		FROM AVL.MAS_ProjectMaster PM
		INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSAM
			ON PM.ProjectID = PSAM.ProjectID
		INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM
			ON  PSAM.ServiceMapID =SAM.ServiceMappingID
		INNER JOIN AVL.TK_MAS_Service SM
			ON SM.ServiceID = SAM.ServiceID
			AND SM.ServiceType = 4 AND PSAM.IsMainspringData='Y' AND SM.ServiceID IN(1,4,16,3,11)
		WHERE PM.ProjectID = @ProjectID
		END
		
	END
ELSE IF (@RequiredFilterType='metrics')
	BEGIN
		--IF (@ServiceIDs IS NULL)
		--BEGIN
			SELECT DISTINCT MMM.MetricID, MMM.MetricName, MUM.UOM_DESC, MUM.UOM_DataType,MSMBMSMM.ServiceID 
			FROM MS.MAS_Metric_Master MMM
			INNER JOIN MS.MAS_UOM_Master MUM ON MMM.UOMID=MUM.UOMID
			INNER JOIN MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping MSMBMSMM ON MMM.MetricID=MSMBMSMM.MetricID
			INNER JOIN  MS.MAP_ProjectStage_Mapping MPSM ON
			MPSM.ServiceMetricBasemeasureMapID=MSMBMSMM.ServiceMetricBaseMeasureMapID
			WHERE MMM.FrequencyID=@FrequencyID AND MMM.IsDeleted=0 
			--AND SM.ServiceID IN(1,4,16,3,11)
			--AND MPSM.ProjectID=@ProjectID
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
	
	select @MainspringConfigured=IsMainSpringConfigured from AVL.MAS_ProjectMaster where ProjectID = @ProjectID
	
	select @SUPPORTCATEGORYCount=COUNT(SCM.ESAProjectID) from MS.MAP_ProjectSUPPORTCATEGORY_Mapping SCM
	INNER JOIN AVL.MAS_ProjectMaster PM ON PM.EsaProjectID=SCM.ESAProjectID
	WHERE
	PM.ProjectID=@ProjectID
	
	SELECT @MainspringConfigured AS MainspringConfigured, @SUPPORTCATEGORYCount AS SupportCategoryCount
	
	END	
END


