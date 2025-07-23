/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
    
CREATE   PROCEDURE [AVL].[Effort_GetSearchTickets]  
--'242330','4/1/2025','4/2/2025',1,null,null,null,null,null,null,null,null,null,null,null,null,7097,1,0
(    
       @ProjectIDs NVARCHAR(MAX),    
       @StartDate DATE = NULL,    
       @EndDate DATE = NULL,    
       @IsFilterByOpenDate BIT = 1,    
       @Hierarchy1IDs NVARCHAR(MAX) = NULL,    
       @Hierarchy2IDs NVARCHAR(MAX) = NULL,    
       @Hierarchy3IDs NVARCHAR(MAX) = NULL,    
       @Hierarchy4IDs NVARCHAR(MAX) = NULL,    
       @Hierarchy5IDs NVARCHAR(MAX) = NULL,    
       @Hierarchy6IDs NVARCHAR(MAX) = NULL,    
       @ApplicationIDs NVARCHAR(MAX) = NULL,    
       @TicketStatusIDs NVARCHAR(MAX) = NULL,    
       @TicketSourceIDs NVARCHAR(5) = NULL,    
       @TicketTypeIDs NVARCHAR(MAX) = NULL,    
       @TicketingData NVARCHAR(5) = NULL, -- 1 - Tickets with Efforts and 2 - Tickets without Efforts and 3 - Unassigned tickets    
       @DataEntryCompletion NVARCHAR(5) = NULL, -- 1 -> Yes and 0 - No    
    @CustomerID BIGINT = 0,    
    @IsCognizant INT = 1,    
    @IsInfra bit = NULL    
)    
AS    
BEGIN    
SET NOCOUNT ON;  
      BEGIN TRY    
    
    --------------Temp Table Project ID-----------------    
 SELECT     
  P.Item, PM.ProjectName     
 INTO     
  #ProjectTable     
 FROM     
  dbo.Split(@ProjectIDs, ',') P    
 INNER JOIN    
  AVL.MAS_ProjectMaster (NOLOCK) PM    
 ON    
  PM.ProjectID = P.Item     
    
     
 DECLARE @SMTicket VARCHAR(20) = 'SM Ticket',    
                           @ApplensTicket VARCHAR(20) = 'Applens Ticket'    
    
                     DECLARE       @StartDate1 varchar(20) =(SELECT convert(varchar, @StartDate, 101))    
                     DECLARE       @EndDate1 varchar(20)=(SELECT convert(varchar, @EndDate, 101))    
    
              -- Set Start Date as first Day of current month and year by default.    
              IF @StartDate1 IS NULL    
              BEGIN    
                     SET @StartDate1 = CONVERT(VARCHAR(25), DATEADD(dd,-(DAY(GETDATE())-1),GETDATE()), 101)    
              END    
    
              -- Set End Date as current date by default.    
              IF @EndDate1 IS NULL    
              BEGIN    
                     SET @EndDate1 = CONVERT(VARCHAR(25), GETDATE(), 101)    
              END    
    
 SELECT Item INTO #TicketTypeIDs FROM dbo.Split(@TicketTypeIDs, ',')    
    
    SELECT     
  L.EmployeeName,    
  L.UserID,    
        L.ClientUserID,    
  L.IsDeleted     
 INTO     
  #LoginTemp    
 FROM     
  AVL.MAS_LoginMaster (NOLOCK) L    
 INNER JOIN    
  #ProjectTable P     
 ON    
  P.Item = L.ProjectID     
    
