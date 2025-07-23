/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--exec [dbo].[Effort_GetDailyEffortHours] 4,20,'DART0001391',0,0,0,'26-03-2018','27-03-2018','28-03-2018','29-03-2018','30-03-2018','31-03-2018','','03-26-2018','03-31-2018'

CREATE Proc [dbo].[Effort_GetDailyEffortHours] --5,26,'RET5656',0,0,0
@ProjectID int=null,
@UserID int=null,
@TicketID nvarchar(100)=null,
@ServiceID INT=NULL,
@CategoryID INT=NULL,
@ActivityID INT=NULL,
@FirstDay varchar(100)=null,
@SecondDay varchar(100)=null,
@ThirdDay varchar(100)=null,
@FourthDay varchar(100)=null,
@FifthDay varchar(100)=null,
@SixthDay varchar(100)=null,
@SeventhDay varchar(100)=null,
@FirstDateOfWeek VARCHAR(100)= NULL,
@LastDateOfWeek VARCHAR(100)= NULL

AS
BEGIN
BEGIN TRY
--DECLARE @i int=0
--select @FirstDateOfWeek+@i
create table #Temp
(
IsSaveOrSubmit int,
DailyHours decimal,
TicketCreateDate varchar(10),
EffortDate datetime,
TimeSheetDetailId int,
TimesheetId int
)
--select @ServiceID
DECLARE @i int=0	
declare @date varchar(10)
IF (@ServiceID !=41 and @ServiceID!=0)
BEGIN
insert into #Temp
select Distinct 
		--TS.TimesheetId as TimesheetID,
		TS.StatusId as IsSaveOrSubmit,
		TSD.Hours as DailyHours,
		CONVERT(varchar(10),TS.TimesheetDate,105) as TicketCreateDate,
		TS.TimesheetDate as EffortDate,
		TSD.TimeSheetDetailId AS TimeSheetDetailId,TSD.TimesheetId AS TimesheetId
		
		from AVL.TM_TRN_TimesheetDetail TSD
		Left join AVL.TK_TRN_TicketDetail TD on TSD.TicketID=TD.TicketID 
		and TSD.ProjectId=TD.ProjectID and TSD.CreatedBy=TD.CreatedBy 
		left join AVL.TM_PRJ_Timesheet TS on TS.TimesheetId=TSD.TimesheetId --and TS.CreatedDateTime=TSD.CreatedDateTime
		where  TSD.ProjectId=@ProjectID and TSD.TicketID=@TicketID
		AND TSD.ServiceId=@ServiceID AND TSD.CategoryId=@CategoryID AND TSD.ActivityId=@ActivityID
		AND TS.TimesheetDate >=@FirstDateOfWeek AND TS.TimesheetDate <=@LastDateOfWeek
		 ORDER by TS.TimesheetDate--TicketCreateDate
		 --select * from #Temp
		 if EXISTS(select * from #Temp where TicketCreateDate= @FirstDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			--(IsSaveOrSubmit,DailyHours,TicketCreateDate,EffortDate,TimeSheetDetailId,TimesheetId)
			insert into #Temp values(0,0,@FirstDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @SecondDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@SecondDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @ThirdDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@ThirdDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @FourthDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@FourthDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @FifthDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@FifthDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @SixthDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@SixthDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @SeventhDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@SeventhDay,null,0,0)
			END

END
ELSE if (@ServiceID = 0)
BEGIN
insert into #Temp
select Distinct
		--TS.TimesheetId as TimesheetID,
		TS.StatusId as IsSaveOrSubmit,
		TSD.Hours as DailyHours,
		CONVERT(varchar(10),TS.TimesheetDate,105) as TicketCreateDate,
		TS.TimesheetDate as EffortDate,
		TSD.TimeSheetDetailId AS TimeSheetDetailId,TSD.TimesheetId AS TimesheetId
		from AVL.TM_TRN_TimesheetDetail TSD
		Left join AVL.TK_TRN_TicketDetail TD on TSD.TicketID=TD.TicketID 
		and TSD.ProjectId=TD.ProjectID and TSD.CreatedBy=TD.CreatedBy 
		left join AVL.TM_PRJ_Timesheet TS on TS.TimesheetId=TSD.TimesheetId --and TS.CreatedDateTime=TSD.CreatedDateTime
		where  TSD.ProjectId=@ProjectID and TSD.TicketID=@TicketID
			AND TS.TimesheetDate >=@FirstDateOfWeek AND TS.TimesheetDate <=@LastDateOfWeek
		--AND TSD.ServiceId=NULL AND TSD.CategoryId=NULL AND TSD.ActivityId=NULL
		 ORDER by TS.TimesheetDate

		 
		 --select @ServiceID
		  if EXISTS(select * from #Temp where TicketCreateDate= @FirstDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@FirstDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @SecondDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@SecondDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @ThirdDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@ThirdDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @FourthDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@FourthDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @FifthDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@FifthDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @SixthDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@SixthDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @SeventhDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@SeventhDay,null,0,0)
			END
	
END
ELSE 
	BEGIN
	insert into #Temp
		select Distinct
		TS.StatusId as IsSaveOrSubmit,
		TSD.Hours as DailyHours,
		CONVERT(varchar(10),TS.TimesheetDate,105) as TicketCreateDate,
		TS.TimesheetDate as EffortDate,
		TSD.TimeSheetDetailId AS TimeSheetDetailId,TSD.TimesheetId AS TimesheetId
		from AVL.TM_TRN_TimesheetDetail TSD
		left join AVL.TM_PRJ_Timesheet TS on TS.TimesheetId=TSD.TimesheetId 
		where  TSD.ProjectId=@ProjectID and TSD.TicketID=@TicketID AND TSD.IsNonTicket=1
		AND TSD.ServiceId=@ServiceID AND TSD.CategoryId=@CategoryID AND TSD.ActivityId=@ActivityID
			AND TS.TimesheetDate >=@FirstDateOfWeek AND TS.TimesheetDate <=@LastDateOfWeek
		 ORDER by TS.TimesheetDate

		
		
		--set @date=@FirstDateOfWeek+@i
		 if EXISTS(select * from #Temp where TicketCreateDate= @FirstDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@FirstDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @SecondDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@SecondDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @ThirdDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@ThirdDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @FourthDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@FourthDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @FifthDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@FifthDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @SixthDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@SixthDay,null,0,0)
			END

			if EXISTS(select * from #Temp where TicketCreateDate= @SeventhDay)
			BEGIN
			print 1
			END
			ELSE
			BEGIN
			--set @date=@FirstDateOfWeek+@i
			insert into #Temp values(0,0,@SeventhDay,null,0,0)
			END
	
	END
	select * from #Temp --ORDER by  coalesce(TicketCreateDate,TicketCreateDate)-- TicketCreateDate DESC
	drop TABLE #Temp
	END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[dbo].[Effort_GetDailyEffortHours] ', @ErrorMessage, @ProjectID,0
	END CATCH  
END
--@FirstDay varchar(100)=null,
--@SecondDay varchar(100)=null,
--@ThirdDay varchar(100)=null,
--@FourthDay varchar(100)=null,
--@FifthDay varchar(100)=null,
--@SixthDay varchar(100)=null,
--@SeventhDay
--select * from AVL.TK_TRN_TicketDetail
--select * from AVL.TM_TRN_TimesheetDetail where TicketID='T2' and ProjectId=5
--select * from AVL.TM_PRJ_Timesheet where ProjectID=5 and SubmitterId=26 


--select TS.StatusId,TSD.TimesheetId
--	from AVL.TM_TRN_TimesheetDetail TSD
--	Left join AVL.TK_TRN_TicketDetail TD on TSD.TicketID=TD.TicketID and TSD.ProjectId=TD.ProjectID and TSD.CreatedBy=TD.CreatedBy
--	left join AVL.TM_PRJ_Timesheet TS on TS.TimesheetId=TSD.TimesheetId
--	where TSD.CreatedBy=3 and TSD.ProjectId=4 and TSD.TicketID='T4'

--	select * from AVL.TM_TRN_TimesheetDetail where TicketID='T4'

--	select * from AVL.TK_TRN_TicketDetail
