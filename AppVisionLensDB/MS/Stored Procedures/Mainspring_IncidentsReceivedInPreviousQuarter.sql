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

-- Description:	Incidents received in previous quarter
-- =============================================

--EXEC [MS].[Mainspring_IncidentsReceivedInPreviousQuarter] @ProjectID=40635,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-22',@Priority=NULL,@SupportCategory=NULL,@Technology=NULL
--EXEC [MS].[Mainspring_IncidentsReceivedInPreviousQuarter] @ProjectID=40635,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-22',@Priority=1,@SupportCategory=NULL,@Technology=NULL
--EXEC [MS].[Mainspring_IncidentsReceivedInPreviousQuarter]  @ProjectID=40635,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-22',@Priority=NULL,@SupportCategory=435,@Technology=NULL
--EXEC [MS].[Mainspring_IncidentsReceivedInPreviousQuarter]  @ProjectID=40635,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-22',@Priority=1,@SupportCategory=435,@Technology='High Level'

CREATE PROCEDURE [MS].[Mainspring_IncidentsReceivedInPreviousQuarter]
	@ProjectID BIGINT,
	@ServiceID int = null,
	@StartDate VARCHAR(50)=NULL,
	@EndDate VARCHAR(50)=NULL,
	@Priority INT=NULL,
	@SupportCategory INT=NULL,
	@Technology VARCHAR(20)=NULL

	 

AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @Date VARCHAR(50)
	DECLARE @StartDateOfQuarter DATETIME
	DECLARE @EndDateOfQuarter DATETIME
	set @Date = @StartDate
	--When datetime stamp is given

	SET @StartDateOfQuarter=(SELECT DATEADD(qq, DATEDIFF(qq, 0, @Date) - 1, 0))
	SET @EndDateOfQuarter=(SELECT DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @Date), 0)))

	--SELECT @StartDateOfQuarter AS QuarterStartDate
	--SELECT @EndDateOfQuarter AS QuarterEndDate
	
	SELECT COUNT(*) AS IncidentsReceivedInPreviousQuarter FROM 
	AppVisionLensOffline.RPT.TK_TRN_TicketDetail(NOLOCK) TM
	WHERE TM.ProjectId=@ProjectID 
	AND TM.OpenDateTime >=@StartDateOfQuarter and TM.OpenDateTime <= @EndDateOfQuarter
	AND TM.ServiceID IN(1,4)
	
	SET NOCOUNT OFF;  
END


