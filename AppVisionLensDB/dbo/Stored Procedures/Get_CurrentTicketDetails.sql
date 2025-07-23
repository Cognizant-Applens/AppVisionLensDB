/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Get_CurrentTicketDetails]  
@UserID INT = NULL,
@TicketID nvarchar(50)=NULL
AS
BEGIN
BEGIN TRY
select distinct APM.ProjectID,
	APM.ProjectApplicationMapID as AppPrjMapID,
	TD.TicketID,
	TD.TicketDescription as TicketDescription,
	TD.ServiceId as ServiceID,
	MASS.ServiceName as ServiceName,
	TD.TicketStatusMapID as StatusID,
	TS.DARTStatusName as StatusName,
	TD.EffortTillDate as EffortTillDate,
	TD.ActualEffort as ITSMEffort 
	from AVL.TK_TRN_TicketDetail TD 
	--TD.ProjectID,APM.Project_Application_MapID,
	join AVL.APP_MAP_ApplicationProjectMapping APM on TD.ApplicationID=APM.ProjectApplicationMapID
	join AVL.TK_MAS_Service MASS on TD.ServiceID=MASS.ServiceID
	join [AVL].[TK_MAS_DARTTicketStatus] TS on TD.TicketStatusMapID=TS.DARTStatusID 
	join [AVL].[APP_MAP_ApplicationUserMapping] AUM on TD.AssignedTo=AUM.UserID
	where TD.TicketID=@TicketID AND TD.AssignedTo=@UserID
	END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);


		EXEC AVL_InsertError '[dbo].[Get_CurrentTicketDetails] ', @ErrorMessage, @UserID,0
	END CATCH  
	END
