/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
   --exec  MS.GetBaseMeasureProjectwiseSearch 40635,4,'','','user defined',62018
CREATE PROCEDURE [MS].[GetBaseMeasureProjectwiseSearch]   
 @ProjectID BIGINT,  
 @FrequencyID INT=NULL,  
 @ServiceIDs VARCHAR(500)=NULL,  
 @MetricsIDs VARCHAR(max)=NULL,  
 @RequiredSearchType VARCHAR(50), -- 'system defined', 'user defined', 'progress'  
 @ReportFrequencyID INT=NULL  
AS  
BEGIN  
SET NOCOUNT ON;  
  
IF (@RequiredSearchType='user defined')  
 BEGIN  
   
  SELECT MSBM.ServiceID, SM.ServiceName, MBM.BaseMeasureID, MBM.BaseMeasureName, MUM.UOM_DESC, MUM.UOM_DataType, '' AS BaseMeasureValue  
  ,@FrequencyID AS FrequencyID, @ReportFrequencyID AS ReportPeriodID, @ProjectID AS ProjectID, MBM.BaseMeasureTypeID, MSMBSM.MetricID, MMM.MetricName  
  INTO #UDBaseMeasureDetails  
  FROM MS.MAS_BaseMeasure_Master MBM  WITH(NOLOCK)
  INNER JOIN  MS.MAS_UOM_Master MUM WITH(NOLOCK) ON MBM.UOMID=MUM.UOMID  
  INNER JOIN MS.MAP_ServiceBaseMeasure_Mapping MSBM WITH(NOLOCK)  ON MBM.BaseMeasureID=MSBM.BaseMeasureID  
  INNER JOIN AVL.TK_MAS_Service SM WITH(NOLOCK) ON MSBM.ServiceID=SM.ServiceID  
  INNER JOIN MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping MSMBSM WITH(NOLOCK) ON MSMBSM.BaseMeasureID=MBM.BaseMeasureID    AND MSMBSM.ServiceID=SM.ServiceID 
  INNER JOIN MS.MAS_Metric_Master  MMM WITH(NOLOCK) ON MMM.MetricID=MSMBSM.MetricID  
  INNER JOIN MS.MAP_ProjectStage_Mapping MPSM WITH(NOLOCK) ON   
   MPSM.ServiceMetricBasemeasureMapID=MSMBSM.ServiceMetricBaseMeasureMapID  
  WHERE MPSM.ProjectID=@ProjectID AND MBM.IsDeleted=0 AND MSMBSM.ServicewiseBasemeasureTypeID IN (2,3) AND MMM.FrequencyID=@FrequencyID  
  AND MSMBSM.IsDeleted=0 AND MMM.IsDeleted=0  AND MPSM.IsDeleted=0  AND MSBM.IsDeleted=0
  --MBM.BaseMeasureTypeID IN (2,3)  
      
  SELECT  TempMBMUDD.ServiceID, TempMBMUDD.ServiceName, TempMBMUDD.BaseMeasureID, TempMBMUDD.BaseMeasureName, TempMBMUDD.UOM_DESC,  
   TempMBMUDD.UOM_DataType, MBMUDD.BaseMeasureValue  
  ,TempMBMUDD.FrequencyID, TempMBMUDD.ReportPeriodID, TempMBMUDD.ProjectID, TempMBMUDD.BaseMeasureTypeID  
  , TempMBMUDD.MetricID, TempMBMUDD.MetricName  
   FROM #UDBaseMeasureDetails TempMBMUDD  
  LEFT JOIN MS.TRN_BaseMeasureUserDefinedData MBMUDD WITH(NOLOCK)
  ON   
  TempMBMUDD.ServiceID=MBMUDD.ServiceID AND  
  TempMBMUDD.BaseMeasureID=MBMUDD.BaseMeasureID AND  
  TempMBMUDD.FrequencyID=MBMUDD.FrequencyID AND  
  TempMBMUDD.ReportPeriodID=MBMUDD.ReportPeriodID AND  
  TempMBMUDD.ProjectID=MBMUDD.ProjectID  
    
  DROP TABLE #UDBaseMeasureDetails  
 END  
