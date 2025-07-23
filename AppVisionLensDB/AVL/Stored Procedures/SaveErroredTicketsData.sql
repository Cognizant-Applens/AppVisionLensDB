/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[SaveErroredTicketsData]
@SaveErrorLogTicketDetails [AVL].[SaveErrorLogTicketDetails] readonly,
@ProjectID int,
@EmployeeID nvarchar(50),
@SupportTypeID INT=1
as
Begin
BEGIN TRY
SET NOCOUNT ON;
declare @userid bigint
set @userid = (select userid from AVL.MAS_LoginMaster With (NOLOCK) where ProjectID=@ProjectID and EmployeeID=@EmployeeID and IsDeleted=0)

IF @SupportTypeID = 1 
BEGIN
insert into AVL.TK_TRN_TicketDetail([TicketID],
[ApplicationID],
[ProjectID],
	AssignedTo,
	TicketDescription,
	IsDeleted,
	CauseCodeMapID,
	DebtClassificationMapID,
	ResolutionCodeMapID,
	ResidualDebtMapID,
	PriorityMapID,
	SeverityMapID,
	TicketStatusMapID,
	TicketTypeMapID,
	AvoidableFlag,
	OpenDateTime,
	IsManual,
	IsSDTicket,
	CreatedBy,
	CreatedDate,
	EffortTillDate,
	ServiceID,
	LastUpdatedDate,
	InitiatedSource,
	IsPartiallyAutomated)
(select TVP.TicketID,
	TVP.ApplicationID,
	@ProjectID,
	@userid,
	TVP.TicketDescription,
	0,
	TVP.CauseCodeID,
	TVP.DebtClassificationID,
	TVP.ResolutionID,
	TVP.ResidualDebtID,
	TVP.PriorityID,
	TVP.SeverityID,
	TVP.StatusID,
	TVP.TicketTypeID,
	TVP.AvoidableFlagID,
	TVP.OpenDate,
	1,
	0,
	@employeeid,
	GETDATE(),'0.00',0,getdate(),
	6,
	TVP.IsPartiallyAutomated
	from @SaveErrorLogTicketDetails TVP   
	left join  AVL.TK_TRN_TicketDetail(nolock) t2 on
	t2.[TicketID] =TVP.ticketid and  t2.ProjectID=@projectid
	WHERE t2.TimeTickerID is NULL)

--updating ticketdetail table
	UPDATE T 
	SET T.[TicketID]=S.TicketID,
T.[ApplicationID]=S.ApplicationID,
T.[ProjectID]=@ProjectID,
	T.AssignedTo=@userid,
	T.TicketDescription=S.TicketDescription,
	T.IsDeleted=0,
	T.CauseCodeMapID=S.CauseCodeID,
	T.DebtClassificationMapID=S.DebtClassificationID,
	T.ResolutionCodeMapID=S.ResolutionID,
	T.ResidualDebtMapID=S.ResidualDebtID,
	T.PriorityMapID=S.PriorityID,
	T.SeverityMapID=S.SeverityID,
	T.TicketStatusMapID=S.StatusID,
	T.TicketTypeMapID=S.TicketTypeID,
	T.AvoidableFlag=S.AvoidableFlagID,
	T.OpenDateTime=S.OpenDate,
	T.IsManual=1,
	T.IsSDTicket=0,
	T.ModifiedBy=@EmployeeID,
	T.ModifiedDate=GETDATE(),T.LastUpdatedDate=GETDATE(),
	T.LastModifiedSource=6
	from AVL.TK_TRN_TicketDetail (nolock) T
	join  @SaveErrorLogTicketDetails S 
		on t.ProjectID = @projectid and s.ticketid = t.TicketID 
	
	IF EXISTS(SELECT TOP 1 1 FROM @SaveErrorLogTicketDetails WHERE IsTicketDescriptionModified = 1)
	BEGIN
		SELECT ITD.[TicketID],TD.TimeTickerID, ITD.IsTicketDescriptionModified, ITD.MTicketDescription
		INTO #MultilingualTblaApp
		FROM  @SaveErrorLogTicketDetails ITD INNER JOIN AVL.TK_TRN_TicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.[TicketID] 
		AND TD.ProjectID=@ProjectID AND TD.IsDeleted=0
		WHERE ITD.IsTicketDescriptionModified = 1
		
		MERGE [AVL].[TK_TRN_Multilingual_TranslatedTicketDetails] AS TARGET
		USING #MultilingualTblaApp AS SOURCE
		ON (Target.TimeTickerID=SOURCE.TimeTickerID)
		WHEN MATCHED  
		THEN 
		UPDATE SET TARGET.TicketDescription = SOURCE.MTicketDescription,
					TARGET.IsTicketDescriptionUpdated = 0,
					TARGET.ModifiedBy=@EmployeeID,
					TARGET.ModifiedDate=GETDATE(),
					TARGET.TicketCreatedType=5
					WHEN NOT MATCHED BY TARGET 
		THEN 
		INSERT (TimeTickerID,TicketDescription,IsTicketDescriptionUpdated,IsResolutionRemarksUpdated,IsTicketSummaryUpdated,
		IsCommentsUpdated,IsFlexField1Updated,IsFlexField2Updated,IsFlexField3Updated,IsFlexField4Updated,
		IsCategoryUpdated,IsTypeUpdated,Isdeleted,CreatedBy,CreatedDate,TicketCreatedType) 
		VALUES (SOURCE.TimeTickerID,SOURCE.MTicketDescription,0,0,0,0,0,0,0,0,0,0,0,@EmployeeID,GETDATE(),5);
	END