IF (@IsInfra = 0)    
BEGIN     
    
 -- PF Implemented Inner Join --    
 SELECT     
  A.HealingTicketID     
 INTO     
  #DormantTicketList     
 FROM      
  AVL.DEBT_TRN_HealTicketDetails(NOLOCK) A     
 INNER JOIN     
  AVL.DEBT_PRJ_HealProjectPatternMappingDynamic(NOLOCK) D     
 ON     
  D.ProjectPatternMapID = A.ProjectPatternMapID     
 INNER JOIN    
  #ProjectTable P (NOLOCK)    
 ON    
  P.Item = D.ProjectID    
 WHERE     
  A.MarkAsDormant=1 AND A.IsDeleted<>1 AND ISNULL(D.ManualNonDebt,0) != 1 AND ISNULL(A.ManualNonDebt,0) != 1     
 ------------------------------------------------------------    
                  
 SELECT      
  TH.HealingTicketID,    
  TD.[Type],    
  TD.ActualDuration,     
  TD.ActualEndDateTime,     
  TD.ActualStartDateTime,                         
  TD.ActualWorkSize,                         
  TD.ApplicationID,    
  TD.ApprovedBy,     
  TD.AssignedTo,    
  TD.AvoidableFlag,     
  TD.CancelledDateTime,     
  TD.Category,    
  TD.CauseCodeMapID,    
  TD.ClosedDate,    
  TD.Comments,                         
  TD.CompletedDateTime,     
  TD.DARTStatusID,     
  TD.DebtClassificationMapID,     
  TD.EffortTillDate,    
  TD.ElevateFlagInternal,     
  TD.EscalatedFlagCustomer,     
  TD.EstimatedWorkSize,     
  TD.FlexField1,    
  TD.FlexField2,    
  TD.FlexField3,    
  TD.FlexField4,    
  TD.IsAttributeUpdated,    
  TD.IsDeleted,    
  TD.IsManual,     
  TD.IsSDTicket,    
  TD.KEDBAvailableIndicatorMapID,                         
  TD.KEDBPath,     
  TD.KEDBUpdatedMapID,     
  TD.MetAcknowledgementSLAMapID,    
  TD.MetResolutionMapID,     
  TD.MetResponseSLAMapID,                        
  TD.NatureOfTheTicket,     
  TD.NewStatusDateTime,     
  TD.OnHoldDateTime,     
  TD.OpenDateTime,    
  TD.OutageDuration,                         
  TD.PlannedEffort,     
  TD.PlannedEndDate,     
  TD.PlannedStartDate,     
  TD.PriorityMapID,     
  TD.ProjectID,    
  TD.RCAID,     
  TD.RejectedDateTime,     
  TD.RelatedTickets,     
  TD.ReleaseTypeMapID,     
  TD.ReopenDateTime,     
  TD.RepeatedIncident,     
  TD.ResidualDebtMapID,                        
  TD.ResolutionCodeMapID,     
  TD.ResolutionRemarks,    
  TD.ServiceID,     
  TD.SeverityMapID,                         
  TD.StartedDateTime,     
  TD.TicketCreatedBy,     
  TD.TicketDescription,     
  TD.TicketID,     
  TD.TicketStatusMapID,                      
  TD.TicketTypeMapID,    
  TD.WIPDateTime,    
  P.ProjectName                        
 INTO     
  #TicketTemp      
 FROM [AVL].TK_TRN_TicketDetail TD (NOLOCK)     
 LEFT JOIN    
  #DormantTicketList TH    
 ON     
  TD.TicketID = TH.HealingTicketID    
 INNER JOIN      
  #ProjectTable P     
 ON     
  P.Item = TD.ProjectID    
 WHERE    
  TD.IsDeleted = 0    
  AND TH.HealingTicketID IS NULL     
    
              -- Get Projects, Applications and Last Level Hierarchy IDs which is tagged to Application.    
 SELECT PM.ProjectID, PM.ProjectName, AD.ApplicationID, AD.ApplicationName,     
                     BM.BusinessClusterMapID, BM.BusinessClusterBaseName, BM.ParentBusinessClusterMapID,    
                     BM.IsHavingSubBusinesss      
              INTO #ProjectApplicationLastHierarchyDetails    
              FROM [AVL].MAS_ProjectMaster (NOLOCK) PM    
              JOIN [AVL].APP_MAP_ApplicationProjectMapping (NOLOCK) APM    
                     ON APM.ProjectID = PM.ProjectID AND APM.IsDeleted = 0     
              JOIN [AVL].APP_MAS_ApplicationDetails (NOLOCK) AD     
       ON AD.ApplicationId = APM.ApplicationID AND AD.IsActive = 1    
              JOIN [AVL].BusinessClusterMapping (NOLOCK) BM    
                     ON BM.BusinessClusterMapID = AD.SubBusinessClusterMapID     
                           AND BM.CustomerID = PM.CustomerID AND BM.IsDeleted = 0    
 INNER JOIN     
  #ProjectTable P     
 ON    
  P.Item = PM.ProjectID    
 WHERE    
 BM.CustomerID = @CustomerID AND BM.IsDeleted =0    
 AND (ISNULL(@ApplicationIDs,'') = '' OR     
                           APM.ApplicationID IN (SELECT Item FROM dbo.Split(@ApplicationIDs, ',')))    
       
              -- Get Hierarchy 1 IDs (Top Most Parent IDs) for each selected projects and applications.    
              ;WITH CTE     
              AS    
              (    
                     SELECT ProjectID,    
                                  ApplicationID,    
                       BusinessClusterMapID,     
                                  BusinessClusterBaseName,    
                                  ParentBusinessClusterMapID,    
                                  IsHavingSubBusinesss     
                     FROM #ProjectApplicationLastHierarchyDetails  (NOLOCK)  
                     UNION ALL    
                     SELECT CTE.ProjectID,    
                                  CTE.ApplicationID,    
                                  BCM.BusinessClusterMapID,     
           BCM.BusinessClusterBaseName,    
                                  BCM.ParentBusinessClusterMapID,    
                                  BCM.IsHavingSubBusinesss     
                     FROM AVL.BusinessClusterMapping (NOLOCK) BCM    
                     JOIN CTE ON BCM.BusinessClusterMapID = CTE.ParentBusinessClusterMapID    
            WHERE BCM.CustomerID = @CustomerID AND BCM.IsDeleted = 0    
              )    
    SELECT ProjectID, ApplicationID, BusinessClusterMapID, BusinessClusterBaseName,     
                     ParentBusinessClusterMapID, IsHavingSubBusinesss    
              INTO #ProjectApplicationHierarchyDetails    
              FROM CTE     
              ORDER BY ProjectID, ApplicationID, BusinessClusterMapID    
    
    IF @Hierarchy4IDs = ''    
    BEGIN    
  SET @Hierarchy4IDs=NULL    
    END    
    IF @Hierarchy5IDs = ''    
    BEGIN    
  SET @Hierarchy5IDs=NULL    
    END    
    IF @Hierarchy6IDs = ''    
    BEGIN    
  SET @Hierarchy6IDs=NULL    
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
       FROM AVL.BusinessClusterMapping(NOLOCK) BCM1    
       LEFT JOIN AVL.BusinessClusterMapping(NOLOCK)  BCM2 on bcm1.BusinessClusterMapID=BCM2.ParentBusinessClusterMapID AND     
       BCM1.ParentBusinessClusterMapID IS NULL    
       LEFT JOIN AVL.BusinessClusterMapping(NOLOCK)  BCM3 ON BCM2.BusinessClusterMapID=BCM3.ParentBusinessClusterMapID    
       LEFT JOIN AVL.BusinessClusterMapping(NOLOCK)  BCM4 ON BCM3.BusinessClusterMapID=BCM4.ParentBusinessClusterMapID    
       LEFT JOIN AVL.BusinessClusterMapping(NOLOCK)  BCM5 ON BCM4.BusinessClusterMapID=BCM5.ParentBusinessClusterMapID    
       LEFT JOIN AVL.BusinessClusterMapping(NOLOCK)  BCM6 ON BCM5.BusinessClusterMapID=BCM6.ParentBusinessClusterMapID    
       LEFT JOIN AVL.BusinessClusterMapping(NOLOCK)  BCM7 ON BCM6.BusinessClusterMapID=BCM7.ParentBusinessClusterMapID    
       LEFT JOIN AVL.BusinessClusterMapping(NOLOCK)  BCM8 ON BCM7.BusinessClusterMapID=BCM8.ParentBusinessClusterMapID    
    WHERE  BCM1.CustomerID=@CustomerID AND BCM1.IsDeleted = 0 AND BCM1.ParentBusinessClusterMapID IS NULL    
       AND     
    ((BCM8.IsHavingSubBusinesss = 0 AND EXISTS(SELECT SubBusinessClusterMapID FROM AVL.APP_MAS_ApplicationDetails (NOLOCK) WHERE BCM8.BusinessClusterMapID=SubBusinessClusterMapID))    
       OR (BCM7.IsHavingSubBusinesss = 0 AND EXISTS(SELECT SubBusinessClusterMapID FROM AVL.APP_MAS_ApplicationDetails (NOLOCK) WHERE BCM7.BusinessClusterMapID=SubBusinessClusterMapID))    
       OR (BCM6.IsHavingSubBusinesss = 0 AND EXISTS(SELECT SubBusinessClusterMapID FROM AVL.APP_MAS_ApplicationDetails (NOLOCK) WHERE BCM6.BusinessClusterMapID=SubBusinessClusterMapID))    
       OR (BCM5.IsHavingSubBusinesss = 0 AND EXISTS(SELECT SubBusinessClusterMapID FROM AVL.APP_MAS_ApplicationDetails (NOLOCK) WHERE BCM5.BusinessClusterMapID=SubBusinessClusterMapID))    
       OR (BCM4.IsHavingSubBusinesss = 0 AND EXISTS(SELECT SubBusinessClusterMapID FROM AVL.APP_MAS_ApplicationDetails (NOLOCK) WHERE BCM4.BusinessClusterMapID=SubBusinessClusterMapID))    
       OR (BCM3.IsHavingSubBusinesss = 0 AND EXISTS(SELECT SubBusinessClusterMapID FROM AVL.APP_MAS_ApplicationDetails (NOLOCK) WHERE BCM3.BusinessClusterMapID=SubBusinessClusterMapID))    
       OR (BCM2.IsHavingSubBusinesss = 0 AND EXISTS(SELECT SubBusinessClusterMapID FROM AVL.APP_MAS_ApplicationDetails (NOLOCK) WHERE BCM2.BusinessClusterMapID=SubBusinessClusterMapID))    
       OR (BCM1.IsHavingSubBusinesss = 0 AND EXISTS(SELECT SubBusinessClusterMapID FROM AVL.APP_MAS_ApplicationDetails (NOLOCK) WHERE BCM1.BusinessClusterMapID=SubBusinessClusterMapID))    
       )    
    
    SELECT Item INTO #Hierarchy1IDs FROM dbo.Split(@Hierarchy1IDs, ',')    
    SELECT Item INTO #Hierarchy2IDs FROM dbo.Split(@Hierarchy2IDs, ',')    
    SELECT Item INTO #Hierarchy3IDs FROM dbo.Split(@Hierarchy3IDs, ',')    
    SELECT Item INTO #Hierarchy4IDs FROM dbo.Split(@Hierarchy4IDs, ',')    
    SELECT Item INTO #Hierarchy5IDs FROM dbo.Split(@Hierarchy5IDs, ',')    
    SELECT Item INTO #Hierarchy6IDs FROM dbo.Split(@Hierarchy6IDs, ',')    
    
       SELECT BCM.CustomerID      ,BCM.CoreBusinessClusterID, BCM.BusinessClusterLevel1       ,BCM.BusinessClusterLevel1Name,BCM.BusinessClusterLevel2,    
              BCM.BusinessClusterLevel2Name,    BCM.BusinessClusterLevel3       ,BCM.BusinessClusterLevel3Name    ,BCM.BusinessClusterLevel4,    
                     BCM.BusinessClusterLevel4Name,    BCM.BusinessClusterLevel5,       BCM.BusinessClusterLevel5Name,    BCM.BusinessClusterLevel6,    
                           BCM.BusinessClusterLevel6Name,    BCM.BusinessClusterLevel7,       BCM.BusinessClusterLevel7Name,    
                                  BCM.BusinessClusterLevel8,    
                                 BCM.BusinessClusterLevel8Name,APM.ApplicationID,AD.ApplicationName,APM.ProjectID,HD.ProjectName    
       INTO #HierarchyDetails    
       FROM #BusinessClusterMapping BCM  (NOLOCK)  
       INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD    
       ON AD.SubBusinessClusterMapID=BCM.CoreBusinessClusterID    
       INNER JOIN AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM    
       ON AD.ApplicationID=APM.ApplicationID     
  INNER JOIN      
   #ProjectTable P     
  ON     
   P.Item = APM.ProjectID    
       INNER JOIN #ProjectApplicationLastHierarchyDetails HD (NOLOCK) ON APM.ProjectID=APM.ProjectID AND HD.ApplicationID=APM.ApplicationID    
  LEFT JOIN #Hierarchy1IDs H1 (NOLOCK) ON H1.Item = BCM.BusinessClusterLevel1    
  LEFT JOIN #Hierarchy2IDs H2 (NOLOCK) ON H2.Item = BCM.BusinessClusterLevel2    
  LEFT JOIN #Hierarchy3IDs H3 (NOLOCK) ON H3.Item = BCM.BusinessClusterLevel3    
  LEFT JOIN #Hierarchy4IDs H4 (NOLOCK) ON H4.Item = BCM.BusinessClusterLevel4    
  LEFT JOIN #Hierarchy5IDs H5 (NOLOCK) ON H5.Item = BCM.BusinessClusterLevel5    
  LEFT JOIN #Hierarchy6IDs H6 (NOLOCK) ON H6.Item = BCM.BusinessClusterLevel6    
    
              -- Push Application, Projects, Hierarchy Details and Ticket Details into Temporary Table.    
              SELECT TKD.ProjectId, TKD.ProjectName, TKD.TicketID, TKD.TicketDescription,     
                     TKD.TicketTypeMapID, PA.ApplicationName, PA.BusinessClusterLevel1Name AS Hierarchy1,     
                     PA.BusinessClusterLevel2Name AS Hierarchy2,    
                     PA.BusinessClusterLevel3Name AS Hierarchy3,    
                     PA.BusinessClusterLevel4Name AS Hierarchy4,    
                     PA.BusinessClusterLevel5Name AS Hierarchy5,    
                     PA.BusinessClusterLevel6Name AS Hierarchy6,    
                     TKD.ServiceID, TKD.CauseCodeMapID, TKD.ResolutionCodeMapID, TKD.OpenDateTime,     
                     TKD.ClosedDate, TKD.AssignedTo, TKD.PriorityMapID, TKD.TicketStatusMapID,     
                     TKD.DARTStatusID, TKD.ReopenDateTime, TKD.IsSDTicket, TKD.SeverityMapID,     
                     TKD.ReleaseTypeMapID, TKD.PlannedEffort, TKD.EstimatedWorkSize, TKD.ActualWorkSize,     
                     TKD.PlannedStartDate, TKD.PlannedEndDate, TKD.IsManual, TKD.EffortTillDate,     
                     TKD.NewStatusDateTime, TKD.RejectedDateTime, TKD.KEDBAvailableIndicatorMapID,     
                     TKD.KEDBUpdatedMapID, TKD.ElevateFlagInternal, TKD.RCAID, TKD.MetResponseSLAMapID,     
                     TKD.MetAcknowledgementSLAMapID, TKD.MetResolutionMapID, TKD.ActualStartDateTime,     
                     TKD.ActualEndDateTime, TKD.ActualDuration, ISNULL(TKD.NatureOfTheTicket,0) AS NatureOfTheTicket, TKD.Comments,     
                     TKD.RepeatedIncident, TKD.RelatedTickets, TKD.TicketCreatedBy, TKD.KEDBPath,     
