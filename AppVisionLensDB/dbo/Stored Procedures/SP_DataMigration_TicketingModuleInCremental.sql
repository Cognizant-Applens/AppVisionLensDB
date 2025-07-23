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
-- Create date: 24 Aug 2018
-- Description: Migration of Incremental Ticketing Module
-- AppVisionLens - App Lens DB, [AVMDART_Migration] - AVM DART DB
-- Test: EXEC SP_DataMigration_TicketingModuleInCremental '1205421', '1000171278'
-- =======================================================================================  

CREATE PROCEDURE [dbo].[SP_DataMigration_TicketingModuleInCremental]
(
       @AccountId BIGINT, -- ESA Account ID
       @ESAProjectIDs NVARCHAR(MAX) -- ESA Project IDs
)
AS
BEGIN
  
	IF OBJECT_ID (N'DataMigrationIncLog', N'U') IS NULL 
	BEGIN

		CREATE TABLE DataMigrationIncLog
		(
			ID BIGINT IDENTITY(1, 1),
			AccountID BIGINT,
			ESAProjectIDs NVARCHAR(MAX),
			TicketingModuleStatus CHAR(1) NULL, -- Holds 'S' - Success, 'F' - Failure
			TicketingModuleErrorMessage NVARCHAR(MAX) NULL,
			CreatedDateTime DATETIME NULL,
			ModifiedDateTime DATETIME NULL
		)

	END

	IF NOT EXISTS (SELECT TOP 1 AccountID FROM DataMigrationIncLog (NOLOCK) WHERE AccountID = @AccountId AND ESAProjectIDs = @ESAProjectIDs)
	BEGIN

		INSERT INTO DataMigrationIncLog VALUES (@AccountId, @ESAProjectIDs, NULL, NULL, GETDATE(), NULL)

	END

    BEGIN TRY
       BEGIN TRAN
          
			---------- Get all projects or specific project(s) for the Accounts ----------
			SELECT Item AS ESAProjectID INTO #ESAProjectIds FROM dbo.Split(@ESAProjectIDs, ',')

			DECLARE @ProjectDetails TABLE 
            ( 
                AccountID INT,
                AccountName NVARCHAR(MAX),
                ProjectID INT,
                EsaProjectID NVARCHAR(MAX),
                ProjectName VARCHAR(MAX),
                AppLensProjectID BIGINT
            )

            INSERT INTO @ProjectDetails
                     SELECT DISTINCT  DA.AccountID AS AccountID,
                                  AccountName,
                                  PM.ProjectID,
                                  PM.EsaProjectID,
                                  PM.ProjectName,
                                  APLPM.ProjectID  
                     FROM AVMDART.MAS.ProjectMaster  PM
                     JOIN AVMDART.[MAP].[DeptAcctMapping]  DA 
                           ON DA.AccountID = @AccountId AND DA.DeptAccountID = PM.DeptAccountID
                                  AND DA.IsDeleted = 'N' AND PM.IsDeleted = 'N'
                     JOIN AVL.Customer (NOLOCK) CUST
                           ON CUST.ESA_AccountID = DA.AccountID AND CUST.IsDeleted = 0
                     JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APLPM
                           ON APLPM.EsaProjectID = PM.EsaProjectID AND APLPM.IsDeleted = 0
                     WHERE @ESAProjectIDs IS NULL OR PM.EsaProjectID IN (SELECT ESAProjectID FROM #ESAProjectIds)

              DROP TABLE #ESAProjectIds

              ------------------------------- PUSH TICKET DETAILS (MASTER) TABLE ------------------------------------

              -- Resolveddate -> If Completed Date Time IS NULL
              -- SlaMiss -> If Met Resolution IS NULL
              -- ReleaseDate -> If Actual End date Time IS NULL
              -- RootCause -> If Resolution Remarks IS NULL
              -- BusinessImpact -> If Comments IS NULL. Append BusinessImpact_ with Value

              SELECT TM.* 
			  INTO #TicketMasterNew 
			  FROM AVMDART.PRJ.TicketMaster TM 
              JOIN @ProjectDetails PD ON PD.ProjectID = TM.ProjectID
			  JOIN AVMDART_MigratedProjectsInfo (NOLOCK) MP ON MP.DARTProjectID = TM.ProjectID 
              WHERE TM.C2TicketLastModifiedTimesstamp >= MP.MigratedDate 
                     AND OpenDate >= '2018-01-01' AND ISNULL(TM.IsDeleted, 'N') = 'N' 

			  UPDATE TM SET Assignee = LM.UserID
			  FROM #TicketMasterNew TM
			  JOIN AVMDART.PRJ.LoginMaster (NOLOCK) LM ON LM.CognizantName = TM.Assignee
			  WHERE Assignee = CognizantName

			  SELECT DISTINCT DARTTM.TicketID,
                           ISNULL(APM.ApplicationID, 0) AS ApplicationID,
                           PM.ProjectID,
                           ISNULL(LM.UserID, 0) AS AssignedTo,
                           NULL AS AssignmentGroup,
                           CASE WHEN ISNULL(DARTTM.EffortTillDate, 0) <> 0 THEN DARTTM.EffortTillDate ELSE 0.0 END AS EffortTillDate,
                           CASE WHEN ISNULL(SM.ServiceID, 0) <> 0 THEN SM.ServiceID ELSE 0 END ServiceID,
                           ISNULL(DARTTM.TicketDescription, '') TicketDescription,
                           0 AS IsDeleted,
                           ISNULL(DC.CauseID, 0) AS CauseCodeMapID,
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
                           ISNULL(DARTTM.PlannedDuration, 0.00) as PlannedDuration,
                           ISNULL(DARTTM.Actualduration, 0.00) as Actualduration,
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
                           GETDATE() AS TicketCreateDate,
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
                           CASE WHEN ISNULL(DARTTM.OutageDuration, '') = '' THEN 0 ELSE CAST(DARTTM.OutageDuration AS DECIMAL(9,2)) END  OutageDuration,
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
                           GETDATE() AS CreatedDate,
                           GETDATE() AS LastUpdatedDate,
                           NULL AS ModifiedBy,
                           NULL AS ModifiedDate,
                           CASE WHEN ISNULL(DDTD.IsApproved, '') = 'Y' THEN 1 ELSE 0 END IsApproved,
                           NULL AS ReasonResidualMapID,
                           NULL AS ExpectedCompletionDate,
                           NULL AS ApprovedBy,
                           NULL AS DAPId,
                           NULL AS DebtClassificationMode 
			   INTO #TicketMaster
			   FROM #TicketMasterNew DARTTM 
			   JOIN AVMDART.MAS.ProjectMaster DARTPM
					  ON DARTPM.ProjectID = DARTTM.ProjectID
			   JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
					  ON PM.EsaProjectID = DARTPM.EsaProjectID        
			   JOIN AVMDART.PRJ.PriorityMaster DARTPMP 
					  ON  DARTPMP.PriorityID = DARTTM.PriorityID AND DARTPMP.ProjectID = DARTTM.ProjectID
			   JOIN AVL.TK_MAP_PriorityMapping (NOLOCK) PMP
					  ON PMP.PriorityName = DARTPMP.PriorityName AND pmp.ProjectID = pm.ProjectID 
							AND PMP.IsDeleted = (CASE WHEN DARTPMP.IsDeleted = 'Y' THEN 1 ELSE 0 END) 
			   JOIN AVMDART.MAS.DARTStatus  DRTSTS 
                      ON DRTSTS.DARTSatusID = DARTTM.DARTStatusID
			   JOIN AVL.TK_MAS_DARTTicketStatus (NOLOCK) DSTS
                      ON DSTS.DARTStatusName = DRTSTS.DARTStatusName
			   JOIN AVMDART.MAS.ApplicationMaster  DARTAP 
                      ON DARTAP.ApplicationID = DARTTM.ApplicationID                
			   JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AP
                      ON AP.ApplicationName = DARTAP.ApplicationName AND AP.IsActive = 1
               JOIN [AVL].[BusinessClusterMapping] (NOLOCK) BC 
					  ON BC.[BusinessClusterMapID] = AP.SubBusinessClusterMapID AND BC.IsHavingSubBusinesss = 0 
			   JOIN [AVL].[Customer] (NOLOCK) C 
					  ON C.customerid = BC.customerid AND c.CustomerID = PM.CustomerID
			   JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APM 
					  ON APM.ApplicationID = AP.ApplicationID AND APM.ProjectID = PM.ProjectID
			   LEFT JOIN AVMDART.PRJ.StatusMaster  DRTSTSM
					  ON DRTSTSM.StatusID = DARTTM.StatusID AND DRTSTSM.ProjectID = DARTTM.ProjectID
			   LEFT JOIN AVL.TK_MAP_ProjectStatusMapping (NOLOCK) PSM
                      ON PSM.StatusName = DRTSTSM.StatusName AND PSM.ProjectID = PM.ProjectID 
							   AND PSM.IsDeleted = (CASE WHEN DRTSTSM.IsDeleted = 'Y' THEN 1 ELSE 0 END) 
			   LEFT JOIN AVMDART.PRJ.TicketTypeMapping  DARTTY
					  ON DARTTY.TicketTypeMappingID = DARTTM.TicketType AND DARTTY.ProjectID = DARTTM.ProjectID
			   LEFT JOIN AVL.TK_MAP_TicketTypeMapping (NOLOCK) TTMP
					  ON TTMP.TicketType = DARTTY.TicketType AND TTMP.ProjectID = PM.ProjectID
			   LEFT JOIN AVMDART.PRJ.DebtApprovedTicketDetails  DDTD
					  ON DDTD.ProjectId = DARTTM.ProjectID AND DDTD.TicketId = DARTTM.TicketID
			   LEFT JOIN AVMDART.PRJ.LoginMaster (NOLOCK)  DARTLM
					  --ON convert(varchar(max),DARTLM.UserID) = DARTTM.Assignee
					  ON DARTLM.UserID = DARTTM.Assignee
			   LEFT JOIN AVL.MAS_LoginMaster (NOLOCK) LM
					  ON LM.EmployeeID = DARTLM.cognizantID AND LM.ProjectID = PM.ProjectID
			   LEFT JOIN AVMDART.MAS.ServiceMaster  DARTSM
					  ON DARTSM.ServiceID = DARTTM.ServiceID
			   LEFT JOIN AVL.TK_MAS_Service (NOLOCK) SM
					  ON SM.ServiceName = DARTSM.ServiceName
			   LEFT JOIN AVMDART.MAS.DeptCauseCode  DARTDC
					  ON DARTDC.CauseID = DARTTM.TicketLocation
			   LEFT JOIN AVL.DEBT_MAP_CauseCode (NOLOCK) DC 
					  ON DC.CauseCode = DARTDC.CauseCode AND DC.ProjectID = PM.ProjectID
			   LEFT JOIN AVMDART.MAS.AttributeFieldMAster  DARTAM
					  ON DARTAM.Id = DARTTM.DebtClassificationId
			   LEFT JOIN AVL.DEBT_MAS_DebtClassification (NOLOCK) DCL
					  ON DCL.DebtClassificationName = DARTAM.AttributeTypeValue
			   LEFT JOIN AVMDART.MAS.AttributeFieldMAster  DARTATM
					  ON DARTATM.Id = DARTTM.ResidualDebt
			   LEFT JOIN AVL.DEBT_MAS_ResidualDebt (NOLOCK) RD
					  ON RD.ResidualDebtName = DARTATM.AttributeTypeValue
			   LEFT JOIN AVMDART.MAS.AttributeFieldMAster  DARTKEDB
					  ON DARTKEDB.ID = DARTTM.KEDBAvailableIndicator
			   LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator (NOLOCK) KEDB
					  ON KEDB.KEDBAvailableIndicatorName = DARTKEDB.AttributeTypeValue
			   LEFT JOIN AVMDART.MAS.AttributeFieldMAster  DTKEDB
					  ON DTKEDB.ID = DARTTM.KEDBUpdated
			   LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator (NOLOCK) KEDBU
					  ON KEDBU.KEDBAvailableIndicatorName = DTKEDB.AttributeTypeValue
			   LEFT JOIN AVMDART.MAS.AttributeFieldMAster  DTKRTY
					  ON DTKRTY.ID = DARTTM.ReleaseType
			   LEFT JOIN AVL.TK_MAS_ReleaseType (NOLOCK) RTY
					  ON RTY.ReleaseTypeName = DTKRTY.AttributeTypeValue
			   LEFT JOIN AVMDART.MAS.AttributeFieldMAster  DTKSVR
					  ON DTKSVR.ID = DARTTM.Severity
			   LEFT JOIN AVL.TK_MAP_SeverityMapping (NOLOCK) SVR
					  ON SVR.SeverityName = DTKRTY.AttributeTypeValue AND SVR.ProjectID = PM.ProjectID
			   LEFT JOIN AVMDART.MAS.AttributeFieldMAster  DRTAF
					  ON DRTAF.Id = DARTTM.AvoidableFlag
			   LEFT JOIN AVL.DEBT_MAS_AvoidableFlag (NOLOCK) AF
					  ON AF.AvoidableFlagName = DRTAF.AttributeTypeValue
			   LEFT JOIN AVMDART.MAS.DeptResolutionCode  DRTDRS
					  ON DRTDRS.ResolutionID = DARTTM.Reviewer AND DRTDRS.ProjectID = DARTTM.ProjectID
			   LEFT JOIN AVL.DEBT_MAP_ResolutionCode (NOLOCK) RC
					  ON RC.ResolutionCode = DRTDRS.ResolutionCode AND RC.ProjectID = PM.ProjectID
			   LEFT JOIN AVMDART.PRJ.ProjectSourceDetails  DRTPSD
					  ON DRTPSD.SourceID = DARTTM.Source AND DRTPSD.ProjectID = DARTTM.ProjectID
			   LEFT JOIN AVL.TK_MAP_SourceMapping (NOLOCK) SMP
					  ON SMP.SourceName = DRTPSD.SourceName AND SMP.ProjectID = PM.ProjectID 
						AND SMP.IsFixedSource = DRTPSD.IsFixedSource -- Added by annadurai on 13/18/2018 for unique key constrains
               
			  PRINT 'Insert / Update Ticket Master'

              MERGE AVL.TK_TRN_TicketDetail TD
              USING #TicketMaster TM
                     ON TM.ProjectID = TD.ProjectID AND TM.TicketID = TD.TicketID

              WHEN MATCHED THEN

              UPDATE SET 
                     TD.ApplicationID=TM.ApplicationID,
                     TD.AssignedTo=TM.AssignedTo,
                     TD.AssignmentGroup=TM.AssignmentGroup,
                     TD.EffortTillDate=TM.EffortTillDate,
                     TD.ServiceID=TM.ServiceID,
                     TD.TicketDescription=TM.TicketDescription,
                     TD.IsDeleted=TM.IsDeleted,
                     TD.CauseCodeMapID=TM.CauseCodeMapID,
                     TD.DebtClassificationMapID=TM.DebtClassificationMapID,
                     TD.ResidualDebtMapID=TM.ResidualDebtMapID,
                     TD.ResolutionCodeMapID=TM.ResolutionCodeMapID,
                     TD.ResolutionMethodMapID=TM.ResolutionMethodMapID,
                     TD.KEDBAvailableIndicatorMapID=TM.KEDBAvailableIndicatorMapID,
                     TD.KEDBUpdatedMapID=TM.KEDBUpdatedMapID,
                     TD.KEDBPath=TM.KEDBPath,
                     TD.PriorityMapID=TM.PriorityMapID,
                     TD.ReleaseTypeMapID=TM.ReleaseTypeMapID,
                     TD.SeverityMapID=TM.SeverityMapID,
                     TD.TicketSourceMapID=TM.TicketSourceMapID,
                     TD.TicketStatusMapID=TM.TicketStatusMapID,
                     TD.TicketTypeMapID=TM.TicketTypeMapID,
                     TD.BusinessSourceName=TM.BusinessSourceName,
                     TD.Onsite_Offshore=TM.Onsite_Offshore,
                     TD.PlannedEffort=TM.PlannedEffort,
                     TD.EstimatedWorkSize=TM.EstimatedWorkSize,
                     TD.ActualEffort=TM.ActualEffort,
                     TD.ActualWorkSize=TM.ActualWorkSize,
                     TD.Resolvedby=TM.Resolvedby,
                     TD.Closedby=TM.Closedby,
                     TD.ElevateFlagInternal=TM.ElevateFlagInternal,
                     TD.RCAID=TM.RCAID,
                     TD.PlannedDuration=TM.PlannedDuration,
                     TD.Actualduration=TM.Actualduration,
                     TD.TicketSummary=TM.TicketSummary,
                     TD.NatureoftheTicket=TM.NatureoftheTicket,
                     TD.Comments=TM.Comments,
                     TD.RepeatedIncident=TM.RepeatedIncident,
                     TD.RelatedTickets=TM.RelatedTickets,
                     TD.TicketCreatedBy=TM.TicketCreatedBy,
                     TD.SecondaryResources=TM.SecondaryResources,
                     TD.EscalatedFlagCustomer=TM.EscalatedFlagCustomer,
                     TD.ReasonforRejection=TM.ReasonforRejection,
                     TD.AvoidableFlag=TM.AvoidableFlag,
                     TD.ReleaseDate=TM.ReleaseDate,
                     TD.TicketCreateDate=TM.TicketCreateDate,
                     TD.PlannedStartDate=TM.PlannedStartDate,
                     TD.PlannedEndDate=TM.PlannedEndDate,
                     TD.ActualStartdateTime=TM.ActualStartdateTime,
                     TD.ActualEnddateTime=TM.ActualEnddateTime,
                     TD.OpenDateTime=TM.OpenDateTime,
                     TD.StartedDateTime=TM.StartedDateTime,
                     TD.WIPDateTime=TM.WIPDateTime,
                     TD.OnHoldDateTime=TM.OnHoldDateTime,
                     TD.CompletedDateTime=TM.CompletedDateTime,
                     TD.ReopenDateTime=TM.ReopenDateTime,
                     TD.CancelledDateTime=TM.CancelledDateTime,
                     TD.RejectedDateTime=TM.RejectedDateTime,
                     TD.Closeddate=TM.Closeddate,
                     TD.AssignedDateTime=TM.AssignedDateTime,                      
                     TD.MetResponseSLAMapID=TM.MetResponseSLAMapID,
                     TD.MetAcknowledgementSLAMapID=TM.MetAcknowledgementSLAMapID,
                     TD.MetResolutionMapID=TM.MetResolutionMapID,
                     TD.EscalationSLA=TM.EscalationSLA,
                     TD.TKBusinessID=TM.TKBusinessID,
                     TD.InscopeOutscope=TM.InscopeOutscope,
                     TD.IsAttributeUpdated=TM.IsAttributeUpdated,
                     TD.NewStatusDateTime=TM.NewStatusDateTime,
                     TD.IsSDTicket=TM.IsSDTicket,
                     TD.IsManual=TM.IsManual,
                     TD.DARTStatusID=TM.DARTStatusID,
                     TD.ResolutionRemarks=TM.ResolutionRemarks,
                     TD.ITSMEffort=TM.ITSMEffort,
                     TD.LastUpdatedDate=TM.LastUpdatedDate,                   
                     TD.IsApproved=TM.IsApproved,
                     TD.ReasonResidualMapID=TM.ReasonResidualMapID,
                     TD.ExpectedCompletionDate=TM.ExpectedCompletionDate,
                     TD.ApprovedBy=TM.ApprovedBy,
                     TD.DAPId=TM.DAPId,
                     TD.DebtClassificationMode=TM.DebtClassificationMode,
                     TD.ModifiedBy = 'Migrated',
                     TD.ModifiedDate = GETDATE()

              WHEN NOT MATCHED BY TARGET THEN
       
              INSERT 
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
              VALUES 
			  ( 
					TM.TicketID,
                    TM.ApplicationID,
                    TM.ProjectID,
                    TM.AssignedTo,
                    TM.AssignmentGroup,
                    TM.EffortTillDate,
                    TM.ServiceID,
                    TM.TicketDescription,
                    TM.IsDeleted,
                    TM.CauseCodeMapID,
                    TM.DebtClassificationMapID,
                    TM.ResidualDebtMapID,
                    TM.ResolutionCodeMapID,
                    TM.ResolutionMethodMapID,
                    TM.KEDBAvailableIndicatorMapID,
                    TM.KEDBUpdatedMapID,
                    TM.KEDBPath,
                    TM.PriorityMapID,
                    TM.ReleaseTypeMapID,
                    TM.SeverityMapID,
                    TM.TicketSourceMapID,
                    TM.TicketStatusMapID,
                    TM.TicketTypeMapID,
                    TM.BusinessSourceName,
                    TM.Onsite_Offshore,
                    TM.PlannedEffort,
                    TM.EstimatedWorkSize,
                    TM.ActualEffort,
                    TM.ActualWorkSize,
                    TM.Resolvedby,
                    TM.Closedby,
                    TM.ElevateFlagInternal,
                    TM.RCAID,
                    TM.PlannedDuration,
                    TM.Actualduration,
                    TM.TicketSummary,
                    TM.NatureoftheTicket,
                    TM.Comments,
                    TM.RepeatedIncident,
                    TM.RelatedTickets,
                    TM.TicketCreatedBy,
                    TM.SecondaryResources,
                    TM.EscalatedFlagCustomer,
                    TM.ReasonforRejection,
                    TM.AvoidableFlag,
                    TM.ReleaseDate,
                    TM.TicketCreateDate,
                    TM.PlannedStartDate,
                    TM.PlannedEndDate,
                    TM.ActualStartdateTime,
                    TM.ActualEnddateTime,
                    TM.OpenDateTime,
                    TM.StartedDateTime,
                    TM.WIPDateTime,
                    TM.OnHoldDateTime,
                    TM.CompletedDateTime,
                    TM.ReopenDateTime,
                    TM.CancelledDateTime,
                    TM.RejectedDateTime,
                    TM.Closeddate,
                    TM.AssignedDateTime,
                    TM.OutageDuration,
                    TM.MetResponseSLAMapID,
                    TM.MetAcknowledgementSLAMapID,
                    TM.MetResolutionMapID,
                    TM.EscalationSLA,
                    TM.TKBusinessID,
                    TM.InscopeOutscope,
                    TM.IsAttributeUpdated,
                    TM.NewStatusDateTime,
                    TM.IsSDTicket,
                    TM.IsManual,
                    TM.DARTStatusID,                         
                    TM.ResolutionRemarks,
                    TM.ITSMEffort,
                    TM.CreatedBy,
                    TM.CreatedDate,
                    TM.LastUpdatedDate,
                    TM.ModifiedBy,
                    TM.ModifiedDate,
                    TM.IsApproved,
                    TM.ReasonResidualMapID,
                    TM.ExpectedCompletionDate,
                    TM.ApprovedBy,
                    TM.DAPId,
                    TM.DebtClassificationMode 
             );
              
       -------------------------------------------------------------------------------------------
       --------------------------------- PUSH TIMESHEET TABLE ------------------------------------

       SELECT DTS.* 
       INTO #TimeSheetNew 
       FROM AVMDART.PRJ.Timesheet DTS
       JOIN @ProjectDetails P ON DTS.ProjectID = P.ProjectID 
	   JOIN AVMDART_MigratedProjectsInfo (NOLOCK) MP ON MP.DARTProjectID = DTS.ProjectID 
       WHERE (DTS.CreatedDateTime >= MP.MigratedDate OR DTS.ModifiedDateTime >= MP.MigratedDate)

       SELECT DISTINCT APM.ProjectId,
                     ALM.UserID as SubmitterId,
                     DTS.TimesheetDate,
                     ATSS.TimesheetStatusId as StatusId,
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
       INTO #TimeSheet
       FROM @ProjectDetails P 
       JOIN #TimeSheetNew  DTS    
              ON P.ProjectID = DTS.ProjectID    
       JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APM
              ON APM.EsaProjectID = P.EsaProjectID
       JOIN AVMDART.[MAS].[TimesheetStatus]  DTSS
              ON DTSS.TimesheetStatusId = DTS.StatusId
       JOIN [AVL].[Customer] (NOLOCK) AC
              ON AC.CustomerID = APM.CustomerID
       LEFT JOIN AVMDART.[PRJ].[LoginMaster]  DLM
              ON DLM.UserID = DTS.SubmitterId 
       LEFT JOIN [AVL].[MAS_LoginMaster] (NOLOCK) ALM
              ON ALM.EmployeeID = DLM.cognizantID AND ALM.ProjectID = APM.ProjectID
       LEFT JOIN AVL.MAS_TimesheetStatus (NOLOCK) ATSS 
              ON ATSS.TimesheetStatus = (CASE WHEN DTSS.TimesheetStatus = 'Unfreezed' THEN 'Unfrozen' ELSE DTSS.TimesheetStatus END)

       PRINT 'Insert / Update Timesheet'

       MERGE AVL.TM_PRJ_Timesheet TSH
       USING #TimeSheet TTS
		ON TTS.ProjectID = TSH.ProjectId AND TTS.SubmitterId = TSH.SubmitterId AND TTS.TimesheetDate = TSH.TimesheetDate 
              
	   WHEN MATCHED THEN
            UPDATE SET	TSH.StatusId=TTS.StatusId,
						TSH.ApprovedBy=TTS.ApprovedBy,
						TSH.UnfreezedBy=TTS.UnfreezedBy,
						TSH.UnfreezedDate=TTS.UnfreezedDate,
						TSH.CreatedBy=TTS.CreatedBy,
						TSH.CreatedDateTime=TTS.CreatedDateTime,
						TSH.ModifiedBy='Migrated',
						TSH.ModifiedDateTime=getdate(),
						TSH.IsAutosubmit=TTS.IsAutosubmit,
						TSH.RejectionComments=TTS.RejectionComments,
						TSH.ApprovedDate=TTS.ApprovedDate,
						TSH.TSRegion=TTS.TSRegion,
						TSH.CustomerID=TTS.CustomerID
                   
       WHEN NOT MATCHED BY TARGET THEN
		   INSERT
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
		   VALUES
		   (
                     TTS.ProjectId,
                     TTS.SubmitterId,
                     TTS.TimesheetDate,
                     TTS.StatusId,
                     TTS.ApprovedBy,
                     TTS.UnfreezedBy,
                     TTS.UnfreezedDate,
                     TTS.CreatedBy,
                     TTS.CreatedDateTime,
                     TTS.ModifiedBy,
                     TTS.ModifiedDateTime,
                     TTS.IsAutosubmit,
                     TTS.RejectionComments,
                     TTS.ApprovedDate,
                     TTS.TSRegion,
                     TTS.CustomerID,
                     TTS.IsNonTicket
		);
       
	   --------------------------------- PUSH TIMESHEET DETAILS TABLE ------------------------------------

	   -- Take the AVMDART Timesheets for which the timesheet details are modified
	   SELECT DISTINCT DTD.ProjectId, DTD.TimesheetId
	   INTO #ModifiedTimesheets
       FROM @ProjectDetails PD
	   JOIN AVMDART_MigratedProjectsInfo (NOLOCK) MP ON MP.DARTProjectID = PD.ProjectID
	   JOIN AVMDART.TRN.TimesheetDetail (NOLOCK) DTD 
			ON DTD.ProjectId = PD.ProjectID AND (DTD.CreatedDateTime >= MP.MigratedDate OR DTD.ModifiedDateTime >= MP.MigratedDate) 

       SELECT DTD.* 
	   INTO #TimesheetDetailNew 
       FROM @ProjectDetails PD
	   JOIN AVMDART_MigratedProjectsInfo (NOLOCK) MP ON MP.DARTProjectID = PD.ProjectID
	   JOIN #ModifiedTimesheets MT ON MT.ProjectId = MP.DARTProjectID 
	   JOIN AVMDART.TRN.TimesheetDetail (NOLOCK) DTD 
			ON DTD.ProjectId = MT.ProjectID AND DTD.TimesheetId = MT.TimesheetId

       SELECT DISTINCT	DTD.TimeSheetDetailId,
						AT.TimesheetId,
						APPM.ApplicationID,
						DTD.TicketNo AS TicketID,
						ASM.ServiceId,
						ACM.CategoryId,
						CASE WHEN ASM.ServiceId IS NOT NULL AND AACM.ActivityId IS NULL THEN 116 ELSE AACM.ActivityId END AS ActivityId,
						DTD.Hours,
						DTD.Remarks,
						CASE WHEN  DTD.IsAttributeUpdated = 'N' THEN 0 ELSE 1 END IsAttributeUpdated,
						ATSM.TicketSourceID, 
						DTD.IsSDTicket,
						APM.ProjectId,
						ATD.TimeTickerID,
						ATD.TicketTypeMapID					
       INTO #TimeSheetDetails
       FROM @ProjectDetails PD
       JOIN #TimesheetDetailNew DTD 
			ON PD.ProjectID = DTD.ProjectID
       JOIN AVMDART.PRJ.Timesheet (NOLOCK) DT 
            ON DT.TimesheetId = DTD.TimesheetId AND DTD.ProjectId = DT.ProjectId              
	   JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APM 
            ON APM.EsaProjectID = PD.EsaProjectID
       JOIN AVMDART.[PRJ].[LoginMaster]  DLM
            ON DLM.UserID = DT.SubmitterId 
       JOIN [AVL].[MAS_LoginMaster] (NOLOCK) ALM
            ON ALM.EmployeeID = DLM.cognizantID AND ALM.ProjectID = APM.ProjectID
       JOIN AVMDART.MAS.ApplicationMaster  DAM 
            ON DAM.ApplicationID = DTD.ApplicationID
       JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AAM 
            ON AAM.ApplicationName = DAM.ApplicationName
       JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APPM 
            ON APPM.ApplicationID = AAM.ApplicationID AND APPM.ProjectID = APM.ProjectID
       JOIN AVL.TM_PRJ_Timesheet (NOLOCK) AT 
            ON AT.ProjectID = APM.ProjectID AND AT.ProjectID IN (SELECT AppLensProjectID FROM @ProjectDetails)   
				AND AT.TimesheetDate = DT.TimesheetDate  AND AT.SubmitterId = ALM.UserID  
       LEFT JOIN AVMDART.MAP.ServiceProjectMapping(NOLOCK) DACM
		    ON DACM.ProjectID = DTD.ProjectId AND DACM.ServiceID = DTD.ServiceID AND DACM.ActivityID = DTD.ActivityID	
       LEFT JOIN [AVL].[MAS_ActivityMaster] (NOLOCK) AACM 
            ON AACM.ActivityName = DACM.ActivityName   
       LEFT JOIN AVMDART.[MAS].[ServiceMaster]  DSM 
            ON DSM.ServiceID = DTD.ServiceID
       LEFT JOIN [AVL].[TK_MAS_Service] (NOLOCK) ASM 
            ON ASM.ServiceName = DSM.ServiceName
       LEFT JOIN AVMDART.MAS.CategoryMaster  DCM 
            ON DCM.CategoryID = DTD.CategoryID
       LEFT JOIN AVL.MAS_CategoryMaster (NOLOCK) ACM 
            ON ACM.CategoryName = DCM.CategoryName            
       LEFT JOIN AVMDART.MAS.TicketSourceMaster  DTSM 
            ON DTSM.DARTTicketSourceID = 
                    (CASE WHEN RTRIM(LTRIM(ISNULL(DTD.TicketSourceID, 0))) IN (' ', 'NULL', 'null') THEN 0 ELSE DTD.TicketSourceID END)
       LEFT JOIN AVL.TK_MAS_TicketSource (NOLOCK) ATSM 
            ON ATSM.TicketSourceName = DTSM.DARTTicketSource
       LEFT JOIN AVL.TK_TRN_TicketDetail (NOLOCK) ATD 
            ON ATD.ProjectID = APM.ProjectID AND ATD.TicketID = DTD.TicketNo
       WHERE DTD.ServiceId NOT IN (41) 

       PRINT 'Delete and Insert into Timesheet Details Table'

	   -- Delete the Timesheet Details - (Normal Tickets)
	   DELETE TD
       FROM AVL.TM_TRN_TimesheetDetail TD
       JOIN #TimeSheetDetails TS ON TS.ProjectID = TD.ProjectID AND TS.TimesheetID = TD.TimesheetID

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
	   SELECT SAM.ServiceMappingID, TSD.ProjectID, SAM.IsDeleted, GETDATE(), 'Migrated', NULL, NULL, 0, NULL, NULL
	   FROM #TimeSheetDetails TSD
	   JOIN AVL.TK_MAS_ServiceActivityMapping (NOLOCK) SAM
			ON SAM.ServiceID = TSD.ServiceID AND SAM.ActivityID = 116 AND IsDeleted = 0
	   LEFT JOIN AVL.TK_PRJ_ProjectServiceActivityMapping (NOLOCK) PSAM
			ON PSAM.ProjectID = TSD.ProjectID AND PSAM.ServiceMapID = SAM.ServiceMappingID
	   WHERE TSD.ServiceID IS NOT NULL AND TSD.ActivityID IS NULL AND PSAM.ProjectID IS NULL

	   SELECT	TimesheetId,
				TicketID,
				ServiceId,
				ActivityId,
				ProjectId,
				SUM(Hours) AS Hours
	   INTO #GroupedTimesheetDetails
	   FROM #TimeSheetDetails
	   GROUP BY TimesheetId, TicketID, ServiceId, ActivityId, ProjectId

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
					SELECT TOP 1 ApplicationID FROM #TimeSheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketID = G.TicketID 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.ProjectID = G.ProjectID AND ApplicationID IS NOT NULL
				),
				0 AS ShiftId,
				TicketID,
				0 AS IsNonTicket,
				ServiceId,
				(
					SELECT TOP 1 CategoryId FROM #TimeSheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketID = G.TicketID 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.ProjectID = G.ProjectID AND CategoryId IS NOT NULL
				),
				ActivityId,
				Hours,
				(
					SELECT TOP 1 Remarks FROM #TimeSheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketID = G.TicketID 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.ProjectID = G.ProjectID AND Remarks IS NOT NULL
				),
			    'Migrated' AS CreatedBy,
				GETDATE() AS CreatedDateTime,
				NULL AS ModifiedBy,
				NULL AS ModifiedDateTime,
				(
					SELECT TOP 1 IsAttributeUpdated FROM #TimeSheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketID = G.TicketID 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.ProjectID = G.ProjectID AND IsAttributeUpdated IS NOT NULL
				),
				(
					SELECT TOP 1 TicketSourceID FROM #TimeSheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketID = G.TicketID 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.ProjectID = G.ProjectID AND TicketSourceID IS NOT NULL
				),
				(
					SELECT TOP 1 IsSDTicket FROM #TimeSheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketID = G.TicketID 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.ProjectID = G.ProjectID AND IsSDTicket IS NOT NULL
				),
				ProjectId,
				(
					SELECT TOP 1 TimeTickerID FROM #TimeSheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketID = G.TicketID 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.ProjectID = G.ProjectID AND TimeTickerID IS NOT NULL
				),
				(
					SELECT TOP 1 TicketTypeMapID FROM #TimeSheetDetails TSD 
					WHERE TSD.TimesheetId = G.TimesheetId AND TSD.TicketID = G.TicketID 
						AND TSD.ServiceID = G.ServiceID AND TSD.ActivityId = G.ActivityId
						AND TSD.ProjectID = G.ProjectID AND TicketTypeMapID IS NOT NULL
				),
				0 AS IsDeleted
	   FROM #GroupedTimesheetDetails G


       PRINT 'Delete and Push Non-Delivery Timesheet Details'

	   SELECT DISTINCT	DTD.TimeSheetDetailId,
						AT.TimesheetId,
						APPM.ApplicationID,
						DTD.TicketNo AS TicketID,
						ASM.ServiceId,
						ACM.CategoryId,
						ISNULL(AACM.ID, 8) ActivityID,
						DTD.Hours,
						DTD.Remarks,
						CASE WHEN  DTD.IsAttributeUpdated = 'N' THEN 0 ELSE 1 END IsAttributeUpdated,
						DTD.IsSDTicket,
						APM.ProjectId
       INTO #TimeSheetDetailsNS
       FROM @ProjectDetails PD
       JOIN #TimesheetDetailNew DTD 
			ON PD.ProjectID = DTD.ProjectID
       JOIN AVMDART.PRJ.Timesheet (NOLOCK) DT 
            ON DT.TimesheetId = DTD.TimesheetId                    
       JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APM 
            ON APM.EsaProjectID = PD.EsaProjectID 
       JOIN AVMDART.[PRJ].[LoginMaster]  DLM
            ON DLM.UserID = DT.SubmitterId 
       JOIN [AVL].[MAS_LoginMaster] (NOLOCK) ALM
            ON ALM.EmployeeID = DLM.cognizantID and ALM.ProjectID = APM.ProjectID
       JOIN AVL.TM_PRJ_Timesheet (NOLOCK) AT 
            ON AT.ProjectID = APM.ProjectID  AND AT.TimesheetDate = DT.TimesheetDate 
                AND AT.SubmitterId = ALM.UserID AND AT.CreatedBy = 'Migrated'
       LEFT JOIN AVMDART.MAS.ApplicationMaster  DAM 
            ON DAM.ApplicationID = DTD.ApplicationID
       LEFT JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AAM 
            ON AAM.ApplicationName = DAM.ApplicationName
       LEFT JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) APPM 
            ON APPM.ApplicationID = AAM.ApplicationID AND APPM.ProjectID = APM.ProjectID        
       LEFT JOIN AVMDART.MAP.ServiceProjectMapping(NOLOCK) DACM
            ON DACM.ProjectID = DTD.ProjectId AND DACM.ServiceID = DTD.ServiceID AND DACM.ActivityID = DTD.ActivityID  
       LEFT JOIN AVL.MAS_NonDeliveryActivity (NOLOCK) AACM 
            ON AACM.NonTicketedActivity = CASE  WHEN DACM.ActivityName = 'Leave' OR DACM.ActivityName = 'Holiday' THEN 'Leave/Holiday' 
												WHEN DACM.ActivityName = 'Organizational Activity' THEN 'Organization Activity'
												ELSE DACM.ActivityName END
       LEFT JOIN AVMDART.[MAS].[ServiceMaster]  DSM 
            ON DSM.ServiceID = DTD.ServiceID
       LEFT JOIN [AVL].[TK_MAS_Service] (NOLOCK) ASM 
            ON ASM.ServiceName = DSM.ServiceName
       LEFT JOIN AVMDART.MAS.CategoryMaster DCM 
            ON DCM.CategoryID = DTD.CategoryID
       LEFT JOIN AVL.MAS_CategoryMaster (NOLOCK) ACM 
            ON ACM.CategoryName = DCM.CategoryName        
       WHERE DTD.ServiceId = 41


	   DELETE TD
       FROM AVL.TM_TRN_TimesheetDetail TD
       JOIN #TimeSheetDetailsNS TS ON TS.ProjectID = TD.ProjectID AND TS.TimesheetID = TD.TimesheetID AND TD.IsNonTicket = 1

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
            NULL,                        -- Shift ID
            'NonDelivery',
            1,                           -- Is Non Ticket
            ServiceId,
            NULL,
            ActivityID, 
            SUM(Hours),
            (
				SELECT TOP 1 NSTD1.Remarks FROM #TimeSheetDetailsNS NSTD1 
				WHERE NSTD1.TimesheetId = NSTD.TimesheetId AND NSTD1.ServiceID = NSTD.ServiceID
					AND NSTD1.ActivityID = NSTD.ActivityID AND NSTD1.ProjectId = NSTD.ProjectId
			),
            'Migrated',                  -- CreatedBy
            GETDATE(),                   -- CreatedDateTime
            NULL,                        -- ModifiedBy
            NULL,                        -- ModifiedDateTime
            NULL,
            NULL,                        -- TicketSourceID
            NULL,
            ProjectId,
            0,                           -- TimeTickerID
            0,                           -- TicketTypeMapID
            0                            -- IsDeleted
       FROM #TimeSheetDetailsNS NSTD
       GROUP BY TimesheetId, ServiceID, ActivityID, ProjectId

       -----------------------------------------------------------------------------------------------------------

		-- Log the Ticketing Module migration is successful for the respective account.
		UPDATE DataMigrationIncLog
		SET TicketingModuleStatus = 'S', TicketingModuleErrorMessage = NULL, ModifiedDateTime = GETDATE()
		WHERE AccountID = @AccountId AND ESAProjectIDs = @ESAProjectIDs

		DROP TABLE #ModifiedTimesheets

      COMMIT TRAN

  END TRY
  BEGIN CATCH
       
              DECLARE @ErrorMessage VARCHAR(MAX);

              SELECT @ErrorMessage = ERROR_MESSAGE()

              SELECT @ErrorMessage AS ErrorMessage
              
              ROLLBACK TRAN

              -- Log the Error in Data Migration Log Table.   
              UPDATE DataMigrationIncLog SET TicketingModuleStatus = 'F', TicketingModuleErrorMessage = @ErrorMessage, ModifiedDateTime = GETDATE()
              WHERE AccountID = @AccountId AND ESAProjectIDs = @ESAProjectIDs

  END CATCH

END
