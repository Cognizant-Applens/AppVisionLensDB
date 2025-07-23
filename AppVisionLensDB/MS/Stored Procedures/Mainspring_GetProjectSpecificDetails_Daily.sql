/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [MS].[Mainspring_GetProjectSpecificDetails_Daily] 
(
@MetricName  nvarchar(30)
) 
AS  
BEGIN  
SET NOCOUNT ON;
SELECT DISTINCT PM.ProjectID
FROM  MS.MetricstagingDailyDump_Outbound_ProjectSpecific(nolock) A
INNER JOIN AVL.MAS_ProjectMaster(nolock) PM ON PM.EsaProjectID =A.DN_PROJECTID
WHERE A.DN_MetricName=@MetricName
SET NOCOUNT OFF;  
End
