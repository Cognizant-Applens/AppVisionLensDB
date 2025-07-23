/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [dbo].[MS.GetAllBaseMeasureProjectwiseSearch]
	@ProjectID INT,
	@FrequencyID INT=NULL,
	@ServiceIDs VARCHAR(500)=NULL,
	@MetricsIDs VARCHAR(max)=NULL,
	@ReportFrequencyID INT=NULL
AS
BEGIN
SET NOCOUNT ON;

	BEGIN

	select distinct sm.ServiceID AS ServiceID,
					s.ServiceName AS ServiceName,
					m.MetricID AS MetricID,
					m.MetricName AS MetricName,
					b.BaseMeasureID AS BaseMeasureID,
					b.BaseMeasureName AS BaseMeasureName,
					pm.MainspringPriorityID AS PRIORITYID,
					pm.MainspringPriorityName AS MainspringPriorityName,
					scm.MainspringSUPPORTCATEGORYID AS SUPPORTCATEGORY,
					scm.MainspringSUPPORTCATEGORYName AS MainspringSUPPORTCATEGORYName,
					CASE  WHEN ps.M_TECHNOLOGY IS NOT NULL AND ps.M_TECHNOLOGY !='' THEN ps.M_TECHNOLOGY
						 ELSE NULL
						END as TECHNOLOGY,
					b.UOMID AS UOMID,u.UOM_DESC AS UOM_DESC, 
					u.UOM_DataType AS UOM_DataType,
					b.BaseMeasureTypeID AS BaseMeasureTypeID,
					'' AS BaseMeasureValue,
					@FrequencyID AS FrequencyID,
					@ReportFrequencyID AS ReportPeriodID,
					@ProjectID AS ProjectID
			INTO #StagingData
			 from MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping sm
			inner join MS.MAP_ProjectStage_Mapping ps on sm.ServiceMetricBaseMeasureMapID=ps.ServiceMetricBasemeasureMapID
			inner join AVL.TK_MAS_Service s on sm.ServiceID=s.ServiceID
			inner join MS.MAS_Metric_Master m on sm.MetricID=m.MetricID
			inner join MS.MAS_BaseMeasure_Master b on sm.BaseMeasureID=b.BaseMeasureID
			inner join MS.MAS_UOM_Master u on b.UOMID=u.UOMID
			LEFT JOIN MS.MAS_Priority_Master (NOLOCK) pm on ps.M_PRIORITYID=pm.MainspringPriorityID
			LEFT JOIN MS.MAS_SUPPORTCATEGORY_Master (NOLOCK) scm on ps.M_SUPPORTCATEGORY=scm.MainspringSUPPORTCATEGORYID

			where 
			--sm.ServiceMetricBaseMeasureMapID <=287
			ps.ProjectID=@ProjectID AND B.IsDeleted=0 AND m.FrequencyID=@FrequencyID 
			AND b.BaseMeasureID NOT IN(208,209) AND ps.IsDeleted=0 and sm.isdeleted=0
			order by sm.ServiceID,b.BaseMeasureID
			
			UPDATE MS.TRN_ManualOverallBaseMeasureData SET Priority=NULL
			WHERE Priority='' and  ProjectID=@ProjectID and ReportPeriodID=@ReportFrequencyID
			UPDATE MS.TRN_ManualOverallBaseMeasureData SET SUPPORTCATEGORY=NULL
			WHERE SUPPORTCATEGORY='' and  ProjectID=@ProjectID and ReportPeriodID=@ReportFrequencyID
			UPDATE MS.TRN_ManualOverallBaseMeasureData SET TECHNOLOGY=NULL
			WHERE TECHNOLOGY='' and  ProjectID=@ProjectID and ReportPeriodID=@ReportFrequencyID

			SELECT distinct 
			T.ServiceID,T.ServiceName,T.MetricID,T.MetricName,T.BaseMeasureID,T.BaseMeasureName,
			T.PRIORITYID,T.MainspringPriorityName,T.SUPPORTCATEGORY,T.MainspringSUPPORTCATEGORYName,
			T.TECHNOLOGY,T.UOMID,T.UOM_DESC,T.UOM_DataType,T.BaseMeasureTypeID,
			U.BaseMeasureValue
			FROM #StagingData T
			LEFT JOIN MS.TRN_ManualOverallBaseMeasureData U
			ON T.ServiceID=U.ServiceID
			AND T.BaseMeasureID=U.BaseMeasureID
			AND (T.PRIORITYID=U.Priority OR (T.PRIORITYID IS NULL AND U.Priority IS NULL))
			AND (T.SupportCategory=U.SupportCategory OR (T.SupportCategory IS NULL AND T.SupportCategory IS NULL))
			AND (T.TECHNOLOGY=U.Technology OR (T.TECHNOLOGY IS NULL OR T.TECHNOLOGY IS NULL))
			AND T.FrequencyID=U.FrequencyID
			AND T.ReportPeriodID=U.ReportPeriodID
			AND T.ProjectID=U.ProjectID
			WHERE T.ServiceID IN
			(SELECT DISTINCT
			SM.ServiceID
		FROM AVL.MAS_ProjectMaster PM
		INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSAM
			ON PM.ProjectID = PSAM.ProjectID
		INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM
			ON  PSAM.ServiceMapID =SAM.ServiceMappingID
		INNER JOIN AVL.TK_MAS_Service SM
			ON SM.ServiceID = SAM.ServiceID WHERE PSAM.ProjectID=@ProjectID AND IsMainspringData='Y')
			--SELECT DISTINCT ServiceID FROM AVL.TK_PRJ_ServiceProjectMapping(NOLOCK)
			--WHERE ProjectID=@ProjectID AND IsMainspringData='Y'
			
	END
END
