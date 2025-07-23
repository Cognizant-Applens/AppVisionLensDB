/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--exec [MS].[GetBaseMeasureServiceWiseReport] '5407',4,'102018','metric report'
--exec [MS].[GetBaseMeasureServiceWiseReport] @ProjectID='11793',@FrequencyID=4,@ReportPeriod=62018, @RequiredSearchType='metric report'
--exec [MS].[GetBaseMeasureServiceWiseReport] @ProjectID='19986',@FrequencyID=4,@ReportPeriod=42018, @RequiredSearchType='metric report'
--exec [MS].[GetBaseMeasureServiceWiseReport] 22413,4,72018,'metric report'
CREATE PROCEDURE [MS].[GetBaseMeasureServiceWiseReport]
	@ProjectID INT,
	@FrequencyID INT,
	@ReportPeriod INT,
	@RequiredSearchType VARCHAR(50) -- 'metric report', 'ticket report'
AS
BEGIN
SET NOCOUNT ON;
DECLARE @MaxDate DATETIME
IF (@RequiredSearchType = 'metric report') BEGIN
	IF EXISTS (SELECT *	FROM MS.TRN_MonthlyJobStatus WHERE ReportingPeriod = @ReportPeriod	AND JobStatus = 4)
	BEGIN
		IF EXISTS(select * from MS.TRN_ProjectStaging_MonthlyBaseMeasure(NOLOCK) PBM
				INNER JOIN MS.MAP_ProjectStage_Mapping_Monthly(NOLOCK) PSM
						ON PBM.ProjectStageID = PSM.ID AND PSM.IsDeleted=0  
						WHERE PSM.ProjectID = @ProjectID
							AND PBM.ReportPeriodID = @ReportPeriod
							AND PBM.FrequencyID = @FrequencyID )
		BEGIN

						SELECT DISTINCT
						PSM.ESAProjectID AS ProjectID
						,CONVERT(NVARCHAR, PBM.MetricStartDate, 106) AS MetricStartDate
						,CONVERT(NVARCHAR, PBM.MetricEndDate, 106) AS MetricEndDate
						,s1.ServiceName
						,M1.MetricName
						,m2.MetricTypeDesc
						,MPM.MainspringPriorityName
						,MSC.MainspringSUPPORTCATEGORYName
						,PSM.M_TECHNOLOGY AS TechnologyLanguageNameShortDESC
						,B1.BaseMeasureName
						,pbm.BaseMeasureValue
						,SM.ServiceID
						,SM.MetricID
						,SM.BaseMeasureID
					FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure(NOLOCK) PBM
					INNER JOIN  MS.MAP_ProjectStage_Mapping_Monthly(NOLOCK) PSM
						ON PBM.ProjectStageID = PSM.ID and psm.IsDeleted=0
					INNER JOIN MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping(NOLOCK) SM
						ON SM.ServiceMetricBaseMeasureMapID = PSm.ServiceMetricBasemeasureMapID and sm.IsDeleted=0
					INNER JOIN MS.MAP_serviceOffering2withService_Mapping(NOLOCK) S2
						ON s2.ServiceID = SM.ServiceID
					INNER JOIN MS.MAS_serviceOffering2_Master(NOLOCK) S2M
						ON S2M.ServiceOffering2ID = S2.ServiceOffering2ID AND S2M.IsDeleted=0
					--INNER JOIN MAS.ServiceMaster(NOLOCK) S1
					INNER JOIN AVL.TK_MAS_Service(NOLOCK) S1
						ON S1.ServiceID = Sm.ServiceID AND S1.IsDeleted=0
					INNER JOIN MS.MAS_Metric_Master(NOLOCK) M1
						ON M1.MetricID = SM.MetricID AND M1.IsDeleted=0
					INNER JOIN MS.MAS_BaseMeasure_Master(NOLOCK) B1
						ON B1.BaseMeasureID = Sm.BaseMeasureID AND B1.IsDeleted=0
					INNER JOIN MS.MAS_MetricType_Master(NOLOCK) M2
						ON m2.MetricTypeID = M1.MetricTypeID AND M2.IsDeleted=0
					LEFT JOIN MS.MAS_Priority_Master(NOLOCK) MPM
						ON MPM.MainspringPriorityID = PSM.M_PRIORITYID AND MPM.IsDeleted=0
					LEFT JOIN MS.MAS_SUPPORTCATEGORY_Master(NOLOCK) MSC
						ON MSC.MainspringSUPPORTCATEGORYID = PSM.M_SUPPORTCATEGORY AND ISNULL(MSC.IsDeleted,0)=0
					--LEFT JOIN MS.MAS_TechnologyLanguage_Master(NOLOCK) TLM
					--	ON TLM.MainspringTechnologyLanguageName = PSM.M_TECHNOLOGY AND TLM.IsDeleted=0
					WHERE PSM.ProjectID = @ProjectID
					AND PBM.ReportPeriodID = @ReportPeriod
					AND PBM.FrequencyID = @FrequencyID
		END
		ELSE
		BEGIN

			
			SET @MaxDate = (select MAX( PBM.UpdatedDate) from MS.TRN_ProjectStaging_MonthlyBaseMeasure_SnapshotMONTHLYDATAPUSH PBM
							INNER JOIN MS.MAP_ProjectStage_Mapping_Monthly(NOLOCK) PSM
								ON PBM.ProjectStageID = PSM.ID AND psm.IsDeleted=0
							WHERE PSM.ProjectID = @ProjectID
								AND PBM.ReportPeriodID = @ReportPeriod
								AND PBM.FrequencyID = @FrequencyID )
			
				SELECT DISTINCT
						PSM.ESAProjectID AS ProjectID
						,CONVERT(NVARCHAR, PBM.MetricStartDate, 106) AS MetricStartDate
						,CONVERT(NVARCHAR, PBM.MetricEndDate, 106) AS MetricEndDate
						,s1.ServiceName
						,M1.MetricName
						,m2.MetricTypeDesc
						,MPM.MainspringPriorityName
						,MSC.MainspringSUPPORTCATEGORYName
						,PSM.M_TECHNOLOGY AS TechnologyLanguageNameShortDESC
						,B1.BaseMeasureName
						,pbm.BaseMeasureValue
						,SM.ServiceID
						,SM.MetricID
						,SM.BaseMeasureID
					FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure_SnapshotMONTHLYDATAPUSH(NOLOCK) PBM
					INNER JOIN MS.MAP_ProjectStage_Mapping_Monthly(NOLOCK) PSM
						ON PBM.ProjectStageID = PSM.ID AND PSM.IsDeleted=0
					INNER JOIN MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping(NOLOCK) SM
						ON SM.ServiceMetricBaseMeasureMapID = PSm.ServiceMetricBasemeasureMapID and sm.IsDeleted=0
					INNER JOIN MS.MAP_serviceOffering2withService_Mapping(NOLOCK) S2
						ON s2.ServiceID = SM.ServiceID
					INNER JOIN MS.MAS_serviceOffering2_Master(NOLOCK) S2M
						ON S2M.ServiceOffering2ID = S2.ServiceOffering2ID AND S2M.IsDeleted=0
					INNER JOIN AVL.TK_MAS_Service(NOLOCK) S1
						ON S1.ServiceID = Sm.ServiceID AND S1.IsDeleted=0
					INNER JOIN MS.MAS_Metric_Master(NOLOCK) M1
						ON M1.MetricID = SM.MetricID AND M1.IsDeleted=0
					INNER JOIN MS.MAS_BaseMeasure_Master(NOLOCK) B1
						ON B1.BaseMeasureID = Sm.BaseMeasureID AND B1.IsDeleted=0
					INNER JOIN MS.MAS_MetricType_Master(NOLOCK) M2
						ON m2.MetricTypeID = M1.MetricTypeID AND M2.IsDeleted=0
					LEFT JOIN MS.MAS_Priority_Master(NOLOCK) MPM
						ON MPM.MainspringPriorityID = PSM.M_PRIORITYID AND MPM.IsDeleted=0
					LEFT JOIN MS.MAS_SUPPORTCATEGORY_Master(NOLOCK) MSC
						ON MSC.MainspringSUPPORTCATEGORYID = PSM.M_SUPPORTCATEGORY AND ISNULL(MSC.IsDeleted,0)=0
					--LEFT JOIN MS.MAS_TechnologyLanguage_Master(NOLOCK) TLM
					--	ON TLM.MainspringTechnologyLanguageName = PSM.M_TECHNOLOGY AND TLM.IsDeleted=0
					WHERE PSM.ProjectID = @ProjectID
					AND PBM.ReportPeriodID = @ReportPeriod
					AND PBM.FrequencyID = @FrequencyID
					AND CONVERT(DATE,PBM.UpdatedDate) = CONVERT(DATE,@MaxDate)
		END
		
		
