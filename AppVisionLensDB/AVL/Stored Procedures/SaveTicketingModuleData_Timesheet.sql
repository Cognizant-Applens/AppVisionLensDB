/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [AVL].[SaveTicketingModuleData_Timesheet]
	@SaveTimesheetDetails AVL.SaveTimesheetDetails readonly,
	@SaveTicketDetails AVL.SaveTicketDetails readonly,
	@Flag INT=NULL,
	@EmployeeID NVARCHAR(50)=NULL
AS
BEGIN


	BEGIN TRY
		
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
		[UserID] INTO #SaveTicketDetails  FROM @SaveTicketDetails 

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
		TicketDescription
		INTO #SaveTimesheetDetails  FROM @SaveTimesheetDetails WHERE Hours>0 AND IsNonTicket=0
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
		TicketDescription
		INTO #SaveTimesheetDetailsForUpdate  FROM #SaveTimesheetDetails WHERE Hours=0 AND IsNonTicket=0

		--ADDED TO ENSURE THE USER ID IS SAME AS THE SUBMITTER ID FOR THE PROJECT

		UPDATE TD
		SET TD.UserID=LM.UserID
		FROM #SaveTimesheetDetails TD
		INNER JOIN AVL.MAS_LoginMaster LM
		ON TD.ProjectID =LM.ProjectID AND LM.EmployeeID=@EmployeeID
		--SELECT * FROM @SaveTimesheetDetails
		SELECT * FROM #SaveTimesheetDetails

		SELECT DISTINCT 
		[ProjectID],
		[TimeSheetID],
		[TimesheetDate],
		[UserID],
		[CustomerID],
		[IsNonTicket]
		INTO #SaveTimesheet  FROM #SaveTimesheetDetails  WHERE  IsNonTicket=0

		--select * from #SaveTimesheet
		UPDATE   ST
		SET ST.TimeSheetID=PT.TimesheetId
		FROM #SaveTimesheet ST
		INNER JOIN AVL.TM_Prj_Timesheet PT
		ON CONVERT(DATE,ST.TimesheetDate)=CONVERT(DATE,PT.TimesheetDate) AND isnull(ST.ProjectID,0)=ISnull(PT.ProjectID,0) AND ST.UserID=PT.SubmitterId
		AND PT.IsNonTicket=0

		SELECT DISTINCT 
		[ProjectID],
		[TimeSheetID],
		[TimesheetDate],
		[UserID],
		[CustomerID],
		[IsNonTicket]
		INTO #SaveTimesheetModified  FROM #SaveTimesheet

		MERGE AVL.TM_Prj_Timesheet bi
		USING #SaveTimesheetModified bo
		ON bi.TimesheetID = bo.TimesheetID AND bi.ProjectID=bo.ProjectID
		 AND bi.SubmitterID=bo.UserID 
		 AND bo.TimesheetID <> 0
		 AND CONVERT(DATE,bi.TimesheetDate)=CONVERT(DATE,bo.TimesheetDate)
		 and bi.IsNonTicket=0 and bi.ProjectID is not null
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


		--select * from AVL.TM_Prj_Timesheet

		UPDATE  TS
		SET TS.TimeSheetID=TD.TimeSheetID
		FROM #SaveTimesheetDetails TS
		INNER JOIN AVL.TM_Prj_Timesheet TD
		ON isnull(TS.ProjectID,0)=Isnull(TD.ProjectID,0) 
		AND CONVERT(DATE,TS.TimesheetDate)=CONVERT(DATE,TD.TimesheetDate)
		AND TS.UserID=TD.SubmitterId
		AND TD.CustomerID=TS.[CustomerID]
		WHERE Hours > 0 and TD.IsNonTicket=0

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
		[ApplicationID] INTO  #SaveTimesheetDetailsModified  FROM #SaveTimesheetDetails WHERE Hours>0 AND IsNonTicket=0
		
		
		--To Subtract effort till date
		SELECT SUM(bi.Hours) AS Hours,bo.TicketID,bo.ProjectID INTO #TimeSheetEffortToSubtract FROM #SaveTimesheetDetailsModified bo
		INNER JOIN AVL.TM_TRN_TimesheetDetail bi
		ON bi.TimesheetID = bo.TimesheetID 
		AND isnull(bi.ProjectID,0)=ISNULL(bo.ProjectID,0)
		AND bi.TicketID=bo.TicketID
		AND bi.TimesheetDetailID=bo.TimesheetDetailID
		AND bi.IsNonTicket=0
		GROUP BY BO.TicketID,BO.ProjectID


		UPDATE TD
		SET TD.EffortTillDate=ISNULL(TD.EffortTillDate,0)- ISNULL(TS.Hours,0)
		FROM AVL.TK_TRN_TicketDetail TD
		INNER JOIN #TimeSheetEffortToSubtract TS
		ON TD.ProjectID=TS.ProjectID
		AND TD.TicketID=TS.TicketID
	

		MERGE AVL.TM_TRN_TimesheetDetail bi
		USING #SaveTimesheetDetailsModified bo
		ON 
		bi.TimesheetID = bo.TimesheetID 
		AND isnull(bi.ProjectID,0)=ISNULL(bo.ProjectID,0)
		AND bi.TicketID=bo.TicketID
		AND bi.TimesheetDetailID=bo.TimesheetDetailID
		--AND bi.ServiceId=bo.ServiceId
		--and bi.ActivityId=bo.ActivityId
		AND bi.IsNonTicket=0

		WHEN MATCHED THEN
		UPDATE
		SET 
		bi.ServiceID=bo.ServiceID,
		bi.ActivityID=bo.ActivityID,
		bi.Hours=bo.Hours,
		bi.TicketTypeMapID=bo.TicketType,
		bi.ModifiedBy=@EmployeeID,
		bi.ModifiedDateTime=GETDATE(),
		bi.IsNonTicket=bo.IsNonTicket
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (TimesheetID,TimeTickerID,ApplicationID,TicketID,IsNonTicket,ServiceId,ActivityID,TicketTypeMapID,Hours,ProjectID,CreatedBy,CreatedDateTime)
		VALUES (bo.TimesheetID, bo.TimeTickerID,bo.ApplicationID,bo.TicketID,bo.IsNonTicket,bo.ServiceId,bo.ActivityID,bo.TicketType,bo.Hours,bo.ProjectID,@EmployeeID,GETDATE());
		
		
		--Update TS 
		--SET TS.Hours=TSU.Hours
		--FROM AVL.TM_TRN_TimesheetDetail TS
		--INNER JOIN #SaveTimesheetDetailsForUpdate TSU ON TSU.TimesheetDetailID=TS.TimeSheetDetailId
		--WHere TSU.Hours=0
		
		select sum(TSD.Hours) as EffortTilldate ,TSD.TicketID as TicketID,TSD.ProjectID as ProjectID,TSD.UserID
		into #TempEffortHours 
		from #SaveTimesheetDetails TSD GROUP by TSD.TicketID ,TSD.ProjectID,TSD.UserID

		----Non Delivery Activity Start
		--Non Delivery Activity Start
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
		TicketDescription
		INTO #SaveTimesheetDetailsNonDelivery  FROM @SaveTimesheetDetails WHERE Hours>0 AND IsNonTicket=1

		SELECT * FROM @SaveTimesheetDetails

		SELECT DISTINCT 
		[ProjectID],
		[TimeSheetID],
		[TimesheetDate],
		[UserID],
		[CustomerID],
		[IsNonTicket]
		
		INTO #SaveTimesheetNonDelivery  FROM @SaveTimesheetDetails  WHERE  IsNonTicket=1

		UPDATE   ST
		SET ST.TimeSheetID=PT.TimesheetId
		FROM #SaveTimesheetNonDelivery ST
		INNER JOIN AVL.TM_Prj_Timesheet PT
		ON CONVERT(DATE,ST.TimesheetDate)=CONVERT(DATE,PT.TimesheetDate) 
		AND ST.CustomerID=PT.CustomerID AND ST.UserID=PT.SubmitterId AND PT.IsNonTicket=1

		SELECT DISTINCT 
		[ProjectID],
		[TimeSheetID],
		[TimesheetDate],
		[UserID],
		[CustomerID],
		[IsNonTicket]
		INTO #SaveTimesheetNonDeliveryModified  FROM #SaveTimesheetNonDelivery

		DELETE FROM #SaveTimesheetNonDeliveryModified 
		WHERE TimesheetDate NOT IN(SELECT TimeSheetDate FROM #SaveTimesheetDetailsNonDelivery)

		--SELECT * FROM #SaveTimesheetDetailsNonDelivery
		--SELECT * FROM #SaveTimesheetNonDelivery

		SELECT * FROM AVL.TM_Prj_Timesheet bi
		INNER JOIN  #SaveTimesheetNonDeliveryModified bo
		ON bi.TimesheetID = bo.TimesheetID AND bi.SubmitterID=bo.UserID AND bo.TimesheetID <> 0
		AND bi.CustomerID=bo.CustomerID AND bi.IsNonTicket=1


		MERGE AVL.TM_Prj_Timesheet bi
		USING #SaveTimesheetNonDeliveryModified bo
		ON bi.TimesheetID = bo.TimesheetID AND bi.SubmitterID=bo.UserID AND bo.TimesheetID <> 0
		AND bi.CustomerID=bo.CustomerID AND bi.IsNonTicket=1

		WHEN MATCHED THEN
		UPDATE
		SET 
		bi.StatusID=case when   (bi.StatusId=4 AND @Flag=1) THEN bi.StatusId
					ELSE @Flag
					END,
		bi.ModifiedBy=@EmployeeID,
		bi.ModifiedDateTime=GETDATE(),
		bi.isnonticket=1
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (ProjectID,SubmitterID,CustomerID,IsNonTicket, TimesheetDate, StatusId,CreatedBy,CreatedDateTime)
		VALUES (NULL,bo.UserID,bo.CustomerID,bo.IsNonTicket, bo.TimesheetDate,@Flag,@EmployeeID,GETDATE());


		UPDATE  TS
		SET TS.TimeSheetID=TD.TimeSheetID
		FROM #SaveTimesheetDetailsNonDelivery TS
		INNER JOIN AVL.TM_Prj_Timesheet TD
		ON  TS.[TimesheetDate]=TD.TimesheetDate AND TS.UserID=TD.SubmitterId AND TD.IsNonTicket=1
		WHERE Hours>0

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
		TicketDescription
		 INTO  #SaveTimesheetDetailsNonDeliveryModified  FROM #SaveTimesheetDetailsNonDelivery WHERE Hours>0



		MERGE AVL.TM_TRN_TimesheetDetail bi
		USING #SaveTimesheetDetailsNonDeliveryModified bo
		ON 
		bi.TimesheetID = bo.TimesheetID 
		--AND bi.customerID=bo.customerID
		AND bi.ActivityID=bo.ActivityID
		AND BI.IsNonTicket=1
		WHEN MATCHED THEN
		UPDATE
		SET 
		bi.ActivityID=bo.ActivityID,
		bi.Hours=bo.Hours,
		bi.ModifiedBy=@EmployeeID,
		bi.ModifiedDateTime=GETDATE(),
		bi.IsNonTicket=bo.IsNonTicket
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (TimesheetID,TimeTickerID,ApplicationID,TicketID,Remarks,IsNonTicket,ServiceId,ActivityID,TicketTypeMapID,Hours,ProjectID,CreatedBy,CreatedDateTime)
		VALUES (bo.TimesheetID,NULL,NULL,bo.TicketID,TicketDescription,bo.IsNonTicket,NULL,bo.ActivityID,NULL,bo.Hours,NULL,@EmployeeID,GETDATE());
		
		SELECT DISTINCT UserID
		INTO #UserIDTemp FROM AVL.MAS_LoginMaster 
		WHERE EmployeeID=@EmployeeID AND CustomerID=@CustomerID AND IsDeleted=0


		--Logic to get the Ticketed Effort
		SELECT TD.TimesheetDate,TD.CustomerID,TD.StatusId,TD.SubmitterId,TD.IsNonTicket
		INTO #TempToUpdate FROM #SaveTimesheetNonDeliveryModified ND
		INNER JOIN AVL.TM_Prj_Timesheet TD
		ON ND.TimesheetDate=TD.TimesheetDate
		AND ND.CustomerID=TD.CustomerID
		WHERE ND.UserID  IN(SELECT UserID FROM #UserIDTemp)  AND TD.IsNonTicket=0 AND TD.StatusId=4

		-- TO UPDATE ONLY NON-TICKET (IF SAVED, AND TIMESHEET IS IN UNFREEZED STATUS)
		UPDATE PT
		SET  PT.StatusId=TU.StatusId ,PT.ModifiedDateTime=GETDATE()
		from #TempToUpdate TU
		inner join AVL.TM_Prj_Timesheet PT
		ON TU.TimesheetDate=PT.TimesheetDate AND TU.CustomerID=PT.CustomerID
		AND TU.SubmitterId=PT.SubmitterId
		AND PT.IsNonTicket=1 AND PT.StatusId IN(1)

		--Temp for submit flag updation
			SELECT TD.TimesheetDate,TD.CustomerID,TD.StatusId,TD.SubmitterId,TD.IsNonTicket
		INTO #TempToUpdateTicketed FROM #SaveTimesheetNonDeliveryModified ND
		INNER JOIN AVL.TM_Prj_Timesheet TD
		ON ND.TimesheetDate=TD.TimesheetDate
		AND ND.CustomerID=TD.CustomerID
		WHERE ND.UserID  IN(SELECT UserID FROM #UserIDTemp) AND TD.IsNonTicket=0 



		-- TO UPDATE FOR TICKETED EFFORT (IF SUBMITTED WITH NON DELIVERY ACTIVITY AFTER UN FREEZE)
		UPDATE PT
		SET  PT.StatusId=2,PT.ModifiedDateTime=GETDATE()
		from #TempToUpdateTicketed TU
		inner join AVL.TM_Prj_Timesheet PT
		ON TU.TimesheetDate=PT.TimesheetDate AND TU.CustomerID=PT.CustomerID
		AND TU.SubmitterId=PT.SubmitterId
		AND PT.IsNonTicket=0 AND @Flag=2

		--NEWLY ADDED PROD ISSUE
		--GET THE LIST OF TICKETED DETAILS WITH SUBMITTED STATUS
		SELECT TD.TimesheetDate,TD.CustomerID,TD.StatusId,TD.SubmitterId,TD.IsNonTicket
		INTO #TempToUpdateNonTicketed FROM #SaveTimesheetModified ND
		INNER JOIN AVL.TM_Prj_Timesheet TD
		ON ND.TimesheetDate=TD.TimesheetDate
		AND ND.CustomerID=TD.CustomerID
		WHERE ND.UserID  IN(SELECT UserID FROM #UserIDTemp)  AND TD.IsNonTicket=0 AND TD.StatusId=2



		--SELECT * FROM #TempToUpdateNonTicketed
		--UPDATE THE STATUS TO SUBMITTED IF ANY NN DELIVERY ENTRY EXISTS IN UNFREEZED STATUS OR SAVED STATUS
		UPDATE TD SET TD.StatusId=ND.StatusID,TD.ModifiedDateTime=GETDATE()
		FROM #TempToUpdateNonTicketed ND
		INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) TD
		ON ND.TimesheetDate=TD.TimesheetDate
		AND ND.CustomerID=TD.CustomerID
		WHERE ND.SubmitterId  IN(SELECT UserID FROM #UserIDTemp)  AND TD.IsNonTicket=1 AND TD.StatusId IN(1,4)
		AND @Flag=2


		--SELECT * FROM #TempToUpdateNonTicketed ND
		--INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) TD
		--ON ND.TimesheetDate=TD.TimesheetDate
		--AND ND.CustomerID=TD.CustomerID
		--WHERE ND.SubmitterId  IN(SELECT UserID FROM #UserIDTemp)  AND TD.IsNonTicket=1 AND TD.StatusId=4

		--END


		--New Block for status same
		DECLARE @IsDaily INT;
		SET @IsDaily=(SELECT IsDaily FROM AVL.Customer 
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
			SELECT DISTINCT TimeSheetDate FROM #SaveTimesheetModified
			UNION 
			SELECT DISTINCT TimeSheetDate FROM #SaveTimesheetNonDeliveryModified

			INSERT INTO #UserIDs
			SELECT UserID FROM AVL.MAS_LoginMaster(NOLOCK) WHERE EmployeeID=@EmployeeID AND CustomerID=@CustomerID
			
			DECLARE @DateFromWeek DATE;
			DECLARE @StartDateOfWeek DATE;
			DECLARE @EndDateOfWeek DATE;
			DECLARE @WeekNum INT;
			DECLARE @YearNum VARCHAR(10);
			SET @DateFromWeek=(SELECT TOP 1 TimeSheetDate FROM #TimeSheetDates)
			SET @WeekNum=(select DATEPART(WEEK,@DateFromWeek))
			--get the start date of week
			SET  @YearNum = CAST(DATEPART(YY, @DateFromWeek) AS VARCHAR(10))
			-- once you have the @WeekNum and @YearNum set, the following calculates the date range.
			SET @StartDateOfWeek=(SELECT DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNum-1), 6) AS StartOfWeek);
			SET @EndDateOfWeek=(SELECT DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNum-1), 5) AS EndOfWeek);
			
			SELECT * FROM #TimeSheetDates
			SELECT @YearNum AS YearNum
			SELECT @StartDateOfWeek AS StartDateOfWeek;
			SELECT @EndDateOfWeek AS EndDateOfWeek;

			SELECT * FROM AVL.TM_PRJ_Timesheet(NOLOCK) 
			WHERE CustomerID=@CustomerID AND TimesheetDate >= @StartDateOfWeek
			AND TimesheetDate <= @EndDateOfWeek AND SubmitterId IN(SELECT UserID FROM #UserIDs )

			DECLARE @CountFreezed INT;
			IF @Flag=1 
				BEGIN
				--Save block
				--Check if any freezed status is present
			
					SET @CountFreezed =(SELECT COUNT(*)  FROM AVL.TM_PRJ_Timesheet(NOLOCK) 
									WHERE CustomerID=@CustomerID AND TimesheetDate >= @StartDateOfWeek
									AND TimesheetDate <= @EndDateOfWeek AND SubmitterId IN(SELECT UserID FROM #UserIDs)
									AND StatusId =4 )
					IF @CountFreezed>0
						BEGIN
								UPDATE AVL.TM_PRJ_Timesheet SET StatusId=4
								WHERE CustomerID=@CustomerID AND TimesheetDate >= @StartDateOfWeek
								AND TimesheetDate <= @EndDateOfWeek AND SubmitterId IN(SELECT UserID FROM #UserIDs)
								AND StatusId =4
						END

				END

			ELSE 

			BEGIN
			--Submit Block,SETTING STATUS ID AS 2
				SET @CountFreezed =(SELECT COUNT(*)  FROM AVL.TM_PRJ_Timesheet(NOLOCK) 
									WHERE CustomerID=@CustomerID AND TimesheetDate >= @StartDateOfWeek
									AND TimesheetDate <= @EndDateOfWeek AND SubmitterId IN(SELECT UserID FROM #UserIDs)
									AND StatusId =4 )
				IF @CountFreezed>0
					BEGIN
							UPDATE AVL.TM_PRJ_Timesheet SET StatusId=2,ModifiedDateTime=GETDATE()
							WHERE CustomerID=@CustomerID AND TimesheetDate >= @StartDateOfWeek
							AND TimesheetDate <= @EndDateOfWeek AND SubmitterId IN(SELECT UserID FROM #UserIDs)
							AND StatusId =4
					END
			END
		END
		--ELSE 
		--BEGIN
		--END


		--New Block end
		UPDATE bi
		SET 
		bi.ServiceID=bo.ServiceID,
		--bi.EffortTillDate=bi.EffortTillDate + ISNULL(bo.TotalEffort,0),
		--bi.TicketStatusMapID=TicketStatus,
		bi.TicketTypeMapID=bo.TicketType,
		--bi.DARTStatusID=bo.DARTStatusID,
		bi.ModifiedBy=@EmployeeID,
		bi.ModifiedDate=GETDATE()
		FROM AVL.TK_TRN_TicketDetail bi
		INNER JOIN #SaveTicketDetails bo
		ON bi.TimeTickerID = bo.TimeTickerID 
		AND bi.ProjectID=bo.ProjectID
		AND bi.TicketID=bo.TicketID
		AND bo.TicketStatus <> 0

		--updation of effort till date
		SELECT SUM(bo.Hours) AS Hours,bo.TicketID,bo.ProjectID 
		INTO #TimeSheetEffortToadd 
		FROM #SaveTimesheetDetailsModified bo
		GROUP BY BO.TicketID,BO.ProjectID


		UPDATE TD
		SET TD.EffortTillDate=ISNULL(TD.EffortTillDate,0) + ISNULL(TS.Hours,0)
		FROM AVL.TK_TRN_TicketDetail TD
		INNER JOIN #TimeSheetEffortToadd TS
		ON TD.ProjectID=TS.ProjectID
		AND TD.TicketID=TS.TicketID


	END TRY
	BEGIN CATCH
		--SELECT 
		--	ERROR_NUMBER() AS ErrorNumber
		--	,ERROR_SEVERITY() AS ErrorSeverity
		--	,ERROR_STATE() AS ErrorState
		--	,ERROR_PROCEDURE() AS ErrorProcedure
		--	,ERROR_LINE() AS ErrorLine
		--	,ERROR_MESSAGE() AS ErrorMessage;
			DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
	EXEC AVL_InsertError '[AVL].[SaveTicketingModuleData]', @ErrorMessage, 0,@EmployeeID
		
	END CATCH;

	
END
