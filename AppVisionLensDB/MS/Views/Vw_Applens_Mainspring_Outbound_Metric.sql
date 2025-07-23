CREATE VIEW [MS].[Vw_Applens_Mainspring_Outbound_Metric]
AS

	SELECT EF.DN_PROJECTNAME AS PROJECTNAME,
	PM.ProjectId AS DARTProjectID	,
	EF.DN_PROJECTID AS DN_PROJECTID,
	NULL AS ReportingMonthStartDate,
	NULL AS ReportingMonthEndDate,
	GetDate() AS PublishedDate,
	EF.DN_ServiceOfferingLevel2 AS ServiceOfferingLevel2,
	EF.DN_ServiceOfferingLevel3 AS ServiceOfferingLevel3,	
	M.MetricName,
	EF.DN_SupportCategory AS SupportCategory,
	EF.DN_Priority AS Priority,
	EF.DN_Technology AS Technology,	
	EF.DN_Mandatory AS Mandatory,	
	EF.DN_UoM AS MetricUOM,
	EF.DN_Applicability AS APPLICABILITY,
	OB.Numerator1Name,
	OB.Numerator1Value,
	OB.Numerator2Name,
	OB.Numerator2Value,
	OB.Numerator3Name,
	OB.Numerator3Value,
	OB.Numerator4Name,
	OB.Numerator4Value,
	OB.Denominator1Name,
	OB.Denominator1Value,
	OB.Denominator2Name,
	OB.Denominator2Value,
	OB.Denominator3Name,
	OB.Denominator3Value,
	OB.Denominator4Name,
	OB.Denominator4Value,
	NULL AS CustomMetricValue,	
	EF.DN_UNIQUEKEY AS UniqueName,
	4 AS FrequencyID,
	J.ReportingPeriod	AS ReportPeriodID,
	J.JobID	,
	EF.DN_GoalType AS GoalType,
	EF.DN_BaselineDate AS BaselineDate,
	EF.DN_BIC,
	EF.DN_GOAL,
	EF.DN_METRICTYPE,
	EF.DN_CPKGOAL,
	EF.DN_MINIMUMSERVICETARGET,
	EF.DN_EXPECTEDSERVICETARGET,	
	EF.DN_GOALLEVEL
  FROM [MS].[OutBoundValueDetails](NOLOCK) OB
  JOIN AVL.MAS_ProjectMaster (NOLOCK)  PM
  ON PM.ProjectId = OB.ProjectId AND PM.Isdeleted = 0
  JOIN MS.JobStatus (NOLOCK) J
  ON J.JobId = OB.JobId AND J.IsOutbound = 1 AND J.IsDaily = 0 AND J.JobStatusId = 4
  JOIN MAS.Metric(NOLOCK) M
  ON M.MetricId = OB.MetricId AND M.IsDeleted = 0 AND M.MetricTypeId = 1 
  JOIN AVL.TK_MAS_Service(NOLOCK) S
  ON S.ServiceId = OB.ServiceId AND S.IsDeleted = 0
  JOIN MS.EformViewDetailsMonthly(NOLOCK) EF
  ON EF.DN_ServiceOfferingLevel3 = S.MainspringServiceName AND EF.DN_MetricName = M.MetricName AND EF.DN_ProjectId = PM.ESAProjectID
  WHERE ReportingPeriod = (SELECT TOP 1 ReportingPeriod FROM MS.JobStatus(NOLOCK)
  WHERE IsOutbound = 1 AND IsDaily = 0 AND JobStatusId = 4 ORDER BY CREATEDDATE DESC)