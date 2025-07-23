/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [MS].[Mainspring_InsertValueForTicketSummaryNonDARTByProject_Monthly]    
 @lstTicketBaseMeasureData MS.Mainspring_TicketBaseMeasureNonDARTProject_TVP READONLY,    
 @ProjectID INT,    
 @ReportingPeriod INT,    
 @FrequencyId INT    
      
    
AS    
BEGIN    
    
 SET NOCOUNT ON;    
  DELETE RealTable    
 FROM MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary   RealTable    
 INNER JOIN @lstTicketBaseMeasureData TempTable    
 ON RealTable.ProjectStageID=TempTable.ProjectStageID AND RealTable.UniqueName=TempTable.UniqueName    
 WHERE     
 RealTable.FrequencyID=@FrequencyID AND     
 RealTable.ReportPeriodID=@ReportingPeriod    
     
  INSERT INTO MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary(ProjectStageID,    
  UniqueName,FrequencyID,    
  ReportPeriodID,TicketSummaryValue,UpdatedDate,JobID,MetricStartDate,MetricEndDate)    
  SELECT ProjectStageID,UniqueName,@FrequencyId,    
  @ReportingPeriod,TicketSummaryValue,UpdatedDate,JobID,MetricStartDate,MetricendDate    
  FROM @lstTicketBaseMeasureData    
     
 SET NOCOUNT OFF;      
END 

