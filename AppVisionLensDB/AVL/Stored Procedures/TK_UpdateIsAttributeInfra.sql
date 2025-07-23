/***************************************************************************        
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET        
*Copyright [2018] – [2021] Cognizant. All rights reserved.        
*NOTICE: This unpublished material is proprietary to Cognizant and        
*its suppliers, if any. The methods, techniques and technical        
  concepts herein are considered Cognizant confidential and/or trade secret information.         
          
*This material may be covered by U.S. and/or foreign patents or patent applications.         
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.        
***************************************************************************/        
        
CREATE PROCEDURE [AVL].[TK_UpdateIsAttributeInfra]                  
@ProjectId BIGINT,                  
@TicketID NVARCHAR(1000),                  
@TicketStatusID BIGINT      
AS                   
BEGIN                   
 BEGIN TRY                  
 SET NOCOUNT ON;                  
  DECLARE @IsDebtEnabled CHAR(1)                  
  DECLARE @DARTStatusID INT                  
  SET @IsDebtEnabled=(SELECT ISNULL(IsDebtEnabled,'N') FROM AVL.MAS_ProjectMaster(NOLOCK)                   
       WHERE ProjectID=@ProjectId)                  
  SET @DARTStatusID=(SELECT TicketStatus_ID FROM AVL.TK_MAP_ProjectStatusMapping(NOLOCK)                  
        WHERE ProjectID=@ProjectId AND                  
        StatusID=@TicketStatusID)                  
  CREATE TABLE #AttributeTemp                  
  (                  
  ID BIGINT IDENTITY(1,1),                  
  AttributeName NVARCHAR(1000) NULL,                  
  TicketDetailFields NVARCHAR(1000) NULL                  
  )                  
  IF @IsDebtEnabled='Y'                  
   BEGIN                  
    INSERT INTO #AttributeTemp                  
     SELECT                  
                A.AttributeName,                  
                B.TicketDetailFields AS TicketDetailFields                  
                FROM [AVL].[MAS_InfraAttributeStatusMaster] A (NOLOCK)                   
                LEFT JOIN AVL.MAS_AttributeMaster B ON A.AttributeID=B.AttributeID                    
                WHERE A.StatusID=@DARTStatusID                  
                AND A.IsDeleted= 0  AND A.DebtFieldType='M' AND B.IsDeleted =0                  
   END                  
  ELSE                  
   BEGIN                  
    INSERT INTO #AttributeTemp                  
     SELECT                  
    A.AttributeName,                  
                B.TicketDetailFields AS TicketDetailFields                  
    FROM [AVL].[MAS_InfraAttributeStatusMaster] A (NOLOCK)                   
    LEFT JOIN AVL.MAS_AttributeMaster B ON A.AttributeID=B.AttributeID                    
    WHERE A.StatusID=@DARTStatusID                  
    AND A.IsDeleted= 0  AND A.StandardFieldType='M' AND B.IsDeleted=0                  
   END                  
                  
IF EXISTS (SELECT IsAutoClassifiedInfra From AVL.MAS_ProjectDebtDetails(NOLOCK) where IsAutoClassifiedInfra='Y'                   
   and ProjectID=@ProjectId AND IsDeleted=0 AND @DARTStatusID=8)                  
BEGIN                  
 IF  EXISTS ( SELECT A.OptionalFields FROM AVL.ML_MAS_OptionalFields(NOLOCK) A                   
      INNER JOIN AVL.ML_MAP_OptionalProjMappingInfra(NOLOCK) B on A.ID=B.OptionalFieldID where B.ProjectId=@ProjectId                   
      AND A.OptionalFields = 'Resolution Remarks' AND B.IsDeleted=0 AND A.IsDeleted=0 )                   
  BEGIN                  
   INSERT INTO #AttributeTemp                  
   SELECT 'Resolution Method' AS AttributeName,'ResolutionRemarks' AS TicketDetailFields                   
  END                  
   INSERT INTO #AttributeTemp                  
   SELECT 'Ticket Description' AS AttributeName,'TicketDescription' AS TicketDetailFields                   