--PRINT 'ML INFRA CROSSED'
	--deleting from errorlog table comparing with ticketdetail table
	DELETE FROM AVL.ErrorLogCorrectionTickets
	WHERE EXISTS (SELECT TicketID
			      FROM AVL.TK_TRN_TicketDetail With  (NOLOCK) 
                  WHERE AVL.TK_TRN_TicketDetail.[TicketID] = AVL.ErrorLogCorrectionTickets.[Ticket ID]
                  AND AVL.TK_TRN_TicketDetail.ProjectID = AVL.ErrorLogCorrectionTickets.ProjectID)
				  AND SupportTypeID=1
END
ELSE
BEGIN
	insert into AVL.TK_TRN_InfraTicketDetail([TicketID],
[TowerID],
[AssignmentGroupID],
[ProjectID],
	AssignedTo,
	TicketDescription,
	IsDeleted,
	CauseCodeMapID,
	DebtClassificationMapID,
	ResolutionCodeMapID,
	ResidualDebtMapID,
	PriorityMapID,
	SeverityMapID,
	TicketStatusMapID,
	TicketTypeMapID,
	AvoidableFlag,
	OpenDateTime,
	IsManual,
	IsSDTicket,
	CreatedBy,
	CreatedDate,
	EffortTillDate,
	ServiceID,
	LastUpdatedDate,
	InitiatedSource,
	IsPartiallyAutomated)
(select TVP.TicketID,
	TVP.TowerID,
	TVP.AssignmentGroupID,
	@ProjectID,
	@userid,
	TVP.TicketDescription,
	0,
	TVP.CauseCodeID,
	TVP.DebtClassificationID,
	TVP.ResolutionID,
	TVP.ResidualDebtID,
	TVP.PriorityID,
	TVP.SeverityID,
	TVP.StatusID,
	TVP.TicketTypeID,
	TVP.AvoidableFlagID,
	TVP.OpenDate,
	1,
	0,
	@employeeid,
	GETDATE(),'0.00',0,getdate(),
	6,
	TVP.IsPartiallyAutomated
	from @SaveErrorLogTicketDetails TVP  
	left join  AVL.TK_TRN_InfraTicketDetail(nolock) t2 on
	t2.[TicketID] =TVP.ticketid and  t2.ProjectID=@projectid
	WHERE t2.TimeTickerID is NULL)

--updating ticketdetail table
	UPDATE T 
	SET T.[TicketID]=S.TicketID,
