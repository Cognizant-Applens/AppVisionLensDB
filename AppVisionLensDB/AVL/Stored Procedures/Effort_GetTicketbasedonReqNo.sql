/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/




CREATE PROCEDURE [AVL].[Effort_GetTicketbasedonReqNo] --'DART0001056',5,'Customer1ID'
 @req_no NVARCHAR(1000),
 @ProjectID int,
 --@IsCognizant int,
 @EmployeeID NVARCHAR(max)
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;
SELECT DISTINCT
--@date AS [Date] ,
TD.AssignedTo as UserID,
LM.EmployeeName as AssigneeName,
TD.ProjectID as ProjectID,
TD.TicketID AS [TicketNumber] ,
--1000 AS Ticket ,
TD.TicketDescription as   TicketDescription,
CASE WHEN TD.ApplicationID IS NULL THEN 0
ELSE TD.ApplicationID
END AS ApplicationID ,
AD.ApplicationName as ApplicationName,
TD.TicketStatusMapID as StatusID,
--TD.TicketTypeMapID AS TicketTypeMapID,
DTS.DARTStatusName as StatusName,
TD.ServiceId as ServiceID,
0 AS CategoryID,
0 AS ActivityID,
--TSD.CategoryId as CategoryID,
--TSD.ActivityId as ActivityID,

TD.EffortTillDate as EffortTillDate,
TD.ActualEffort as ITSMEffort,
ISNULL(TD.IsAttributeUpdated,0) AS IsAttributeUpdated,
ISNULL(TD.IsSDTicket,0) AS IsSDTicket,
TD.TicketTypeMapID AS  TicketTypeID ,

TD.ProjectID,
TD.EffortTilldate ,
TD.TicketCreateDate,
PM.IsMainSpringConfigured as IsMainSpringConfig,
PM.IsDebtEnabled as IsDebtEnabled,
ISNULL(MASS.ServiceName,'') AS ServiceName    
FROM  AVL.TK_TRN_TicketDetail TD 
	left join  AVL.MAS_LoginMaster LM on LM.UserID=TD.AssignedTo
	left join AVL.APP_MAS_ApplicationDetails AD on AD.ApplicationID=TD.ApplicationID
	left join AVL.TK_MAP_TicketTypeMapping TTM on TD.TicketTypeMapID=TTM.TicketTypeMappingID AND TD.ProjectID=TTM.ProjectID AND TD.IsDeleted=0
    --left join  AVL.TM_TRN_TimesheetDetail TSD  on TD.TicketID=TSD.TicketID
    --left join AVL.TM_PRJ_Timesheet TS on TSD.TimesheetId=TS.TimesheetId
	left join AVL.TK_MAS_Service MASS on TD.ServiceID=MASS.ServiceID
	left join [AVL].[TK_MAS_DARTTicketStatus] DTS on TD.TicketStatusMapID=DTS.DARTStatusID
	left join AVL.MAS_ProjectMaster PM on TD.ProjectID= PM.ProjectID 
	left join AVL.TK_PRJ_ServiceProjectMapping SPM on SPM.ServiceID=TD.ServiceID and SPM.ProjectID=TD.ProjectID
WHERE ISNULL(TD.TicketID,'') != ''  AND PM.IsDeleted = 0  
AND TD.AssignedTo in (select distinct 
ISNULL(LM.UserID,0) as UserID
from AVL.MAS_LoginMaster LM
LEFT JOIN AVL.Customer Cust on LM.CustomerID=Cust.CustomerID
--LEFT JOIN AVL.RoleMaster RM on LM.RoleID=RM.RoleID
LEFT JOIN AVL.MAS_TimeZoneMaster TZM on LM.TimeZoneId=TZM.TimeZoneID
where LM.UserID=TD.AssignedTo)     
AND PM.IsDeleted = 0 AND TD.TicketID IN (  
SELECT  Item  
FROM    dbo.Split(@req_no, ';') ) AND  
 --TTM.IsDeleted = 0 AND
TD.ProjectID = @ProjectID  
ORDER BY TicketNumber DESC

SET NOCOUNT OFF;
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError ' [AVL].[Effort_GetTicketbasedonReqNo] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  
END
