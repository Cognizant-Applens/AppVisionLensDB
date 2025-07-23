/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


-- ============================================================================
-- Author:      Prakash     
-- Create date:      23 Nov 2018
-- Description:   get configuration data
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- [AVL].[Mini_GetConfigurationDetailsByEmployee] '245829'

-- ============================================================================ 
--[AVL].[Mini_GetConfigurationDetailsByEmployee] '245829'
CREATE Procedure [AVL].[Mini_GetConfigurationDetailsByEmployee] 
@EmployeeID NVARCHAR(50)=null 
AS
BEGIN
	BEGIN TRY
	SELECT UserID,ProjectID,EmployeeID,CustomerID,TimeZoneId INTO #MAS_LoginMaster FROM [AVL].[MAS_LoginMaster](NOLOCK) 
	WHERE EmployeeID = @EmployeeID  AND IsDeleted=0 AND ISNULL(ISMINICONFIGURED,1)=1

	UPDATE #MAS_LoginMaster SET TimeZoneId=NULL WHERE TimeZoneId=0

	CREATE TABLE #UserProjectDetails
	(
		SNO INT IDENTITY(1,1),
		UserID BigINT,
		ProjectID BigINT,
		CustomerID BigINT,
		UserTimeZoneId INT NULL,
		UserTimeZoneName NVARCHAR(100)
	)
	INSERT INTO #UserProjectDetails
	SELECT UserID,ProjectID,CustomerID,ISNULL(LM.TimeZoneID,32) AS TimeZoneID,
	TM.TZoneName AS UserTimeZoneName  FROM #MAS_LoginMaster LM
	LEFT JOIN AVL.MAS_TimeZoneMaster TM ON ISNULL(LM.TimeZoneId,32) = TM.TimeZoneID
	WHERE EmployeeID = @EmployeeID 

	SELECT ProjectID,EsaProjectID,CustomerID,ProjectName,IsDebtEnabled,IsMainSpringConfigured
	 INTO #ProjectDetails FROM AVL.MAS_ProjectMaster(NOLOCK) 
	WHERE ProjectID IN(SELECT DISTINCT ProjectID FROM #UserProjectDetails)

	SELECT C.CustomerId AS CustomerId,
	c.CustomerName AS CustomerName,
	ISNULL(C.IsCognizant,1)	AS IsCognizant,
	ISNULL(C.IsEffortTrackActivityWise,1) AS IsActivityTracked,
	ISNULL(C.IsITSMEffortConfigured,0)	AS IsITSMLinked,
	ISNULL(C.IsEffortConfigured,0)		AS IsEffortTracked,
	C.IsDaily
	INTO #CustomerDetails
	 FROM AVL.Customer(NOLOCK) C
	WHERE C.CustomerID IN(SELECT DISTINCT CustomerID FROM #UserProjectDetails)

	--User Details
	SELECT UserID,ProjectID,CustomerID,UserTimeZoneId,UserTimeZoneName  FROM #UserProjectDetails

	--Customer Details
	SELECT CustomerId,CustomerName,IsCognizant,IsEffortTracked,IsITSMLinked,IsActivityTracked,IsDaily FROM #CustomerDetails
	
	--Project Details
	SELECT PM.ProjectID,
	CD.CustomerID,
	ISNULL(CASE WHEN PM.IsDebtEnabled='Y' THEN 1 ELSE 0 END,0)			AS IsDebtEnabled,
	ISNULL(CASE WHEN PM.IsMainspringConfigured='Y' THEN 1 ELSE 0 END,0)	AS IsMainSpringConfigured,
	PM.EsaProjectID AS EsaProjectID,PM.ProjectName AS ProjectName,
	ISNULL(PC.TimeZoneId,32) AS ProjectTimeZoneID,
	TM.TZoneName AS ProjectTimeZoneName 	

	FROM #ProjectDetails PM
	INNER JOIN #CustomerDetails CD
	ON PM.CustomerID=CD.CustomerID
	INNER JOIN #UserProjectDetails UPD
	ON PM.ProjectID=UPD.ProjectID
	LEFT JOIN AVL.MAP_ProjectConfig PC ON PM.ProjectID = PC.ProjectID
	LEFT JOIN AVL.MAS_TimeZoneMaster TM ON ISNULL(PC.TimeZoneId,32) = TM.TimeZoneID
	ORDER BY  PM.ProjectName ASC --UPD.CustomerID,PC.ProjectID

	--service details
	select distinct PM.CustomerID,PSAM.ProjectID,SM.ServiceID,SM.ServiceName,STM.ServiceTypeID,SAM.ActivityID,SAM.ActivityName,
	ISNULL(SM.ServiceLevelID,0) AS ServiceLevelID  from avl.TK_MAS_Service (NOLOCK)  SM
	INNER JOIN AVL.TK_MAS_ServiceType (NOLOCK) STM ON STM.ServiceTypeID=SM.ServiceType
	INNER JOIN AVL.TK_MAS_ServiceActivityMapping(NOLOCK) SAM ON SAM.ServiceTypeID = STM.ServiceTypeID AND SAM.ServiceID = SM.ServiceID
	INNER JOIN avl.TK_PRJ_ProjectServiceActivityMapping (NOLOCK) PSAM ON PSAM.ServiceMapID=SAM.ServiceMappingID and PSAM.IsDeleted=0
	INNER JOIN #ProjectDetails PM ON PM.ProjectID=PSAM.ProjectID 
	WHERE SM.ServiceID <> 41 AND ISNULL(PSAM.IsHidden,0)=0

	--Ticket Type Details
	select DISTINCT PM.CustomerID ,TTM.ProjectID, TTM.AVMTicketType,TTM.TicketTypeMappingID,TT.TicketTypeID,TT.TicketTypeName AS TicketType,TTM.TicketType AS TicketTypeName
	from [AVL].[TK_MAP_TicketTypeMapping](NOLOCK) TTM
	LEFT JOIN [AVL].[TK_MAS_TicketType](NOLOCK) TT ON TTM.AVMTicketType=TT.TicketTypeID
	INNER JOIN #ProjectDetails PM ON PM.ProjectID=TTM.ProjectID 
	and ISNULL(TTM.IsDeleted,0)=0
	WHERE ISNULL(TT.TicketTypeID,0) NOT IN(9,10)

	--Status Details
	select DISTINCT PM.CustomerID ,PSM.ProjectID, PSM.TicketStatus_ID  AS DARTStatusID,DT.DARTStatusName,
	PSM.StatusID AS TicketStatus_ID,PSM.StatusName
	from [AVL].[TK_MAP_ProjectStatusMapping](NOLOCK) PSM
	INNER JOIN [AVL].[TK_MAS_DARTTicketStatus](NOLOCK) DT ON PSM.TicketStatus_ID=DT.DARTStatusID
	INNER JOIN #ProjectDetails  PM ON PM.ProjectID=PSM.ProjectID 
	AND ISNULL(PSM.IsDeleted,0)=0

	--Ticket Type Service Details
	select distinct PM.CustomerID,PSAM.ProjectID,ISNULL(TTSM.TicketTypeMappingID,0) AS TicketTypeMappingID,SM.ServiceID,ISNULL(STM.ServiceTypeID,0) AS ServiceTypeID
	from avl.TK_MAS_Service (NOLOCK)  SM
	INNER JOIN AVL.TK_MAS_ServiceType (NOLOCK) STM ON STM.ServiceTypeID=SM.ServiceType
	INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM ON SAM.ServiceTypeID = STM.ServiceTypeID AND SAM.ServiceID = SM.ServiceID
	INNER JOIN avl.TK_PRJ_ProjectServiceActivityMapping (NOLOCK) PSAM ON PSAM.ServiceMapID=SAM.ServiceMappingID and PSAM.IsDeleted=0
	INNER JOIN #ProjectDetails PM ON PM.ProjectID=PSAM.ProjectID 
	LEFT JOIN AVL.TK_MAP_TicketTypeServiceMapping TTSM ON SAM.ServiceID=TTSM.ServiceID AND PSAM.ProjectID=TTSM.ProjectID
	WHERE TTSM.TicketTypeMappingID IS NOT NULL AND TTSM.IsDeleted=0

	--Priority Details
	SELECT PriorityIDMapID,ProjectID,PriorityID,PriorityName FROM AVL.TK_MAP_PriorityMapping(NOLOCK)
	WHERE ProjectID IN(SELECT DISTINCT ProjectID FROM #UserProjectDetails) AND ISNULL(IsDeleted,0)=0

	--Application Project Mapping
	SELECT DISTINCT APM.ProjectID,APM.ApplicationID,AD.ApplicationName FROM AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM
	INNER JOIN #UserProjectDetails UPD ON APM.ProjectID=UPD.ProjectID
	LEFT JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON APM.ApplicationID=AD.ApplicationID
	WHERE APM.ProjectID IN(SELECT DISTINCT ProjectID FROM #UserProjectDetails) AND APM.IsDeleted=0

	--selecting project based services
	SELECT DISTINCT CustomerID AS CustomerID,USM.ServiceLevelID AS ServiceLevelID,
	USM.ProjectID AS ProjectID FROM [avl].UserServiceLevelMapping (NOLOCK) USM 
	WHERE USM.EmployeeID=@EmployeeID 

	DECLARE @Accesslevel INT;
	SET @Accesslevel=( SELECT COUNT(*) FROM [AVL].[MAS_LoginMaster](NOLOCK) 
	WHERE EmployeeID = @EmployeeID  AND IsDeleted=0 )

	--select ID,NonTicketedActivity from [AVL].[MAS_NonDeliveryActivity]  where IsActive=1
	DECLARE @TimeZoneName NVARCHAR(250);
	SET @TimeZoneName=(SELECT TOP 1  UserTimeZoneName FROM #UserProjectDetails
						WHERE UserTimeZoneName IS NOT NULL AND UserTimeZoneName != '')
	SELECT @TimeZoneName AS UserTimeZoneName,ISNULL(@Accesslevel,0) AS Accesslevel

	


	END TRY  

BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[Mini_GetConfigurationDetailsByEmployee]', @ErrorMessage, @EmployeeID,0
END CATCH  

END
