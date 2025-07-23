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
-- Author:      Prakash, Divya     
-- Create date:      23 Nov 2018
-- Description:    Mini Job Push
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- EXEC [AVL].[Mini_SaveTimeSheetDetails] 

-- ============================================================================ 
--[AVL].[Mini_SaveTimeSheetDetails]
CREATE PROCEDURE [AVL].[Mini_SaveTimeSheetDetails]
AS
BEGIN

BEGIN TRY  
BEGIN TRAN
SET NOCOUNT ON;     

	CREATE TABLE #TimeSheetTickets
	(
		SNo INT IDENTITY(1,1),
		TicketID NVARCHAR(50),
		ProjectID BIGINT,
		UserID BIGINT,
		ApplicationID BIGINT,
		ServiceID BIGINT,
		ActivityID BIGINT,
		TicketTypeMapID BIGINT,
		StartTime DATETIME,
		EndTime DATETIME,
		EmployeeID NVARCHAR(50),
		IsNonDelivery BIT,
		TimeTickerID BIGINT,
		NonTicketDescription NVARCHAR(250),
		TotalEffort DECIMAL(8,2),
		CustomerID BIGINT,
		TimeSheetID BIGINT,
		SessionID BIGINT,
		UserCreatedTimeDate DATETIME,
		IsCognizant INT NULL
	)

	CREATE TABLE #FinalSessions
	(
		SNo INT IDENTITY(1,1),
		SessionID BIGINT, 
		ProjectID BIGINT, 
		TicketID NVARCHAR(50),
		EmployeeID NVARCHAR(50),
		UserID BIGINT,
		TotalSeconds INT,
		IsNonDelivery INT
	)
	CREATE TABLE #TotalSessions
	(
	SessionID BIGINT NULL,
	ProjectID BIGINT NULL,
	TicketID NVARCHAR(50) NULL,
	EmployeeID NVARCHAR(50) NULL,
	UserID  BIGINT NULL,
	TotalSeconds BIGINT NULL,
	IsNonDelivery BIT NULL
	)
		--Step 1 getting the cognizant sessions for past 2 days that are not processed
		INSERT	INTO #TotalSessions 
		SELECT ms.SessionID, ms.ProjectID,ms.TicketID,ms.EmployeeID,ms.UserID,
		 ((ISNULL(ms.[hours],0)*3600)+ (ISNULL(ms.[minutes],0)*60)+ISNULL(ms.[seconds],0)) AS TotalSeconds,
		MS.IsNonDelivery AS IsNonDelivery
		FROM AVL.TK_Mini_Sessions(NOLOCK) ms
		JOIN AVL.MAS_ProjectMaster(NOLOCK) pm on ms.ProjectID=pm.ProjectID 
		INNER JOIN AVL.Customer(NOLOCK) C ON PM.CustomerID=C.CustomerID
		WHERE ms.IsDeleted=0 
		 AND ISNULL(ms.ServiceID,0)>0 and ISNULL(ms.ActivityID,0)>0
		AND ISNULL(ms.ProjectID,0)>0 
		AND ms.IsRunning=1
		AND C.IsCognizant=1 AND ISNULL(C.IsEffortTrackActivityWise,1)=1
		AND ISNULL(ms.IsDeleted,0)=0 AND ISNULL(ms.IsProcessed,0) IN(0,2)
		AND CONVERT(DATE,ms.CreatedOn) >= CONVERT(DATE,GETDATE() -2)

		INSERT	INTO #TotalSessions 
		SELECT ms.SessionID, ms.ProjectID,ms.TicketID,ms.EmployeeID,ms.UserID,
		 ((ISNULL(ms.[hours],0)*3600)+ (ISNULL(ms.[minutes],0)*60)+ISNULL(ms.[seconds],0)) AS TotalSeconds,
		MS.IsNonDelivery AS IsNonDelivery
		FROM AVL.TK_Mini_Sessions(NOLOCK) ms
		JOIN AVL.MAS_ProjectMaster(NOLOCK) pm on ms.ProjectID=pm.ProjectID 
		INNER JOIN AVL.Customer(NOLOCK) C ON PM.CustomerID=C.CustomerID
		WHERE ms.IsDeleted=0 
		 AND ISNULL(ms.ServiceID,0)>0 
		AND ISNULL(ms.ProjectID,0)>0 
		AND ms.IsRunning=1
		AND C.IsCognizant=1 AND ISNULL(C.IsEffortTrackActivityWise,1)=0
		AND ISNULL(ms.IsDeleted,0)=0 AND ISNULL(ms.IsProcessed,0) IN(0,2)
		AND CONVERT(DATE,ms.CreatedOn) >= CONVERT(DATE,GETDATE() -2)

	--Step 2 getting the Customer sessions for past 2 days that are not processed
		SELECT ms.SessionID, ms.ProjectID,ms.TicketID,ms.EmployeeID,ms.UserID, ((ISNULL(ms.[hours],0)*3600)+ (ISNULL(ms.[minutes],0)*60)+ISNULL(ms.[seconds],0)) AS TotalSeconds,
		MS.IsNonDelivery 
		INTO #TotalSessionsCustomer
		FROM AVL.TK_Mini_Sessions(NOLOCK) ms
		JOIN AVL.MAS_ProjectMaster(NOLOCK) pm on ms.ProjectID=pm.ProjectID 
		INNER JOIN AVL.Customer(NOLOCK) C ON PM.CustomerID=C.CustomerID
		WHERE ms.IsDeleted=0 
		AND ISNULL(Ms.TicketTypeMapID,0)>0		
		AND ISNULL(MS.ProjectID,0)>0 
		AND ms.IsRunning=1
		AND C.IsCognizant=0
		AND ISNULL(ms.IsDeleted,0)=0 AND ISNULL(ms.IsProcessed,0) IN(0,2)
		AND CONVERT(DATE,ms.CreatedOn) >= CONVERT(DATE,GETDATE() -2)

		--Step 3 getting the non delivery sessions for past 2 days that are not processed
		SELECT ms.SessionID, ms.ProjectID,ms.TicketID,ms.EmployeeID,ms.UserID, ((ISNULL(ms.[hours],0)*3600)+ (ISNULL(ms.[minutes],0)*60)+ISNULL(ms.[seconds],0)) AS TotalSeconds,
		MS.IsNonDelivery 
		INTO #TotalSessionsNonDelivery
		FROM AVL.TK_Mini_Sessions(NOLOCK) ms
		JOIN AVL.MAS_ProjectMaster(NOLOCK) pm on ms.ProjectID=pm.ProjectID 
		INNER JOIN AVL.Customer(NOLOCK) C ON PM.CustomerID=C.CustomerID
		WHERE ms.IsDeleted=0 	
		AND ISNULL(MS.ProjectID,0)>0 
		AND ms.IsRunning=1 AND
		ms.IsNonDelivery=1 and ms.NonDeliveryActivityType >0
		AND ISNULL(ms.IsDeleted,0)=0 AND ISNULL(ms.IsProcessed,0) IN(0,2)
		AND CONVERT(DATE,ms.CreatedOn) >= CONVERT(DATE,GETDATE() -2)

		--Step 4 :inserting overall sessions
		INSERT INTO #FinalSessions
		SELECT SessionID, ProjectID,TicketID,EmployeeID,UserID,TotalSeconds,IsNonDelivery  FROM #TotalSessions 
		UNION ALL 
		SELECT SessionID, ProjectID,TicketID,EmployeeID,UserID,TotalSeconds,IsNonDelivery FROM #TotalSessionsCustomer 
		UNION
		SELECT SessionID, ProjectID,TicketID,EmployeeID,UserID,TotalSeconds,IsNonDelivery FROM #TotalSessionsNonDelivery 

		--Step 5 Grouping and find sum
		SELECT ProjectID,TicketID,EmployeeID,UserID, SUM(ISNULL(TotalSeconds,0)) AS TotalEffortSeconds,
		MAX(sessionID) AS SessionID ,IsNonDelivery
		INTO #GroupedTickets FROM #FinalSessions 
		GROUP BY ProjectID,TicketID,EmployeeID,UserID,IsNonDelivery


		IF EXISTS( SELECT ProjectID FROM #GroupedTickets)

		BEGIN
				--Step 6 Inserting the session tickets
				INSERT INTO #TimeSheetTickets(TicketID,ProjectID,UserID,EmployeeID,SessionID)
				SELECT TicketID,ProjectID,UserID,EmployeeID,SessionID FROM #GroupedTickets		
				--Step 7 Updating the details
				UPDATE TST  SET tst.IsNonDelivery=ISNULL(ms.IsNonDelivery,0),
				tst.ServiceID=ms.ServiceID,tst.ActivityID=ms.ActivityID,
				tst.UserCreatedTimeDate=ms.UserCreatedTimeDate
				FROM #TimeSheetTickets TST 
				JOIN AVL.TK_Mini_Sessions MS ON tst.SessionID=MS.SessionID

				--Step 8 Logic to filter out only the valid tickets from the session details table
				UPDATE TS SET TS.TimeTickerID= TD.TimeTickerID,TS.ApplicationID=TD.ApplicationID,
				TS.TicketTypeMapID=TD.TicketTypeMapID
				FROM  #TimeSheetTickets TS
				INNER JOIN AVL.TK_TRN_TicketDetail TD
				ON TS.ProjectID=TD.ProjectID AND TS.TicketID=TD.TicketID AND ISNULL(TS.IsNonDelivery,0)=0


				SELECT * FROM #TimeSheetTickets
				DELETE FROM #TimeSheetTickets WHERE IsNonDelivery=0 
				AND (ISNULL(TimeTickerID,0)=0 OR ISNULL(TicketTypeMapID,0)=0)  

				UPDATE MS SET MS.IsProcessed=2 
				FROM AVL.TK_Mini_Sessions MS
				INNER JOIN #TimeSheetTickets TT
				ON MS.SessionID=TT.SessionID WHERE TT.IsNonDelivery=0 
				AND (ISNULL(TT.TimeTickerID,0)=0 OR ISNULL(TT.TicketTypeMapID,0)=0)   

				UPDATE TST  SET TST.TotalEffort= cast(ROUND(ms.TotalEffortSeconds/3600+((((ms.TotalEffortSeconds%3600)/60.00)/60.00)),2)as numeric(8,2))								
				from #TimeSheetTickets TST 
				JOIN #GroupedTickets MS on tst.SessionID=MS.SessionID											
				
				UPDATE td set td.EffortTillDate = tst.TotalEffort,ModifiedDate=GETDATE() FROM AVL.TK_TRN_TicketDetail td 
				JOIN #TimeSheetTickets tst ON tst.TicketID=td.TicketID and tst.ProjectID = td.ProjectID --and tst.IsNonDelivery<>1
				WHERE ISNULL(tst.IsNonDelivery,0)=0

				UPDATE td set td.ServiceID = tst.ServiceID,ModifiedDate=GETDATE() FROM AVL.TK_TRN_TicketDetail td 
				INNER JOIN #TimeSheetTickets tst ON tst.TicketID=td.TicketID and tst.ProjectID = td.ProjectID --and tst.IsNonDelivery<>1
				INNER JOIN AVL.TK_Mini_Sessions MS ON TST.SessionID=MS.SessionID
				WHERE ISNULL(tst.IsNonDelivery,0)=0 AND TD.ModifiedDate < ISNULL(MS.ModifiedOn,MS.CreatedOn)

				UPDATE tst set tst.CustomerID =pm.CustomerID,tst.IsCognizant=C.IsCognizant FROM #TimeSheetTickets tst 
				INNER JOIN AVl.MAS_ProjectMaster pm on tst.ProjectID=pm.ProjectID
				INNER JOIN AVL.Customer C ON PM.CustomerID=C.CustomerID

				update TST  SET tst.NonTicketDescription=ms.NonTicketDescription,
				tst.ActivityID=MS.NonDeliveryActivityType
				FROM #TimeSheetTickets TST 
				JOIN AVL.TK_Mini_Sessions MS on tst.SessionID=MS.SessionID 
				WHERE tst.IsNonDelivery=1

				
				SELECT A.* INTO  #NewTimesheetEntry  FROM
				(
				SELECT CustomerID AS CustomerID,ProjectID AS ProjectID,UserID AS UserID,
				CONVERT(DATE,UserCreatedTimeDate) AS TimesheetDate FROM #TimeSheetTickets
				EXCEPT
				SELECT CustomerID AS CustomerID,ProjectID as ProjectID,SubmitterId AS SubmitterId,
				CONVERT(DATE,TimesheetDate) as TimesheetDate FROM AVL.TM_PRJ_Timesheet(NOLOCK)
				)AS A

				SELECT A.* INTO  #UpdateTimesheetEntry  FROM
				(
				SELECT CustomerID AS CustomerID,ProjectID AS ProjectID,UserID AS UserID,
				CONVERT(DATE,UserCreatedTimeDate) AS TimesheetDate FROM #TimeSheetTickets
				INTERSECT
				SELECT CustomerID AS CustomerID,ProjectID AS ProjectID,SubmitterId as SubmitterId,
				CONVERT(DATE,TimesheetDate) AS TimesheetDate FROM AVL.TM_PRJ_Timesheet(NOLOCK)
				)AS A

				INSERT INTO AVL.TM_PRJ_Timesheet(CustomerID,ProjectID,SubmitterId, TimesheetDate,StatusId,
				CreatedBy,CreatedDateTime)
				SELECT DISTINCT CustomerID,ProjectID,UserID,CAST(TimesheetDate AS DATE),1, 'Mini', GETDATE() 
				from #NewTimesheetEntry	--#TimeSheetTickets

				UPDATE TD SET TD.ModifiedBy='Mini',ModifiedDateTime=GETDATE() 
				FROM  AVL.TM_PRJ_Timesheet TD
				INNER JOIN #UpdateTimesheetEntry TE ON TD.CustomerID=TE.CustomerID AND TD.ProjectID=TE.ProjectID
				AND TD.SubmitterId=TE.UserID AND TD.TimesheetDate=TE.TimesheetDate

				UPDATE tst set tst.TimeSheetID=ts.TimesheetId From AVL.TM_PRJ_Timesheet ts 
				INNER join #TimeSheetTickets tst on ts.ProjectID=tst.ProjectID and ts.SubmitterId=tst.UserID 
				and ts.TimesheetDate=CAST(tst.UserCreatedTimeDate AS DATE)

				UPDATE #TimeSheetTickets SET TicketID='NonDelivery' WHERE IsNonDelivery=1

				--Code Block Tickets to get inserted to TimeSheet Details cognizant
				SELECT B.* INTO #TimeSheetInsertTickets FROM
				(SELECT TimeSheetID,TimeTickerID,IsNonDelivery,ServiceID,ActivityID,ProjectID,0 AS IsDeleted
				from #TimeSheetTickets WHERE IsCognizant=1
				EXCEPT
				select TimesheetId,TimeTickerID,IsNonTicket,ServiceId,ActivityId,ProjectId,IsDeleted
				FROM AVL.TM_TRN_TimesheetDetail(NOLOCK) WHERE ISNULL(IsDeleted,0)=0 AND IsNonTicket=0)AS B

		
				SELECT B.* INTO #TimeSheetUpdateTickets FROM
				(SELECT TimeSheetID,TimeTickerID,IsNonDelivery,ServiceID,ActivityID,ProjectID,0 AS IsDeleted
				from #TimeSheetTickets WHERE IsCognizant=1
					INTERSECT
				SELECT TimesheetId,TimeTickerID,IsNonTicket,ServiceId,ActivityId,ProjectId,IsDeleted
				FROM AVL.TM_TRN_TimesheetDetail(NOLOCK) WHERE ISNULL(IsDeleted,0)=0 AND IsNonTicket=0)as B

				SELECT * FROM #TimeSheetInsertTickets
				SELECT * FROM #TimeSheetTickets
				INSERT INTO AVL.TM_TRN_TimesheetDetail(TimesheetId,TimeTickerID, ApplicationID,TicketID,IsNonTicket,ServiceId,ActivityId,TicketTypeMapID,Hours,ProjectId,IsDeleted,CreatedBy,CreatedDateTime,Remarks)
				SELECT DISTINCT TII.TimeSheetID,TII.TimeTickerID,TS.ApplicationID,TS.TicketID,TII.IsNonDelivery,TII.ServiceID,TII.ActivityID,TicketTypeMapID,
				TS.TotalEffort,TII.ProjectID,0,'Mini',GETDATE(),NULL 
				from #TimeSheetInsertTickets TII
				INNER JOIN #TimeSheetTickets TS ON TII.TimesheetId=TS.TimesheetId AND TII.PROJECTID=TS.PROJECTID
				AND TII.IsNonDelivery=0 AND  IsCognizant=1 AND TII.TimeTickerID=TS.TimeTickerID

				UPDATE TD SET TD.Hours=TD.Hours + TS.TotalEffort,ModifiedBy='Mini',ModifiedDateTime=GETDATE()
				FROM AVL.TM_TRN_TimesheetDetail TD
				INNER JOIN  #TimeSheetUpdateTickets TII ON TD.TimesheetId=TII.TimeSheetID AND TD.TimeTickerID=TII.TimeTickerID
				INNER JOIN #TimeSheetTickets TS ON TII.TimesheetId=TS.TimesheetId AND TII.PROJECTID=TS.PROJECTID
				AND ISNULL(TD.ServiceId,0)=ISNULL(TII.SERVICEID,0) AND ISNULL(TD.ActivityId,0)=ISNULL(TII.ActivityID,0) 
				AND TD.IsNonTicket=0 AND  IsCognizant=1 AND TII.TimeTickerID=TS.TimeTickerID
				--Code Block end for Timesheet Details
			

			

				--Code Block Tickets to get inserted to TimeSheet Details customer
				SELECT B.* INTO #TimeSheetDetailsCustomerInsert FROM
				(SELECT TimeSheetID,TimeTickerID,IsNonDelivery,TicketTypeMapID,ProjectID,0 AS IsDeleted
				from #TimeSheetTickets WHERE IsCognizant=0
				EXCEPT
				select TimesheetId,TimeTickerID,IsNonTicket,TicketTypeMapID,ProjectId,IsDeleted
				FROM AVL.TM_TRN_TimesheetDetail(NOLOCK) WHERE ISNULL(IsDeleted,0)=0 AND IsNonTicket=0)AS B

		
				SELECT B.* INTO #TimeSheetDetailsCustomerUpdate FROM
				(SELECT TimeSheetID,TimeTickerID,IsNonDelivery,TicketTypeMapID,ProjectID,0 AS IsDeleted
				from #TimeSheetTickets WHERE IsCognizant=0
					INTERSECT
				SELECT TimesheetId,TimeTickerID,IsNonTicket,TicketTypeMapID,ProjectId,IsDeleted
				FROM AVL.TM_TRN_TimesheetDetail(NOLOCK) WHERE ISNULL(IsDeleted,0)=0 AND IsNonTicket=0)AS B

				INSERT INTO AVL.TM_TRN_TimesheetDetail(TimesheetId,TimeTickerID, ApplicationID,TicketID,IsNonTicket,TicketTypeMapID,Hours,ProjectId,IsDeleted,CreatedBy,CreatedDateTime,Remarks)
				SELECT DISTINCT TII.TimeSheetID,TII.TimeTickerID,TS.ApplicationID,TS.TicketID,TII.IsNonDelivery,TII.TicketTypeMapID,
				TS.TotalEffort,TII.ProjectID,0,'Mini',GETDATE(),NULL 
				from #TimeSheetDetailsCustomerInsert TII
				INNER JOIN #TimeSheetTickets TS ON TII.TimesheetId=TS.TimesheetId AND TII.PROJECTID=TS.PROJECTID
				AND TII.IsNonDelivery=0 AND  IsCognizant=0 AND TII.TimeTickerID=TS.TimeTickerID

				UPDATE TD SET TD.Hours=TD.Hours + TS.TotalEffort,ModifiedBy='Mini',ModifiedDateTime=GETDATE()
				FROM AVL.TM_TRN_TimesheetDetail TD
				INNER JOIN  #TimeSheetDetailsCustomerUpdate TII ON TD.TimesheetId=TII.TimeSheetID AND TD.TimeTickerID=TII.TimeTickerID
				INNER JOIN #TimeSheetTickets TS ON TII.TimesheetId=TS.TimesheetId AND TII.PROJECTID=TS.PROJECTID
				AND ISNULL(TD.TicketTypeMapID,0)=ISNULL(TII.TicketTypeMapID,0) 
				AND TD.IsNonTicket=0 AND  IsCognizant=0 AND TII.TimeTickerID=TS.TimeTickerID
				--Code Block end for Timesheet Details

			



				--For non Delivery Tickets
				SELECT B.* INTO #TimeSheetNonDeliveryInsertTickets FROM
				(SELECT TimeSheetID,IsNonDelivery,ActivityID,ProjectID,0 AS IsDeleted
				from #TimeSheetTickets WHERE IsNonDelivery=1
				EXCEPT
				select TimesheetId,IsNonTicket,ActivityId,ProjectId,0 AS IsDeleted
				FROM AVL.TM_TRN_TimesheetDetail(NOLOCK) WHERE ISNULL(IsDeleted,0)=0 AND IsNonTicket=1)AS B

				SELECT B.* INTO #TimeSheetNonDeliveryUpdateTickets FROM
				(SELECT TimeSheetID,IsNonDelivery,ActivityID,ProjectID,0 AS IsDeleted
				from #TimeSheetTickets WHERE IsNonDelivery=1
				INTERSECT
				select TimesheetId,IsNonTicket,ActivityId,ProjectId,0 AS IsDeleted
				FROM AVL.TM_TRN_TimesheetDetail(NOLOCK) WHERE ISNULL(IsDeleted,0)=0 AND IsNonTicket=1)AS B

				INSERT INTO AVL.TM_TRN_TimesheetDetail(TimesheetId,TimeTickerID, ApplicationID,TicketID,IsNonTicket,
				ServiceId,ActivityId,TicketTypeMapID,Hours,ProjectId,IsDeleted,CreatedBy,CreatedDateTime,Remarks)
				SELECT DISTINCT TII.TimeSheetID,NULL,NULL,TS.TicketID,TII.IsNonDelivery,NULL,TII.ActivityID,NULL,
				TS.TotalEffort,TII.ProjectID,0,'Mini',GETDATE(),TS.NonTicketDescription 
				from #TimeSheetNonDeliveryInsertTickets TII
				INNER JOIN #TimeSheetTickets TS ON TII.TimesheetId=TS.TimesheetId AND TII.PROJECTID=TS.PROJECTID
				AND TII.IsNonDelivery=1
		

				UPDATE TD SET TD.Hours=TD.Hours + TS.TotalEffort,ModifiedBy='Mini',ModifiedDateTime=GETDATE(),Remarks=TS.NonTicketDescription
				FROM AVL.TM_TRN_TimesheetDetail TD
				INNER JOIN  #TimeSheetNonDeliveryUpdateTickets TII ON TD.TimesheetId=TII.TimeSheetID 
				INNER JOIN #TimeSheetTickets TS ON TII.TimesheetId=TS.TimesheetId AND TII.PROJECTID=TS.PROJECTID
				 AND TD.ActivityId=TII.ActivityID AND TD.IsNonTicket=1 

				UPDATE ms set ms.IsProcessed=1 FROM AVL.TK_Mini_Sessions ms 
				join #TimeSheetTickets ts on ms.SessionID=ts.SessionID

				DROP TABLE #NewTimesheetEntry
				DROP TABLE #UpdateTimesheetEntry
				DROP TABLE #TimeSheetInsertTickets
				DROP TABLE #TimeSheetUpdateTickets
				DROP TABLE #TimeSheetDetailsCustomerInsert
				DROP TABLE #TimeSheetDetailsCustomerUpdate
				DROP TABLE #TimeSheetNonDeliveryInsertTickets
				DROP TABLE #TimeSheetNonDeliveryUpdateTickets
		END


	SET NOCOUNT OFF;   
	COMMIT TRAN   	
END TRY  
	BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SET @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[AVL].[Mini_SaveTimeSheetDetails]', @ErrorMessage, 0,0
		
	END CATCH  
		
END