END                  
                  
  SELECT TimeTickerID,TicketID,ProjectID,AssignedTo,AssignmentGroup,EffortTillDate,ServiceID                  
   ,TicketDescription,IsDeleted,CauseCodeMapID,DebtClassificationMapID,ResidualDebtMapID,ResolutionCodeMapID                  
   ,ResolutionMethodMapID,KEDBAvailableIndicatorMapID,KEDBUpdatedMapID,KEDBPath,PriorityMapID,ReleaseTypeMapID                  
   ,SeverityMapID,TicketSourceMapID,TicketStatusMapID,TicketTypeMapID,BusinessSourceName,Onsite_Offshore,PlannedEffort                  
   ,EstimatedWorkSize,ActualEffort,ActualWorkSize,Resolvedby,Closedby,ElevateFlagInternal,RCAID,PlannedDuration                  
   ,Actualduration,TicketSummary,NatureoftheTicket,Comments,RepeatedIncident,RelatedTickets,TicketCreatedBy                  
   ,SecondaryResources,EscalatedFlagCustomer,ReasonforRejection,AvoidableFlag,ReleaseDate,TicketCreateDate                  
   ,PlannedStartDate,PlannedEndDate,ActualStartdateTime,ActualEnddateTime,OpenDateTime,StartedDateTime                  
   ,WIPDateTime,OnHoldDateTime,CompletedDateTime,ReopenDateTime,CancelledDateTime,RejectedDateTime,Closeddate                  
   ,AssignedDateTime,OutageDuration,MetResponseSLAMapID,MetAcknowledgementSLAMapID,MetResolutionMapID                  
   ,EscalationSLA,TKBusinessID,InscopeOutscope,IsAttributeUpdated,NewStatusDateTime,IsSDTicket,IsManual,DARTStatusID                  
   ,ResolutionRemarks,ITSMEffort,CreatedBy,CreatedDate,LastUpdatedDate,ModifiedBy,ModifiedDate,IsApproved                  
   ,ReasonResidualMapID,ExpectedCompletionDate,ApprovedBy,DAPId,DebtClassificationMode,FlexField1,FlexField2                  
   ,FlexField3,FlexField4,Category,[Type],TowerID,IsPartiallyAutomated INTO #TempTM                   
   FROM AVL.TK_TRN_InfraTicketDetail (NOLOCK)                   
   WHERE ProjectID = @ProjectId AND TicketID = @TicketID                  
                  
   UPDATE  #TempTM SET ResolutionRemarks =NULL WHERE ResolutionRemarks =''                  
   UPDATE  #TempTM SET IsPartiallyAutomated=2    WHERE IsPartiallyAutomated=''                  
                  
   DECLARE @CountMin INT                  
   DECLARE @CountMax INT                  
   DECLARE @IsAttributeUpdatedFlg VARCHAR(10)                  
   DECLARE @TotalAttributeCount BIGINT = (SELECT COUNT(1) FROM #AttributeTemp)                   
   SET @CountMin = (SELECT MIN(ID) FROM #AttributeTemp)                  
   SET @CountMax = (SELECT MAX(ID) FROM #AttributeTemp)                  
   DECLARE @AttributeCount BIGINT = 1                  
   DECLARE @AttributeName VARCHAR(500)                   
   DECLARE @Selectquery NVARCHAR(1000)='';                  
   DECLARE @rowcntAvailable INT=0;                  
                  

				   DECLARE @AlgorithmKey NVARCHAR(25)          
 DECLARE @NotUpdated bit          
SET @AlgorithmKey=(SELECT  TOP 1  AlgorithmKey FROM [ML].[TRN_MLTransaction] WHERE ProjectId=@ProjectId AND SupportTypeId=2 AND ISNULL(IsActiveTransaction,0)=1)               
SET @NotUpdated=(SELECT  TOP 1 IsAttributeUpdated FROM AVL.TK_TRN_InfraTicketDetail WHERE ProjectID = @ProjectId AND TicketID=@TicketID)          
          
IF(@AlgorithmKey ='AL002' AND @NotUpdated=0)             
BEGIN            
            
Declare @DataExists bit            
            
CREATE TABLE #newAlgo(            
 DataExists bit            
)            
--Get Column Mapping                      
SELECT FN.TK_TicketDetailColumn     into #columnMap                       
FROM [ML].[TRN_MLTransaction] MT                            
JOIN [ML].[TRN_TransactionCategorical] MD ON MD.MLTransactionId=MT.TransactionId                             
JOIN [MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=MD.CategoricalFieldId                             
WHERE ProjectId= @ProjectId  AND ISNULL(MT.IsActiveTransaction,0)=1 AND SupportTypeId=2      
UNION                            
(SELECT FN.TK_TicketDetailColumn FROM [ML].[TRN_MLTransaction] t LEFT join                             
[MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=t.IssueDefinitionId                            
or FN.FieldMappingId=t.ResolutionProviderId                             
WHERE t.ProjectId= @ProjectId  AND ISNULL(t.IsActiveTransaction,0)=1 AND SupportTypeId=2)            
            
DECLARE @GetQuery NVARCHAR(MAX)                      
DECLARE @result nvarchar(max)                      
SET @GetQuery=STUFF((SELECT ' ' + ' ' + QUOTENAME(TK_TicketDetailColumn)  +' IS  NULL'+' OR'                      
           from #columnMap (NOLOCK)                           
           FOR XML PATH(''), TYPE                            
           ).value('.', 'NVARCHAR(MAX)')                             
           ,1,0,'')                   
            
SET @result='Insert into #newAlgo Select Top 1 1 FROM  AVL.TK_TRN_InfraTicketDetail WHERE TicketId='''+ Convert(Varchar(50),@TicketID) +''' and ('+@GetQuery+' '                      
SET @result=(SELECT left(@result, len(@result)-2))             
SET @result = @result +')'            
EXEC sp_executesql @result;              
            
select @DataExists=DataExists from #newAlgo            
            
IF(@DataExists is NULL)            
BEGIN            
 SET @IsAttributeUpdatedFlg = 1          
 SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated          
 Update AVL.TK_TRN_InfraTicketDetail SET IsAttributeUpdated=@IsAttributeUpdatedFlg WHERE ProjectID = @ProjectId AND TicketID=@TicketID           
END            
            
DROP TABLE #columnMap            
DROP TABLE #newAlgo            
            
END          
 
  WHILE(@CountMin < = @CountMax AND @AttributeCount > 0)                  
  BEGIN                  
   SET @rowcntAvailable=0;                  
   SET @AttributeName = (SELECT TicketDetailFields FROM #AttributeTemp WHERE ID=@CountMin)                  
   SET @Selectquery='SELECT @cnt=COUNT(1) FROM #TempTM WHERE '+@AttributeName+ ' IS NOT NULL'                  
   IF(@AttributeName = 'TicketDescription')                  
   BEGIN                   
    SET @Selectquery='SELECT @cnt=COUNT(1) FROM #TempTM WHERE '+@AttributeName+ '<>'''''                  
   END                  
   exec sp_executesql @Selectquery, N'@cnt int out', @rowcntAvailable out                   
   IF @rowcntAvailable>0                  
    BEGIN                  
     SET @AttributeCount = @AttributeCount + 1;                  
    END                  
   SET @CountMin = @CountMin+1                    
  END                  
 SET @AttributeCount = @AttributeCount -1                  
                  
  --Check If AHTicket                        
 DECLARE @IsAHTicket INT, @BusinessImpact INT,@ImpactComments VARCHAR(100)                        
                        
 SELECT @IsAHTicket =(SELECT CASE WHEN TT.HealingTicketID IS NOT NULL THEN 1 ELSE 0 END  AS 'IsAHTicket'),                        
  @BusinessImpact=TT.BusinessImpactId,                       
  @ImpactComments=TT.ImpactComments                        
  FROM AVL.TK_TRN_InfraTicketDetail (NOLOCK) TM                              
  INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails] TT ON TM.TicketID=TT.HealingTicketID AND TT.IsDeleted=0                      
   INNER JOIN AVL.DEBT_TRN_InfraHealTicketEfffortDormantDetails TTDO ON TTDO.HealingID=TT.Id                     
  INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] PM ON PM.ProjectPatternMapID=TT.ProjectPatternMapID AND TM.ProjectID=PM.ProjectID                               
  INNER JOIN avl.TK_MAP_TicketTypeMapping (NOLOCK) TTM on TM.ProjectID = TTM.ProjectID AND TM.TicketTypeMapID = TTM.TicketTypeMappingID AND TTM.IsDeleted = 0                              
  WHERE tm.ProjectID = @ProjectId  and tm.TicketID = @TicketID                        
                      
  --If Not AH Ticket                        
  IF(@AttributeCount = @TotalAttributeCount  AND (ISNULL(@IsAHTicket,0)=0))                          
   BEGIN                             
    SET @IsAttributeUpdatedFlg = 1                          
    SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                          
    UPDATE AVL.TK_TRN_InfraTicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg,                          
    TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                          
    WHERE ProjectID = @ProjectId AND TicketID = @TicketID                           
   END                          
  ELSE  IF(ISNULL(@IsAHTicket,0)=0)                          
   BEGIN                           
    SET @IsAttributeUpdatedFlg = 0                          
    SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                          
    UPDATE AVL.TK_TRN_InfraTicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg,                          
    TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                           
     WHERE ProjectID = @ProjectId AND TicketID = @TicketID                           
   END                        
                         
    --IF AH Ticket                        
  IF(@AttributeCount = @TotalAttributeCount AND (@DARTStatusID=8 OR @DARTStatusID=9) AND  ((ISNULL(@IsAHTicket,0)=1)                        
   AND(@BusinessImpact<>0 OR ISNULL(@BusinessImpact,'')<>'')                        
  AND (ISNULL(@ImpactComments,'')<>'')))                          
   BEGIN                             
    SET @IsAttributeUpdatedFlg = 1                          
    SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                          
    UPDATE AVL.TK_TRN_InfraTicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg,                          
    TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                          
 WHERE ProjectID = @ProjectId AND TicketID = @TicketID                           
   END                          
  ELSE IF(ISNULL(@IsAHTicket,0)=1 AND (@DARTStatusID=8 OR @DARTStatusID=9))                              
   BEGIN                           
    SET @IsAttributeUpdatedFlg = 0                          
    SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                          
    UPDATE AVL.TK_TRN_InfraTicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg,                          
    TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                           
     WHERE ProjectID = @ProjectId AND TicketID = @TicketID                           
   END                      
                  
  --Not in completed/Closed Status AH Tickets              
  IF(@AttributeCount = @TotalAttributeCount AND (@DARTStatusID<>8 AND @DARTStatusID<>9) AND  ((ISNULL(@IsAHTicket,0)=1)))               
  BEGIN               
  SET @IsAttributeUpdatedFlg = 1                 
    SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                          
    UPDATE AVL.TK_TRN_InfraTicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg,                          
    TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                          
 WHERE ProjectID = @ProjectId AND TicketID = @TicketID                
 END              
              
 ELSE  IF(ISNULL(@IsAHTicket,0)=1 AND (@DARTStatusID<>8 AND @DARTStatusID<>9))               
 BEGIN              
 SET @IsAttributeUpdatedFlg = 0                          
    SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                          
    UPDATE AVL.TK_TRN_InfraTicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg,                          
    TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                           
     WHERE ProjectID = @ProjectId AND TicketID = @TicketID              
 END              
              
              
   --To update the ticket details of heal and automation                  
  SELECT TM.ProjectID,TM.TicketID,TM.DARTStatusID                  
  INTO #StatusChangedTemp                  
  FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) TM                  
  INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails](NOLOCK) TT ON TM.TicketID=TT.HealingTicketID                  
  INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic](NOLOCK) PM ON PM.ProjectPatternMapID=TT.ProjectPatternMapID AND TM.ProjectID=PM.ProjectID AND TT.IsDeleted=0                  
  INNER JOIN avl.TK_MAP_TicketTypeMapping (NOLOCK) TTM on TM.ProjectID = TTM.ProjectID AND TM.TicketTypeMapID = TTM.TicketTypeMappingID                   
  WHERE TM.ProjectID = @ProjectId AND tm.TicketID = @TicketID AND TTM.AVMTicketType IN (9,10)                    
  --AND ISNULL(TT.ManualNonDebt,0)<>1 AND ISNULL(PM.ManualNonDebt,0)<>1                  
                  
                     
  DECLARE @HealTblStatus VARCHAR(50)                   
  SET @HealTblStatus = (SELECT HTD.DARTStatusID FROM [AVL].[DEBT_TRN_InfraHealTicketDetails](NOLOCK) HTD                   
        WHERE HTD.HealingTicketID = @TicketID --AND ISNULL(HTD.ManualNonDebt,0)<>1                   
        AND HTD.IsDeleted = 0)                     
                   
  IF(@DARTStatusID <> @HealTblStatus)                  
   BEGIN                  
    INSERT INTO [AVL].[DEBT_TRN_InfraHealTicketsLog]                  
    (ProjectID,HealingTicketID,ActivityID,[Priority],Assignee,[Status],ProblemTicketID,NewHealingTicketID,ParentTicket,                  
                 TableName,PlannedEffort,HealTypeId,PlannedStartDate,PlannedEndDate,CreatedBy,CreatedDate)                  
    SELECT ProjectID,TicketID,1,NULL,NULL,DARTStatusID,NULL,NULL,NULL,'[AVL].[DEBT_TRN_InfraHealTicketDetails]',NULL,NULL,NULL,NULL,'system',GETDATE()                  
    FROM #StatusChangedTemp                  
   END                  
  ---Update status of HEalTicket                  
  UPDATE TT                   
  SET TT.DARTStatusID=@DARTStatusID,TT.ModifiedDate=getdate(), TT.ClosedDate = TM.Closeddate                  
  FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) TM                  
  INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails](NOLOCK) TT ON TM.TicketID=TT.HealingTicketID                  
  INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] PM ON PM.ProjectPatternMapID=TT.ProjectPatternMapID AND TM.ProjectID=PM.ProjectID AND TT.IsDeleted=0                  
  INNER JOIN avl.TK_MAP_TicketTypeMapping (NOLOCK) TTM on TM.ProjectID = TTM.ProjectID AND TM.TicketTypeMapID = TTM.TicketTypeMappingID                   
  WHERE tm.ProjectID = @ProjectId  and tm.TicketID = @TicketID  AND TTM.AVMTicketType IN (9,10)                   
  --AND ISNULL(TT.ManualNonDebt,0)<>1 AND ISNULL(PM.ManualNonDebt,0)<>1                  
                  
  IF @DARTStatusID = 8                  
  BEGIN                  
   UPDATE PM                   
   SET PM.PatternStatus = 0, PM.ModifiedDate=GETDATE()                  
   FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) TM                  
   INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails](NOLOCK) TT ON TM.TicketID=TT.HealingTicketID                  
   INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic](NOLOCK) PM ON TM.ProjectID=PM.ProjectID AND PM.ProjectPatternMapID=TT.ProjectPatternMapID                   
   AND TT.IsDeleted=0                  
   WHERE TM.ProjectID = @ProjectId AND  TM.TicketID = @TicketID                   
   --AND ISNULL(TT.ManualNonDebt,0)<>1 AND ISNULL(PM.ManualNonDebt,0)<>1                  
  END                
            
                  
 SET NOCOUNT OFF;                  
 END TRY                    
BEGIN CATCH                    
  DECLARE @ErrorMessage VARCHAR(MAX);                  
  SELECT @ErrorMessage = ERROR_MESSAGE()                  
  EXEC AVL_InsertError '[AVL].[TK_UpdateIsAttributeInfra]', @ErrorMessage, @ProjectId,0                  
                    
 END CATCH                   
END
