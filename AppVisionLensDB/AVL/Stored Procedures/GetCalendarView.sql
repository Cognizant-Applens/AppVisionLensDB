/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetCalendarView]   
	@FromDate DATE=null,  
	@ToDate DATE=null,  
	@SubmitterId VARCHAR(2000)=null,  
	@CustomerId BIGINT=null  
	AS  
	BEGIN  
	BEGIN TRY
SET NOCOUNT ON; 
  
DECLARE @MinDate DATE = CONVERT(DATE,@FromDate),  
        @MaxDate DATE = CONVERT(DATE,@ToDate), 
		@IsCognizant BIT;

SELECT @IsCognizant=ISNULL(IsCognizant,0) 
FROM AVL.Customer WITH (NOLOCK)
WHERE CustomerID = @CustomerId AND IsDeleted = 0
DECLARE @UserIds AS TABLE  
(  
UserId VARCHAR(10),  
EmployeeID  VARCHAR(10)  
)  
  
CREATE TABLE #DateValue  
(  
DateValue DATE,  
	UserId INT,  
EmployeeID varchar(10),  
TimeSheetStatusID INT,  
TimeSheetID BIGINT NULL DEFAULT 0  
)  
CREATE NONCLUSTERED INDEX [DateValueIndex] ON #DateValue
(
	[DateValue] ,
	[UserId] ,
	[TimeSheetID] 
)

DECLARE @TimeSheetDetails AS TABLE  
(  
DayValue varchar(100),  
DateValue DATE,  
EmployeeID VARCHAR(100)  
)  
  
DECLARE @TimeSheetDetailsNotSubmitted AS TABLE  
(  
DayValue varchar(100),  
DateValue DATE,  
EmployeeID VARCHAR(100),
	UserId INT 
)    


DECLARE @Result AS TABLE  
( 
	DayValue VARCHAR(50),  
	DateValue DATE,  
	ResultValue INT,  
	TimesheetStatusID INT,  
	TimesheetStatus VARCHAR(50)  
)  

--INSERT INTO @UserIds    
--select distinct UserID,EmployeeID FROM AVL.MAS_LoginMaster (NOLOCK) lm 
-- JOIN AVL.PRJ_ConfigurationProgress cp ON lm.ProjectID=cp.ProjectID  
--where  lm.IsDeleted=0 AND lm.CustomerID=@CustomerId AND (tsapproverid=@SubmitterId OR ((TSApproverID is null) AND HcmSupervisorID=@SubmitterId))  
--  AND cp.ScreenID='2' and cp.ITSMScreenId='11' and cp.CompletionPercentage='100' 



INSERT INTO @UserIds    
select distinct UserID,EmployeeID 
   FROM AVL.MAS_LoginMaster(NOLOCK)   lm  
 LEFT JOIN AVL.PRJ_ConfigurationProgress(NOLOCK) cp ON lm.ProjectID=cp.ProjectID and cp.IsDeleted = 0
  LEFT JOIN PP.ScopeOfWork(NOLOCK) SW   
  ON SW.ProjectID = LM.ProjectID AND ISNULL(SW.IsDeleted,0) = 0  
  LEFT JOIN PP.ProjectAttributeValues(NOLOCK) PAV  
    ON PAV.ProjectID = LM.ProjectID AND PAV.IsDeleted = 0  
  LEFT JOIN PP.ProjectProfilingTileProgress (NOLOCK) PTP  
    ON PTP.ProjectID = LM.ProjectID AND PTP.IsDeleted = 0  
	 WHERE LM.CustomerID=@CustomerId AND (tsapproverid=@SubmitterId OR ((TSApproverID is null or TSApproverID='NULL' OR TSApproverID='') AND HcmSupervisorID=@SubmitterId)) AND lm.IsDeleted=0    
  AND ((@IsCognizant = 1 AND (cp.ScreenID='2' and cp.ITSMScreenId='11' and cp.CompletionPercentage='100') or( PAV.AttributeValueID IN(1,4)  
 AND PTP.TileID = 5 AND PTP.TileProgressPercentage = 100))
 OR (@IsCognizant = 0 AND cp.ScreenID='2' and cp.ITSMScreenId='10' and cp.CompletionPercentage='100'))


;WITH MYCTE AS
(

	SELECT CAST(@MinDate AS DATETIME) DATEVALUE
	UNION ALL
	SELECT  DATEVALUE + 1
	FROM    MYCTE   
	WHERE   DATEVALUE + 1 <= @MaxDate
)  
INSERT INTO #DateValue(DateValue,UserId,EmployeeID,TimeSheetStatusID)  
Select Date,u.UserId,u.EmployeeID,ts.TimeSheetStatusID from(SELECT DATEVALUE AS Date FROM MYCTE)a  
CROSS JOIN @UserIds u  
CROSS JOIN avl.MAS_TimesheetStatus TS

  
UPDATE DV  
SET DV.TimeSheetID=ts.TimesheetId  
FROM #DateValue DV 
INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) TS  ON 
        CONVERT(INT,TS.SubmitterId)=DV.UserId  
	AND TS.TimesheetDate=DV.DateValue  
	AND TS.CustomerID=@CustomerId  AND EXISTS
(SELECT TD.TimesheetId FROM AVL.TM_TRN_TimesheetDetail(NOLOCK) TD WHERE TD.TimesheetId=TS.TimesheetId AND TD.IsDeleted=0 
UNION ALL
SELECT ITD.TimesheetId FROM AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) ITD WHERE ITD.TimesheetId=TS.TimesheetId AND ITD.IsDeleted=0
UNION ALL
SELECT WS.TimesheetId FROM ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) WS WHERE WS.TimesheetId=TS.TimesheetId AND
ISNULL(WS.IsDeleted,0)=0 )
  
