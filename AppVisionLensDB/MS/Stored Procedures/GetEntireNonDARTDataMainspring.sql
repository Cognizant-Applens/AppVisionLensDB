/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC [MS].GetEntireNonDARTDataMainspring  @ReportPeriod=062018
CREATE PROCEDURE [MS].[GetEntireNonDARTDataMainspring] 

@ReportPeriod VARCHAR(50)

AS
BEGIN

	SET NOCOUNT ON;

	select * into #TRN_ManualOverallBaseMeasureData
	 FROM MS.TRN_ManualOverallBaseMeasureData(NOLOCK)
    WHERE ReportPeriodID=@ReportPeriod
	UPDATE #TRN_ManualOverallBaseMeasureData set Priority=NULL
	where Priority=''
	UPDATE #TRN_ManualOverallBaseMeasureData set supportcategory=NULL
	where SupportCategory=''
    --for Base Measures 
    SELECT 
     ProjectID AS ProjectID,ServiceID AS ServiceID,BaseMeasureID AS BaseMeasureID,
      ISNULL(Priority,0) AS Priority,ISNULL(SupportCategory,0) AS SupportCategory,ISNULL(Technology,'') AS Technology,
    FrequencyID AS FrequencyID,ReportPeriodID AS ReportPeriodID,
    BaseMeasureValue AS BaseMeasureValue,CreatedBy AS CreatedBy,
    CreatedOn AS CreatedOn,ModifiedBy AS ModifiedBy,ModifiedOn AS ModifiedOn
     FROM #TRN_ManualOverallBaseMeasureData(NOLOCK)
    WHERE ReportPeriodID=@ReportPeriod
    SELECT 
    ProjectID AS ProjectID,ServiceID AS ServiceID,
    TicketSummaryBaseMeasureID AS TicketSummaryBaseMeasureID,
    ISNULL(Priority,0) AS Priority,ISNULL(SupportCategory,0) AS SupportCategory,FrequencyID AS FrequencyID,
    ReportPeriodID AS ReportPeriodID,TicketBaseMeasureValue AS TicketBaseMeasureValue,
    CreatedBy AS CreatedBy,CreatedOn AS CreatedOn,ModifiedBy AS ModifiedBy,ModifiedBy AS ModifiedBy
    FROM MS.TRN_ManualTicketSummaryBaseMeasureData(NOLOCK)
    WHERE ReportPeriodID=@ReportPeriod

     SELECT ProjectId AS ProjectId,ProjectName AS ProjectName 
    FROM AVL.MAS_ProjectMaster(NOLOCK) PM
    WHERE IsMainSpringConfigured='Y' AND ISNULL(IsODCRestricted,'N')='Y' AND ISNULL(IsDeleted,0)=0
    
    
	SET NOCOUNT OFF;  
END


--SELECT * FROM AVL.MAS_ProjectMaster

