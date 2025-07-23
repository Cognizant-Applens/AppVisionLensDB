
CREATE PROCEDURE [AVL].[SaveOnPremGovernanceMetrics]             
(            
@TVP_GovernanceData AVL.TVP_OnPremGovernanceMetrics READONLY         
)            
AS              
BEGIN              
BEGIN TRY  
BEGIN TRAN
SET NOCOUNT ON;
CREATE TABLE #tempGovernanceData(
	[AccountID] [varchar](1000) NOT NULL,
	[ProjectID] [varchar](1000) NOT NULL,
	--newly added
	[ProjectName] [varchar](1000) NOT NULL,
	[Month] [varchar](1000) NOT NULL,
	[Year] [varchar](1000) NOT NULL,
	[AllDebtClassifiedTicketCount] [varchar](1000) NULL,
	[EligibleTicketCountForDebtClassification] [varchar](1000) NULL,
	[MLDDAutoClassifiedTicketCount] [varchar](1000) NULL,
	[BoTTicketCount] [varchar](1000) NULL,
	[PartiallyAutomatedTicketCount] [varchar](1000) NULL,
	[ClosedATicketCount] [varchar](1000) NULL,
	[ClosedHTicketCount] [varchar](1000) NULL,
	[TotalEffortofChildATickets] [varchar](1000) NULL,
	[CompletedMonthsofATicket] [varchar](1000) NULL,
	[TotalEffortofChildHTickets] [varchar](1000) NULL,
	[CompletedMonthsofHTicket] [varchar](1000) NULL,
	[HChidTicketCount] [varchar](1000) NULL,
	[OperationalTicketCount] [varchar](1000) NULL,
	[KnowledgeTicketCount] [varchar](1000) NULL,
	[FunctionalTicketCount] [varchar](1000) NULL,
	[TechnicalTicketCount] [varchar](1000) NULL,
	[EnvironmentalTicketCount] [varchar](1000) NULL,
	[ResidualTicketCount] [varchar](1000) NULL,
	[CreatedATicketCount] [varchar](1000) NULL,
	[CreatedHTicketCount] [varchar](1000) NULL,
	[InProgressATicketCount] [varchar](1000) NULL,
	[InProgressHTicketCount] [varchar](1000) NULL,
	[DormantATicketsClosedCount] [varchar](1000) NULL,
	[DormantHTicketsClosedCount] [varchar](1000) NULL,
	[CancelledATicketCount] [varchar](1000) NULL,
	[CancelledHTicketCount] [varchar](1000) NULL,
	[AvoidableIncidentCount] [varchar](1000) NULL,
	[UnAvoidableIncidentCount] [varchar](1000) NULL
)
Insert into #tempGovernanceData
select * from @TVP_GovernanceData
MERGE #tempGovernanceData AS TGD
    using CustomerProjectMapping AS CPM 
    ON TRIM(CPM.OnPremProjectName)= TRIM(TGD.ProjectName) --CPM.OnpremAccountID = TGD.AccountID AND CPM.OnpremProjectID = TGD.ProjectID 
	AND CPM.IsDeleted = 0
   WHEN matched THEN    
