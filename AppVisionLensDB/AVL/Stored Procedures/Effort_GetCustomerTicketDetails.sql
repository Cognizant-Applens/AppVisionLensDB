/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[Effort_GetCustomerTicketDetails]
@EmployeeID NVARCHAR(1000)=null
as
begin
BEGIN TRY
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
	PM.IsMainSpringConfigured as IsMainSpringConfig,
	PM.IsDebtEnabled as IsDebtEnabled
	from AVL.TK_TRN_TicketDetail TD 
	left join AVL.TM_TRN_TimesheetDetail TSD on TD.TicketID=TSD.TicketID
	left join AVL.TM_PRJ_Timesheet TS on TSD.TimesheetId=TS.TimesheetId
	left join [AVL].[TK_MAS_DARTTicketStatus] DTS on TD.TicketStatusMapID=DTS.DARTStatusID
	left join AVL.MAS_ProjectMaster PM on TD.ProjectID= PM.ProjectID 
	where TD.AssignedTo in (select distinct 
ISNULL(LM.UserID,0) as UserID
from AVL.MAS_LoginMaster LM
LEFT JOIN AVL.Customer Cust on LM.CustomerID=Cust.CustomerID

LEFT JOIN AVL.MAS_TimeZoneMaster TZM on LM.TimeZoneId=TZM.TimeZoneID
where LM.EmployeeID=@EmployeeID
     and LM.IsDeleted=0 AND TD.IsDeleted=0
AND LM.ProjectID = TD.ProjectID
  --and RM.IsActive=1
)  
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Effort_GetCustomerTicketDetails]', @ErrorMessage, @EmployeeID,0
		
	END CATCH  
END
