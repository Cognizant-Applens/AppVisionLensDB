/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[CheckWeeklyConfigValue]
@from date='',
@to date=''

AS
BEGIN

DECLARE @DATE DATEtime
DECLARE @PrevDate DATE
declare @Count int
Declare @DATES date
DECLARE @DAYNumber INT
SET @DAYNumber = (SELECT DATEPART(dw,GETDATE()))


IF(@DAYNumber = 2 OR @DAYNumber =3)
BEGIN
	SET @DATE = (SELECT getdate()-4)
	set @Count=4
END
ELSE IF(@DAYNumber = 4 OR @DAYNumber = 5 OR @DAYNumber = 6)
BEGIN
	SET @DATE = (SELECT getdate()-2)
	set @Count=2
END
ELSE
BEGIN 
	SET @DATE = (SELECT getdate()-2)
	set @Count=2
END



set @DATES=(select cast(@DATE as DATE))
DECLARE @NOWDATE DATE
SET @NOWDATE=DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE))
IF(datename(dw,@NOWDATE)='SUNDAY')
BEGIN
SET @NOWDATE=DATEADD(DAY, -1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE))
END
ELSE IF(datename(dw,@NOWDATE)='SATURDAY')
BEGIN
SET @NOWDATE=DATEADD(DAY, 0 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE))
END
set @NOWDATE=@DATE
SET @PrevDate=DATEADD(DAY, -28 - DATEPART(WEEKDAY, @NOWDATE), CAST(@NOWDATE AS DATE))      --(SELECT @DATE -(30+ @Count))
SET @PrevDate=DATEADD(day,-30, @NOWDATE) 
DECLARE @LastBusinessDay Datetime
SEt @LastBusinessDay = dbo.WorkDay(@NOWDATE,-30)

set @PrevDate=@LastBusinessDay
PRINT @PrevDate 
PRINT @NOWDATE
PRINT datename(dw,@NOWDATE)



