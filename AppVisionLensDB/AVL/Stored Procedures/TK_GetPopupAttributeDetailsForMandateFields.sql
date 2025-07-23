/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[AVL].[TK_GetPopupAttributeDetailsForMandateFields] 4,2,null,'DART0001107',7
CREATE PROCEDURE [AVL].[TK_GetPopupAttributeDetailsForMandateFields]
(
@ProjectID INT,
@ServiceID INT = null,
@StatusID INT =  null,
@TicketID VARCHAR(150),
@CustomerID bigint
)
AS
BEGIN
BEGIN TRY


--To Ticket Attribute

	SELECT DISTINCT AD.ApplicationName, 
	TicketID,
	ISNULL(OpenDateTime,'') AS TicketOpenDate,
	TicketDescription,
	MP.PriorityName AS Priority,
	TTM.TicketType AS TicketType,
	
	CC.CauseCode,
	RC.ResolutionCode,
	DC.DebtClassificationName AS DebtType,
	ISNULL(AvoidableFlag,'0')AS AvoidableFlag,
	RD.ResidualDebtName AS ResidualDebt,
	SM.SeverityName AS Severity,
	AssignedTo,
	TS.TicketSourceName AS TicketSource,
	RT.ReleaseTypeName AS ReleaseType,
	EstimatedWorkSize,
	ActualEffort,
	ISNULL(TicketCreateDate,'') AS TicketCreateDate,
	ISNULL(ActualStartdateTime,'') AS ActualStartdateTime,
	ISNULL(ActualEnddateTime,'') AS ActualEnddateTime,
	ISNULL(Closeddate,'') AS Closeddate,
	KU.KEDBUpdatedName AS KEDBUpdated,
	KAI.KEDBAvailableIndicatorName AS KEDBAvailable,
	TD.KEDBPath,
	RCAID,
	Actualduration,
	MetResponseSLAMapID AS MetResponseSLA,
	MetAcknowledgementSLAMapID AS MetAcknowledgementSLA,
	MetResolutionMapID AS MetResolution,
	ISNULL(OpenDateTime,'') AS OpenDateTime,
	ISNULL(StartedDateTime,'') AS StartDateTime,
	ISNULL(WIPDateTime,'') AS WIPDateTime,
	ISNULL(OnHoldDateTime,'') AS OnHoldDateTime,
	ISNULL(CompletedDateTime,'') AS CompletedDateTime,
	ISNULL(ReopenDateTime,'') AS ReopenDateTime,
	ISNULL(CancelledDateTime,'') AS CancelledDateTime,
	ISNULL(RejectedDateTime,'') AS RejectedDateTime,
	ISNULL(AssignedDateTime,'') AS AssignedDateTime,
	SPM.ServiceName,
	DS.DARTStatusName,
	TD.ServiceID,
	TD.DARTStatusID,
	TD.ProjectID,
	MRM.ResolutionMethodName,
	TD.SeverityMapID,
	TD.PriorityMapID,
	TD.MetResponseSLAMapID,
	TD.MetAcknowledgementSLAMapID,
	TD.MetResolutionMapID,
	TD.ResolutionMethodMapID,
	TD.TicketSourceMapID,
	TD.CauseCodeMapID,
	TD.ResolutionCodeMapID,
	TD.ApplicationID,
	TD.DebtClassificationMapID,
	ISNULL(TD.ResidualDebtMapID,'0')AS ResidualDebtMapID,
	TD.KEDBAvailableIndicatorMapID,
	TD.KEDBUpdatedMapID,
	TD.ReleaseTypeMapID	,
	TD.TicketTypeMapID,
	TD.NatureoftheTicket,
	TD.IsAttributeUpdated,
	@StatusID AS TicketStatusID INTO #AllAtributeTemp
	FROM AVL.TK_TRN_TicketDetail(NOLOCK) TD
	LEFT JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON TD.ApplicationID = AD.ApplicationID AND AD.IsActive = 1
	LEFT JOIN AVL.TK_MAP_PriorityMapping(NOLOCK) MP ON TD.PriorityMapID = MP.PriorityIDMapID AND MP.IsDeleted = 0
	LEFT JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TD.TicketTypeMapID = TTM.TicketTypeMappingID AND TTM.IsDeleted = 0
	LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON TD.CauseCodeMapID = CC.CauseID AND CC.IsDeleted = 0
	LEFT JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC ON TD.ResolutionCodeMapID = RC.ResolutionID AND RC.IsDeleted = 0
	LEFT JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DC ON TD.DebtClassificationMapID = DC.DebtClassificationID AND DC.IsDeleted = 0
	LEFT JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RD ON TD.ResidualDebtMapID = RD.ResidualDebtID AND RD.IsDeleted = 0
	LEFT JOIN AVL.TK_MAP_SeverityMapping(NOLOCK) SM ON TD.SeverityMapID = SM.SeverityIDMapID AND SM.IsDeleted = 0 
	LEFT JOIN AVL.TK_MAS_TicketSource(NOLOCK) TS ON TD.TicketSourceMapID = TS.TicketSourceID AND TS.IsDeleted = 0
	LEFT JOIN AVL.TK_MAS_ReleaseType(NOLOCK) RT ON TD.ReleaseTypeMapID = RT.ReleaseTypeID AND RT.IsDeleted = 0
	LEFT JOIN AVL.TK_MAS_KEDBUpdated(NOLOCK) KU ON TD.KEDBUpdatedMapID = KU.KEDBUpdatedID AND KU.IsDeleted = 0	
	LEFT JOIN AVL.TK_PRJ_ServiceProjectMapping(NOLOCK) SPM ON TD.ServiceID = SPM.ServiceID AND SPM.IsDeleted = 0 AND SPM.ProjectID = @ProjectID
	LEFT JOIN AVL.TK_MAS_DARTTicketStatus(NOLOCK) DS ON TD.DARTStatusID = DS.DARTStatusID AND DS.IsDeleted = 0
	LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator(NOLOCK) KAI ON TD.KEDBAvailableIndicatorMapID = KAI.KEDBAvailableIndicatorID AND KAI.IsDeleted = 0
	LEFT JOIN AVL.DEBT_MAS_ResolutionMethod(NOLOCK) MRM ON TD.ResolutionMethodMapID = MRM.ResolutionMethodID AND MRM.IsDeleted = 0
	WHERE TD.TicketID = @TicketID 
	--AND TD.TicketStatusMapID = @StatusID 
	--AND TD.ServiceID = @ServiceID 
	AND TD.ProjectID = @ProjectID


	--Ticketing Attriburte
	SELECT DISTINCT ApplicationName, 
	TicketID,
	TicketOpenDate,
	TicketDescription,
	[Priority],
	TicketType
	 FROM #AllAtributeTemp
	 	--Debt Attriburte
	 SELECT DISTINCT ApplicationName, 
	TicketID,
	CauseCode,
	ResolutionCode,
	DebtType,
 AvoidableFlag,
	ResidualDebt
	 FROM #AllAtributeTemp
	 --Mandate Attribute
	 SELECT ApplicationName, 
	TicketID,
	CauseCode,
	ResolutionCode,
	DebtType,
 AvoidableFlag,
	ResidualDebt
	 FROM #AllAtributeTemp


	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[TK_GetPopupAttributeDetails] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  



END


--select * from AVL.DEBT_MAS_ResidualDebt

--select * from AVL.TK_TRN_TicketDetail  where ticketid='125'
