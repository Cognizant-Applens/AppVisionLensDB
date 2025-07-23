/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
            
CREATE PROCEDURE [AVL].[TK_UpdateIsAttributeUpdatedCustomer]            
@ProjectId BIGINT,            
@ServiceID INT,            
@TicketStatusID BIGINT,            
@TicketID NVARCHAR(1000),            
@TicketTypeID bigint=0  
                 
AS             
BEGIN             
BEGIN TRY            
BEGIN TRAN            
SET NOCOUNT ON;            
            
            
CREATE TABLE #AttributeTemp            
(            
ID BIGINT IDENTITY(1,1),            
ServiceID INT NULL,            
AttributeName NVARCHAR(1000) NULL,            
ProjectStatusID BIGINT NULL,            
ProjectID BIGINT NULL,            
DARTStatusID INT NULL,            
TicketDetailFields NVARCHAR(1000) NULL            
)            
DECLARE @DARTStatusID INT;            
DECLARE @DebtConsidered NVARCHAR(10);            
SET @DARTStatusID=(SELECT TicketStatus_ID FROM AVL.TK_MAP_ProjectStatusMapping WHERE StatusID=@TicketStatusID AND IsDeleted=0)            
SET @DebtConsidered=(SELECT ISNULL(DebtConsidered,'N') AS DebtConsidered from AVL.TK_MAP_TicketTypeMapping(NOLOCK) WHERE TicketTypeMappingID=@TicketTypeID AND ProjectID=@ProjectId)            
IF(@DebtConsidered='')            
BEGIN            
SET @DebtConsidered='N';            
END            
     DECLARE @IsAttributeUpdatedFlg VARCHAR(10) 
	 DECLARE @AlgorithmKey NVARCHAR(25)      
 DECLARE @NotUpdated bit      
