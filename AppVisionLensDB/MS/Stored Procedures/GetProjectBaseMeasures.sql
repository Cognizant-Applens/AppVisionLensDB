CREATE PROCEDURE [MS].[GetProjectBaseMeasures]   
 @ProjectID BIGINT,  
 @FrequencyID INT=NULL,  
 @ServiceIDs VARCHAR(500)=NULL,  
 @MetricsIDs VARCHAR(max)=NULL,  
 @RequiredSearchType VARCHAR(50), -- 'system defined', 'user defined', 'progress'  
 @ReportFrequencyID INT=NULL  
AS  
BEGIN  
BEGIN TRY
SET NOCOUNT ON; 
 DECLARE @JobId BIGINT;
 SET @JobId=(SELECT Top 1 JobID FROM Ms.JobStatus(NOLOCK) 
	WHERE JobStatusId = 2 AND IsDaily = 0 AND IsOutBound = 1 AND IsDeleted=0 ORDER BY CreatedDate DESC);

IF (@RequiredSearchType='user defined')  
 BEGIN  

  SELECT MSMBSM.ServiceID,
  MS.ServiceName, 
  MSMBSM.BaseMeasureID, 
  MBM.BaseMeasureName,
  MUM.UOMID, MUM.UOM AS UOMDESC, MUM.UOMDataType AS UOMDataType, 
  MSOB.BaseMeasureValue ,
  JOS.ReportingPeriod, 
  MBM.BaseMeasureTypeID, 
  MSOB.ServiceMetricBaseMeasureId,
  MM.MetricID, 
  MM.MetricName
  FROM MS.ProjectOutBoundEformData(NOLOCK) MSOB  
   INNER JOIN MS.ServiceMetricBaseMeasureMapping(NOLOCK) MSMBSM ON  MSOB.ServiceMetricBaseMeasureId = MSMBSM.ServiceMetricBaseMeasureID AND MSMBSM.ISdeleted=0
   INNER JOIN MAS.Metric(NOLOCK) MM ON MSMBSM.MetricID = MM.MetricID and MM.IsDeleted=0
   INNER JOIN AVL.TK_MAS_Service(NOLOCK) MS ON MSMBSM.ServiceID = MS.ServiceID and MS.Isdeleted=0
   INNER JOIN MAS.BaseMeasure(NOLOCK) MBM ON MBM.BaseMeasureID = MSMBSM.BaseMeasureID and MBM.isdeleted=0
   INNER JOIN MAS.UOM(NOLOCK) MUM ON MBM.UOMID = MUM.UOMID AND MUM.IsDeleted=0
   INNER JOIN MS.JobStatus JOS ON JOS.jobid = MSOB.JobId AND JOS.IsDeleted = 0 AND MSOB.JobId = @JobId
  WHERE MSOB.ProjectID=@ProjectId AND MSOB.IsDeleted=0 
  AND MSMBSM.IsDeleted=0 AND MM.IsDeleted=0 
  UNION
    SELECT MSMBSM.ServiceID,
  'All (Project Level)', 
  MSMBSM.BaseMeasureID, 
  MBM.BaseMeasureName,
  MUM.UOMID, MUM.UOM AS UOMDESC, MUM.UOMDataType AS UOMDataType, 
  MSOB.BaseMeasureValue ,
  JOS.ReportingPeriod, 
  MBM.BaseMeasureTypeID, 
  MSOB.ServiceMetricBaseMeasureId,
  MM.MetricID, 
  MM.MetricName
  FROM MS.ProjectOutBoundEformData(NOLOCK) MSOB  
   INNER JOIN MS.ServiceMetricBaseMeasureMapping(NOLOCK) MSMBSM ON  MSOB.ServiceMetricBaseMeasureId = MSMBSM.ServiceMetricBaseMeasureID AND MSMBSM.ISdeleted=0
   INNER JOIN MAS.Metric(NOLOCK) MM ON MSMBSM.MetricID = MM.MetricID and MM.IsDeleted=0
   INNER JOIN MAS.BaseMeasure(NOLOCK) MBM ON MBM.BaseMeasureID = MSMBSM.BaseMeasureID and MBM.isdeleted=0
   INNER JOIN MAS.UOM(NOLOCK) MUM ON MBM.UOMID = MUM.UOMID AND MUM.IsDeleted=0
   INNER JOIN MS.JobStatus JOS ON JOS.jobid = MSOB.JobId AND JOS.IsDeleted = 0 AND MSOB.JobId = @JobId
  WHERE MSOB.ProjectID=@ProjectID AND MSOB.IsDeleted=0   
  AND MSMBSM.IsDeleted=0 AND MM.IsDeleted=0 
  AND MSMBSM.ServiceId = 0

 END

