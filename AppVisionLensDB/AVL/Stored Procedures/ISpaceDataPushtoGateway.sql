/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROC [AVL].[ISpaceDataPushtoGateway]
AS
BEGIN 
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON; 

DECLARE @lastTriggeredDate DATETIME,
		@2ndLastTriggeredDate DATETIME,
		@JobSuccessDate DATETIME


SELECT @lastTriggeredDate=  MAX(TriggeredDate) FROM AVL.DEBT_MAS_ReleasePlanDetails(NOLOCK) WHERE TicketType='A'
--SELECT @JobSuccessDate= MAX(ISpaceJobDate) FROM AVL.DEBT_MAS_ReleasePlanDetails(NOLOCK) WHERE ISpaceJobStatus=1 AND  TicketType='A'
SELECT @JobSuccessDate= MAX(JobDate) FROM AVL.ISpaceJobStatus(NOLOCK) where JobStatus=1
if @JobSuccessDate is null 
Begin 
SET @JobSuccessDate=dateadd(day,-1,@lastTriggeredDate)
End

SELECT @2ndLastTriggeredDate=MAX(TriggeredDate) FROM AVL.DEBT_MAS_ReleasePlanDetails(NOLOCK) WHERE
		TriggeredDate < (SELECT MAX(TriggeredDate) FROM AVL.DEBT_MAS_ReleasePlanDetails(NOLOCK) WHERE TicketType='A') AND  TicketType='A'

INSERT INTO AVL.ISpaceJobStatus(JobStatus,createdDate)VALUES(0,getdate())

SELECT DISTINCT * INTO #DEBT_MAS_ReleasePlanDetails FROM  (
SELECT [Id] AS ApplensOpportunityId   
      ,[ProjectId]
      ,[PlannedStartDate]
      ,[PlannedEndDate]
      ,[ActualEndDate]
      ,[ActualStartDate]
      ,[ReleasePlanName]
      ,[IsDeleted]
      ,[TicketType]
      ,[CreatedBy]
      ,[CreatedDate]
      ,[ModifiedBy]
      ,[ModifiedDate]
      ,[TriggeredDate]
      --,[ISpaceJobStatus]
      --,[ISpaceJobDate]
      ,[ISpaceStatus] 
	  ,ISpaceOpportunityId
FROM AVL.DEBT_MAS_ReleasePlanDetails(NOLOCK) RPD 
WHERE RPD.IsDeleted=0 AND RPD.TriggeredDate IS NOT NULL AND (RPD.TriggeredDate>@lastTriggeredDate OR RPD.TriggeredDate>@JobSuccessDate) 
	 AND RPD.TicketType='A'

UNION ALL

SELECT RPD.[Id] AS ApplensOpportunityId 
      ,RPD.[ProjectId]
      ,RPD.[PlannedStartDate]
      ,RPD.[PlannedEndDate]
      ,RPD.[ActualEndDate]
      ,RPD.[ActualStartDate]
      ,RPD.[ReleasePlanName]
      ,RPD.[IsDeleted]
      ,RPD.[TicketType]
      ,RPD.[CreatedBy]
      ,RPD.[CreatedDate]
      ,RPD.[ModifiedBy]
      ,RPD.[ModifiedDate]
      ,RPD.[TriggeredDate]
      --,RPD.[ISpaceJobStatus]
      --,RPD.[ISpaceJobDate]
      ,RPD.[ISpaceStatus] 
	 ,RPD.ISpaceOpportunityId
