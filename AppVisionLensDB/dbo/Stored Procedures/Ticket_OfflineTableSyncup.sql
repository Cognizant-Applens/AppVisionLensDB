/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[Ticket_OfflineTableSyncup]
AS
BEGIN
BEGIN TRY
BEGIN TRAN
	DECLARE @StartDateTime DATETIME    
	DECLARE @EndDateTime DATETIME    
	DECLARE @LastStartDateTime DATETIME    
	DECLARE @TktMasterMinDate DATETIME    
	DECLARE @TimesheetMinDate DATETIME    
	DECLARE @TicketInsert INT         
	DECLARE @TicketUpdate INT    
	
	 SET @StartDateTime = GETDATE()    
      SELECT TOP 1 @LastStartDateTime = StartDateTime FROM AVL.DEBT_TRN_OfflineSyncLog ORDER BY StartDateTime DESC    


	  IF(@LastStartDateTime is NULL)    
      BEGIN    
            SELECT @TktMasterMinDate = MIN(LastUpdatedDate) FROM AVL.TK_TRN_TicketDetail          
            --SELECT @TimesheetMinDate = MIN(CreatedDateTime) FROM AVL.TM_PRJ_Timesheet   
            select @LastStartDateTime = @TktMasterMinDate   
      END 


SELECT BCM1.CustomerID,
CASE WHEN BCM8.IsHavingSubBusinesss IS NOT NULL THEN BCM8.BusinessClusterMapID
 WHEN  BCM7.IsHavingSubBusinesss  is not null THEN BCM7.BusinessClusterMapID
 WHEN  BCM6.IsHavingSubBusinesss  is not null THEN BCM6.BusinessClusterMapID
 WHEN  BCM5.IsHavingSubBusinesss  is not null THEN BCM5.BusinessClusterMapID
 WHEN  BCM4.IsHavingSubBusinesss  is not null THEN BCM4.BusinessClusterMapID
 WHEN  BCM3.IsHavingSubBusinesss  is not null THEN BCM3.BusinessClusterMapID
 WHEN  BCM2.IsHavingSubBusinesss  is not null THEN BCM2.BusinessClusterMapID
 WHEN  BCM1.IsHavingSubBusinesss  is not null THEN BCM1.BusinessClusterMapID
END AS CoreBusinessClusterID,
BCM1.BusinessClusterMapID AS BusinessClusterLevel1,BCM1.BusinessClusterBaseName AS BusinessClusterLevel1Name,BCM1.IsHavingSubBusinesss AS Final1,
BCM2.BusinessClusterMapID AS BusinessClusterLevel2,BCM2.BusinessClusterBaseName AS BusinessClusterLevel2Name,BCM2.IsHavingSubBusinesss AS Final2,
BCM3.BusinessClusterMapID AS BusinessClusterLevel3,BCM3.BusinessClusterBaseName AS BusinessClusterLevel3Name ,BCM3.IsHavingSubBusinesss AS Final3,
BCM4.BusinessClusterMapID AS BusinessClusterLevel4,BCM4.BusinessClusterBaseName AS BusinessClusterLevel4Name,BCM4.IsHavingSubBusinesss AS Final4,
BCM5.BusinessClusterMapID AS BusinessClusterLevel5,bcm5.BusinessClusterBaseName AS BusinessClusterLevel5Name,BCM5.IsHavingSubBusinesss AS Final5,
BCM6.BusinessClusterMapID AS BusinessClusterLevel6,bcm6.BusinessClusterBaseName AS BusinessClusterLevel6Name,BCM6.IsHavingSubBusinesss AS Final6,
BCM7.BusinessClusterMapID AS BusinessClusterLevel7,bcm7.BusinessClusterBaseName AS BusinessClusterLevel7Name,BCM7.IsHavingSubBusinesss AS Final7,
BCM8.BusinessClusterMapID AS BusinessClusterLevel8,bcm8.BusinessClusterBaseName AS BusinessClusterLevel8Name,BCM8.IsHavingSubBusinesss AS Final8
INTO #BusinessClusterMapping  
FROM AVL.BusinessClusterMapping BCM1
LEFT JOIN AVL.BusinessClusterMapping  BCM2 on bcm1.BusinessClusterMapID=BCM2.ParentBusinessClusterMapID AND 
BCM1.ParentBusinessClusterMapID IS NULL
LEFT JOIN AVL.BusinessClusterMapping  BCM3 ON BCM2.BusinessClusterMapID=BCM3.ParentBusinessClusterMapID
LEFT JOIN AVL.BusinessClusterMapping  BCM4 ON BCM3.BusinessClusterMapID=BCM4.ParentBusinessClusterMapID
LEFT JOIN AVL.BusinessClusterMapping  BCM5 ON BCM4.BusinessClusterMapID=BCM5.ParentBusinessClusterMapID
LEFT JOIN AVL.BusinessClusterMapping  BCM6 ON BCM5.BusinessClusterMapID=BCM6.ParentBusinessClusterMapID
LEFT JOIN AVL.BusinessClusterMapping  BCM7 ON BCM6.BusinessClusterMapID=BCM7.ParentBusinessClusterMapID
LEFT JOIN AVL.BusinessClusterMapping  BCM8 ON BCM7.BusinessClusterMapID=BCM8.ParentBusinessClusterMapID
WHERE
--AND 
((BCM8.IsHavingSubBusinesss = 0 AND BCM8.BusinessClusterMapID IN(SELECT SubBusinessClusterMapID 
																	FROM AVL.APP_MAS_ApplicationDetails))
OR (BCM7.IsHavingSubBusinesss = 0 AND BCM7.BusinessClusterMapID IN(SELECT SubBusinessClusterMapID 
																	FROM AVL.APP_MAS_ApplicationDetails))
OR (BCM6.IsHavingSubBusinesss = 0 AND BCM6.BusinessClusterMapID IN(SELECT SubBusinessClusterMapID 
																	FROM AVL.APP_MAS_ApplicationDetails))
OR (BCM5.IsHavingSubBusinesss = 0 AND BCM5.BusinessClusterMapID IN(SELECT SubBusinessClusterMapID 
																	FROM AVL.APP_MAS_ApplicationDetails))
OR (BCM4.IsHavingSubBusinesss = 0 AND BCM4.BusinessClusterMapID IN(SELECT SubBusinessClusterMapID 
																	FROM AVL.APP_MAS_ApplicationDetails))
OR (BCM3.IsHavingSubBusinesss = 0 AND BCM3.BusinessClusterMapID IN(SELECT SubBusinessClusterMapID 
																	FROM AVL.APP_MAS_ApplicationDetails))
OR (BCM2.IsHavingSubBusinesss = 0 AND BCM2.BusinessClusterMapID IN(SELECT SubBusinessClusterMapID 
																	FROM AVL.APP_MAS_ApplicationDetails))
OR (BCM1.IsHavingSubBusinesss = 0 AND BCM1.BusinessClusterMapID IN(SELECT SubBusinessClusterMapID 
																	FROM AVL.APP_MAS_ApplicationDetails))
)
AND BCM1.ParentBusinessClusterMapID IS NULL