T.[TowerID]=S.[TowerID],
T.AssignmentGroupID=S.AssignmentGroupID,
T.[ProjectID]=@ProjectID,
	T.AssignedTo=@userid,
	T.TicketDescription=S.TicketDescription,
	T.IsDeleted=0,
	T.CauseCodeMapID=S.CauseCodeID,
	T.DebtClassificationMapID=S.DebtClassificationID,
	T.ResolutionCodeMapID=S.ResolutionID,
	T.ResidualDebtMapID=S.ResidualDebtID,
	T.PriorityMapID=S.PriorityID,
	T.SeverityMapID=S.SeverityID,
	T.TicketStatusMapID=S.StatusID,
	T.TicketTypeMapID=S.TicketTypeID,
	T.AvoidableFlag=S.AvoidableFlagID,
	T.OpenDateTime=S.OpenDate,
	T.IsManual=1,
	T.IsSDTicket=0,
	T.ModifiedBy=@EmployeeID,
	T.ModifiedDate=GETDATE(),T.LastUpdatedDate=GETDATE(),
	T.LastModifiedSource=6
	from AVL.TK_TRN_InfraTicketDetail(nolock) T
	join  @SaveErrorLogTicketDetails S 
		on t.ProjectID = @projectid and s.ticketid = t.TicketID 

	
	IF EXISTS(SELECT TOP 1 1 FROM @SaveErrorLogTicketDetails WHERE IsTicketDescriptionModified = 1)
	BEGIN
		SELECT ITD.[TicketID],TD.TimeTickerID, ITD.IsTicketDescriptionModified, ITD.MTicketDescription
		INTO #MultilingualTblaInfra
		FROM  @SaveErrorLogTicketDetails ITD INNER JOIN AVL.TK_TRN_InfraTicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.[TicketID] 
		AND TD.ProjectID=@ProjectID AND TD.IsDeleted=0
		WHERE ITD.IsTicketDescriptionModified = 1
		
		MERGE [AVL].[TK_TRN_Multilingual_TranslatedInfraTicketDetails] AS TARGET
		USING #MultilingualTblaInfra AS SOURCE
		ON (Target.TimeTickerID=SOURCE.TimeTickerID)
		WHEN MATCHED  
		THEN 
		UPDATE SET TARGET.TicketDescription = SOURCE.MTicketDescription,
					TARGET.IsTicketDescriptionUpdated = 0,
					TARGET.ModifiedBy=@EmployeeID,
					TARGET.ModifiedDate=GETDATE(),
					TARGET.TicketCreatedType=5
					WHEN NOT MATCHED BY TARGET 
		THEN 
		INSERT (TimeTickerID,TicketDescription,IsTicketDescriptionUpdated,IsResolutionRemarksUpdated,IsTicketSummaryUpdated,
		IsCommentsUpdated,IsFlexField1Updated,IsFlexField2Updated,IsFlexField3Updated,IsFlexField4Updated,
		IsCategoryUpdated,IsTypeUpdated,Isdeleted,CreatedBy,CreatedDate,TicketCreatedType ) 
		VALUES (SOURCE.TimeTickerID,SOURCE.MTicketDescription,0,0,0,0,0,0,0,0,0,0,0,@EmployeeID,GETDATE(),5);
	END

	--deleting from errorlog table comparing with ticketdetail table
	DELETE FROM AVL.ErrorLogCorrectionTickets
	WHERE EXISTS (SELECT TicketID
			      FROM AVL.TK_TRN_InfraTicketDetail 
                  WHERE AVL.TK_TRN_InfraTicketDetail.[TicketID] = AVL.ErrorLogCorrectionTickets.[Ticket ID]
                  AND AVL.TK_TRN_InfraTicketDetail.ProjectID = AVL.ErrorLogCorrectionTickets.ProjectID)
				  AND SupportTypeID=2
END
--select * from AVL.ErrorLogCorrectionTickets(NOLOCK) WHERE ProjectID=@projectid AND SupportTypeID=@SupportTypeID
SET NOCOUNT OFF
 END TRY
  BEGIN CATCH
  	DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		SELECT @ErrorMessage
		--ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[SaveErroredTicketsData]', @ErrorMessage, @projectid,0
		
  END CATCH

End
