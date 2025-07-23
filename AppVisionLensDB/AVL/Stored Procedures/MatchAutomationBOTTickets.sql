/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ====================================================================================================================  
-- Author   : Sreeya  
-- Create Date   : 5-2-2020  
-- Description   : Matches BOT and Automation tickets   
-- Revision By   :   
-- Revision Date :   
-- ====================================================================================================================   
  
CREATE PROCEDURE [AVL].[MatchAutomationBOTTickets]  
AS     
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @JobID INT;  
 DECLARE @JobName VARCHAR(50) = 'Automation BOT Mapping' ;  
 DECLARE @JobStartTime DATETIME;  
 DECLARE @Success VARCHAR(10) ='Success'  
 DECLARE @Failed VARCHAR(10) ='Failed'  
 DECLARE @ErrorMessage VARCHAR(MAX);   
 DECLARE @JobDate DATETIME;  
 DECLARE @InsertedRowCount BIGINT=0;  
 DECLARE @UpdatedRowCount BIGINT=0;  
 SET @JobStartTime=GETDATE()  
  
  
 BEGIN TRY   
  BEGIN TRAN  
  
  SELECT @JobID = JobID FROM MAS.JobMaster WHERE JobName =@JobName;  
    
    --STEP 1--  
  
  IF EXISTS(SELECT 1 FROM MAS.JobStatus WHERE JobId=@JobID AND JobStatus=@Success)  
  BEGIN  
   SELECT TOP 1 @JobDate=JobRunDate FROM MAS.JobStatus WHERE JobId=@JobID AND JobStatus=@Success ORDER BY JobRunDate DESC;  
  END    
  
  
    --STEP 2--  
  CREATE TABLE #TicketData  
   (  
    [TimeTickerID] BIGINT,  
    [ProjectID] [BIGINT] NULL,  
    [TicketID] [nvarchar](100) NULL,  
    [ApplicationID] [BIGINT]  NULL,  
    [DebtClassificationID] [int]  NULL,  
    [AvoidableFlagID] [int]   NULL,  
    [CauseCodeID] [Nvarchar](150)  NULL,  
    [ResolutionCodeID] [Nvarchar](150) NULL,  
    [FlexField1] [Nvarchar](MAX)  NULL,  
    [FlexField2] [Nvarchar](MAX)  NULL,  
    [FlexField3] [Nvarchar](MAX)  NULL,  
    [FlexField4] [Nvarchar](MAX)  NULL,  
    OptionalAttributeType INT NULL,  
    IsWebRule INT NULL,  
    TicketPattern [NVARCHAR](MAX) NULL,  
    SupportType INT NULL,  
    TowerID BIGINT NULL,  
    RuleID BIGINT NULL,  
    LWRuleID BIGINT NULL,  
    IsSimilar INT NULL,  
    [AHTicketID] [nvarchar](100) NULL,  
    IsDeleted BIT NULL  
  
  )  
  
  --STEP 3--  
  IF @JobDate IS NOT NULL   
  BEGIN  
    INSERT INTO   
    #TicketData(ProjectID,TicketID,ApplicationID,ResolutionCodeID,CauseCodeID,DebtClassificationID,AvoidableFlagID,OptionalAttributeType,FlexField1,  
    FlexField2,FlexField3,FlexField4,TimeTickerID,SupportType,TowerID,IsDeleted)  
    SELECT   
    BOT.ProjectID,BOT.TicketID,BOT.ApplicationID,BOT.ResolutionCodeMapID,BOT.CauseCodeMapID,BOT.DebtClassificationMapID,BOT.AvoidableFlag,  
    PDM.OptionalAttributeType,BOT.FlexField1,BOT.FlexField2,BOT.FlexField3,BOT.FlexField4,BOT.TimeTickerID,BOT.SupportType,BOT.TowerID,0  
    FROM   
      AVL.TK_TRN_BOTTicketDetail BOT With (NOLOCK)   
    JOIN   
      AVL.MAS_ProjectMaster PM  (NOLOCK) ON PM.ProjectID=BOT.ProjectID   
    JOIN   
      AVL.MAS_ProjectDebtDetails PDM  (NOLOCK) ON PM.ProjectID=PDM.ProjectID   
    WHERE   
      DARTStatusID IN (8,9) AND  LastUpdatedDate >= @JobDate AND PM.IsDeleted=0 AND PM.IsDebtEnabled='Y'   
    AND PDM.IsDeleted=0;  
  END  
  ELSE  
  BEGIN  
    INSERT INTO #TicketData(ProjectID,TicketID,ApplicationID,ResolutionCodeID,CauseCodeID,DebtClassificationID,AvoidableFlagID,OptionalAttributeType,FlexField1  
    ,FlexField2,FlexField3,FlexField4,TimeTickerID,SupportType,TowerID,IsDeleted)  
    SELECT   
    BOT.ProjectID,BOT.TicketID,BOT.ApplicationID,BOT.ResolutionCodeMapID,BOT.CauseCodeMapID,BOT.DebtClassificationMapID,BOT.AvoidableFlag,  
    PDM.OptionalAttributeType,BOT.FlexField1,BOT.FlexField2,BOT.FlexField3,BOT.FlexField4,BOT.TimeTickerID,BOT.SupportType,BOT.TowerID,0  
    FROM     
    AVL.TK_TRN_BOTTicketDetail BOT With  (NOLOCK)   
    JOIN   
    AVL.MAS_ProjectMaster PM  (NOLOCK) ON PM.ProjectID=BOT.ProjectID   
    JOIN   
    AVL.MAS_ProjectDebtDetails PDM  (NOLOCK) ON PM.ProjectID=PDM.ProjectID   
    WHERE DARTStatusID IN (8,9) AND PM.IsDeleted=0 AND PM.IsDebtEnabled='Y' AND PDM.IsDeleted=0;  
  END  
  
