/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		Sreeya
-- Create date: 1-8-2019
-- Description:	Gets the tasks for initial and continuous learning.
-- =============================================
--EXEC [AVL].[MLCLMyTaskPatterns] '456789'
CREATE PROCEDURE [AVL].[MLCLMyTaskPatterns]
@UserID varchar(50)
AS

BEGIN
BEGIN TRY
		


declare @taskname varchar(500),@taskurl varchar(max),@taskapplication varchar(500),
@taskstatus varchar(100),@tasktype as varchar(100),@taskstatusDD varchar(100);
declare @taskid int=9;
select @taskname=taskname from dbo.taskmaster where taskid=@taskid;
select @taskurl=taskurl from dbo.taskurl where taskid=@taskid;
select @taskapplication=applicationname from dbo.taskapplication where taskid=@taskid;
select @taskstatus=status from dbo.taskstatus where taskstatusid=2;
select @taskstatusDD=status from dbo.taskstatus where taskstatusid=1;
select @tasktype=tasktype from dbo.tasktype where tasktypeid=2;
declare @taskidCL int=11;
declare @tasknameCL varchar(500),@taskurlCL varchar(max),@taskapplicationCL varchar(500);
select @tasknameCL=taskname from dbo.taskmaster where taskid=@taskidCL;
select @taskurlCL=taskurl from dbo.taskurl where taskid=@taskidCL;
select @taskapplicationCL=applicationname from dbo.taskapplication where taskid=@taskidCL;
declare @taskidDD int=12;
declare @tasknameDD varchar(500),@taskurlDD varchar(max),@taskapplicationDD varchar(500);
select @tasknameDD=taskname from dbo.taskmaster where taskid=@taskidDD;
select @taskurlDD=taskurl from dbo.taskurl where taskid=@taskidDD;
select @taskapplicationDD=applicationname from dbo.taskapplication where taskid=@taskidDD;
declare @taskidAH int=15;
declare @tasknameAH varchar(500),@taskurlAH varchar(max),@taskapplicationAH varchar(500);
select @tasknameAH=taskname from dbo.taskmaster where taskid=@taskidAH;
select @taskurlAH=taskurl from dbo.taskurl where taskid=@taskidAH;
select @taskapplicationAH=applicationname from dbo.taskapplication where taskid=@taskidAH;


 SELECT DISTINCT PD.ProjectID ,LM.TSApproverID,PM.CustomerID,PM.EsaProjectID,PM.ProjectName,PD.IsDDAutoClassified,
 IsAutoClassified,IsMLSignOff,ISCLSIGNOFF,LM.EmployeeID INTO #TotalMasterValues
 FROM avl.MAS_ProjectDebtDetails PD WITH (NOLOCK) JOIN  AVL.MAS_LoginMaster LM WITH (NOLOCK)
 ON LM.ProjectID=PD.ProjectID JOIN AVL.MAS_ProjectMaster PM ON PM.ProjectID=LM.ProjectID
  WHERE PD.IsDeleted=0 AND LM.TSApproverID IS NOT NULL AND LM.TSApproverID <>'' AND PM.IsDeleted=0 AND
 LM.IsDeleted=0;

select DISTINCT M.ProjectID ,M.TSApproverID,M.CustomerID,M.EsaProjectID,M.ProjectName,M.IsDDAutoClassified,
 M.IsAutoClassified,M.IsMLSignOff,M.ISCLSIGNOFF INTO #MasterValues
  FROM #TotalMasterValues M JOIN #TotalMasterValues T ON M.projectID=T.ProjectID AND M.TSApproverID=T.EmployeeID;


DECLARE @DDDueDate DATE;
SELECT @DDDueDate=CAST([dbo].[WorkDay](GETDATE(),7) AS DATE);