SELECT TD.TimeTickerID,BU.BUID,BU.BUName,C.CustomerID,C.CustomerName,
TicketID,ApplicationID,TD.ProjectID,PM.EsaProjectID,PM.ProjectName,TD.AssignedTo,
TD.AssignmentGroup,NULL as AssignmentGroupName,TD.EffortTillDate,TD.ServiceID,TD.TicketDescription,TD.IsDeleted,
TD.DARTStatusID,DTS.DARTStatusName,TD.CauseCodeMapID,TD.DebtClassificationMapID,
TD.ResidualDebtMapID,TD.ResolutionCodeMapID,
TD.KEDBAvailableIndicatorMapID,TD.ResolutionMethodMapID,
TD.KEDBUpdatedMapID,TD.KEDBPath,TD.PriorityMapID,TD.ReleaseTypeMapID,TD.SeverityMapID,
TD.TicketSourceMapID,TD.TicketStatusMapID,TD.TicketTypeMapID,TD.BusinessSourceName,
TD.Onsite_Offshore,TD.PlannedEffort,TD.EstimatedWorkSize,TD.ActualEffort,TD.ActualWorkSize,TD.Resolvedby,TD.Closedby,TD.ElevateFlagInternal,
TD.RCAID,TD.PlannedDuration,TD.Actualduration,TD.TicketSummary,TD.NatureoftheTicket,TD.Comments,TD.RepeatedIncident,TD.RelatedTickets,
TD.TicketCreatedBy,TD.SecondaryResources,TD.EscalatedFlagCustomer,TD.ReasonforRejection,TD.AvoidableFlag,AF.[AvoidableFlagName],TD.ReleaseDate,
TD.TicketCreateDate,TD.PlannedStartDate,TD.PlannedEndDate,TD.ActualStartdateTime,TD.ActualEnddateTime,TD.OpenDateTime,TD.StartedDateTime,
TD.WIPDateTime,TD.OnHoldDateTime,TD.CompletedDateTime,TD.ReopenDateTime,TD.CancelledDateTime,TD.RejectedDateTime,TD.Closeddate,
TD.AssignedDateTime,TD.OutageDuration,TD.MetResponseSLAMapID,TD.MetAcknowledgementSLAMapID,TD.MetResolutionMapID,TD.TKBusinessID,
TD.IsAttributeUpdated,TD.IsManual,TD.IsSDTicket,TD.CREATEDBY,TD.CreatedDate,TD.LastUpdatedDate,TD.ModifiedBy,TD.ModifiedDate
INTO #TicketMaster  
 FROM AVL.TK_TRN_TicketDetail TD
LEFT JOIN AVL.MAS_ProjectMaster PM ON TD.ProjectID=PM.ProjectID
LEFT JOIN AVL.Customer C ON  PM.CustomerID=C.CustomerID 
LEFT JOIN AVL.BusinessUnit BU ON BU.BUID=C.BUID 
JOIN AVL.DEBT_MAS_AvoidableFlag AF on AF.AvoidableFlagID=TD.AvoidableFlag
join AVL.TK_MAS_DARTTicketStatus DTS on dts.DARTStatusID=td.DARTStatusID
WHERE TD.LastUpdatedDate >= @LastStartDateTime
AND (UPPER(DTS.DARTStatusName) in('CLOSED','COMPLETED' ))
and td.IsDeleted =0

	COMMIT TRAN
	END TRY  
	BEGIN CATCH  

	END CATCH  
	END