--SELECT * FROM #TicketData;  
  
  --STEP 4--  
  UPDATE TD   
    SET TD.RuleID=TDR.RuleID,  
     TD.LWRuleID=TDR.LWRuleID,TD.IsWebRule=CASE WHEN ISNULL(TDR.LWRuleID,0)=0 THEN 2 ELSE 3 END   
  FROM   
    #TicketData TD With  (NOLOCK)    
  LEFT JOIN   
    AVL.TK_TRN_TicketDetail_RuleID TDR  (NOLOCK) ON TD.TimeTickerID = TDR.TimeTickerID  
  WHERE (OptionalAttributeType=2 OR OptionalAttributeType=3)  AND SupportType=1;  
  
  UPDATE TD   
    SET TD.RuleID=TDR.RuleID,  
     TD.LWRuleID=TDR.LWRuleID,TD.IsWebRule=CASE WHEN ISNULL(TDR.LWRuleID,0)=0 THEN 2 ELSE 3 END   
  FROM   
    #TicketData TD With  (NOLOCK)   
  LEFT JOIN   
    AVL.TK_TRN_InfraTicketDetail_RuleID TDR  (NOLOCK) ON TD.TimeTickerID = TDR.TimeTickerID  
  WHERE (OptionalAttributeType=2 OR OptionalAttributeType=3) AND SupportType=2;  
  
  --STEP 5--  
  UPDATE TD   
  SET TicketPattern=  
    (CONVERT(NVARCHAR(100),ISNULL(TD.TowerID,0)) +'-'+  
    CONVERT(NVARCHAR(10),ISNULL(ResolutionCodeID,0))+'-'+  
    CONVERT(NVARCHAR(10),ISNULL(TD.CauseCodeID,0))+'-'+  
    CONVERT(NVARCHAR(10),ISNULL(TD.DebtClassificationID,0))+'-'  
    +CONVERT(NVARCHAR(10),ISNULL(TD.AvoidableFlagID,0))+'-'+  
  CASE WHEN (TD.OptionalAttributeType = 1 OR TD.OptionalAttributeType = 3) AND ((SELECT AVL.CheckFlexFieldsIsMap(TD.ProjectID,11)) = 1)  
  THEN CONVERT(NVARCHAR(100),ISNULL(FlexField1,0))  
  ELSE '0' END +'-'+  
  CASE WHEN (TD.OptionalAttributeType = 1 OR TD.OptionalAttributeType = 3) AND ((SELECT AVL.CheckFlexFieldsIsMap(TD.ProjectID,12)) = 1)  
  THEN CONVERT(NVARCHAR(100),ISNULL(FlexField2,0))  
  ELSE '0' END +'-'+  
  CASE WHEN (TD.OptionalAttributeType = 1 OR TD.OptionalAttributeType = 3) AND ((SELECT AVL.CheckFlexFieldsIsMap(TD.ProjectID,13)) = 1)  
  THEN CONVERT(NVARCHAR(100),ISNULL(FlexField3,0))  
  ELSE '0' END +'-'+  
  CASE WHEN (TD.OptionalAttributeType = 1 OR TD.OptionalAttributeType = 3) AND ((SELECT AVL.CheckFlexFieldsIsMap(TD.ProjectID,14)) = 1)  
  THEN CONVERT(NVARCHAR(100),ISNULL(FlexField4,0))  
  ELSE '0' END +'-'+  
  CASE WHEN (TD.OptionalAttributeType = 2 OR TD.OptionalAttributeType = 3)  
  THEN CONVERT(NVARCHAR(25),ISNULL(RuleID,0))  
  ELSE '0' END +'-0-0')  
  FROM #TicketData TD WHERE TD.SupportType=2;  
       
  
  UPDATE TD   
  SET TicketPattern=  
    (CONVERT(VARCHAR(100),ISNULL(TD.ApplicationID,0)) +'-'+  
    CONVERT(VARCHAR(10),ISNULL(TD.ResolutionCodeID,0))+'-'+  
    CONVERT(VARCHAR(10),ISNULL(TD.CauseCodeID,0))+'-'+  
    CONVERT(VARCHAR(10),ISNULL(TD.DebtClassificationID,0))+'-'  
    +CONVERT(VARCHAR(10),ISNULL(TD.AvoidableFlagID,0))+'-'+  
  CASE WHEN (TD.OptionalAttributeType = 1 OR TD.OptionalAttributeType = 3) AND ((SELECT AVL.CheckFlexFieldsIsMap(TD.ProjectID,11)) = 1)  
  THEN CONVERT(NVARCHAR(100),ISNULL(FlexField1,0))  
  ELSE '0' END +'-'+  
  CASE WHEN (TD.OptionalAttributeType = 1 OR TD.OptionalAttributeType = 3) AND ((SELECT AVL.CheckFlexFieldsIsMap(TD.ProjectID,12)) = 1)  
  THEN CONVERT(NVARCHAR(100),ISNULL(FlexField2,0))  
  ELSE '0' END +'-'+  
  CASE WHEN (TD.OptionalAttributeType = 1 OR TD.OptionalAttributeType = 3) AND ((SELECT AVL.CheckFlexFieldsIsMap(TD.ProjectID,13)) = 1)  
  THEN CONVERT(NVARCHAR(100),ISNULL(FlexField3,0))  
  ELSE '0' END +'-'+  
  CASE WHEN (TD.OptionalAttributeType = 1 OR TD.OptionalAttributeType = 3) AND ((SELECT AVL.CheckFlexFieldsIsMap(TD.ProjectID,14)) = 1)  
  THEN CONVERT(NVARCHAR(100),ISNULL(FlexField4,0))  
  ELSE '0' END +'-'+  
  CASE WHEN (TD.OptionalAttributeType = 2 OR TD.OptionalAttributeType = 3) AND TD.IsWebRule=2   
  THEN CONVERT(NVARCHAR(25),ISNULL(TD.RuleID,0))  
  ELSE CONVERT(NVARCHAR(25),ISNULL(TD.LWRuleID,0)) END +'-0-0')  
  FROM #TicketData TD WHERE TD.SupportType=1;  
     
  --STEP 6--  
  
  UPDATE TD   
  SET TD.IsSimilar=1,AHTicketID=htd.HealingTicketID   
  FROM   
   #TicketData TD  With  (NOLOCK)  
  JOIN   
   AVL.DEBT_PRJ_HealProjectPatternMappingDynamic HPD  (NOLOCK)  
  ON TD.TicketPattern=HPD.HealPattern   
  JOIN   
  AVL.DEBT_TRN_HealTicketDetails HTD  (NOLOCK) ON HPD.ProjectPatternMapID=HTD.ProjectPatternMapID   
  WHERE   
   HPD.IsDeleted=0 AND HTD.IsDeleted=0 AND TD.SupportType=1 AND PatternStatus=1 AND HTD.TicketType='A'  
   AND DARTStatusID NOT IN (8,9,5,7);  
  
  UPDATE TD   
  SET TD.IsSimilar=1,AHTicketID=htd.HealingTicketID   
  FROM   
   #TicketData TD With  (NOLOCK)  
  JOIN   
   AVL.DEBT_PRJ_InfraHealProjectPatternMappingDynamic HPD   (NOLOCK)  
  ON TD.TicketPattern=HPD.HealPattern   
  JOIN   
  AVL.DEBT_TRN_InfraHealTicketDetails HTD  (NOLOCK) ON HPD.ProjectPatternMapID=HTD.ProjectPatternMapID   
  WHERE   
   HPD.IsDeleted=0 AND HTD.IsDeleted=0 AND TD.SupportType=2 AND PatternStatus=1 AND HTD.TicketType='A'  
   AND DARTStatusID NOT IN (8,9,5,7);  
  
  --SELECT * FROM #TicketData;  
  --STEP 7--  
  
  IF NOT EXISTS(SELECT TOP 1 * FROM avl.BotAutomationMapping)  
  BEGIN  
  
  PRINT 'FIRST INSERT'  
  INSERT INTO AVL.BotAutomationMapping(ProjectID,BoTTicketID,AHTicketID,SupportType,IsDeleted,CreatedBy,CreatedOn)  
  SELECT TD.ProjectID,TD.TicketID,TD.AHTicketID,TD.SupportType,0,'SYSTEM',GETDATE() FROM  #TicketData TD WHERE TD.IsSimilar=1;  
  SET @InsertedRowCount=@@ROWCOUNT;  
  
  END  
  ELSE  
  BEGIN  
  
  PRINT 'UPDATE QUERY'  
  --FINDING ALREADY EXISTING TICKETS  
  UPDATE TD SET Td.IsDeleted=1 FROM #TicketData TD  With  (NOLOCK) JOIN AVL.BotAutomationMapping BA (NOLOCK) ON BA.AHTicketID=TD.AHTicketID  
  AND BA.BoTTicketID=TD.TicketID AND BA.ProjectID=TD.ProjectID WHERE TD.IsSimilar=1 AND BA.IsDeleted=0;  
  
  --FINDING EXISTING TICKETS WHICH HAVE BEEN MODIFIED AND NO AH TICKET MATCH IS FOUND  
  UPDATE TD SET TD.IsSimilar=2 FROM #TicketData TD With  (NOLOCK) JOIN AVL.BotAutomationMapping BA  (NOLOCK) ON   
  BA.BoTTicketID=TD.TicketID AND BA.ProjectID=TD.ProjectID WHERE TD.AHTicketID IS NULL AND BA.IsDeleted=0;  
  
  --FINDING ID OF EXISTING TICKETS WHICH ARE MAPPED TO NEW TICKETS/NO AH MATCH FOUND  
  SELECT BA.ID AS 'ID' INTO #UpdateTblList FROM #TicketData TD  With  (NOLOCK) JOIN AVL.BotAutomationMapping BA  (NOLOCK) ON  BA.BoTTicketID=TD.TicketID   
  AND BA.ProjectID=TD.ProjectID AND TD.IsDeleted=0 AND (TD.IsSimilar=1 OR TD.IsSimilar=2) AND BA.IsDeleted=0;  
  
  --DELETING THOSE TICKETS  
  UPDATE BA SET IsDeleted=1,ModifiedBy='SYSTEM',ModifiedOn=GETDATE() FROM AVL.BotAutomationMapping BA With  (NOLOCK) JOIN   
  #UpdateTblList tbl  (NOLOCK) on tbl.ID=BA.ID AND BA.IsDeleted=0;  
  SET @UpdatedRowCount=@@ROWCOUNT;  
  
  --REMAPPING TICKETS TO PREVENT DUPLICATE INSERTION  
  UPDATE TD SET TD.IsSimilar=3 FROM #TicketData TD With  (NOLOCK) JOIN AVL.BotAutomationMapping BA  (NOLOCK) ON   
  BA.BoTTicketID=TD.TicketID AND BA.ProjectID=TD.ProjectID AND BA.AHTicketID=TD.AHTicketID WHERE  
  TD.IsSimilar=1 AND TD.IsDeleted=0 AND BA.IsDeleted=1;  
  
  UPDATE BA SET IsDeleted=0,ModifiedBy='SYSTEM',ModifiedOn=GETDATE() FROM AVL.BotAutomationMapping BA With (NOLOCK) JOIN   
  #TicketData TD  (NOLOCK) ON BA.BoTTicketID=TD.TicketID AND BA.ProjectID=TD.ProjectID AND BA.AHTicketID=TD.AHTicketID  
  WHERE TD.IsSimilar=3 AND TD.IsDeleted=0 AND BA.IsDeleted=1;  
  SET @UpdatedRowCount=@UpdatedRowCount+@@ROWCOUNT;  
  
  --INSERTING NEW TICETS  
  INSERT INTO AVL.BotAutomationMapping(ProjectID,BoTTicketID,AHTicketID,SupportType,IsDeleted,CreatedBy,CreatedOn)  
  SELECT TD.ProjectID,TD.TicketID,TD.AHTicketID,TD.SupportType,0,'SYSTEM',GETDATE() FROM  #TicketData TD  With  (NOLOCK)  
  WHERE TD.IsSimilar=1 AND IsDeleted=0 ;  
  SET @InsertedRowCount=@@ROWCOUNT;  
  
  DROP TABLE #UpdateTblList;  
  
  END  
  
    --Auto Close the BOT Tickets
  UPDATE HT SET DARTStatusID=8,closedDate=GETDATE(),ReasonForCancellation='Closed based on BoT Ticket Upload',
  ModifiedBy='SYSTEM',ModifiedDate=GETDATE() FROM AVL.DEBT_TRN_HealTicketDetails HT 
  JOIN AVL.BotAutomationMapping as BT ON BT.AHTicketID=HT.HealingTicketID   
  JOIN #TicketData as TD ON BT.BoTTicketID=TD.TicketID AND BT.ProjectID=TD.ProjectID AND BT.AHTicketID=TD.AHTicketID  
  WHERE HT.DARTStatusID NOT IN (8,9,5,7) AND (TD.IsSimilar=1 OR TD.IsSimilar=2) AND BT.SupportType=1 AND
  TD.IsDeleted=0 AND BT.IsDeleted=0 AND HT.IsDeleted=0
  SET @UpdatedRowCount=@UpdatedRowCount+@@ROWCOUNT; 

    --Auto Close the BOT InfraTickets
  UPDATE IHT SET DARTStatusID=8,closedDate=GETDATE(),ReasonForCancellation='Closed based on BoT Ticket Upload',
  ModifiedBy='SYSTEM',ModifiedDate=GETDATE() FROM  AVL.DEBT_TRN_InfraHealTicketDetails IHT 
  JOIN AVL.BotAutomationMapping as BT ON BT.AHTicketID=IHT.HealingTicketID   
  JOIN #TicketData as TD ON BT.BoTTicketID=TD.TicketID AND BT.ProjectID=TD.ProjectID AND BT.AHTicketID=TD.AHTicketID  
  WHERE IHT.DARTStatusID NOT IN (8,9,5,7) AND (TD.IsSimilar=1 OR TD.IsSimilar=2) AND BT.SupportType=2 AND 
  TD.IsDeleted=0 AND BT.IsDeleted=0 AND IHT.IsDeleted=0
  SET @UpdatedRowCount=@UpdatedRowCount+@@ROWCOUNT; 

  
  
  --STEP 8--  
  
  --SELECT * FROM #TicketData;  
  
  DROP TABLE #TicketData;  
  
  
    
  --STEP 9--      
      
     INSERT INTO MAS.JobStatus  
     (JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,  
     DeletedRecordCount,UpdatedRecordCount)  
     VALUES(@JobID,@JobStartTime,GETDATE(),@Success,@JobStartTime,0,'SYSTEM',GETDATE(),  
     @InsertedRowCount,0,@UpdatedRowCount)  
       
  
  
  COMMIT TRAN  
  SET NOCOUNT OFF
 END TRY  
  
 BEGIN CATCH    
 ROLLBACK TRAN  
  
 SELECT @ErrorMessage = ERROR_MESSAGE() + ' Line Number :' + ERROR_LINE()  
  
 SELECT @JobID = JobID FROM MAS.JobMaster WHERE JobName =@JobName;  
  
 INSERT INTO MAS.JobStatus  
     (JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,  
     DeletedRecordCount,UpdatedRecordCount)  
     VALUES(@JobID,@JobStartTime,GETDATE(),@Failed,@JobStartTime,0,'SYSTEM',GETDATE(),  
     @InsertedRowCount,0,@UpdatedRowCount);   
  
 EXEC AVL_InsertError '[AVL].[MatchAutomationBOTTickets]', @ErrorMessage, 0,0  
  
  
 END CATCH   
   
END
