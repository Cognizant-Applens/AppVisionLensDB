/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [MS].[Mainspring_InsertValueForServiceBaseMeasureNonDARTByProject_Monthly]  
 @lstBaseMeasureData MS.[Mainspring_BaseMeasureNonDARTProject_TVP] READONLY,  
 @ProjectID INT,  
 @ReportingPeriod INT,  
 @FrequencyId INT  
    
  
AS  
BEGIN  
  
 SET NOCOUNT ON;  
  
  --Indicates a insert to the table  
    
  DELETE RealTable  
 FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure  RealTable  
 INNER JOIN @lstBaseMeasureData TempTable  
 ON RealTable.ProjectStageID=TempTable.ProjectStageID AND RealTable.UniqueName=TempTable.UniqueName  
 WHERE   
 RealTable.FrequencyID=@FrequencyID AND   
 RealTable.ReportPeriodID=@ReportingPeriod  
   
  INSERT INTO MS.TRN_ProjectStaging_MonthlyBaseMeasure (ProjectStageID,  
  UniqueName,FrequencyID,  
  ReportPeriodID,BaseMeasureValue,UpdatedDate,JobID,MetricStartDate,MetricEndDate)  
  SELECT ProjectStageID,UniqueName,@FrequencyId,  
  @ReportingPeriod,BaseMeasureValue,UpdatedDate,JobID,MetricStartDate,MetricendDate  
  FROM @lstBaseMeasureData  
  
 SET NOCOUNT OFF;    
END  
  

