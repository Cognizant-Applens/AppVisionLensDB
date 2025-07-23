/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC [dbo].[Mainspring_InsertValueForServiceBaseMeasureByProject] 
CREATE PROCEDURE [MS].[Mainspring_InsertValueForTicketSummaryByProject]
	@ProjectStageID INT,
	@UniqueName Nvarchar(500),
	@FrequencyID INT,
	@ReportPeriodID NVARCHAR(50),
	@TicketSummaryValue NVARCHAR(50)=NULL,
	@UpdatedDate NVARCHAR(50)=NULL,
	@JobID INT=NULL,
	@MetricStartDate NVARCHAR(50)=NULL,
	@MetricendDate NVARCHAR(50)=NULL
	 

AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @ProjectStageIDExists INT;
	SET @ProjectStageIDExists=(SELECT COUNT(*) FROM MS.TRN_ProjectStaging_TillDateBaseMeasure_TicketSummary
								WHERE   ProjectStageID=@ProjectStageID)
	IF @ProjectStageIDExists > 0
		BEGIN
		--Indicates already existing record to update
		UPDATE MS.TRN_ProjectStaging_TillDateBaseMeasure_TicketSummary
		SET UniqueName= @UniqueName,FrequencyID= @FrequencyID,ReportPeriodID= @ReportPeriodID,
		 TicketSummaryValue = @TicketSummaryValue,UpdatedDate= @UpdatedDate,JobID= @JobID,
		MetricStartDate= @MetricStartDate,MetricEndDate= @MetricendDate
		
		END
	ELSE
		BEGIN
		--Indicates a insert to the table
		INSERT INTO MS.TRN_ProjectStaging_TillDateBaseMeasure_TicketSummary 
		(ProjectStageID,UniqueName,FrequencyID,ReportPeriodID,TicketSummaryValue,UpdatedDate,JobID,MetricStartDate,MetricEndDate)
		VALUES(@ProjectStageID,@UniqueName,@FrequencyID,@ReportPeriodID,@TicketSummaryValue,@UpdatedDate,@JobID,@MetricStartDate,@MetricendDate)
		END

	
	SET NOCOUNT OFF;  
END


