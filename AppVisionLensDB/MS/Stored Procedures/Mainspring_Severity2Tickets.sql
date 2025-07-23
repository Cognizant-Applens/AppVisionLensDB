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

-- Description:Gets the severity two tickets
-- =============================================

--EXEC [MS].[Mainspring_Severity2Tickets] @ProjectID=19100,@ServiceID=4,@StartDate='2012-11-01',@EndDate='2016-12-10',@Priority='',@SupportCategory=''
CREATE PROCEDURE [MS].[Mainspring_Severity2Tickets]
	@ProjectID BIGINT,
	@ServiceID INT,
	@StartDate VARCHAR(50),
	@EndDate VARCHAR(50),
	@Priority INT=NULL,
	@SupportCategory INT=NULL,
	@Technology VARCHAR(20)=NULL
	 

AS
BEGIN

	SET NOCOUNT ON;
	
	SET @EndDate=CONVERT(DATETIME,@EndDate)+1

	SELECT COUNT(*) AS Severity2 from AppVisionLensOffline.RPT.TK_TRN_TicketDetail(NOLOCK) TM
	INNER JOIN AVL.TK_MAS_Service SM WITH(NOLOCK)
	ON TM.ServiceID=SM.ServiceID
	INNER JOIN AVL.TK_MAP_SeverityMapping(NOLOCK) PSD 
	ON TM.SeverityMapID = PSD.SeverityIDMapID AND TM.ProjectID = PSD.ProjectID
	INNER JOIN AVL.TK_MAS_Severity  (NOLOCK) DSM 
	ON PSD.SeverityID = DSM.SeverityID
	WHERE DSM.SeverityID = 2 AND TM.ProjectID = @ProjectID
	AND TM.OpenDateTime >=@StartDate and tm.OpenDateTime < @EndDate
	AND SM.ServiceID=@ServiceID

	SET NOCOUNT OFF;  
END



