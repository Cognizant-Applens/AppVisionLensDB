/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--exec [AVL_SaveNonTicketDetailsInfra] '1','',5301,471742,'TEST','05-20-2018','05-26-2018'
--exec [AVL_SaveNonTicketDetails] '1','',7,627384,'TEST','04-29-2018','05-05-2018'
CREATE PROC [dbo].[AVL_SaveNonTicketDetails]
@NonTicketActivity nvarchar(max),
@TicketID nvarchar(max)=null,
@CustomerID bigint,
@EmployeeID nvarchar(max),
@Remarks nvarchar(max),
@FirstDateOfWeek varchar(30)=null,
@LastDateOfWeek varchar(30)=null,
@ProjectID varchar(30)= null,
@SuggestedActivityName NVARCHAR(50) =NULL

AS
BEGIN
BEGIN TRY
SET NOCOUNT ON; 
DECLARE @TopUSerID bigint
SET @TopUSerID=(SELECT top 1 UserID from [AVL].[MAS_LoginMaster](NOLOCK) where EmployeeID=@EmployeeID and CustomerID=@CustomerID and ProjectId = @ProjectId  AND IsDeleted=0)
 DECLARE @Servicecount INT
SET @Servicecount=0;
DECLARE @SupportTypeIDADM INT;
DECLARE @SupportTypeID INT;
	SET @SupportTypeIDADM=(SELECT  TOP 1 SupportTypeId FROM AVL.MAP_ProjectConfig(NOLOCK) WHERE ProjectID=@ProjectID)
	IF(@SupportTypeIDADM = 4)
	BEGIN
		SET @SupportTypeID = 0;
	END
	ELSE IF(ISNULL(@SupportTypeIDADM,'') <> '')
	BEGIN
		SET @SupportTypeID = @SupportTypeIDADM;
	END
	ELSE
	BEGIN
		DECLARE @IsAVMProject INT;
		DECLARE @IsAVMInfraProject INT;
		DECLARE @IsADMProject INT;
		SET @IsADMProject = (SELECT COUNT(AttributeValueId) FROM PP.ProjectAttributeValues(NOLOCK)
		WHERE AttributeID = 1 AND AttributeValueID in(1,4) AND ProjectID = @ProjectID AND IsDeleted = 0)
		SET @IsAVMProject = (SELECT COUNT(AttributeValueId) FROM PP.ProjectAttributeValues(NOLOCK) 
		WHERE AttributeID = 1 AND AttributeValueID in(3) AND ProjectID = @ProjectID AND IsDeleted = 0)
		SET @IsAVMInfraProject = (SELECT COUNT(AttributeValueId) FROM PP.ProjectAttributeValues(NOLOCK) 
		WHERE AttributeID = 1 AND AttributeValueID in(2) AND ProjectID = @ProjectID AND IsDeleted = 0)
	 IF(@IsADMProject > 0 AND @IsAVMProject = 0 AND @IsAVMInfraProject = 0)
		SET @SupportTypeID = 0;
	 ELSE IF(@IsAVMInfraProject > 0 AND @IsADMProject = 0 AND @IsAVMProject = 0)
		SET @SupportTypeID = 2;
	 ELSE
		SET @SupportTypeID = 1;
	END

	        CREATE TABLE #EFFORTDATES
			(
			  SNO INT IDENTITY(1,1),
			  DATETODAY DATE,
			  NAME VARCHAR(50),
			  FreezeStatus NVARCHAR(50)
			 )

		;WITH MYCTE AS
			  (
				SELECT CAST(@FirstDateOfWeek AS DATETIME) DATEVALUE
				UNION ALL
				SELECT  DATEVALUE + 1
				FROM    MYCTE   
				WHERE   DATEVALUE + 1 <= @LastDateOfWeek
			  )
      
					INSERT INTO #EFFORTDATES
					SELECT  CONVERT(DATE,DATEVALUE) AS DATETODAY , DATENAME(W,DATEVALUE) AS NAME,''
					FROM    MYCTE 
					OPTION (MAXRECURSION 0)


					SELECT C.CustomerId						AS CustomerId,
					--PM.ProjectID,
							ISNULL(CASE WHEN C.IsCognizant='0' THEN 0 ELSE 1 END,1)			AS IsCustomer,
							ISNULL(CASE WHEN C.IsCognizant='0' THEN 0 ELSE 1 END,1)			AS IsCognizant,
							ISNULL(C.IsEffortConfigured,0)		AS IsEfforTracked,
							ISNULL(C.IsITSMEffortConfigured,0)	AS IsITSMLinked,
							null			AS IsDebtEnabled,
							NULL	AS IsMainSpringConfigured,C.IsDaily Into #ConfigTemp
							FROM AVL.Customer C ( NOLOCK ) 
							--INNER JOIN AVL.MAS_ProjectMaster PM ( NOLOCK ) 
							--ON C.CustomerID=PM.CustomerID 
							WHERE C.CustomerID=@CustomerID AND C.IsDeleted = 0
							--and PM.ProjectID=@ProjectID

				
			

