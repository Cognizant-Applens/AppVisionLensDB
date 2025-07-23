/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- exec [MS].[IsProjectSpecificLoadFactor] '11489','Load Factor'
CREATE PROCEDURE [MS].[IsProjectSpecificLoadFactor]
(
@ProjectID  nvarchar(30),
@MetricName  nvarchar(30)
) 
AS  
BEGIN  

SELECT top 1 *  FROM [MS].[MetricstagingDailyDump_Outbound_ProjectSpecific](NOLOCK)
WHERE DN_MetricName=@MetricName AND DN_ProjectID IN (SELECT EsaProjectID FROM 
AVL.MAS_ProjectMaster(NOLOCK)
WHERE ProjectID=@ProjectID AND IsODCRestricted='Y'AND IsDeleted=0 AND IsMainSpringConfigured='Y')

End
