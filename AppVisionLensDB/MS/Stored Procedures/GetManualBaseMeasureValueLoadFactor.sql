/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
--exec [MS].[GetManualBaseMeasureValueLoadFactor]'19986','Load Factor',72018
CREATE PROCEDURE [MS].[GetManualBaseMeasureValueLoadFactor]
(
@ProjectID  nvarchar(30),
--@MetricName  nvarchar(30),
@ReportPeriodID INT
) 
AS  
BEGIN  
SET NOCOUNT ON;
SELECT BaseMeasureValue FROM MS.TRN_Mainspring_ProjectStaging_BaseMeasure_ProjectSpecific_Manual(NOLOCK)
WHERE  ProjectID IN (@ProjectID) AND ReportPeriodID=@ReportPeriodID
SET NOCOUNT OFF;
End