Else IF(@RequiredSearchType='ODC')

       BEGIN
              SELECT DISTINCT sm.ServiceID,
                                    s.ServiceName,
                                    b.BaseMeasureID,
                                    b.BaseMeasureName,
                                    u.UOMID,u.UOM  AS UOMDESC, u.UOMDataType AS UOMDataType,
                                    b.BaseMeasureTypeID,
                                    OBD.BaseMeasureValue,       
                                    OBD.ServiceMetricBaseMeasureId,
                                    JOS.ReportingPeriod,
                                    m.MetricID,
                                    m.MetricName
                      from MS.ServiceMetricBaseMeasureMapping(NOLOCK) sm
                      inner join MS.ProjectOutBoundEformData(NOLOCK) OBD 
					  ON sm.ServiceMetricBaseMeasureID=OBD.ServiceMetricBaseMeasureId AND obd.isdeleted=0
                      inner join AVL.TK_MAS_Service(NOLOCK) s ON sm.ServiceID=s.ServiceID AND s.isdeleted=0
                      inner join MAS.Metric(NOLOCK) m on sm.MetricID=m.MetricID and m.isdeleted=0
                      inner join MAS.BaseMeasure(NOLOCK) b on sm.BaseMeasureID=b.BaseMeasureID and b.isdeleted=0
                      inner join MAS.UOM(NOLOCK) u on b.UOMID=u.UOMID and u.isdeleted=0
                      INNER JOIN MS.JobStatus JOS ON JOS.jobid = OBD.JobId and JOS.isdeleted=0 AND OBD.JobId = @JobId
                      WHERE 
                      OBD.ProjectID=@ProjectID AND B.IsDeleted=0
                      AND b.BaseMeasureID NOT IN(208,209) AND OBD.IsDeleted=0 and sm.isdeleted=0
                      
					  UNION ALL
					   SELECT DISTINCT 
					                 0 AS ServiceID,
                                    'All (Project Level)' AS ServiceName,
                                    b.BaseMeasureID,
                                    b.BaseMeasureName,
                                    u.UOMID,u.UOM  AS UOMDESC, u.UOMDataType AS UOMDataType,
                                    b.BaseMeasureTypeID,
                                    OBD.BaseMeasureValue,       
                                    OBD.ServiceMetricBaseMeasureId,
                                    JOS.ReportingPeriod,
                                    m.MetricID,
                                    m.MetricName
                      from MS.ServiceMetricBaseMeasureMapping(NOLOCK) sm
                      inner join MS.ProjectOutBoundEformData(NOLOCK) OBD 
					  ON sm.ServiceMetricBaseMeasureID=OBD.ServiceMetricBaseMeasureId AND obd.isdeleted=0
                      inner join MAS.Metric(NOLOCK) m on sm.MetricID=m.MetricID and m.isdeleted=0
                      inner join MAS.BaseMeasure(NOLOCK) b on sm.BaseMeasureID=b.BaseMeasureID and b.isdeleted=0
                      inner join MAS.UOM(NOLOCK) u on b.UOMID=u.UOMID and u.isdeleted=0
                      INNER JOIN MS.JobStatus JOS ON JOS.jobid = OBD.JobId and JOS.isdeleted=0 AND OBD.JobId = @JobId
                      WHERE 
                      OBD.ProjectID=@ProjectID AND B.IsDeleted=0
                      AND b.BaseMeasureID NOT IN(208,209) AND OBD.IsDeleted=0 and sm.isdeleted=0 AND SM.ServiceId = 0
                      

       END 
