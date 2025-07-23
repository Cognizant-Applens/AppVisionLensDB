
    
  
          
  /***************************************************************************                    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET                    
*Copyright [2018] – [2021] Cognizant. All rights reserved.                    
*NOTICE: This unpublished material is proprietary to Cognizant and                    
*its suppliers, if any. The methods, techniques and technical                    
  concepts herein are considered Cognizant confidential and/or trade secret information.                     
                      
*This material may be covered by U.S. and/or foreign patents or patent applications.                     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.                    
***************************************************************************/                    
-- =============================================                      
-- Author:  <Ram kumar>                      
-- Create date: <01/21/2019>                      
-- Description: <[Effort_OfflineHealTicketTableSyncup]>                      
-- =============================================                      
CREATE PROCEDURE [dbo].[Effort_OfflineHealTicketTableSyncup]                        
AS                      
                      
BEGIN                      
SET NOCOUNT ON;                    
BEGIN TRY                      
                      
 DECLARE @StartDateTime DATETIME                          
 DECLARE @EndDateTime DATETIME                          
 DECLARE @LastStartDateTime DATETIME                          
 DECLARE @HTktMasterMinDate DATETIME                          
 DECLARE @TicketInsert INT                               
 DECLARE @TicketUpdate INT                          
BEGIN TRAN                      
                      
   SET @StartDateTime = GETDATE()                          
      SELECT TOP 1 @LastStartDateTime = StartDateTime FROM [AVL].[TRN_HealOfflineSyncLog] (NOLOCK) ORDER BY StartDateTime DESC                  
                         
                         
  IF(@LastStartDateTime is NULL)                         
      BEGIN                          
            SELECT @HTktMasterMinDate =  MIN(ModifiedDate) FROM AVL.DEBT_TRN_HealTicketDetails(NOLOCK) Where  ISNULL(ManualNonDebt,0) != 1                               
   select @LastStartDateTime = @HTktMasterMinDate                         
      END                       
   SELECT @LastStartDateTime as lastrundate                      
                      
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
   LEFT JOIN AVL.BusinessClusterMapping  BCM2 (NOLOCK)  on bcm1.BusinessClusterMapID=BCM2.ParentBusinessClusterMapID AND                       
   BCM1.ParentBusinessClusterMapID IS NULL                      
 LEFT JOIN AVL.BusinessClusterMapping  BCM3 (NOLOCK) ON BCM2.BusinessClusterMapID=BCM3.ParentBusinessClusterMapID                      
   LEFT JOIN AVL.BusinessClusterMapping  BCM4 (NOLOCK) ON BCM3.BusinessClusterMapID=BCM4.ParentBusinessClusterMapID                      
   LEFT JOIN AVL.BusinessClusterMapping  BCM5 (NOLOCK) ON BCM4.BusinessClusterMapID=BCM5.ParentBusinessClusterMapID                      
   LEFT JOIN AVL.BusinessClusterMapping  BCM6 (NOLOCK) ON BCM5.BusinessClusterMapID=BCM6.ParentBusinessClusterMapID                      
   LEFT JOIN AVL.BusinessClusterMapping  BCM7 (NOLOCK) ON BCM6.BusinessClusterMapID=BCM7.ParentBusinessClusterMapID                      
   LEFT JOIN AVL.BusinessClusterMapping  BCM8 (NOLOCK) ON BCM7.BusinessClusterMapID=BCM8.ParentBusinessClusterMapID                      
   WHERE                      
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
                      
                      
   SET @TicketInsert =0                      
                      
   SET @TicketUpdate =0                      
                         
  SELECT HTD.*,HPPM.ApplicationID INTO #temptable FROM AVL.DEBT_TRN_HealTicketDetails HTD (NOLOCK)        
  INNER JOIN AVL.DEBT_PRJ_HealProjectPatternMappingDynamic HPPM (NOLOCK)                      
  ON HPPM.ProjectPatternMapID = HTD.ProjectPatternMapID                      
  WHERE (HTD.ModifiedDate is not null and HTD.ModifiedDate >= @LastStartDateTime) or                       
  (HTD.ModifiedDate is null and HTD.CreatedDate >=@LastStartDateTime) AND ISNULL(HTD.ManualNonDebt,0) != 1              
                        
  --select * from #temptable                      
  IF EXISTS (SELECT COUNT(*) FROM #temptable)                      
                        
  BEGIN                      
                        
    SET @TicketInsert = @@ROWCOUNT                        
                            
    DELETE TM FROM [ApplensOfflineQATUpgrade8.30to9.7.1].RPT.TK_TRN_HealTicketDetail TM INNER JOIN #temptable TTM ON TM.HealingTicketID = TTM.HealingTicketID                       
    inner join avl.APP_MAP_ApplicationProjectMapping Apm ON Apm.ApplicationID=TTM.ApplicationID AND TM.ProjectID = apm.ProjectID                      
                     
    --DELETE TM FROM [ApplensOfflineQATUpgrade8.30to9.7.1].RPT.TK_TRN_HealTicketDetail_Dashboard TM INNER JOIN #temptable TTM ON TM.HealingTicketID = TTM.HealingTicketID                       
    --inner join avl.APP_MAP_ApplicationProjectMapping Apm ON Apm.ApplicationID=TTM.ApplicationID AND TM.ProjectID = apm.ProjectID                      
                          
    SET @TicketUpdate = @@ROWCOUNT                       
        
 ---- New Model Algo - Getting the Unique DebtClassificationMapID with Count for each ProjectPatternMapID        
 --SELECT PPD.ProjectPatternMapID,        
 --TD.DebtClassificationMapID, COUNT(TD.DebtClassificationMapID) CountOfTickets         
 --INTO #Temp_Debt        
 --from avl.DEBT_PRJ_HealProjectPatternMappingDynamic PPD        
 --INNER JOIN avl.DEBT_PRJ_HealParentChild PC ON PPD.ProjectPatternMapID = PC.ProjectPatternMapID        
 --INNER JOIN AVL.TK_TRN_TicketDetail TD ON TD.ProjectID = PPD.ProjectID AND TD.TicketID = PC.DARTTicketID        
 --WHERE PPD.Algorithmkey = 'AL002'    
 --GROUP BY PPD.ProjectPatternMapID, TD.DebtClassificationMapID    
 --ORDER BY PPD.ProjectPatternMapID DESC    
                      
    CREATE TABLE #Heal_ProjectPatternMapping(                    
          [ProjectPatternMapID] [int] NULL,                      
          [ProjectID] [int] NOT NULL,                      
          [ApplicationID] [int] NOT NULL,                       
          [ResolutionCode] [bigint] NULL,                      
          [CauseCode] [bigint] NULL,                      
          [DebtClassificationId] [int] NULL,                      
    [AvoidableFlag] [int] NULL,                      
          --[ServiceID] INT NULL,                      
          --[NatureOfTheTicket] INT NULL,                      
          --[TechnologyId] BIGINT NULL,                      
          --[KEDBPath] VARCHAR(1000) NULL,                      
          [FlexField1] [Nvarchar](MAX)  NULL,                      
     [FlexField2] [Nvarchar](MAX)  NULL,                      
          [FlexField3] [Nvarchar](MAX)  NULL,                      
          [FlexField4] [Nvarchar](MAX)  NULL,                      
          --[TicketType] [char](1) NULL,                      
          [PatternFrequency] [int] NULL,                      
          [PatternStatus] [int] NULL,                      
          [IsDeleted] [char](1) NULL,                      
          [IsManual] [char](1) NULL,                      
          [ESAProjectID] [VARCHAR](100) NOT NULL                      
          )                        
                    
 -- Debt Rule Algo        
    INSERT INTO #Heal_ProjectPatternMapping                      
      Select ProjectPatternMapID                      
       ,ProjectID                      
       ,ApplicationID = ISNULL(xDim.value('/x[1]','varchar(max)'),0) --could change to desired datatype (int ?)                      
       ,ResolutionCode = xDim.value('/x[2]','varchar(max)')                       
       ,CauseCode = xDim.value('/x[3]','varchar(max)')                      
       ,DebtClassificationId = xDim.value('/x[4]','varchar(max)')                      
       ,AvoidableFlag = xDim.value('/x[5]','varchar(max)')                      
       --,ServiceID = xDim.value('/x[6]','varchar(max)')                     
       --,NatureOfTheTicket = xDim.value('/x[7]','varchar(max)')                      
       --,TechnologyId = xDim.value('/x[8]','varchar(max)')                      
       --,KEDBPath = xDim.value('/x[9]','varchar(max)')                      
       ,FlexField1 = xDim.value('/x[6]','varchar(max)')                      
       ,FlexField2 = xDim.value('/x[7]','varchar(max)')                    
       ,FlexField3 = xDim.value('/x[8]','varchar(max)')                      
       ,FlexField4 = xDim.value('/x[9]','varchar(max)')                      
       --,A.TicketType                      
       ,A.PatternFrequency                      
       ,A.PatternStatus                      
       ,A.IsDeleted                      
   ,A.IsManual                      
       ,A.EsaProjectID                      
      From  (Select ProjectPatternMapID AS ProjectPatternMapID,                       
       PPM.ProjectID AS ProjectID,                      
       Cast('<x>' + replace((select HealPattern as [text()]for xml path('')),'-','</x><x>')+'</x>' as xml) as xDim,                      
       PM.EsaProjectID,                      
       --TicketType AS TicketType,                      
       PatternFrequency, PatternStatus,                      
       IsManual, PPM.IsDeleted                      
      FROM  avl.DEBT_PRJ_HealProjectPatternMappingDynamic PPM (NOLOCK)                      
      JOIN avl.MAS_ProjectMaster PM (NOLOCK) ON PPM.ProjectID = PM.ProjectID AND PM.IsDeleted= PPM.IsDeleted                      
      WHERE PPM.IsDeleted = 0 AND ISNULL(PPM.ManualNonDebt,0) != 1  AND PPM.Algorithmkey = 'AL001'                    
      ) as A                        
        
 -- New Model Algo        
 INSERT INTO #Heal_ProjectPatternMapping                      
      Select ProjectPatternMapID                      
       ,ProjectID                      
       ,ApplicationID = ISNULL(xDim.value('/x[1]','varchar(max)'),0) --could change to desired datatype (int ?)                      
       ,ResolutionCode = 0                       
       ,CauseCode = 0                      
       ,DebtClassificationId =xDim.value('/x[10]','varchar(max)')                   
       ,AvoidableFlag = 0                   
       ,FlexField1 = xDim.value('/x[6]','varchar(max)')                      
       ,FlexField2 = xDim.value('/x[7]','varchar(max)')                      
       ,FlexField3 = xDim.value('/x[8]','varchar(max)')                      
       ,FlexField4 = xDim.value('/x[9]','varchar(max)')                            
       ,A.PatternFrequency                      
       ,A.PatternStatus                      
       ,A.IsDeleted                      
       ,A.IsManual                      
       ,A.EsaProjectID                      
      From  (Select ProjectPatternMapID AS ProjectPatternMapID,                       
       PPM.ProjectID AS ProjectID,                      
       Cast('<x>' + replace((select HealPattern as [text()]for xml path('')),'-','</x><x>')+'</x>' as xml) as xDim,                      
       PM.EsaProjectID,                      
       --TicketType AS TicketType,                      
       PatternFrequency, PatternStatus,                      
       IsManual, PPM.IsDeleted                      
      FROM  avl.DEBT_PRJ_HealProjectPatternMappingDynamic PPM (NOLOCK)                      
      JOIN avl.MAS_ProjectMaster PM (NOLOCK) ON PPM.ProjectID = PM.ProjectID AND PM.IsDeleted= PPM.IsDeleted                      
      WHERE PPM.IsDeleted = 0 AND ISNULL(PPM.ManualNonDebt,0) != 1 AND PPM.Algorithmkey = 'AL002'                     
      ) as A                           
            
    SELECT * FROM #temptable  (NOLOCK)                    
                    
    INSERT INTO [ApplensOfflineQATUpgrade8.30to9.7.1].[RPT].[TK_TRN_HealTicketDetail]                      
      ([ID]                      
      ,[ProjectPatternMapID]                      
      ,[BUID]                      
      ,[BUNAME]                      
      ,[CustomerID]                      
      ,[CustomerName]                      
      ,[CoreBusinessClusterID]                      
      ,[BusinessClusterLevel1]                      
      ,[BusinessClusterLevel1Name]                      
      ,[BusinessClusterLevel2]                      
      ,[BusinessClusterLevel2Name]                      
      ,[BusinessClusterLevel3]                      
      ,[BusinessClusterLevel3Name]                      
      ,[BusinessClusterLevel4]                      
      ,[BusinessClusterLevel4Name]                 
   ,[BusinessClusterLevel5]                      
      ,[BusinessClusterLevel5Name]                      
      ,[BusinessClusterLevel6]                      
      ,[BusinessClusterLevel6Name]                      
      ,[BusinessClusterLevel7]                      
      ,[BusinessClusterLevel7Name]                      
      ,[BusinessClusterLevel8]                      
      ,[BusinessClusterLevel8Name]                      
      ,[HealingTicketID]                      
      ,[ApplicationID]                      
   ,ApplicationName                      
      ,[ProjectID]                      
      ,[ESAProjectID]                      
      ,[ProjectName]                      
      ,[AssignedTo]                      
      ,[EmployeeID]                      
      ,[EmployeeName]                      
      ,[ServiceID]                      
      ,[ServiceName]                                 
      ,[IsDeleted]                      
      ,[CauseCodeMapID]                      
      ,[CauseCodeName]                      
      ,[DebtClassificationMapID]                      
      ,[DebtClassificationName]                      
      ,[ResolutionCodeMapID]                      
      ,[ResolutionCodeName]                      
      ,[PriorityMapID]                      
      ,[TicketType]                      
      ,[DARTStatusID]                      
      ,[DARTStatusName]                      
      ,[OpenDate]                      
      ,[PlannedEffort]                      
      ,[HealTypeid]                      
      ,[Avoidable]                      
      ,[PatterenStatus]                                 
      ,[PlannedStartDate]                      
      ,[PlannedEndDate]                      
      ,[InscopeOutScope]                      
      ,[IsManual]                      
      ,[IsPushed]                      
      ,[IsMappedToProblemTicket]                      
      ,[CreateDate]                      
      ,[CreatedBy]                      
      ,[ModifiedBy]                      
      ,[ModifiedDate]                      
      ,BuisnessCriticality                      
      ,IsCognizant                      
      ,Assignee                      
      ,PriorityID                      
      ,CreatedDate                      
      ,ReleasePlanning                      
      ,TicketDescription                      
      ,SolutionType                      
      ,DormantCreatedDate                      
      ,MarkAsDormantDate                      
      ,MarkAsDormantComments                      
      ,MarkAsDormantBy                      
      ,ReasonForRepetition                      
      ,ReasonForCancellation                      
      ,MTicketDescription                      
      ,IncidentReductionMonth                      
      ,EffortReductionMonth                      
      ,ActualEffortReduction                      
      ,PlannedEffortReduction                      
      ,Scope                      
      ,ImplementationStatus                      
      ,SavingsHardDollarActualCognizant                      
      ,SavingsHardDollarActualCustomer                      
      ,SavingsHardDollarPlannedCognizant                      
      ,SavingsHardDollarPlannedCustomer                      
      ,SavingsSoftDollarActualCognizant                      
      ,SavingsSoftDollarActualCustomer                      
      ,SavingsSoftDollarPlannedCognizant                      
      ,SavingsSoftDollarPlannedCustomer                      
      ,IsMandatory                      
      ,TriggeredDate                      
 ,ISpaceIdeaId                      
      ,Comments                      
      ,ImplementationEffort                      
      ,CancellationDate                      
      ,ManualNonDebt                      
      ,ActivityID                      
      ,ManualNonDebtMinDate                      
      ,ActivityName                      
      ,IsDormant           
      ,MarkAsDormant                      
      ,IsPartialAutomationHealTicket                      
      ,PartialAutomationTicketID                      
      )                      
                            
      SELECT TD.[Id],                      
       TD.[ProjectPatternMapID],                      
       bu.BUID,                      
       bu.BUName,                      
       c.CustomerID,                    
       c.CustomerName,                      
       ADS.SubBusinessClusterMapID AS SubBusinessClusterMapID,                      
       ISNULL(BCM.BusinessClusterLevel1,0) AS BusinessClusterLevel1,                      
       ISNULL(BCM.BusinessClusterLevel1Name,'') AS BusinessClusterLevel1Name,                      
       ISNULL(BCM.BusinessClusterLevel2,0) AS BusinessClusterLevel2 ,                      
       ISNULL(BCM.BusinessClusterLevel2Name,'') AS BusinessClusterLevel2Name,                      
       ISNULL(BCM.BusinessClusterLevel3,0) AS BusinessClusterLevel3,                      
       ISNULL(BCM.BusinessClusterLevel3Name,'') AS BusinessClusterLevel3Name,                      
       ISNULL(BCM.BusinessClusterLevel4,0) AS BusinessClusterLevel4,                      
       ISNULL(BCM.BusinessClusterLevel4Name,'') AS BusinessClusterLevel4Name,                      
       ISNULL(BCM.BusinessClusterLevel5,0) AS BusinessClusterLevel5,                      
       ISNULL(BCM.BusinessClusterLevel5Name,'') AS BusinessClusterLevel5Name,                      
       ISNULL(BCM.BusinessClusterLevel6,0) AS BusinessClusterLevel6,                      
       ISNULL(BCM.BusinessClusterLevel6Name,'') AS BusinessClusterLevel6Name,                      
       ISNULL(BCM.BusinessClusterLevel7,0) AS BusinessClusterLevel7,                      
       ISNULL(BCM.BusinessClusterLevel7Name,'') AS BusinessClusterLevel7Name,                      
       ISNULL(BCM.BusinessClusterLevel8,0) AS BusinessClusterLevel8,                      
       ISNULL(BCM.BusinessClusterLevel8Name,'') AS BusinessClusterLevel8Name,                      
       TD.[HealingTicketID],                      
       TD.[ApplicationID],                      
       ads.ApplicationName,                      
       ppm.ProjectID,                      
       ppm.ESAProjectID,                      
       pm.ProjectName,                       
       td.Assignee,                      
          LM.EmployeeID,                      
          LM.EmployeeName,                      
       Null,--PPM.[ServiceID],                      
       Null as ServiceName,--sm.ServiceName,                      
       TD.[IsDeleted],                      
       PPM.[CauseCode] as causecodemapid,                      
       dc.CauseCode as CauseCodeName,                       
       PPM.[DebtClassificationId],                      
       mdc.DebtClassificationName,                      
       ppm.ResolutionCode,                      
      rc.ResolutionCode as ResolutionCodeName,                      
       TD.[PriorityID],                      
       TD.TicketType,                      
       ISNULL(TD.[DARTStatusID],0),       
       ISNULL(DTS.DARTStatusName,'Not Assigned'),                      
       TD.[OpenDate],                      
       TD.[PlannedEffort],                      
       TD.[HealTypeid],                      
       ppm.AvoidableFlag,                      
       PPM.[PatternStatus],                      
       MR.PlannedStartDate,                      
       MR.PlannedEndDate,                      
       DCS.DebtcontrolScopeID as InScopeOutScope,                      
       TD.[IsManual],                      
       TD.[IsPushed],                      
       TD.[IsMappedToProblemTicket],                      
       TD.[CreatedDate],                      
       TD.[CreatedBy],                      
       TD.[ModifiedBy],                      
       TD.[ModifiedDate],                      
       bc.BusinessCriticalityName,                      
       C.IsCognizant,                      
       TD.Assignee,                      
       TD.PriorityID,                      
       TD.CreatedDate,                      
       TD.ReleasePlanning,                      
       TD.TicketDescription,                      
       TD.SolutionType,                      
       TD.DormantCreatedDate,                      
       TD.MarkAsDormantDate,                      
       TD.MarkAsDormantComments,                      
       TD.MarkAsDormantBy,                      
       TD.ReasonForRepetition,                      
       TD.ReasonForCancellation,                      
       TD.MTicketDescription,                      
       TD.IncidentReductionMonth,                      
       TD.EffortReductionMonth,                      
       TD.ActualEffortReduction,                      
       TD.PlannedEffortReduction,                      
       TD.Scope,                      
       TD.ImplementationStatus,                      
       TD.SavingsHardDollarActualCognizant,                      
       TD.SavingsHardDollarActualCustomer,                      
       TD.SavingsHardDollarPlannedCognizant,                      
       TD.SavingsHardDollarPlannedCustomer,                      
       TD.SavingsSoftDollarActualCognizant,                      
       TD.SavingsSoftDollarActualCustomer,                      
       TD.SavingsSoftDollarPlannedCognizant,                   TD.SavingsSoftDollarPlannedCustomer,                      
       TD.IsMandatory,                      
       TD.TriggeredDate,                      
       TD.ISpaceIdeaId,                      
       TD.Comments,                      
       TD.ImplementationEffort,                      
       TD.CancellationDate,                      
       TD.ManualNonDebt,                      
       TD.ActivityID,                      
       TD.ManualNonDebtMinDate,                      
       TD.ActivityName,                      
       TD.IsDormant,                      
       TD.MarkAsDormant,                      
       TD.IsPartialAutomationHealTicket,                      
       TD.PartialAutomationTicketID                      
        FROM #temptable TD                         
       LEFT JOIN #Heal_ProjectPatternMapping PPM (NOLOCK) ON TD.ProjectPatternMapID=PPM.ProjectPatternMapID                      
       LEFT JOIN avl.APP_MAP_ApplicationProjectMapping scope (NOLOCK) ON PPM.ProjectID = scope.ProjectID AND PPM.ApplicationId = scope.ApplicationId AND scope.IsDeleted = 0                      
       LEFT JOIN avl.APP_MAS_ApplicationDetails ADS (NOLOCK) ON PPM.ApplicationID= ADS.ApplicationID                      
       LEFT JOIN avl.APP_MAS_DebtcontrolScope DCS (NOLOCK) ON ADS.DebtControlScopeID =DCS.DebtcontrolScopeID                      
       LEFT JOIN avl.DEBT_MAP_CauseCode dc (NOLOCK) ON PPM.causecode=dc.CauseID  AND dc.isdeleted = 0                      
       LEFT JOIN  avl.DEBT_MAP_ResolutionCode rc (NOLOCK) ON PPM.resolutioncode =rc.ResolutionID AND rc.isdeleted = 0                      
       LEFT JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON ppm.ProjectID =PM.ProjectID              
       LEFT JOIN AVL.MAS_LoginMaster LM (NOLOCK) ON TD.Assignee=LM.UserID                      
       LEFT JOIN AVL.Customer C (NOLOCK) ON  PM.CustomerID=C.CustomerID                       
       LEFT JOIN AVL.BusinessUnit BU (NOLOCK) ON C.BUID =BU.BUID                      
       LEFT JOIN #BusinessClusterMapping BCM (NOLOCK) ON ADS.SubBusinessClusterMapID=BCM.CoreBusinessClusterID                      
       --LEFT JOIN AVL.TK_MAS_ServiceMapping sm on ppm.ServiceID=sm.ServiceID                      
       LEFT JOIN AVL.DEBT_MAS_DebtClassification mdc (NOLOCK) on ppm.DebtClassificationId = mdc.DebtClassificationID                        
       LEFT JOIN AVL.APP_MAS_BusinessCriticality bc (NOLOCK) on ads.BusinessCriticalityID = bc.BusinessCriticalityID                      
       LEFT JOIN AVL.TK_MAS_DARTTicketStatus DTS (NOLOCK) on TD.DARTStatusID = DTS.DARTStatusID                      
       LEFT JOIN AVL.DEBT_MAS_ReleasePlanDetails MR (NOLOCK) ON MR.Id=TD.ReleasePlanning                       
                  AND MR.ProjectId=PPM.ProjectID AND MR.IsDeleted<>1                          
                      
                      
   DELETE TM FROM [ApplensOfflineQATUpgrade8.30to9.7.1].RPT.TK_TRN_HealTicketDetail_Dashboard TM INNER JOIN #temptable TTM (NOLOCK) ON TM.HealingTicketID = TTM.HealingTicketID                       
      inner join avl.APP_MAP_ApplicationProjectMapping Apm (NOLOCK) ON Apm.ApplicationID=TTM.ApplicationID AND TM.ProjectID = apm.ProjectID                      
    --select * from [ApplensOfflineQATUpgrade8.30to9.7.1].[RPT].[TK_TRN_HealTicketDetail_Dashboard]                      
                      
    --select * from [ApplensOfflineQATUpgrade8.30to9.7.1].[RPT].[TK_TRN_HealTicketDetail]                 
                      
 INSERT INTO [ApplensOfflineQATUpgrade8.30to9.7.1].[RPT].[TK_TRN_HealTicketDetail_Dashboard]                      
      ([ID]           
      ,[ProjectPatternMapID]                      
      ,[BUID]                      
      ,[BUNAME]                      
      ,[CustomerID]                      
      ,[CustomerName]                      
      ,[CoreBusinessClusterID]                      
      ,[BusinessClusterLevel1]                      
      ,[BusinessClusterLevel1Name]                      
      ,[BusinessClusterLevel2]                      
      ,[BusinessClusterLevel2Name]                      
      ,[BusinessClusterLevel3]                      
      ,[BusinessClusterLevel3Name]                      
      ,[BusinessClusterLevel4]                      
      ,[BusinessClusterLevel4Name]                      
      ,[BusinessClusterLevel5]                      
      ,[BusinessClusterLevel5Name]                      
      ,[BusinessClusterLevel6]                      
      ,[BusinessClusterLevel6Name]                      
      ,[BusinessClusterLevel7]                      
     ,[BusinessClusterLevel7Name]                      
      ,[BusinessClusterLevel8]                      
      ,[BusinessClusterLevel8Name]                      
      ,[HealingTicketID]                      
      ,[ApplicationID]                      
      ,ApplicationName                      
      ,[ProjectID]                      
      ,[ESAProjectID]                      
      ,[ProjectName]                      
      ,[AssignedTo]                      
      ,[EmployeeID]                      
      ,[EmployeeName]                      
      ,[ServiceID]                      
      ,[ServiceName]                                 
      ,[IsDeleted]                      
      ,[CauseCodeMapID]                      
      ,[CauseCodeName]                      
      ,[DebtClassificationMapID]                      
      ,[DebtClassificationName]                      
      ,[ResolutionCodeMapID]                      
      ,[ResolutionCodeName]                      
      ,[PriorityMapID]                      
      ,[TicketType]                      
      ,[DARTStatusID]                      
      ,[DARTStatusName]                      
      ,[OpenDate]                      
      ,[PlannedEffort]                      
      ,[HealTypeid]                      
      ,[Avoidable]                      
      ,[PatterenStatus]                                 
      ,[PlannedStartDate]                      
      ,[PlannedEndDate]                      
      ,[InscopeOutScope]                      
      ,[IsManual]                      
      ,[IsPushed]                      
      ,[IsMappedToProblemTicket]                      
      ,[CreateDate]                      
      ,[CreatedBy]                      
      ,[ModifiedBy]                      
      ,[ModifiedDate]                      
      ,BuisnessCriticality                      
      ,BlendedRateCost                      
      ,Price                      
      ,EffortTillDate                        
      ,AvoidableResidual                      
      ,UnAvoidable                      
      ,UnAvoidableResidual                      
      ,ProblemTicketID                      
      ,IncidentEffort                      
      ,TicketCount                      
      ,ActualEndDate                      
      ,IsCognizant                      
      ,Assignee                      
      ,PriorityID                      
      ,CreatedDate                      
      ,ReleasePlanning                      
      ,TicketDescription                  
      ,SolutionType                      
      ,DormantCreatedDate                      
      ,MarkAsDormantDate                      
      ,MarkAsDormantComments                      
      ,MarkAsDormantBy                      
      ,ReasonForRepetition                      
      ,ReasonForCancellation                      
      ,MTicketDescription                      
      ,IncidentReductionMonth                      
      ,EffortReductionMonth                      
      ,ActualEffortReduction                      
      ,PlannedEffortReduction                      
      ,Scope                      
      ,ImplementationStatus                      
      ,SavingsHardDollarActualCognizant                      
      ,SavingsHardDollarActualCustomer                      
      ,SavingsHardDollarPlannedCognizant                      
      ,SavingsHardDollarPlannedCustomer                      
      ,SavingsSoftDollarActualCognizant                      
      ,SavingsSoftDollarActualCustomer                      
      ,SavingsSoftDollarPlannedCognizant                      
      ,SavingsSoftDollarPlannedCustomer                      
      ,IsMandatory                      
      ,TriggeredDate                      
      ,ISpaceIdeaId                      
      ,Comments                      
      ,ImplementationEffort                  
      ,CancellationDate                      
      ,ManualNonDebt                      
      ,ActivityID                      
      ,ManualNonDebtMinDate                      
      ,ActivityName                      
      ,IsDormant                      
      ,MarkAsDormant                      
      ,IsPartialAutomationHealTicket                      
      ,PartialAutomationTicketID                      
      )                      
                            
      SELECT TD.[Id],                      
       TD.[ProjectPatternMapID],                      
       TD.BUID,                      
  TD.BUName,                      
       TD.CustomerID,                      
       TD.CustomerName,                      
       TD.CoreBusinessClusterID AS SubBusinessClusterMapID,                      
       ISNULL(TD.BusinessClusterLevel1,0) AS BusinessClusterLevel1,                      
       ISNULL(TD.BusinessClusterLevel1Name,'') AS BusinessClusterLevel1Name,                      
       ISNULL(TD.BusinessClusterLevel2,0) AS BusinessClusterLevel2 ,                      
       ISNULL(TD.BusinessClusterLevel2Name,'') AS BusinessClusterLevel2Name,                      
  ISNULL(TD.BusinessClusterLevel3,0) AS BusinessClusterLevel3,                  
       ISNULL(td.BusinessClusterLevel3Name,'') AS BusinessClusterLevel3Name,                      
       ISNULL(td.BusinessClusterLevel4,0) AS BusinessClusterLevel4,                      
       ISNULL(td.BusinessClusterLevel4Name,'') AS BusinessClusterLevel4Name,                      
       ISNULL(td.BusinessClusterLevel5,0) AS BusinessClusterLevel5,                      
       ISNULL(td.BusinessClusterLevel5Name,'') AS BusinessClusterLevel5Name,                      
       ISNULL(td.BusinessClusterLevel6,0) AS BusinessClusterLevel6,                      
       ISNULL(td.BusinessClusterLevel6Name,'') AS BusinessClusterLevel6Name,                      
       ISNULL(td.BusinessClusterLevel7,0) AS BusinessClusterLevel7,                      
       ISNULL(td.BusinessClusterLevel7Name,'') AS BusinessClusterLevel7Name,                      
       ISNULL(td.BusinessClusterLevel8,0) AS BusinessClusterLevel8,                      
       ISNULL(td.BusinessClusterLevel8Name,'') AS BusinessClusterLevel8Name,                      
       TD.[HealingTicketID],                      
       TD.[ApplicationID],                      
       td.ApplicationName,                     
       td.ProjectID,                      
       td.ESAProjectID,                      
       TD.ProjectName,                       
       TD.[AssignedTo],                      
          TD.EmployeeID,                      
          TD.EmployeeName,                      
       TD.[ServiceID],                      
       Null as ServiceName,--sm.ServiceName,                      
       TD.[IsDeleted],                      
       TD.CauseCodeMapID as causecodemapid,                      
       TD.[CauseCodeName] as CauseCodeName,                       
       TD.[DebtClassificationMapID],                      
       TD.[DebtClassificationName],                      
       TD.ResolutionCodeMapID,                      
       TD.[ResolutionCodeName] as ResolutionCodeName,                      
       TD.[PriorityMapID],                      
       TD.TicketType,                      
       TD.[DARTStatusID],                      
       TD.[DARTStatusName],                      
       TD.[OpenDate],                      
       TD.[PlannedEffort],                      
       TD.[HealTypeid],                      
       TD.[Avoidable],                      
       TD.PatterenStatus,                      
       TD.PlannedStartDate,                      
       TD.PlannedEndDate,                      
       TD.[InscopeOutScope] as InScopeOutScope,                      
       TD.[IsManual],                      
       TD.[IsPushed],                      
       TD.[IsMappedToProblemTicket],                      
       TD.[CreateDate],                      
       TD.[CreatedBy],                      
       TD.[ModifiedBy],                      
       TD.[ModifiedDate],                      
       TD.BuisnessCriticality ,                      
       TD.BlendedRateCost,                      
       TD.Price,                      
       td.EffortTillDate,                             
       td.AvoidableResidual,                      
       td.UnAvoidable,                      
       td.UnAvoidableResidual,                      
       td.ProblemTicketID,                      
       td.IncidentEffort,                      
       td.TicketCount,                      
       td.ActualEndDate,                           
       td.IsCognizant,                      
       TD.Assignee,                      
       TD.PriorityID,                      
       TD.CreatedDate,                      
       TD.ReleasePlanning,                      
       TD.TicketDescription,                      
       TD.SolutionType,                      
       TD.DormantCreatedDate,                      
       TD.MarkAsDormantDate,                      
       TD.MarkAsDormantComments,                      
       TD.MarkAsDormantBy,                      
       TD.ReasonForRepetition,                      
   TD.ReasonForCancellation,                      
       TD.MTicketDescription,                      
       TD.IncidentReductionMonth,                      
       TD.EffortReductionMonth,                      
       TD.ActualEffortReduction,                      
       TD.PlannedEffortReduction,                      
       TD.Scope,                      
       TD.ImplementationStatus,                      
       TD.SavingsHardDollarActualCognizant,                      
       TD.SavingsHardDollarActualCustomer,                      
       TD.SavingsHardDollarPlannedCognizant,                      
       TD.SavingsHardDollarPlannedCustomer,                      
       TD.SavingsSoftDollarActualCognizant,                      
       TD.SavingsSoftDollarActualCustomer,                
       TD.SavingsSoftDollarPlannedCognizant,                      
       TD.SavingsSoftDollarPlannedCustomer,                      
       TD.IsMandatory,                      
       TD.TriggeredDate,                      
       TD.ISpaceIdeaId,                      
       TD.Comments,                      
       TD.ImplementationEffort,                      
       TD.CancellationDate,                      
       TD.ManualNonDebt,                    
       TD.ActivityID,                      
       TD.ManualNonDebtMinDate,                      
       TD.ActivityName,                      
       TD.IsDormant,                      
       TD.MarkAsDormant,                      
       TD.IsPartialAutomationHealTicket,                      
       TD.PartialAutomationTicketID                      
       from [ApplensOfflineQATUpgrade8.30to9.7.1].[RPT].[TK_TRN_HealTicketDetail] TD (NOLOCK) WHERE (TD.ModifiedDate is not null and TD.ModifiedDate >= @LastStartDateTime) or (TD.ModifiedDate is null and TD.CreateDate >=@LastStartDateTime)               
  
    
       
                                 
