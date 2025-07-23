/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[sp_SaveHealDelinkMappingData]
(        
@ProjectID INT        
,@UserID NVARCHAR(50)        
,@HealingTicketID NVARCHAR(MAX)        
,@TicketList dbo.SaveHealDelinkingDetails READONLY        
)       
AS        
BEGIN        
BEGIN TRY        
BEGIN TRAN        
       SET NOCOUNT ON;             
            
       --push the values to temp table        
              CREATE TABLE #temp       
              (        
              ID INT IDENTITY        
              ,TicketID NVARCHAR(50)        
              ,Ischecked BIT        
              )        
        
              INSERT INTO #temp         
              SELECT * FROM @TicketList             
                      
              -- get the ticket type of the healing ticket        
        
              DECLARE @TicketType VARCHAR(50)        
        
              SET @TicketType = (SELECT TOP 1 TicketType FROM [AVL].[DEBT_TRN_HealTicketDetails]         
     WHERE HealingTicketID = @HealingTicketID and IsDeleted=0 AND ISNULL(ManualNonDebt,0) != 1)        
             
      
      
              CREATE TABLE #Heal_ProjectPatternMapping(       
                     [ProjectPatternMapID] [bigint] NULL,     
                     [ProjectID] [bigint] NOT NULL,     
                     [ApplicationID] [bigint] NULL,      
                     [AvoidableFlag] [int] NULL,           
                     HealPattern NVARCHAR(1000) NULL,     
                     [PatternFrequency] [int] NULL,      
                     [PatternStatus] [int] NULL,     
                     [IsDeleted] bit NULL,     
                     [IsManual] bit NULL,    
      RuleType INT NULL,        
      ResidualDebtId tinyint null ,  
   Algorithmkey NVARCHAR(12)  
                     )        
        