ELSE IF (@RequiredSearchType='progress')  
 BEGIN  

  SELECT MSMBSM.ServiceID, SM.ServiceName, MBM.BaseMeasureID, MBM.BaseMeasureName, MUM.UOM, MUM.UOMDataType, OBD.BaseMeasureValue  AS BaseMeasureValue  
  ,@FrequencyID AS FrequencyID, @ReportFrequencyID AS ReportPeriodID, @ProjectID AS ProjectID, MBM.BaseMeasureTypeID, MSMBSM.MetricID, MMM.MetricName  
  INTO #UDBaseMeasureDetails1  
  FROM MAS.BaseMeasure  MBM 
  INNER JOIN MS.ServiceMetricBaseMeasureMapping MSMBSM ON MSMBSM.BaseMeasureID=MBM.BaseMeasureID and MSMBSM.isdeleted=0
  INNER JOIN MAS.Metric MMM ON MMM.MetricID=MSMBSM.MetricID and MMM.isdeleted=0
  INNER JOIN MAS.UOM MUM ON MBM.UOMID=MUM.UOMID  and MUM.isdeleted=0
  INNER JOIN AVL.TK_MAS_Service  SM ON MSMBSM.ServiceID=SM.ServiceID and SM.isdeleted=0
  INNER JOIN MS.ProjectOutBoundEformData OBD ON  
   OBD.ServiceMetricBasemeasureID=MSMBSM.ServiceMetricBaseMeasureID  and OBD.isdeleted=0
  WHERE OBD.ProjectId = @ProjectID AND MBM.IsDeleted=0 AND OBD.JobId = @JobId   
  AND MSMBSM.IsDeleted=0 AND MMM.IsDeleted=0 AND OBD.IsDeleted=0  AND MSMBSM.IsDeleted=0  
  AND MBM.BaseMeasureTypeID=2  
  UNION
    SELECT 0 AS ServiceID, 'All (Project Level)' AS ServiceName, MBM.BaseMeasureID, MBM.BaseMeasureName, MUM.UOM, MUM.UOMDataType, OBD.BaseMeasureValue  AS BaseMeasureValue  
  ,@FrequencyID AS FrequencyID, @ReportFrequencyID AS ReportPeriodID, @ProjectID AS ProjectID, MBM.BaseMeasureTypeID, MSMBSM.MetricID, MMM.MetricName  
  FROM MAS.BaseMeasure  MBM 
  INNER JOIN MS.ServiceMetricBaseMeasureMapping MSMBSM ON MSMBSM.BaseMeasureID=MBM.BaseMeasureID and MSMBSM.isdeleted=0
  INNER JOIN MAS.Metric MMM ON MMM.MetricID=MSMBSM.MetricID and MMM.isdeleted=0
  INNER JOIN MAS.UOM MUM ON MBM.UOMID=MUM.UOMID  and MUM.isdeleted=0
 -- INNER JOIN AVL.TK_MAS_Service  SM ON MSMBSM.ServiceID=SM.ServiceID and SM.isdeleted=0
  INNER JOIN MS.ProjectOutBoundEformData OBD ON  
   OBD.ServiceMetricBasemeasureID=MSMBSM.ServiceMetricBaseMeasureID  and OBD.isdeleted=0
  WHERE OBD.ProjectId = @ProjectID AND MBM.IsDeleted=0   AND OBD.JobId = @JobId
  AND MSMBSM.IsDeleted=0 AND MMM.IsDeleted=0 AND OBD.IsDeleted=0  AND MSMBSM.IsDeleted=0  
  AND MBM.BaseMeasureTypeID=2  AND MSMBSM.ServiceId = 0

 
  DECLARE @ValuesAvailableCount DECIMAL(10,2)  
  DECLARE @ValuesTotalCount DECIMAL(10,2)  
 
  SELECT @ValuesAvailableCount=COUNT(BaseMeasureValue) FROM #UDBaseMeasureDetails1 WHERE ISNULL(REPLACE(BaseMeasureValue, ' ', ''),'') <> ''  
  SELECT @ValuesTotalCount=COUNT(BaseMeasureID) FROM #UDBaseMeasureDetails1  
  
  SELECT @ValuesAvailableCount AS ValuesAvailableCount, @ValuesTotalCount AS ValuesTotalCount,  
  CASE WHEN @ValuesTotalCount>0 THEN  
  (@ValuesAvailableCount/@ValuesTotalCount) * 100   
  ELSE  
  0  
  END  
  AS ProgressPercentage, 'user defined' AS BaseMeasureType  
   
  DROP TABLE #UDBaseMeasureDetails1
  
    
 END  
  SET NOCOUNT OFF;   
END TRY 
BEGIN CATCH   
              DECLARE @ErrorMessage VARCHAR(MAX);
              SELECT @ErrorMessage = ERROR_MESSAGE()
              --INSERT Error    
              EXEC AVL_InsertError '[MS].[GetProjectBaseMeasures]', @ErrorMessage,0
END CATCH  
END