EXEC [dbo].[Effort_OfflineUpdateHealTicketCostPrice]                      
                      
     --SELECT * FROM #PatternMappingCollection pmc LEFT JOIN AVL.MAS_LoginMaster                       
     --LM ON pmc.Assignee=LM.UserID -- LEFT JOIN AVL.DEBT_MAS_DebtClassification mdc on pmc.DebtClassificationId = mdc.DebtClassificationID--LEFT JOIN AVL.TK_MAS_ServiceMapping sm o                      
     --n pmc.ServiceID=sm.ServiceID                       
                      
    -- select * from #patternmappingCollection                      
    -- select * from #temptable where healingTicketID='HivPro00000002'                      
    -- select * from #Heal_ProjectPatternMapping                      
    -- drop table #patternmappingCollection                      
    DROP TABLE #temptable                      
    DROP TABLE #BusinessClusterMapping                      
                      
                          
                      
  END                      
                         
   SET @EndDateTime = GETDATE()                       
                      
   INSERT INTO [AVL].[TRN_HealOfflineSyncLog]  VALUES(@TicketInsert - @TicketUpdate , @TicketUpdate ,NULL ,NULL , @StartDateTime ,@EndDateTime,0,NULL,GETDATE(),NULL,NULL)                              
                      
   COMMIT TRAN                      
                      
 END TRY                        
                      
 BEGIN CATCH                        
                      
  DECLARE @ErrorMessage VARCHAR(MAX);                      
                      
  SELECT @ErrorMessage = ERROR_MESSAGE()                      
                      
  SELECT @ErrorMessage as ErrorMessage                      
                      
  ROLLBACK TRAN                      
                      
  --INSERT Error                          
  EXEC AVL_InsertError '[dbo].[Effort_OfflineHealTicketTableSyncup]', @ErrorMessage, 0,0                      
                      
                        
                      
 DECLARE @Subjecttext VARCHAR(max);                        
 DECLARE @tableHTML  VARCHAR(MAX);         
                      
 SET @Subjecttext = 'Production - A/H Offline Import Job failure in Step 5'                      
 SET @tableHTML ='<html style="width:auto !important">'+                      
   '<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">'+                      
   '<table width="650" face="Times New Roman,serif" border="0" cellpadding="0" cellspacing="0" style="margin-left:60px;font-family:sans-serif;font-size:14px;font-weight:normal">'+                      
   '<tbody>'+                      
   '<tr>'+                      
   '<td valign="top" style="padding: 0;">'+                      
   '<div align="center" style="text-align: center;">'+                      
   '<table width="650" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">'+                      
   '<tbody>'+                      
     '<tr style="height:50px">'+                      
                                    '<td width="auto" valign="top" align="center">'+                      
                                     '<img src="\\CTSC01165050301\WeeklyUAT\ApplensBanner.png" width="700" height="50" style="border-width: 0px;"/>'+                      
                                    '</td>'+                      
    '</tr>'+                      
                          
     '<tr style="background-color:#F0F8FF">'+                      
                                    '<td valign="top" style="padding: 0;">'+                      
                                        '<div align="center" style="text-align: center;margin-left:50px">'+                      
        '<table width="650" border="0" cellpadding="0" cellspacing="0" style="font-family:sans-serif;font-size:14px;font-weight:normal">'+                      
                                                                     
    '<tbody>'+                      
             '</br>'+                      
                                                                        
             N'<left>                       
                                  
          <font-weight:normal>                      
                                
           Hi All,'                      
           + '</BR>'                      
           +'&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp'                      
           +'</BR>'                      
           +'Automation/Healing Ticket Offline Job failure in '                      
            +'<font color="#000000"><b>Step 5 - [dbo].[Effort_OfflineHealTicketTableSyncup]</b></font>'                      
           +'</BR>'                      
           +'</BR>'                      
           +'Exception Message: '+@ErrorMessage+                      
           +'</BR>'                      
           +'</BR>'                      
           +'Requesting you to check this issue details in Errors log table'                      
           +'</BR>'                      
           +'</BR>'                      
 +'PS : This is system generated mail, please do not reply to this mail.'                      
           +'</font>                        
        </Left>'                       
                  +                      
          N'                      
                              
        <p align="left">                  
        <font color="Black" Size = "2" font-weight=bold>                        
        <b> Thanks & Regards,</b>                      
         </font>                       
         </BR>                      
         Solution Zone Team                         
          </BR>                      
          </BR>                      
           <font size="1">                              
       **This is an Auto Generated Mail. Please Do not reply to this mail**                      
       </font>                      
       </p>' +                         
                             
                      
   '</tbody>'+                      
                                            '</table>'+                      
                '</div>'+                      
                                   '</td>'+                      
                                '</tr>'+                      
   '</tbody>'+                      
   '</table>'+                      
   '</div>'+                      
   '</td>'+                      
   '</tr>'+                      
   '</tbody>'+                      
   '</table>'+                      
   '</body>' +                      
   '</html>'                      
                         
   -----------executing mail-------------                      
      DECLARE @recipientsAddress NVARCHAR(4000)='';                
            SET @recipientsAddress = (SELECT ConfigValue FROM AVL.AppLensConfig (NOLOCK) WHERE ConfigName='Mail' AND IsActive=1);                         
   EXEC [AVL].[SendDBEmail] @To=@recipientsAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@Subjecttext,
    @Body = @tableHTML
                      
                        
 END CATCH                        
  SET NOCOUNT OFF;                    
END


