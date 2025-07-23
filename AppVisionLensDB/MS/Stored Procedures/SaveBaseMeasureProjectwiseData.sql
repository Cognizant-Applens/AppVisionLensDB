/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [MS].[SaveBaseMeasureProjectwiseData]
	@ProjectID INT,
	@FrequencyID INT=NULL,
	@ReportFrequencyID INT=NULL,
	@UserID VARCHAR(50)=NULL,
	@TVP MS.BaseMeasureUserDefinedData_TVP READONLY
AS
BEGIN
SET NOCOUNT ON;
	
	DELETE RealTable
	FROM MS.TRN_BaseMeasureUserDefinedData RealTable
	INNER JOIN @TVP TempTable
	ON RealTable.ServiceID=TempTable.ServiceID AND RealTable.BaseMeasureID=TempTable.BaseMeasureID
	WHERE 
	RealTable.ProjectID=@ProjectID AND RealTable.FrequencyID=@FrequencyID AND RealTable.ReportPeriodID=@ReportFrequencyID
	
	
	INSERT INTO MS.TRN_BaseMeasureUserDefinedData
	([ProjectID],[ServiceID],[BaseMeasureID],[FrequencyID],[ReportPeriodID],[BaseMeasureValue],[CreatedBy],[CreatedOn])
	SELECT @ProjectID,[ServiceID],[BaseMeasureID],@FrequencyID,@ReportFrequencyID,[BaseMeasureValue],@UserID, GETDATE() FROM @TVP
END



