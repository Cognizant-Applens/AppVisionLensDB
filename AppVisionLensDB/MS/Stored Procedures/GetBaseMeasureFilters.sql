CREATE PROCEDURE [MS].[GetBaseMeasureFilters] --267128
	@ProjectID BIGINT

AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;

	DECLARE @JobID BIGINT;
	SET @JobID=(SELECT Top 1 JobID FROM Ms.JobStatus(NOLOCK) 
	WHERE JobStatusId = 2 AND IsDaily = 0 AND IsOutBound = 1 AND IsDeleted=0 ORDER BY CreatedDate DESC);

	SELECT	4 as FrequencyID, 'Monthly' as FrequencyName

	SELECT JobID AS RowIndex,ReportingPeriod AS ReportPeriodID, ReportingPeriodDESC AS ReportPeriod  
	FROM Ms.JobStatus(NOLOCK) WHERE JobStatusId = 2 AND IsDaily = 0 AND IsOutBound = 1 AND IsDeleted=0 ORDER BY JobID DESC
	
	SELECT DISTINCT 0 AS ServiceID,'All (Project Level)'  as MainspringServiceName
	FROM AVL.MAS_ProjectMaster(NOLOCK) PM
	INNER JOIN MS.EFormViewDetails (NOLOCK) EF
	ON EF.DN_ProjectId = PM.EsaProjectId AND PM.IsDeleted = 0
	JOIN MS.MetricViewDetails (NOLOCK) MF
	ON MF.ServiceOffering3 = EF.DN_SERVICEOFFERINGLEVEL3 AND MF.MetricName = EF.DN_MetricName
	WHERE EF.DN_ServiceOfferingLevel3 = 'All' AND PM.ProjectID =@ProjectId
	UNION
    SELECT DISTINCT SM.ServiceID,SM.ServiceName  as MainspringServiceName
	FROM AVL.MAS_ProjectMaster(NOLOCK) PM
	INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PSAM
	ON PM.ProjectID = PSAM.ProjectID AND PSAM.IsDeleted=0 AND PM.IsDeleted=0                   
	INNER JOIN AVL.TK_MAS_ServiceActivityMapping(NOLOCK) SAM
	ON  PSAM.ServiceMapID =SAM.ServiceMappingID AND SAM.IsDeleted=0
	INNER JOIN AVL.TK_MAS_Service(NOLOCK) SM
	ON SM.ServiceID = SAM.ServiceID AND SM.IsDeleted=0
	AND SM.ServiceType = 4  
	INNER JOIN MS.EFormViewDetails (NOLOCK) EF
	ON EF.DN_SERVICEOFFERINGLEVEL3 = SM.MainspringServiceName
	AND EF.DN_PROJECTID = PM.EsaProjectID AND PM.IsDeleted=0
	JOIN MS.MetricViewDetails (NOLOCK) MF
	ON MF.ServiceOffering3 = EF.DN_SERVICEOFFERINGLEVEL3 AND MF.MetricName = EF.DN_MetricName
	WHERE   PSAM.IsMainspringData='Y' AND PM.ProjectID =@ProjectId
	AND ISNULL(PSAM.IsHidden,0) <> 1
  
	

	SELECT DISTINCT MMM.MetricID, MMM.MetricName, MUM.UOM, MUM.UOMDataType,MSMBMSMM.ServiceID 
	FROM MAS.Metric(NOLOCK) MMM 
	INNER JOIN MAS.UOM(NOLOCK) MUM ON MMM.UOMID=MUM.UOMID AND MUM.IsDeleted=0 AND MMM.IsDeleted=0
	INNER JOIN MS.ServiceMetricBaseMeasureMapping(NOLOCK) MSMBMSMM ON MMM.MetricID=MSMBMSMM.MetricID AND MSMBMSMM.IsDeleted=0
	INNER JOIN MS.ProjectOutBoundEformData(NOLOCK) MPSM ON  --outbound table
	MPSM.ServiceMetricBaseMeasureId=MSMBMSMM.ServiceMetricBaseMeasureID AND MPSM.IsDeleted=0
	WHERE  MPSM.ProjectID=@ProjectID AND MPSM.JobId= @JobID
	ORDER BY MMM.MetricName

	DECLARE @MainspringConfigured VARCHAR(10)
	DECLARE @SUPPORTCATEGORYCount INT
	DECLARE @IsODCRestricted VARCHAR(10)

	select @MainspringConfigured=IsMainSpringConfigured from AVL.MAS_ProjectMaster(NOLOCK) where ProjectID = @ProjectID AND IsDeleted=0
	select @IsODCRestricted=ISNULL(IsODCRestricted,'N') from AVL.MAS_ProjectMaster(NOLOCK) where ProjectID = @ProjectID AND IsDeleted=0
	select @SUPPORTCATEGORYCount=COUNT(SCM.ProjectID) from Ms.ProjectSupportCategory SCM
	INNER JOIN avl.MAS_ProjectMaster(NOLOCK) PM ON PM.ProjectID=SCM.ProjectID AND PM.IsDeleted=0 AND SCM.IsDeleted=0
	WHERE
	PM.ProjectID=@ProjectID

	SELECT @MainspringConfigured AS MainspringConfigured
	, @SUPPORTCATEGORYCount AS SupportCategoryCount,@IsODCRestricted AS IsODCRestricted
	
SET NOCOUNT OFF;   
END TRY  
BEGIN CATCH   	
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[MS].[GetBaseMeasureFilters]', @ErrorMessage,0
END CATCH  

END