Select null as TimesheetId, cast(null as date) as TimesheetDate,NULL AS TimeSheetDetailId, NULL AS TimeTickerID,	NULL AS TicketID,	NULL AS ApplicationID,	@ProjectID AS ProjectID,	@TopUSerID as AssignedTo,
0 AS EffortTillDate,0 As Effort	,NULL AS ServiceID,	@Remarks as TicketDescription,	NULL AS IsDeleted,	NULL AS TicketStatusMapID,	NULL AS TicketTypeMapID, 
	 0 AS IsSDTicket,		NULL AS DARTStatusID,	NULL AS ITSMEffort, 1 as IsNonTicket,
	--ISNULL(CASE WHEN ATT.IsCognizant='0' THEN 0 ELSE 1 END,1)	AS IsCustomer,
	--ISNULL(ATT.IsEffortConfigured,0)		AS IsEfforTracked ,
	--ISNULL(ATT.IsITSMEffortConfigured,0)	AS IsITSMLinked,
							ATT.IsCustomer,
							ATT.IsEfforTracked,
							ATT.IsITSMLinked,
							null AS IsDebtEnabled,
							Null	AS IsMainSpringConfigured, 1 as ISTicket,
							@NonTicketActivity as ActivityId,NULL AS TowerID
							,@SuggestedActivityName AS SuggestedActivityName INTO #EffortEntryDataTemp FROM
	   #ConfigTemp(NOLOCK) ATT 
	  INNER JOIN [AVL].[MAS_LoginMaster](NOLOCK) LM ON LM.EmployeeID=@EmployeeID and  ATT.CustomerID=LM.CustomerID
	  WHERE  ATT.CustomerID= @CustomerID AND LM.IsDeleted = 0 


CREATE TABLE #TimesheetandTimesheetdetailsidTemp
			(
			SNO INT ,
			  DATETODAY DATE,
			  TimesheetId Bigint,
			  TimesheetDate DATE,
			  ProjectID Bigint,
			  TimeSheetDetailId Bigint
			  )

INSERT Into #TimesheetandTimesheetdetailsidTemp
SELECT DISTINCT  
	 ED.SNO,ED.DATETODAY,TS.TimesheetId,TS.TimesheetDate ,TS.ProjectID,TS.TimeSheetDetailId   From  #EFFORTDATES ED
	  LEFT JOIN #EffortEntryDataTemp(NOLOCK) TS   on TS.TimesheetDate=ED.DATETODAY


--select * from #TimesheetandTimesheetdetailsidTemp

