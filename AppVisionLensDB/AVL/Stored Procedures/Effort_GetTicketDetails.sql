/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[AVL].[Effort_GetTicketDetails] '593611','03/19/2018','03/26/2018','03/2018'

--[AVL].[Effort_GetTicketDetails] '627119','03/12/2018','03/18/2018','03/2018'
--[AVL].[Effort_GetTicketDetailsNewFeb22] '659977','03/01/2018','03/02/2018'
CREATE Procedure [AVL].[Effort_GetTicketDetails] --627119-- '471742','02-08-2018','02-09-2018'
@EmployeeID NVARCHAR(1000)=null ,
@FirstDateOfWeek varchar(30)=null,
@LastDateOfWeek varchar(30)=null,
@monthPicker VARCHAR(100) =NULL
as
begin
BEGIN TRY

Declare @FirstDate varchar(100);
Declare @FirstDate1 datetime;
--set @FirstDate=(select convert(VARCHAR, @FirstDateOfWeek, 111))
--set @FirstDate1=CONVERT(DATETIME,@FirstDateOfWeek)
--print @FirstDate
--PRINT @FirstDate1
--set @FirstDate=convert(VARCHAR, @FirstDateOfWeek, 101)
set @FirstDate1=CONVERT(DATETIME,@FirstDateOfWeek,120)
PRINT @FirstDateOfWeek
--PRINT @FirstDate1

Declare @LastDate VARCHAR(100);
Declare @LastDate1 datetime;
set @LastDate= convert(VARCHAR, @LastDateOfWeek, 120)
set @LastDate1=CONVERT(DATETIME,@LastDate)
PRINT @FirstDate1
print @LastDate1


Select DISTINCT IsCognizant,IsEffortConfigured,IsCategoryConfigured into #Temp from AVL.Customer where CustomerID in 
				  (select TOP 1 LM.CustomerID from AVL.MAS_LoginMaster LM where EmployeeID=@EmployeeID and LM.IsDeleted=0)

select * from #Temp

declare @IsCognizant int 
declare @IsEffortConfigured int 
declare @IsCategoryConfigured int 