ELSE IF (@RequiredSearchType='system defined')  
 BEGIN  
   
  SELECT MSBM.ServiceID, SM.ServiceName, MBM.BaseMeasureID, MBM.BaseMeasureName, MUM.UOM_DESC, MUM.UOM_DataType, '' AS BaseMeasureValue  
  ,@FrequencyID AS FrequencyID, @ReportFrequencyID AS ReportPeriodID, @ProjectID AS ProjectID, MBM.BaseMeasureTypeID,MSMBSM.ServiceMetricBaseMeasureMapID, MSMBSM.MetricID, '' AS MetricName  
  INTO #SDBaseMeasureDetails  
  FROM MS.MAS_BaseMeasure_Master MBM  WITH(NOLOCK)
  INNER JOIN MS.MAS_UOM_Master MUM WITH(NOLOCK) ON MBM.UOMID=MUM.UOMID  
  INNER JOIN MS.MAP_ServiceBaseMeasure_Mapping MSBM WITH(NOLOCK) ON MBM.BaseMeasureID=MSBM.BaseMeasureID  
  INNER JOIN AVL.TK_MAS_Service SM WITH(NOLOCK) ON MSBM.ServiceID=SM.ServiceID  
  INNER JOIN MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping MSMBSM WITH(NOLOCK) ON MSMBSM.BaseMeasureID=MBM.BaseMeasureID    AND MSMBSM.ServiceID=SM.ServiceID 
  INNER JOIN MS.MAS_Metric_Master MMM WITH(NOLOCK) ON MMM.MetricID=MSMBSM.MetricID  
  INNER JOIN MS.MAP_ProjectStage_Mapping MPSM WITH(NOLOCK) ON  
   MPSM.ServiceMetricBasemeasureMapID=MSMBSM.ServiceMetricBaseMeasureMapID  
  WHERE MPSM.ProjectID=@ProjectID AND MBM.IsDeleted=0 AND MSMBSM.ServicewiseBasemeasureTypeID IN (1) AND MMM.FrequencyID=@FrequencyID  
  AND MSMBSM.IsDeleted=0 AND MMM.IsDeleted=0 AND MPSM.IsDeleted=0  AND MSBM.IsDeleted=0
    
  SELECT  TempMBMUDD.ServiceID, TempMBMUDD.ServiceName, TempMBMUDD.BaseMeasureID, TempMBMUDD.BaseMeasureName, TempMBMUDD.UOM_DESC,  
   TempMBMUDD.UOM_DataType, MBMUDD.BaseMeasureValue  
  ,TempMBMUDD.FrequencyID, TempMBMUDD.ReportPeriodID, TempMBMUDD.BaseMeasureTypeID, TempMBMUDD.ProjectID, TempMBMUDD.ServiceMetricBaseMeasureMapID, TempMBMUDD.MetricID, TempMBMUDD.MetricName  
  FROM #SDBaseMeasureDetails TempMBMUDD  WITH(NOLOCK)
  INNER JOIN MS.MAP_ProjectStage_Mapping  MPSM WITH(NOLOCK) ON MPSM.ProjectID=TempMBMUDD.ProjectID   
  AND TempMBMUDD.ServiceMetricBaseMeasureMapID=MPSM.ServiceMetricBasemeasureMapID  
  LEFT JOIN MS.TRN_ProjectStaging_TillDateBaseMeasure MBMUDD WITH(NOLOCK)
  ON  
  MPSM.ID=MBMUDD.ProjectStageID  
  WHERE MPSM.ProjectID=@ProjectID
    
  --SELECT * FROM #SDBaseMeasureDetails  
    
  DROP TABLE #SDBaseMeasureDetails  
 END  