INSERT INTO #Heal_ProjectPatternMapping      
Select HPPM.ProjectPatternMapID,ProjectID,HPPM.ApplicationID, HPPM.AvoidableFlag,       
       HealPattern,PatternFrequency,PatternStatus,HPPM.IsManual,HPPM.IsDeleted,RuleType,ResidualDebtId,HPPM.Algorithmkey        
       FROM [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPPM With (NOLOCK)        
     INNER JOIN AVL.DEBT_TRN_HealTicketDetails HTD WITH (NOLOCK) ON HTD.ProjectPatternMapId = HPPM.ProjectPatternMapId        
     WHERE ProjectID=@ProjectID AND ISNULL(HPPM.ManualNonDebt,0) != 1 AND HTD.HealingTicketID=@HealingTicketID and HTD.IsDeleted=0     
        
 --get the count of ticket, to increment the ticket id        
        
 DECLARE @TicketCount NVARCHAR(50)         
 DECLARE @NewHealingTicketID NVARCHAR(50)                       
        
     SET @NewHealingTicketID = @TicketType + (SELECT TOP 1 ESAProjectId FROM AVL.AHKIdGeneration         
          WHERE ProjectID=@ProjectId AND Category= (CASE WHEN @TicketType IN ('A','H') THEN 'AH' ELSE 'K' END)) +        
            RIGHT('0000000'+CONVERT(VARCHAR,(SELECT TOP 1 (NextId + 1) FROM AVL.AHKIdGeneration         
            WHERE ProjectID=@ProjectId AND Category=(CASE WHEN @TicketType IN ('A','H') THEN 'AH' ELSE 'K' END))),8)        
      --PRINT @NewHealingTicketID        
     Update  [AVL].[AHKIdGeneration]  Set NextId=(NextId+1)         
     WHERE  ProjectID=@ProjectId and Category=(CASE WHEN @TicketType IN ('A','H') THEN 'AH' ELSE 'K' END)        
        
 DECLARE @ProjectPatternMapID NVARCHAR(50)                      
                           
     SET @ProjectPatternMapID = (SELECT TOP 1 ProjectPatternMapID FROM [AVL].[DEBT_TRN_HealTicketDetails] WHERE HealingTicketID = @HealingTicketID and IsDeleted=0        
           AND ISNULL(ManualNonDebt,0) != 1)              
                        
              -- insert the entry into PRJ.Heal_ProjectPatternMapping        
      DECLARE @TotalCount NVARCHAR(50)        
        
              SET @TotalCount = (SELECT COUNT(ID) FROM #temp  WHERE Ischecked='1')        
                                   
        -- PRINT @ProjectPatternMapID        
              INSERT INTO [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (ProjectID,AvoidableFlag,ApplicationID,HealPattern        
        
           ,PatternFrequency,PatternStatus,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,IsDeleted,IsManual,RuleType,ManualNonDebt,        
     IsEffectiveness,ResidualDebtId,LastChildUpdatedDate,Algorithmkey)        
        
              SELECT ProjectID,AvoidableFlag,ApplicationID,HealPattern,        
              @TotalCount-1,PatternStatus,@UserID,GETDATE(),NULL,NULL,0,1,ISNULL(RuleType,1),0,        
     0,ResidualDebtId,GETDATE(),Algorithmkey        
              FROM #Heal_ProjectPatternMapping WHERE ProjectPatternMapID = @ProjectPatternMapID        
             
                      
     --get the projectpatternmap id for the newly created healing ticket                                 
       --print SCOPE_IDENTITY()        
              DECLARE @NewProjectPatternMapID NVARCHAR(50)                   
        
              SET @NewProjectPatternMapID = (SELECT SCOPE_IDENTITY())        
        
              print @NewProjectPatternMapID                                   
        
              --insert an entry in to TRN.Heal_TicketDetails                                   
        
              INSERT INTO [AVL].[DEBT_TRN_HealTicketDetails] (ProjectPatternMapID,HealingTicketID,TicketType,DARTStatusID,Assignee,OpenDate,PriorityID,IsManual,IsPushed        
        
       ,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,IsDeleted,IsMappedToProblemTicket,PlannedEffort,HealTypeId,PlannedStartDate,PlannedEndDate,ManualNonDebt)        
        
              SELECT @NewProjectPatternMapID,@NewHealingTicketID,TicketType,12,NULL,GETDATE(),NULL,1,0        
        
              ,@UserID,GETDATE(),NULL,NULL,0,0,NULL,NULL,NULL,NULL,0 FROM [AVL].[DEBT_TRN_HealTicketDetails]         
     WHERE ProjectPatternMapID = @ProjectPatternMapID AND ISNULL(ManualNonDebt,0) != 1        
             
             
              --insert into heal log table        
        
              INSERT INTO [AVL].[DEBT_TRN_HealTicketsLog] VALUES (@ProjectID,@NewHealingTicketID,14,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[DE].[HealTicketDetails]',NULL,NULL,NULL,NULL,@UserID,GETDATE())               
        
              INSERT INTO [AVL].[DEBT_TRN_HealTicketsLog] VALUES (@ProjectID,@NewHealingTicketID,2,NULL,NULL,NULL,NULL,@HealingTicketID,NULL,NULL,'[DE].[HealTicketDetails]',NULL,NULL,NULL,NULL,@UserID,GETDATE())               
        
                     
    -- check if the temp table have more than 1 value        
        
              SET @TotalCount = (SELECT COUNT(ID) FROM #temp)        
        
    /* ---- Checking whether A exists for H ticket ---*/        
    DECLARE @PartialAutomationTicketID NVARCHAR(50)        
    DECLARE @PartialProjectPatternMapID INT        
        
    SELECT @PartialAutomationTicketID=PartialAutomationTicketID        
     --@PartialProjectPatternMapID =ProjectPatternMapID        
      FROM AVL.DEBT_TRN_HealTicketDetails         
      WHERE HealingTicketID=@HealingTicketID --and IsPartialAutomationHealTicket=1        
         AND TicketType='H'        
                     
              WHILE (@TotalCount > 0)        
        
                     BEGIN        
        
                                  DECLARE @TicketID NVARCHAR(MAX)        
        
                                  DECLARE @Checked NVARCHAR(100)        
        
                                  SET @TicketID = (SELECT TOP 1 TicketID FROM #temp where Ischecked='1')        
        
                                  SET @Checked = (SELECT TOP 1 IsChecked FROM #temp where Ischecked='1')        
                                                    
        
                                  --deactivate the link betwen dart ticket and old helaing ticket        
        
                                  IF(@Checked  = '1')                                     
        
                                  BEGIN                                                                        
        
                                         UPDATE A SET A.MapStatus = 0, A.ModifiedBy = @UserID, ModifiedDate = GETDATE()         
        
                                         FROM [AVL].[DEBT_PRJ_HealParentChild] A INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] B         
        
                                         ON A.ProjectPatternMapID = B.ProjectPatternMapID        
        
                                         WHERE A.DARTTicketID = @TicketID AND A.IsDeleted =0        
        
                                         AND A.ProjectPatternMapID = @ProjectPatternMapID AND ISNULL(B.ManualNonDebt,0) != 1         
                   
            UPDATE AVL.DEBT_PRJ_HealProjectPatternMappingDynamic SET PatternFrequency = PatternFrequency - 1         
            WHERE ProjectPatternMapID = @ProjectPatternMapID   and ProjectID = @ProjectID                                
           AND ISNULL(ManualNonDebt,0) != 1        
                                                
                                         --insert the child ticket details into PRJ.Heal_ParentChild        
        
                                         INSERT INTO [AVL].[DEBT_PRJ_HealParentChild]         
           (ProjectPatternMapID,DARTTicketID,MapStatus,IsManual,IsDeleted,CreatedBy,CreatedDate,        
           ModifiedBy,ModifiedDate,TicketDescription,ResolutionRemarks,EffortTillDate,ITSMEffort)        
           --VALUES(@NewProjectPatternMapID,@TicketID,1,NULL,NULL,0,1)        
           SELECT @NewProjectPatternMapID,@TicketID,1,1,0,@UserID,GETDATE(),NULL,NULL,         
           TicketDescription,ResolutionRemarks,EffortTillDate,ITSMEffort        
           FROM [AVL].[DEBT_PRJ_HealParentChild] WHERE ProjectPatternMapID = @ProjectPatternMapID        
           AND DARTTicketID = @TicketID AND IsDeleted =0 AND MapStatus = 0        
        
                                         --Insert the mapping into [PRJ].[Heal_DelinkMapping] table                                          
             INSERT INTO [AVL].[DEBT_PRJ_DelinkMapping] VALUES (@HealingTicketID,@ProjectPatternMapID,@NewHealingTicketID        
                ,@NewProjectPatternMapID,@TicketID,0,@UserID,GETDATE(),NULL,NULL)                 
                   
                  
          -- Deactivating the child tickets of partail automated A tickets         
           IF(@PartialAutomationTicketID is not null and @PartialAutomationTicketID!='')        
           BEGIN        
        
           UPDATE A SET A.MapStatus = 0, A.ModifiedBy = @UserID, ModifiedDate = GETDATE()         
           FROM [AVL].[DEBT_PRJ_HealParentChild] A         
           INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] B         
              ON A.ProjectPatternMapID = B.ProjectPatternMapID        
           WHERE A.DARTTicketID = @TicketID AND A.IsDeleted =0        
           AND B.HealingTicketID= @PartialAutomationTicketID and B.TicketType='A'        
           AND B.IsManual=1        
        
           SELECT @PartialProjectPatternMapID =ProjectPatternMapID        
           FROM AVL.DEBT_TRN_HealTicketDetails         
           WHERE HealingTicketID=@PartialAutomationTicketID and TicketType='A'        
           AND IsManual=1        
        
            UPDATE AVL.DEBT_PRJ_HealProjectPatternMappingDynamic         
            SET PatternFrequency = PatternFrequency - 1         
            WHERE ProjectPatternMapID = @PartialProjectPatternMapID          
            and ProjectID = @ProjectID  AND IsManual=1        
            AND ISNULL(ManualNonDebt,0) != 1        
        
           END            
        
                               END        
        
                                  DELETE FROM #temp WHERE TicketID = @TicketID        
        
                                  SELECT * FROM #temp        
        
                                  SET @TotalCount = @TotalCount-1        
        
                                  PRINT @TotalCount        
        
                     END          
       SET NOCOUNT OFF;        
        
  COMMIT TRAN        
        
       END TRY          
    
BEGIN CATCH          
        
              DECLARE @ErrorMessage VARCHAR(MAX);        
        
              SELECT @ErrorMessage = ERROR_MESSAGE()        
        
              ROLLBACK TRAN        
        
              --INSERT Error            
        
              EXEC AVL_InsertError '[dbo].[sp_SaveHealDelinkMappingData] ', @ErrorMessage, @ProjectID,0        
        
       END CATCH          
END