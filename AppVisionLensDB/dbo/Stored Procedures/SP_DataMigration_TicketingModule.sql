/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =======================================================================================  
-- Author:  Annadurai.S  
-- Create date: 13 July 2018
-- Description: Migration of Debt Configuration Module
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- Test: EXEC SP_DataMigration_TicketingModule 1211571 ,'1000101016', 1
-- =======================================================================================  

CREATE PROCEDURE [dbo].[SP_DataMigration_TicketingModule]
(
	@AccountId BIGINT, -- ESA Account ID
	@ESAProjectIDs NVARCHAR(MAX), -- ESA Project IDs
	@IsIncrementalProject BIT
)
AS
BEGIN
  BEGIN TRY
	BEGIN TRAN
	   
	   ---------- Get all projects or specific project(s) for the Accounts ----------
	   SELECT Item AS ESAProjectID INTO #ESAProjectIds FROM dbo.Split(@ESAProjectIDs, ',')

	   DECLARE @ProjectID INT

	   --SELECT @ProjectID = ProjectID from AVL.MAS_ProjectMaster where EsaProjectID = @ESAProjectIDs

	   DECLARE @ProjectDetails TABLE 
		( 
			AccountID INT,
			AccountName NVARCHAR(MAX),
			ProjectID INT,
			EsaProjectID NVARCHAR(MAX),
			ProjectName VARCHAR(MAX),
			AppLensCustomerID BIGINT,
			AppLensProjectID BIGINT
		)

		INSERT INTO @ProjectDetails
			SELECT DISTINCT DA.AccountID AS AccountID,
			AccountName,
			PM.ProjectID,
			PM.EsaProjectID,
			PM.ProjectName,
			CUST.CustomerID,
			APLPM.ProjectID  
		FROM AVMDART.MAS.ProjectMaster (NOLOCK) PM
		JOIN AVMDART.[MAP].[DeptAcctMapping] (NOLOCK) DA 
			ON DA.DeptAccountID = PM.DeptAccountID
				AND DA.AccountID=@AccountId AND DA.IsDeleted = 'N' 
				AND PM.IsDeleted = 'N' 
		JOIN AVL.Customer (NOLOCK) CUST
			ON CUST.ESA_AccountID = DA.AccountID AND CUST.IsDeleted = 0
		JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APLPM
			ON APLPM.EsaProjectID = PM.EsaProjectID AND APLPM.IsDeleted = 0
				WHERE @ESAProjectIDs IS NULL OR PM.EsaProjectID IN (SELECT ESAProjectID FROM #ESAProjectIds)

		DROP TABLE #ESAProjectIds

		-------------------------------- INSERT DEBT STOP WORDS -------------------------------
	
		INSERT INTO dbo.Debt_Stopwords
		(	
			Stopword
		)
		SELECT DS.Stopword
		FROM AVMDART.[dbo].[Debt_Stopwords] (NOLOCK) DS
		LEFT JOIN dbo.Debt_Stopwords (NOLOCK) ALDS 
			ON ALDS.Stopword = DS.Stopword
		WHERE ALDS.Stopword_No IS NULL

		---------------------------------------------------------------------------------------

		----------------------------------- ID Generation -------------------------------------

        DECLARE @TEMP TABLE
		( 
			AccountID INT,			
			ProjectID INT,
			NextID INT,
			SDTicketFormat NVARCHAR(MAX)	
		)

		INSERT INTO @TEMP
			SELECT	@AccountId AS AccountID,
					PIDG.ProjectID,
					PIDG.NextID,
					MPC.SDTicketFormat 		
			FROM AVMDART.PRJ.IDGeneration  PIDG
			JOIN AVMDART.MAP.ProjectConfig MPC
				ON MPC.ProjectID = PIDG.ProjectID
			JOIN AVMDART.[MAS].[ProjectMaster] DPM
				ON DPM.ProjectID = MPC.ProjectID AND DPM.IsDeleted = 'N'
			JOIN AVMDART.[MAP].[DeptAcctMapping]  DAM 
				ON DAM.DeptAccountID = DPM.DeptAccountID AND DAM.IsDeleted = 'N'
			JOIN @ProjectDetails P
				ON P.ProjectID = DPM.ProjectID


		INSERT INTO AVL.TK_MAP_IDGeneration
		(
			NextID, 
			CustomerID,
			IsDeleted,
			CreatedBy,
			CreatedDate,
			ModifiedBy,
			ModifiedDate
		)
		SELECT	MAX(TP.NextID), 
				CUST.CustomerID AS CustomerID,
				0 IsDeleted,
				'Migrated' AS CreatedBy,
				GETDATE() AS CreatedDate,
				Null AS ModifiedBy,
				Null AS ModifiedDate 
		FROM @TEMP TP
		JOIN AVL.Customer (NOLOCK) CUST ON CUST.ESA_AccountID = TP.AccountID
		LEFT JOIN AVL.TK_MAP_IDGeneration (NOLOCK) ID
			ON ID.CustomerID = CUST.CustomerID
		WHERE ID.CustomerID IS NULL
		GROUP BY CUST.CustomerID
		HAVING COUNT(TP.SDTicketFormat) = 1 	

		-------------------------------------------------------------------------------------------------------

		------------------------------- PUSH TICKET DETAILS (MASTER) TABLE ------------------------------------
		PRINT 'Pushing Tickets - Start'

		-- Resolveddate -> If Completed Date Time IS NULL
		-- SlaMiss -> If Met Resolution IS NULL
		-- ReleaseDate -> If Actual End date Time IS NULL
		-- RootCause -> If Resolution Remarks IS NULL
		-- BusinessImpact -> If Comments IS NULL. Append BusinessImpact_ with Value

		SELECT TM.* 
        INTO #TicketMasterFromJuly
        FROM AVMDART.PRJ.TicketMaster (NOLOCK) TM 
        JOIN @ProjectDetails PD ON TM.ProjectID = PD.ProjectID
        WHERE OpenDate >= '2018-07-01' AND ISNULL(TM.IsDeleted, 'N') = 'N'


		SELECT TM.*
        INTO #TimeSheetDetailsTicketMaster
        FROM @ProjectDetails PD
        JOIN AVMDART.PRJ.TicketMaster (NOLOCK) TM
                ON TM.ProjectID = PD.ProjectID AND ISNULL(TM.IsDeleted, 'N') = 'N'
        JOIN AVMDART.PRJ.Timesheet (NOLOCK) DTS 
                ON DTS.ProjectId = TM.ProjectID AND DTS.TimesheetDate >= '2018-07-01'
        JOIN AVMDART.TRN.TimesheetDetail (NOLOCK) DTD 
                ON DTD.ProjectId = TM.ProjectID AND DTD.TimesheetId = DTS.TimesheetId AND DTD.TicketNo = TM.TicketID 

	
       SELECT TM.* INTO #LeftOutTicketMaster  from #TimeSheetDetailsTicketMaster (NOLOCK) TM
	   LEFT JOIN #TicketMasterFromJuly (nolock) TFM
			  ON TFM.ProjectId=TM.ProjectId
	   AND TFM.TicketID=TM.TicketID
	   AND TFM.ProjectId is null

        SELECT DISTINCT *
        INTO #TicketMasterNew
        FROM
        (
                SELECT * FROM #TicketMasterFromJuly
                UNION 
                SELECT * FROM #LeftOutTicketMaster
        ) AS T

		UPDATE TM SET Assignee = LM.UserID
		FROM #TicketMasterNew (nolock) TM
		JOIN AVMDART.PRJ.LoginMaster (nolock) LM
			ON LM.CognizantName = TM.Assignee
		WHERE Assignee = CognizantName
			
			
		SELECT DARTTM.*, DARTPMP.PriorityName, DARTPMP.IsDeleted AS PriorityIsDeleted, DRTSTS.DARTStatusName, DARTAP.ApplicationName, DRTSTSM.StatusName, 
			DRTSTSM.IsDeleted AS ProjectStatusIsDeleted, DARTTY.TicketType AS TicketTypeName, DARTTY.IsDeleted AS TicketTypeIsDeleted,
			CASE WHEN ISNULL(DDTD.IsApproved, '') = 'Y' THEN 1 ELSE 0 END IsApproved, 
			DARTLM.CognizantID AS AssigneeCognizantID, DARTSM.ServiceName, DARTDC.CauseCode, DARTAM.AttributeTypeValue AS DebtClassificationName, 
			DARTATM.AttributeTypeValue AS ResidualDebtName, DARTKEDB.AttributeTypeValue AS KEDBAvailableIndicatorName, DTKEDB.AttributeTypeValue AS KEDBUpdatedName, 
			DTKRTY.AttributeTypeValue AS ReleaseTypeName, DTKSVR.AttributeTypeValue AS SeverityName, DRTAF.AttributeTypeValue AS AvoidableFlagName, 
			DRTDRS.ResolutionCode AS ResolutionCode1, DRTPSD.SourceName, DRTPSD.IsFixedSource
		INTO #DARTTicketDetails
		FROM @ProjectDetails PD
		JOIN #TicketMasterNew DARTTM ON DARTTM.ProjectID = PD.ProjectID 
		JOIN AVMDART.PRJ.PriorityMaster (NOLOCK) DARTPMP 
			ON  DARTPMP.PriorityID = DARTTM.PriorityID AND DARTPMP.ProjectID = DARTTM.ProjectID
		JOIN AVMDART.MAS.DARTStatus (NOLOCK) DRTSTS 
			ON DRTSTS.DARTSatusID = DARTTM.DARTStatusID
		JOIN AVMDART.MAS.ApplicationMaster (NOLOCK) DARTAP 
			ON DARTAP.ApplicationID = DARTTM.ApplicationID			
		LEFT JOIN AVMDART.PRJ.StatusMaster (NOLOCK) DRTSTSM
			ON DRTSTSM.StatusID = DARTTM.StatusID AND DRTSTSM.ProjectID = DARTTM.ProjectID
		LEFT JOIN AVMDART.PRJ.TicketTypeMapping (NOLOCK) DARTTY
			ON DARTTY.TicketTypeMappingID = DARTTM.TicketType AND DARTTY.ProjectID = DARTTM.ProjectID
		LEFT JOIN AVMDART.PRJ.DebtApprovedTicketDetails (NOLOCK) DDTD
			ON DDTD.ProjectId = DARTTM.ProjectID AND DDTD.TicketId = DARTTM.TicketID
		LEFT JOIN AVMDART.PRJ.LoginMaster (NOLOCK) DARTLM
			ON CONVERT(VARCHAR(MAX), DARTLM.UserID) = DARTTM.Assignee
		LEFT JOIN AVMDART.MAS.ServiceMaster (NOLOCK) DARTSM
			ON DARTSM.ServiceID = DARTTM.ServiceID
		LEFT JOIN AVMDART.MAS.DeptCauseCode (NOLOCK) DARTDC
			ON DARTDC.CauseID = DARTTM.TicketLocation
		LEFT JOIN AVMDART.MAS.AttributeFieldMAster (NOLOCK) DARTAM
			ON DARTAM.Id = DARTTM.DebtClassificationId
		LEFT JOIN AVMDART.MAS.AttributeFieldMAster (NOLOCK) DARTATM
			ON DARTATM.Id = DARTTM.ResidualDebt
		LEFT JOIN AVMDART.MAS.AttributeFieldMAster (NOLOCK) DARTKEDB
			ON DARTKEDB.ID = DARTTM.KEDBAvailableIndicator
		LEFT JOIN AVMDART.MAS.AttributeFieldMAster (NOLOCK) DTKEDB
			ON DTKEDB.ID = DARTTM.KEDBUpdated
		LEFT JOIN AVMDART.MAS.AttributeFieldMAster (NOLOCK) DTKRTY
			ON DTKRTY.ID = DARTTM.ReleaseType
		LEFT JOIN AVMDART.MAS.AttributeFieldMAster (NOLOCK) DTKSVR
			ON DTKSVR.ID = DARTTM.Severity
		LEFT JOIN AVMDART.MAS.AttributeFieldMAster (NOLOCK) DRTAF
			ON DRTAF.Id = DARTTM.AvoidableFlag
		LEFT JOIN AVMDART.MAS.DeptResolutionCode (NOLOCK) DRTDRS
			ON DRTDRS.ResolutionID = DARTTM.Reviewer AND DRTDRS.ProjectID = DARTTM.ProjectID
		LEFT JOIN AVMDART.PRJ.ProjectSourceDetails (NOLOCK) DRTPSD
			ON DRTPSD.SourceID = DARTTM.Source AND DRTPSD.ProjectID = DARTTM.ProjectID
			
		SELECT ATM.* 
		INTO #AppLensTicketMaster 
		FROM AVL.TK_TRN_TicketDetail (NOLOCK) ATM
		JOIN @ProjectDetails PD ON PD.AppLensProjectID = ATM.ProjectID

		SELECT BC.*
		INTO #AppLensBusinessClusterMapping
		FROM @ProjectDetails PD
		JOIN [AVL].[BusinessClusterMapping] (NOLOCK) BC 
			ON BC.CustomerID = PD.AppLensCustomerID 
			AND BC.IsHavingSubBusinesss = 0

		-- Resolveddate -> If Completed Date Time IS NULL
		-- SlaMiss -> If Met Resolution IS NULL
		-- ReleaseDate -> If Actual End date Time IS NULL
		-- RootCause -> If Resolution Remarks IS NULL
		-- BusinessImpact -> If Comments IS NULL. Append BusinessImpact_ with Value
		INSERT INTO AVL.TK_TRN_TicketDetail
	    (
			TicketID,
			ApplicationID,
			ProjectID,
			AssignedTo,
			AssignmentGroup,
			EffortTillDate,
			ServiceID,
			TicketDescription,
			IsDeleted,
			CauseCodeMapID,
			DebtClassificationMapID,
			ResidualDebtMapID,
			ResolutionCodeMapID,
			ResolutionMethodMapID,
			KEDBAvailableIndicatorMapID,
			KEDBUpdatedMapID,
			KEDBPath,
			PriorityMapID,
			ReleaseTypeMapID,
			SeverityMapID,
			TicketSourceMapID,
			TicketStatusMapID,
			TicketTypeMapID,
			BusinessSourceName,
			Onsite_Offshore,
			PlannedEffort,
			EstimatedWorkSize,
			ActualEffort,
			ActualWorkSize,
			Resolvedby,
			Closedby,
			ElevateFlagInternal,
			RCAID,
			PlannedDuration,
			Actualduration,
			TicketSummary,
			NatureoftheTicket,
			Comments,
			RepeatedIncident,
			RelatedTickets,
			TicketCreatedBy,
			SecondaryResources,
			EscalatedFlagCustomer,
			ReasonforRejection,
			AvoidableFlag,
			ReleaseDate,
			TicketCreateDate,
			PlannedStartDate,
			PlannedEndDate,
			ActualStartdateTime,
			ActualEnddateTime,
			OpenDateTime,
			StartedDateTime,
			WIPDateTime,
			OnHoldDateTime,
			CompletedDateTime,
			ReopenDateTime,
			CancelledDateTime,
			RejectedDateTime,
			Closeddate,
			AssignedDateTime,
			OutageDuration,
			MetResponseSLAMapID,
			MetAcknowledgementSLAMapID,
			MetResolutionMapID,
			EscalationSLA,
			TKBusinessID,
			InscopeOutscope,
			IsAttributeUpdated,
			NewStatusDateTime,
			IsSDTicket,
			IsManual,
			DARTStatusID,
			ResolutionRemarks,
			ITSMEffort,
			CreatedBy,
			CreatedDate,
			LastUpdatedDate,
			ModifiedBy,
			ModifiedDate,
			IsApproved,
			ReasonResidualMapID,
			ExpectedCompletionDate,
			ApprovedBy,
			DAPId,
			DebtClassificationMode
		)			

		SELECT	DISTINCT DARTTM.TicketID,
				ISNULL(APM.ApplicationID, 0) AS ApplicationID,
				PD.AppLensProjectID,
				ISNULL(LM.UserID, 0) AS AssignedTo,
				NULL AS AssignmentGroup,
				CASE WHEN ISNULL(DARTTM.EffortTillDate, 0) <> 0 THEN DARTTM.EffortTillDate ELSE 0.0 END AS EffortTillDate,
				CASE WHEN ISNULL(SM.ServiceID, 0) <> 0 THEN SM.ServiceID ELSE 0 END ServiceID,
				ISNULL(DARTTM.TicketDescription, ''),
				0,
				ISNULL(DC.CauseID, 0) as CauseCodeMapID,
				ISNULL(DCL.DebtClassificationID, 0) AS DebtClassificationMapID,
				RD.ResidualDebtID AS ResidualDebtMapID,
				RC.ResolutionID AS ResolutionCodeMapID,
				0 AS ResolutionMethodMapID,
				KEDB.KEDBAvailableIndicatorID AS KEDBAvailableIndicatorMapID,
			    KEDBU.KEDBAvailableIndicatorID AS KEDBUpdatedMapID,
				DARTTM.KEDBPath AS KEDBPath,
				ISNULL(PMP.PriorityIDMapID, 0) AS PriorityMapID,
				RTY.ReleaseTypeID AS ReleaseTypeMapID,
				SVR.SeverityIDMapID AS SeverityMapID,
				SMP.SourceIDMapID AS TicketSourceMapID,
				PSM.StatusID AS TicketStatusMapID,
				TTMP.TicketTypeMappingID AS TicketTypeMapID,
				SourceDepartment AS BusinessSourceName,
				NULL AS Onsite_Offshore,
				ISNULL(DARTTM.PlannedEffort, 0.00) AS PlannedEffort,
				ISNULL(DARTTM.EstimatedWorkSize, 0.00) AS EstimatedWorkSize,
				0 AS ActualEffort,
				ISNULL(DARTTM.ActualWorkSize, 0.00) AS ActualWorkSize,
				DARTTM.Resolvedby AS Resolvedby,
				NULL AS Closedby,
				CASE WHEN ISNULL(DARTTM.ElevateFlagInternal, '') = 'Y' THEN 1 ELSE 0 END AS ElevateFlagInternal,
				DARTTM.RCAID,
				ISNULL(DARTTM.PlannedDuration, 0.00),
				ISNULL(DARTTM.Actualduration, 0.00),
				DARTTM.TicketSummary AS TicketSummary,
				DARTTM.NatureOfTheTicket AS NatureoftheTicket,
				CASE WHEN ISNULL(DARTTM.Comments, '') = '' THEN 'BusinessImpact_' + DARTTM.BusinessImpact 
					 ELSE DARTTM.Comments END Comments,
				DARTTM.RepeatedIncident AS RepeatedIncident,
				DARTTM.RelatedTickets AS RelatedTickets,
				'Migrated' AS TicketCreatedBy,
				SecAssignee AS SecondaryResources,
				DARTTM.EscalatedFlagCustomer,
				DARTTM.ReasonforRejection,
				AF.AvoidableFlagID AS AvoidableFlag,
				DARTTM.ReleaseDate,
				(GETDATE() - 1) AS TicketCreateDate,
				PlannedStartDateandTime AS PlannedStartDate,
				DARTTM.PlannedEndDate AS PlannedEndDate,
				DARTTM.ActualStartdateTime AS ActualStartdateTime,
				CASE WHEN ISNULL(DARTTM.ActualEnddateTime,'') = '' THEN DARTTM.ReleaseDate 
					 ELSE DARTTM.ActualEnddateTime END AS ActualEnddateTime,
				OpenDate AS OpenDateTime,
				DARTTM.StartedDateTime AS StartedDateTime,
				DARTTM.WIPDateTime AS WIPDateTime,
				DARTTM.OnHoldDateTime AS OnHoldDateTime,
				CASE WHEN ISNULL(DARTTM.CompletedDateTime, '') = '' THEN DARTTM.Resolveddate 
					 ELSE DARTTM.CompletedDateTime END AS CompletedDateTime,
				ReopenDate AS ReopenDateTime,
				DARTTM.CancelledDateTime AS CancelledDateTime,
				RejectedTimeStamp AS RejectedDateTime,
				CloseDate AS Closeddate,
				AssignedTimeStamp AS AssignedDateTime,
				CASE WHEN ISNULL(DARTTM.OutageDuration, '') = '' THEN 0 ELSE CAST(DARTTM.OutageDuration AS DECIMAL(9,2)) END,
				CASE WHEN ISNULL(MetResponseSLA, '') = 'Y' THEN 1  
					 WHEN ISNULL(MetResponseSLA, '') = 'N' THEN 2  
					 ELSE NULL END AS MetResponseSLAMapID,
				CASE WHEN ISNULL(MetAcknowledgementSLA, '') = 'Y' THEN 1 
					 WHEN ISNULL(MetAcknowledgementSLA, '') = 'N' THEN 2 
					 ELSE NULL END AS MetAcknowledgementSLAMapID,
				CASE WHEN ISNULL(MetResolution, '') = 'Y' THEN 1  
					 WHEN ISNULL(MetResolution, '') = 'N' THEN 2  
					 ELSE 
						CASE WHEN ISNULL(DARTTM.SlaMiss, '') = 'Y' OR ISNULL(DARTTM.SlaMiss, '') = 'MISS_6' THEN 2  
							 WHEN ISNULL(DARTTM.SlaMiss, '') = 'N' OR ISNULL(DARTTM.SlaMiss, '') = 'NO' THEN 1  
					         ELSE NULL END
					 END AS MetResolutionMapID,
				0 AS EscalationSLA,
				0 AS TKBusinessID,
				NULL AS InscopeOutscope,
				CASE WHEN ISNULL(DARTTM.IsAttributeUpdated, '') = 'N' THEN 0 ELSE 1 END AS IsAttributeUpdated,
				DARTTM.NewStatusDateTime AS NewStatusDateTime,
				ISNULL(DARTTM.IsSDTicket, 0) AS IsSDTicket,
				CASE WHEN DARTTM.IsManual = 'Y' THEN 1 ELSE 0 END AS IsManual,
				DSTS.DARTStatusID AS DARTStatusID,				
				CASE WHEN ISNULL(DARTTM.ResolutionMethod, '') = '' THEN RootCause 
					 ELSE ResolutionMethod END ResolutionRemarks,
				NULL AS ITSMEffort,
				'Migrated' AS CreatedBy,
				(GETDATE() - 1) AS CreatedDate,
				(GETDATE() - 1) AS LastUpdatedDate,
				NULL AS ModifiedBy,
				NULL AS ModifiedDate,
				DARTTM.IsApproved as IsApproved,
				--CASE WHEN ISNULL(DARTTM.IsApproved, '') = 'Y' THEN 1 ELSE 0 END IsApproved,
				NULL AS ReasonResidualMapID,
				NULL AS ExpectedCompletionDate,
				NULL AS ApprovedBy,
				NULL AS DAPId,
				NULL AS DebtClassificationMode
	FROM @ProjectDetails PD
	JOIN #DARTTicketDetails DARTTM ON DARTTM.ProjectID = PD.ProjectID
	JOIN AVL.TK_MAP_PriorityMapping (NOLOCK) PMP
		ON PMP.PriorityName = DARTTM.PriorityName AND pmp.ProjectID = PD.AppLensProjectID
			AND PMP.IsDeleted = (CASE WHEN DARTTM.PriorityIsDeleted = 'Y' THEN 1 ELSE 0 END) 		
	JOIN AVL.TK_MAS_DARTTicketStatus (NOLOCK) DSTS
		ON DSTS.DARTStatusName = DARTTM.DARTStatusName
		JOIN #AppLensBusinessClusterMapping (NOLOCK) BC 
		ON  BC.CustomerID = PD.AppLensCustomerID AND BC.IsHavingSubBusinesss = 0 -----Duplicate application name
   	       JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AP
		ON BC.[BusinessClusterMapID] = AP.SubBusinessClusterMapID AND AP.ApplicationName = DARTTM.ApplicationName AND AP.IsActive = 1 
	      JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APM 
		ON APM.ApplicationID = AP.ApplicationID AND APM.ProjectID = PD.AppLensProjectID		
	----JOIN #AppLensBusinessClusterMapping (NOLOCK) BC 
	----	ON  BC.CustomerID = PD.AppLensCustomerID AND BC.IsHavingSubBusinesss = 0 -----Duplicate application name
 --  	JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AP
	--	ON --BC.[BusinessClusterMapID] = AP.SubBusinessClusterMapID AND 
	--	AP.ApplicationName = DARTTM.ApplicationName 
	--	--AND AP.IsActive = 1
	--JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APM 
	--	ON APM.ApplicationID = AP.ApplicationID AND APM.ProjectID = PD.AppLensProjectID 
	--	--AND APM.IsDeleted = 0
    LEFT JOIN AVL.TK_MAP_ProjectStatusMapping (NOLOCK) PSM
		ON PSM.StatusName = DARTTM.StatusName AND PSM.ProjectID = PD.AppLensProjectID 
			AND PSM.IsDeleted = (CASE WHEN DARTTM.ProjectStatusIsDeleted = 'Y' THEN 1 ELSE 0 END) 
	LEFT JOIN AVL.TK_MAP_TicketTypeMapping (NOLOCK) TTMP
		ON TTMP.TicketType = DARTTM.TicketTypeName AND TTMP.ProjectID = PD.AppLensProjectID 
			AND TTMP.IsDeleted = (CASE WHEN DARTTM.TicketTypeIsDeleted = 'Y' THEN 1 ELSE 0 END) 
	LEFT JOIN AVL.MAS_LoginMaster (NOLOCK) LM
		ON CONVERT(VARCHAR(MAX), LM.EmployeeID) = DARTTM.AssigneeCognizantID 
		AND LM.ProjectID = PD.AppLensProjectID AND LM.CustomerID=PD.AppLensCustomerID	
	LEFT JOIN AVL.TK_MAS_Service (NOLOCK) SM
		ON SM.ServiceName = DARTTM.ServiceName
	LEFT JOIN AVL.DEBT_MAP_CauseCode (NOLOCK) DC 
		ON DC.CauseCode = DARTTM.CauseCode AND DC.ProjectID = PD.AppLensProjectID
	LEFT JOIN AVL.DEBT_MAS_DebtClassification (NOLOCK) DCL
		ON DCL.DebtClassificationName = DARTTM.DebtClassificationName
	LEFT JOIN AVL.DEBT_MAS_ResidualDebt (NOLOCK) RD
		ON RD.ResidualDebtName = DARTTM.ResidualDebtName
	LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator (NOLOCK) KEDB
		ON KEDB.KEDBAvailableIndicatorName = DARTTM.KEDBAvailableIndicatorName
	LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator (NOLOCK) KEDBU
		ON KEDBU.KEDBAvailableIndicatorName = DARTTM.KEDBUpdatedName
	LEFT JOIN AVL.TK_MAS_ReleaseType (NOLOCK) RTY
		ON RTY.ReleaseTypeName = DARTTM.ReleaseTypeName
	LEFT JOIN AVL.TK_MAP_SeverityMapping (NOLOCK) SVR
		ON SVR.SeverityName = DARTTM.SeverityName AND SVR.ProjectID = PD.AppLensProjectID
	LEFT JOIN AVL.DEBT_MAS_AvoidableFlag (NOLOCK) AF
		ON AF.AvoidableFlagName = DARTTM.AvoidableFlagName
	LEFT JOIN AVL.DEBT_MAP_ResolutionCode (NOLOCK) RC
		ON RC.ResolutionCode = DARTTM.ResolutionCode1 AND RC.ProjectID = PD.AppLensProjectID
	LEFT JOIN AVL.TK_MAP_SourceMapping (NOLOCK) SMP
		ON SMP.SourceName = DARTTM.SourceName AND SMP.ProjectID = PD.AppLensProjectID
		AND SMP.IsFixedSource = DARTTM.IsFixedSource --Added by annadurai on 13/18/2018 for unique key constrains
	LEFT JOIN #AppLensTicketMaster ALTD 
		ON ALTD.ProjectID = PD.AppLensProjectID AND ALTD.TicketID = DARTTM.TicketID				
	WHERE ALTD.TicketID IS NULL 


	PRINT 'Pushing Tickets - End'

	
	--------------------------------- PUSH TIMESHEET TABLE ------------------------------------

	PRINT 'Pushing Timesheet - Start'

    SELECT DTS.* 
	INTO #TimeSheetNew 
	FROM AVMDART.PRJ.Timesheet (NOLOCK) DTS
	JOIN @ProjectDetails P ON DTS.ProjectID = P.ProjectID 
	WHERE DTS.TimesheetDate >= '2018-07-01'


	SELECT DTD.* 
	INTO #TimesheetDetailNew 
	FROM AVMDART.TRN.TimesheetDetail (NOLOCK) DTD 
	INNER JOIN @ProjectDetails PD
		ON DTD.ProjectID = PD.ProjectID  
	JOIN #TimeSheetNew DT 
		ON DT.TimesheetId = DTD.TimesheetId AND DTD.ProjectId = DT.ProjectId	

	SELECT ATM.* 
	INTO #AppLensTimesheet 
	FROM AVL.TM_PRJ_Timesheet (NOLOCK) ATM
	JOIN @ProjectDetails PD 
		ON PD.AppLensProjectID = ATM.ProjectID

	SELECT ATM.* 
	INTO #AppLensTimesheetDetail 
	FROM AVL.TM_TRN_TimesheetDetail (NOLOCK) ATM
	JOIN @ProjectDetails PD 
		ON PD.AppLensProjectID = ATM.ProjectID 
	
	INSERT INTO AVL.TM_PRJ_Timesheet
	(
		ProjectID,
		SubmitterId,
		TimesheetDate,
		StatusId,
		ApprovedBy,
		UnfreezedBy,
		UnfreezedDate,
		CreatedBy,
		CreatedDateTime,
		ModifiedBy,
		ModifiedDateTime,
		IsAutosubmit,
		RejectionComments,
		ApprovedDate,
		TSRegion,
		CustomerID,
		IsNonTicket
	)
	SELECT DISTINCT APM.ProjectId,
			ALM.UserID,
			DTS.TimesheetDate,
			ATSS.TimesheetStatusId,
			DTS.ApprovedBy AS ApprovedBy,
			DTS.UnfreezedBy AS UnfreezedBy,
			DTS.UnfreezedDate,
			'Migrated' AS CreatedBy,
			GETDATE() AS CreatedDateTime,
			NULL AS ModifiedBy,
			NULL AS ModifiedDateTime,
			DTS.IsAutosubmit,
			DTS.RejectionComments,
			DTS.ApprovedDate,
			DTS.TSRegion,
			AC.CustomerID,
			0 AS IsNonTicket
	FROM  @ProjectDetails P 
	JOIN #TimeSheetNew  DTS	
	    ON P.ProjectID = DTS.ProjectID	
	JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APM
		ON APM.EsaProjectID = P.EsaProjectID
	JOIN AVMDART.[MAS].[TimesheetStatus] (NOLOCK) DTSS
		ON DTSS.TimesheetStatusId = DTS.StatusId
	JOIN  [AVL].[Customer] (NOLOCK) AC
		ON AC.CustomerID = APM.CustomerID
	LEFT JOIN AVMDART.[PRJ].[LoginMaster] (NOLOCK) DLM
		ON DLM.UserID = DTS.SubmitterId 
	LEFT JOIN [AVL].[MAS_LoginMaster] (NOLOCK) ALM
		ON ALM.EmployeeID = DLM.cognizantID AND ALM.ProjectID = APM.ProjectID AND ALM.CustomerID=P.AppLensCustomerID
	LEFT JOIN AVL.MAS_TimesheetStatus (NOLOCK) ATSS 
		ON ATSS.TimesheetStatus = (CASE WHEN DTSS.TimesheetStatus = 'Unfreezed' THEN 'Unfrozen' ELSE DTSS.TimesheetStatus END)
    LEFT JOIN AVL.TM_PRJ_Timesheet (NOLOCK) ALTS 
		ON ALTS.ProjectID = APM.ProjectId AND ALTS.SubmitterId = ALM.UserID
			AND ALTS.TimesheetDate = DTS.TimesheetDate
	WHERE DTS.TimesheetDate >= '2018-07-01' AND ALTS.ProjectID IS NULL

	
	--PRINT 'Pushing Timesheet - End'
			
--	--------------------------------- PUSH TIMESHEET DETAILS TABLE ------------------------------------

	PRINT 'Pushing Timesheet Details - Start'

	SELECT ATM.* 
	INTO #AppLensMigratedTimesheet 
	FROM AVL.TM_PRJ_Timesheet (NOLOCK) ATM
	JOIN @ProjectDetails PD 
		ON PD.AppLensProjectID = ATM.ProjectID

	SELECT DISTINCT DARTTM.*, 
        DAM.ApplicationName,
		DLM.cognizantID,			
        DSM.ServiceName,
        DCM.CategoryName,
        DACM.ActivityName    
 	INTO #DARTTimesheetDetails
	From @ProjectDetails PD
	JOIN #TimesheetDetailNew DARTTM 
		ON PD.ProjectID = DARTTM.ProjectID
	JOIN #TimeSheetNew DT 
		ON DT.TimesheetId = DARTTM.TimesheetId AND DARTTM.ProjectId = DT.ProjectId		
	JOIN AVMDART.[PRJ].[LoginMaster] (NOLOCK) DLM
		ON DLM.UserID = DT.SubmitterId		
	LEFT JOIN AVMDART.MAS.ApplicationMaster (NOLOCK) DAM 
		ON DAM.ApplicationID = DARTTM.ApplicationID	
	LEFT JOIN AVMDART.MAP.ServiceProjectMapping(NOLOCK) DACM
		ON DACM.ProjectID = DARTTM.ProjectId AND DACM.ServiceID = DARTTM.ServiceID AND DACM.ActivityID = DARTTM.ActivityID	
			AND DACM.CategoryID = DARTTM.CategoryID	
		--and DACM.IsDeleted='N'
	LEFT JOIN AVMDART.[MAS].[ServiceMaster] (NOLOCK) DSM 
		ON DSM.ServiceID = DARTTM.ServiceID	
	LEFT JOIN AVMDART.MAS.CategoryMaster (NOLOCK) DCM 
		ON DCM.CategoryID = DARTTM.CategoryID	        
	LEFT JOIN AVMDART.MAS.TicketSourceMaster (NOLOCK) DTSM 
		ON DTSM.DARTTicketSourceID = 
		(CASE WHEN RTRIM(LTRIM(ISNULL(DARTTM.TicketSourceID, 0))) IN (' ', 'NULL', 'null') THEN 0 ELSE DARTTM.TicketSourceID END)	
	WHERE DT.TimesheetDate >= '2018-07-01'

	---- '2018-07-01'

    PRINT 'Insert Timesheet Details'

	SELECT DISTINCT DARTTD.TimeSheetDetailId,
			AT.TimesheetId,
            APPM.ApplicationID,
			0 AS shiftid,
			DARTTD.TicketNo,
            0 AS IsNonTicket,
            ASM.ServiceId,
            ACM.CategoryId,
			--CASE WHEN ASM.ServiceId IS NOT NULL AND SAM.ActivityId IS NULL THEN 116 ELSE AACM.ActivityId END AS ActivityId, ---added by anna on 17.11.2018
			CASE WHEN (ASM.ServiceId IS NOT NULL AND AACM.ActivityId IS NULL ) OR SAM.ActivityId IS NULL THEN 116 ELSE SAM.ActivityId END AS ActivityId, ---Applens activity id 
			DARTTD.Hours,
            DARTTD.Remarks,
            'Migrated' AS CreatedBy,
            GETDATE() AS CreatedDateTime,
            NULL AS ModifiedBy,
            NULL AS ModifiedDateTime,
            CASE WHEN DARTTD.IsAttributeUpdated = 'N' THEN 0 ELSE 1 END AS IsAttributeUpdated,
            '' AS TicketSourceID,  
            DARTTD.IsSDTicket,
            PD.AppLensProjectID,
		    ATD.TimeTickerID AS TimeTickerID,
            ATD.TicketTypeMapID AS TicketTypeMapID,
            0 AS IsDeleted
		INTO #AppLensTimesheetDetails
		FROM @ProjectDetails PD
		JOIN #DARTTimesheetDetails DARTTD ON DARTTD.ProjectId = PD.ProjectID		
		JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APM 
			ON APM.EsaProjectID = PD.EsaProjectID 
		JOIN #TimeSheetNew (NOLOCK) DT 
			ON DT.TimesheetId = DARTTD.TimesheetId	
		JOIN [AVL].[MAS_LoginMaster] (NOLOCK) ALM
			ON ALM.EmployeeID = DARTTD.cognizantID AND ALM.CustomerID=PD.AppLensCustomerID	
        JOIN #AppLensMigratedTimesheet (NOLOCK) AT
			ON AT.ProjectID = APM.ProjectID  
			AND AT.TimesheetDate = DT.TimesheetDate 
		    AND AT.SubmitterId = ALM.UserID 
			AND AT.CreatedBy = 'Migrated'			
	    JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AAM 
			ON AAM.ApplicationName = DARTTD.ApplicationName 
			--AND AAM.IsActive = 1
  --      JOIN #AppLensBusinessClusterMapping (NOLOCK) BC 
		--ON BC.[BusinessClusterMapID] = AAM.SubBusinessClusterMapID AND BC.CustomerID = PD.AppLensCustomerID AND BC.IsHavingSubBusinesss = 0 -----Duplicate application name
	    JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APPM 
			ON APPM.ApplicationID = AAM.ApplicationID AND APPM.ProjectID = APM.ProjectID AND APPM.IsDeleted = 0
	    JOIN AVL.TK_TRN_TicketDetail (NOLOCK) ATD 
			ON ATD.ProjectID = APM.ProjectID AND ATD.TicketID = DARTTD.TicketNo  
		LEFT JOIN [AVL].[MAS_ActivityMaster] (NOLOCK) AACM 
			ON AACM.ActivityName = DARTTD.ActivityName 
		LEFT JOIN [AVL].[TK_MAS_Service] (NOLOCK) ASM 
			ON ASM.ServiceName = DARTTD.ServiceName
		LEFT JOIN AVL.TK_MAS_ServiceActivityMapping (NOLOCK) SAM 
			ON SAM.ServiceName = DARTTD.ServiceName AND SAM.ActivityName = DARTTD.ActivityName ----added by anna on 17.11.2018
		LEFT JOIN AVL.MAS_CategoryMaster (NOLOCK) ACM 
			ON ACM.CategoryName = DARTTD.CategoryName 
		LEFT JOIN #AppLensTimesheetDetail (NOLOCK) ALTSD 
			ON ALTSD.TimesheetId = AT.TimesheetId AND ALTSD.ServiceId = ASM.ServiceId 
				AND ALTSD.ProjectId = AT.ProjectID AND ISNULL(ALTSD.ServiceId, '') <> 41 
		WHERE  ISNULL(DARTTD.ServiceId, '') <> 41 AND ALTSD.ProjectId IS NULL 

	   -- Insert into Project Service Activity Mapping Table
	   INSERT INTO AVL.TK_PRJ_ProjectServiceActivityMapping
	   (
			ServiceMapID,
			ProjectID,
			IsDeleted,
			CreatedDateTime,
			CreatedBY,
			ModifiedDateTime,
			ModifiedBY,
			IsHidden,
			EffectiveDate,
			IsMainspringData
	   )
	   SELECT DISTINCT SAM.ServiceMappingID, TSD.AppLensProjectID, SAM.IsDeleted, GETDATE(), 'Migrated', NULL, NULL, 0, NULL, NULL
	   FROM #AppLensTimesheetDetails TSD
	   JOIN AVL.TK_MAS_ServiceActivityMapping (NOLOCK) SAM
			ON SAM.ServiceID = TSD.ServiceID AND SAM.ActivityID = 116 AND SAM.IsDeleted = 0 -----left join was added by annadurai on 16.11.2018 
	   LEFT JOIN AVL.TK_PRJ_ProjectServiceActivityMapping (NOLOCK) PSAM
			ON PSAM.ProjectID = TSD.AppLensProjectID AND PSAM.ServiceMapID = SAM.ServiceMappingID 
	   WHERE TSD.ServiceID IS NOT NULL AND (TSD.ActivityID IS NULL OR TSD.ActivityID = 116) AND PSAM.ProjectID IS NULL

	   SELECT	TimesheetId,
				TicketNo,
				ServiceId,
				ActivityId,
				AppLensProjectID,
				SUM(Hours) AS Hours
	   INTO #GroupedTimesheetDetails
	   FROM #AppLensTimesheetDetails
	   GROUP BY TimesheetId, TicketNo, ServiceId, ActivityId, AppLensProjectID

		INSERT INTO AVL.TM_TRN_TimesheetDetail
		(
			TimesheetId,
			ApplicationID,
			ShiftId,
			TicketID,
			IsNonTicket,
			ServiceId,
			CategoryId,
			ActivityId,
			Hours,
			Remarks,
			CreatedBy,
			CreatedDateTime,
			ModifiedBy,
			ModifiedDateTime,
			IsAttributeUpdated,
			TicketSourceID,
			IsSDTicket,
			ProjectId,
			TimeTickerID,
			TicketTypeMapID,
			IsDeleted
		 )
		 SELECT	G.TimesheetId,
				(
					SELECT TOP 1 ApplicationID FROM #AppLensTimesheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketNo = G.TicketNo 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.AppLensProjectID = G.AppLensProjectID AND ApplicationID IS NOT NULL
				),
				0 AS ShiftId,
				TicketNo,
				0 AS IsNonTicket,
				ServiceId,
				(
					SELECT TOP 1 CategoryId FROM #AppLensTimesheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketNo = G.TicketNo 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.AppLensProjectID = G.AppLensProjectID AND CategoryId IS NOT NULL
				),
				ActivityId,
				Hours,
				(
					SELECT TOP 1 Remarks FROM #AppLensTimesheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketNo = G.TicketNo 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.AppLensProjectID = G.AppLensProjectID AND Remarks IS NOT NULL
				),
			    'Migrated' AS CreatedBy,
				GETDATE() AS CreatedDateTime,
				NULL AS ModifiedBy,
				NULL AS ModifiedDateTime,
				(
					SELECT TOP 1 IsAttributeUpdated FROM #AppLensTimesheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketNo = G.TicketNo 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.AppLensProjectID = G.AppLensProjectID AND IsAttributeUpdated IS NOT NULL
				),
				(
					SELECT TOP 1 TicketSourceID FROM #AppLensTimesheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketNo = G.TicketNo 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.AppLensProjectID = G.AppLensProjectID AND TicketSourceID IS NOT NULL
				),
				(
					SELECT TOP 1 IsSDTicket FROM #AppLensTimesheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketNo = G.TicketNo 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.AppLensProjectID = G.AppLensProjectID AND IsSDTicket IS NOT NULL
				),
				AppLensProjectID,
				(
					SELECT TOP 1 TimeTickerID FROM #AppLensTimesheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketNo = G.TicketNo 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.AppLensProjectID = G.AppLensProjectID AND TimeTickerID IS NOT NULL
				),
				(
					SELECT TOP 1 TicketTypeMapID FROM #AppLensTimesheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketNo = G.TicketNo 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.AppLensProjectID = G.AppLensProjectID AND TicketTypeMapID IS NOT NULL
				),
				0 AS IsDeleted
	   FROM #GroupedTimesheetDetails G

		PRINT 'Pushing Timesheet Details - End'
		
	-------------------------------------------- NON DELIVERY TICKETS ------------------------------------------
	----------------------------------- PUSH TIMESHEET DETAILS TABLE ------------------------------------

	 PRINT 'Pushing Non-Delivery Timesheet Details - Start'

	 SELECT DISTINCT DARTTD.TimeSheetDetailId,
			AT.TimesheetId,
            DARTTD.ApplicationID,
			DARTTD.TicketNo,
            ASM.ServiceId,
            ACM.CategoryId,
            ISNULL(AACM.ID, 8) ActivityID, ---Applens activity id 
            DARTTD.Hours,
            DARTTD.Remarks,
            CASE WHEN DARTTD.IsAttributeUpdated = 'N' THEN 0 ELSE 1 END IsAttributeUpdated,
            DARTTD.IsSDTicket,
            PD.AppLensProjectID
		INTO #NonDeliveryTimesheetDetails
		FROM @ProjectDetails PD
		JOIN #DARTTimesheetDetails DARTTD ON DARTTD.ProjectId = PD.ProjectID		
		JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APM 
			ON APM.EsaProjectID = PD.EsaProjectID 
		JOIN #TimeSheetNew (NOLOCK) DT 
			ON DT.TimesheetId = DARTTD.TimesheetId	
		JOIN [AVL].[MAS_LoginMaster] (NOLOCK) ALM
			ON ALM.EmployeeID = DARTTD.cognizantID AND ALM.CustomerID=PD.AppLensCustomerID		
        JOIN #AppLensMigratedTimesheet (NOLOCK) AT
			ON AT.ProjectID = APM.ProjectID AND AT.TimesheetDate = DT.TimesheetDate
				AND AT.SubmitterId = ALM.UserID AND AT.CreatedBy = 'Migrated' 			
  --      LEFT JOIN #AppLensBusinessClusterMapping (NOLOCK) BC 
		--	ON BC.CustomerID = PD.AppLensCustomerID AND BC.IsHavingSubBusinesss = 0 -----Duplicate application name
		--LEFT JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AAM 
		--	ON AAM.ApplicationName = DARTTD.ApplicationName AND AAM.SubBusinessClusterMapID = BC.[BusinessClusterMapID]
		--LEFT JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APPM 
		--	ON APPM.ApplicationID = AAM.ApplicationID AND APPM.ProjectID = APM.ProjectID
		LEFT JOIN AVL.MAS_NonDeliveryActivity (NOLOCK) AACM 
			ON AACM.NonTicketedActivity = CASE  WHEN DARTTD.ActivityName = 'Leave' OR DARTTD.ActivityName = 'Holiday' THEN 'Leave/Holiday' 
												WHEN DARTTD.ActivityName = 'Organizational Activity' THEN 'Organization Activity'
												ELSE DARTTD.ActivityName END 
		LEFT JOIN [AVL].[TK_MAS_Service] (NOLOCK) ASM 
			ON ASM.ServiceName = DARTTD.ServiceName
		LEFT JOIN AVL.MAS_CategoryMaster (NOLOCK) ACM 
			ON ACM.CategoryName = DARTTD.CategoryName        
		LEFT JOIN #AppLensTimesheetDetail (NOLOCK) ALTSD 
			ON ALTSD.TimesheetId = AT.TimesheetId AND ALTSD.ServiceId = ASM.ServiceId 
				AND ALTSD.ProjectId = AT.ProjectID and ISNULL(ALTSD.ServiceId, '') = 41 
		WHERE  ISNULL(DARTTD.ServiceId, '') = 41 AND ALTSD.ProjectId IS NULL 

		INSERT INTO AVL.TM_TRN_TimesheetDetail
		(
			TimesheetId,
			ApplicationID,
			ShiftId,
			TicketID,
			IsNonTicket,
			ServiceId,
			CategoryId,
			ActivityId,
			Hours,
			Remarks,
			CreatedBy,
			CreatedDateTime,
			ModifiedBy,
			ModifiedDateTime,
			IsAttributeUpdated,
			TicketSourceID,
			IsSDTicket,
			ProjectId,
			TimeTickerID,
			TicketTypeMapID,
			IsDeleted
		)
		SELECT TimesheetId,
            NULL,
			NULL,
			'NonDelivery',
            1,
            ServiceId,
            NULL,
            ActivityID, 
            SUM(Hours),
            (
				SELECT TOP 1 NSTD1.Remarks FROM #NonDeliveryTimesheetDetails NSTD1 
				WHERE NSTD1.TimesheetId = NSTD.TimesheetId AND NSTD1.ServiceID = NSTD.ServiceID
					AND NSTD1.ActivityID = NSTD.ActivityID AND NSTD1.AppLensProjectID = NSTD.AppLensProjectID
			),
            'Migrated',
            GETDATE(),
            NULL,
            NULL,
            NULL,
            NULL,  
            NULL,
            AppLensProjectID,
		    0,
            0,
            0
		FROM #NonDeliveryTimesheetDetails NSTD
		GROUP BY TimesheetId, TicketNo, ServiceID, ActivityID,  AppLensProjectID

		PRINT 'Pushing Non-Delivery Timesheet Details - End'

		DROP TABLE #NonDeliveryTimesheetDetails

		-----------------------------------------------------------------------------------------------------------

		-- Log the Ticketing Module migration is successful for the respective account.
		IF @IsIncrementalProject = 1
		BEGIN
			
			UPDATE DataMigrationLogInc
			SET TicketingModuleStatus = 'S', TicketingModuleErrorMessage = NULL
			WHERE AccountID = @AccountId AND ESAProjectID = @ESAProjectIDs

		END
		ELSE 
		BEGIN

			UPDATE DataMigrationLog
			SET TicketingModuleStatus = 'S', TicketingModuleErrorMessage = NULL
			WHERE AccountID = @AccountId AND ESAProjectID = @ESAProjectIDs

		END

		DROP TABLE #AppLensBusinessClusterMapping
		DROP TABLE #AppLensMigratedTimesheet
		DROP TABLE #TicketMasterFromJuly
		DROP TABLE #TimeSheetDetailsTicketMaster
		DROP TABLE #LeftOutTicketMaster
		DROP TABLE #AppLensTicketMaster
		DROP TABLE #AppLensTimesheet
		DROP TABLE #AppLensTimesheetDetail
		DROP TABLE #AppLensTimesheetDetails
		DROP TABLE #DARTTicketDetails
		DROP TABLE #DARTTimesheetDetails
		DROP TABLE #GroupedTimesheetDetails
		DROP TABLE #TicketMasterNew
		DROP TABLE #TimesheetDetailNew
		DROP TABLE #TimeSheetNew

	    COMMIT TRAN

  END TRY
  BEGIN CATCH
	
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage AS ErrorMessage
              
		ROLLBACK TRAN

		IF @IsIncrementalProject = 1
		BEGIN

			-- Log the Error in Data Migration Log Table.   
			UPDATE DataMigrationLogInc SET TicketingModuleStatus = 'F', TicketingModuleErrorMessage = @ErrorMessage
			WHERE AccountID = @AccountId AND ESAProjectID = @ESAProjectIDs

		END
		ELSE
		BEGIN

			-- Log the Error in Data Migration Log Table.   
			UPDATE DataMigrationLog SET TicketingModuleStatus = 'F', TicketingModuleErrorMessage = @ErrorMessage
			WHERE AccountID = @AccountId AND ESAProjectID = @ESAProjectIDs

		END

  END CATCH

END
