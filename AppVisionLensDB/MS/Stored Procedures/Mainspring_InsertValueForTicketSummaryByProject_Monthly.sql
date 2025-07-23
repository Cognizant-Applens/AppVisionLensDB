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

-- Description:
-- =============================================

--EXEC [dbo].[Mainspring_InsertValueForServiceBaseMeasureByProject] 
CREATE PROCEDURE [MS].[Mainspring_InsertValueForTicketSummaryByProject_Monthly]
	@ProjectStageID INT,
	@UniqueName varchar(500),
	@FrequencyID INT,
	@ReportPeriodID VARCHAR(50),
	@TicketSummaryValue VARCHAR(50)=NULL,
	@UpdatedDate VARCHAR(50)=NULL,
	@JobID INT=NULL,
	@MetricStartDate VARCHAR(50)=NULL,
	@MetricendDate VARCHAR(50)=NULL
	 

AS
BEGIN

	SET NOCOUNT ON;
	--DECLARE @ProjectStageIDExists INT;
	--SET @ProjectStageIDExists=(SELECT COUNT(*) FROM TRN.Mainspring_ProjectStaging_TillDateBaseMeasure_TicketSummary
	--							WHERE   ProjectStageID=@ProjectStageID)
	--IF @ProjectStageIDExists > 0
	--	BEGIN
	--	--Indicates already existing record to update
	--	UPDATE TRN.Mainspring_ProjectStaging_MonthlyBaseMeasure_TicketSummary
	--	SET UniqueName= @UniqueName,FrequencyID= @FrequencyID,ReportPeriodID= @ReportPeriodID,
	--	 TicketSummaryValue = @TicketSummaryValue,UpdatedDate= @UpdatedDate,JobID= @JobID,
	--	MetricStartDate= @MetricStartDate,MetricEndDate= @MetricendDate
		
	--	END
	--ELSE
	--	BEGIN
		--Indicates a insert to the table
		INSERT INTO MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary
		(ProjectStageID,UniqueName,FrequencyID,ReportPeriodID,TicketSummaryValue,UpdatedDate,JobID,MetricStartDate,MetricEndDate)
		VALUES(@ProjectStageID,@UniqueName,@FrequencyID,@ReportPeriodID,@TicketSummaryValue,@UpdatedDate,@JobID,@MetricStartDate,@MetricendDate)
		--END

	
	SET NOCOUNT OFF;  
END


