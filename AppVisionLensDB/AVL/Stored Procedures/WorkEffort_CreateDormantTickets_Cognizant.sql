CREATE PROCEDURE [AVL].[WorkEffort_CreateDormantTickets_Cognizant]
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON; 		 
			DECLARE  @ID BIGINT = (SELECT JobID FROM MAS.JobMaster WHERE  JobName = 'Dormant Creation')
			INSERT INTO  MAS.JobStatus(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate) 
			VALUES (@ID,getdate(),'','',GETDATE(),0,'DormantTicket',GETDATE())
			DECLARE  @JobID bigint = (SELECT IDENT_CURRENT( 'MAS.JobStatus' )) 

		
			UPDATE AVL.DEBT_TRN_HealTicketDetails SET IsDormant = 1, DormantCreatedDate = GETDATE(), ModifiedDate=GETDATE(),ModifiedBy='System' FROM (
			SELECT HPC.ProjectPatternMapID,HPC.HealingTicketID AS AHTicketId, MAX(HPC.CreatedDate) AS LastCreateDate FROM AVL.DEBT_PRJ_HealProjectPatternMappingDynamic HPPM
			INNER JOIN AVL.DEBT_TRN_HealTicketDetails  HTD on HPPM.ProjectPatternMapID = HTD.ProjectPatternMapID
			INNER JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic PPMD ON HTD.ProjectPatternMapID = PPMD.ProjectPatternMapID
			INNER JOIN AVL.DEBT_PRJ_HealParentChild HPC ON HPPM.ProjectPatternMapID = HPC.ProjectPatternMapID AND HTD.HealingTicketID = HPC.HealingTicketID
			INNER JOIN AVL.MAS_LoginMaster LM ON LM.ProjectId = PPMD.ProjectID
			INNER JOIN AVL.Customer C ON LM.CustomerId = C.CustomerID
			WHERE (HTD.DARTStatusID not in(5,7,8,9,13) OR HTD.DARTStatusID IS NULL) AND HTD.IsDormant = 0 AND HTD.IsDeleted = 0 AND PPMD.IsDeleted = 0 
			AND C.IsCognizant = 1
			AND ISNULL(HTD.ManualNonDebt,0)<>1 AND ISNULL(PPMD.ManualNonDebt,0)<>1
			GROUP BY HPC.ProjectPatternMapID,HPC.HealingTicketID) AHT 
			WHERE AHT.LastCreateDate < (SELECT GETDATE() -90) AND HealingTicketID = AHT.AHTicketId	


			SELECT 
			ProjectPatternMapID,
			DHPPM.ProjectID,
			ApplicationID= (SELECT Item FROM [dbo].[StringSplit](HealPattern,'-') WHERE RowNumber = 1),
			ResolutionCode = (SELECT Item FROM [dbo].[StringSplit](HealPattern,'-') WHERE RowNumber = 2),
			CauseCode= (SELECT Item FROM [dbo].[StringSplit](HealPattern,'-') WHERE RowNumber = 3)		
			INTO #Heal_ProjectPatternMapping
			From  [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic](NOLOCK) DHPPM
			INNER JOIN [AVL].MAS_PROJECTMASTER(NOLOCK) PM ON DHPPM.ProjectID = PM.ProjectID AND PM.IsDeleted=0
			INNER JOIN AVL.Customer(NOLOCK) C ON PM.CustomerId = C.CustomerID AND C.IsDeleted = 0 
			WHERE PatternStatus = 1 AND C.IsCognizant = 1 AND DHPPM.IsDeleted = 0 
			AND ISNULL(ManualNonDebt,0)<>1

		   UPDATE DHTD
		   SET DHTD.IsDormant = 1, DHTD.DormantCreatedDate = GETDATE(), DHTD.ModifiedDate=GETDATE(),DHTD.ModifiedBy='System'
		   FROM [AVL].[DEBT_TRN_HealTicketDetails](NOLOCK) DHTD
		   INNER JOIN #Heal_ProjectPatternMapping DHPPM ON DHTD.ProjectPatternMapID=DHPPM.ProjectPatternMapID 	   
		   INNER JOIN [AVL].[APP_MAS_ApplicationDetails](NOLOCK) AD ON DHPPM.ApplicationID = AD.ApplicationID  
		   INNER JOIN [AVL].[DEBT_MAP_ResolutionCode](NOLOCK) DRC ON DHPPM.ResolutionCode = DRC.ResolutionID AND DRC.ProjectID = DHPPM.ProjectID
		   INNER JOIN [AVL].[DEBT_MAP_CauseCode](NOLOCK) MCC  ON DHPPM.CauseCode = MCC.CauseID AND MCC.ProjectID = DHPPM.ProjectID	   
		   WHERE (DHTD.DARTStatusID not in(5,7,8,9,13) OR DHTD.DARTStatusID IS NULL) 
				AND DHTD.IsDormant = 0 AND DHTD.IsDeleted = 0 
				AND ISNULL(DHTD.ManualNonDebt,0)<>1 AND (AD.IsActive = 0 OR DRC.IsDeleted = 1 OR MCC.IsDeleted = 1)
			
			INSERT INTO AVL.DEBT_TRN_HealTicketsLog (ProjectID,HealingTicketID,ActivityID,Priority,Assignee,Status,ProblemTicketID,
			NewHealingTicketID,ServiceID,ParentTicket,TableName,CreatedBy,CreatedDate,PlannedEffort,
			HealTypeId,PlannedStartDate,PlannedEndDate)
			SELECT DISTINCT PPMD.ProjectID,HTD.HealingTicketID, 25,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'AVL.DEBT_TRN_HealTicketDetails','system',GETDATE(),NULL,
				NULL,NULL,NULL FROM
				AVL.DEBT_TRN_HealTicketDetails HTD
				INNER JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic PPMD ON HTD.ProjectPatternMapID = PPMD.ProjectPatternMapID
				INNER JOIN AVL.MAS_LoginMaster LM ON LM.ProjectId = PPMD.ProjectID
				INNER JOIN AVL.Customer C ON LM.CustomerId = C.CustomerID
				WHERE HTD.IsDormant = 1 AND CONVERT(DATE, HTD.DormantCreatedDate) = CONVERT(DATE,GETDATE()) 
				AND C.IsCognizant = 1 AND HTD.IsDeleted = 0 AND PPMD.IsDeleted = 0		
				AND ISNULL(HTD.ManualNonDebt,0)<>1 AND ISNULL(PPMD.ManualNonDebt,0)<>1
					 
			UPDATE MAS.JobStatus set EndDateTime = GETDATE(),JobStatus = 'Success' where ID  = @JobID

		SET NOCOUNT OFF; 
END TRY
BEGIN CATCH
  UPDATE MAS.JobStatus set EndDateTime = GETDATE(),JobStatus = 'Failed' where ID  = @JobID
  DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[WorkEffort_CreateDormantTickets_Cognizant]', @ErrorMessage, '',''
		RETURN @ErrorMessage
  END CATCH   
END