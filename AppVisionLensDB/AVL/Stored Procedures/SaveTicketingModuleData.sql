/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [AVL].[SaveTicketingModuleData]
	@SaveTimesheetDetails AVL.SaveTimesheetDetails readonly,
	@SaveTicketDetails AVL.SaveTicketDetails_TS readonly,
	@Flag INT=NULL,
	@EmployeeID NVARCHAR(50)=NULL
AS
BEGIN


	BEGIN TRY

	select * INTO #MAS_LoginMaster from AVL.MAS_LoginMaster(NOLOCK) where EmployeeID=@EmployeeID AND IsDeleted = 0
		DECLARE @CustomerID BIGINT;
		SELECT DISTINCT  [TicketID] ,
		[TicketDescription] ,
		[ServiceID] ,
		[ActivityID],
		[TicketType] ,
		[TicketStatus], 
		[ITSMEffort],
		[TotalEffort], 
		[ProjectID],
		[TimeTickerID], 
		[DARTStatusID] ,
		[ApplicationID], 
		[UserID],
		[Type]
		INTO #SaveTicketDetails  FROM @SaveTicketDetails 

		

		SELECT DISTINCT [TicketID] ,
		[ServiceID],
		[ActivityID] ,
		[TicketType] ,
		[TicketStatus],
		[ProjectID],
		[TimeSheetID],
		[TimesheetDetailID],
		[TimeTickerID] ,
		[IsNonTicket],
		[Hours] ,
		[TimesheetDate],
		[UserID], 
		[ApplicationID],
		[CustomerID],
		TicketDescription,SupportTypeID,TowerID,NULL AS SuggestedActivityID,
		LTRIM(RTRIM(SuggestedActivityName)) AS SuggestedActivityName
		,[Type]
		INTO #SaveTimesheetDetails  FROM @SaveTimesheetDetails 

		

		--Logics to insert into [AVL].[TM_NonDeliverySuggestedActivity]
		MERGE [AVL].[TM_NonDeliverySuggestedActivity] bi
		USING (SELECT DISTINCT ProjectID,SuggestedActivityName FROM #SaveTimesheetDetails 
		WHERE SuggestedActivityName IS NOT NULL)bo
		ON bi.ProjectID=bo.ProjectID AND bi.SuggestedActivityName = bo.SuggestedActivityName AND ISNULL(bi.IsDeleted,0) =0
		WHEN MATCHED THEN
		UPDATE
		SET 
		bi.ModifiedBy=@EmployeeID,
		bi.ModifiedDateTime=GETDATE()
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (ProjectID,SuggestedActivityName,IsReviewed,IsDeleted,CreatedBy,CreatedDateTime)
		VALUES (bo.ProjectID,ISNULL(bo.SuggestedActivityName,''),0,0,@EmployeeID,GETDATE());
		
		UPDATE ST SET ST.SuggestedActivityID=NSA.SuggestedActivityID
		FROM #SaveTimesheetDetails ST
		INNER JOIN [AVL].[TM_NonDeliverySuggestedActivity] NSA
		ON ST.ProjectID=NSA.ProjectID AND ST.SuggestedActivityName=NSA.SuggestedActivityName
		AND ISNULL(NSA.IsDeleted,0)=0

		SET @CustomerID=(SELECT DISTINCT [CustomerID] FROM @SaveTimesheetDetails)

		SELECT DISTINCT [TicketID] ,
		[ServiceID],
		[ActivityID] ,
		[TicketType] ,
		[TicketStatus],
		[ProjectID],
		[TimeSheetID],
		[TimesheetDetailID],
		[TimeTickerID] ,
		[IsNonTicket],
		[Hours] ,
		[TimesheetDate],
		[UserID], 
		[ApplicationID],
		[CustomerID],
		TicketDescription,SupportTypeID,[Type]
		INTO #SaveTimesheetDetailsForUpdate  FROM #SaveTimesheetDetails WHERE Hours=0 --AND IsNonTicket=0

		SELECT DISTINCT [TicketID] ,
		[ServiceID],
		[ActivityID] ,
		[TicketType] ,
		[TicketStatus],
		[ProjectID],
		[TimeSheetID],
		[TimesheetDetailID],
		[TimeTickerID] ,
		[IsNonTicket],
		[Hours] ,
		[TimesheetDate],
		[UserID], 
		[ApplicationID],
		[CustomerID],
		TicketDescription,SupportTypeID,[Type]
		INTO #SaveTimesheetDetailsToDelete  FROM @SaveTimesheetDetails WHERE Hours=0
		--ADDED TO ENSURE THE USER ID IS SAME AS THE SUBMITTER ID FOR THE PROJECT


		UPDATE TD
		SET TD.UserID=LM.UserID
		FROM #SaveTimesheetDetails TD
		INNER JOIN #MAS_LoginMaster LM with(NOLOCK)
		ON TD.ProjectID =LM.ProjectID AND LM.EmployeeID=@EmployeeID


		SELECT DISTINCT 
		[ProjectID],
		[TimeSheetID],
		[TimesheetDate],
		[UserID],
		[CustomerID],
		[IsNonTicket],SupportTypeID,[Type]
		INTO #SaveTimesheet  FROM #SaveTimesheetDetails(NOLOCK)  WHERE -- IsNonTicket=0 AND 
		Hours>0
	

		UPDATE   ST
		SET ST.TimeSheetID=PT.TimesheetId
		FROM #SaveTimesheet ST
		INNER JOIN AVL.TM_Prj_Timesheet PT with(NOLOCK)
		ON CONVERT(DATE,ST.TimesheetDate)=CONVERT(DATE,PT.TimesheetDate) 
		AND isnull(ST.ProjectID,0)=ISnull(PT.ProjectID,0) AND ST.UserID=PT.SubmitterId AND ST.SupportTypeID IN(1,3) 
		AND (ST.[Type]='T' OR ST.[Type]='ND')

		--Infra
		UPDATE   ST
		SET ST.TimeSheetID=PT.TimesheetId
		FROM #SaveTimesheet ST
		INNER JOIN AVL.TM_Prj_Timesheet PT with(NOLOCK)
		ON CONVERT(DATE,ST.TimesheetDate)=CONVERT(DATE,PT.TimesheetDate) 
		AND isnull(ST.ProjectID,0)=ISnull(PT.ProjectID,0) AND ST.UserID=PT.SubmitterId AND ST.SupportTypeID=2 
		AND (ST.[Type]='T' OR ST.[Type] ='ND')

		--WorkItem
		UPDATE   ST
		SET ST.TimeSheetID=PT.TimesheetId
		FROM #SaveTimesheet ST
		INNER JOIN AVL.TM_Prj_Timesheet PT with(NOLOCK)
		ON CONVERT(DATE,ST.TimesheetDate)=CONVERT(DATE,PT.TimesheetDate) 
		AND isnull(ST.ProjectID,0)=ISnull(PT.ProjectID,0) AND ST.UserID=PT.SubmitterId AND ST.SupportTypeID=0 
		AND (ST.[Type] = 'W' OR ST.[Type] ='ND')


		SELECT DISTINCT 
		[ProjectID],
		[TimeSheetID],
		[TimesheetDate],
		[UserID],
		[CustomerID],
		0 as [IsNonTicket]
		INTO #SaveTimesheetModified  FROM #SaveTimesheet(NOLOCK)


		MERGE AVL.TM_Prj_Timesheet bi
		USING #SaveTimesheetModified bo
		ON 
		-- bi.TimesheetID = bo.TimesheetID AND
		 bi.ProjectID=bo.ProjectID
		 AND bi.SubmitterID=bo.UserID 
		 --AND bo.TimesheetID <> 0
		 AND CONVERT(DATE,bi.TimesheetDate)=CONVERT(DATE,bo.TimesheetDate)
		 and bi.ProjectID is not null
		WHEN MATCHED THEN
		UPDATE
		SET 
		bi.StatusID=case when   (bi.StatusId=4 AND @Flag=1) THEN bi.StatusId
					ELSE @Flag
					END,
		bi.ModifiedBy=@EmployeeID,
		bi.ModifiedDateTime=GETDATE()
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (ProjectID,SubmitterID,CustomerID,IsNonTicket, TimesheetDate, StatusId,CreatedBy,CreatedDateTime)
		VALUES (bo.ProjectID,bo.UserID,bo.CustomerID,bo.IsNonTicket, bo.TimesheetDate,@Flag,@EmployeeID,GETDATE());


		UPDATE  TS
		SET TS.TimeSheetID=TD.TimeSheetID
		FROM #SaveTimesheetDetails TS
		INNER JOIN AVL.TM_Prj_Timesheet TD with(NOLOCK)
		ON isnull(TS.ProjectID,0)=Isnull(TD.ProjectID,0) 
		AND CONVERT(DATE,TS.TimesheetDate)=CONVERT(DATE,TD.TimesheetDate)
		AND TS.UserID=TD.SubmitterId
		AND TD.CustomerID=TS.[CustomerID]
		and TD.ProjectID =TS.ProjectID
		WHERE 
		Hours > 0 --and TD.IsNonTicket=0


		SELECT DISTINCT [TicketID] ,
		[ServiceID],
		[ActivityID] ,
		[TicketType] ,
		[TicketStatus],
		[ProjectID],
		[TimeSheetID],
		[TimesheetDetailID],
		[TimeTickerID] ,
		[IsNonTicket],
		[Hours] ,
		[TimesheetDate],
		[UserID], 
		[ApplicationID],
		TicketDescription,SupportTypeID,TowerID,SuggestedActivityID,[Type]
		INTO  #SaveTimesheetDetailsModified  FROM #SaveTimesheetDetails(NOLOCK)

		CREATE TABLE #TimeSheetEffortToSubtract
		( 
		Hours DECIMAL(18,2) NULL,
		TicketID NVARCHAR(100) NULL,
		ProjectID BIGINT NULL,
		SupportTypeID INT NULL,
		[Type] varchar(10) null
		)
		--To Subtract effort till date
		INSERT INTO #TimeSheetEffortToSubtract
		SELECT SUM(bi.Hours) AS Hours,bo.TicketID,bo.ProjectID,bo.SupportTypeID,bo.[Type]
		FROM #SaveTimesheetDetailsModified bo with(NOLOCK)
		INNER JOIN AVL.TM_TRN_TimesheetDetail bi with(NOLOCK)
		ON bi.TimesheetID = bo.TimesheetID 
		AND isnull(bi.ProjectID,0)=ISNULL(bo.ProjectID,0)
		AND bi.TicketID=bo.TicketID
		AND bi.TimesheetDetailID=bo.TimesheetDetailID
		AND bi.IsNonTicket=0 AND bo.SupportTypeID IN(1,3) AND (bo.Type = 'T' OR bo.Type = 'ND')
		GROUP BY BO.TicketID,BO.ProjectID,bo.SupportTypeID,bo.[Type]
		
		UPDATE TD
		SET TD.EffortTillDate=ISNULL(TD.EffortTillDate,0)- ISNULL(TS.Hours,0)
		,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE(),LastUpdatedDate=GETDATE()
		FROM AVL.TK_TRN_TicketDetail TD
		INNER JOIN #TimeSheetEffortToSubtract TS with(NOLOCK)
		ON TD.ProjectID=TS.ProjectID
		AND TD.TicketID=TS.TicketID AND TS.SupportTypeID IN(1,3) AND (TS.Type = 'T' OR TS.[Type] = 'ND')
	
		INSERT INTO #TimeSheetEffortToSubtract
		--To Subtract effort till date Infra
		SELECT SUM(bi.Hours) AS Hours,bo.TicketID,bo.ProjectID,bo.SupportTypeID ,bo.[Type]
		FROM 
		#SaveTimesheetDetailsModified bo with(NOLOCK)
		INNER JOIN AVL.TM_TRN_InfraTimesheetDetail bi with(NOLOCK)
		ON bi.TimesheetID = bo.TimesheetID 
		AND isnull(bi.ProjectID,0)=ISNULL(bo.ProjectID,0)
		AND bi.TicketID=bo.TicketID
		AND bi.TimesheetDetailID=bo.TimesheetDetailID
		AND bi.IsNonTicket=0 AND bo.SupportTypeID=2 AND (bo.Type = 'T' OR bo.Type = 'ND')
		GROUP BY BO.TicketID,BO.ProjectID,bo.SupportTypeID,bo.[Type]
		
		UPDATE TD
		SET TD.EffortTillDate=ISNULL(TD.EffortTillDate,0)- ISNULL(TS.Hours,0)
		,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE(),LastUpdatedDate=GETDATE()
		FROM AVL.TK_TRN_InfraTicketDetail TD
		INNER JOIN #TimeSheetEffortToSubtract TS with(NOLOCK)
		ON TD.ProjectID=TS.ProjectID
		AND TD.TicketID=TS.TicketID AND TS.SupportTypeID=2 AND (TS.Type = 'T' OR TS.Type = 'ND')

		-- Work Item
		INSERT INTO #TimeSheetEffortToSubtract
		--To Subtract effort till date work item
		SELECT SUM(bi.Hours) AS Hours,bo.TicketID,bo.ProjectID,bo.SupportTypeID ,bo.[Type]
		FROM 
		#SaveTimesheetDetailsModified bo with(NOLOCK)
		INNER JOIN ADM.TM_TRN_WorkItemTimesheetDetail bi with(NOLOCK)
		ON bi.WorkItemDetailsId  = bo.TimeTickerID
		AND bi.TimesheetID = bo.TimesheetID 
		AND bi.TimesheetDetailID=bo.TimesheetDetailID
		AND bi.IsNonTicket=0 AND bo.SupportTypeID = 0 AND (bo.[Type] = 'W' OR bo.[Type] = 'ND') 
		GROUP BY BO.TicketID,BO.ProjectID,bo.SupportTypeID,bo.[Type]
		
		UPDATE TD
		SET TD.WorkProfilerEffort=ISNULL(TD.WorkProfilerEffort,0)- ISNULL(TS.Hours,0)
		,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE()--,LastUpdatedDate=GETDATE()
		FROM ADM.ALM_TRN_WorkItem_Details TD
		INNER JOIN #TimeSheetEffortToSubtract TS with(NOLOCK)
		ON TD.Project_Id=TS.ProjectID
		AND TD.WorkItem_Id=TS.TicketID AND TS.SupportTypeID = 0 AND (TS.[Type]='W' OR TS.[Type] ='ND')

		--TO DELETE CR
		UPDATE   SD
		SET SD.TimeSheetID=PT.TimesheetId
		FROM #SaveTimesheetDetailsToDelete sd
		INNER JOIN AVL.TM_Prj_Timesheet PT with(NOLOCK)
		ON CONVERT(DATE,SD.TimesheetDate)=CONVERT(DATE,PT.TimesheetDate) AND isnull(SD.ProjectID,0)=ISnull(PT.ProjectID,0) AND SD.UserID=PT.SubmitterId
		--AND PT.IsNonTicket=0

		UPDATE #SaveTimesheetDetailsModified SET TicketDescription=''
		WHERE IsNonTicket=0

		UPDATE #SaveTimesheetDetailsModified SET TicketDescription=CONVERT(NVARCHAR(MAX),ISNULL(TicketDescription,''))
		WHERE IsNonTicket=1

		MERGE AVL.TM_TRN_TimesheetDetail bi
		USING #SaveTimesheetDetailsModified bo
		ON 
		bi.TimesheetID = bo.TimesheetID 
		AND isnull(bi.ProjectID,0)=ISNULL(bo.ProjectID,0)
		AND bi.TicketID=bo.TicketID
		AND bi.TimesheetDetailID=bo.TimesheetDetailID
		AND bo.SupportTypeID IN(1,3) AND (bo.Type='T' OR bo.Type ='ND')

		WHEN MATCHED THEN
		UPDATE
		SET 
		bi.ServiceID=bo.ServiceID,
		bi.ActivityID=bo.ActivityID,
		bi.Hours=bo.Hours,
		bi.TicketTypeMapID=CASE WHEN bo.TicketType=0 THEN bi.TicketTypeMapID ELSE bo.TicketType END,
		bi.ModifiedBy=@EmployeeID,
		bi.ModifiedDateTime=GETDATE(),
		bi.IsNonTicket=bo.IsNonTicket
		WHEN NOT MATCHED BY TARGET AND bo.Hours >0  AND bo.SupportTypeID IN(1,3) AND (bo.Type='T' OR bo.Type ='ND') 
		THEN
		INSERT (TimesheetID,TimeTickerID,ApplicationID,TicketID,Remarks,IsNonTicket,ServiceId,ActivityID,TicketTypeMapID,Hours,ProjectID,CreatedBy,CreatedDateTime,IsDeleted,
		SuggestedActivityID)
		VALUES (bo.TimesheetID, bo.TimeTickerID,bo.ApplicationID,bo.TicketID,TicketDescription,bo.IsNonTicket,bo.ServiceId,bo.ActivityID,bo.TicketType,bo.Hours,bo.ProjectID,@EmployeeID,GETDATE(),0,
		bo.SuggestedActivityID);

		

		MERGE AVL.TM_TRN_InfraTimesheetDetail bi
		USING #SaveTimesheetDetailsModified bo
		ON 
		bi.TimesheetID = bo.TimesheetID 
		AND isnull(bi.ProjectID,0)=ISNULL(bo.ProjectID,0)
		AND bi.TicketID=bo.TicketID
		AND bi.TimesheetDetailID=bo.TimesheetDetailID
		AND bo.SupportTypeID=2 AND (bo.Type='T' OR bo.Type ='ND')

		WHEN MATCHED THEN
		UPDATE
		SET 
		bi.TaskId=bo.ActivityID,
		bi.Hours=bo.Hours,
		bi.TicketTypeMapID=CASE WHEN bo.TicketType=0 THEN bi.TicketTypeMapID ELSE bo.TicketType END,
		bi.ModifiedBy=@EmployeeID,
		bi.ModifiedDateTime=GETDATE(),
		bi.IsNonTicket=bo.IsNonTicket
		WHEN NOT MATCHED BY TARGET AND bo.Hours >0  AND bo.SupportTypeID=2 AND (bo.Type='T' OR bo.Type ='ND') 
		THEN
		INSERT (TimesheetID,TimeTickerID,TowerID,TicketID,Remarks,IsNonTicket,TaskId,TicketTypeMapID,Hours,ProjectID,CreatedBy,CreatedDateTime,IsDeleted,SuggestedActivityID)
		VALUES (bo.TimesheetID, bo.TimeTickerID,bo.TowerID,bo.TicketID,TicketDescription,bo.IsNonTicket,bo.ActivityID,bo.TicketType,bo.Hours,bo.ProjectID,@EmployeeID,GETDATE(),0,
		bo.SuggestedActivityID);

		-- Work Item

		MERGE ADM.TM_TRN_WorkItemTimesheetDetail bi
		USING  #SaveTimesheetDetailsModified bo
 
		ON 
		bi.TimesheetID = bo.TimesheetID 
	AND bi.TimesheetDetailID=bo.TimesheetDetailID 
		and bi.Isdeleted=0 AND bo.SupportTypeId = 0 AND (bo.Type='W' OR bo.Type ='ND')
		WHEN MATCHED THEN
		UPDATE
		SET 
		bi.ServiceID=CASE WHEN ISNULL(bo.ServiceId,0)=0 THEN NULL ELSE bo.ServiceID END,
		bi.ActivityId=bo.ActivityID,
		bi.Hours=bo.Hours,
		bi.ModifiedBy=@EmployeeID,
		bi.ModifiedDate=GETDATE(),
		bi.IsNonTicket=bo.IsNonTicket
		WHEN NOT MATCHED BY TARGET AND bo.Hours >0  AND bo.SupportTypeId = 0 AND (bo.Type='W' OR bo.Type ='ND') 
		THEN
		INSERT (TimeSheetId,WorkItemDetailsId,ServiceID,ActivityID,Hours,IsNonTicket,SuggestedActivityID,Remarks,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
		VALUES (
		bo.TimeSheetId,CASE WHEN ISNULL(bo.TimeTickerId,0) = 0 THEN NULL  ELSE bo.TimeTickerId END ,
		CASE WHEN ISNULL(bo.ServiceId,0)=0 THEN NULL ELSE bo.ServiceID END,bo.ActivityId,bo.Hours,bo.IsNonTicket,bo.SuggestedActivityId,
		TicketDescription,0,@EmployeeId,GetDate(),null,null);
		
		UPDATE TD SET TD.IsDeleted=1,TD.Hours=0,ModifiedDateTime=GETDATE(),ModifiedBy=@EmployeeID
		FROM  AVL.TM_TRN_TimesheetDetail TD INNER JOIN #SaveTimesheetDetailsToDelete SDD with(NOLOCK)
		ON TD.TimesheetId=SDD.TimesheetId AND TD.TimeSheetDetailId=SDD.TimeSheetDetailId 
		AND SDD.SupportTypeID IN(1,3) and (SDD.Type = 'T' OR SDD.Type ='ND')

		UPDATE TD SET TD.IsDeleted=1,TD.Hours=0,ModifiedDateTime=GETDATE(),ModifiedBy=@EmployeeID
		FROM   AVL.TM_TRN_InfraTimesheetDetail  TD INNER JOIN #SaveTimesheetDetailsToDelete SDD with(NOLOCK)
		ON TD.TimesheetId=SDD.TimesheetId AND TD.TimeSheetDetailId=SDD.TimeSheetDetailId AND SDD.SupportTypeID=2 
		AND (SDD.Type = 'T' OR SDD.Type = 'ND')

		--Work Item
		UPDATE TD SET TD.IsDeleted=1,TD.Hours=0,ModifiedDate=GETDATE(),ModifiedBy=@EmployeeID
		FROM   ADM.TM_TRN_WorkItemTimesheetDetail  TD INNER JOIN #SaveTimesheetDetailsToDelete SDD with(NOLOCK)
		ON TD.TimesheetId=SDD.TimesheetId AND TD.TimeSheetDetailId=SDD.TimeSheetDetailId AND SDD.SupportTypeID = 0 
		AND (SDD.[Type] = 'W' OR SDD.Type = 'ND')

		SELECT DISTINCT UserID
		INTO #UserIDTemp FROM #MAS_LoginMaster(NOLOCK)
		WHERE EmployeeID=@EmployeeID AND CustomerID=@CustomerID AND IsDeleted=0


		--New Block for status same
		DECLARE @IsDaily INT;
		SET @IsDaily=(SELECT ISNULL(IsDaily,0) FROM AVL.Customer(NOLOCK)
					  WHERE CustomerID=@CustomerID AND IsDeleted=0)
		CREATE TABLE #TimeSheetDates
		(
			TimeSheetDate DATETIME NULL
		)
		CREATE TABLE #UserIDs
		(
			UserID BIGINT NULL
		)
		IF @IsDaily =0 
		BEGIN
			INSERT INTO #TimeSheetDates
			SELECT DISTINCT TimeSheetDate FROM #SaveTimesheetModified(NOLOCK)
			--UNION 
			--SELECT DISTINCT TimeSheetDate FROM #SaveTimesheetNonDeliveryModified

			INSERT INTO #UserIDs
			SELECT UserID FROM #MAS_LoginMaster(NOLOCK) WHERE EmployeeID=@EmployeeID AND CustomerID=@CustomerID
			
			DECLARE @DateFromWeek DATE;
			DECLARE @StartDateOfWeek DATE;
			DECLARE @EndDateOfWeek DATE;
			DECLARE @WeekNum INT;
			DECLARE @YearNum VARCHAR(10);
			SET @DateFromWeek=(SELECT TOP 1 TimeSheetDate FROM #TimeSheetDates(NOLOCK))
			SET @WeekNum=(select DATEPART(WEEK,@DateFromWeek))
			--get the start date of week
			SET  @YearNum = CAST(DATEPART(YY, @DateFromWeek) AS VARCHAR(10))
			-- once you have the @WeekNum and @YearNum set, the following calculates the date range.
			SET @StartDateOfWeek=(SELECT DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNum-1), 6) AS StartOfWeek);
			SET @EndDateOfWeek=(SELECT DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNum-1), 5) AS EndOfWeek);
			


			DECLARE @CountFreezed INT;
			IF @Flag=1 
				BEGIN
				--Save block
				--Check if any freezed status is present
			
					SET @CountFreezed =(SELECT COUNT(*)  FROM AVL.TM_PRJ_Timesheet(NOLOCK) 
									WHERE CustomerID=@CustomerID AND TimesheetDate >= @StartDateOfWeek
									AND TimesheetDate <= @EndDateOfWeek AND SubmitterId IN(SELECT UserID FROM #UserIDs(NOLOCK))
									AND StatusId =4 )
					IF @CountFreezed>0
						BEGIN
								UPDATE AVL.TM_PRJ_Timesheet SET StatusId=4,ModifiedDateTime=GETDATE()
								WHERE CustomerID=@CustomerID AND TimesheetDate >= @StartDateOfWeek
								AND TimesheetDate <= @EndDateOfWeek AND SubmitterId IN(SELECT UserID FROM #UserIDs(NOLOCK))
								AND StatusId =1
						END

				END

			ELSE 

			BEGIN
			--Submit Block,SETTING STATUS ID AS 2
				SET @CountFreezed =(SELECT COUNT(*)  FROM AVL.TM_PRJ_Timesheet(NOLOCK) 
									WHERE CustomerID=@CustomerID AND TimesheetDate >= @StartDateOfWeek
									AND TimesheetDate <= @EndDateOfWeek AND SubmitterId IN(SELECT UserID FROM #UserIDs(NOLOCK))
									AND StatusId =4 )
				IF @CountFreezed>0
					BEGIN
							UPDATE AVL.TM_PRJ_Timesheet SET StatusId=2,ModifiedDateTime=GETDATE()
							WHERE CustomerID=@CustomerID AND TimesheetDate >= @StartDateOfWeek
							AND TimesheetDate <= @EndDateOfWeek AND SubmitterId IN(SELECT UserID FROM #UserIDs(NOLOCK))
							AND StatusId =4
					END
			END
		END
		ELSE 
			BEGIN
			CREATE TABLE #TimeSheetDatesDaily
			(
			ID BIGINT IDENTITY(1,1),
			TimeSheetDate DATE NULL
			)
			CREATE TABLE #UserIDsDaily
			(
				UserID BIGINT NULL
			)
				--Daily Timesheet
			INSERT INTO #TimeSheetDatesDaily
			SELECT DISTINCT TimeSheetDate FROM #SaveTimesheetModified(NOLOCK)

			INSERT INTO #UserIDsDaily
			SELECT UserID FROM #MAS_LoginMaster WHERE EmployeeID=@EmployeeID AND CustomerID=@CustomerID

			DECLARE @MinID INT;
			DECLARE @MaxID INT;
			SET @MinID=(SELECT MIN(ID) FROM #TimeSheetDatesDaily(NOLOCK))
			SET @MaxID=(SELECT MAX(ID) FROM #TimeSheetDatesDaily(NOLOCK))
			WHILE @MinID <=@MaxID
			BEGIN
				DECLARE @TimeSheetDate DATE;
				SET  @TimeSheetDate=(SELECT TimeSheetDate FROM #TimeSheetDatesDaily(NOLOCK) WHERE ID=@MinID)

				--Check for each dates
				IF @Flag =1
					BEGIN
						SET @CountFreezed =(SELECT COUNT(*)  FROM AVL.TM_PRJ_Timesheet(NOLOCK) 
									WHERE CustomerID=@CustomerID AND TimesheetDate =@TimeSheetDate
									 AND SubmitterId IN(SELECT UserID FROM #UserIDsDaily(NOLOCK))
									AND StatusId =4 )
									--select @CountFreezed as CountFreezed,@TimeSheetDate as TimeSheetDate
						IF @CountFreezed>0
						BEGIN
								UPDATE AVL.TM_PRJ_Timesheet SET StatusId=4,ModifiedDateTime=GETDATE()
								WHERE CustomerID=@CustomerID AND TimesheetDate=@TimeSheetDate
								AND SubmitterId IN(SELECT UserID FROM #UserIDsDaily(NOLOCK))
								AND StatusId =1
						END


					END
				ELSE
					BEGIN
						--Submit Block,SETTING STATUS ID AS 2
					SET @CountFreezed =(SELECT COUNT(*)  FROM AVL.TM_PRJ_Timesheet(NOLOCK) 
									WHERE CustomerID=@CustomerID AND TimesheetDate= @TimeSheetDate
									 AND SubmitterId IN(SELECT UserID FROM #UserIDsDaily(NOLOCK))
									AND StatusId IN(4,1) )

					IF @CountFreezed>0
						BEGIN
								UPDATE AVL.TM_PRJ_Timesheet SET StatusId=2,ModifiedDateTime=GETDATE()
								WHERE CustomerID=@CustomerID AND TimesheetDate =@TimeSheetDate
								 AND SubmitterId IN(SELECT UserID FROM #UserIDsDaily(NOLOCK))
								AND StatusId IN(4,1)
						END


					END
					set @MinID=@MinID+1
			END
			END
		--New Block end


		UPDATE bi
		SET 
		bi.ServiceID=CASE WHEN bo.ServiceID =0 THEN bi.ServiceID ELSE bo.ServiceID END ,
		bi.TicketTypeMapID=CASE WHEN bo.TicketType=0 THEN bi.TicketTypeMapID ELSE bo.TicketType END,
		bi.ModifiedBy=@EmployeeID,
		bi.ModifiedDate=GETDATE(),
		bi.LastUpdatedDate=GETDATE()
		FROM AVL.TK_TRN_TicketDetail bi
		INNER JOIN #SaveTicketDetails bo with(NOLOCK)
		ON bi.TimeTickerID = bo.TimeTickerID 
		AND bi.ProjectID=bo.ProjectID
		AND bi.TicketID=bo.TicketID
		AND bo.TicketStatus <> 0 
		
		--Work Item
        UPDATE bi
		SET 
		bi.ServiceID=CASE WHEN bo.ServiceID =0 THEN bi.ServiceID ELSE bo.ServiceID END,
		bi.StatusMapId = bo.TicketStatus,
		bi.ModifiedBy=@EmployeeID,
		bi.ModifiedDate=GETDATE()
		FROM ADM.ALM_TRN_WorkItem_Details bi
		INNER JOIN #SaveTicketDetails bo with(NOLOCK)
		ON bi.WorkItemDetailsId = bo.TimeTickerID 
		AND bi.Project_Id=bo.ProjectID
		AND bi.WorkItem_Id=bo.TicketID
		 AND bo.TicketStatus <> 0

		--updation of effort till date
		CREATE TABLE #TimeSheetEffortToadd
		( 
		Hours DECIMAL(5,2) NULL,
		TicketID NVARCHAR(100) NULL,
		ProjectID BIGINT NULL,
		SupportTypeID INT NULL,
		Type varchar(10) null
		)
		INSERT INTO #TimeSheetEffortToadd
		SELECT SUM(bo.Hours) AS Hours,bo.TicketID,bo.ProjectID ,bo.SupportTypeID,bo.Type
		--INTO #TimeSheetEffortToadd 
		FROM #SaveTimesheetDetailsModified bo with(NOLOCK)
		GROUP BY BO.TicketID,BO.ProjectID,bo.SupportTypeID,bo.Type

		UPDATE TD
		SET TD.EffortTillDate=ISNULL(TD.EffortTillDate,0) + ISNULL(TS.Hours,0)
		,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE(),LastUpdatedDate=GETDATE()
		FROM AVL.TK_TRN_TicketDetail TD
		INNER JOIN #TimeSheetEffortToadd TS with(NOLOCK)
		ON TD.ProjectID=TS.ProjectID
		AND TD.TicketID=TS.TicketID AND TS.SupportTypeID IN(1,3) AND (TS.Type = 'T' OR TS.Type = 'ND')

		UPDATE TD
		SET TD.EffortTillDate=ISNULL(TD.EffortTillDate,0) - ISNULL(TS.Hours,0)
		,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE(),LastUpdatedDate=GETDATE()
		FROM AVL.TK_TRN_TicketDetail TD
		INNER JOIN #SaveTimesheetDetailsToDelete TS with(NOLOCK)
		ON TD.ProjectID=TS.ProjectID
		AND TD.TicketID=TS.TicketID  AND TS.SupportTypeID IN(1,3) AND (TS.Type = 'T' OR TS.Type = 'ND')

		UPDATE TD
		SET TD.EffortTillDate=ISNULL(TD.EffortTillDate,0) + ISNULL(TS.Hours,0)
		,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE(),LastUpdatedDate=GETDATE()
		FROM AVL.TK_TRN_InfraTicketDetail TD
		INNER JOIN #TimeSheetEffortToadd TS with(NOLOCK)
		ON TD.ProjectID=TS.ProjectID
		AND TD.TicketID=TS.TicketID AND TS.SupportTypeID=2 AND (TS.Type = 'T' OR TS.Type = 'ND')


		UPDATE TD
		SET TD.EffortTillDate=ISNULL(TD.EffortTillDate,0) - ISNULL(TS.Hours,0)
		,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE(),LastUpdatedDate=GETDATE()
		FROM AVL.TK_TRN_InfraTicketDetail TD
		INNER JOIN #SaveTimesheetDetailsToDelete TS with(NOLOCK)
		ON TD.ProjectID=TS.ProjectID
		AND TD.TicketID=TS.TicketID  AND TS.SupportTypeID=2 AND (TS.Type = 'T' OR TS.Type = 'ND')
		--Work Item

		UPDATE TD
		SET TD.WorkProfilerEffort=ISNULL(TD.WorkProfilerEffort,0) + ISNULL(TS.Hours,0)
		,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE()
		FROM adm.ALM_TRN_WorkItem_Details TD
		INNER JOIN #TimeSheetEffortToadd TS with(NOLOCK)
		ON TD.Project_Id=TS.ProjectID
		AND TD.WorkItem_Id=TS.TicketID AND TS.SupportTypeID = 0 AND (TS.Type = 'W' OR TS.Type = 'ND')
		UPDATE TD
		SET TD.WorkProfilerEffort=ISNULL(TD.WorkProfilerEffort,0) - ISNULL(TS.Hours,0)
		,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE()
		FROM adm.ALM_TRN_WorkItem_Details TD
		INNER JOIN #SaveTimesheetDetailsToDelete TS with(NOLOCK)
		ON TD.Project_Id=TS.ProjectID
		AND TD.WorkItem_Id=TS.TicketID AND TS.SupportTypeID = 0 AND (TS.Type = 'W' OR TS.Type = 'ND')



		UPDATE TT
		SET TT.ImplementationEffort=ISNULL(TD.EffortTillDate,0)
		,TT.ModifiedBy=@EmployeeID,TT.ModifiedDate=GETDATE()
		FROM AVL.TK_TRN_TicketDetail TD 
		INNER JOIN #TimeSheetEffortToSubtract TS with(NOLOCK)
		ON TD.ProjectID=TS.ProjectID
		AND TD.TicketID=TS.TicketID
		INNER JOIN avl.DEBT_TRN_HealTicketDetails TT ON TD.TicketID=TT.HealingTicketID
		INNER JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic PM with(NOLOCK) ON PM.ProjectPatternMapID=TT.ProjectPatternMapID AND TD.ProjectID=PM.ProjectID AND TT.IsDeleted=0
		INNER JOIN avl.TK_MAP_TicketTypeMapping TTM with(NOLOCK) on TD.ProjectID = TTM.ProjectID AND TD.TicketTypeMapID = TTM.TicketTypeMappingID 

		--Infra A/H Ticket Update Implementation Effort---
		UPDATE TTDO
		SET TTDO.ImplementationEffort=ISNULL(TD.EffortTillDate,0)
		,TTDO.ModifiedBy=@EmployeeID,TTDO.ModifiedDate=GETDATE()
		FROM AVL.TK_TRN_InfraTicketDetail TD 
		INNER JOIN #TimeSheetEffortToSubtract TS with(NOLOCK)
		ON TD.ProjectID=TS.ProjectID
		AND TD.TicketID=TS.TicketID
		INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails] TT with(NOLOCK) ON TD.TicketID=TT.HealingTicketID 
		INNER JOIN AVL.DEBT_TRN_InfraHealTicketEfffortDormantDetails TTDO ON TTDO.HealingID=TT.Id 
		INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] PM with(NOLOCK) ON PM.ProjectPatternMapID=TT.ProjectPatternMapID AND TD.ProjectID=PM.ProjectID AND TT.IsDeleted=0
		INNER JOIN avl.TK_MAP_TicketTypeMapping TTM with(NOLOCK) on TD.ProjectID = TTM.ProjectID AND TD.TicketTypeMapID = TTM.TicketTypeMappingID 

		--Updated Actual start date and Actual end date
       	Update bi set Actual_StartDate=(select MIN (t.TimesheetDate) from  ADM.TM_TRN_WorkItemTimesheetDetail tw
              join AVL.TM_PRJ_Timesheet  t on t.TimesheetId = tw.TimesheetId
              where tw.IsDeleted =0 AND t.ProjectId =bi.Project_Id AND  tw.WorkItemDetailsId =bi.WorkItemDetailsId),
              Actual_EndDate =(select MAX (t.TimesheetDate) from  ADM.TM_TRN_WorkItemTimesheetDetail tw
              join AVL.TM_PRJ_Timesheet  t on t.TimesheetId = tw.TimesheetId
              where tw.IsDeleted =0 AND t.ProjectId =bi.Project_Id AND  tw.WorkItemDetailsId =bi.WorkItemDetailsId)
              FROM ADM.ALM_TRN_WorkItem_Details bi
              INNER JOIN #SaveTimesheetDetailsModified STD with(NOLOCK)         
              ON bi.WorkItemDetailsId = STD.TimeTickerID             
              AND bi.Project_Id=STD.ProjectID
              AND bi.WorkItem_Id=STD.TicketID
              INNER JOIN  [PP].[ALM_MAP_Status] Map with(NOLOCK) on Map.StatusMapId=bi.StatusMapId
              INNER JOIN  [PP].[ALM_MAS_Status] Mas with(NOLOCK) on Mas.StatusId=map.StatusId
              where bi.IsDeleted=0 AND map.StatusId=4 AND bi.Actual_StartDate is null AND bi.Actual_EndDate is null
		
IF OBJECT_ID('tempdb..#MAS_LoginMaster', 'U') IS NOT NULL
BEGIN
	DROP TABLE #MAS_LoginMaster
END
IF OBJECT_ID('tempdb..#SaveTicketDetails', 'U') IS NOT NULL
BEGIN	
	DROP TABLE #SaveTicketDetails
END
IF OBJECT_ID('tempdb..#SaveTimesheetDetails', 'U') IS NOT NULL
BEGIN
	DROP TABLE #SaveTimesheetDetails
END
IF OBJECT_ID('tempdb..#SaveTimesheetDetailsForUpdate', 'U') IS NOT NULL
BEGIN
	DROP TABLE #SaveTimesheetDetailsForUpdate
END
IF OBJECT_ID('tempdb..#SaveTimesheetDetailsToDelete', 'U') IS NOT NULL
BEGIN
	DROP TABLE #SaveTimesheetDetailsToDelete
END
IF OBJECT_ID('tempdb..#SaveTimesheet', 'U') IS NOT NULL
BEGIN
	DROP TABLE #SaveTimesheet
END
IF OBJECT_ID('tempdb..#SaveTimesheetModified', 'U') IS NOT NULL
BEGIN
	DROP TABLE #SaveTimesheetModified
END
IF OBJECT_ID('tempdb..#TimeSheetEffortToSubtract', 'U') IS NOT NULL
BEGIN
	DROP TABLE #TimeSheetEffortToSubtract
END
IF OBJECT_ID('tempdb..#SaveTimesheetDetailsModified', 'U') IS NOT NULL
BEGIN
	DROP TABLE #SaveTimesheetDetailsModified
END
IF OBJECT_ID('tempdb..#UserIDTemp', 'U') IS NOT NULL
BEGIN
	DROP TABLE #UserIDTemp
END
IF OBJECT_ID('tempdb..#TimeSheetDates', 'U') IS NOT NULL
BEGIN
	DROP TABLE #TimeSheetDates
END
IF OBJECT_ID('tempdb..#UserIDs', 'U') IS NOT NULL
BEGIN
	DROP TABLE #UserIDs
END
IF OBJECT_ID('tempdb..#TimeSheetDatesDaily', 'U') IS NOT NULL
BEGIN
	DROP TABLE #TimeSheetDatesDaily
END
IF OBJECT_ID('tempdb..#UserIDsDaily', 'U') IS NOT NULL
BEGIN
	DROP TABLE #UserIDsDaily
END
IF OBJECT_ID('tempdb..#TimeSheetEffortToadd', 'U') IS NOT NULL
BEGIN
	DROP TABLE #TimeSheetEffortToadd
END

	END TRY
	BEGIN CATCH

			DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
	EXEC AVL_InsertError '[AVL].[SaveTicketingModuleData]', @ErrorMessage, 0,@EmployeeID
		
	END CATCH;

	
END
