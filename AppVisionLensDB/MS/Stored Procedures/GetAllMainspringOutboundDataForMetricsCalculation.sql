/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
-- =============================================

-- Description:	TO retrieve the list of all mainspring outbound data
-- =============================================


--[MS].[GetAllMainspringOutboundDataForMetricsCalculation]
CREATE PROCEDURE [MS].[GetAllMainspringOutboundDataForMetricsCalculation]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT MPS.ID,MPS.UniqueName,MPS.ESAProjectID,MPS.ProjectID,MPS.ServiceMetricBasemeasureMapID,MPS.M_PRIORITYID,
	MPS.M_SUPPORTCATEGORY,MPS.M_TECHNOLOGY,MPS.IsDeleted,MPS.TillDate,MPS.flag,
	SMBM.ServiceID,SMBM.MetricID,SMBM.BaseMeasureID,SMBM.PositionID,SMBM.ServicewiseBasemeasureTypeID
	FROM MS.MAP_ProjectStage_Mapping (NOLOCK) MPS
	LEFT JOIN MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping (NOLOCK)  SMBM
	ON MPS.ServiceMetricBasemeasureMapID=SMBM.ServiceMetricBaseMeasureMapID
	WHERE MPS.IsDeleted=0 and SMBM.MetricID  not IN (44) AND MPS.UniqueName IS NOT NULL
	SET NOCOUNT OFF;  
END



