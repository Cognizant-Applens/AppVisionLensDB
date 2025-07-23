/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[sp_GetLeadReportees]  --EXEC sp_GetLeadReportees '471741',110
    @EmployeeId VARCHAR(MAX),                   
    @CustomerId INT,
	@StartDate DATE,
	@EndDate	DATE
	AS                       
    BEGIN                               
    SET NOCOUNT ON;
		DECLARE @MinDate DATE = CONVERT(DATE,@StartDate),
		@MaxDate DATE = CONVERT(DATE,@EndDate);
		DECLARE @IsDaily AS BIT = 0;

		SELECT @IsDaily=IsDaily FROM avl.Customer where CustomerID=@CustomerId

		DECLARE @UserIds AS TABLE
		(
			UserId VARCHAR(10)
		)

		DECLARE @DateValue AS TABLE
		(
		DateValue DATE,
		EmployeeId VARCHAR(10),
		EmployeeName VARCHAR(250)
		)

		DECLARE @ReporteeDetails AS TABLE
		(
		EmployeeId VARCHAR(10),
		EmployeeName VARCHAR(250),
		ProjectID INT,
		DateValue DATE,
		TimeSheetDate DATE,
		Hours DECIMAL(5,2),
		MandatoryHours DECIMAL(5,2)
		)

		INSERT INTO @UserIds
		SELECT DISTINCT(EmployeeID) AS EmployeeId
		FROM AVL.MAS_LoginMaster 
		WHERE CustomerID=@CustomerID AND tsapproverid=@EmployeeId


		INSERT INTO @DateValue(DateValue,EmployeeId)
		Select Date,u.UserId from(SELECT  TOP (DATEDIFF(DAY, @MinDate, @MaxDate) + 1)
		Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @MinDate)
		FROM    sys.all_objects a
		CROSS JOIN sys.all_objects b)a
		CROSS JOIN @UserIds u


		UPDATE DV
		SET DV.EmployeeName=LM.EmployeeName
		FROM @DateValue DV INNER JOIN AVL.MAS_LoginMaster LM
		ON DV.EmployeeId=LM.EmployeeID

		INSERT INTO @ReporteeDetails
		(EmployeeId,EmployeeName,ProjectID,DateValue,TimeSheetDate,Hours,MandatoryHours)
		SELECT 
		DISTINCT 
		D.EmployeeId
		,D.EmployeeName
		, LM.ProjectID
		,D.DateValue
		,TS.TimesheetDate
		,SUM(ISNULL(TSD.Hours,0)) AS Hours 
		,ISNULL(LM.MandatoryHours,0) AS MandatoryHours
		FROM AVL.MAS_LoginMaster LM INNER JOIN @DateValue D
		ON D.EmployeeId=LM.EmployeeID AND LM.CustomerID=@CustomerID
		LEFT JOIN AVL.TM_PRJ_Timesheet TS ON TS.TimesheetDate=D.DateValue
		LEFT JOIN AVL.TM_TRN_TimesheetDetail TSD ON TSD.TimesheetId=TS.TimesheetId
		AND TS.ProjectID=LM.ProjectID AND TSD.ProjectId=TS.ProjectID AND TS.SubmitterId=LM.UserID
		GROUP BY D.EmployeeId
		,D.EmployeeName
		, LM.ProjectID
		,D.DateValue
		,TS.TimesheetDate
		,LM.MandatoryHours

		IF @IsDaily = 1 
		BEGIN
			SELECT DISTINCT EmployeeId,EmployeeName,'false' IsDefaulter FROM @ReporteeDetails
			UNION ALL
			SELECT DISTINCT EmployeeId,EmployeeName,'true' IsDefaulter FROM @ReporteeDetails
			WHERE Hours<MandatoryHours
		END
		ELSE 
		BEGIN
			SELECT DISTINCT EmployeeId,EmployeeName,'false' IsDefaulter FROM @ReporteeDetails
			UNION ALL
			SELECT A.EmployeeId,A.EmployeeName,'true' AS IsDefaulter FROM 
			(SELECT DISTINCT EmployeeId,EmployeeName,SUM(Hours) Hours FROM @ReporteeDetails
			GROUP BY EmployeeId,EmployeeName) A
			WHERE A.Hours<40
		END
	END
