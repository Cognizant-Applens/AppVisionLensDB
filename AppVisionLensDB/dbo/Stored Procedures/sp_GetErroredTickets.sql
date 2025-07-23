/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Proc  [dbo].[sp_GetErroredTickets] @projectid int,@employeeid nvarchar(100),@SupportTypeID int=1
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;
IF @SupportTypeID = 1
BEGIN
Declare @DefaultValue varchar(10)='InValid'
select DISTINCT ECT.[ID]
      ,[Ticket ID]
      ,[Ticket Type]
      ,CASE WHEN [TicketTypeID] = -1 THEN NULL ELSE [TicketTypeID] END as TicketTypeID
      ,ECT.[Assignee]
      ,[Modified Date Time]
      ,[Open Date]
      ,[Priority]
      ,ECT.[PriorityID]
      ,[ResolutionID]
      ,[Resolution Code]
      ,[Status]
      ,[StatusID]
      ,[Ticket Description]
      ,ECT.[IsManual]
      ,ECT.[ModifiedBY]
      ,[Application]
      ,ECT.[ApplicationID]
      ,[EmployeeID]
      ,[EmployeeName]
      ,[External Login ID]
      ,[ProjectID]
      ,ECT.[IsDeleted]
      ,[Severity]
      ,[severityID]
      ,[DebtClassificationId]
      ,[Debt Classification]
      ,[AvoidableFlagID]
      ,[Avoidable Flag]
      ,[Residual Debt]
      ,[ResidualDebtID]
      ,[Cause code]
      ,[CauseCodeID]
      ,[SupporttypeID]
	  ,ECT.TowerID
	  ,TowerName
	  ,[Assignment Group ID]
	  ,[Assignment Group]
	   ,CASE WHEN HTD.HealingTicketID IS NOT NULL
	THEN 1 ELSE 0 END AS 'IsAHTicket',
	CASE WHEN IsPartiallyAutomated <> @DefaultValue then IsPartiallyAutomated else 2 END IsPartiallyAutomated
	from AVL.ErrorLogCorrectionTickets ECT with(NOLOCK)
	  LEFT JOIN [AVL].[DEBT_TRN_HealTicketDetails] HTD with(NOLOCK) ON ECT.[Ticket ID]=HTD.HealingTicketID
where ECT.projectid=@projectid and ECT.[External Login ID]=@employeeid  and SupporttypeID=1
and ECT.[Ticket ID] not in (select TD.TicketID from AVL.TK_TRN_TicketDetail TD with(NOLOCK) where  TD.ProjectID = @projectid)

	IF EXISTS(
	select DISTINCT top 1 1 from AVL.ErrorLogCorrectionTickets ECT with(NOLOCK)
	where ECT.projectid=@projectid and ECT.[External Login ID]=@employeeid and SupporttypeID=1
	and ECT.[Ticket ID] in (select TD.TicketID from AVL.TK_TRN_TicketDetail TD with(NOLOCK) where  TD.ProjectID = @projectid)
	)

	BEGIN
		DELETE from AVL.ErrorLogCorrectionTickets 
		where projectid=@projectid and [External Login ID]=@employeeid and SupporttypeID=1
		and [Ticket ID] in (select TD.TicketID from AVL.TK_TRN_TicketDetail TD with(NOLOCK) where  TD.ProjectID = @projectid)
	END
END
ELSE
BEGIN
select DISTINCT ECT.[ID]
      ,[Ticket ID]
      ,[Ticket Type]
     , CASE WHEN [TicketTypeID] = -1 THEN NULL ELSE [TicketTypeID] END as TicketTypeID
      ,ECT.[Assignee]
      ,[Modified Date Time]
      ,[Open Date]
      ,[Priority]
      ,ECT.[PriorityID]
      ,[ResolutionID]
      ,[Resolution Code]
      ,[Status]
      ,[StatusID]
      ,[Ticket Description]
      ,ECT.[IsManual]
      ,ECT.[ModifiedBY]
      ,[Application]
      ,[ApplicationID]
      ,[EmployeeID]
      ,[EmployeeName]
      ,[External Login ID]
      ,[ProjectID]
      ,ECT.[IsDeleted]
      ,[Severity]
      ,[severityID]
      ,[DebtClassificationId]
      ,[Debt Classification]
      ,[AvoidableFlagID]
      ,[Avoidable Flag]
      ,[Residual Debt]
      ,[ResidualDebtID]
      ,[Cause code]
      ,[CauseCodeID]
      ,[SupporttypeID]
	  ,ECT.TowerID
	  ,TowerName
	  ,[Assignment Group ID]
	  ,[Assignment Group] 
	  ,CASE WHEN HTD.HealingTicketID IS NOT NULL
	THEN 1 ELSE 0 END AS 'IsAHTicket',
	CASE WHEN IsPartiallyAutomated <> @DefaultValue then IsPartiallyAutomated else 2 END IsPartiallyAutomated
	from AVL.ErrorLogCorrectionTickets ECT with(NOLOCK)
	LEFT JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails] HTD with(NOLOCK) ON ECT.[Ticket ID]=HTD.HealingTicketID
where ECT.projectid=@projectid and ECT.[External Login ID]=@employeeid  and SupporttypeID=2
and ECT.[Ticket ID] not in (select TD.TicketID from AVL.TK_TRN_InfraTicketDetail TD with(NOLOCK) where  TD.ProjectID = @projectid)

	IF EXISTS(
	select DISTINCT top 1 1 from AVL.ErrorLogCorrectionTickets ECT with(NOLOCK)
	where ECT.projectid=@projectid and ECT.[External Login ID]=@employeeid and SupporttypeID=2
	and ECT.[Ticket ID] in (select TD.TicketID from AVL.TK_TRN_InfraTicketDetail TD with(NOLOCK) where  TD.ProjectID = @projectid)
	)

	BEGIN
		DELETE from AVL.ErrorLogCorrectionTickets 
		where projectid=@projectid and [External Login ID]=@employeeid and SupporttypeID=2
		and [Ticket ID] in (select TD.TicketID from AVL.TK_TRN_InfraTicketDetail TD with(NOLOCK) where  TD.ProjectID = @projectid)
	END
END

END TRY
  BEGIN CATCH
  	DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		SELECT @ErrorMessage
		--ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[sp_GetErroredTickets]', @ErrorMessage, @projectid,0
		
  END CATCH

End
