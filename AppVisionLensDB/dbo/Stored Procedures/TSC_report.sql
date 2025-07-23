/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE  [dbo].[TSC_report] 
	(
	@CustomerId AS INT
	)
AS
BEGIN
 DECLARE @StartDate DATE ='2018-08-01' 
DECLARE  @EndDate DATE  ='2018-08-20'
    
    SET NOCOUNT ON;  
   DECLARE @MinDate DATE = CONVERT(DATE,@StartDate),  
  @MaxDate DATE = CONVERT(DATE,@EndDate);  
  DECLARE @IsDaily AS BIT = 0;  
  DECLARE @MandatoryHours DECIMAL(5,2)=8;  
  
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
  MandatoryHours DECIMAL(5,2),  
  StatusID INT  ,
    CustomerID BIGINT
  )  
  
  INSERT INTO @UserIds  
  SELECT DISTINCT(EmployeeID) AS EmployeeId  
  FROM AVL.MAS_LoginMaster    (NOLOCK)
  WHERE CustomerID=@CustomerID  AND IsDeleted=0  
  
  
  INSERT INTO @DateValue(DateValue,EmployeeId)  
  Select Date,u.UserId from(SELECT  TOP (DATEDIFF(DAY, @MinDate, @MaxDate) + 1)  
  Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @MinDate)  
  FROM    sys.all_objects a  
  CROSS JOIN sys.all_objects b)a  
  CROSS JOIN @UserIds u  
  
  
  UPDATE DV  
  SET DV.EmployeeName=LM.EmployeeName  
  FROM @DateValue DV INNER JOIN AVL.MAS_LoginMaster LM  
  ON DV.EmployeeId=LM.EmployeeID AND LM.IsDeleted=0  
    
  INSERT INTO @ReporteeDetails  
  (EmployeeId,EmployeeName,ProjectID,DateValue,TimeSheetDate,Hours,MandatoryHours,StatusID,CustomerID)  
  SELECT   
  DISTINCT   
  D.EmployeeId  
  ,D.EmployeeName  
  ,0 as ProjectID  
  ,D.DateValue  
  ,D.DateValue  
  ,SUM(ISNULL(TSD.Hours,0)) AS Hours   
  ,ISNULL(@MandatoryHours,0) AS MandatoryHours  
  ,ISNULL(TS.StatusId  ,0)
   ,LM.CustomerID 
  FROM AVL.MAS_LoginMaster LM INNER JOIN @DateValue D  
  ON D.EmployeeId=LM.EmployeeID AND LM.CustomerID=@CustomerID  
  LEFT JOIN AVL.TM_PRJ_Timesheet TS ON TS.TimesheetDate=D.DateValue  AND LM.CustomerID=TS.CustomerID AND TS.CustomerID=@CustomerId AND LM.UserID=TS.SubmitterId 
  LEFT JOIN AVL.TM_TRN_TimesheetDetail TSD ON TSD.TimesheetId=TS.TimesheetId  
  AND TS.ProjectID=LM.ProjectID AND TSD.ProjectId=TS.ProjectID AND TS.SubmitterId=LM.UserID  
  GROUP BY D.EmployeeId  
  ,D.EmployeeName  
  --, LM.ProjectID  
  ,D.DateValue  
  --,TS.TimesheetDate  
  ,TS.StatusId
  ,LM.CustomerID
    

  SELECT * INTO #ReporteeForDefaulterDetails FROM @ReporteeDetails where StatusID=0
   
   
 
  DELETE A
  FROM #ReporteeForDefaulterDetails A INNER JOIN @ReporteeDetails B
  ON B.EmployeeId=B.EmployeeId
  AND B.EmployeeName=B.EmployeeName
  AND B.DateValue=B.DateValue
  AND  B.TimeSheetDate=B.TimeSheetDate
  AND B.StatusID <> 0

  INSERT INTO dbo.TSCReport_ReporteeForDefaulterDetails
  select  EmployeeId as SuperVisorID,*   From #ReporteeForDefaulterDetails
  
  INSERT INTO dbo.TSCReport_AssigneeDetails
   select EmployeeId as SuperVisorID, *  from @ReporteeDetails

  --IF @IsDaily = 1   
  --BEGIN  
  -- SELECT DISTINCT EmployeeId,EmployeeName,'false' IsDefaulter FROM @ReporteeDetails  
  -- UNION ALL  
  -- SELECT DISTINCT EmployeeId,EmployeeName,'true' IsDefaulter FROM @ReporteeDetails  
  -- WHERE StatusID<>0 AND(Hours<MandatoryHours OR StatusID NOT IN (2,3,4))  
  --    UNION ALL  
  -- SELECT DISTINCT EmployeeId,EmployeeName,'true' IsDefaulter FROM #ReporteeForDefaulterDetails  
  -- WHERE Hours<MandatoryHours 
  --END  
  --ELSE   
  --BEGIN  
  -- SELECT DISTINCT EmployeeId,EmployeeName,'false' IsDefaulter FROM @ReporteeDetails  
  -- UNION ALL  
  -- SELECT A.EmployeeId,A.EmployeeName,'true' AS IsDefaulter FROM   
  -- (SELECT DISTINCT EmployeeId,EmployeeName,SUM(Hours) Hours FROM @ReporteeDetails  
  -- WHERE StatusID<>0 and StatusID NOT IN (2,3,4)  
  -- GROUP BY EmployeeId,EmployeeName) A  
  -- WHERE A.Hours<40 
  --    UNION ALL  
  -- SELECT DISTINCT EmployeeId,EmployeeName,'true' IsDefaulter FROM #ReporteeForDefaulterDetails  
  -- WHERE Hours<MandatoryHours  
  --END  
  END