WITH 
CTEMLValues AS
(
SELECT DISTINCT pv.ProjectID,CAST(pv.CreatedDate AS DATE) AS'CreatedDate',M.TSApproverID,M.CustomerID,M.EsaProjectID,M.ProjectName 
FROM avl.ML_TRN_MLPatternValidation pv WITH (NOLOCK) JOIN #MasterValues 
M ON M.ProjectID=pv.ProjectID WHERE M.IsAutoClassified='Y' AND (M.IsMLSignOff=0 OR M.IsMLSignOff IS NULL) AND
 DATEDIFF(day, CAST([dbo].[WorkDay](CAST(pv.CreatedDate AS DATE),8) AS DATE), CAST(GETDATE() AS Date)) >=0 AND PV.IsDeleted=0
),
--CTECLValues AS
--(
--SELECT DISTINCT pv.ProjectID,CAST(pv.CreatedDate AS DATE) AS 'CreatedDate',M.TSApproverID,M.CustomerID,M.EsaProjectID,M.ProjectName 
--FROM avl.ML_TRN_MLPatternValidation_CL pv WITH (NOLOCK) JOIN #MasterValues 
--M ON M.ProjectID=pv.ProjectID WHERE M.IsAutoClassified='Y' AND M.IsMLSignOff=1 AND (M.ISCLSIGNOFF=0 OR M.ISCLSIGNOFF IS NULL) AND
-- DATEDIFF(day, CAST([dbo].[WorkDay](CAST(pv.CreatedDate AS DATE),8) AS DATE), CAST(GETDATE() AS Date)) >=0 AND PV.IsDeleted=0
--),
CTEDDValues AS
(

SELECT DISTINCT DP.ProjectID,DP.TSApproverID,DP.CustomerID,DP.EsaProjectID,DP.ProjectName  FROM #MasterValues DP 
LEFT JOIN AVL.Debt_MAS_ProjectDataDictionary MS ON MS.ProjectID=DP.ProjectID AND MS.IsDeleted=0 WHERE
DP.IsDDAutoClassified='Y' AND DP.TSApproverID IS NOT NULL AND MS.ProjectID IS NULL
),
CTEAHOp AS(

SELECT DISTINCT AccessLevelID  AS 'ProjectID',UR.EmployeeID,PM.EsaProjectID,PM.ProjectName FROM AVL.UserRoleMapping UR WITH (NOLOCK)
JOIN AVL.MAS_ProjectMaster PM WITH (NOLOCK) ON PM.ProjectID=UR.AccessLevelID 
WHERE UR.RoleID=3 AND AccessLevelSourceID=4 AND IsActive=1 AND PM.IsDeleted=0 AND NOT EXISTS(SELECT DISTINCT URM.EmployeeID FROM AVL.UserRoleMapping URM WHERE 
URM.RoleID<>3 AND URM.IsActive=1 AND URM.EmployeeID=UR.EmployeeID AND URM.AccessLevelID=PM.ProjectID)

),
CTEAHPrj7 AS
(

SELECT DISTINCT dy.ProjectID ,MIN(CAST(ht.CreatedDate AS DATE)) AS 'CreatedDate'
 FROM avl.DEBT_TRN_HealTicketDetails ht WITH (NOLOCK)
JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic dy WITH (NOLOCK) on ht.ProjectPatternMapID=dy.ProjectPatternMapID
WHERE ht.IsDeleted=0 and dy.IsDeleted=0 and (ht.Assignee IS NULL OR ht.Assignee=0) AND ht.TicketType<>'K' AND
 DATEDIFF(day, CAST([dbo].[WorkDay](CAST(ht.CreatedDate AS DATE),8) AS DATE), CAST(GETDATE() AS Date)) >=0  
 AND dy.PatternStatus=1 AND ISNULL(ht.ManualNonDebt,0) != 1 AND ISNULL(dy.ManualNonDebt,0) != 1  GROUP BY dy.ProjectID
 ),
 CTEAHAll AS
 (
 SELECT P.ProjectID,P.CreatedDate,UR.EmployeeID,UR.EsaProjectID,UR.ProjectName
  FROM CTEAHPrj7 P JOIN CTEAHOp UR ON UR.ProjectID=P.ProjectID
 ),
CTEAHPrj14 AS
(
SELECT DISTINCT dy.ProjectID ,MIN(CAST(ht.CreatedDate AS DATE)) AS 'CreatedDate'
 FROM avl.DEBT_TRN_HealTicketDetails ht WITH (NOLOCK)
join avl.DEBT_PRJ_HealProjectPatternMappingDynamic dy WITH (NOLOCK) on ht.ProjectPatternMapID=dy.ProjectPatternMapID
WHERE ht.IsDeleted=0 and dy.IsDeleted=0 and (ht.Assignee IS NULL OR ht.Assignee=0) AND dy.PatternStatus=1 AND ht.TicketType<>'K' AND
 DATEDIFF(day, CAST([dbo].[WorkDay](CAST(ht.CreatedDate AS DATE),14) AS DATE), CAST(GETDATE() AS Date)) >=0 AND ISNULL(ht.ManualNonDebt,0) != 1 AND ISNULL(dy.ManualNonDebt,0) != 1 GROUP BY dy.ProjectID
),
CTEAHSDM AS(

SELECT PM.ProjectID,CP.Project_ID AS 'EsaProjectID',PM.ProjectName,CP.Project_Owner AS 'EmployeeID',CTE.CreatedDate from 
CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Project CP WITH (NOLOCK) JOIN 
AVL.MAS_ProjectMaster PM WITH (NOLOCK) ON PM.EsaProjectID=CP.Project_ID JOIN CTEAHPrj14 CTE 
ON CTE.ProjectID=PM.ProjectID WHERE PM.IsDeleted=0 AND CP.Project_Owner IS NOT NULL 
)

