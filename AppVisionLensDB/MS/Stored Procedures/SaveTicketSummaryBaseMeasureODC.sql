/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [MS].[SaveTicketSummaryBaseMeasureODC]
	@ProjectID INT,
	@FrequencyID INT=NULL,
	@ReportFrequencyID INT=NULL,
	@UserID VARCHAR(50)=NULL,
	@GridDetails MS.TicketSummaryBaseMeasureOdc_TVP READONLY
AS
BEGIN
SET NOCOUNT ON;
	
	UPDATE MS.TRN_ManualTicketSummaryBaseMeasureData SET Priority=''
	WHERE Priority IS NULL and  ProjectID=@ProjectID and ReportPeriodID=@ReportFrequencyID
	UPDATE MS.TRN_ManualTicketSummaryBaseMeasureData SET SUPPORTCATEGORY=''
	WHERE SUPPORTCATEGORY IS NULL and  ProjectID=@ProjectID and ReportPeriodID=@ReportFrequencyID

	
	DELETE RealTable
	FROM MS.TRN_ManualTicketSummaryBaseMeasureData  RealTable
	INNER JOIN @GridDetails TempTable
	ON RealTable.ServiceID=TempTable.ServiceID AND 
	RealTable.TicketSummaryBaseMeasureID=TempTable.TicketSummaryBaseMeasureID
	AND ((RealTable.Priority=TempTable.MainspringPriorityID) OR (RealTable.Priority='' AND TempTable.MainspringPriorityID=''))
	AND ((RealTable.SupportCategory=TempTable.MainspringSUPPORTCATEGORYID) OR (RealTable.SupportCategory='' AND TempTable.MainspringSUPPORTCATEGORYID=''))
	WHERE 
	RealTable.ProjectID=@ProjectID AND RealTable.FrequencyID=@FrequencyID AND RealTable.ReportPeriodID=@ReportFrequencyID
	
	
	INSERT INTO MS.TRN_ManualTicketSummaryBaseMeasureData
	([ProjectID],[ServiceID],TicketSummaryBaseMeasureID,[Priority],SupportCategory,
	[FrequencyID],[ReportPeriodID],TicketBaseMeasureValue,[CreatedBy],[CreatedOn])
	SELECT @ProjectID,ServiceID,TicketSummaryBaseMeasureID,MainspringPriorityID,
	MainspringSUPPORTCATEGORYID
	,@FrequencyID,@ReportFrequencyID,
	TicketBaseMeasureValue,@UserID, GETDATE() FROM @GridDetails
END