ELSE IF (@RequiredSearchType='progress')  
 BEGIN  
   
  SELECT MSBM.ServiceID, SM.ServiceName, MBM.BaseMeasureID, MBM.BaseMeasureName, MUM.UOM_DESC, MUM.UOM_DataType, '' AS BaseMeasureValue  
  ,@FrequencyID AS FrequencyID, @ReportFrequencyID AS ReportPeriodID, @ProjectID AS ProjectID, MBM.BaseMeasureTypeID, MSMBSM.MetricID, MMM.MetricName  
  INTO #UDBaseMeasureDetails1  
  FROM MS.MAS_BaseMeasure_Master  MBM  WITH(NOLOCK)
  INNER JOIN MS.MAS_UOM_Master MUM WITH(NOLOCK) ON MBM.UOMID=MUM.UOMID  
  INNER JOIN MS.MAP_ServiceBaseMeasure_Mapping MSBM WITH(NOLOCK) ON MBM.BaseMeasureID=MSBM.BaseMeasureID  
  INNER JOIN AVL.TK_MAS_Service  SM WITH(NOLOCK) ON MSBM.ServiceID=SM.ServiceID  
  INNER JOIN MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping MSMBSM WITH(NOLOCK) ON MSMBSM.BaseMeasureID=MBM.BaseMeasureID   AND MSMBSM.ServiceID=SM.ServiceID 
  INNER JOIN MS.MAS_Metric_Master MMM WITH(NOLOCK) ON MMM.MetricID=MSMBSM.MetricID  
  INNER JOIN MS.MAP_ProjectStage_Mapping MPSM WITH(NOLOCK) ON  
   MPSM.ServiceMetricBasemeasureMapID=MSMBSM.ServiceMetricBaseMeasureMapID  
  WHERE MPSM.ProjectID=@ProjectID AND MBM.IsDeleted=0 AND MSMBSM.ServicewiseBasemeasureTypeID IN (2,3) AND MMM.FrequencyID=@FrequencyID  
  AND MSMBSM.IsDeleted=0 AND MMM.IsDeleted=0 AND MPSM.IsDeleted=0  AND MSBM.IsDeleted=0
  -- MBM.BaseMeasureTypeID=2  
      
  SELECT  TempMBMUDD.ServiceID, TempMBMUDD.ServiceName, TempMBMUDD.BaseMeasureID, TempMBMUDD.BaseMeasureName, TempMBMUDD.UOM_DESC,  
   TempMBMUDD.UOM_DataType, MBMUDD.BaseMeasureValue  
  ,TempMBMUDD.FrequencyID, TempMBMUDD.ReportPeriodID, TempMBMUDD.ProjectID  
  INTO #UDBaseMeasureDetails2  
  FROM #UDBaseMeasureDetails1 TempMBMUDD WITH(NOLOCK)
  LEFT JOIN MS.TRN_BaseMeasureUserDefinedData MBMUDD   WITH(NOLOCK)
  ON   
  TempMBMUDD.ServiceID=MBMUDD.ServiceID AND  
  TempMBMUDD.BaseMeasureID=MBMUDD.BaseMeasureID AND  
  TempMBMUDD.FrequencyID=MBMUDD.FrequencyID AND  
  TempMBMUDD.ReportPeriodID=MBMUDD.ReportPeriodID AND  
  TempMBMUDD.ProjectID=MBMUDD.ProjectID  
    
  SELECT DISTINCT UDB2.BaseMeasureID,UDB2.ServiceID,UDB2.BaseMeasureValue  INTO #UDBaseMeasureDetails3 FROM #UDBaseMeasureDetails2 UDB2  WITH(NOLOCK)
 -- INNER JOIN AVL.TK_PRJ_ServiceProjectMapping SPM ON SPM.ServiceID=UDB2.ServiceID AND SPM.ProjectID = @ProjectID AND SPM.IsMainspringData='Y'  
   INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM WITH(NOLOCK) ON  SAM.ServiceID=UDB2.ServiceID 
  INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSAM WITH(NOLOCK) ON PSAM.ServiceMapID=SAM.ServiceMappingID AND PSAM.IsMainspringData='Y' AND PSAM.ProjectID = @ProjectID 
  INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSAM WITH(NOLOCK) ON PSAM.ServiceMapID=SAM.ServiceMappingID AND PSAM.IsMainspringData='Y' AND PSAM.ProjectID = @ProjectID 
  INNER JOIN AVL.TK_MAS_Service SM ON SM.ServiceID = SAM.ServiceID  
    
  SELECT DISTINCT MSBM.ServiceID, SM.ServiceName, MBM.BaseMeasureID, MBM.BaseMeasureName, MUM.UOM_DESC, MUM.UOM_DataType, '' AS BaseMeasureValue  
  ,@FrequencyID AS FrequencyID, @ReportFrequencyID AS ReportPeriodID, @ProjectID AS ProjectID, MBM.BaseMeasureTypeID,MSMBSM.ServiceMetricBaseMeasureMapID  
  INTO #SDBaseMeasureDetails1  
  FROM MS.MAS_BaseMeasure_Master MBM  WITH(NOLOCK)
  INNER JOIN MS.MAS_UOM_Master MUM WITH(NOLOCK) ON MBM.UOMID=MUM.UOMID  
  INNER JOIN MS.MAP_ServiceBaseMeasure_Mapping MSBM WITH(NOLOCK) ON MBM.BaseMeasureID=MSBM.BaseMeasureID  
  INNER JOIN AVL.TK_MAS_Service SM  WITH(NOLOCK) ON MSBM.ServiceID=SM.ServiceID  
  INNER JOIN MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping MSMBSM WITH(NOLOCK) ON MSMBSM.BaseMeasureID=MBM.BaseMeasureID    AND MSMBSM.ServiceID=SM.ServiceID 
  INNER JOIN MS.MAS_Metric_Master MMM WITH(NOLOCK) ON MMM.MetricID=MSMBSM.MetricID  
  INNER JOIN MS.MAP_ProjectStage_Mapping MPSM WITH(NOLOCK) ON  
   MPSM.ServiceMetricBasemeasureMapID=MSMBSM.ServiceMetricBaseMeasureMapID  
  WHERE MPSM.ProjectID=@ProjectID AND MBM.IsDeleted=0 AND MSMBSM.ServicewiseBasemeasureTypeID IN (1) AND MMM.FrequencyID=@FrequencyID  
  AND MSMBSM.IsDeleted=0 AND MMM.IsDeleted=0 AND MPSM.IsDeleted=0  AND MSBM.IsDeleted=0
    
  SELECT  TempMBMUDD.ServiceID, TempMBMUDD.ServiceName, TempMBMUDD.BaseMeasureID, TempMBMUDD.BaseMeasureName, TempMBMUDD.UOM_DESC,  
   TempMBMUDD.UOM_DataType, MBMUDD.BaseMeasureValue  
  ,TempMBMUDD.FrequencyID, TempMBMUDD.ReportPeriodID, TempMBMUDD.BaseMeasureTypeID,  TempMBMUDD.ProjectID, TempMBMUDD.ServiceMetricBaseMeasureMapID  
  INTO #SDBaseMeasureDetails2  
  FROM #SDBaseMeasureDetails1 TempMBMUDD  
  INNER JOIN MS.MAP_ProjectStage_Mapping MPSM WITH(NOLOCK) ON MPSM.ProjectID=TempMBMUDD.ProjectID   
  AND TempMBMUDD.ServiceMetricBaseMeasureMapID=MPSM.ServiceMetricBasemeasureMapID  
  LEFT JOIN MS.TRN_ProjectStaging_TillDateBaseMeasure MBMUDD   WITH(NOLOCK)
  ON   
  MPSM.ID=MBMUDD.ProjectStageID  
  WHERE MPSM.ProjectID=@ProjectID  
    
  SELECT DISTINCT SDB2.BaseMeasureID,SDB2.ServiceID,SDB2.BaseMeasureValue  INTO #SDBaseMeasureDetails3 FROM #SDBaseMeasureDetails2  SDB2 WITH(NOLOCK)
  --INNER JOIN AVL.TK_PRJ_ServiceProjectMapping SPM ON SPM.ServiceID=SDB2.ServiceID AND SPM.ProjectID = @ProjectID AND SPM.IsMainspringData='Y'  
   INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM WITH(NOLOCK) ON  SAM.ServiceID=SDB2.ServiceID 
  INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping PSAM WITH(NOLOCK) ON PSAM.ServiceMapID=SAM.ServiceMappingID AND PSAM.IsMainspringData='Y' AND PSAM.ProjectID = @ProjectID 
  INNER JOIN AVL.TK_MAS_Service SM WITH(NOLOCK) ON SM.ServiceID = SAM.ServiceID  
    
  DECLARE @ValuesAvailableCount DECIMAL(10,2)  
  DECLARE @ValuesTotalCount DECIMAL(10,2)  
    
  DECLARE @ValuesAvailableCountSystem DECIMAL(10,2)  
  DECLARE @ValuesTotalCountSystem DECIMAL(10,2)  
    
  SELECT @ValuesAvailableCount=COUNT(BaseMeasureValue) FROM #UDBaseMeasureDetails3 WITH(NOLOCK) WHERE ISNULL(REPLACE(BaseMeasureValue, ' ', ''),'') <> ''  
  SELECT @ValuesTotalCount=COUNT(BaseMeasureID) FROM #UDBaseMeasureDetails3  WITH(NOLOCK)
    
  SELECT @ValuesAvailableCountSystem=COUNT(BaseMeasureValue) FROM #SDBaseMeasureDetails3 WITH(NOLOCK) WHERE ISNULL(REPLACE(BaseMeasureValue, ' ', ''),'') <> ''  
  SELECT @ValuesTotalCountSystem=COUNT(BaseMeasureID) FROM #SDBaseMeasureDetails3  WITH(NOLOCK)
    
  SELECT @ValuesAvailableCount AS ValuesAvailableCount, @ValuesTotalCount AS ValuesTotalCount,  
  CASE WHEN @ValuesTotalCount>0 THEN  
  (@ValuesAvailableCount/@ValuesTotalCount) * 100   
  ELSE  
  0  
  END  
  AS ProgressPercentage, 'user defined' AS BaseMeasureType  
  UNION  
  SELECT @ValuesAvailableCountSystem AS ValuesAvailableCount, @ValuesTotalCountSystem AS ValuesTotalCount,  
  CASE WHEN @ValuesTotalCountSystem>0 THEN  
  (@ValuesAvailableCountSystem/@ValuesTotalCountSystem) * 100   
  ELSE  
  0  
  END AS ProgressPercentage, 'system defined' AS BaseMeasureType  
    
  DROP TABLE #UDBaseMeasureDetails1  
  DROP TABLE #UDBaseMeasureDetails2  
  DROP TABLE #UDBaseMeasureDetails3  
    
  DROP TABLE #SDBaseMeasureDetails1  
  DROP TABLE #SDBaseMeasureDetails2  
  DROP TABLE #SDBaseMeasureDetails3  
    
 END  
 SET NOCOUNT OFF;  
END  