FROM AVL.DEBT_MAS_ReleasePlanDetails(NOLOCK) RPD INNER JOIN
AVL.DEBT_TRN_HealTicketDetails HTD ON HTD.ReleasePlanning=RPD.Id 
WHERE RPD.IsDeleted=0 AND HTD.IsDeleted=0 AND RPD.TriggeredDate IS NOT NULL 
  AND ((RPD.ModifiedDate > @JobSuccessDate) OR (HTD.ModifiedDate  > @JobSuccessDate)) AND RPD.TicketType='A' 
  --AND ((RPD.ModifiedDate BETWEEN @2ndLastTriggeredDate AND @lastTriggeredDate) OR (HTD.ModifiedDate BETWEEN @2ndLastTriggeredDate AND @lastTriggeredDate)) AND RPD.TicketType='A'

) ReleasePlanDetails


SELECT HTD.[Id] ApplensIdeaId
      ,HTD.[ProjectPatternMapID]
      ,HTD.[HealingTicketID]
      ,HTD.[TicketType]
      ,HTD.[DARTStatusID]
      ,HTD.[Assignee]
      ,HPPM.[ApplicationID]
      ,HTD.[OpenDate]
      ,HTD.[PriorityID]
      ,HTD.[IsManual]
      ,HTD.[IsPushed]
      ,HTD.[CreatedBy]
      ,HTD.[CreatedDate]
      ,HTD.[ModifiedBy]
      ,HTD.[ModifiedDate]
      ,HTD.[IsDeleted]
      ,HTD.[IsMappedToProblemTicket]
      ,HTD.[PlannedEffort]
      ,HTD.[HealTypeId]
      ,HTD.[PlannedStartDate]
      ,HTD.[PlannedEndDate]
      ,HTD.[ReleasePlanning] ApplensOpportunityId
      ,HTD.[TicketDescription]
      ,HTD.[SolutionType]
      ,HTD.[IsDormant]
      ,HTD.[DormantCreatedDate]
      ,HTD.[MarkAsDormant]
      ,HTD.[MarkAsDormantDate]
      ,HTD.[MarkAsDormantComments]
      ,HTD.[MarkAsDormantBy]
      ,HTD.[ReasonForRepetition]
      ,HTD.[ReasonForCancellation]
      ,HTD.[ActualEffortReduction]
      ,HTD.[PlannedEffortReduction]
      ,HTD.[Scope]
      ,HTD.[ImplementationStatus]
      ,HTD.[SavingsHardDollarActualCognizant]
      ,HTD.[SavingsHardDollarActualCustomer]
      ,HTD.[SavingsHardDollarPlannedCognizant]
      ,HTD.[SavingsHardDollarPlannedCustomer]
      ,HTD.[SavingsSoftDollarActualCognizant]
      ,HTD.[SavingsSoftDollarActualCustomer]
      ,HTD.[SavingsSoftDollarPlannedCognizant]
      ,HTD.[SavingsSoftDollarPlannedCustomer]
      ,HTD.[IsMandatory]
      ,HTD.[IncidentReductionMonth]
      ,HTD.[EffortReductionMonth]
     ,HTD.TriggeredDate
	 --,ISpaceJobDate
	 ,HTD.ISpaceIdeaId
	  INTO #DEBT_TRN_HealTicketDetails
	  FROM AVL.DEBT_PRJ_HealProjectPatternMappingDynamic HPPM WITH (NOLOCK)
	  INNER JOIN AVL.DEBT_TRN_HealTicketDetails HTD WITH (NOLOCK)
	  ON HTD.ProjectPatternMapID = HPPM.ProjectPatternMapID
	  WHERE HTD.ReleasePlanning IN  (
	  SELECT ApplensOpportunityId FROM  #DEBT_MAS_ReleasePlanDetails
	  ) 

	   SELECT 	 D.ApplensOpportunityId	
				,D.ProjectId	
				,D.PlannedStartDate	
				,D.PlannedEndDate	
				,D.ActualEndDate	
				,D.ActualStartDate	
				,D.ReleasePlanName	
				,D.IsDeleted	
				,D.TicketType	
				,D.CreatedBy	
				,D.CreatedDate	
				,D.ModifiedBy	
				,D.ModifiedDate	
				,D.TriggeredDate	
				,0 ISpaceJobStatus	
				,getdate() ISpaceJobDate	
				,D.ISpaceStatus
				,D.ISpaceOpportunityId
				,PM.EsaProjectID
				FROM #DEBT_MAS_ReleasePlanDetails D  INNER JOIN AVL.MAS_ProjectMaster PM on PM.ProjectID=D.ProjectID AND PM.IsDeleted=0
	  SELECT DISTINCT HTD.ApplensIdeaId
      ,HTD.[ProjectPatternMapID]
      ,HTD.[HealingTicketID]
      ,HTD.[TicketType]
      ,HTD.[DARTStatusID]
      ,HTD.[Assignee]
      ,D.[ApplicationID]
      ,HTD.[OpenDate]
      ,HTD.[PriorityID]
      ,HTD.[IsManual]
      ,HTD.[IsPushed]
      ,HTD.[CreatedBy]
      ,HTD.[CreatedDate]
      ,HTD.[ModifiedBy]
      ,HTD.[ModifiedDate]
      ,HTD.[IsDeleted]
      ,HTD.[IsMappedToProblemTicket]
      ,HTD.[PlannedEffort]
      ,HTD.[HealTypeId]
      ,HTD.[PlannedStartDate]
      ,HTD.[PlannedEndDate]
      ,HTD.ApplensOpportunityId
      ,HTD.[TicketDescription]
	  , case WHEN HTD.SolutionType ='1,2,3' or HTD.SolutionType ='1,2' or HTD.SolutionType ='1,3' 
		then 'Both' WHEN HTD.SolutionType ='1' then 'Script' when  HTD.SolutionType ='2' or HTD.SolutionType ='2,3' or HTD.SolutionType ='3' 
		then 'Tool based' ELSE '' end SolutionType
	 ,0 SolutionTypeID-- ,ST.SolutionTypeID [SolutionType]
      ,HTD.[IsDormant]
      ,HTD.[DormantCreatedDate]
      ,HTD.[MarkAsDormant]
      ,HTD.[MarkAsDormantDate]
      ,HTD.[MarkAsDormantComments]
      ,HTD.[MarkAsDormantBy]
      ,HTD.[ReasonForRepetition]
      ,HTD.[ReasonForCancellation]
      ,HTD.[ActualEffortReduction]
      ,HTD.[PlannedEffortReduction]
      ,HTD.[Scope]
      ,HTD.[ImplementationStatus]
      ,HTD.[SavingsHardDollarActualCognizant]
      ,HTD.[SavingsHardDollarActualCustomer]
      ,HTD.[SavingsHardDollarPlannedCognizant]
      ,HTD.[SavingsHardDollarPlannedCustomer]
      ,HTD.[SavingsSoftDollarActualCognizant]
      ,HTD.[SavingsSoftDollarActualCustomer]
      ,HTD.[SavingsSoftDollarPlannedCognizant]
      ,HTD.[SavingsSoftDollarPlannedCustomer]
      ,HTD.[IsMandatory]
      ,HTD.[IncidentReductionMonth]
      ,HTD.[EffortReductionMonth]
	  ,PM.ProjectID
	  ,PM.EsaProjectID
	   ,HTD.TriggeredDate
	 , getdate() ISpaceJobDate
	 ,HTD.ISpaceIdeaId
	   FROM #DEBT_TRN_HealTicketDetails HTD INNER JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic D on HTD.[ProjectPatternMapID]=D.ProjectPatternMapID

	  INNER JOIN AVL.MAS_ProjectMaster PM on PM.ProjectID=D.ProjectID AND PM.IsDeleted=0
	  --LEFT JOIN AVL.TK_MAS_SolutionType ST on st.SolutionTypeID=HTD.SolutionType

SET NOCOUNT OFF; 	
	COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SET @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[ISpaceDataPushtoGateway]', @ErrorMessage, 0,0
END CATCH  

END
