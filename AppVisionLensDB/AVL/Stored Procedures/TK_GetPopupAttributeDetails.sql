/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[TK_GetPopupAttributeDetails]      
(      
-- Add the parameters for the stored procedure here       
 @ProjectID INT,      
 @ServiceID INT = null,      
 @StatusID INT =  null,      
 @TicketID VARCHAR(150),      
 @TicketTypeId bigint=null,      
 @SupportTypeID INT=NULL      
)      
AS      
BEGIN      
BEGIN TRY      
BEGIN TRAN  
 SET NOCOUNT ON;
  DECLARE @IsTaggedToATicket BIT       
  DECLARE @OptionalAttribute INT;      
  DECLARE @FlexField1 BIT ;      
  DECLARE @FlexField2 BIT ;      
  DECLARE @FlexField3 BIT ;      
  DECLARE @FlexField4 BIT ;      
  DECLARE @IsResolutionReConfiguredApp BIT;      
  DECLARE @IsResolutionReConfiguredInfra BIT;      
  DECLARE @AutoClassificationAppType tinyint = 0;      
  DECLARE @AutoClassificationInfraType tinyint = 1;    
  SET @IsTaggedToATicket=(SELECT 1 FROM AVL.DEBT_PRJ_HealParentChild(NOLOCK) HPD  
						  INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPPMD
							ON HPPMD.ProjectPatternMapID = HPD.ProjectPatternMapID
							WHERE HPPMD.ProjectID = @ProjectID AND HPD.DARTTicketID= @TicketID
						  AND HPD.MapStatus = 1 AND HPD.IsDeleted = 0 AND HPPMD.IsDeleted = 0)         
      
        
  SET @OptionalAttribute=(SELECT OptionalAttributeType FROM AVL.MAS_ProjectDebtDetails (NOLOCK)      
        WHERE ProjectID=@ProjectID AND IsDeleted = 0)      
      
  IF EXISTS       
   (SELECT 1 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)       
   WHERE ProjectID=@ProjectID AND IsActive=1 AND ColumnID=11)      
   BEGIN      
    SET @FlexField1=1;      
   END      
         
  IF EXISTS       
   (SELECT 1 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)      
   WHERE ProjectID=@ProjectID AND IsActive=1 AND  ColumnID=12)      
   BEGIN      
    SET @FlexField2=1;      
   END      
  IF EXISTS       
   (SELECT 1 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)       
   WHERE ProjectID=@ProjectID AND IsActive=1 AND  ColumnID=13)      
   BEGIN      
    SET @FlexField3=1;      
   END      
  IF EXISTS       
   (SELECT 1 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)      
   WHERE ProjectID=@ProjectID AND IsActive=1 AND  ColumnID=14)      
   BEGIN      
    SET @FlexField4=1;      
   END      
  IF EXISTS (SELECT TOP 1 ID FROM [ML].[ConfigurationProgress] (NOLOCK)      
     WHERE PROJECTID=@ProjectID AND IsOptionalField=1      
     and IsDeleted=0)      
   BEGIN      
    SET @IsResolutionReConfiguredApp=1;      
   END      
  SET @AutoClassificationAppType = (SELECT TOP 1 DebtAttributeId FROM [ML].[ConfigurationProgress] (NOLOCK)      
           WHERE PROJECTID=@ProjectID      
           and IsDeleted=0      
           ORDER BY ID ASC)      
  SET @AutoClassificationInfraType = (SELECT TOP 1 DebtAttributeId FROM [ML].[InfraConfigurationProgress] (NOLOCK)      
           WHERE PROJECTID=@ProjectID      
           and IsDeleted=0      
           ORDER BY ID ASC)   
    
  IF EXISTS (SELECT TOP 1 ID FROM [ML].[InfraConfigurationProgress] (NOLOCK)    
     WHERE PROJECTID=@ProjectID AND IsOptionalField=1    
     and IsDeleted=0)      
   BEGIN      
    SET @IsResolutionReConfiguredInfra=1;      
   END      
 IF (@SupportTypeID=1 OR @SupportTypeID IS NULL)      
 BEGIN      
 UPDATE TD SET TD.ServiceClassificationMode =        
   CASE        
   WHEN TD.ServiceClassificationMode = 3 THEN 4       
   WHEN TD.ServiceClassificationMode = 5 THEN 6        
   ELSE TD.ServiceClassificationMode      
   END         
  FROM avl.TK_TRN_TicketDetail TD      
  WHERE TD.TicketID = @TicketID      
   AND TD.ProjectID = @ProjectID      
   AND TD.IsDeleted = 0      
   AND @serviceid <> 0      
   AND TD.ServiceID != @ServiceID      
        
  update AVL.TK_TRN_TicketDetail set TicketTypeMapID=@TicketTypeId,       
           LastUpdatedDate=GETDATE(),      
           ModifiedDate=GETDATE()      
  where TicketID=@TicketID and ProjectID=@ProjectID AND @TicketTypeId != 0      
  SELECT DISTINCT AD.ApplicationName,      
  0 as TowerID,      
  '' as TowerName ,      
  TicketID,      
  ISNULL(OpenDateTime,'') AS TicketOpenDate,      
  TD.TicketDescription,      
  MP.PriorityName AS Priority,      
  TTM.TicketType AS TicketType,      
  isnull(CC.CauseCode,0) as CauseCode,      
  isnull(RC.ResolutionCode,0) as ResolutionCode,      
  DC.DebtClassificationName AS DebtType,      
  ISNULL(AvoidableFlag,'0')AS AvoidableFlag,      
  RD.ResidualDebtName AS ResidualDebt,      
  SM.SeverityName AS Severity,      
  ISNULL(LM.EmployeeName,'') AS AssignedTo,      
  TS.TicketSourceName AS TicketSource,      
  RT.ReleaseTypeName AS ReleaseType,      
  EstimatedWorkSize,      
  EffortTillDate as ActualEffort,      
  ISNULL(OpenDateTime,'') AS TicketCreateDate,      
  ISNULL(ActualStartdateTime,'') AS ActualStartdateTime,      
  ISNULL(ActualEnddateTime,'') AS ActualEnddateTime,      
  ISNULL(TD.Closeddate,'') AS Closeddate,      
  KU.KEDBUpdatedName AS KEDBUpdated,      
  KAI.KEDBAvailableIndicatorName AS KEDBAvailable,      
  TD.KEDBPath,      
  RCAID,      
  Actualduration,      
  ISNULL(MetResponseSLAMapID,0) AS MetResponseSLA,      
  ISNULL(MetAcknowledgementSLAMapID,0) AS MetAcknowledgementSLA,      
  ISNULL(MetResolutionMapID,0) AS MetResolution,      
  ISNULL(OpenDateTime,'') AS OpenDateTime,      
  ISNULL(StartedDateTime,'') AS StartDateTime,      
  ISNULL(WIPDateTime,'') AS WIPDateTime,      
  ISNULL(OnHoldDateTime,'') AS OnHoldDateTime,      
  ISNULL(CompletedDateTime,'') AS CompletedDateTime,      
  ISNULL(ReopenDateTime,'') AS ReopenDateTime,      
  ISNULL(CancelledDateTime,'') AS CancelledDateTime,      
  ISNULL(RejectedDateTime,'') AS RejectedDateTime,      
  ISNULL(AssignedDateTime,'') AS AssignedDateTime,      
  SPM.ServiceName,      
  DS.DARTStatusName,      
  TD.ServiceID,      
  TD.DARTStatusID,      
  TD.ProjectID,      
  TD.ResolutionRemarks AS ResolutionMethodName,      
  TD.SeverityMapID,      
  TD.PriorityMapID,      
  ISNULL(TD.MetResponseSLAMapID,0) AS MetResponseSLAMapID,      
  ISNULL(TD.MetAcknowledgementSLAMapID,0) AS MetAcknowledgementSLAMapID,      
  ISNULL(TD.MetResolutionMapID,0) AS MetResolutionMapID,      
  ISNULL(TD.ResolutionMethodMapID,0) AS ResolutionMethodMapID,      
  ISNULL(TD.TicketSourceMapID,0)  AS TicketSourceMapID,      
  ISNULL(TD.CauseCodeMapID,0) AS CauseCodeMapID,      
  ISNULL(TD.ResolutionCodeMapID,0) AS ResolutionCodeMapID,      
  TD.ApplicationID,      
  ISNULL(TD.DebtClassificationMapID,0) AS DebtClassificationMapID,      
  ISNULL(TD.ResidualDebtMapID,'0')AS ResidualDebtMapID,      
  ISNULL(TD.KEDBAvailableIndicatorMapID,0) AS KEDBAvailableIndicatorMapID,      
  ISNULL(TD.KEDBUpdatedMapID,0) AS KEDBUpdatedMapID,      
  --ISNULL(TD.KEDBUpdatedMapID,0) AS KEDBUpdatedMapID,      
  ISNULL(TD.ReleaseTypeMapID,0) AS ReleaseTypeMapID,      
  TD.TicketTypeMapID,      
  Isnull(TD.NatureoftheTicket,0) as NatureoftheTicket,      
  TD.IsAttributeUpdated,      
  @StatusID AS TicketStatusID,      
  TD.ActualWorkSize,      
  TD.ApprovedBy AS ApprovedBy,      
  --NULL AS ApprovedDateTime ,      
  NULL AS BusinessImpact ,      
  TD.Closedby,      
  TD.Comments,      
  NULL AS CSATScore,      
  ISNULL(TD.ElevateFlagInternal,0) AS ElevateFlagInternal,      
  ISNULL(TD.EscalatedFlagCustomer,0) AS EscalatedFlagCustomer,      
  '' AS JobProcessName,      
  TD.Onsite_Offshore,      
  TD.OutageDuration,      
 TD.PlannedDuration,       
 TD.PlannedEffort ,      
 ISNULL(TD.PlannedEndDate,'') as PlannedEndDate,      
 ISNULL(TD.PlannedStartDate,'') AS PlannedStartDate,       
 TD.ReasonforRejection,       
 TD.RelatedTickets ,      
 ISNULL(TD.ReleaseDate,'') AS ReleaseDate ,      
 TD.RepeatedIncident,       
 TD.Resolvedby ,      
 TD.SecondaryResources ,      
 TD.TicketCreatedBy ,      
  TD.TicketStatusMapID AS TicketStatus,      
 TD.TicketSummary ,      
 NULL AS OutageFlag,      
 --ISNULL(TD.TicketCreatedBy,'') AS TicketCreatedBy,      
 ISNULL(TD.TicketCreatedBy,'') AS TicketCreatedBy,      
 ISNULL(TD.FlexField1,'') AS FlexField1,      
 ISNULL(TD.FlexField2,'') AS FlexField2,      
 ISNULL(TD.FlexField3,'') AS FlexField3,      
 ISNULL(TD.FlexField4,'') AS FlexField4,      
 ISNULL(TD.Category,'') AS Category,      
 ISNULL(TD.Type,'') AS Type,      
 @SupportTypeID AS SupportTypeID,      
 ISNULL(TD.DebtClassificationMode,'') AS DebtClassificationMode,      
 ISNULL(PDB.GracePeriod,365) AS GracePeriod,      
 @IsTaggedToATicket AS IsAHTagged,      
 @OptionalAttribute AS OptionalAttributeType,       
  ISNULL(@FlexField1,0) AS IsFlexField1Configured,      
  ISNULL(@FlexField2,0) AS IsFlexField2Configured,      
  ISNULL(@FlexField3,0) AS IsFlexField3Configured,      
  ISNULL(@FlexField4,0) AS IsFlexField4Configured,      
  ISNULL(@IsResolutionReConfiguredApp,0) AS IsResolutionReConfigured,      
  ISNULL(TD.IsPartiallyAutomated,2) AS IsPartiallyAutomated,      
  ISNULL(@AutoClassificationAppType,0) AS AutoClassificationType ,
   AHT.BusinessImpactId,  
  AHT.ImpactComments,
  LM.EmployeeID AS AssignedUserID  
  FROM AVL.TK_TRN_TicketDetail (NOLOCK) TD      
  LEFT JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AD ON TD.ApplicationID = AD.ApplicationID AND AD.IsActive = 1      
  LEFT JOIN AVL.TK_MAP_PriorityMapping (NOLOCK) MP ON TD.PriorityMapID = MP.PriorityIDMapID AND TD.ProjectID = MP.ProjectId AND MP.IsDeleted = 0      
  LEFT JOIN AVL.TK_MAP_TicketTypeMapping (NOLOCK) TTM ON TD.TicketTypeMapID = TTM.TicketTypeMappingID AND TD.ProjectID = TTM.ProjectId AND TTM.IsDeleted = 0      
  LEFT JOIN AVL.DEBT_MAP_CauseCode (NOLOCK) CC ON TD.CauseCodeMapID = CC.CauseID AND TD.ProjectID = CC.ProjectId AND CC.IsDeleted = 0      
  LEFT JOIN AVL.DEBT_MAP_ResolutionCode (NOLOCK) RC ON TD.ResolutionCodeMapID = RC.ResolutionID AND TD.ProjectID = RC.ProjectId AND RC.IsDeleted = 0      
  LEFT JOIN AVL.DEBT_MAS_DebtClassification (NOLOCK) DC ON TD.DebtClassificationMapID = DC.DebtClassificationID AND DC.IsDeleted = 0      
  LEFT JOIN AVL.DEBT_MAS_ResidualDebt (NOLOCK) RD ON TD.ResidualDebtMapID = RD.ResidualDebtID AND RD.IsDeleted = 0      
  LEFT JOIN AVL.TK_MAP_SeverityMapping (NOLOCK) SM ON TD.SeverityMapID = SM.SeverityIDMapID AND TD.ProjectID = SM.ProjectId AND SM.IsDeleted = 0       
  LEFT JOIN AVL.TK_MAS_TicketSource (NOLOCK) TS ON TD.TicketSourceMapID = TS.TicketSourceID AND TS.IsDeleted = 0      
  LEFT JOIN AVL.TK_MAS_ReleaseType (NOLOCK) RT ON TD.ReleaseTypeMapID = RT.ReleaseTypeID AND RT.IsDeleted = 0      
  LEFT JOIN AVL.TK_MAS_KEDBUpdated (NOLOCK) KU ON TD.KEDBUpdatedMapID = KU.KEDBUpdatedID AND KU.IsDeleted = 0       
  LEFT JOIN AVL.TK_PRJ_ServiceProjectMapping (NOLOCK) SPM ON TD.ServiceID = SPM.ServiceID AND SPM.IsDeleted = 0 AND SPM.ProjectID = @ProjectID      
  LEFT JOIN AVL.TK_MAS_DARTTicketStatus (NOLOCK) DS ON TD.DARTStatusID = DS.DARTStatusID AND DS.IsDeleted = 0      
  LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator (NOLOCK) KAI ON TD.KEDBAvailableIndicatorMapID = KAI.KEDBAvailableIndicatorID AND KAI.IsDeleted = 0      
  LEFT JOIN AVL.DEBT_MAS_ResolutionMethod (NOLOCK) MRM ON TD.ResolutionMethodMapID = MRM.ResolutionMethodID AND MRM.IsDeleted = 0      
  LEFT JOIN AVL.MAS_LoginMaster (NOLOCK) LM ON TD.AssignedTo=LM.UserID AND TD.ProjectID = LM.ProjectID  AND LM.IsDeleted = 0  
  LEFT JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDB ON TD.ProjectID=PDB.ProjectID AND ISNULL(PDB.IsDeleted,0)=0      
  LEFT JOIN [AVL].[DEBT_TRN_HealTicketDetails](NOLOCK) AHT ON TD.TicketID=AHT.HealingTicketID 
  WHERE TD.TicketID = @TicketID       
  --AND TD.TicketStatusMapID = @StatusID       
  --AND TD.ServiceID = @ServiceID       
  AND TD.ProjectID = @ProjectID      
      
 END      
 ELSE      
 BEGIN      
     update AVL.TK_TRN_InfraTicketDetail set TicketTypeMapID=@TicketTypeId,      
           LastUpdatedDate=GETDATE(),      
           ModifiedDate=GETDATE()      
   where TicketID=@TicketID and ProjectID=@ProjectID AND @TicketTypeId != 0      
  SELECT DISTINCT AD.TowerName,      
  AD.InfraTowerTransactionID as TowerID,       
  '' AS ApplicationName,      
  TicketID,      
  ISNULL(OpenDateTime,'') AS TicketOpenDate,      
  TD.TicketDescription,      
  MP.PriorityName AS Priority,      
  TTM.TicketType AS TicketType,      
  isnull(CC.CauseCode,0) as CauseCode,      
  isnull(RC.ResolutionCode,0) as ResolutionCode,      
  DC.DebtClassificationName AS DebtType,      
  ISNULL(AvoidableFlag,'0')AS AvoidableFlag,      
  RD.ResidualDebtName AS ResidualDebt,      
  SM.SeverityName AS Severity,      
  ISNULL(LM.EmployeeName,'') AS AssignedTo,      
  TS.TicketSourceName AS TicketSource,      
  RT.ReleaseTypeName AS ReleaseType,      
  EstimatedWorkSize,      
  EffortTillDate as ActualEffort,      
  ISNULL(OpenDateTime,'') AS TicketCreateDate,    
  ISNULL(ActualStartdateTime,'') AS ActualStartdateTime,      
  ISNULL(ActualEnddateTime,'') AS ActualEnddateTime,      
  ISNULL(TD.Closeddate,'') AS Closeddate,      
  KU.KEDBUpdatedName AS KEDBUpdated,      
  KAI.KEDBAvailableIndicatorName AS KEDBAvailable,      
  TD.KEDBPath,      
  RCAID,      
  Actualduration,      
  ISNULL(MetResponseSLAMapID,0) AS MetResponseSLA,      
  ISNULL(MetAcknowledgementSLAMapID,0) AS MetAcknowledgementSLA,      
  ISNULL(MetResolutionMapID,0) AS MetResolution,      
  ISNULL(OpenDateTime,'') AS OpenDateTime,      
  ISNULL(StartedDateTime,'') AS StartDateTime,      
  ISNULL(WIPDateTime,'') AS WIPDateTime,      
  ISNULL(OnHoldDateTime,'') AS OnHoldDateTime,      
  ISNULL(CompletedDateTime,'') AS CompletedDateTime,      
 ISNULL(ReopenDateTime,'') AS ReopenDateTime,      
  ISNULL(CancelledDateTime,'') AS CancelledDateTime,      
  ISNULL(RejectedDateTime,'') AS RejectedDateTime,      
  ISNULL(AssignedDateTime,'') AS AssignedDateTime,      
  SPM.ServiceName,      
  DS.DARTStatusName,      
  TD.ServiceID,      
  TD.DARTStatusID,      
  TD.ProjectID,      
  TD.ResolutionRemarks AS ResolutionMethodName,      
  TD.SeverityMapID,      
  TD.PriorityMapID,      
  ISNULL(TD.MetResponseSLAMapID,0) AS MetResponseSLAMapID,      
  ISNULL(TD.MetAcknowledgementSLAMapID,0) AS MetAcknowledgementSLAMapID,      
  ISNULL(TD.MetResolutionMapID,0) AS MetResolutionMapID,      
  ISNULL(TD.ResolutionMethodMapID,0) AS ResolutionMethodMapID,      
  ISNULL(TD.TicketSourceMapID,0)  AS TicketSourceMapID,      
  ISNULL(TD.CauseCodeMapID,0) AS CauseCodeMapID,      
  ISNULL(TD.ResolutionCodeMapID,0) AS ResolutionCodeMapID,      
  TD.TowerID AS TowerID,      
  ISNULL(TD.DebtClassificationMapID,0) AS DebtClassificationMapID,      
  ISNULL(TD.ResidualDebtMapID,'0')AS ResidualDebtMapID,      
  ISNULL(TD.KEDBAvailableIndicatorMapID,0) AS KEDBAvailableIndicatorMapID,      
  ISNULL(TD.KEDBUpdatedMapID,0) AS KEDBUpdatedMapID,      
  ISNULL(TD.ReleaseTypeMapID,0) AS ReleaseTypeMapID,      
  TD.TicketTypeMapID,      
  Isnull(TD.NatureoftheTicket,0) as NatureoftheTicket,      
  TD.IsAttributeUpdated,      
  @StatusID AS TicketStatusID,      
  TD.ActualWorkSize,      
  TD.ApprovedBy AS ApprovedBy,      
  NULL AS BusinessImpact ,      
  TD.Closedby,      
  TD.Comments,      
  NULL AS CSATScore,      
  ISNULL(TD.ElevateFlagInternal,0) AS ElevateFlagInternal,      
  ISNULL(TD.EscalatedFlagCustomer,0) AS EscalatedFlagCustomer,      
  '' AS JobProcessName,      
  TD.Onsite_Offshore,      
  TD.OutageDuration,      
 TD.PlannedDuration,       
 TD.PlannedEffort ,      
 ISNULL(TD.PlannedEndDate,'') as PlannedEndDate,      
 ISNULL(TD.PlannedStartDate,'') AS PlannedStartDate,       
 TD.ReasonforRejection,       
 TD.RelatedTickets ,      
 ISNULL(TD.ReleaseDate,'') AS ReleaseDate ,      
 TD.RepeatedIncident,       
 TD.Resolvedby ,      
 TD.SecondaryResources ,      
 TD.TicketCreatedBy ,      
  TD.TicketStatusMapID AS TicketStatus,      
 TD.TicketSummary ,      
 NULL AS OutageFlag,      
 ISNULL(TD.TicketCreatedBy,'') AS TicketCreatedBy,      
 ISNULL(TD.FlexField1,'') AS FlexField1,      
 ISNULL(TD.FlexField2,'') AS FlexField2,      
 ISNULL(TD.FlexField3,'') AS FlexField3,      
 ISNULL(TD.FlexField4,'') AS FlexField4,      
       
 ISNULL(TD.Category,'') AS Category,      
 ISNULL(TD.Type,'') AS Type,      
 0 AS ApplicationID,      
 @SupportTypeID AS SupportTypeID,      
  ISNULL(TD.DebtClassificationMode,'') AS DebtClassificationMode,       
  ISNULL(PDB.GracePeriod,365) AS GracePeriod,      
  0 AS IsAHTagged,      
  @OptionalAttribute AS OptionalAttributeType,      
  ISNULL(@FlexField1,0) AS IsFlexField1Configured,      
  ISNULL(@FlexField2,0) AS IsFlexField2Configured,      
  ISNULL(@FlexField3,0) AS IsFlexField3Configured,      
  ISNULL(@FlexField4,0) AS IsFlexField4Configured,      
  ISNULL(@IsResolutionReConfiguredInfra,0) AS IsResolutionReConfigured,      
  ISNULL(TD.IsPartiallyAutomated,2) AS IsPartiallyAutomated,      
  ISNULL(@AutoClassificationInfraType,0) AS AutoClassificationType  ,
  IAHT.BusinessImpactId,  
  IAHT.ImpactComments,
  LM.EmployeeID AS AssignedUserID  
  FROM AVL.TK_TRN_InfraTicketDetail (NOLOCK) TD      
  LEFT JOIN AVL.InfraTowerDetailsTransaction (NOLOCK) AD ON TD.TowerID = AD.InfraTowerTransactionID AND AD.IsDeleted = 0      
  LEFT JOIN AVL.TK_MAP_PriorityMapping (NOLOCK) MP ON TD.PriorityMapID = MP.PriorityIDMapID AND MP.IsDeleted = 0      
  LEFT JOIN AVL.TK_MAP_TicketTypeMapping (NOLOCK) TTM ON TD.TicketTypeMapID = TTM.TicketTypeMappingID AND TD.ProjectID = TTM.ProjectID AND TTM.IsDeleted = 0      
  LEFT JOIN AVL.DEBT_MAP_CauseCode (NOLOCK) CC ON TD.CauseCodeMapID = CC.CauseID AND TD.ProjectID = CC.ProjectID AND CC.IsDeleted = 0      
  LEFT JOIN AVL.DEBT_MAP_ResolutionCode (NOLOCK) RC ON TD.ResolutionCodeMapID = RC.ResolutionID AND TD.ProjectID = RC.ProjectID AND RC.IsDeleted = 0      
  LEFT JOIN AVL.DEBT_MAS_DebtClassification (NOLOCK) DC ON TD.DebtClassificationMapID = DC.DebtClassificationID AND DC.IsDeleted = 0      
  LEFT JOIN AVL.DEBT_MAS_ResidualDebt (NOLOCK) RD ON TD.ResidualDebtMapID = RD.ResidualDebtID AND RD.IsDeleted = 0      
  LEFT JOIN AVL.TK_MAP_SeverityMapping (NOLOCK) SM ON TD.SeverityMapID = SM.SeverityIDMapID AND TD.ProjectID = SM.ProjectID AND SM.IsDeleted = 0       
  LEFT JOIN AVL.TK_MAS_TicketSource (NOLOCK) TS ON TD.TicketSourceMapID = TS.TicketSourceID AND TS.IsDeleted = 0      
  LEFT JOIN AVL.TK_MAS_ReleaseType (NOLOCK) RT ON TD.ReleaseTypeMapID = RT.ReleaseTypeID AND RT.IsDeleted = 0      
  LEFT JOIN AVL.TK_MAS_KEDBUpdated (NOLOCK) KU ON TD.KEDBUpdatedMapID = KU.KEDBUpdatedID AND KU.IsDeleted = 0       
  LEFT JOIN AVL.TK_PRJ_ServiceProjectMapping (NOLOCK) SPM ON TD.ServiceID = SPM.ServiceID AND SPM.IsDeleted = 0 AND SPM.ProjectID = @ProjectID      
  LEFT JOIN AVL.TK_MAS_DARTTicketStatus (NOLOCK) DS ON TD.DARTStatusID = DS.DARTStatusID AND DS.IsDeleted = 0      
  LEFT JOIN AVL.TK_MAS_KEDBAvailableIndicator (NOLOCK) KAI ON TD.KEDBAvailableIndicatorMapID = KAI.KEDBAvailableIndicatorID AND KAI.IsDeleted = 0      
  LEFT JOIN AVL.DEBT_MAS_ResolutionMethod (NOLOCK) MRM ON TD.ResolutionMethodMapID = MRM.ResolutionMethodID AND MRM.IsDeleted = 0      
  LEFT JOIN AVL.MAS_LoginMaster (NOLOCK) LM ON TD.AssignedTo=LM.UserID AND TD.ProjectID = LM.ProjectID  AND LM.IsDeleted = 0 
  LEFT JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDB ON TD.ProjectID=PDB.ProjectID AND ISNULL(PDB.IsDeleted,0)=0
   LEFT JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails](NOLOCK) IAHT ON TD.TicketID=IAHT.HealingTicketID 
  WHERE TD.TicketID = @TicketID       
  AND TD.ProjectID = @ProjectID      
      
 END      
      SET NOCOUNT OFF;
 COMMIT TRAN      
 END TRY        
BEGIN CATCH        
      
  DECLARE @ErrorMessage VARCHAR(MAX);      
      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
  ROLLBACK TRAN      
  --INSERT Error          
  EXEC AVL_InsertError '[AVL].[TK_GetPopupAttributeDetails] ', @ErrorMessage, @ProjectID, 0      
        
 END CATCH        
      
END