END 
	ELSE 
		BEGIN

			SELECT DISTINCT
				 PSM.ESAProjectID AS ProjectID
				,CONVERT(NVARCHAR, PBM.MetricStartDate, 106) AS MetricStartDate
				,CONVERT(NVARCHAR, PBM.MetricEndDate, 106) AS MetricEndDate
				,s1.ServiceName
				,M1.MetricName
				,m2.MetricTypeDesc
				,MPM.MainspringPriorityName
				,MSC.MainspringSUPPORTCATEGORYName
				,PSM.M_TECHNOLOGY AS TechnologyLanguageNameShortDESC
				,B1.BaseMeasureName
				,pbm.BaseMeasureValue
				,SM.ServiceID
				,SM.MetricID
				,SM.BaseMeasureID
			FROM MS.TRN_ProjectStaging_TillDateBaseMeasure(NOLOCK) PBM
			INNER JOIN MS.MAP_ProjectStage_Mapping(NOLOCK) PSM
				ON PBM.ProjectStageID = PSM.ID AND PSM.IsDeleted=0
			INNER JOIN MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping(NOLOCK) SM
				ON SM.ServiceMetricBaseMeasureMapID = PSm.ServiceMetricBasemeasureMapID and sm.IsDeleted=0
			INNER JOIN MS.MAP_serviceOffering2withService_Mapping(NOLOCK) S2
				ON s2.ServiceID = SM.ServiceID
			INNER JOIN MS.MAS_serviceOffering2_Master(NOLOCK) S2M
				ON S2M.ServiceOffering2ID = S2.ServiceOffering2ID AND S2M.IsDeleted=0
			INNER JOIN AVL.TK_MAS_Service(NOLOCK) S1
				ON S1.ServiceID = Sm.ServiceID AND S1.IsDeleted=0
			INNER JOIN MS.MAS_Metric_Master(NOLOCK) M1
				ON M1.MetricID = SM.MetricID AND M1.IsDeleted=0
			INNER JOIN MS.MAS_BaseMeasure_Master(NOLOCK) B1
				ON B1.BaseMeasureID = Sm.BaseMeasureID AND B1.IsDeleted=0
			INNER JOIN MS.MAS_MetricType_Master(NOLOCK) M2
				ON m2.MetricTypeID = M1.MetricTypeID AND M2.IsDeleted=0
			LEFT JOIN MS.MAS_Priority_Master(NOLOCK) MPM
				ON MPM.MainspringPriorityID = PSM.M_PRIORITYID AND MPM.IsDeleted=0
			LEFT JOIN MS.MAS_SUPPORTCATEGORY_Master(NOLOCK) MSC
				ON MSC.MainspringSUPPORTCATEGORYID = PSM.M_SUPPORTCATEGORY AND ISNULL(MSC.IsDeleted,0)=0
			--LEFT JOIN MS.MAS_TechnologyLanguage_Master(NOLOCK) TLM
			--	ON TLM.MainspringTechnologyLanguageName = PSM.M_TECHNOLOGY AND TLM.IsDeleted=0
			WHERE PSM.ProjectID = @ProjectID
			AND PBM.ReportPeriodID = @ReportPeriod
			AND PBM.FrequencyID = @FrequencyID
		END
	END
