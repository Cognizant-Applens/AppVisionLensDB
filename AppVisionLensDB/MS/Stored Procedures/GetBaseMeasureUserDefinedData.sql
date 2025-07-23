/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/




--EXEC [MS].[GetBaseMeasureUserDefinedData]  062018
CREATE PROCEDURE [MS].[GetBaseMeasureUserDefinedData]     
@ReportPeriod VARCHAR(50)  
  
AS  
BEGIN  
  
 SET NOCOUNT ON;  
   
    SELECT BUD.ProjectID,BUD.ServiceID,BUD.BaseMeasureID,BUD.FrequencyID,BUD.ReportPeriodID,
	BUD.BaseMeasureValue,BUD.CreatedBy  
     FROM MS.TRN_BaseMeasureUserDefinedData BUD WITH(NOLOCK)
     INNER JOIN  MS.MAS_BaseMeasure_Master MBM WITH(NOLOCK) ON MBM.BaseMeasureID=BUD.BaseMeasureID and MBM.IsDeleted=0
     WHERE BUD.ReportPeriodID=@ReportPeriod  
      
 SET NOCOUNT OFF;    
END  

--SELECT * FROM MS.TRN_BaseMeasureUserDefinedData


