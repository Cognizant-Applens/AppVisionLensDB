/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[RefreshForAutomationTickets] 
AS 
  BEGIN 
	DECLARE @JobStatusId BIGINT=0

      BEGIN TRY 	  

		if EXISTS(SELECT JobID FROM mas.JobMaster WHERE JobName like '%Manually Created Automation Tickets%')
			BEGIN
				DECLARE @JobId BIGINT
				SELECT @JobId=JobID FROM mas.JobMaster WHERE JobName like '%Manually Created Automation Tickets%'
				INSERT INTO MAS.JobStatus(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,Remarks,IsDeleted,CreatedBy,CreatedDate)
				SELECT @JobId,GETDATE(),'','Started',getdate(),'Job Started',0,'SQL - Job',getdate()
				SET @JobStatusId=@@IDENTITY
			END


	
		DECLARE @ProjectID AS TABLE
		(ProjectID  INT
		)
		INSERT INTO @ProjectID
		(ProjectID)
		select  DISTINCT ProjectID from [AVL].[DEBT_PRJ_NonDebtParentChild]

		SELECT TimeTickerID,ServiceID,ProjectID,ApplicationID INTO #TK_TRN_TicketDetail FROM AVL.TK_TRN_TicketDetail(NOLOCK) T
		WHERE ProjectID IN (select ProjectID from @ProjectID) AND DARTStatusID=8
		AND T.IsDeleted=0

		SELECT ProjectID,HealingTicketID,HTD.CreatedDate,HTD.ManualNonDebt,DARTStatusID INTO #DEBT_TRN_HealTicketDetails FROM 
		AVL.DEBT_TRN_HealTicketDetails HTD INNER JOIN  AVL.DEBT_PRJ_HealProjectPatternMappingDynamic PMD 
		ON PMD.ProjectPatternMapID=HTD.ProjectPatternMapID AND  ProjectID IN (select ProjectID from @ProjectID)
		WHERE HTD.DARTStatusID NOT IN(5,7,8,13) AND ISNULL(HTD.ManualNonDebt,0)=1 AND ISNULL(PMD.ManualNonDebt,0)=1


		SELECT  TD.ProjectID,TD.ServiceID,SAM.ActivityName,TD.ApplicationID,
		COUNT(DISTINCT TS.SubmitterId) AS TotalNoOfAnalysts
		,COUNT(TIMDT.TimeSheetDetailId) AS NoOfOccurence,
		SUM(Hours) AS TotalHours
		INTO #NewTickets 
		FROM AVL.TM_TRN_TimesheetDetail(NOLOCK) TIMDT INNER JOIN #TK_TRN_TicketDetail TD ON TD.TimeTickerID=TIMDT.TimeTickerID AND TIMDT.IsDeleted=0
		INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) TS ON TS.TimesheetId=TIMDT.TimesheetId AND ISNULL(TIMDT.IsDeleted,0)=0
		INNER JOIN AVL.TK_MAS_ServiceActivityMapping(NOLOCK) SAM ON TD.ServiceId=SAM.ServiceID AND TIMDT.ActivityId=SAM.ActivityID
		INNER JOIN [AVL].[DEBT_PRJ_NonDebtParentChild] PC ON PC.ServiceID=TD.ServiceID 	AND PC.ActivityName=SAM.ActivityName AND PC.ApplicationID = TIMDT.ApplicationID
		INNER JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PD ON PD.ProjectID=TS.ProjectID	
		INNER JOIN #DEBT_TRN_HealTicketDetails HTD ON HTD.HealingTicketID=PC.HealingTicketID 
		WHERE TIMDT.ProjectID IN (select ProjectID from @ProjectID) 
		AND PC.ProjectID IN (select ProjectID from @ProjectID) AND
		CONVERT(DATE,TS.TimesheetDate) >= CONVERT(DATE,ISNULL(HTD.CreatedDate,GETDATE())-ISNULL(PD.NonDebtThresholdDays,60))
		
		GROUP BY TD.ProjectID, TD.ServiceID,SAM.ActivityName,TD.ApplicationID
		
		--select *  from #NewTickets
		--drop table  #NewTickets

		----Update the child table with latest data 
		UPDATE PC SET PC.NoOfAnalystsInvolved=NT.TotalNoOfAnalysts,
					  PC.NoOfOccurrence=NT.NoOfOccurence,
					  PC.TotalEfforts=NT.TotalHours,
					  PC.ModifiedDate=GETDATE(),
					  pc.ModifiedBy='System'
		FROM [AVL].[DEBT_PRJ_NonDebtParentChild] PC INNER JOIN #NewTickets NT ON NT.ProjectID=PC.ProjectID
		AND NT.ServiceId=PC.ServiceID
		AND NT.ActivityName=PC.ActivityName
		AND NT.ApplicationID=PC.ApplicationID
		AND PC.IsDeleted=0
		AND (ISNULL(NT.TotalNoOfAnalysts,0)+ISNULL(NT.NoOfOccurence,0)+ISNULL(NT.TotalHours,0))<>0

		----Update the child table with latest data for application changes 
		UPDATE PC SET PC.NoOfAnalystsInvolved=0,
					  PC.NoOfOccurrence=0,
					  PC.TotalEfforts=0,
					  PC.ModifiedDate=GETDATE(),
					  pc.ModifiedBy='System'
		FROM [AVL].[DEBT_PRJ_NonDebtParentChild] PC LEFT JOIN #NewTickets NT ON NT.ProjectID=PC.ProjectID
		AND NT.ServiceId=PC.ServiceID
		AND NT.ActivityName=PC.ActivityName
		AND NT.ApplicationID=PC.ApplicationID
		AND PC.IsDeleted=0
		AND (ISNULL(NT.TotalNoOfAnalysts,0)+ISNULL(NT.NoOfOccurence,0)+ISNULL(NT.TotalHours,0))<>0 WHERE NT.ApplicationID is null

		----Inactivate the child record if not exists in the latest refresh
		UPDATE PC SET PC.IsDeleted=1,
					  PC.ModifiedDate=GETDATE(),
					  pc.ModifiedBy='System'
		FROM [AVL].[DEBT_PRJ_NonDebtParentChild] PC LEFT JOIN #NewTickets NT ON NT.ProjectID=PC.ProjectID
		AND NT.ServiceId=PC.ServiceID
		AND NT.ActivityName=PC.ActivityName
		AND NT.ApplicationID=PC.ApplicationID
		AND PC.IsDeleted=0
		WHERE NT.ServiceId IS NULL

		---In Activate the parent record if no child with active state
		
		UPDATE AVL.DEBT_TRN_HealTicketDetails SET IsDeleted=1 WHERE ManualNonDebt=1 AND IsDeleted=0 AND HealingTicketID NOT IN(
		SELECT DISTINCT PC.HealingTicketID FROM  [AVL].[DEBT_PRJ_NonDebtParentChild] PC WHERE PC.IsDeleted=0)  

		-----
		IF @JobStatusId>0 
			BEGIN
			 UPDATE MAS.JobStatus SET EndDateTime=GETDATE(),JobStatus='Success',Remarks='Job Completed' WHERE ID=@JobStatusId
			END
			SELECT 1 AS Success


      END TRY 
      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = ERROR_MESSAGE()   
          EXEC AVL_INSERTERROR '[AVL].[RefreshForAutomationTickets]',  @ErrorMessage, 'RefreshForAutomationTickets -Job ',  0 
		  IF @JobStatusId>0 
			BEGIN
			 UPDATE MAS.JobStatus SET EndDateTime=GETDATE(),JobStatus='Failed',Remarks=@ErrorMessage WHERE ID=@JobStatusId
			END
      END CATCH 
  END