Set @IsCognizant= (select IsCognizant from #Temp)

set @IsEffortConfigured=(select IsEffortConfigured from #Temp)

set @IsCategoryConfigured=(select IsCategoryConfigured from #Temp)

		CREATE TABLE #TimeSheetTickets
		(
		TicketID NVARCHAR(1000) NULL,
		ProjectID BIGINT NULL
		)
	  		INSERT INTO #TimeSheetTickets
			select  Distinct
			TD.TicketID,
			TD.ProjectID as ProjectID
			from AVL.TK_TRN_TicketDetail TD
			left join  AVL.TM_TRN_TimesheetDetail TSD  on TD.TicketID=TSD.TicketID
			left join AVL.TM_PRJ_Timesheet TS on TSD.TimesheetId=TS.TimesheetId
			left join AVL.TK_MAS_Service MASS on TD.ServiceID=MASS.ServiceID
			left join [AVL].[TK_MAS_DARTTicketStatus] DTS on TD.TicketStatusMapID=DTS.DARTStatusID
			left join AVL.MAS_ProjectMaster PM on TD.ProjectID= PM.ProjectID 
			where TD.AssignedTo in (select distinct 
				ISNULL(LM.UserID,0) as UserID
				from AVL.MAS_LoginMaster LM
				INNER JOIN AVL.MAS_ProjectMaster PM1 ON LM.ProjectID=PM1.ProjectID
				where LM.EmployeeID=@EmployeeID
				AND LM.ProjectID = TD.ProjectID
				and LM.IsDeleted=0 and PM1.IsDeleted=0
			)  and TS.TimesheetDate BETWEEN @FirstDate1 and @LastDate1 and PM.IsDeleted=0
			--AND TSD.ServiceId != 0


	  if(@IsCognizant=1)
	  BEGIN	
	  print 'cog'
			select  Distinct
			TD.AssignedTo as UserID,
			TD.ProjectID as ProjectID,
			TD.ApplicationID as ApplicationID,
			TD.TicketID,TD.TicketDescription as TicketDescription,
			TSD.ServiceId as ServiceID,
			MASS.ServiceName as ServiceName,
			TSD.CategoryId as CategoryId,
			TSD.ActivityId as ActivityId,
			TD.TicketStatusMapID as StatusID,
			TD.TicketTypeMapID AS TicketTypeMapID,
			DTS.DARTStatusName as StatusName,
			TD.EffortTillDate as EffortTillDate,
			TD.ActualEffort as ITSMEffort,
			ISNULL(PM.IsMainSpringConfigured,'N') as IsMainSpringConfig,
			PM.IsDebtEnabled as IsDebtEnabled
			,TD.IsAttributeUpdated
			from AVL.TK_TRN_TicketDetail TD
			left join  AVL.TM_TRN_TimesheetDetail TSD  on TD.TicketID=TSD.TicketID
			left join AVL.TM_PRJ_Timesheet TS on TSD.TimesheetId=TS.TimesheetId
			left join AVL.TK_MAS_Service MASS on TD.ServiceID=MASS.ServiceID
			left join [AVL].[TK_MAS_DARTTicketStatus] DTS on TD.TicketStatusMapID=DTS.DARTStatusID
			left join AVL.MAS_ProjectMaster PM on TD.ProjectID= PM.ProjectID 
			where TD.AssignedTo in (select distinct 
				ISNULL(LM.UserID,0) as UserID
				from AVL.MAS_LoginMaster LM
				INNER JOIN AVL.MAS_ProjectMaster PM1 ON LM.ProjectID=PM1.ProjectID
				where LM.EmployeeID=@EmployeeID
				AND LM.ProjectID = TD.ProjectID
				and LM.IsDeleted=0 and PM1.IsDeleted=0
			)  and TS.TimesheetDate BETWEEN @FirstDate1 and @LastDate1 and  PM.IsDeleted=0
			AND TSD.ServiceId != 0 and PM.IsDeleted=0
			
			UNION
			select  Distinct
			TD.AssignedTo as UserID,
			TD.ProjectID as ProjectID,
			TD.ApplicationID as ApplicationID,
			TD.TicketID,TD.TicketDescription as TicketDescription,
			TD.ServiceId as ServiceID,
			MASS.ServiceName as ServiceName,
			0 as CategoryId,
			0 as ActivityId,
			TD.TicketStatusMapID as StatusID,
			TD.TicketTypeMapID AS TicketTypeMapID,
			DTS.DARTStatusName as StatusName,
			TD.EffortTillDate as EffortTillDate,
			TD.ActualEffort as ITSMEffort,
			ISNULL(PM.IsMainSpringConfigured,'N') as IsMainSpringConfig,
			PM.IsDebtEnabled as IsDebtEnabled
			,TD.IsAttributeUpdated
			from AVL.TK_TRN_TicketDetail TD
			left join AVL.TK_MAS_Service MASS on TD.ServiceID=MASS.ServiceID
			left join [AVL].[TK_MAS_DARTTicketStatus] DTS on TD.TicketStatusMapID=DTS.DARTStatusID
			left join AVL.MAS_ProjectMaster PM on TD.ProjectID= PM.ProjectID 
			where TD.AssignedTo in (select distinct 
				ISNULL(LM.UserID,0) as UserID
				from AVL.MAS_LoginMaster LM
				INNER JOIN AVL.MAS_ProjectMaster PM1 ON LM.ProjectID=PM1.ProjectID
				where LM.EmployeeID=@EmployeeID
				AND LM.ProjectID = TD.ProjectID
				and LM.IsDeleted=0 and PM1.IsDeleted=0
			)  and TD.OpenDateTime BETWEEN @FirstDate1 and @LastDate1 and PM.IsDeleted=0
			AND ISNULL(TD.DARTStatusID,0) <> 8 AND TD.TicketID NOT IN
			(SELECT DISTINCT TicketID FROM #TimeSheetTickets)

			UNION
			SELECT LM.UserID AS UserID,TD.ProjectId AS ProjectID,TD.ApplicationID AS ApplicationID,
			TD.TicketID AS TicketID,NULL AS TicketDescription,
			TD.ServiceId AS ServiceID,''AS ServiceName,TD.CategoryId AS CategoryId,
			TD.ActivityId AS ActivityId,0 AS StatusID,0 AS TicketTypeMapID,''AS StatusName,
			0 AS EffortTillDate,0 AS ITSMEffort,'N' AS IsMainSpringConfig,'N' AS IsDebtEnabled,
			1 AS IsAttributeUpdated
			
			--SELECT *
			 FROM  AVL.TM_TRN_TimesheetDetail TD
			INNER JOIN  AVL.TM_PRJ_Timesheet TS
			ON TD.TimesheetId=TS.TimesheetId AND TD.IsNonTicket=1
			INNER JOIN AVL.MAS_LoginMaster LM ON LM.UserID=TS.SubmitterId
			WHERE TS.TimesheetDate BETWEEN @FirstDate1 and @LastDate1 AND LM.EmployeeID=@EmployeeID
			AND TD.ServiceId != 0 AND TD.CategoryId !=0 AND TD.ActivityId !=0

	  END
	  else
	  BEGIN
			if(@IsEffortConfigured=1)
	        BEGIN
			print 'cust eff'
				select  Distinct	
				TD.AssignedTo as UserID,
				TD.ProjectID as ProjectID,
				TD.ApplicationID as ApplicationID,
				TD.TicketID,TD.TicketDescription as TicketDescription,	
				TD.TicketStatusMapID as StatusID,
				TD.TicketTypeMapID AS TicketTypeMapID,
				DTS.DARTStatusName as StatusName,
				TD.EffortTillDate as EffortTillDate,
				TD.ActualEffort as ITSMEffort,
				ISNULL(PM.IsMainSpringConfigured,'N') as IsMainSpringConfig,
				PM.IsDebtEnabled as IsDebtEnabled,
				TD.IsAttributeUpdated
				from  AVL.TK_TRN_TicketDetail TD
				INNER join AVL.MAS_ProjectMaster PM on TD.ProjectID= PM.ProjectID  
				INNER JOIN AVL.MAS_LoginMaster LM ON TD.AssignedTo=LM.UserID
				left join AVL.TM_TRN_TimesheetDetail TSD on TD.TicketID=TSD.TicketID
				left join AVL.TM_PRJ_Timesheet TS on TSD.TimesheetId=TS.TimesheetId
				left join [AVL].[TK_MAS_DARTTicketStatus] DTS on TD.DARTStatusID=DTS.DARTStatusID
				where TD.AssignedTo in (select distinct 
				ISNULL(LM.UserID,0) as UserID
				from AVL.MAS_LoginMaster LM
				INNER JOIN AVL.MAS_ProjectMaster PM1 ON LM.ProjectID=PM1.ProjectID
				where LM.EmployeeID=@EmployeeID
				and LM.IsDeleted=0 and PM1.IsDeleted=0
				AND LM.ProjectID = TD.ProjectID
				)  and TS.TimesheetDate BETWEEN @FirstDateOfWeek and @LastDateOfWeek and  PM.IsDeleted=0
			UNION

			select  Distinct
			TD.AssignedTo as UserID,
			TD.ProjectID as ProjectID,
			TD.ApplicationID as ApplicationID,
			TD.TicketID,TD.TicketDescription as TicketDescription,
			TD.TicketStatusMapID as StatusID,
				TD.TicketTypeMapID AS TicketTypeMapID,
				DTS.DARTStatusName as StatusName,
				TD.EffortTillDate as EffortTillDate,
				TD.ActualEffort as ITSMEffort,
				ISNULL(PM.IsMainSpringConfigured,'N') as IsMainSpringConfig,
				PM.IsDebtEnabled as IsDebtEnabled,
				TD.IsAttributeUpdated
			from AVL.TK_TRN_TicketDetail TD
			INNER join [AVL].[TK_MAS_DARTTicketStatus] DTS on TD.DARTStatusID=DTS.DARTStatusID
			INNER join AVL.MAS_ProjectMaster PM on TD.ProjectID= PM.ProjectID 
			INNER JOIN AVL.MAS_LoginMaster LM ON PM.ProjectID=LM.ProjectID AND TD.AssignedTo=LM.UserID
			WHERE LM.EmployeeID=@EmployeeID and LM.ISDeleted=0 AND TD.OpenDateTime < @LastDateOfWeek and  PM.IsDeleted=0
			AND (ISNULL(TD.DARTStatusID,0) <> 8 or (TD.DARTStatusID=8 and TD.closeddate is null))
			AND TD.TicketID NOT IN
			(SELECT DISTINCT TicketID FROM #TimeSheetTickets)



	       
		   --SELECT * FROM AVL.MAS_ProjectMaster 
		    END
			ELSE
			BEGIN
			PRINT 'cust non eff'
						DECLARE @Month VARCHAR(10);
			DECLARE @Year VARCHAR(10);
			SET @Month=LEFT(@monthPicker, 2)
			SET @Year=RIGHT(@monthPicker, 4)
			DECLARE @FirstDayOfMonth varchar(20)
			DECLARE @LastDayOfMonth varchar(20)
			DECLARE @FirstDayOfMonth1 Datetime
			DECLARE @LastDayOfMonth1 DATETIME

			DECLARE @m1 varchar(20)
			DECLARE @m2 varchar(20)
			DECLARE @one varchar(10)
			set @FirstDayOfMonth=@year+'-'+@month+'-01'--+@one
			--set @FirstDayOfMonth1=(SELECT CAST(@FirstDayOfMonth as DATE))
			--select @FirstDayOfMonth
			--print @m1
			 --select CONVERT(VARCHAR,@m1,101)
		SET @m2= DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@FirstDayOfMonth)+1,0))
		SET @LastDayOfMonth1 =convert(VARCHAR,@m2,101)
		SET @LastDayOfMonth=(SELECT CAST(@LastDayOfMonth1 as DATE))
		 print 3
				select  Distinct
				--TD.OpenDateTime,
				--TD.DARTStatusID,	
				TD.AssignedTo as UserID,
				TD.ProjectID as ProjectID,
				TD.ApplicationID as ApplicationID,
				TD.TicketID,TD.TicketDescription as TicketDescription,	
				TD.TicketStatusMapID as StatusID,
				TD.TicketTypeMapID AS TicketTypeMapID,
				DTS.DARTStatusName as StatusName,
				TD.ActualEffort as ITSMEffort,
				ISNULL(PM.IsMainSpringConfigured,'N') as IsMainSpringConfig,
				PM.IsDebtEnabled as IsDebtEnabled,
				TD.IsAttributeUpdated
			--	from AVL.TK_TRN_TicketDetail TD
			--INNER join [AVL].[TK_MAS_DARTTicketStatus] DTS on TD.DARTStatusID=DTS.DARTStatusID
			--INNER join AVL.MAS_ProjectMaster PM on TD.ProjectID= PM.ProjectID 
			--INNER JOIN AVL.MAS_LoginMaster LM ON PM.ProjectID=LM.ProjectID AND TD.AssignedTo=LM.UserID
			--WHERE LM.EmployeeID=@EmployeeID and LM.ISDeleted=0 AND TD.OpenDateTime < @LastDayOfMonth and  PM.IsDeleted=0
			--AND ISNULL(TD.DARTStatusID,0) <> 8 
				from AVL.TK_TRN_TicketDetail TD
				left join [AVL].[TK_MAS_DARTTicketStatus] DTS on TD.DARTStatusID=DTS.DARTStatusID
				--left join [AVL].[TK_MAS_DARTTicketStatus] DTS on TD.TicketStatusMapID=DTS.DARTStatusID
				left join AVL.MAS_ProjectMaster PM on TD.ProjectID= PM.ProjectID and PM.IsDeleted=0
				where TD.AssignedTo in (select distinct 
				ISNULL(LM.UserID,0) as UserID
				from AVL.MAS_LoginMaster LM
				LEFT JOIN AVL.Customer Cust on LM.CustomerID=Cust.CustomerID
				LEFT JOIN AVL.MAS_TimeZoneMaster TZM on LM.TimeZoneId=TZM.TimeZoneID
				where LM.EmployeeID=@EmployeeID
				and LM.IsDeleted=0 AND TD.IsDeleted=0
				AND LM.ProjectID = TD.ProjectID --AND TD.OpenDateTime >= @FirstDayOfMonth
				) AND TD.OpenDateTime <= @LastDayOfMonth AND ISNULL(TD.DARTStatusID,0) <> 8 
				PRINT @LastDayOfMonth
				print @FirstDayOfMonth
			END
	  END
	  END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Effort_GetTicketDetails]', @ErrorMessage, @EmployeeID,0
		
	END CATCH  
end

--select * from AVL.TK_TRN_TicketDetail
--select * from AVL.TM_PRJ_Timesheet
--select * from AVL.TM_TRN_TimesheetDetail

--SELECT DATEFROMPARTS(YEAR('02/2017'),MONTH('02/2017'),1)




--select distinct 
--				ISNULL(LM.UserID,0) as UserID
--				from AVL.MAS_LoginMaster LM
--				LEFT JOIN AVL.Customer Cust on LM.CustomerID=Cust.CustomerID
--				LEFT JOIN AVL.MAS_TimeZoneMaster TZM on LM.TimeZoneId=TZM.TimeZoneID
--				where LM.EmployeeID='471742'
--				and LM.IsDeleted=0 AND TD.IsDeleted=0
--				AND LM.ProjectID =
