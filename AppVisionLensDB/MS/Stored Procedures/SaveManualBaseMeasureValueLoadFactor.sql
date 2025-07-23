/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/



CREATE PROCEDURE [MS].[SaveManualBaseMeasureValueLoadFactor]
(
@ProjectID  nvarchar(30),
@MetricName  nvarchar(30),
@ReportPeriodID INT,
@BaseMeasureValue  nvarchar(30)
) 
AS  
BEGIN  

SET NOCOUNT ON;
IF EXISTS(SELECT 1 From MS.TRN_Mainspring_ProjectStaging_BaseMeasure_ProjectSpecific_Manual WITH(NOLOCK)

Where ProjectID=@ProjectID AND UniqueName=@MetricName AND ReportPeriodID=@ReportPeriodID)
      BEGIN
          UPDATE MS.TRN_Mainspring_ProjectStaging_BaseMeasure_ProjectSpecific_Manual
          SET BaseMeasureValue=@BaseMeasureValue,UpdatedDate=getdate()
          WHERE ProjectID=@ProjectID AND UniqueName=@MetricName AND ReportPeriodID=@ReportPeriodID
		  select 2 As Result
       END
    ELSE
      BEGIN      
         INSERT INTO MS.TRN_Mainspring_ProjectStaging_BaseMeasure_ProjectSpecific_Manual
         VALUES(@ProjectID,@MetricName,4,@ReportPeriodID,@BaseMeasureValue,getdate(),NULL,NULL,NULL)
		 select 1 As Result
       END
SET NOCOUNT OFF;
END
