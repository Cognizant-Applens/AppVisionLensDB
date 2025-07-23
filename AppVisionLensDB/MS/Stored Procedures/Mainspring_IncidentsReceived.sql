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

-- Description:Total Number of New Unknown Incident  received in the reporting period- 
--All tickets opened in reporting month irrespective of status (ignore cancelled)
-- =============================================

--EXEC [MS].[Mainspring_IncidentsReceived] @ProjectID=40635,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-22',@Priority=NULL,@SupportCategory=NULL,@Technology=NULL
--EXEC [MS].[Mainspring_IncidentsReceived] @ProjectID=40635,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-22',@Priority=1,@SupportCategory=NULL,@Technology=NULL
--EXEC [MS].[Mainspring_IncidentsReceived]  @ProjectID=40635,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-22',@Priority=NULL,@SupportCategory=435,@Technology=NULL
--EXEC [MS].[Mainspring_IncidentsReceived]  @ProjectID=40635,@ServiceID=4,@StartDate='2018-06-01',@EndDate='2018-06-22',@Priority=1,@SupportCategory=435,@Technology='High Level'

CREATE PROCEDURE [MS].[Mainspring_IncidentsReceived]
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
	 
	 CREATE TABLE #TECHNOLOGY
	 (
		ApplicationID INT,
		ProjectID INT
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
			INNER JOIN AVL.APP_MAP_ApplicationProjectMapping APM WITH(NOLOCK) ON AA.ApplicationID=APM.ApplicationID
			INNER JOIN MS.MAP_ProjectSUPPORTCATEGORY_Mapping MSCMP WITH(NOLOCK) ON APM.MainspringSUPPORTCATEGORYID=MSCMP.MainSpringProjectSUPPORTCATEGORYID
			INNER JOIN MS.MAS_SUPPORTCATEGORY_Master MSC WITH(NOLOCK) ON MSC.MainspringSUPPORTCATEGORYID=MSCMP.SUPPORTCATEGORYID
			INNER JOIN AVL.MAS_ProjectMaster PM WITH(NOLOCK) ON PM.EsaProjectID=MSCMP.ESAProjectID
			WHERE PM.ProjectID=@ProjectID AND MSC.MainspringSUPPORTCATEGORYID=@SupportCategory
	END
	ELSE
	BEGIN
	
			INSERT INTO #SUPPORTCATEGORY VALUES (NULL,NULL,NULL,NULL)
	END
	
	IF (@Technology IS NOT NULL)
	BEGIN
			 INSERT INTO #TECHNOLOGY
			SELECT AA.ApplicationID,APM.ProjectID FROM AVL.APP_MAS_ApplicationDetails AA WITH(NOLOCK)
			INNER JOIN AVL.APP_MAP_ApplicationProjectMapping APM WITH(NOLOCK) ON AA.ApplicationID=APM.ApplicationID
			INNER JOIN AVL.APP_MAS_PrimaryTechnology T WITH(NOLOCK) ON AA.PrimaryTechnologyID=T.PrimaryTechnologyID
			INNER JOIN MS.MAS_TechnologyLanguage_Master TLM WITH(NOLOCK) ON T.PrimaryTechnologyName=TLM.MainspringTechnologyName
			INNER JOIN  MS.MAS_TechnologyType MTT WITH(NOLOCK) ON MTT.MainspringTechType=TLM.MainspringTechnologyLanguageName 
			WHERE APM.ProjectID=@ProjectID AND MTT.MainspringTechType=@Technology
	END
	ELSE
	BEGIN
			INSERT INTO #TECHNOLOGY VALUES (NULL,NULL)
	END
	
	SET @EndDate=CONVERT(DATETIME,@EndDate)+1
	
	SELECT COUNT(*) AS IncidentsReceived FROM AppVisionLensOffline.RPT.TK_TRN_TicketDetail(NOLOCK) TM
	INNER JOIN AVL.TK_MAS_Service SM WITH(NOLOCK)
	ON TM.ServiceId=SM.ServiceID 
	INNER JOIN #PRIORITY P WITH(NOLOCK) ON  TM.PriorityMapID =ISNULL(P.PriorityID,TM.PriorityMapID) 
	INNER JOIN #SUPPORTCATEGORY SC  WITH(NOLOCK) ON TM.ApplicationID = ISNULL(SC.ApplicationID,TM.ApplicationID)
	INNER JOIN #TECHNOLOGY T WITH(NOLOCK) ON TM.ApplicationID = ISNULL(T.ApplicationID,TM.ApplicationID)
	AND TM.ProjectId=@ProjectID AND TM.ServiceId=@ServiceID 
	AND TM.OpenDateTime >= @StartDate AND TM.OpenDateTime < @EndDate
	AND TM.DARTStatusID NOT IN(5,7,13)
	
	DROP TABLE #PRIORITY
	DROP TABLE #SUPPORTCATEGORY
	DROP TABLE #TECHNOLOGY
	
	SET NOCOUNT OFF;  
END