SELECT PVTResult.* INTO #LastTemp From   
(SELECT TimeTickerID,	TicketID,	ApplicationID,	ProjectID,	AssignedTo,
	EffortTillDate,ServiceID,	TicketDescription,	IsDeleted,	TicketStatusMapID,TicketTypeMapID, 
	IsSDTicket,		DARTStatusID,	ITSMEffort, IsNonTicket,
	IsCustomer,IsEfforTracked,IsITSMLinked,IsDebtEnabled,IsMainSpringConfigured, ISTicket ,ActivityId,
		[1TimeSheetDetailId]= CASE WHEN p.[1] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
        [1] = CASE WHEN p.[1] IS NULL THEN NULL ELSE p.[1] END,
		[2TimeSheetDetailId]= CASE WHEN p.[2] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
        [2] = CASE WHEN p.[2] IS NULL THEN NULL ELSE p.[2] END, 
		[3TimeSheetDetailId]= CASE WHEN p.[3] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
        [3] = CASE WHEN p.[3] IS NULL THEN NULL ELSE p.[3] END,  
		[4TimeSheetDetailId]= CASE WHEN p.[4] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
        [4] = CASE WHEN p.[4] IS NULL THEN NULL ELSE p.[4] END,  
		[5TimeSheetDetailId]= CASE WHEN p.[5] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
        [5] = CASE WHEN p.[5] IS NULL THEN NULL ELSE p.[5] END,  
		[6TimeSheetDetailId]= CASE WHEN p.[6] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
        [6] = CASE WHEN p.[6] IS NULL THEN NULL ELSE p.[6] END,  
		[7TimeSheetDetailId]= CASE WHEN p.[7] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
        [7] = CASE WHEN p.[7] IS NULL THEN NULL ELSE p.[7] END  ,
		TowerID,
		SuggestedActivityName
FROM  (SELECT   
	 ED.SNO,ED.DATETODAY,TS.TimesheetId,TS.TimesheetDate,TS.TimeSheetDetailId, TS.TimeTickerID,	TS.TicketID,	TS.ApplicationID,	TS.ProjectID,	TS.AssignedTo,
	TS.EffortTillDate,TS.Effort	,TS.ServiceID,	TS.TicketDescription,	TS.IsDeleted,	TS.TicketStatusMapID,TS.TicketTypeMapID, 
	 TS.IsSDTicket,		TS.DARTStatusID,	TS.ITSMEffort, TS.IsNonTicket,
	 TS.IsCustomer,TS.IsEfforTracked,TS.IsITSMLinked,TS.IsDebtEnabled,TS.IsMainSpringConfigured, TS.ISTicket,ActivityId,
	 TS.TowerID,TS.SuggestedActivityName FROM  #EffortEntryDataTemp(NOLOCK) TS
	  LEFT JOIN #EFFORTDATES(NOLOCK) ED  on Ts.TimesheetDate=ED.DATETODAY) s
 PIVOT(MAX(Effort)
	  FOR s.SNO IN ( [1], [2], [3], [4], [5], [6], [7]) ) p 
	  )
	  as PVTResult  

ORDER BY PVTResult.TicketID;

--Select * from #LastTemp
			
	select distinct TimeTickerID,	TicketID,	ApplicationID,	ProjectID,	AssignedTo,
	EffortTillDate,ServiceID,	TicketDescription,	IsDeleted,	TicketStatusMapID,TicketTypeMapID, 
	IsSDTicket,		DARTStatusID,	ITSMEffort, IsNonTicket,
	IsCustomer,IsEfforTracked,IsITSMLinked,IsDebtEnabled,IsMainSpringConfigured, ISTicket,ActivityId,
	max([1TimeSheetDetailId]) AS [1TimeSheetDetailId],max([1]) AS [1],
	max([2TimeSheetDetailId]) AS [2TimeSheetDetailId] ,max([2]) AS [2],
	max([3TimeSheetDetailId]) AS [3TimeSheetDetailId],max([3]) AS [3] ,
	 max([4TimeSheetDetailId]) AS [4TimeSheetDetailId],max([4]) AS [4],
	max([5TimeSheetDetailId]) AS [5TimeSheetDetailId],max([5]) AS [5] ,
	max([6TimeSheetDetailId]) AS [6TimeSheetDetailId],max([6]) AS [6],
	max([7TimeSheetDetailId]) AS [7TimeSheetDetailId],max([7]) AS [7],
	TowerID,SuggestedActivityName
	Into #FinalTemp from #LastTemp(NOLOCK)
	GROUP BY TimeTickerID,	TicketID,	ApplicationID,	ProjectID,	AssignedTo,
	EffortTillDate,ServiceID,	TicketDescription,	IsDeleted,	TicketStatusMapID,TicketTypeMapID, 
	IsSDTicket,		DARTStatusID,	ITSMEffort, IsNonTicket,
	IsCustomer,IsEfforTracked,IsITSMLinked,IsDebtEnabled,IsMainSpringConfigured, ISTicket,ActivityId,TowerID,
	SuggestedActivityName

Select  FT.TimeTickerID,	FT.TicketID,	FT.ApplicationID,	FT.ProjectID,	FT.AssignedTo,
	FT.EffortTillDate,FT.ServiceID,	FT.TicketDescription,	FT.IsDeleted,	FT.TicketStatusMapID,FT.TicketTypeMapID, 
	FT.IsSDTicket,		FT.DARTStatusID,	FT.ITSMEffort,FT.IsNonTicket,
	FT.IsCustomer,FT.IsEfforTracked,FT.IsITSMLinked,FT.IsDebtEnabled,FT.IsMainSpringConfigured,FT.ISTicket,FT.ActivityId,null as IsAttributeUpdated,
	FT.[1TimeSheetDetailId], FT.[1],
	FT.[2TimeSheetDetailId],  FT.[2],
	FT.[3TimeSheetDetailId], FT.[3] ,
	FT.[4TimeSheetDetailId],   FT.[4],
	FT.[5TimeSheetDetailId], FT.[5] ,
	FT.[6TimeSheetDetailId], FT.[6],
	FT.[7TimeSheetDetailId], FT.[7],TowerID,@SupportTypeID AS SupportTypeID,
	FT.SuggestedActivityName from #FinalTemp(NOLOCK) FT

	select NULL

	select distinct TTDT.SNO,TTDT.DATETODAY,TTDT.TimesheetId,TTDT.TimesheetDate,TTDT.TimeSheetDetailId,null as ProjectID,
	'false'  AS FreezeStatus  
    INTO #FreezeStatus from #TimesheetandTimesheetdetailsidTemp(NOLOCK) TTDT
	where TTDT.sno is not null 

	
	UPDATE ED 
	SET ED.FreezeStatus=FS.FreezeStatus 
	FROM #EFFORTDATES  ED
	INNER JOIN #FreezeStatus(NOLOCK)  FS
	ON FS.DATETODAY=ED.DATETODAY

	UPDATE #FreezeStatus SET FreezeStatus='false' WHERE FreezeStatus=''

	DECLARE @IsDaily INT;

	SET @IsDaily=(SELECT TOP 1 IsDaily FROM #ConfigTemp)

	IF @IsDaily = 0

	BEGIN

		DECLARE @CheckFreezeStatus NVARCHAR(50);

		SET @CheckFreezeStatus=(SELECT COUNT(*) FROM #EFFORTDATES WHERE FreezeStatus='true')

		if @CheckFreezeStatus> 0

		update #EFFORTDATES set FreezeStatus='true'

	END

	SELECT TimesheetDate,StatusId INTO #TimesheetTemp FROM AVL.TM_PRJ_Timesheet(NOLOCK)
	WHERE CustomerID=@CustomerID AND SubmitterId IN(SELECT  UserID from [AVL].[MAS_LoginMaster](NOLOCK) 
													where EmployeeID=@EmployeeID and CustomerID=@CustomerID AND ProjectId = @ProjectId  AND IsDeleted=0)
	
	--newly added
	UPDATE E
	SET E.FreezeStatus='true'
	from #EFFORTDATES E
	LEFT JOIN #TimesheetTemp(NOLOCK) TT ON TT.TimesheetDate=E.DATETODAY
	WHERE ISNULL(TT.StatusId,0) in (2,3,6)



	select DISTINCT SNO , DATETODAY ,  NAME,CONCAT(DATEPART(DAY,DATETODAY) , '-',LEFT(NAME,3)) AS DisplayDate,
	FreezeStatus AS FreezeStatus,ISNULL(TT.StatusId,0) AS StatusId from #EFFORTDATES(NOLOCK) E
	LEFT JOIN #TimesheetTemp(NOLOCK) TT ON TT.TimesheetDate=E.DATETODAY


	select NULL
	select NULL
	select NULL

CREATE TABLE #UserProjectDetails
    (
    SNO INT IDENTITY(1,1),
	   UserID BigINT,
      ProjectID BigINT
   
     )

;WITH MYCTE AS
      (
      SELECT UserID,ProjectID FROM [AVL].[MAS_LoginMaster](NOLOCK) WHERE EmployeeID = @EmployeeID and CustomerID=@CustomerID AND IsDeleted=0
      )
      
            INSERT INTO #UserProjectDetails
            SELECT UserID,ProjectID
            FROM    MYCTE 
            OPTION (MAXRECURSION 0)

DECLARE @IsITSMExists INT;
IF EXISTS (SELECT  TOP 1 1 FROM AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK)
WHERE 
 ProjectID IN(SELECT ProjectID FROM #UserProjectDetails(NOLOCK))  AND ServiceDartColumn='ITSM Effort' AND IsDeleted=0)
BEGIN
       SET @IsITSMExists=1;
END
ELSE
BEGIN
       SET @IsITSMExists=0;
END


SELECT DISTINCT CustomerId,IsCustomer,IsCognizant,IsEfforTracked AS IsEffortTracked,@IsITSMExists AS IsITSMLinked
,IsDaily AS IsDaily  FROM #ConfigTemp(NOLOCK)

	IF OBJECT_ID('tempdb..#temp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #temp
	END
	IF OBJECT_ID('tempdb..#ConfigTemp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #ConfigTemp
	END
	IF OBJECT_ID('tempdb..#EFFORTDATES', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #EFFORTDATES
	END
	IF OBJECT_ID('tempdb..#EffortEntryDataTemp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #EffortEntryDataTemp
	END
	IF OBJECT_ID('tempdb..#LastTemp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #LastTemp
	END
	IF OBJECT_ID('tempdb..#FinalTemp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FinalTemp
	END
	IF OBJECT_ID('tempdb..#TimesheetandTimesheetdetailsidTemp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #TimesheetandTimesheetdetailsidTemp
	END
	IF OBJECT_ID('tempdb..#FreezeStatus', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FreezeStatus
	END
	IF OBJECT_ID('tempdb..#TimesheetTemp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #TimesheetTemp
	END
	IF OBJECT_ID('tempdb..#UserProjectDetails', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #UserProjectDetails
	END
	
end try
begin catch

DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError 'AVL_SaveNonTicketDetails', @ErrorMessage, 0,@EmployeeID
end catch
end