INSERT INTO @TimeSheetDetails  
(DayValue,DateValue,EmployeeID)  
select DISTINCT   
--SUBSTRING(Datename(month,DV.DateValue),0,4)+'-'+Datename(DAY,DV.DateValue) AS DayValue,
FORMAT(DV.DateValue, 'MMM-dd') AS DayValue,  
DV.DateValue AS DateValue,  
DV.EmployeeID  
FROM #DateValue DV   
INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) T ON  DV.DateValue = T.TimesheetDate AND DV.TimeSheetStatusID=T.StatusId  
--INNER JOIN [AVL].TM_TRN_TimesheetDetail TD ON TD.TimesheetId=T.TimesheetId AND TD.IsDeleted=0 
AND DV.UserId=CONVERT(INT, T.SubmitterId) AND  
t.CustomerID=@CustomerId 
--AND isnull(td.IsDeleted,0)=0  
  
  
  
INSERT INTO @TimeSheetDetailsNotSubmitted  
(DayValue,DateValue,EmployeeID,UserId)  
select DISTINCT   
	--SUBSTRING(Datename(month,DV.DateValue),0,4)+'-'+Datename(DAY,DV.DateValue) AS DayValue,
	FORMAT(DV.DateValue, 'MMM-dd') AS DayValue,
DV.DateValue AS DateValue,  
DV.EmployeeID,
DV.UserId     
FROM #DateValue DV   
LEFT JOIN AVL.TM_PRJ_Timesheet(NOLOCK) T ON  DV.DateValue = T.TimesheetDate AND DV.TimeSheetStatusID=T.StatusId  
	AND DV.UserId=CONVERT(INT,T.SubmitterId) AND t.CustomerID=@CustomerId
WHERE T.SubmitterId IS NULL AND DV.TimeSheetID=0  
  
  
-------------------------------------

DELETE A FROM @TimeSheetDetailsNotSubmitted A JOIN AVL.TM_PRJ_Timesheet B
ON A.DateValue=B.TimesheetDate AND A.UserId=B.SubmitterId AND B.StatusId=4

-------------------------------------  
  
DELETE T1  
FROM @TimeSheetDetailsNotSubmitted T1 INNER JOIN @TimeSheetDetails T2   
ON T1.DayValue=T2.DayValue AND t1.EmployeeID=T2.EmployeeID and t1.DateValue=t2.DateValue  
   
INSERT INTO @Result  
(DayValue,DateValue,ResultValue,TimesheetStatusID,TimesheetStatus)  
 SELECT   
 T.DayValue,  
 T.DateValue,  
 T.ResultValue,  
 T.TimesheetStatusID,  
 T.TimesheetStatus  
 FROM   
 (  
	SELECT DISTINCT   
		--SUBSTRING(Datename(month,DV.DateValue),0,4)+'-'+Datename(DAY,DV.DateValue) AS DayValue, 
		FORMAT(DV.DateValue, 'MMM-dd') AS DayValue, 
DV.DateValue AS DateValue,  
Count(DISTINCT LM.EmployeeID) 'ResultValue',  
ISNULL(DV.TimeSheetStatusID,0) AS TimesheetStatusID,  
ISNULL(ts.TimesheetStatus,'') as TimesheetStatus  
	FROM #DateValue(NOLOCK) DV   
	LEFT JOIN AVL.TM_PRJ_Timesheet(NOLOCK) T ON  DV.DateValue = T.TimesheetDate AND DV.TimeSheetStatusID=T.StatusId  
		AND DV.UserId=CONVERT(INT,T.SubmitterId) AND t.CustomerID=@CustomerId
LEFT JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON T.SubmitterId=LM.UserID AND T.ProjectID = LM.ProjectID AND LM.CustomerID=@CustomerId   AND LM.IsDeleted = 0
	--LEFT JOIN [AVL].TM_TRN_TimesheetDetail TD ON  TD.TimesheetId=T.TimesheetId AND TD.IsDeleted = 0 --isnull(TD.IsDeleted,0)=0
	--	AND DV.UserId=CONVERT(INT,T.SubmitterId) AND t.CustomerID=@CustomerId  
LEFT JOIN [AVL].[MAS_TimesheetStatus](NOLOCK) ts on  DV.TimeSheetStatusID=ts.TimesheetStatusId  
GROUP BY   
DV.TimeSheetStatusID,  
DV.DateValue,  
ts.TimesheetStatus  
) T  
ORDER BY T.DateValue;  
  
UPDATE R   
SET R.ResultValue=T.ResultValue  
FROM @Result R INNER JOIN  
(SELECT DateValue,COUNT(DISTINCT EmployeeID) ResultValue FROM @TimeSheetDetailsNotSubmitted GROUP BY DateValue) T  
ON T.DateValue=R.DateValue AND R.TimesheetStatusID=5  
  
IF OBJECT_ID('tempdb..#DateValue', 'U') IS NOT NULL
BEGIN
       DROP TABLE #DateValue
END
  
SELECT DayValue,DateValue,ResultValue,TimesheetStatusID,TimesheetStatus FROM @Result ORDER BY DateValue 
SET NOCOUNT OFF;

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetCalendarView]', @ErrorMessage, 0,0
		
	END CATCH  
	
END