ISNULL(TKD.EscalatedFlagCustomer,0) AS EscalatedFlagCustomer, TKD.ApprovedBy, TKD.StartedDateTime, TKD.WIPDateTime,     
                     TKD.OnHoldDateTime, TKD.CompletedDateTime, TKD.CancelledDateTime, TKD.OutageDuration,     
                     TKD.DebtClassificationMapID, TKD.AvoidableFlag, TKD.ResidualDebtMapID,     
                     TKD.ResolutionRemarks,TKD.IsAttributeUpdated    
        ,TKD.FlexField1,TKD.FlexField2,    
      TKD.FlexField3,TKD.FlexField4,TKD.Category,TKD.[Type],TKD.IsDeleted    
              INTO #TicketDetails    
              FROM #HierarchyDetails PA (NOLOCK)   
              JOIN #TicketTemp TKD (NOLOCK) ON TKD.ProjectID = PA.ProjectID AND TKD.ApplicationID = PA.ApplicationID    
    WHERE  PA.ProjectID IN(SELECT Item FROM #ProjectTable (NOLOCK)) AND    
     ((@IsFilterByOpenDate = 1 AND	
	--(CONVERT(DATE,DATEADD(MINUTE, -DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()), TKD.OpenDateTime))
	(CONVERT(DATE, DATEADD(HOUR, +5, DATEADD(MINUTE, +30, TKD.OpenDateTime)))
	BETWEEN @StartDate1 AND @EndDate1))  
                                  OR (@IsFilterByOpenDate = 0 AND     
    -- (CONVERT(DATE, TKD.ClosedDate) BETWEEN @StartDate1 AND @EndDate1))) 
	--(CONVERT(DATE,DATEADD(MINUTE, -DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()), TKD.ClosedDate))
	(CONVERT(DATE, DATEADD(HOUR, +5, DATEADD(MINUTE, +30, TKD.ClosedDate)))
	BETWEEN @StartDate1 AND @EndDate1))) 
	
    AND (ISNULL(@TicketStatusIDs,'') = '' OR     
                                  TKD.DARTStatusID IN (SELECT Item FROM dbo.Split(@TicketStatusIDs, ',')))    
                           AND (@TicketSourceIDs IS NULL OR @TicketSourceIDs = '' OR     
                                  TKD.IsSDTicket IN (SELECT Item FROM dbo.Split(@TicketSourceIDs, ',')))    
    AND (ISNULL(@TicketTypeIDs,'') = '' OR     
    (TKD.TicketTypeMapID IN (SELECT Item FROM #TicketTypeIDs) AND @IsCognizant = 0 )OR    
    (EXISTS(SELECT TicketTypeMappingID FROM AVL.TK_MAP_TicketTypeMapping(NOLOCK)    
    WHERE TKD.TicketTypeMapID = TicketTypeMappingID AND AVMTicketType IN (SELECT Item FROM #TicketTypeIDs (NOLOCK))     
    AND EXISTS(SELECT Item FROM #ProjectTable (NOLOCK) WHERE Item = ProjectID)) AND @IsCognizant = 1))    
    AND (ISNULL(@TicketingData,'') = '' OR     
    (CHARINDEX ('1', @TicketingData) > 0 AND CHARINDEX ('2', @TicketingData) > 0    
     AND CHARINDEX ('3', @TicketingData) > 0 ) OR    
                                  (@TicketingData = '1' AND TKD.EffortTillDate > 0) OR    
                                  (@TicketingData = '2' AND TKD.EffortTillDate = 0) OR     
    (@TicketingData = '3' AND (ISNULL(TKD.AssignedTo,'')='')) OR     
          (@TicketingData ='1,2' AND  (TKD.EffortTillDate > 0 OR TKD.EffortTillDate = 0)) OR    
    (@TicketingData ='1,3' AND TKD.EffortTillDate > 0 AND (ISNULL(TKD.AssignedTo,'') ='')) OR     
    (@TicketingData ='2,3' AND TKD.EffortTillDate = 0 AND (ISNULL(TKD.AssignedTo,'')='')))    
    AND (ISNULL(@DataEntryCompletion,'') = '' OR     
                                  (CHARINDEX ('1', @DataEntryCompletion) > 0     
                                         AND CHARINDEX ('0', @DataEntryCompletion) > 0) OR    
                                  (@DataEntryCompletion = '1' AND TKD.IsAttributeUpdated = 1) OR    
                                  (@DataEntryCompletion = '0' AND (TKD.IsAttributeUpdated = 0 OR     
                                         TKD.IsAttributeUpdated IS NULL)))    
                           AND TKD.IsDeleted = 0     
   GROUP BY     
    TKD.ProjectId, TKD.ProjectName, TKD.TicketID, TKD.TicketDescription,     
                     TKD.TicketTypeMapID, PA.ApplicationName, PA.BusinessClusterLevel1Name,     
                     PA.BusinessClusterLevel2Name,    
                     PA.BusinessClusterLevel3Name,    
                     PA.BusinessClusterLevel4Name,    
                     PA.BusinessClusterLevel5Name,    
                     PA.BusinessClusterLevel6Name,    
                     TKD.ServiceID, TKD.CauseCodeMapID, TKD.ResolutionCodeMapID, TKD.OpenDateTime,     
                     TKD.ClosedDate, TKD.AssignedTo, TKD.PriorityMapID, TKD.TicketStatusMapID,     
                     TKD.DARTStatusID, TKD.ReopenDateTime, TKD.IsSDTicket, TKD.SeverityMapID,     
                     TKD.ReleaseTypeMapID, TKD.PlannedEffort, TKD.EstimatedWorkSize, TKD.ActualWorkSize,     
         TKD.PlannedStartDate, TKD.PlannedEndDate, TKD.IsManual, TKD.EffortTillDate,     
                     TKD.NewStatusDateTime, TKD.RejectedDateTime, TKD.KEDBAvailableIndicatorMapID,     
                     TKD.KEDBUpdatedMapID, TKD.ElevateFlagInternal, TKD.RCAID, TKD.MetResponseSLAMapID,     
                     TKD.MetAcknowledgementSLAMapID, TKD.MetResolutionMapID, TKD.ActualStartDateTime,     
                     TKD.ActualEndDateTime, TKD.ActualDuration, TKD.NatureOfTheTicket, TKD.Comments,     
                     TKD.RepeatedIncident, TKD.RelatedTickets, TKD.TicketCreatedBy, TKD.KEDBPath,     
                     TKD.EscalatedFlagCustomer, TKD.ApprovedBy, TKD.StartedDateTime, TKD.WIPDateTime,     
                     TKD.OnHoldDateTime, TKD.CompletedDateTime, TKD.CancelledDateTime, TKD.OutageDuration,     
                     TKD.DebtClassificationMapID, TKD.AvoidableFlag, TKD.ResidualDebtMapID,     
                     TKD.ResolutionRemarks,TKD.IsAttributeUpdated    
       ,TKD.FlexField1,TKD.FlexField2,    
      TKD.FlexField3,TKD.FlexField4,TKD.Category,TKD.[Type],TKD.IsDeleted    
           
        
              -- Get the Ticket Details based on search fields    
              SELECT DISTINCT    
      TKD.ProjectName, TKD.TicketID,     
      TKD.TicketDescription,     
      ISNULL(TKTM.TicketType,TKTMAS.TicketTypeName) AS TicketType,     
                     TKD.ApplicationName, TKD.Hierarchy1, TKD.Hierarchy2, TKD.Hierarchy3, TKD.Hierarchy4,    
                     TKD.Hierarchy5, TKD.Hierarchy6,     
      SR.ServiceName AS [Service],     
                     SRT.ServiceTypeName AS ServiceGroup, CC.CauseCode, RC.ResolutionCode,     
                     TKD.OpenDateTime AS OpenDate, TKD.ClosedDate,     
      LM.EmployeeName AS Assignee,     
                     PR.PriorityName AS [Priority], PSM.StatusName AS [Status],     
                     DTSTS.DARTStatusName AS AppLensStatus,     
      TKD.ReopenDateTime AS ReopenDate,     
                     CASE WHEN TKD.IsSDTicket = 1 THEN @ApplensTicket ELSE @SMTicket END AS [Source],    
                     SEV.SeverityName AS Severity, RT.ReleaseTypeName AS ReleaseType,     
                     ISNULL(TKD.PlannedEffort, 0) AS PlannedEffort,     
                     ISNULL(TKD.EstimatedWorkSize, 0) AS EstimatedWorkSize,     
    ISNULL(TKD.ActualWorkSize, 0) AS ActualWorkSize,     
                     TKD.PlannedStartDate, TKD.PlannedEndDate,     
                     CASE WHEN TKD.IsManual = 1 THEN 'Manual'    
                           WHEN TKD.IsManual = 0 THEN 'Upload' END AS InsertionMode,     
                     TKD.EffortTillDate, TKD.NewStatusDateTime, TKD.RejectedDateTime AS RejectedTimeStamp,     
                     KEDBA.KEDBAvailableIndicatorName AS KEDBAvailableIndicator,     
                     CASE WHEN TKD.IsAttributeUpdated=1 THEN 'Yes' ELSE 'No' END AS DataEntryComplete,    
                     KEDBU.KEDBUpdatedName AS KEDBUpdated, ELFI.MetSLAName AS ElevateFlagInternal,     
                     TKD.RCAID,     
      RESSLA.MetSLAName AS MetResponseSLA,     
                     ACKSLA.MetSLAName AS MetAcknowledgementSLA, RESLSLA.MetSLAName AS MetResolution,     
                     TKD.ActualStartDateTime, TKD.ActualEndDateTime,     
                     ISNULL(TKD.ActualDuration, 0) AS ActualDuration,     
      NT.[Nature Of The Ticket] AS NatureOfTheTicket,    
       TKD.Comments, TKD.RepeatedIncident, TKD.RelatedTickets,     
                     TKD.TicketCreatedBy AS TicketCreatedBy, TKD.KEDBPath,     
                     EFC.[Escalated Flag Customer] AS EscalatedFlagCustomer,    
                     TKD.ApprovedBy AS ApprovedBy, TKD.StartedDateTime, TKD.WIPDateTime,     
                     TKD.OnHoldDateTime, TKD.CompletedDateTime, TKD.CancelledDateTime,     
                     ISNULL(TKD.OutageDuration, 0) AS OutageDuration,     
                     DBTCL.DebtClassificationName AS DebtClassification,     
                     AVDF.AvoidableFlagName AS AvoidableFlag, RSDBT.ResidualDebtName AS ResidualDebt,     
                  TKD.ResolutionRemarks,    
TKD.FlexField1,TKD.FlexField2,TKD.FlexField3,TKD.FlexField4,TKD.Category,TKD.[Type],0 as TowerName,LM.ClientUserID as ClientUserID    
              FROM #TicketDetails TKD  (NOLOCK)  
              LEFT JOIN #LoginTemp LM  (NOLOCK)  
                     ON LM.UserID = TKD.AssignedTo --AND LM.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAP_TicketTypeMapping (NOLOCK) TKTM    
                     ON TKTM.TicketTypeMappingID = TKD.TicketTypeMapID     
                           AND TKTM.ProjectID = TKD.ProjectID     
                           AND (ISNULL(@TicketTypeIDs,'') = '' OR    
                                  (TKTM.AVMTicketType IN (SELECT Item FROM #TicketTypeIDs (NOLOCK)) AND @IsCognizant=1) OR    
        (TKTM.TicketTypeMappingID IN (SELECT Item FROM #TicketTypeIDs (NOLOCK)) AND @IsCognizant=0)  )    
                           AND TKTM.IsDeleted = 0    
    LEFT JOIN [AVL].TK_MAS_TicketType (NOLOCK) TKTMAS    
                     ON TKTMAS.TicketTypeID IN (SELECT Item FROM #TicketTypeIDs (NOLOCK))    
                           AND (ISNULL(@TicketTypeIDs,'') = '' OR --TKTM.AVMTicketType=TKTM.AVMTicketType OR    
                                  TKTMAS.TicketTypeID IN (SELECT Item FROM #TicketTypeIDs (NOLOCK)))    
                           AND TKTMAS.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_Service (NOLOCK) SR    
                     ON SR.ServiceID = TKD.ServiceID AND SR.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_ServiceType (NOLOCK) SRT    
                     ON SRT.ServiceTypeID = SR.ServiceType AND SRT.IsDeleted = 0    
              LEFT JOIN [AVL].DEBT_MAP_CauseCode (NOLOCK) CC    
                     ON CC.CauseID = TKD.CauseCodeMapID AND CC.IsDeleted = 0    
              LEFT JOIN [AVL].DEBT_MAP_ResolutionCode (NOLOCK) RC    
                     ON RC.ResolutionID = TKD.ResolutionCodeMapID AND RC.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAP_PriorityMapping (NOLOCK) PR    
                     ON PR.PriorityIDMapID = TKD.PriorityMapID AND PR.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAP_SeverityMapping (NOLOCK) SEV    
                     ON SEV.SeverityIDMapID = TKD.SeverityMapID AND SEV.IsDeleted = 0    
          LEFT JOIN [AVL].TK_MAS_ReleaseType (NOLOCK) RT    
                     ON RT.ReleaseTypeID = TKD.ReleaseTypeMapID AND RT.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_KEDBAvailableIndicator (NOLOCK) KEDBA    
                     ON KEDBA.KEDBAvailableIndicatorID = TKD.KEDBAvailableIndicatorMapID     
                           AND KEDBA.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_KEDBUpdated (NOLOCK) KEDBU    
                     ON KEDBU.KEDBUpdatedID = TKD.KEDBUpdatedMapID AND KEDBU.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_MetSLACondition (NOLOCK) ELFI    
                     ON ELFI.MetSLAId = TKD.ElevateFlagInternal AND ELFI.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_MetSLACondition (NOLOCK) AVDFLG    
                     ON AVDFLG.MetSLAId = TKD.MetResponseSLAMapID AND AVDFLG.IsDeleted = 0     
              LEFT JOIN [AVL].TK_MAS_MetSLACondition (NOLOCK) RESSLA    
                     ON RESSLA.MetSLAId = TKD.MetResponseSLAMapID AND RESSLA.IsDeleted = 0     
              LEFT JOIN [AVL].TK_MAS_MetSLACondition (NOLOCK) ACKSLA    
                     ON ACKSLA.MetSLAId = TKD.MetAcknowledgementSLAMapID AND ACKSLA.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_MetSLACondition (NOLOCK) RESLSLA    
                     ON RESLSLA.MetSLAId = TKD.MetResolutionMapID AND RESLSLA.IsDeleted = 0         
              LEFT JOIN AVL.DEBT_MAS_DebtClassification (NOLOCK) DBTCL    
                     ON DBTCL.DebtClassificationID = TKD.DebtClassificationMapID AND DBTCL.IsDeleted = 0     
              LEFT JOIN AVL.DEBT_MAS_ResidualDebt (NOLOCK) RSDBT    
                     ON RSDBT.ResidualDebtID = TKD.ResidualDebtMapID AND RSDBT.IsDeleted = 0     
              LEFT JOIN [AVL].DEBT_MAS_AvoidableFlag (NOLOCK) AVDF    
                     ON AVDF.AvoidableFlagID = TKD.AvoidableFlag AND AVDF.IsDeleted = 0     
              LEFT JOIN [AVL].TK_MAP_ProjectStatusMapping (NOLOCK) PSM    
 ON PSM.StatusID = TKD.TicketStatusMapID AND PSM.IsDeleted = 0            
              LEFT JOIN [AVL].TK_MAS_DARTTicketStatus (NOLOCK) DTSTS    
                     ON DTSTS.DARTStatusID = TKD.DARTStatusID AND DTSTS.IsDeleted = 0      
     LEFT JOIN AVL.ITSM_MAS_Natureoftheticket (NOLOCK) NT    
      ON NT.NatureOfTheTicketId=TKD.NatureOfTheTicket AND NT.IsDeleted = 0     
     LEFT JOIN AVL.ITSM_MAS_EscalatedFlagCustomer (NOLOCK) EFC    
      ON EFC.EscalatedFlagCustomerId=TKD.EscalatedFlagCustomer AND EFC.IsDeleted = 0         
END    
    
IF (@IsInfra = 1 )    
BEGIN    
    
SELECT DISTINCT ITPM.ProjectID,PT.ProjectName,A.CustomerID,One.HierarchyOneTransactionID,One.HierarchyName AS HierarchyOneName,    
     two.HierarchyTwoTransactionID,two.HierarchyName HierarchyTwoName,    
     three.HierarchyThreeTransactionID,three.HierarchyName HierarchyThreeName,    
     four.HierarchyFourTransactionID,four.HierarchyName HierarchyFourName,    
     IFVM.HierarchyFiveTransactionID,IFVM.HierarchyName HierarchyFiveName,    
     ISM.HierarchySixTransactionID,ISM.HierarchyName HierarchySixName,    
     ITPM.TowerID,ITDT.TowerName    
     INTO #InfraHierarchyDetails    
 FROM avl.InfraHierarchyMappingTransaction A (NOLOCK)   
 LEFT JOIN AVL.InfraHierarchyOneTransaction One (NOLOCK) ON A.HierarchyOneTransactionID=One.HierarchyOneTransactionID    
 LEFT JOIN AVL.InfraHierarchyTwoTransaction two (NOLOCK) ON A.HierarchyTwoTransactionID = two.HierarchyTwoTransactionID    
 LEFT JOIN AVL.InfraHierarchyThreeTransaction three (NOLOCK) ON A.HierarchyThreeTransactionID = three.HierarchyThreeTransactionID    
 LEFT JOIN AVL.InfraHierarchyFourTransaction four (NOLOCK) ON A.HierarchyFourTransactionID = four.HierarchyFourTransactionID    
 LEFT JOIN AVL.InfraHierarchyFiveTransaction(NOLOCK) IFVM ON A.HierarchyFiveTransactionID=IFVM.HierarchyFiveTransactionID AND IFVM.IsDeleted=0    
 LEFT JOIN AVL.InfraHierarchySixTransaction(NOLOCK) ISM ON A.HierarchySixTransactionID=ISM.HierarchySixTransactionID AND ISM.IsDeleted=0    
 LEFT JOIN AVL.InfraTowerDetailsTransaction ITDT (NOLOCK) ON ITDT.InfraTransMappingID=A.InfraTransMappingID    
 LEFT JOIN AVL.InfraTowerProjectMapping ITPM (NOLOCK) ON ITPM.TowerID=ITDT.InfraTowerTransactionID    
 INNER JOIN #ProjectTable PT (NOLOCK) ON PT.Item = ITPM.ProjectID    
 where A.CustomerID = @CustomerID AND (ISNULL(@ApplicationIDs,'') = '' OR     
                           ITPM.TowerID IN (SELECT Item FROM dbo.Split(@ApplicationIDs, ',')))    
    
    
 IF @Hierarchy4IDs = ''    
    BEGIN    
  SET @Hierarchy4IDs=NULL    
    END    
    IF @Hierarchy5IDs = ''    
    BEGIN    
  SET @Hierarchy5IDs=NULL    
    END    
    IF @Hierarchy6IDs = ''    
    BEGIN    
  SET @Hierarchy6IDs=NULL    
    END    
    
    SELECT Item INTO #Hierarchy1ID FROM dbo.Split(@Hierarchy1IDs, ',')    
    SELECT Item INTO #Hierarchy2ID FROM dbo.Split(@Hierarchy2IDs, ',')    
    SELECT Item INTO #Hierarchy3ID FROM dbo.Split(@Hierarchy3IDs, ',')    
    SELECT Item INTO #Hierarchy4ID FROM dbo.Split(@Hierarchy4IDs, ',')    
    SELECT Item INTO #Hierarchy5ID FROM dbo.Split(@Hierarchy5IDs, ',')    
    SELECT Item INTO #Hierarchy6ID FROM dbo.Split(@Hierarchy6IDs, ',')    
    
    
    
 SELECT IHMD.CustomerID   , IHMD.HierarchyOneTransactionID       ,IHMD.HierarchyOneName,IHMD.HierarchyTwoTransactionID,    
              IHMD.HierarchyTwoName,    IHMD.HierarchyThreeTransactionID       ,IHMD.HierarchyThreeName    ,IHMD.HierarchyFourTransactionID,    
                     IHMD.HierarchyFourName,    IHMD.HierarchyFiveTransactionID,       IHMD.HierarchyFiveName,    IHMD.HierarchySixTransactionID,    
                           IHMD.HierarchySixName, IHMD.TowerID,IHMD.TowerName,IHMD.ProjectID,IHMD.ProjectName    
       INTO #InfraHierarchySearchParameter    
       FROM #InfraHierarchyDetails IHMD    
  LEFT JOIN #Hierarchy1ID H1 (NOLOCK) ON H1.Item = IHMD.HierarchyOneTransactionID    
  LEFT JOIN #Hierarchy2ID H2 (NOLOCK) ON H2.Item = IHMD.HierarchyTwoTransactionID    
  LEFT JOIN #Hierarchy3ID H3 (NOLOCK) ON H3.Item = IHMD.HierarchyThreeTransactionID    
  LEFT JOIN #Hierarchy4ID H4 (NOLOCK) ON H4.Item = IHMD.HierarchyFourTransactionID    
  LEFT JOIN #Hierarchy5ID H5 (NOLOCK) ON H5.Item = IHMD.HierarchyFiveTransactionID    
  LEFT JOIN #Hierarchy6ID H6 (NOLOCK) ON H6.Item = IHMD.HierarchySixTransactionID    
    
    
     
SELECT      
      
  TD.[Type],    
  TD.ActualDuration,     
  TD.ActualEndDateTime,     
  TD.ActualStartDateTime,                         
  TD.ActualWorkSize,                        
  TD.ApprovedBy,     
  TD.AssignedTo,    
  TD.AvoidableFlag,     
  TD.CancelledDateTime,     
  TD.Category,    
  TD.CauseCodeMapID,    
  TD.ClosedDate,    
  TD.Comments,                         
  TD.CompletedDateTime,     
  TD.DARTStatusID,     
  TD.DebtClassificationMapID,     
  TD.EffortTillDate,    
  TD.ElevateFlagInternal,     
  TD.EscalatedFlagCustomer,     
  TD.EstimatedWorkSize,     
  TD.FlexField1,    
  TD.FlexField2,    
  TD.FlexField3,    
  TD.FlexField4,    
  TD.IsAttributeUpdated,    
  TD.IsDeleted,    
  TD.IsManual,     
  TD.IsSDTicket,    
  TD.KEDBAvailableIndicatorMapID,                         
  TD.KEDBPath,     
  TD.KEDBUpdatedMapID,     
  TD.MetAcknowledgementSLAMapID,    
  TD.MetResolutionMapID,     
  TD.MetResponseSLAMapID,                        
  TD.NatureOfTheTicket,     
  TD.NewStatusDateTime,     
  TD.OnHoldDateTime,     
  TD.OpenDateTime,    
  TD.OutageDuration,                         
  TD.PlannedEffort,     
  TD.PlannedEndDate,     
  TD.PlannedStartDate,     
  TD.PriorityMapID,     
  TD.ProjectID,    
  TD.RCAID,     
  TD.RejectedDateTime,     
  TD.RelatedTickets,     
  TD.ReleaseTypeMapID,     
  TD.ReopenDateTime,     
  TD.RepeatedIncident,     
  TD.ResidualDebtMapID,                        
  TD.ResolutionCodeMapID,     
  TD.ResolutionRemarks,    
  TD.TowerID,    
  TD.SeverityMapID,                         
  TD.StartedDateTime,     
  TD.TicketCreatedBy,     
  TD.TicketDescription,     
  TD.TicketID,     
  TD.TicketStatusMapID,                      
  TD.TicketTypeMapID,    
 TD.WIPDateTime,    
  P.ProjectName                        
 INTO     
  #InfraTicketTemp      
 FROM [AVL].TK_TRN_InfraTicketDetail TD (NOLOCK)     
 INNER JOIN      
  #ProjectTable P     
 ON     
  P.Item = TD.ProjectID    
 WHERE    
  TD.IsDeleted = 0    
    
    
 SELECT TKD.ProjectId, TKD.ProjectName, TKD.TicketID, TKD.TicketDescription,     
                     TKD.TicketTypeMapID, IHSP.TowerName, IHSP.HierarchyOneName AS Hierarchy1,     
                     IHSP.HierarchyTwoName AS Hierarchy2,    
                     IHSP.HierarchyThreeName AS Hierarchy3,    
                     IHSP.HierarchyFourName AS Hierarchy4,    
                     IHSP.HierarchyFiveName AS Hierarchy5,    
                     IHSP.HierarchyFiveName AS Hierarchy6,    
                     TKD.CauseCodeMapID, TKD.ResolutionCodeMapID, TKD.OpenDateTime,     
                     TKD.ClosedDate, TKD.AssignedTo, TKD.PriorityMapID, TKD.TicketStatusMapID,     
                     TKD.DARTStatusID, TKD.ReopenDateTime, TKD.IsSDTicket, TKD.SeverityMapID,     
                     TKD.ReleaseTypeMapID, TKD.PlannedEffort, TKD.EstimatedWorkSize, TKD.ActualWorkSize,     
                     TKD.PlannedStartDate, TKD.PlannedEndDate, TKD.IsManual, TKD.EffortTillDate,     
                     TKD.NewStatusDateTime, TKD.RejectedDateTime, TKD.KEDBAvailableIndicatorMapID,     
                     TKD.KEDBUpdatedMapID, TKD.ElevateFlagInternal, TKD.RCAID, TKD.MetResponseSLAMapID,     
                     TKD.MetAcknowledgementSLAMapID, TKD.MetResolutionMapID, TKD.ActualStartDateTime,     
                     TKD.ActualEndDateTime, TKD.ActualDuration, ISNULL(TKD.NatureOfTheTicket,0) AS NatureOfTheTicket, TKD.Comments,     
                     TKD.RepeatedIncident, TKD.RelatedTickets, TKD.TicketCreatedBy, TKD.KEDBPath,     
ISNULL(TKD.EscalatedFlagCustomer,0) AS EscalatedFlagCustomer, TKD.ApprovedBy, TKD.StartedDateTime, TKD.WIPDateTime,     
                     TKD.OnHoldDateTime, TKD.CompletedDateTime, TKD.CancelledDateTime, TKD.OutageDuration,     
                     TKD.DebtClassificationMapID, TKD.AvoidableFlag, TKD.ResidualDebtMapID,     
                     TKD.ResolutionRemarks,TKD.IsAttributeUpdated    
        ,TKD.FlexField1,TKD.FlexField2,    
      TKD.FlexField3,TKD.FlexField4,TKD.Category,TKD.[Type],TKD.IsDeleted    
              INTO #InfraTicketDetails    
              FROM #InfraHierarchySearchParameter IHSP (NOLOCK)   
   JOIN #InfraTicketTemp TKD (NOLOCK) ON TKD.ProjectID = TKD.ProjectID AND TKD.TowerID = IHSP.TowerID    
    WHERE  TKD.ProjectID IN(SELECT Item FROM #ProjectTable) AND    
    ((@IsFilterByOpenDate = 1 AND	
	--(CONVERT(DATE,DATEADD(MINUTE, -DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()), TKD.OpenDateTime))
	(CONVERT(DATE, DATEADD(HOUR, +5, DATEADD(MINUTE, +30, TKD.OpenDateTime)))
	BETWEEN @StartDate1 AND @EndDate1))  
	--(CONVERT(DATE, TKD.OpenDateTime) BETWEEN @StartDate1 AND @EndDate1))    
                                  OR (@IsFilterByOpenDate = 0 AND     
     --(CONVERT(DATE, TKD.ClosedDate) 
	 	(CONVERT(DATE, DATEADD(HOUR, +5, DATEADD(MINUTE, +30, TKD.ClosedDate)))
	 BETWEEN @StartDate1 AND @EndDate1)))     
    AND (ISNULL(@TicketStatusIDs,'') = '' OR     
                                  TKD.DARTStatusID IN (SELECT Item FROM dbo.Split(@TicketStatusIDs, ',')))    
                           AND (@TicketSourceIDs IS NULL OR @TicketSourceIDs = '' OR     
                                  TKD.IsSDTicket IN (SELECT Item FROM dbo.Split(@TicketSourceIDs, ',')))    
    AND (ISNULL(@TicketTypeIDs,'') = '' OR     
    (TKD.TicketTypeMapID IN (SELECT Item FROM #TicketTypeIDs) AND @IsCognizant = 0 )OR    
    (EXISTS(SELECT TicketTypeMappingID FROM AVL.TK_MAP_TicketTypeMapping(NOLOCK)    
    WHERE TKD.TicketTypeMapID = TicketTypeMappingID AND AVMTicketType IN (SELECT Item FROM #TicketTypeIDs)     
    AND EXISTS(SELECT Item FROM #ProjectTable WHERE Item = ProjectID)) AND @IsCognizant = 1))    
    AND (ISNULL(@TicketingData,'') = '' OR     
    (CHARINDEX ('1', @TicketingData) > 0 AND CHARINDEX ('2', @TicketingData) > 0    
     AND CHARINDEX ('3', @TicketingData) > 0 ) OR    
                                  (@TicketingData = '1' AND TKD.EffortTillDate > 0) OR    
                                  (@TicketingData = '2' AND TKD.EffortTillDate = 0) OR     
   (@TicketingData = '3' AND (ISNULL(TKD.AssignedTo,'')='')) OR     
          (@TicketingData ='1,2' AND  (TKD.EffortTillDate > 0 OR TKD.EffortTillDate = 0)) OR    
    (@TicketingData ='1,3' AND TKD.EffortTillDate > 0 AND (ISNULL(TKD.AssignedTo,'') ='')) OR     
    (@TicketingData ='2,3' AND TKD.EffortTillDate = 0 AND (ISNULL(TKD.AssignedTo,'')='')))    
    AND (ISNULL(@DataEntryCompletion,'') = '' OR     
                                  (CHARINDEX ('1', @DataEntryCompletion) > 0     
                                         AND CHARINDEX ('0', @DataEntryCompletion) > 0) OR    
                                  (@DataEntryCompletion = '1' AND TKD.IsAttributeUpdated = 1) OR    
                                  (@DataEntryCompletion = '0' AND (TKD.IsAttributeUpdated = 0 OR     
                                         TKD.IsAttributeUpdated IS NULL)))    
                           AND TKD.IsDeleted = 0     
   GROUP BY     
    TKD.ProjectId, TKD.ProjectName, TKD.TicketID, TKD.TicketDescription,     
                     TKD.TicketTypeMapID, IHSP.TowerName, IHSP.HierarchyOneName,     
                     IHSP.HierarchyTwoName ,    
                     IHSP.HierarchyThreeName ,    
                     IHSP.HierarchyFourName ,    
                     IHSP.HierarchyFiveName ,    
                     IHSP.HierarchyFiveName ,                         
      TKD.CauseCodeMapID, TKD.ResolutionCodeMapID, TKD.OpenDateTime,     
                     TKD.ClosedDate, TKD.AssignedTo, TKD.PriorityMapID, TKD.TicketStatusMapID,     
                     TKD.DARTStatusID, TKD.ReopenDateTime, TKD.IsSDTicket, TKD.SeverityMapID,     
                     TKD.ReleaseTypeMapID, TKD.PlannedEffort, TKD.EstimatedWorkSize, TKD.ActualWorkSize,     
                     TKD.PlannedStartDate, TKD.PlannedEndDate, TKD.IsManual, TKD.EffortTillDate,     
                     TKD.NewStatusDateTime, TKD.RejectedDateTime, TKD.KEDBAvailableIndicatorMapID,     
                     TKD.KEDBUpdatedMapID, TKD.ElevateFlagInternal, TKD.RCAID, TKD.MetResponseSLAMapID,     
                     TKD.MetAcknowledgementSLAMapID, TKD.MetResolutionMapID, TKD.ActualStartDateTime,     
                     TKD.ActualEndDateTime, TKD.ActualDuration, TKD.NatureOfTheTicket, TKD.Comments,     
                     TKD.RepeatedIncident, TKD.RelatedTickets, TKD.TicketCreatedBy, TKD.KEDBPath,     
                     TKD.EscalatedFlagCustomer, TKD.ApprovedBy, TKD.StartedDateTime, TKD.WIPDateTime,     
                     TKD.OnHoldDateTime, TKD.CompletedDateTime, TKD.CancelledDateTime, TKD.OutageDuration,     
                     TKD.DebtClassificationMapID, TKD.AvoidableFlag, TKD.ResidualDebtMapID,     
                     TKD.ResolutionRemarks,TKD.IsAttributeUpdated    
       ,TKD.FlexField1,TKD.FlexField2,    
      TKD.FlexField3,TKD.FlexField4,TKD.Category,TKD.[Type],TKD.IsDeleted    
    
    
      --------------------------    
    
         SELECT DISTINCT    
      TKD.ProjectName, TKD.TicketID,     
      TKD.TicketDescription,     
      ISNULL(TKTM.TicketType,TKTMAS.TicketTypeName) AS TicketType,    
      0 as ApplicationName,    
                     TKD.TowerName, TKD.Hierarchy1, TKD.Hierarchy2, TKD.Hierarchy3, TKD.Hierarchy4,    
                     TKD.Hierarchy5, TKD.Hierarchy6,     
      0 as  Service,    
      0 as  ServiceGroup,    
                     CC.CauseCode, RC.ResolutionCode,     
                     TKD.OpenDateTime AS OpenDate, TKD.ClosedDate,     
      LM.EmployeeName AS Assignee,     
                     PR.PriorityName AS [Priority], PSM.StatusName AS [Status],     
                     DTSTS.DARTStatusName AS AppLensStatus,     
      TKD.ReopenDateTime AS ReopenDate,     
                     CASE WHEN TKD.IsSDTicket = 1 THEN @ApplensTicket ELSE @SMTicket END AS [Source],    
                     SEV.SeverityName AS Severity, RT.ReleaseTypeName AS ReleaseType,     
                     ISNULL(TKD.PlannedEffort, 0) AS PlannedEffort,     
                     ISNULL(TKD.EstimatedWorkSize, 0) AS EstimatedWorkSize,     
                     ISNULL(TKD.ActualWorkSize, 0) AS ActualWorkSize,     
                     TKD.PlannedStartDate, TKD.PlannedEndDate,     
                     CASE WHEN TKD.IsManual = 1 THEN 'Manual'    
                           WHEN TKD.IsManual = 0 THEN 'Upload' END AS InsertionMode,     
                     TKD.EffortTillDate, TKD.NewStatusDateTime, TKD.RejectedDateTime AS RejectedTimeStamp,     
                     KEDBA.KEDBAvailableIndicatorName AS KEDBAvailableIndicator,     
                     CASE WHEN TKD.IsAttributeUpdated=1 THEN 'Yes' ELSE 'No' END AS DataEntryComplete,    
                     KEDBU.KEDBUpdatedName AS KEDBUpdated, ELFI.MetSLAName AS ElevateFlagInternal,     
                     TKD.RCAID,     
      RESSLA.MetSLAName AS MetResponseSLA,     
                     ACKSLA.MetSLAName AS MetAcknowledgementSLA, RESLSLA.MetSLAName AS MetResolution,     
                     TKD.ActualStartDateTime, TKD.ActualEndDateTime,     
                     ISNULL(TKD.ActualDuration, 0) AS ActualDuration,     
      NT.[Nature Of The Ticket] AS NatureOfTheTicket,    
       TKD.Comments, TKD.RepeatedIncident, TKD.RelatedTickets,     
                     TKD.TicketCreatedBy AS TicketCreatedBy, TKD.KEDBPath,     
                     EFC.[Escalated Flag Customer] AS EscalatedFlagCustomer,    
                     TKD.ApprovedBy AS ApprovedBy, TKD.StartedDateTime, TKD.WIPDateTime,     
                     TKD.OnHoldDateTime, TKD.CompletedDateTime, TKD.CancelledDateTime,     
                     ISNULL(TKD.OutageDuration, 0) AS OutageDuration,     
                     DBTCL.DebtClassificationName AS DebtClassification,     
                     AVDF.AvoidableFlagName AS AvoidableFlag, RSDBT.ResidualDebtName AS ResidualDebt,     
                  TKD.ResolutionRemarks,    
TKD.FlexField1,TKD.FlexField2,TKD.FlexField3,TKD.FlexField4,TKD.Category,TKD.[Type],LM.ClientUserID as ClientUserID    
              FROM #InfraTicketDetails TKD  (NOLOCK)  
              LEFT JOIN #LoginTemp LM  (NOLOCK)  
                     ON LM.UserID = TKD.AssignedTo --AND LM.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAP_TicketTypeMapping (NOLOCK) TKTM    
                     ON TKTM.TicketTypeMappingID = TKD.TicketTypeMapID     
                           AND TKTM.ProjectID = TKD.ProjectID     
                           AND (ISNULL(@TicketTypeIDs,'') = '' OR    
                                  (TKTM.AVMTicketType IN (SELECT Item FROM #TicketTypeIDs(NOLOCK)) AND @IsCognizant=1) OR    
        (TKTM.TicketTypeMappingID IN (SELECT Item FROM #TicketTypeIDs(NOLOCK)) AND @IsCognizant=0)  )    
                 AND TKTM.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_TicketType (NOLOCK) TKTMAS    
                     ON TKTMAS.TicketTypeID IN (SELECT Item FROM #TicketTypeIDs(NOLOCK))    
                           AND (ISNULL(@TicketTypeIDs,'') = '' OR --TKTM.AVMTicketType=TKTM.AVMTicketType OR    
                                  TKTMAS.TicketTypeID IN (SELECT Item FROM #TicketTypeIDs(NOLOCK)))    
                           AND TKTMAS.IsDeleted = 0    
              LEFT JOIN [AVL].DEBT_MAP_CauseCode (NOLOCK) CC    
                     ON CC.CauseID = TKD.CauseCodeMapID AND CC.IsDeleted = 0    
              LEFT JOIN [AVL].DEBT_MAP_ResolutionCode (NOLOCK) RC    
                     ON RC.ResolutionID = TKD.ResolutionCodeMapID AND RC.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAP_PriorityMapping (NOLOCK) PR    
                     ON PR.PriorityIDMapID = TKD.PriorityMapID AND PR.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAP_SeverityMapping (NOLOCK) SEV    
                     ON SEV.SeverityIDMapID = TKD.SeverityMapID AND SEV.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_ReleaseType (NOLOCK) RT    
                     ON RT.ReleaseTypeID = TKD.ReleaseTypeMapID AND RT.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_KEDBAvailableIndicator (NOLOCK) KEDBA    
                     ON KEDBA.KEDBAvailableIndicatorID = TKD.KEDBAvailableIndicatorMapID     
                           AND KEDBA.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_KEDBUpdated (NOLOCK) KEDBU    
                     ON KEDBU.KEDBUpdatedID = TKD.KEDBUpdatedMapID AND KEDBU.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_MetSLACondition (NOLOCK) ELFI    
                     ON ELFI.MetSLAId = TKD.ElevateFlagInternal AND ELFI.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_MetSLACondition (NOLOCK) AVDFLG    
                     ON AVDFLG.MetSLAId = TKD.MetResponseSLAMapID AND AVDFLG.IsDeleted = 0     
              LEFT JOIN [AVL].TK_MAS_MetSLACondition (NOLOCK) RESSLA    
                     ON RESSLA.MetSLAId = TKD.MetResponseSLAMapID AND RESSLA.IsDeleted = 0     
              LEFT JOIN [AVL].TK_MAS_MetSLACondition (NOLOCK) ACKSLA    
                     ON ACKSLA.MetSLAId = TKD.MetAcknowledgementSLAMapID AND ACKSLA.IsDeleted = 0    
              LEFT JOIN [AVL].TK_MAS_MetSLACondition (NOLOCK) RESLSLA    
                     ON RESLSLA.MetSLAId = TKD.MetResolutionMapID AND RESLSLA.IsDeleted = 0         
              LEFT JOIN AVL.DEBT_MAS_DebtClassificationInfra (NOLOCK) DBTCL    
                     ON DBTCL.DebtClassificationID = TKD.DebtClassificationMapID AND DBTCL.IsDeleted = 0     
              LEFT JOIN AVL.DEBT_MAS_ResidualDebt (NOLOCK) RSDBT    
                     ON RSDBT.ResidualDebtID = TKD.ResidualDebtMapID AND RSDBT.IsDeleted = 0     
              LEFT JOIN [AVL].DEBT_MAS_AvoidableFlag (NOLOCK) AVDF    
                     ON AVDF.AvoidableFlagID = TKD.AvoidableFlag AND AVDF.IsDeleted = 0     
              LEFT JOIN [AVL].TK_MAP_ProjectStatusMapping (NOLOCK) PSM    
                     ON PSM.StatusID = TKD.TicketStatusMapID AND PSM.IsDeleted = 0            
              LEFT JOIN [AVL].TK_MAS_DARTTicketStatus (NOLOCK) DTSTS    
                     ON DTSTS.DARTStatusID = TKD.DARTStatusID AND DTSTS.IsDeleted = 0      
     LEFT JOIN AVL.ITSM_MAS_Natureoftheticket (NOLOCK) NT    
      ON NT.NatureOfTheTicketId=TKD.NatureOfTheTicket AND NT.IsDeleted = 0     
     LEFT JOIN AVL.ITSM_MAS_EscalatedFlagCustomer (NOLOCK) EFC    
      ON EFC.EscalatedFlagCustomerId=TKD.EscalatedFlagCustomer AND EFC.IsDeleted = 0                        
    
END    
                                     
   END TRY      
   BEGIN CATCH      
              DECLARE @ErrorMessage VARCHAR(MAX);    
              SELECT @ErrorMessage = ERROR_MESSAGE()    
              --Insert Error        
              EXEC AVL_InsertError '[AVL].[Effort_GetSearchTickets]',@ErrorMessage, 0, 0    
              RETURN @@ERROR    
   END CATCH    
   SET NOCOUNT OFF;  
END  