declare @mailerReq int
Declare @ConfigVal Varchar(10)
set @mailerReq=(select MailerRequired from AVL.MAP_DefaultMailerConfig)
set @ConfigVal=(select ConfigValue from AVL.MAP_DefaultMailerConfig)
	if(@mailerReq=1)
	BEGIN
	---------------------------------------------To Get the count of Active Users for each Account----------------------
	select DISTINCT LM.EmployeeID,lm.CustomerID into #distinctEmp from AVL.MAS_LoginMaster LM
	join AVL.Customer C on C.CustomerID=LM.CustomerID  where LM.IsDeleted=0 and C.IsDeleted=0 and C.IsDaily=0 and C.Defaultermail=1 and LM.TicketingModuleEnabled=1 



	select  Count(*) as ActiveAssociates,CustomerID into #ActiveUser from #distinctEmp GROUP by CustomerID
	
	
	select distinct C.CustomerID,lm.EmployeeID  into #SubmittedList10 from AVL.Customer C join AVL.MAS_LoginMaster LM on lm.CustomerID=c.CustomerID
	  join AVL.TM_PRJ_Timesheet TS on ts.CustomerID=lm.CustomerID  and ts.SubmitterId=lm.UserID 
	 WHERE ts.StatusId in (2,3) and c.Defaultermail=1 AND lm.TicketingModuleEnabled=1 and lm.IsDeleted=0 and c.IsDeleted=0 
	 and TS.TimesheetDate>=@from AND TS.TimesheetDate<=@to

	 select distinct C.CustomerID,lm.EmployeeID  into #SubmittedList11 from AVL.Customer C join AVL.MAS_LoginMaster LM on lm.CustomerID=c.CustomerID
	  join AVL.TM_PRJ_Timesheet TS on ts.CustomerID=lm.CustomerID  and ts.SubmitterId=lm.UserID 
	 WHERE ts.StatusId not in (2,3) and c.Defaultermail=1 AND lm.TicketingModuleEnabled=1 and lm.IsDeleted=0 and c.IsDeleted=0 


	
	 
	 DECLARE @DefaultersListIds as Table(Id BIGINT IDENTITY,EmployeeID BIGINT,CustomerID BIGINT)
	 
	  DECLARE @mainTable as Table(Id BIGINT IDENTITY,Hours DECIMAL,TSDate VARCHAR(MAX),EmployeeID BIGINT,EmployeeName varchar(MAX),Employee varchar(MAX),Employeemail varchar(MAX),CustomerID BIGINT,CustomerID2 BIGINT,CustomerName VARCHAR(MAX),Customer varchar(MAX))  


	


	   insert into @DefaultersListIds(CustomerID,EmployeeID)(select distinct LM.CustomerID,LM.EmployeeID  FROM AVL.MAS_LoginMaster LM join AVL.Customer C
	 on lm.CustomerID=c.CustomerID  WHERE Lm.EmployeeID  in(select EmployeeID FROM #SubmittedList11 where customerid=Lm.CustomerID)
	 and lm.IsDeleted=0 and lm.TicketingModuleEnabled=1 and c.Defaultermail=1 and c.IsDeleted=0)
	 
	  insert into @DefaultersListIds(CustomerID,EmployeeID)(select distinct LM.CustomerID,LM.EmployeeID  FROM AVL.MAS_LoginMaster LM join AVL.Customer C
	 on lm.CustomerID=c.CustomerID  WHERE Lm.EmployeeID  in(select EmployeeID FROM #SubmittedList10 where customerid=Lm.CustomerID)
	 and lm.IsDeleted=0 and lm.TicketingModuleEnabled=1 and c.Defaultermail=1 and c.IsDeleted=0)

	 insert into @DefaultersListIds(CustomerID,EmployeeID)(select distinct LM.CustomerID,LM.EmployeeID  FROM AVL.MAS_LoginMaster LM join AVL.Customer C
	 on lm.CustomerID=c.CustomerID  WHERE Lm.EmployeeID not in(select EmployeeID FROM #SubmittedList10 where customerid=Lm.CustomerID)
	 and lm.IsDeleted=0 and lm.TicketingModuleEnabled=1 and c.Defaultermail=1 and c.IsDeleted=0 )
	 
	 
	 DECLARE @DefaultersCountCheck as Table(Count BIGINT,CustomerID BIGINT)
	 INSERT into @DefaultersCountCheck(Count,CustomerID)(SELECT DISTINCT 0,customerid from @DefaultersListIds)
	 
	 DECLARE @countcheck int =0;
	 DECLARE @i int = 0
	 DECLARE @customer VARCHAR(MAX)=''
	 DECLARE @presentdate DATETIME
	 PRINT 'bEFORE'
	 SET @presentdate = (SELECT DATEADD(DAY,@i,@PrevDate))
     WHILE @presentdate < @NOWDATE
     BEGIN
           SET @presentdate = (SELECT DATEADD(DAY,@i,@PrevDate))
		   IF(datename(dw,@presentdate)<>'SUNDAY' and datename(dw,@presentdate)<>'SATURDAY')
		   BEGIN
		    DECLARE @j int = 0
			PRINT @presentdate
            WHILE @j < (select count(*) FROM @DefaultersListIds)
            BEGIN
			SET @j = @j + 1
			DECLARE @stcount int=0
			set @stcount =(select COUNT(TimesheetId) from AVL.TM_PRJ_Timesheet TS JOIN AVL.MAS_LoginMaster LM on LM.UserID=ts.SubmitterId and (cast(TS.TimesheetDate as date)= @presentdate)
			where lm.IsDeleted=0 and lm.TicketingModuleEnabled=1 and  lm.EmployeeID=(select employeeid FROM @DefaultersListIds where id=@j) and TS.StatusId not in(2,3))
			if(@stcount>0)
			BEGIN
			set @customer=(select CustomerID FROM @DefaultersListIds where id=@j)
			set @countcheck=(select COUNT FROM @DefaultersCountCheck where CustomerID=@customer)
			UPDATE @DefaultersCountCheck set count=@countcheck+1
			INSERT INTO @mainTable(Hours,TSDate,EmployeeID,EmployeeName,Employee,Employeemail,CustomerID,CustomerID2,CustomerName,Customer)
			(select sum(TSD.Hours) as Hours,CAST(@presentdate as DATE),LM.EmployeeID,LM.EmployeeName,Lm.EmployeeName+'('+LM.EmployeeID+')',LM.EmployeeEmail,C.CustomerID,c.ESA_AccountID,C.CustomerName,C.CustomerName+'('+cast(C.ESA_AccountID as NVARCHAR(MAX))+')'
			  from  AVL.MAS_LoginMaster LM(NOLOCK)
			   JOIN AVL.Customer C(NOLOCK) ON LM.CustomerID=c.CustomerID 
			    Join @DefaultersListIds dl on dl.EmployeeID=lm.EmployeeID and dl.CustomerID=lm.CustomerID AND dl.id=@j
			    JOIN AVL.TM_PRJ_Timesheet TS(NOLOCK) on LM.UserID=ts.SubmitterId  and lm.CustomerID=ts.CustomerID and lm.IsDeleted=0
			    and (cast(TS.TimesheetDate as date)=@presentdate)
				join AVL.TM_TRN_TimesheetDetail TSD ON TSD.TimesheetId=ts.TimesheetId
				GROUP BY LM.EmployeeID,LM.EmployeeName,LM.EmployeeEmail,C.CustomerID,c.ESA_AccountID,C.CustomerName)  
				
				
			END
			DECLARE @stcount2 int=0
			set @stcount2 =(select COUNT(TimesheetId) from AVL.TM_PRJ_Timesheet TS JOIN AVL.MAS_LoginMaster LM on LM.UserID=ts.SubmitterId and (cast(TS.TimesheetDate as date)= @presentdate)
			where lm.IsDeleted=0 and lm.TicketingModuleEnabled=1 and  lm.EmployeeID=(select employeeid FROM @DefaultersListIds where id=@j) and TS.StatusId  in(2,3))
			if(@stcount2=0)
			BEGIN
			if(@stcount=0)
			BEGIN
			DECLARE @effectivedate DATETIME
			
			set @effectivedate=(SELECT top 1 cast(CreatedDate as DATE) from AVL.MAS_LoginMaster WHERE EmployeeID=(select EmployeeID FROM @DefaultersListIds where id=@j) and CustomerID=(select CustomerID FROM @DefaultersListIds where id=@j) and IsDeleted=0 ORDER by CreatedDate ASC)
			
			if(@effectivedate<=@presentdate)
			BEGIN
			set @customer=(select CustomerID FROM @DefaultersListIds where id=@j)
			set @countcheck=(select COUNT FROM @DefaultersCountCheck where CustomerID=@customer)
			UPDATE @DefaultersCountCheck set count=@countcheck+1
			INSERT INTO @mainTable(Hours,TSDate,EmployeeID,EmployeeName,Employee,Employeemail,CustomerID,CustomerID2,CustomerName,Customer)
			(select 0 as Hours,@presentdate,LM.EmployeeID,LM.EmployeeName,Lm.EmployeeName+'('+LM.EmployeeID+')',LM.EmployeeEmail,C.CustomerID,c.ESA_AccountID,C.CustomerName,C.CustomerName+'('+cast(C.ESA_AccountID as NVARCHAR(MAX))+')'
			  from  AVL.MAS_LoginMaster LM(NOLOCK)
			   JOIN AVL.Customer C(NOLOCK) ON LM.CustomerID=c.CustomerID 
			   Join @DefaultersListIds dl on dl.EmployeeID=lm.EmployeeID and dl.CustomerID=lm.CustomerID
			   left JOIN AVL.TM_PRJ_Timesheet TS(NOLOCK) on LM.UserID=ts.SubmitterId  and lm.CustomerID=ts.CustomerID and lm.IsDeleted=0
			   where dl.id=@j)
	        END
			END
	        END
			END
			END

		    SET @i = @i + 1
     END
	 
	
	 DROP  table #SubmittedList11
	 delete  ConfigValueWeekly
	 
	 insert into ConfigValueWeekly(configvalue,customerid)(select ((dc.Count)*100)/(AU.ActiveAssociates*31) as ConfigValue,AU.CustomerID  from @DefaultersListIds DU
			join #ActiveUser AU on AU.CustomerID=DU.CustomerID 
			JOIN @DefaultersCountCheck dc on DU.CustomerID=dc.CustomerID
			GROUP by AU.CustomerID,AU.ActiveAssociates,dc.Count)

   
			Drop table #ActiveUser
			PRINT 'aFTER'
			PRINT @presentdate
	END
END