SET @AlgorithmKey=(SELECT  TOP 1  AlgorithmKey FROM [ML].[TRN_MLTransaction] WHERE ProjectId=@ProjectId AND SupportTypeId=1 AND ISNULL(IsActiveTransaction,0)=1)           
SET @NotUpdated=(SELECT  TOP 1 IsAttributeUpdated FROM AVL.TK_TRN_TicketDetail WHERE ProjectID = @ProjectId AND TicketID=@TicketID)      
      
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
WHERE ProjectId= @ProjectId  AND ISNULL(MT.IsActiveTransaction,0)=1 AND SupportTypeId=1                        
UNION                        
(SELECT FN.TK_TicketDetailColumn FROM [ML].[TRN_MLTransaction] t LEFT join                         
[MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=t.IssueDefinitionId                        
or FN.FieldMappingId=t.ResolutionProviderId                         
WHERE t.ProjectId= @ProjectId  AND ISNULL(t.IsActiveTransaction,0)=1 AND SupportTypeId=1)        
        
DECLARE @GetQuery NVARCHAR(MAX)                  
DECLARE @result nvarchar(max)                  
SET @GetQuery=STUFF((SELECT ' ' + ' ' + QUOTENAME(TK_TicketDetailColumn)  +' IS  NULL'+' OR'                  
           from #columnMap (NOLOCK)                       
           FOR XML PATH(''), TYPE                        
           ).value('.', 'NVARCHAR(MAX)')                         
           ,1,0,'')               
        
SET @result='Insert into #newAlgo Select Top 1 1 FROM  AVL.TK_TRN_TicketDetail WHERE TicketId='''+ Convert(Varchar(50),@TicketID) +''' and ('+@GetQuery+' '                  
SET @result=(SELECT left(@result, len(@result)-2))         
SET @result = @result +')'        
EXEC sp_executesql @result;          
        
select @DataExists=DataExists from #newAlgo        
        
IF(@DataExists is NULL)        
BEGIN        
 SET @IsAttributeUpdatedFlg = 1      
 SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated      
 Update AVL.TK_TRN_TicketDetail SET IsAttributeUpdated=@IsAttributeUpdatedFlg WHERE ProjectID = @ProjectId AND TicketID=@TicketID           
END        
        
DROP TABLE #columnMap        
DROP TABLE #newAlgo        
        
END       
    
	 
DECLARE @IsDebtEnabled VARCHAR(10);            
declare @IsDebtConsidered nvarchar(max);            
            
SET @IsDebtEnabled=(SELECT ISNULL(IsDebtEnabled,'N') FROM AVL.MAS_ProjectMaster WHERE ProjectID=@ProjectId AND IsDeleted=0)            
set @IsDebtConsidered=(select ISNULL(DebtConsidered,'N') from AVL.TK_MAP_TicketTypeMapping where TicketTypeMappingID=@TicketTypeID)             
 INSERT INTO #AttributeTemp            
 SELECT 0 AS ServiceID,AM.AttributeName,0 AS ProjectStatusID,            
  0 AS ProjectID,tm.StatusID AS DARTStatusID,AM.TicketDetailFields FROM AVL.MAS_TicketTypeStatusAttributeMaster tm            
  inner join  AVL.MAS_AttributeMaster am            
  ON TM.AttributeID=AM.AttributeID            
  WHERE StatusID=@DARTStatusID AND FieldType='M' AND am.IsDeleted=0            
            
--select * from AVL.MAS_AttributeMaster            
    DECLARE @OptionalAttributeType int            
 SELECT TOP 1 @OptionalAttributeType=OptionalAttributeType from AVL.MAS_ProjectDebtDetails where ProjectID=@ProjectId AND IsDeleted<>1            
            
 IF (@OptionalAttributeType=1 OR @OptionalAttributeType=3)          
  BEGIN            
            
SELECT ColumnID INTO #Temp FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping WHERE ProjectID=@ProjectId            
AND IsActive=1            
IF(@DebtConsidered='Y')            
BEGIN            
IF EXISTS (SELECT ColumnID FROM #Temp WHERE ColumnID =11 AND @DARTStatusID=8)            
BEGIN            
 INSERT INTO #AttributeTemp            
 SELECT 0 AS ServiceID,'Flex Field (1)' AS AttributeName,0 AS ProjectStatusID,            
 0 AS ProjectID,8 AS DARTStatusID,'FlexField(1)' AS TicketDetailFields             
END            
IF EXISTS (SELECT ColumnID FROM #Temp WHERE ColumnID =12 AND @DARTStatusID=8)            
BEGIN            
 INSERT INTO #AttributeTemp            
 SELECT 0 AS ServiceID,'Flex Field (2)' AttributeName,0 AS ProjectStatusID,            
  0 AS ProjectID,8 AS DARTStatusID,'FlexField(2)' AS TicketDetailFields            
END            
IF EXISTS (SELECT ColumnID FROM #Temp WHERE ColumnID =13 AND @DARTStatusID=8)            
BEGIN            
 INSERT INTO #AttributeTemp            
 SELECT 0 AS ServiceID,'Flex Field (3)' AS AttributeName,0 AS ProjectStatusID,            
 0 AS ProjectID,8 AS DARTStatusID,'FlexField(3)' AS TicketDetailFields             
END            
IF EXISTS (SELECT ColumnID FROM #Temp WHERE ColumnID =14 AND @DARTStatusID=8)            
BEGIN            
 INSERT INTO #AttributeTemp            
 SELECT 0 AS ServiceID,'Flex Field (4)' AttributeName,0 AS ProjectStatusID,            
  0 AS ProjectID,8 AS DARTStatusID,'FlexField(4)' AS TicketDetailFields            
END            
END            
END            
            
IF EXISTS ( SELECT IsAutoClassified From AVL.MAS_ProjectDebtDetails(NOLOCK) where IsAutoClassified='Y'             
   AND ProjectID=@ProjectId AND IsDeleted=0  AND @DARTStatusID=8 AND @DebtConsidered='Y')            
BEGIN            
  IF  EXISTS ( SELECT TOP 1 IsOptionalField FROM ML.ConfigurationProgress(NOLOCK)             
       where ProjectId=@ProjectId AND IsDeleted=0 AND IsOptionalField = 1)             
    BEGIN            
     INSERT INTO #AttributeTemp            
     SELECT 0 AS ServiceID,'Resolution Method' AS AttributeName,0 AS ProjectStatusID,            
  0 AS ProjectID,8 AS DARTStatusID,'ResolutionRemarks' AS TicketDetailFields            
    END            
    declare @IsTicketDescriptionOpted int;            
 set @IsTicketDescriptionOpted=(select TOP 1 IsTicketDescriptionOpted from ml.ConfigurationProgress(NOLOCK) where projectid=@ProjectId AND IsDeleted = 0            
          ORDER BY ID ASC)            
            
 IF(@IsTicketDescriptionOpted=1)            
 BEGIN            
 INSERT INTO #AttributeTemp            
 SELECT 0 AS ServiceID,'Ticket Description' AS AttributeName,0 AS ProjectStatusID,            
  0 AS ProjectID,8 AS DARTStatusID,'TicketDescription' AS TicketDetailFields             
 END             
END            
            
--SELECT * FROM #AttributeTemp            
 SELECT * INTO             
 #TempTM             
 FROM AVL.TK_TRN_TicketDetail (NOLOCK)             
 WHERE ProjectID = @ProjectId AND TicketID = @TicketID            
 UPDATE  #TempTM SET ReleaseTypeMapID   =NULL WHERE ReleaseTypeMapID             =0  
 UPDATE  #TempTM SET SeverityMapID    =NULL WHERE SeverityMapID     =0  
 UPDATE  #TempTM SET KEDBAvailableIndicatorMapID =NULL WHERE KEDBAvailableIndicatorMapID  =0  
 UPDATE  #TempTM SET MetAcknowledgementSLAMapID =NULL WHERE MetAcknowledgementSLAMapID  =0  
 UPDATE  #TempTM SET MetResolutionMapID   =NULL WHERE MetResolutionMapID    =0  
 UPDATE  #TempTM SET MetResponseSLAMapID   =NULL WHERE MetResponseSLAMapID    =0  
 UPDATE  #TempTM SET NatureoftheTicket   =NULL WHERE NatureoftheTicket    =0  
 UPDATE  #TempTM SET ReleaseTypeMapID   =NULL WHERE ReleaseTypeMapID    =0  
 UPDATE  #TempTM SET DebtClassificationMapID  =NULL WHERE DebtClassificationMapID   =0  
 UPDATE  #TempTM SET ElevateFlagInternal   =NULL WHERE ElevateFlagInternal    =0  
 UPDATE  #TempTM SET EscalatedFlagCustomer   =NULL WHERE EscalatedFlagCustomer    =0  
 UPDATE  #TempTM SET AvoidableFlag    =NULL WHERE AvoidableFlag     =0  
 UPDATE  #TempTM SET CauseCodeMapID    =NULL WHERE CauseCodeMapID     =0  
 UPDATE  #TempTM SET KEDBUpdatedMapID   =NULL WHERE KEDBUpdatedMapID    =0  
 UPDATE  #TempTM SET ActualWorkSize    =NULL WHERE ActualWorkSize    ='0.00'  
 UPDATE  #TempTM SET EstimatedWorkSize   =NULL WHERE EstimatedWorkSize   ='0.00'  
 UPDATE  #TempTM SET OutageDuration    =NULL WHERE OutageDuration    ='0.00'  
 UPDATE  #TempTM SET PlannedEffort    =NULL WHERE PlannedEffort    ='0.00'  
 UPDATE  #TempTM SET ResolutionRemarks   =NULL WHERE ResolutionRemarks   =''  
 UPDATE  #TempTM SET IsPartiallyAutomated     =2 WHERE IsPartiallyAutomated      =''  
            
 DECLARE @AttributeCount BIGINT = 1            
 DECLARE @CountMin INT            
 DECLARE @CountMax INT                       
 DELETE FROM #AttributeTemp WHERE TicketDetailFields='effortTilldate'            
 DELETE FROM #AttributeTemp WHERE TicketDetailFields='StatusID'            
            
 --select * from #AttributeTemp            
 IF @IsDebtEnabled<> 'Y' or  @IsDebtConsidered<>'Y'            
--and @IsDebtConsidered='Y'            
BEGIN            
  --SELECT * FROM #AttributeTemp            
  DELETE FROM #AttributeTemp WHERE TicketDetailFields in('DebtClassificationMapID',            
'AvoidableFlag',            
'ResidualDebtMapID',            
'CauseCodeMapID',            
'ResolutionCodeMapID')            
--DELETE FROM #AttributeTemp WHERE AttributeName IN('Nature Of The Ticket','KEDB Path')            
DELETE FROM #AttributeTemp WHERE AttributeName IN('Flex Field (1)','Flex Field (2)','Flex Field (3)','Flex Field (4)')            
END            
 --select * from #AttributeTemp            
 DELETE FROM #AttributeTemp  WHERE (TicketDetailFields is null OR TicketDetailFields = 'NULL')            
 DELETE FROM #AttributeTemp WHERE TicketDetailFields=''            
 DECLARE @TotalAttributeCount BIGINT = (SELECT COUNT(*) FROM #AttributeTemp)       
 SET @CountMin = (SELECT MIN(ID) FROM #AttributeTemp)            
 SET @CountMax = (SELECT MAX(ID) FROM #AttributeTemp)            
 Update #AttributeTemp set TicketDetailFields = REPLACE(REPLACE(TicketDetailFields,')',''),'(','')            
WHILE(@CountMin < = @CountMax AND @AttributeCount > 0)            
 BEGIN            
  DECLARE @AttributeName VARCHAR(500)         
  SET @AttributeName = (SELECT TicketDetailFields FROM #AttributeTemp WHERE ID=@CountMin)            
  DECLARE @Selectquery NVARCHAR(1000)='';            
  DECLARE @rowcntAvailable INT=0;            
  SET @Selectquery='SELECT @cnt=COUNT(1) FROM #TempTM WHERE '+@AttributeName+ ' IS NOT NULL'            
  IF(@AttributeName = 'TicketDescription')            
   BEGIN             
    SET @Selectquery='SELECT @cnt=COUNT(1) FROM #TempTM WHERE '+@AttributeName+ '<>'''''            
   END            
  exec sp_executesql @Selectquery, N'@cnt int out', @rowcntAvailable out             
            
  --newly added end            
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
  FROM AVL.TK_TRN_TicketDetail(NOLOCK) TM                        
  INNER JOIN avl.DEBT_TRN_HealTicketDetails TT ON TM.TicketID=TT.HealingTicketID AND TT.IsDeleted=0                        
  INNER JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic PM ON PM.ProjectPatternMapID=TT.ProjectPatternMapID AND TM.ProjectID=PM.ProjectID                         
  INNER JOIN avl.TK_MAP_TicketTypeMapping (NOLOCK) TTM on TM.ProjectID = TTM.ProjectID AND TM.TicketTypeMapID = TTM.TicketTypeMappingID AND TTM.IsDeleted = 0                        
  WHERE tm.ProjectID = @ProjectId  and tm.TicketID = @TicketID                  
                
   --If Not AH Ticket                
                
 IF(@AttributeCount = @TotalAttributeCount AND (ISNULL(@IsAHTicket,0)=0))                  
  BEGIN                     
   SET @IsAttributeUpdatedFlg = 1                  
   SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                  
   UPDATE AVL.TK_TRN_TicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg,TicketTypeMapID=@TicketTypeID,-- ServiceID = @serviceid,                  
   TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                   
   WHERE ProjectID = @ProjectId AND TicketID = @TicketID                  
  END                  
 ELSE  IF(ISNULL(@IsAHTicket,0)=0)                  
  BEGIN                   
   SET @IsAttributeUpdatedFlg = 0                  
   SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                  
   UPDATE AVL.TK_TRN_TicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg,TicketTypeMapID=@TicketTypeID,-- ServiceID = @serviceid,                  
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
   UPDATE AVL.TK_TRN_TicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg,TicketTypeMapID=@TicketTypeID,-- ServiceID = @serviceid,                  
   TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                   
   WHERE ProjectID = @ProjectId AND TicketID = @TicketID                  
  END                  
 ELSE  IF(ISNULL(@IsAHTicket,0)=1 AND (@DARTStatusID=8 OR @DARTStatusID=9))               
  BEGIN                   
   SET @IsAttributeUpdatedFlg = 0                  
   SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                
   UPDATE AVL.TK_TRN_TicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg,TicketTypeMapID=@TicketTypeID,-- ServiceID = @serviceid,                  
   TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                   
    WHERE ProjectID = @ProjectId AND TicketID = @TicketID                  
  END         
          
        
  --Not in completed/Closed Status AH Tickets        
  IF(@AttributeCount = @TotalAttributeCount AND (@DARTStatusID<>8 AND @DARTStatusID<>9) AND  ((ISNULL(@IsAHTicket,0)=1)))         
  BEGIN                     
   SET @IsAttributeUpdatedFlg = 1                  
   SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                 
   UPDATE AVL.TK_TRN_TicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg,TicketTypeMapID=@TicketTypeID,-- ServiceID = @serviceid,                  
   TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                   
   WHERE ProjectID = @ProjectId AND TicketID = @TicketID                  
  END                  
 ELSE  IF(ISNULL(@IsAHTicket,0)=1 AND (@DARTStatusID<>8 AND @DARTStatusID<>9))               
  BEGIN                   
   SET @IsAttributeUpdatedFlg = 0                  
   SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated                
   UPDATE AVL.TK_TRN_TicketDetail SET IsAttributeUpdated = @IsAttributeUpdatedFlg,TicketTypeMapID=@TicketTypeID,-- ServiceID = @serviceid,                  
   TicketStatusMapID=@TicketStatusID,DARTStatusID=@DARTStatusID,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE()                   
    WHERE ProjectID = @ProjectId AND TicketID = @TicketID                  
  END         
--SELECT @IsAttributeUpdatedFlg AS IsAttributeUpdated            
            
              
--To update the ticket details of heal and automation            
 --insert into heal log table            
 SELECT TM.ProjectID,TM.TicketID,TM.DARTStatusID            
 INTO #StatusChangedTemp            
 FROM avl.TK_TRN_TicketDetail(NOLOCK) TM            
 --INNER JOIN @tempAttri as tA on tm.TicketID = tA.TicketID AND tm.ProjectID = tA.projectId            
 INNER JOIN avl.DEBT_TRN_HealTicketDetails(NOLOCK) TT ON TM.TicketID=TT.HealingTicketID  AND ISNULL(TT.ManualNonDebt,0) != 1            
 INNER JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic PM ON PM.ProjectPatternMapID=TT.ProjectPatternMapID             
 AND TM.ProjectID=PM.ProjectID AND TT.IsDeleted=0 AND ISNULL(PM.ManualNonDebt,0) != 1            
 INNER JOIN avl.TK_MAP_TicketTypeMapping (NOLOCK) TTM on TM.ProjectID = TTM.ProjectID AND TM.TicketTypeMapID = TTM.TicketTypeMappingID             
 WHERE TTM.AVMTicketType IN (9,10) and tm.TicketID = @TicketID and tm.ProjectID = @ProjectId            
             
 DECLARE @TcktMasStatus VARCHAR(50)            
 SELECT  @TcktMasStatus =@DARTStatusID            
 --( DS.DARTSatusID from PRJ.StatusMaster SM JOIN @tempAttri TA ON TA.AvmStatus = SM.StatusID                  
  --     AND TA.projectId = SM.ProjectID        
 --    JOIN MAS.DARTStatus DS ON DS.DARTSatusID = SM.DARTStatusId        
 --    WHERE SM.IsDeleted = 'N'        
 --    and DS.IsDeleted = 'N')         
                 
 DECLARE @HealTblStatus VARCHAR(50)             
 SET @HealTblStatus = (SELECT HTD.DARTStatusID FROM avl.DEBT_TRN_HealTicketDetails HTD WHERE HTD.HealingTicketID = @TicketID            
 AND HTD.IsDeleted = 0  AND ISNULL(HTD.ManualNonDebt,0) !=1)               
             
 IF(@TcktMasStatus = @HealTblStatus)            
 BEGIN            
  PRINT '1'            
 END            
 ELSE             
  BEGIN            
  --INSERT INTO dbo.TempStatus            
  --SELECT @TcktMasStatus,@HealTblStatus,NULL            
   INSERT INTO avl.DEBT_TRN_HealTicketsLog            
   SELECT ProjectID,TicketID,1,NULL,NULL,DARTStatusID,NULL,NULL,NULL,NULL,'TRN.Heal_TicketDetails',NULL,NULL,NULL,NULL,'system',GETDATE()            
   FROM #StatusChangedTemp            
  END            
             
             
 UPDATE TT             
 SET TT.DARTStatusID=@DARTStatusID,TT.ModifiedDate=getdate(), TT.ClosedDate = TM.Closeddate            
 FROM AVL.TK_TRN_TicketDetail(NOLOCK) TM            
 --INNER JOIN @tempAttri as tA on tm.TicketID = tA.TicketID AND tm.ProjectID = tA.projectId            
 INNER JOIN avl.DEBT_TRN_HealTicketDetails(NOLOCK) TT ON TM.TicketID=TT.HealingTicketID AND ISNULL(TT.ManualNonDebt,0) != 1            
 INNER JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic PM ON PM.ProjectPatternMapID=TT.ProjectPatternMapID             
 AND TM.ProjectID=PM.ProjectID AND TT.IsDeleted=0  AND ISNULL(PM.ManualNonDebt,0) != 1            
 INNER JOIN avl.TK_MAP_TicketTypeMapping (NOLOCK) TTM on TM.ProjectID = TTM.ProjectID AND TM.TicketTypeMapID = TTM.TicketTypeMappingID             
 WHERE TTM.AVMTicketType IN (9,10) and tm.TicketID = @TicketID and tm.ProjectID = @ProjectId            
            
 IF @DARTStatusID = 8            
  BEGIN            
   UPDATE PM             
   SET PM.PatternStatus = 0, PM.ModifiedDate=GETDATE()            
   FROM AVL.TK_TRN_TicketDetail(NOLOCK) TM            
   INNER JOIN avl.DEBT_TRN_HealTicketDetails(NOLOCK) TT ON TM.TicketID=TT.HealingTicketID  AND ISNULL(TT.ManualNonDebt,0) != 1            
   INNER JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic(NOLOCK) PM ON TM.ProjectID=PM.ProjectID AND PM.ProjectPatternMapID=TT.ProjectPatternMapID             
   AND TT.IsDeleted=0  AND ISNULL(PM.ManualNonDebt,0) != 1            
   WHERE TM.ProjectID = @ProjectId AND  TM.TicketID = @TicketID             
  END            
  EXEC AVL.DebtClassificationModeUpdate @ProjectId, @TicketID            
            
drop table #AttributeTemp            
drop table #TempTM        
            
SET NOCOUNT OFF;            
COMMIT TRAN            
END TRY              
BEGIN CATCH              
            
  DECLARE @ErrorMessage VARCHAR(MAX);            
  ROLLBACK TRAN            
  SELECT @ErrorMessage = ERROR_MESSAGE()            
            
  --INSERT Error                
  EXEC AVL_InsertError '[AVL].[TK_UpdateIsAttributeUpdatedCustomer]', @ErrorMessage, @ProjectId,0            
              
 END CATCH             
END
