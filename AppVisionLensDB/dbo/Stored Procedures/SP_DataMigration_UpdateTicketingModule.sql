/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =================================================================================  
-- Author: Kumuthini 
-- Create date: 23-Aug-18
-- Description: Migration - Service Activity Table and Ticketing module Updates
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
-- Test: [dbo].[SP_DataMigration_UpdateTicketingModule] 
-- ================================================================================= 

CREATE PROCEDURE [dbo].[SP_DataMigration_UpdateTicketingModule]
AS
BEGIN

	DECLARE @ProjectDetails TABLE 
	( 
		AccountID BIGINT,
		AccountName NVARCHAR(MAX),
		ProjectID BIGINT,
		EsaProjectID NVARCHAR(MAX),
		ProjectName VARCHAR(MAX),
		AppLensProjectID BIGINT
	)

	INSERT INTO @ProjectDetails
		SELECT  DA.AccountID AS AccountID,
				AccountName,
				PM.ProjectID,
				PM.EsaProjectID,
				PM.ProjectName,
				APLPM.ProjectID
		FROM AVMDART.MAS.ProjectMaster (NOLOCK) PM
		JOIN AVMDART.[MAP].[DeptAcctMapping] (NOLOCK) DA 
			ON DA.DeptAccountID = PM.DeptAccountID
				AND DA.IsDeleted = 'N' AND PM.IsDeleted = 'N'
		JOIN AVL.Customer (NOLOCK) CUST
			ON CUST.ESA_AccountID = DA.AccountID AND CUST.IsDeleted = 0
		JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) APLPM
			ON APLPM.EsaProjectID = PM.EsaProjectID AND APLPM.IsDeleted = 0 
			--and APLPM.EsaProjectID in('1000117088')
		JOIN DataMigration_Projects (NOLOCK) DP ON DP.ProjectID = APLPM.ProjectID
			
	-- Update Ticket Status for DART Tickets

	UPDATE TD 
	SET TD.TICKETSTATUSMAPID = 
		(
			SELECT TOP 1 StatusID 
			FROM AVL.TK_MAP_ProjectStatusMapping (NOLOCK) 
			WHERE ProjectID = PM.ProjectID AND TicketStatus_ID = TD.DARTStatusID AND IsDeleted = 0
		) 
	FROM AVL.TK_TRN_TicketDetail (NOLOCK) TD
	JOIN AVL.MAS_ProjectMaster (NOLOCK) PM ON PM.ProjectID = TD.ProjectID
	JOIN @ProjectDetails P ON P.AppLensProjectID = PM.ProjectID
	WHERE TD.TicketStatusMapID IS NULL AND TD.IsSDTicket = 1 

	DECLARE @Temp TABLE
	(
		EmployeeID varchar(100),
		Customer varchar(100),
		count_ts bigint 
	)

	INSERT into @Temp
		select EmployeeID, CustomerID, count(distinct TSApproverID)  
		from AVL.MAS_LoginMaster 
		where IsDeleted = 0
		group by EmployeeID,CustomerID


	select * from AVL.MAS_LoginMaster LM
	join @Temp T on T.EmployeeID = LM.EmployeeID and T.Customer = LM.CustomerID
	where T.count_ts <> 1 and lm.IsDeleted = 0

	update lm set lm.TSApproverID=lm.HcmSupervisorID from AVL.MAS_LoginMaster LM
	join @Temp T on T.EmployeeID = LM.EmployeeID and T.Customer = LM.CustomerID
	where T.count_ts <> 1  and lm.IsDeleted =0

	---- Update Activity ID for all tickets of migrated projects
	--SELECT ATD.* 
	--INTO #DartTimesheetDetail
	--FROM AVMDART.TRN.TimesheetDetail (NOLOCK) ATD
	--JOIN @ProjectDetails P ON P.ProjectID = ATD.ProjectID

	--SELECT DAPM.* 
	--INTO #DartServiceProjectMapping
	--FROM AVMDART.[MAP].[ServiceProjectMapping] (NOLOCK) DAPM
	--JOIN @ProjectDetails P ON P.ProjectID = DAPM.ProjectID

	--UPDATE ATD 
	--SET ATD.ActivityId = AM.ActivityId 
	--FROM AVL.TM_TRN_TimesheetDetail ATD
	--JOIN @ProjectDetails P ON P.AppLensProjectID = ATD.ProjectID
	--JOIN #DartTimesheetDetail DTD ON DTD.ProjectID = P.ProjectID And ATD.TicketID = DTD.TicketNo
	--JOIN #DartServiceProjectMapping DSPM ON DSPM.ProjectID = DTD.ProjectID AND DSPM.ServiceID = DTD.ServiceId AND DSPM.ActivityID = DTD.ActivityId
	--JOIN [AVL].[TK_MAS_ServiceActivityMapping] (NOLOCK) ASPM ON ASPM.ServiceID = DSPM.ServiceID AND ASPM.ActivityName = DSPM.ActivityName 
	--JOIN AVL.TK_PRJ_ProjectServiceActivityMapping (NOLOCK) PSAM ON PSAM.ProjectID = P.AppLensProjectID AND PSAM.ServiceMapID = ASPM.ServiceMappingID  
	--JOIN [AVL].[MAS_ActivityMaster] (NOLOCK) AM ON AM.ActivityName = ASPM.ActivityName
	--WHERE ATD.CreatedBy = 'Migrated'

	--DROP TABLE #DartTimesheetDetail
	--DROP TABLE #DartServiceProjectMapping

	---- Update Activity ID as others if the Activity ID is null

	--SELECT DISTINCT ts.ProjectId, ServiceId 
	--INTO #ServiceIDTemp
	--FROM AVL.TM_TRN_TimesheetDetail (NOLOCK) ts
	--JOIN @ProjectDetails p 
	--	ON p.ProjectID = ts.ProjectID AND ts.ServiceId IS NOT NULL AND ts.ActivityId IS NULL
	

	--INSERT INTO AVL.TK_PRJ_ProjectServiceActivityMapping
	--(
	--	ServiceMapID,
	--	ProjectID,
	--	IsDeleted,
	--	CreatedDateTime,
	--	CreatedBY,
	--	ModifiedDateTime,
	--	ModifiedBY,
	--	IsHidden,
	--	EffectiveDate,
	--	IsMainspringData
	--)
	--SELECT ServiceMappingID, sp.ProjectID, sam.IsDeleted, GETDATE(), 'Migrated', NULL, NULL, 0, NULL, NULL
	--FROM AVL.TK_MAS_ServiceActivityMapping (NOLOCK) sam 
	--JOIN 
	--(
	--	SELECT DISTINCT ServiceId FROM #ServiceIDTemp
	--) s 
	--ON s.ServiceId = sam.ServiceID
	--JOIN #ServiceIDTemp sp ON sp.ServiceId = sam.ServiceID
	--LEFT JOIN AVL.TK_PRJ_ProjectServiceActivityMapping (NOLOCK) psam 
	--	ON psam.ServiceMapID = sam.ServiceMappingID AND psam.ProjectID = sp.ProjectID
	--WHERE psam.ServiceMapID IS NULL 

	--UPDATE ts 
	--SET ts.ActivityId = sam.ActivityID
	--FROM AVL.TM_TRN_TimesheetDetail ts
	--JOIN @ProjectDetails p 
	--	ON p.ProjectID = ts.ProjectID AND ts.ServiceId IS NOT NULL AND ts.ActivityId IS NULL
	--JOIN AVL.TK_MAS_ServiceActivityMapping (nolock) sam 
	--	ON sam.ServiceID = ts.ServiceId AND sam.ActivityName = 'Others'
	--JOIN AVL.TK_PRJ_ProjectServiceActivityMapping (nolock) psam 
	--	ON psam.ProjectID = ts.ProjectID AND psam.ServiceMapID = sam.ServiceMappingID

	--DROP TABLE #ServiceIDTemp
	
END
