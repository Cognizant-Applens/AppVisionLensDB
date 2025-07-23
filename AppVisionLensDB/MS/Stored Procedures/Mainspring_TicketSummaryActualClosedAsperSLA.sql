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

-- Description:	Consider the no. of tickets with status as 
--closed and closed date falling
-- in the reporting period with Resolution SLA as Yes
-- =============================================


--EXEC [MS].[Mainspring_TicketSummaryActualClosedAsperSLA] @ProjectID=40635,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-21',@Priority=NULL,@SupportCategory=NULL
--EXEC [MS].[Mainspring_TicketSummaryActualClosedAsperSLA] @ProjectID=40635,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-21',@Priority=2,@SupportCategory=NULL
--EXEC [MS].[Mainspring_TicketSummaryActualClosedAsperSLA] @ProjectID=40635,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-21',@Priority=NULL,@SupportCategory=433
--EXEC [MS].[Mainspring_TicketSummaryActualClosedAsperSLA] @ProjectID=40635,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-21',@Priority=1,@SupportCategory=433

CREATE PROCEDURE [MS].[Mainspring_TicketSummaryActualClosedAsperSLA]
	@ProjectID BIGINT,
	@ServiceID INT,
	@StartDate VARCHAR(50),
	@EndDate VARCHAR(50),
	@Priority INT=NULL,
	@SupportCategory INT=NULL

AS
BEGIN

	SET NOCOUNT ON;
		
	CREATE TABLE #PRIORITY
	 (
		ProjectID INT,
		MainSpringProjectPriorityID INT,
		MainspringPriorityID INT,
		PriorityID INT
	 )
	
	 CREATE TABLE #SUPPORTCATEGORY
	 (
		ProjectID INT,
		ApplicationID INT,
		MainSpringProjectSUPPORTCATEGORYID INT,
		MainspringSUPPORTCATEGORYID INT
	 ) 

	 
	IF (@Priority IS NOT NULL)
	BEGIN
			INSERT INTO #PRIORITY 
			SELECT PM.ProjectID,PMAP.MainSpringProjectPriorityID,MPM.MainspringPriorityID,P.PriorityIDMapID AS PriorityID 
			FROM MS.MAS_Priority_Master(NOLOCK) MPM
			INNER JOIN  MS.MAP_ProjectPriority_Mapping(NOLOCK) PMAP ON MPM.MainspringPriorityID=PMAP.PriorityID
			INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PMAP.ESAProjectID=PM.EsaProjectID
			INNER JOIN AVL.TK_MAP_PriorityMapping(NOLOCK) P ON MPM.MainspringPriorityName=P.PriorityName AND PM.ProjectID=P.ProjectID
			WHERE PM.ProjectID=@ProjectID AND MPM.MainspringPriorityID=@Priority
			
			
	END
	ELSE
	BEGIN
			INSERT INTO #PRIORITY VALUES (NULL,NULL,NULL,NULL)
	END
	
	IF (@SupportCategory IS NOT NULL)
	BEGIN
			INSERT INTO #SUPPORTCATEGORY 
			SELECT PM.ProjectID,AA.ApplicationID,MSCMP.MainSpringProjectSUPPORTCATEGORYID,MSC.MainspringSUPPORTCATEGORYID 
			FROM AVL.APP_MAS_ApplicationDetails AA WITH(NOLOCK)
			INNER JOIN AVL.APP_MAP_ApplicationProjectMapping APM  WITH(NOLOCK) ON AA.ApplicationID=APM.ApplicationID
			INNER JOIN MS.MAP_ProjectSUPPORTCATEGORY_Mapping MSCMP WITH(NOLOCK) ON APM.MainspringSUPPORTCATEGORYID=MSCMP.MainSpringProjectSUPPORTCATEGORYID
			INNER JOIN MS.MAS_SUPPORTCATEGORY_Master MSC  WITH(NOLOCK) ON MSC.MainspringSUPPORTCATEGORYID=MSCMP.SUPPORTCATEGORYID
			INNER JOIN AVL.MAS_ProjectMaster PM  WITH(NOLOCK) ON PM.EsaProjectID=MSCMP.ESAProjectID
			WHERE PM.ProjectID=@ProjectID AND MSC.MainspringSUPPORTCATEGORYID=@SupportCategory
	END
	ELSE
	BEGIN
	
			INSERT INTO #SUPPORTCATEGORY VALUES (NULL,NULL,NULL,NULL)
	END

	SET @EndDate=CONVERT(DATETIME,@EndDate)+1
	
	SELECT COUNT(*) AS TicketSummaryActualClosedAsperSLA
	 FROM AppVisionLensOffline.RPT.TK_TRN_TicketDetail(NOLOCK) TM
	INNER JOIN AVL.TK_MAS_Service SM WITH(NOLOCK)
	ON TM.ServiceId=SM.ServiceID 
	AND TM.DARTStatusID=8
	INNER JOIN #PRIORITY P WITH(NOLOCK) ON TM.PriorityMapID =ISNULL(P.PriorityID,TM.PriorityMapID) 
	INNER JOIN #SUPPORTCATEGORY SC WITH(NOLOCK) ON TM.ApplicationID = ISNULL(SC.ApplicationID,TM.ApplicationID)
	WHERE TM.ProjectID=@ProjectID AND TM.ServiceId=@ServiceID 
	AND TM.Closeddate >= @StartDate AND TM.Closeddate < @EndDate
	AND TM.[MetResolutionMapID] in(1) --for yes
	
	--select *from AVL.TK_MAS_MetSLACondition

	DROP TABLE #PRIORITY
	DROP TABLE #SUPPORTCATEGORY

	
	SET NOCOUNT OFF;  
END