UPDATE  
set TGD.ProjectID = CPM.EsaProjectID,TGD.AccountID =CPM.customerID; 
MERGE [AVL].[OnPremGovernanceMetrics] OG
    using #tempGovernanceData AS TVPGM 
    ON OG.AccountId = TVPGM.AccountID   AND OG.ProjectID = TVPGM.ProjectID AND OG.[Month] = charindex(TVPGM.Month,'JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC')/4+1 AND OG.[Year] =CAST(TVPGM.Year AS SMALLINT)  AND OG.IsDeleted = 0
    WHEN matched THEN   

			UPDATE SET       
				   OG.[AllDebtClassifiedTicketCount] = CAST(TVPGM.[AllDebtClassifiedTicketCount] AS INT)        
				   ,OG.[EligibleTicketCountForDebtClassification] = CAST(TVPGM.[EligibleTicketCountForDebtClassification] AS INT)    
				   ,OG.[MLDDAutoClassifiedTicketCount] = CAST(TVPGM.[MLDDAutoClassifiedTicketCount] AS INT)    
				   ,OG.[BoTTicketCount] = CAST(TVPGM.[BoTTicketCount] AS INT)    
				   ,OG.[PartiallyAutomatedTicketCount] = CAST(TVPGM.[PartiallyAutomatedTicketCount] AS INT)    
				   ,OG.[ClosedATicketCount] = CAST(TVPGM.[ClosedATicketCount] AS INT)    
				   ,OG.[ClosedHTicketCount] = CAST(TVPGM.[ClosedHTicketCount] AS INT)    
				   ,OG.[TotalEffortofChildATickets] = CAST(TVPGM.[TotalEffortofChildATickets] AS DECIMAL(18,2))        
				   ,OG.[CompletedMonthsofATicket] = CAST(TVPGM.[CompletedMonthsofATicket] AS INT)    
				   ,OG.[TotalEffortofChildHTickets] = CAST(TVPGM.[TotalEffortofChildHTickets] AS DECIMAL(18,2))        
				   ,OG.[CompletedMonthsofHTicket] = CAST(TVPGM.[CompletedMonthsofHTicket] AS INT)    
				   ,OG.[HChidTicketCount] = CAST(TVPGM.[HChidTicketCount] AS INT)    
				   ,OG.[OperationalTicketCount] = CAST(TVPGM.[OperationalTicketCount] AS INT)    
				   ,OG.[KnowledgeTicketCount] = CAST(TVPGM.[KnowledgeTicketCount] AS INT)    
				   ,OG.[FunctionalTicketCount] = CAST(TVPGM.[FunctionalTicketCount] AS INT)    
				   ,OG.[TechnicalTicketCount] = CAST(TVPGM.[TechnicalTicketCount] AS INT)    
				   ,OG.[EnvironmentalTicketCount] = CAST(TVPGM.[EnvironmentalTicketCount] AS INT)    
				   ,OG.[ResidualTicketCount] = CAST(TVPGM.[ResidualTicketCount] AS INT)    
				   ,OG.[CreatedATicketCount] = CAST(TVPGM.[CreatedATicketCount] AS INT)    
				   ,OG.[CreatedHTicketCount] = CAST(TVPGM.[CreatedHTicketCount] AS INT)    
				   ,OG.[InProgressATicketCount] = CAST(TVPGM.[InProgressATicketCount] AS INT)    
				   ,OG.[InProgressHTicketCount] = CAST(TVPGM.[InProgressHTicketCount] AS INT)    
				   ,OG.[DormantATicketsClosedCount] = CAST(TVPGM.[DormantATicketsClosedCount] AS INT)    
				   ,OG.[DormantHTicketsClosedCount] = CAST(TVPGM.[DormantHTicketsClosedCount] AS INT)    
				   ,OG.[CancelledATicketCount] = CAST(TVPGM.[CancelledATicketCount] AS INT)    
				   ,OG.[CancelledHTicketCount] = CAST(TVPGM.[CancelledHTicketCount] AS INT)    
				   ,OG.[AvoidableIncidentCount] = CAST(TVPGM.[AvoidableIncidentCount] AS INT)    
				   ,OG.[UnAvoidableIncidentCount] = CAST(TVPGM.[UnAvoidableIncidentCount] AS INT)    
				   ,OG.[ModifiedBy] = 'SYSTEM'        
				   ,OG.[ModifiedDate] = GETDATE()        
			 
	 WHEN NOT matched THEN       
			INSERT          
			   ([AccountID]        
			   ,[ProjectID]        
			   ,[Month]        
			   ,[Year]        
			   ,[AllDebtClassifiedTicketCount]        
			   ,[EligibleTicketCountForDebtClassification]        
			   ,[MLDDAutoClassifiedTicketCount]        
			   ,[BoTTicketCount]        
			   ,[PartiallyAutomatedTicketCount]        
			   ,[ClosedATicketCount]        
			   ,[ClosedHTicketCount]        
			   ,[TotalEffortofChildATickets]        
			   ,[CompletedMonthsofATicket]        
			   ,[TotalEffortofChildHTickets]        
			   ,[CompletedMonthsofHTicket]        
			   ,[HChidTicketCount]        
			   ,[OperationalTicketCount]        
			   ,[KnowledgeTicketCount]        
			   ,[FunctionalTicketCount]        
			   ,[TechnicalTicketCount]        
			   ,[EnvironmentalTicketCount]        
			   ,[ResidualTicketCount]        
			   ,[CreatedATicketCount]        
			   ,[CreatedHTicketCount]        
			   ,[InProgressATicketCount]        
			   ,[InProgressHTicketCount]        
			   ,[DormantATicketsClosedCount]        
			   ,[DormantHTicketsClosedCount]        
			   ,[CancelledATicketCount]        
			   ,[CancelledHTicketCount]        
			   ,[AvoidableIncidentCount]        
			   ,[UnAvoidableIncidentCount]        
			   ,[IsDeleted]        
			   ,[CreatedBy]        
			   ,[CreatedDate]  
			   ,[ModifiedBy]
			   ,[ModifiedDate]
			   )    
			   VALUES
			   (CAST(TVPGM.[AccountID] AS BIGINT)    
			   ,TVPGM.[ProjectID]        
			   ,charindex(TVPGM.Month,'JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC')/4+1
			   ,CAST(TVPGM.[Year] AS SMALLINT)    
			   ,CAST(TVPGM.[AllDebtClassifiedTicketCount] AS INT)    
			   ,CAST(TVPGM.[EligibleTicketCountForDebtClassification] AS INT)    
			   ,CAST(TVPGM.[MLDDAutoClassifiedTicketCount] AS INT)    
			   ,CAST(TVPGM.[BoTTicketCount] AS INT)    
			   ,CAST(TVPGM.[PartiallyAutomatedTicketCount] AS INT)    
			   ,CAST(TVPGM.[ClosedATicketCount] AS INT)    
			   ,CAST(TVPGM.[ClosedHTicketCount] AS INT)    
			   ,CAST(TVPGM.[TotalEffortofChildATickets] AS DECIMAL(18,2))    
			   ,CAST(TVPGM.[CompletedMonthsofATicket] AS INT)    
			   ,CAST(TVPGM.[TotalEffortofChildHTickets] AS DECIMAL(18,2))    
			   ,CAST(TVPGM.[CompletedMonthsofHTicket] AS INT)    
			   ,CAST(TVPGM.[HChidTicketCount] AS INT)    
			   ,CAST(TVPGM.[OperationalTicketCount] AS INT)    
			   ,CAST(TVPGM.[KnowledgeTicketCount] AS INT)    
			   ,CAST(TVPGM.[FunctionalTicketCount] AS INT)    
			   ,CAST(TVPGM.[TechnicalTicketCount] AS INT)    
			   ,CAST(TVPGM.[EnvironmentalTicketCount] AS INT)    
			   ,CAST(TVPGM.[ResidualTicketCount] AS INT)    
			   ,CAST(TVPGM.[CreatedATicketCount] AS INT)    
			   ,CAST(TVPGM.[CreatedHTicketCount] AS INT)    
			   ,CAST(TVPGM.[InProgressATicketCount] AS INT)    
			   ,CAST(TVPGM.[InProgressHTicketCount] AS INT)    
			   ,CAST(TVPGM.[DormantATicketsClosedCount] AS INT)    
			   ,CAST(TVPGM.[DormantHTicketsClosedCount] AS INT)    
			   ,CAST(TVPGM.[CancelledATicketCount] AS INT)    
			   ,CAST(TVPGM.[CancelledHTicketCount] AS INT)    
			   ,CAST(TVPGM.[AvoidableIncidentCount] AS INT)    
			   ,CAST(TVPGM.[UnAvoidableIncidentCount] AS INT)    
			   ,0          
			   ,'SYSTEM'          
			   ,GetDate(),
			   null,
			   null);  

SELECT 'Success' 
COMMIT TRAN
END TRY    
BEGIN CATCH  
DECLARE @ErrorMessage VARCHAR(MAX);    
SELECT @ErrorMessage = ERROR_MESSAGE()    
SELECT @ErrorMessage    
 ROLLBACK TRAN            
  --INSERT Error                  
  EXEC AVL_InsertError '[AVL].[SaveOnPremGovernanceMetrics]', @ErrorMessage, 0,0              
      SELECT 'Error'          
  END CATCH              
              
END