ELSE IF (@RequiredSearchType = 'ticket report')
	BEGIN
	IF EXISTS (SELECT * FROM MS.TRN_MonthlyJobStatus WHERE ReportingPeriod = @ReportPeriod	AND JobStatus = 4)
		BEGIN
			IF EXISTS(SELECT * FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary(NOLOCK) PBM
						INNER JOIN MS.MAP_TicketSummary_Stage_Mapping_Monthly(NOLOCK) PSM
							ON PBM.ProjectStageID = PSM.ID AND PSM.IsDeleted=0
							WHERE PSM.ProjectID = @ProjectID
							AND PBM.ReportPeriodID = @ReportPeriod
							AND PBM.FrequencyID = @FrequencyID)
			BEGIN
							SELECT DISTINCT
							PSM.ESAProjectID AS ProjectID
							,CONVERT(NVARCHAR, PBM.MetricStartDate, 106) AS MetricStartDate
							,CONVERT(NVARCHAR, PBM.MetricEndDate, 106) AS MetricEndDate
							,s1.ServiceName
							,MPM.MainspringPriorityName
							,MSC.MainspringSUPPORTCATEGORYName
							,TSM.TicketSummaryBaseName
							,TSM.TicketSummaryBaseID
							,pbm.TicketSummaryValue
							,pSM.ServiceID


						FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary(NOLOCK) PBM
						INNER JOIN MS.MAP_TicketSummary_Stage_Mapping_Monthly(NOLOCK) PSM
							ON PBM.ProjectStageID = PSM.ID AND PSM.IsDeleted=0
						INNER JOIN MS.MAS_TicketSummaryBase_Master TSM
							ON TSM.TicketSummaryBaseID = PSM.TicketSummaryBaseID AND TSM.IsDeleted=0
						INNER JOIN Ms.MAP_serviceOffering2withService_Mapping(NOLOCK) S2
							ON s2.ServiceID = PSM.ServiceID
						INNER JOIN MS.MAS_serviceOffering2_Master(NOLOCK) S2M
							ON S2M.ServiceOffering2ID = S2.ServiceOffering2ID AND S2M.IsDeleted=0
						INNER JOIN AVL.TK_MAS_Service(NOLOCK) S1
							ON PSM.ServiceID = s1.ServiceID AND S1.IsDeleted=0
						LEFT JOIN MS.MAS_Priority_Master(NOLOCK) MPM
							ON MPM.MainspringPriorityID = PSM.M_PRIORITYID AND MPM.IsDeleted=0
						LEFT JOIN MS.MAS_SUPPORTCATEGORY_Master(NOLOCK) MSC
							ON MSC.MainspringSUPPORTCATEGORYID = PSM.M_SUPPORTCATEGORY AND ISNULL(MSC.IsDeleted,0)=0
						WHERE PSM.ProjectID = @ProjectID
						AND PBM.ReportPeriodID = @ReportPeriod
						AND PBM.FrequencyID = @FrequencyID
				
			END
			ELSE
			BEGIN
				
					SET @MaxDate = (select MAX( PBM.UpdatedDate) from MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary_SnapshotMONTHLYDATA(NOLOCK) PBM
						INNER JOIN MS.MAP_TicketSummary_Stage_Mapping_Monthly(NOLOCK) PSM
							ON PBM.ProjectStageID = PSM.ID AND PSM.IsDeleted=0
							WHERE PSM.ProjectID = @ProjectID
						AND PBM.ReportPeriodID = @ReportPeriod
						AND PBM.FrequencyID = @FrequencyID )
						SELECT DISTINCT
							PSM.ESAProjectID AS ProjectID
							,CONVERT(NVARCHAR, PBM.MetricStartDate, 106) AS MetricStartDate
							,CONVERT(NVARCHAR, PBM.MetricEndDate, 106) AS MetricEndDate
							,s1.ServiceName
							,MPM.MainspringPriorityName
							,MSC.MainspringSUPPORTCATEGORYName
							,TSM.TicketSummaryBaseName
							,TSM.TicketSummaryBaseID
							,pbm.TicketSummaryValue
							,pSM.ServiceID


						FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary_SnapshotMONTHLYDATA(NOLOCK) PBM
						INNER JOIN MS.MAP_TicketSummary_Stage_Mapping_Monthly(NOLOCK) PSM
							ON PBM.ProjectStageID = PSM.ID AND PSM.IsDeleted=0
						INNER JOIN MS.MAS_TicketSummaryBase_Master TSM
							ON TSM.TicketSummaryBaseID = PSM.TicketSummaryBaseID AND TSM.IsDeleted=0
						INNER JOIN MS.MAP_serviceOffering2withService_Mapping(NOLOCK) S2
							ON s2.ServiceID = PSM.ServiceID
						INNER JOIN MS.MAS_serviceOffering2_Master(NOLOCK) S2M
							ON S2M.ServiceOffering2ID = S2.ServiceOffering2ID AND S2M.IsDeleted=0
						INNER JOIN AVL.TK_MAS_Service(NOLOCK) S1
							ON PSM.ServiceID = s1.ServiceID AND S1.IsDeleted=0
						LEFT JOIN MS.MAS_Priority_Master(NOLOCK) MPM
							ON MPM.MainspringPriorityID = PSM.M_PRIORITYID AND MPM.IsDeleted=0
						LEFT JOIN MS.MAS_SUPPORTCATEGORY_Master(NOLOCK) MSC
							ON MSC.MainspringSUPPORTCATEGORYID = PSM.M_SUPPORTCATEGORY AND ISNULL(MSC.IsDeleted,0)=0
						WHERE PSM.ProjectID = @ProjectID
						AND PBM.ReportPeriodID = @ReportPeriod
						AND PBM.FrequencyID = @FrequencyID
						AND CONVERT(DATE,PBM.UpdatedDate) = CONVERT(DATE,@MaxDate)
			
			END
			

	END 
	ELSE 
		BEGIN

			SELECT DISTINCT
				PSM.ESAProjectID AS ProjectID
				,CONVERT(NVARCHAR, PBM.MetricStartDate, 106) AS MetricStartDate
				,CONVERT(NVARCHAR, PBM.MetricEndDate, 106) AS MetricEndDate
				,s1.ServiceName
				,MPM.MainspringPriorityName
				,MSC.MainspringSUPPORTCATEGORYName
				,TSM.TicketSummaryBaseName
				,TSM.TicketSummaryBaseID
				,pbm.TicketSummaryValue
				,pSM.ServiceID


			FROM MS.TRN_ProjectStaging_TillDateBaseMeasure_TicketSummary(NOLOCK) PBM
			INNER JOIN MS.MAP_TicketSummary_Stage_Mapping(NOLOCK) PSM
				ON PBM.ProjectStageID = PSM.ID
			INNER JOIN MS.MAS_TicketSummaryBase_Master TSM
				ON TSM.TicketSummaryBaseID = PSM.TicketSummaryBaseID AND TSM.IsDeleted=0
			INNER JOIN MS.MAP_serviceOffering2withService_Mapping(NOLOCK) S2
				ON s2.ServiceID = PSM.ServiceID
			INNER JOIN MS.MAS_serviceOffering2_Master(NOLOCK) S2M
				ON S2M.ServiceOffering2ID = S2.ServiceOffering2ID AND S2M.IsDeleted=0
			INNER JOIN AVL.TK_MAS_Service(NOLOCK) S1
				ON PSM.ServiceID = s1.ServiceID AND S1.IsDeleted=0
			LEFT JOIN MS.MAS_Priority_Master(NOLOCK) MPM
				ON MPM.MainspringPriorityID = PSM.M_PRIORITYID AND MPM.IsDeleted=0
			LEFT JOIN MS.MAS_SUPPORTCATEGORY_Master(NOLOCK) MSC
				ON MSC.MainspringSUPPORTCATEGORYID = PSM.M_SUPPORTCATEGORY AND ISNULL(MSC.IsDeleted,0)=0
			WHERE PSM.ProjectID = @ProjectID
			AND PBM.ReportPeriodID = @ReportPeriod
			AND PBM.FrequencyID = @FrequencyID
	
		END
	END
END

