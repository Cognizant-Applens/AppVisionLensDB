/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [MS].[SaveOverallBaseMeasureProjectwiseData]
	@ProjectID INT,
	@FrequencyID INT=NULL,
	@ReportFrequencyID INT=NULL,
	@UserID VARCHAR(50)=NULL,
	@GridDetails [dbo].[TVP_MSOverallBaseMeasureData] READONLY 
AS
BEGIN
SET NOCOUNT ON;
	
	UPDATE [MS].[TRN_ManualOverallBaseMeasureData] SET Priority=''
	WHERE Priority IS NULL and  ProjectID=@ProjectID and ReportPeriodID=@ReportFrequencyID
	UPDATE [MS].[TRN_ManualOverallBaseMeasureData] SET SUPPORTCATEGORY=''
	WHERE SUPPORTCATEGORY IS NULL and ProjectID=@ProjectID and ReportPeriodID=@ReportFrequencyID
	UPDATE [MS].[TRN_ManualOverallBaseMeasureData] SET TECHNOLOGY=''
	WHERE TECHNOLOGY IS NULL and ProjectID=@ProjectID and ReportPeriodID=@ReportFrequencyID

	DELETE RealTable
	FROM [MS].[TRN_ManualOverallBaseMeasureData] RealTable
	INNER JOIN @GridDetails TempTable
	ON RealTable.ServiceID=TempTable.ServiceID  
	AND RealTable.BaseMeasureID=TempTable.BaseMeasureID 
	AND ((RealTable.Priority=TempTable.MainspringPriorityID) OR (RealTable.Priority='' AND TempTable.MainspringPriorityID=''))
	AND ((RealTable.SupportCategory=TempTable.MainspringSUPPORTCATEGORYID) OR (RealTable.SupportCategory='' AND TempTable.MainspringSUPPORTCATEGORYID=''))
	AND ((RealTable.Technology=TempTable.MainspringTechnology) OR (RealTable.Technology='' AND TempTable.MainspringTechnology=''))
	WHERE 
	RealTable.ProjectID=@ProjectID AND RealTable.FrequencyID=@FrequencyID 
	AND RealTable.ReportPeriodID=@ReportFrequencyID
	
	
	INSERT INTO [MS].[TRN_ManualOverallBaseMeasureData]
	([ProjectID],[ServiceID],BaseMeasureID,[Priority],SupportCategory,Technology,
	[FrequencyID],[ReportPeriodID],BaseMeasureValue,[CreatedBy],[CreatedOn])
	SELECT @ProjectID,ServiceID,[BaseMeasureID],MainspringPriorityID,
	MainspringSUPPORTCATEGORYID,[MainspringTechnology]
	,@FrequencyID,@ReportFrequencyID,
	[BaseMeasureValue],@UserID, GETDATE() FROM @GridDetails
	SET NOCOUNT OFF;
END

