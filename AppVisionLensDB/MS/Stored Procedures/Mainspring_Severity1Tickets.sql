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

-- Description:Gets the severity one tickets
-- =============================================

--EXEC [MS].[Mainspring_Severity1Tickets] @ProjectID=21328,@ServiceID=31,@StartDate='2018-06-01',@EndDate='2018-06-13',@Priority='',@SupportCategory=''
CREATE PROCEDURE [MS].[Mainspring_Severity1Tickets]
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
	SELECT COUNT(*) AS Severity1 from AppVisionLensOffline.RPT.TK_TRN_TicketDetail(NOLOCK) TM
	INNER JOIN AVL.TK_MAS_Service (NOLOCK) SM
	ON TM.ServiceID=SM.ServiceID
	INNER JOIN AVL.TK_MAP_SeverityMapping(NOLOCK) PSD 
	ON TM.SeverityMapID = PSD.SeverityIDMapID AND TM.ProjectID = PSD.ProjectID
	INNER JOIN AVL.TK_MAS_Severity (NOLOCK) DSM 
	ON PSD.SeverityID = DSM.SeverityID
	WHERE DSM.SeverityID = 1 AND TM.ProjectID = @ProjectID
	AND TM.OpenDateTime >=@StartDate and tm.OpenDateTime < @EndDate
	AND SM.ServiceID=@ServiceID
	SET NOCOUNT OFF;  
END