SELECT ML.TSApproverID as'UserID',@taskid as 'TaskID',@taskname as 'TaskName',@taskurl as 'URL',
'Initial Learning Pattern are not signed off since '+convert(varchar(1000),CAST(ML.CreatedDate AS DATE),101)+'  for the Project : '+ML.EsaProjectID +'-'+ LTRIM(RTRIM(ML.ProjectName))
as 'TaskDetails',@taskapplication as 'Application',@taskstatus as 'Status',
getdate() as 'RefreshedTime','system' as 'CreatedBy', getdate() as 'CreatedTime',null as 'ModifiedBy',null as 'ModifiedTime',
@tasktype as 'TaskType',null as 'ExpiryDate','N' as 'Read',CAST([dbo].[WorkDay](ML.CreatedDate,7) AS DATE) as 'DueDate',0 as 'ExpiryAfterRead',
ProjectID as 'AccountID',1 AS 'JobTypeID'
FROM CTEMLValues ML

UNION

--SELECT CL.TSApproverID as'UserID',@taskidCL as 'TaskID',@tasknameCL as 'TaskName',@taskurlCL as 'URL',
--'Continuous Learning Pattern are not signed off since '+convert(varchar(1000),CAST(CL.CreatedDate AS DATE),101)+'  for the Project : '+CL.EsaProjectID +'-'+ LTRIM(RTRIM(CL.ProjectName))
--as 'TaskDetails',@taskapplicationCL as 'Application',@taskstatus as 'Status',
--getdate() as 'RefreshedTime','system' as 'CreatedBy', getdate() as 'CreatedTime',null as 'ModifiedBy',null as 'ModifiedTime',
--@tasktype as 'TaskType',null as 'ExpiryDate','N' as 'Read',CAST([dbo].[WorkDay](CL.CreatedDate,7) AS DATE)as 'DueDate',0 as 'ExpiryAfterRead',
--ProjectID as 'AccountID',2 AS 'JobTypeID'
--FROM CTECLValues CL

--UNION

SELECT DD.TSApproverID as'UserID',@taskidDD as 'TaskID',@tasknameDD as 'TaskName',@taskurlDD as 'URL',
'Patterns are not mapped in Data Dictionary for the Project : '+DD.EsaProjectID +'-'+ LTRIM(RTRIM(DD.ProjectName))
as 'TaskDetails',@taskapplicationDD as 'Application',@taskstatusDD as 'Status',
getdate() as 'RefreshedTime','system' as 'CreatedBy', getdate() as 'CreatedTime',null as 'ModifiedBy',null as 'ModifiedTime',
@tasktype as 'TaskType',null as 'ExpiryDate','N' as 'Read',@DDDueDate as 'DueDate',0 as 'ExpiryAfterRead',
ProjectID as 'AccountID',3 AS 'JobTypeID'
FROM CTEDDValues DD 


UNION
 
SELECT AH7.EmployeeID as'UserID',@taskidAH as 'TaskID',@tasknameAH as 'TaskName',@taskurlAH as 'URL',
'Automation/Healing tickets are Not-Assigned since '+convert(varchar(1000),CAST(AH7.CreatedDate AS DATE),101)+'  for the Project : '+AH7.EsaProjectID +'-'+ LTRIM(RTRIM(AH7.ProjectName))
as 'TaskDetails',@taskapplicationAH as 'Application',@taskstatus as 'Status',
getdate() as 'RefreshedTime','system' as 'CreatedBy', getdate() as 'CreatedTime',null as 'ModifiedBy',null as 'ModifiedTime',
@tasktype as 'TaskType',null as 'ExpiryDate','N' as 'Read',CAST([dbo].[WorkDay](AH7.CreatedDate,7) AS DATE) as 'DueDate',0 as 'ExpiryAfterRead',
ProjectID as 'AccountID',4 AS 'JobTypeID'
FROM CTEAHAll AH7		

UNION
 
SELECT AH7.EmployeeID as'UserID',@taskidAH as 'TaskID',@tasknameAH as 'TaskName',@taskurlAH as 'URL',
'Automation/Healing tickets are Not-Assigned since '+convert(varchar(1000),CAST(AH7.CreatedDate AS DATE),101)+'  for the Project : '+AH7.EsaProjectID +'-'+ LTRIM(RTRIM(AH7.ProjectName))
as 'TaskDetails',@taskapplicationAH as 'Application',@taskstatus as 'Status',
getdate() as 'RefreshedTime','system' as 'CreatedBy', getdate() as 'CreatedTime',null as 'ModifiedBy',null as 'ModifiedTime',
@tasktype as 'TaskType',null as 'ExpiryDate','N' as 'Read',CAST([dbo].[WorkDay](AH7.CreatedDate,14) AS DATE) as 'DueDate',0 as 'ExpiryAfterRead',
ProjectID as 'AccountID',5 AS 'JobTypeID'
FROM CTEAHSDM AH7
		
END TRY
BEGIN CATCH

	DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()

	--INSERT Error

	EXEC AVL_InsertError 'AVL.MLCLMyTaskPatterns',@ErrorMessage,0,0
			
END CATCH
END
