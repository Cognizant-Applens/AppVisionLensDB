/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================------    
-- Author: Dhivya Bharathi M              
-- Create date:    December 17 2018     
-- Description:        
-- EXEC  [AVL].[Effort_UpdateTicketIsAttributeFlagByProject] 10337    
--EXEC  [AVL].[Effort_UpdateTicketIsAttributeFlagByProject] 44639    
-- ============================================================================    
    
CREATE PROCEDURE [AVL].[Effort_UpdateTicketIsAttributeFlagByProject]    
@ProjectId BIGINT=NULL,    
@Mode NVARCHAR(100)= NULL    
AS    
BEGIN    
SET NOCOUNT ON;  
BEGIN TRY    
    
CREATE TABLE #TRN_TicketDetails    
(    
ID BIGINT IDENTITY(1,1),    
TimeTickerID BIGINT NULL,    
ProjectID BIGINT NOT NULL,    
TicketID NVARCHAR(100) NULL,    
ServiceID INT NULL,    
DartStatusId INT NULL,    
TicketTypeMapID BIGINT NULL,    
IsAttributeUpdated INT NULL    
)    
CREATE TABLE #TicketUpdated    
(    
TimeTickerID BIGINT NULL,    
ProjectID BIGINT NULL,    
TicketID NVARCHAR(100) NULL,    
IsAttributeUpdated INT NULL    
)    
DECLARE @FlexField1Name NVARCHAR(100)='Flex Field (1)'    
DECLARE @FlexField2Name NVARCHAR(100)='Flex Field (2)'    
DECLARE @FlexField3Name NVARCHAR(100)='Flex Field (3)'    
DECLARE @FlexField4Name NVARCHAR(100)='Flex Field (4)'    
--Step 1 Get the Tickets from IsAttributeUpdatedTable by project    
SELECT * INTO #TRN_IsAttributeUpdated    
FROM AVL.TK_TRN_IsAttributeUpdated (NOLOCK) WHERE ISNULL(IsProcessed,0)=0 AND ProjectId=@ProjectId    
AND Mode=@Mode    
    
--Step 2: Get the necessary information to calculate the flag value    
INSERT INTO #TRN_TicketDetails    
SELECT TAU.TimeTickerID as TimeTickerID,TAU.ProjectID as ProjectID,TAU.TicketID as TicketID,    
TD.ServiceID as ServiceID,TD.DartStatusId as DartStatusId,TD.TicketTypeMapID as TicketTypeMapID,NULL AS IsAttributeUpdated     
FROM #TRN_IsAttributeUpdated TAU (NOLOCK)    
INNER JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD    
ON TAU.TimeTickerID=TD.TimeTickerID WHERE TD.ProjectID=@ProjectId --AND TD.ServiceID >0    
    
--Step 3 : Move all the column data to temp table    
SELECT TD.* INTO #TempTM FROM     
#TRN_TicketDetails TM (NOLOCK)   
INNER JOIN AVL.TK_TRN_TicketDetail (NOLOCK) TD  ON TM.TimeTickerID=TD.TimeTickerID    
WHERE TD.ProjectID=@ProjectId    
    
--Step 4 : Updating the column values with null data    
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
UPDATE  #TempTM SET ResolutionRemarks =NULL WHERE ResolutionRemarks =''  
--Step 5: Check whether the project is cognizant or customer    
DECLARE @IsCognizant NVARCHAR(10)    
SET @IsCognizant=(SELECT ISNULL(C.IsCognizant,0) AS IsCognizant FROM AVL.MAS_ProjectMaster(NOLOCK) PM    
     INNER JOIN AVL.Customer(NOLOCK) C    
     ON PM.CustomerID=C.CustomerID WHERE PM.ProjectID=@ProjectId and ISNULL(PM.IsDeleted,0)=0)    
IF @IsCognizant='1'    
 BEGIN    
  DECLARE @MainspringIntegration NVARCHAR(10);    
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
  SET @MainspringIntegration =(SELECT ISNULL(IsMainSpringConfigured,'N')  from AVL.MAS_ProjectMaster (NOLOCK)    
          WHERE ProjectID = @ProjectId AND IsDeleted=0)    
  IF(@MainspringIntegration = 'Y')    
  BEGIN    
   IF NOT EXISTS(SELECT TOP 1 StatusName from AVL.PRJ_MainspringAttributeProjectStatusMaster (NOLOCK)     
        WHERE Projectid = @ProjectId and IsDeleted = 0)     
    BEGIN     
     INSERT INTO #AttributeTemp    
     SELECT D.ServiceID, D.AttributeName, 0 AS ProjectStatusID,0 as ProjectID,      
     DS.DARTStatusID AS DARTStatusID,AM.TicketDetailFields    
     FROM AVL.MAS_MainspringAttributeStatusMaster D (NOLOCK)     
     INNER JOIN AVL.TK_MAS_DARTTicketStatus DS (NOLOCK) on D.StatusID=DS.DARTStatusID       
     LEFT JOIN AVL.MAS_AttributeMaster AM (NOLOCK) ON D.AttributeID=AM.AttributeID    
     WHERE D.IsDeleted= 0  AND DS.IsDeleted = 0  AND AM.IsDeleted =0    
     AND D.FieldType='M'  AND AM.IsDeleted=0   
    END     
   ELSE    
    BEGIN     
     INSERT INTO #AttributeTemp     
     SELECT D.ServiceID, D.AttributeName, C.StatusID AS ProjectStatusID,    
     C.ProjectID as ProjectID,  DS.DARTStatusID AS DARTStatusID,AM.TicketDetailFields    
     FROM AVL.PRJ_MainspringAttributeProjectStatusMaster D (NOLOCK)     
     INNER JOIN AVL.TK_MAP_ProjectStatusMapping C (NOLOCK) ON D.StatusID=C.TicketStatus_ID     
     AND D.IsDeleted=0 AND D.Projectid=C.ProjectID    
     INNER JOIN AVL.TK_MAS_DARTTicketStatus DS (NOLOCK) on D.StatusID=DS.DARTStatusID       
     LEFT JOIN AVL.MAS_AttributeMaster AM (NOLOCK) ON D.AttributeID=AM.AttributeID    
     WHERE  D.IsDeleted= 0  AND DS.IsDeleted = 0 AND D.FieldType='M'  AND AM.IsDeleted=0  
     AND D.Projectid=@ProjectId  AND AM.IsDeleted=0  
    END     
   END    
  ELSE    
  BEGIN     
   IF NOT EXISTS(SELECT TOP 1 StatusName from AVL.PRJ_StandardAttributeProjectStatusMaster(NOLOCK)     
        WHERE Projectid = @ProjectId and IsDeleted = 0)     
    BEGIN    
     INSERT INTO #AttributeTemp    
     SELECT D.ServiceID,D.AttributeName,0 AS ProjectStatusID,0 as ProjectID,      
     DS.DARTStatusID AS DARTStatusID,AM.TicketDetailFields    
     FROM AVL.MAS_StandardAttributeStatusMaster D (NOLOCK)     
     INNER JOIN AVL.TK_MAS_DARTTicketStatus DS (NOLOCK) on D.StatusID=DS.DARTStatusID       
     LEFT JOIN AVL.MAS_AttributeMaster AM (NOLOCK) ON D.AttributeID=AM.AttributeID    
     WHERE D.IsDeleted= 0  AND DS.IsDeleted = 0 AND D.FieldType='M'  AND AM.IsDeleted=0  
    END    
   ELSE    
    BEGIN    
     INSERT INTO #AttributeTemp    
     SELECT D.ServiceID,D.AttributeName,C.StatusID AS ProjectStatusID,C.ProjectID as ProjectID,      
     DS.DARTStatusID AS DARTStatusID,AM.TicketDetailFields    
     FROM AVL.PRJ_StandardAttributeProjectStatusMaster D (NOLOCK)     
     INNER JOIN AVL.TK_MAP_ProjectStatusMapping C (NOLOCK) ON D.StatusID=C.TicketStatus_ID     
     AND D.IsDeleted=0 AND D.Projectid=C.ProjectID    
     INNER JOIN AVL.TK_MAS_DARTTicketStatus DS (NOLOCK) on D.StatusID=DS.DARTStatusID       
     LEFT JOIN AVL.MAS_AttributeMaster AM (NOLOCK) ON D.AttributeID=AM.AttributeID    
     WHERE D.Projectid=@ProjectId AND D.FieldType='M'   AND AM.IsDeleted=0   
    END     
  END    
  DELETE FROM #AttributeTemp WHERE TicketDetailFields IN('effortTilldate','StatusID','Onsite_Offshore','TicketCreatedBy')    
    
  DECLARE @OptionalAttributeType int    
  SELECT TOP 1 @OptionalAttributeType=OptionalAttributeType from AVL.MAS_ProjectDebtDetails(NOLOCK)     
  WHERE ProjectID=@ProjectId AND ISNULL(IsDeleted,0)=0    
  IF (@OptionalAttributeType=1  OR @OptionalAttributeType=1)   
   BEGIN    
    SELECT ColumnID INTO #TempColumns FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK)     
    WHERE ProjectID=@ProjectId AND IsActive=1    
   END    
  --Get the distinct patterns    
  CREATE TABLE #DistinctPatterns    
  (    
  ID BIGINT IDENTITY(1,1),    
  ServiceID INT NULL,    
  DARTStatusID INT NULL    
  )    
  DECLARE @MinPatternID INT;    
  DECLARE @MaxPatternID INT;    
  INSERT INTO #DistinctPatterns    
  SELECT DISTINCT ServiceID,DARTStatusID FROM #TempTM (NOLOCK) WHERE ProjectID =@ProjectId    
    
  SET @MinPatternID=(SELECT MIN(ID) FROM #DistinctPatterns (NOLOCK))    
  SET @MaxPatternID=(SELECT MAX(ID) FROM #DistinctPatterns (NOLOCK))    
  WHILE @MinPatternID <= @MaxPatternID    
   BEGIN    
    DECLARE @ServiceID INT;     
    DECLARE @DARTStatusID INT;    
    DECLARE @TicketID NVARCHAR(50);    
    
    SET @ServiceID=(SELECT ServiceID FROM #DistinctPatterns (NOLOCK) WHERE ID=@MinPatternID)    
    SET @DARTStatusID=(SELECT DARTStatusID FROM #DistinctPatterns (NOLOCK) WHERE ID=@MinPatternID)    
    SELECT DISTINCT TimeTickerID,TicketID INTO #TicketsFiltered FROM #TempTM (NOLOCK)    
    WHERE ServiceID=@ServiceID AND DARTStatusID=@DARTStatusID    
     
   IF(@ServiceID in (1,4,5,6,7,8,10) AND (@OptionalAttributeType=1 OR @OptionalAttributeType=3))    
     BEGIN    
      IF EXISTS (SELECT ColumnID FROM #TempColumns (NOLOCK) WHERE ColumnID =11 AND @DARTStatusID=8)    
       BEGIN    
        INSERT INTO #AttributeTemp    
        SELECT @ServiceID AS ServiceID,'Flex Field (1)' AS AttributeName,0 AS ProjectStatusID,    
        @ProjectId AS ProjectID,8 AS DARTStatusID,'FlexField(1)' AS TicketDetailFields     
    
       END    
      IF EXISTS (SELECT ColumnID FROM #TempColumns (NOLOCK) WHERE ColumnID =12 AND @DARTStatusID=8 )    
       BEGIN    
        INSERT INTO #AttributeTemp    
        SELECT @ServiceID AS ServiceID,'Flex Field (2)' AS AttributeName,0 AS ProjectStatusID,    
        @ProjectId AS ProjectID,8 AS DARTStatusID,'FlexField(2)' AS TicketDetailFields     
       END    
      IF EXISTS (SELECT ColumnID FROM #TempColumns (NOLOCK) WHERE ColumnID =13 AND @DARTStatusID=8)    
       BEGIN    
        INSERT INTO #AttributeTemp    
        SELECT @ServiceID AS ServiceID,'Flex Field (3)' AS AttributeName,0 AS ProjectStatusID,    
        @ProjectId AS ProjectID,8 AS DARTStatusID,'FlexField(3)' AS TicketDetailFields     
       END    
      IF EXISTS (SELECT ColumnID FROM #TempColumns (NOLOCK) WHERE ColumnID =14 AND @DARTStatusID=8 )    
       BEGIN    
        INSERT INTO #AttributeTemp    
        SELECT @ServiceID AS ServiceID,'Flex Field (4)' AS AttributeName,0 AS ProjectStatusID,    
        @ProjectId AS ProjectID,8 AS DARTStatusID,'FlexField(4)' AS TicketDetailFields     
       END    
     END    
  
IF EXISTS (SELECT IsAutoClassified From AVL.MAS_ProjectDebtDetails(NOLOCK) where IsAutoClassified='Y'   
   and ProjectID=@ProjectId AND IsDeleted=0 AND @DARTStatusID=8 AND @ServiceID in (1,4,5,6,7,8,10))  
 BEGIN  
  IF  EXISTS ( SELECT TOP 1 IsOptionalField FROM ML.ConfigurationProgress(NOLOCK)   
      where ProjectId=@ProjectId AND IsDeleted=0 and IsOptionalField = 1)   
   BEGIN  
   INSERT INTO #AttributeTemp  
   SELECT @ServiceID AS ServiceID,'Resolution Method' AS AttributeName,0 AS ProjectStatusID,    
     @ProjectId AS ProjectID,8 AS DARTStatusID,'ResolutionRemarks' AS TicketDetailFields    
   END  
  INSERT INTO #AttributeTemp  
  SELECT @ServiceID AS ServiceID,'Ticket Description' AS AttributeName,0 AS ProjectStatusID,    
    @ProjectId AS ProjectID,8 AS DARTStatusID,'TicketDescription' AS TicketDetailFields    
 END  
     
    
    Update #AttributeTemp set TicketDetailFields = REPLACE(REPLACE(TicketDetailFields,')',''),'(','')    
    SELECT DISTINCT TicketDetailFields,ServiceID,DARTStatusID INTO #AttributeTempByPattern FROM #AttributeTemp     
    WHERE ServiceID=@ServiceID AND DARTStatusID=@DARTStatusID    
    
    SELECT * INTO #TempTMFiltered FROM #TempTM (NOLOCK) WHERE ServiceID=@ServiceID AND DARTStatusID=@DARTStatusID    
    DECLARE @colsUnpivot  AS NVARCHAR(MAX),@query  AS NVARCHAR(MAX)    
    DECLARE @colsUnpivotNotNull AS NVARCHAR(MAX);    
    DECLARE @colsUnpivotNotEmpty AS NVARCHAR(MAX);    
    DECLARE @SelectTicketsInfo NVARCHAR(MAX);    
    SET @SelectTicketsInfo='SELECT TimeTickerID FROM #TicketsFiltered (NOLOCK)'    
    select @colsUnpivot  = STUFF((SELECT ',' + QUOTENAME(TicketDetailFields)     
         from #AttributeTempByPattern (NOLOCK) WHERE ServiceID=@ServiceID and DARTStatusID=@DARTStatusID    
         --order by id    
         FOR XML PATH(''), TYPE    
         ).value('.', 'NVARCHAR(MAX)')     
         ,1,1,'')    
    select @colsUnpivotNotNull  = STUFF((SELECT ' IS NOT NULL' + ' AND' + QUOTENAME(TicketDetailFields)     
         from #AttributeTempByPattern(NOLOCK)  WHERE ServiceID=@ServiceID and DARTStatusID=@DARTStatusID    
         --order by id    
         FOR XML PATH(''), TYPE    
         ).value('.', 'NVARCHAR(MAX)')     
         ,1,16,'')    
    select @colsUnpivotNotEmpty  = STUFF(( SELECT ' !=  ''''  AND' +' CONVERT(NVARCHAR(MAX),'  + QUOTENAME(TicketDetailFields) + ')'    
         from #AttributeTempByPattern (NOLOCK) WHERE ServiceID=@ServiceID and DARTStatusID=@DARTStatusID    
         --order by id    
         FOR XML PATH(''), TYPE    
         ).value('.', 'NVARCHAR(MAX)')     
         ,1,12,'')    
    
    SET @query= 'INSERT INTO  #TicketUpdated SELECT  TimeTickerID, ProjectID,TicketID,1 AS IsAttributeUpdated FROM #TempTMFiltered WHERE ' +@colsUnpivotNotNull +'IS NOT NULL ' +' AND'    
    +@colsUnpivotNotEmpty + ' != ''''' + 'AND TimeTickerID IN (' + @SelectTicketsInfo + ')'    
    
   EXEC sp_executesql @query;    
    
  IF OBJECT_ID('tempdb..#AttributeTempByPattern', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #AttributeTempByPattern  
END  
IF OBJECT_ID('tempdb..#TempTMFiltered', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #TempTMFiltered  
END  
IF OBJECT_ID('tempdb..#TicketsFiltered', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #TicketsFiltered  
END  
  
   
   SET @MinPatternID=@MinPatternID+1;    
   END    
  
     IF OBJECT_ID('tempdb..#TempColumns', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #TempColumns  
END  
IF OBJECT_ID('tempdb..#AttributeTemp', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #AttributeTemp  
END  
IF OBJECT_ID('tempdb..#DistinctPatterns', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #DistinctPatterns  
END  
   
  END    
ELSE    
 BEGIN    
  CREATE TABLE #CustomerTickets    
  (    
  ID BIGINT IDENTITY(1,1),    
  TimeTickerID BIGINT NULL,    
  ProjectID BIGINT NULL,    
  TicketID NVARCHAR(500) NULL,    
  TicketTypeMappingID BIGINT NULL,    
  DARTStatusID INT NULL,    
  DebtConsidered NVARCHAR(10) NULL    
  )    
  INSERT INTO #CustomerTickets    
  SELECT TimeTickerID,ProjectID,TicketID,TicketTypeMapID,DARTStatusID,NULL FROM #TRN_TicketDetails (NOLOCK)   
  WHERE ProjectID =@ProjectID    
    
  UPDATE TD SET TD.DebtConsidered=ISNULL(TTM.DebtConsidered,'N')    
  FROM #CustomerTickets TD    
  INNER JOIN AVL.TK_MAP_TicketTypeMapping  TTM    
  ON TD.TicketTypeMappingID=TTM.TicketTypeMappingID AND TD.ProjectID=TTM.ProjectID    
    
  DECLARE @IsDebtEnabled NVARCHAR(10);    
  SET @IsDebtEnabled=(SELECT IsDebtEnabled FROM AVL.MAS_ProjectMaster (NOLOCK) WHERE ProjectID=@ProjectId AND IsDeleted=0);    
    
  SELECT TOP 1 @OptionalAttributeType=OptionalAttributeType from AVL.MAS_ProjectDebtDetails (NOLOCK) where ProjectID=@ProjectId AND IsDeleted<>1    
    
  IF (@OptionalAttributeType=1 OR @OptionalAttributeType=3) 
  BEGIN    
   SELECT ColumnID INTO #TempColumnsCustomer FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping (NOLOCK)    
   WHERE ProjectID=@ProjectId AND IsActive=1    
  END    
  CREATE TABLE #DistinctPatternsCustomer    
  (    
  ID BIGINT IDENTITY(1,1),    
  DebtConsidered NVARCHAR(10) NULL,    
  DARTStatusID INT NULL    
  )    
  INSERT INTO #DistinctPatternsCustomer    
  SELECT DISTINCT  DebtConsidered , DartStatusID  FROM #CustomerTickets (NOLOCK)    
  WHERE ProjectID=@ProjectId    
    
  DECLARE @MinPatternIDCustomer INT;    
  DECLARE @MaxPatternIDCustomer INT;    
  SET @MinPatternIDCustomer=(SELECT MIN(ID) FROM #DistinctPatternsCustomer (NOLOCK))    
  SET @MaxPatternIDCustomer=(SELECT MAX(ID) FROM #DistinctPatternsCustomer (NOLOCK))    
  WHILE @MinPatternIDCustomer <= @MaxPatternIDCustomer    
  BEGIN    
   DECLARE @DARTStatusIDCustomer INT;    
   DECLARE @IsDebtConsidered NVARCHAR(10);    
    
   CREATE TABLE #AttributeTempCustomer    
   (    
   ID BIGINT IDENTITY(1,1),    
   ServiceID INT NULL,    
   AttributeName NVARCHAR(1000) NULL,    
   ProjectStatusID BIGINT NULL,    
   ProjectID BIGINT NULL,    
   DARTStatusID INT NULL,    
   TicketDetailFields NVARCHAR(1000) NULL    
   )    
   SET @DARTStatusIDCustomer=(SELECT DARTStatusID FROM #DistinctPatternsCustomer (NOLOCK) WHERE ID=@MinPatternIDCustomer);    
   SET @IsDebtConsidered=(SELECT DebtConsidered FROM #DistinctPatternsCustomer (NOLOCK) WHERE ID=@MinPatternIDCustomer);    
       
   SELECT * INTO #TempTMCustomer FROM #TempTM  TD (NOLOCK)   
   WHERE TD.TimeTickerID IN(SELECT TimeTickerID from #CustomerTickets (NOLOCK)    
          WHERE ProjectID=@ProjectId AND DartStatusId=@DARTStatusIDCustomer AND DebtConsidered=@IsDebtConsidered)    
    
    INSERT INTO #AttributeTempCustomer    
    SELECT 0 AS ServiceID,AM.AttributeName,0 AS ProjectStatusID,    
    0 AS ProjectID,tm.StatusID AS DARTStatusID,AM.TicketDetailFields FROM AVL.MAS_TicketTypeStatusAttributeMaster tm (NOLOCK)   
    inner join  AVL.MAS_AttributeMaster am (NOLOCK)  
    ON TM.AttributeID=AM.AttributeID    
    WHERE StatusID=@DARTStatusIDCustomer AND FieldType='M' AND am.IsDeleted=0   
        
    IF (@DARTStatusIDCustomer=8 AND (@OptionalAttributeType=1 OR @OptionalAttributeType=3))    
     BEGIN    
       IF EXISTS (SELECT ColumnID FROM #TempColumnsCustomer (NOLOCK) WHERE ColumnID =11 AND @DARTStatusIDCustomer=8)    
       BEGIN    
        INSERT INTO #AttributeTempCustomer    
        SELECT 0 AS ServiceID,'Flex Field (1)' AS AttributeName,0 AS ProjectStatusID,    
        0 AS ProjectID,8 AS DARTStatusID,'FlexField(1)' AS TicketDetailFields     
       END    
      IF EXISTS (SELECT ColumnID FROM #TempColumnsCustomer (NOLOCK) WHERE ColumnID =12 AND @DARTStatusIDCustomer=8)    
      BEGIN    
       INSERT INTO #AttributeTempCustomer    
       SELECT 0 AS ServiceID,'Flex Field (2)' AttributeName,0 AS ProjectStatusID,    
        0 AS ProjectID,8 AS DARTStatusID,'FlexField(2)' AS TicketDetailFields    
      END    
      IF EXISTS (SELECT ColumnID FROM #TempColumnsCustomer (NOLOCK) WHERE ColumnID =13 AND @DARTStatusIDCustomer=8)    
      BEGIN    
       INSERT INTO #AttributeTempCustomer    
       SELECT 0 AS ServiceID,'Flex Field (3)' AS AttributeName,0 AS ProjectStatusID,    
       0 AS ProjectID,8 AS DARTStatusID,'FlexField(3)' AS TicketDetailFields     
      END    
      IF EXISTS (SELECT ColumnID FROM #TempColumnsCustomer (NOLOCK) WHERE ColumnID =14 AND @DARTStatusIDCustomer=8)    
      BEGIN    
       INSERT INTO #AttributeTempCustomer    
       SELECT 0 AS ServiceID,'Flex Field (4)' AttributeName,0 AS ProjectStatusID,    
        0 AS ProjectID,8 AS DARTStatusID,'FlexField(4)' AS TicketDetailFields    
      END    
     END    
  
 IF EXISTS ( SELECT IsAutoClassified From AVL.MAS_ProjectDebtDetails(NOLOCK) where IsAutoClassified='Y'  
    and ProjectID=@ProjectId AND IsDeleted=0  AND @DARTStatusIDCustomer=8 AND @IsDebtConsidered='Y')  
  BEGIN  
   IF  EXISTS ( SELECT TOP 1 IsOptionalField FROM ML.ConfigurationProgress(NOLOCK)   
      where ProjectId=@ProjectId AND IsDeleted=0 and IsOptionalField = 1)   
    BEGIN  
     INSERT INTO #AttributeTempCustomer  
     SELECT 0 AS ServiceID,'Resolution Method' AttributeName,0 AS ProjectStatusID,    
      0 AS ProjectID,8 AS DARTStatusID,'ResolutionRemarks' AS TicketDetailFields  
    END    
  INSERT INTO #AttributeTempCustomer  
  SELECT 0 AS ServiceID,'Ticket Description' AttributeName,0 AS ProjectStatusID,    
   0 AS ProjectID,8 AS DARTStatusID,'TicketDescription' AS TicketDetailFields      
 END  
  
    
    Update #AttributeTempCustomer set TicketDetailFields = REPLACE(REPLACE(TicketDetailFields,')',''),'(','')    
    IF @IsDebtEnabled != 'Y' or  @IsDebtConsidered != 'Y'    
     BEGIN    
      DELETE FROM #AttributeTempCustomer WHERE TicketDetailFields in('DebtClassificationMapID',    
      'AvoidableFlag','ResidualDebtMapID','CauseCodeMapID','ResolutionCodeMapID')    
      DELETE FROM #AttributeTempCustomer WHERE AttributeName IN('Flex Field (1)','Flex Field (2)','Flex Field (3)','Flex Field (4)',    
      'FlexField(1)','FlexField(2)','FlexField(3)','FlexField(4)')    
     END    
    
    IF (SELECT  COUNT(*) FROM #AttributeTempCustomer (NOLOCK)) >0    
     BEGIN    
     DECLARE @colsUnpivotCustomer  AS NVARCHAR(MAX),@queryCustomer  AS NVARCHAR(MAX)    
     DECLARE @colsUnpivotNotNullCustomer  AS NVARCHAR(MAX);    
     DECLARE @colsUnpivotNotEmptyCustomer  AS NVARCHAR(MAX);    
     DECLARE @SelectTicketsInfoCustomer  NVARCHAR(MAX);    
     SET @SelectTicketsInfoCustomer ='SELECT TicketID FROM #TempTMCustomer (NOLOCK)'    
     select @colsUnpivotCustomer   = STUFF((SELECT ',' + QUOTENAME(TicketDetailFields)     
          from #AttributeTempCustomer (NOLOCK) WHERE DARTStatusID=@DARTStatusIDCustomer    
          order by id    
          FOR XML PATH(''), TYPE    
          ).value('.', 'NVARCHAR(MAX)')     
          ,1,1,'')    
     select @colsUnpivotNotNullCustomer   = STUFF((SELECT ' IS NOT NULL' + ' AND' + QUOTENAME(TicketDetailFields)     
          from #AttributeTempCustomer (NOLOCK) WHERE  DARTStatusID=@DARTStatusIDCustomer    
          order by id    
          FOR XML PATH(''), TYPE    
          ).value('.', 'NVARCHAR(MAX)')     
          ,1,16,'')    
     select @colsUnpivotNotEmptyCustomer   = STUFF(( SELECT ' !=  ''''  AND' +' CONVERT(NVARCHAR(MAX),'  + QUOTENAME(TicketDetailFields) + ')'    
          from #AttributeTempCustomer (NOLOCK) WHERE  DARTStatusID=@DARTStatusIDCustomer    
          order by id    
          FOR XML PATH(''), TYPE    
          ).value('.', 'NVARCHAR(MAX)')     
          ,1,12,'')    
    
     SET @queryCustomer = 'INSERT INTO  #TicketUpdated SELECT  TimeTickerID, ProjectID,TicketID,1 AS IsAttributeUpdated FROM #TempTMCustomer (NOLOCK)  WHERE '    
      +@colsUnpivotNotNullCustomer +'IS NOT NULL ' +' AND'+@colsUnpivotNotEmptyCustomer + ' != '''''    
    EXEC sp_executesql @queryCustomer;    
    END    
   ELSE    
    BEGIN    
     SET @queryCustomer = 'INSERT INTO  #TicketUpdated SELECT  TimeTickerID, ProjectID,TicketID,1 AS IsAttributeUpdated FROM #TempTMCustomer (NOLOCK)'    
    EXEC sp_executesql @queryCustomer;    
    END    
  
      IF OBJECT_ID('tempdb..#TempTMCustomer', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #TempTMCustomer  
END  
IF OBJECT_ID('tempdb..#AttributeTempCustomer', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #AttributeTempCustomer  
END  
    
    
   SET @MinPatternIDCustomer=@MinPatternIDCustomer+1;    
  END    
        IF OBJECT_ID('tempdb..#CustomerTickets', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #CustomerTickets  
END  
IF OBJECT_ID('tempdb..#DistinctPatternsCustomer', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #DistinctPatternsCustomer  
END  
IF OBJECT_ID('tempdb..#TempColumnsCustomer', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #TempColumnsCustomer  
END  
  
  
  
    
END  

--Check for Clustering Algo        
        
DECLARE @AlgorithmKey NVARCHAR(25)        
SET @AlgorithmKey=ISNULL( (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@PROJECTID AND ISNULL(IsActiveTransaction,0)=1 AND IsDeleted=0 AND SupportTypeId=1),'AL002')
IF(@AlgorithmKey='AL002')        
BEGIN                     
CREATE TABLE #BatchProcess(                    
ticketid nvarchar(100),                    
BatchProcessId bigint ,                    
[Assignment Group] bigint,                            
[Category] nvarchar(max) ,                            
[Cause Code] bigint,                            
[Comments] nvarchar(2000) ,                            
[Flex Field (1)] nvarchar(max) ,                            
[Flex Field (2)] nvarchar(max) ,                            
[Flex Field (3)] nvarchar(max) ,                            
[Flex Field (4)] nvarchar(max) ,                            
[KEDB Available Indicator] bigint  , [Related Tickets] nvarchar(100),                            
[Release Type] bigint,                            
[Resolution Code] bigint,                            
[Resolution Remarks] nvarchar(max),                            
[Ticket Description] nvarchar(max) ,                            
[Ticket Source] bigint,                            
[Ticket Summary] nvarchar(max),                            
[Ticket Type] bigint);                    
--Get Column Mapping                    
SELECT FN.ITSMColumn     into #temp                      
FROM [ML].[TRN_MLTransaction] (NOLOCK) MT                          
JOIN [ML].[TRN_TransactionCategorical] (NOLOCK) MD ON MD.MLTransactionId=MT.TransactionId                           
JOIN [MAS].[ML_Prerequisite_FieldMapping] (NOLOCK) FN ON FN.FieldMappingId=MD.CategoricalFieldId                           
WHERE ProjectId= @ProjectId  AND ISNULL(MT.IsActiveTransaction,0)=1 AND MT.SupportTypeId=1                            
UNION                          
(SELECT FN.ITSMColumn FROM [ML].[TRN_MLTransaction] (NOLOCK) t LEFT join                           
[MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=t.IssueDefinitionId             
or FN.FieldMappingId=t.ResolutionProviderId                           
WHERE t.ProjectId= @ProjectId  AND ISNULL(t.IsActiveTransaction,0)=1 AND t.SupportTypeId=1 )                       
--Get Batch Column                    
SELECT T.ticketid, T.BatchProcessId, T.[AssignmentGroupId] 'Assignment Group',  T.[Category] , T.[CauseCodeMapID] 'Cause Code',  T.[Comments] ,                            
T.[FlexField1]  'Flex Field (1)',T.[FlexField2] 'Flex Field (2)', T.[FlexField3] 'Flex Field (3)', T.[FlexField4] 'Flex Field (4)',                
T.[KEDBAvailableIndicatorMapID] 'KEDB Available Indicator'  , T.[RelatedTickets] 'Related Tickets', T.[ReleaseTypeMapID] 'Release Type',                            
T.[ResolutionCodeMapID] 'Resolution Code',T.[ResolutionRemarks] 'Resolution Remarks',T.[TicketDescription] 'Ticket Description',T.[TicketSourceMapID] 'Ticket Source',                            
T.[TicketSummary] 'Ticket Summary', T.[TicketTypeMapID] 'Ticket Type' INTO #Batch                      
FROM ML.AutoClassificationBatchProcess (NOLOCK) M                     
INNER JOIN ML.TicketsforAutoClassification (NOLOCK) T ON M.BatchProcessId=T.BatchProcessId                    
WHERE projectid=@ProjectId AND T.SupportType=1                    
                    
--GET NULL                     
DECLARE @GetQuery NVARCHAR(MAX)                    
DECLARE @result nvarchar(max)                     
SET @GetQuery=STUFF((SELECT ' ' + ' ' + QUOTENAME(ITSMColumn)  +' IS  NULL'+' OR'    + QUOTENAME(ITSMColumn)  +'= ''' +''''+' OR '                  
           from #temp (NOLOCK)                         
           FOR XML PATH(''), TYPE                          
           ).value('.', 'NVARCHAR(MAX)')                           
           ,1,0,'')                      
                    
SET @result=' INSERT  into #BatchProcess SELECT * FROM  #Batch (NOLOCK) WHERE '+@GetQuery+' '                    
SET @result=(SELECT left(@result, len(@result)-2))                    
EXEC sp_executesql @result;                    
                    
 DELETE   T              
 FROM #TicketUpdated T                    
 JOIN #BatchProcess B   ON B.ticketid=T.TicketID                    
 WHERE B.ticketid=T.TicketID                    
                    
DROP TABLE #temp                    
DROP TABLE #Batch                     
DROP TABLE #BatchProcess                    
END   
  UPDATE #TRN_TicketDetails SET IsAttributeUpdated=0 WHERE TimeTickerID NOT IN    
  (SELECT TimeTickerID FROM #TicketUpdated (NOLOCK))    
  UPDATE #TRN_TicketDetails SET IsAttributeUpdated=1 WHERE TimeTickerID  IN    
  (SELECT TimeTickerID FROM #TicketUpdated (NOLOCK))    
    
  UPDATE TD SET TD.IsAttributeUpdated =T1.IsAttributeUpdated, TD.LastUpdatedDate=GETDATE()    
  FROM #TRN_TicketDetails T1    
  INNER JOIN AVL.TK_TRN_TicketDetail TD    
  ON T1.TimeTickerID =TD.TimeTickerID AND T1.ProjectID =TD.ProjectID    
  AND T1.TicketID = TD.TicketID    
    
  UPDATE AVL.TK_TRN_IsAttributeUpdated SET IsProcessed=1 WHERE TimeTickerID IN    
  (SELECT TimeTickerID FROM #TRN_TicketDetails (NOLOCK))    
    
  DELETE FROM AVL.TK_TRN_IsAttributeUpdated WHERE Mode=@Mode AND ProjectId=@ProjectId    
  AND TimeTickerID IN    
  (SELECT TimeTickerID FROM #TRN_TicketDetails (NOLOCK))    
    
  
 --BLOCK START FOR INFRA ATTRIBUTES update  
 CREATE TABLE #TRN_InfraIsAttributeUpdated  
 (  
 ID BIGINT IDENTITY(1,1),  
 TimeTickerID BIGINT NOT NULL,  
 ProjectID BIGINT NOT NULL,  
 TicketID NVARCHAR(100) NULL  
 )  
 CREATE TABLE #TRN_InfraTicketDetails  
 (  
 TimeTickerID BIGINT NOT NULL,  
 ProjectID BIGINT NOT NULL,  
 TicketID  NVARCHAR(100) NULL,  
 DartStatusId INT  NULL,  
 IsAttributeUpdated  INT NULL,  
 )  
 CREATE TABLE #InfraAttributeTemp  
 (  
 ID BIGINT IDENTITY(1,1),  
 AttributeName NVARCHAR(1000) NULL,  
 TicketDetailFields NVARCHAR(1000) NULL,  
 DartStatusID INT NULL  
 )  
 INSERT INTO #TRN_InfraIsAttributeUpdated  
 SELECT TimeTickerID,ProjectID,TicketID FROM AVL.TK_TRN_InfraIsAttributeUpdated (NOLOCK) 
 WHERE ProjectId=@ProjectID AND Mode=@Mode AND ISNULL(IsProcessed,0)=0  
  
 INSERT INTO #TRN_InfraTicketDetails    
 SELECT TAU.TimeTickerID as TimeTickerID,TAU.ProjectID as ProjectID,TAU.TicketID as TicketID,   
 TD.DartStatusId as DartStatusId,NULL AS IsAttributeUpdated     
 FROM #TRN_InfraIsAttributeUpdated (NOLOCK) TAU    
 INNER JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD    
 ON TAU.TimeTickerID=TD.TimeTickerID WHERE TD.ProjectID=@ProjectId  
  
 SELECT TD.TimeTickerID,TD.TicketID,TD.ProjectID,TD.AssignedTo,TD.AssignmentGroup,TD.EffortTillDate,TD.ServiceID  
 ,TD.TicketDescription,TD.IsDeleted,CauseCodeMapID,DebtClassificationMapID,ResidualDebtMapID,ResolutionCodeMapID  
 ,ResolutionMethodMapID,KEDBAvailableIndicatorMapID,KEDBUpdatedMapID,KEDBPath,PriorityMapID,ReleaseTypeMapID  
 ,SeverityMapID,TicketSourceMapID,TicketStatusMapID,TicketTypeMapID,BusinessSourceName,Onsite_Offshore,PlannedEffort  
 ,EstimatedWorkSize,ActualEffort,ActualWorkSize,Resolvedby,Closedby,ElevateFlagInternal,RCAID,PlannedDuration  
 ,Actualduration,TicketSummary,NatureoftheTicket,Comments,RepeatedIncident,RelatedTickets,TicketCreatedBy  
 ,SecondaryResources,EscalatedFlagCustomer,ReasonforRejection,AvoidableFlag,ReleaseDate,TicketCreateDate  
 ,PlannedStartDate,PlannedEndDate,ActualStartdateTime,ActualEnddateTime,OpenDateTime,StartedDateTime  
 ,WIPDateTime,OnHoldDateTime,CompletedDateTime,ReopenDateTime,CancelledDateTime,RejectedDateTime,Closeddate  
 ,AssignedDateTime,OutageDuration,MetResponseSLAMapID,MetAcknowledgementSLAMapID,MetResolutionMapID  
 ,EscalationSLA,TKBusinessID,InscopeOutscope,TD.IsAttributeUpdated,NewStatusDateTime,IsSDTicket,IsManual,  
 TD.DARTStatusID  
 ,ResolutionRemarks,ITSMEffort,CreatedBy,CreatedDate,LastUpdatedDate,ModifiedBy,ModifiedDate,IsApproved  
 ,ReasonResidualMapID,ExpectedCompletionDate,ApprovedBy,DAPId,DebtClassificationMode,FlexField1,FlexField2  
 ,FlexField3,FlexField4,Category,[Type],TowerID,IsPartiallyAutomated  INTO #TempTMInfra FROM #TRN_InfraTicketDetails TM (NOLOCK)   
 INNER JOIN AVL.TK_TRN_InfraTicketDetail (NOLOCK) TD  ON TM.TimeTickerID=TD.TimeTickerID    
 WHERE TD.ProjectID=@ProjectId    
  
 -- Updating the column values with null data    
 UPDATE  #TempTMInfra SET ReleaseTypeMapID   =NULL WHERE ReleaseTypeMapID             =0    
 UPDATE  #TempTMInfra SET SeverityMapID    =NULL WHERE SeverityMapID     =0    
 UPDATE  #TempTMInfra SET KEDBAvailableIndicatorMapID =NULL WHERE KEDBAvailableIndicatorMapID  =0    
 UPDATE  #TempTMInfra SET MetAcknowledgementSLAMapID =NULL WHERE MetAcknowledgementSLAMapID  =0    
 UPDATE  #TempTMInfra SET MetResolutionMapID   =NULL WHERE MetResolutionMapID    =0    
 UPDATE  #TempTMInfra SET MetResponseSLAMapID   =NULL WHERE MetResponseSLAMapID    =0    
 UPDATE  #TempTMInfra SET NatureoftheTicket   =NULL WHERE NatureoftheTicket    =0    
 UPDATE  #TempTMInfra SET ReleaseTypeMapID   =NULL WHERE ReleaseTypeMapID    =0    
 UPDATE  #TempTMInfra SET DebtClassificationMapID  =NULL WHERE DebtClassificationMapID   =0    
 UPDATE  #TempTMInfra SET ElevateFlagInternal   =NULL WHERE ElevateFlagInternal    =0    
 UPDATE  #TempTMInfra SET EscalatedFlagCustomer   =NULL WHERE EscalatedFlagCustomer    =0    
 UPDATE  #TempTMInfra SET ResidualDebtMapID   =NULL WHERE ResidualDebtMapID    =0    
 UPDATE  #TempTMInfra SET AvoidableFlag    =NULL WHERE AvoidableFlag     =0    
 UPDATE  #TempTMInfra SET CauseCodeMapID    =NULL WHERE CauseCodeMapID     =0    
 UPDATE  #TempTMInfra SET KEDBUpdatedMapID   =NULL WHERE KEDBUpdatedMapID    =0    
 UPDATE  #TempTMInfra SET ActualWorkSize    =NULL WHERE ActualWorkSize    ='0.00'    
 UPDATE  #TempTMInfra SET EstimatedWorkSize   =NULL WHERE EstimatedWorkSize   ='0.00'    
 UPDATE  #TempTMInfra SET OutageDuration    =NULL WHERE OutageDuration    ='0.00'    
 UPDATE  #TempTMInfra SET PlannedEffort    =NULL WHERE PlannedEffort    ='0.00'    
 UPDATE  #TempTMInfra SET ResolutionRemarks =NULL WHERE ResolutionRemarks =''  
  
 DECLARE @IsDebtProject CHAR(1);  
 SET @IsDebtProject=(SELECT ISNULL(IsDebtEnabled,'N') FROM AVL.MAS_ProjectMaster(NOLOCK)   
      WHERE ProjectID=@ProjectID AND ISNULL(IsDeleted,0)=0)  
  
 IF @IsDebtProject ='Y'  
  BEGIN  
   INSERT INTO #InfraAttributeTemp  
   SELECT  
   A.AttributeName,  
   B.TicketDetailFields AS TicketDetailFields,A.StatusID  
   FROM [AVL].[MAS_InfraAttributeStatusMaster] A (NOLOCK)   
   LEFT JOIN AVL.MAS_AttributeMaster B (NOLOCK) ON A.AttributeID=B.AttributeID    
   WHERE  A.IsDeleted= 0  AND A.DebtFieldType='M' AND B.IsDeleted=0  
  END  
 ELSE  
  BEGIN  
   INSERT INTO #InfraAttributeTemp  
   SELECT  
   A.AttributeName,  
   B.TicketDetailFields AS TicketDetailFields,A.StatusID  
   FROM [AVL].[MAS_InfraAttributeStatusMaster] A (NOLOCK)   
   LEFT JOIN AVL.MAS_AttributeMaster B (NOLOCK) ON A.AttributeID=B.AttributeID    
   WHERE  A.IsDeleted= 0  AND A.StandardFieldType='M' AND B.IsDeleted=0  
  END  
  
IF EXISTS (SELECT IsAutoClassifiedInfra From AVL.MAS_ProjectDebtDetails(NOLOCK) where IsAutoClassifiedInfra='Y'   
   and ProjectID=@ProjectID AND IsDeleted=0)  
BEGIN  
   IF  EXISTS ( SELECT A.OptionalFields FROM AVL.ML_MAS_OptionalFields(NOLOCK) A   
       INNER JOIN AVL.ML_MAP_OptionalProjMappingInfra(NOLOCK) B on A.ID=B.OptionalFieldID where B.ProjectId=@ProjectId   
       AND A.OptionalFields = 'Resolution Remarks' AND B.IsDeleted=0 AND A.IsDeleted=0 )   
   BEGIN  
     INSERT INTO #InfraAttributeTemp  
     SELECT 'Resolution Method' AS AttributeName,'ResolutionRemarks' AS TicketDetailFields,8 as DartStatusID   
   END  
 INSERT INTO #InfraAttributeTemp  
 SELECT 'Ticket Description' AS AttributeName,'TicketDescription' AS TicketDetailFields,8 as DartStatusID  
END  
  
 --Get the distinct patterns    
 CREATE TABLE #DistinctPatternsInfra  
 (    
 ID BIGINT IDENTITY(1,1),     
 DARTStatusID INT NULL    
 )    
 DECLARE @MinPatternIDInfra INT;    
 DECLARE @MaxPatternIDInfra INT;    
 INSERT INTO #DistinctPatternsInfra    
 SELECT DISTINCT DARTStatusID FROM #TempTMInfra (NOLOCK) WHERE ProjectID =@ProjectId  AND DARTStatusID IS NOT NULL  
 SET @MinPatternIDInfra=(SELECT MIN(ID) FROM #DistinctPatternsInfra)    
 SET @MaxPatternIDInfra=(SELECT MAX(ID) FROM #DistinctPatternsInfra)    
 WHILE @MinPatternIDInfra <= @MaxPatternIDInfra    
 BEGIN    
  DECLARE @DARTStatusIDInfra INT  
  SET @DARTStatusIDInfra=(SELECT DARTStatusID FROM #DistinctPatternsInfra (NOLOCK) WHERE ID=@MinPatternIDInfra)  
  SELECT DISTINCT TimeTickerID,TicketID INTO #TicketsFilteredInfra FROM #TempTMInfra (NOLOCK)     
  WHERE  DARTStatusID=@DARTStatusIDInfra    
  SELECT DISTINCT TicketDetailFields,DARTStatusID INTO #AttributeTempByPatternInfra FROM #InfraAttributeTemp (NOLOCK)    
  WHERE DARTStatusID=@DARTStatusIDInfra    
  SELECT * INTO #TempTMFilteredInfra FROM #TempTMInfra (NOLOCK) WHERE  DARTStatusID=@DARTStatusIDInfra    
  DECLARE @colsUnpivotInfra  AS NVARCHAR(MAX),@queryInfra  AS NVARCHAR(MAX)    
  DECLARE @colsUnpivotNotNullInfra AS NVARCHAR(MAX);    
  DECLARE @colsUnpivotNotEmptyInfra AS NVARCHAR(MAX);    
  DECLARE @SelectTicketsInfoInfra NVARCHAR(MAX);    
  SET @SelectTicketsInfoInfra='SELECT TimeTickerID FROM #TicketsFilteredInfra'    
  select @colsUnpivotInfra  = STUFF((SELECT ',' + QUOTENAME(TicketDetailFields)     
         from #AttributeTempByPatternInfra (NOLOCK) WHERE  DARTStatusID=@DARTStatusIDInfra    
         FOR XML PATH(''), TYPE    
         ).value('.', 'NVARCHAR(MAX)')     
         ,1,1,'')    
  select @colsUnpivotNotNullInfra  = STUFF((SELECT ' IS NOT NULL' + ' AND' + QUOTENAME(TicketDetailFields)     
           from #AttributeTempByPatternInfra (NOLOCK) WHERE  DARTStatusID=@DARTStatusIDInfra    
           FOR XML PATH(''), TYPE    
           ).value('.', 'NVARCHAR(MAX)')     
           ,1,16,'')    
  select @colsUnpivotNotEmptyInfra  = STUFF(( SELECT ' !=  ''''  AND' +' CONVERT(NVARCHAR(MAX),'  + QUOTENAME(TicketDetailFields) + ')'    
           from #AttributeTempByPatternInfra (NOLOCK) WHERE DARTStatusID=@DARTStatusIDInfra    
           FOR XML PATH(''), TYPE    
           ).value('.', 'NVARCHAR(MAX)')     
           ,1,12,'')    
  
  SET @queryInfra= 'INSERT INTO  #TicketUpdated SELECT  TimeTickerID, ProjectID,TicketID,  
       1 AS IsAttributeUpdated FROM #TempTMFilteredInfra WHERE '  
       +@colsUnpivotNotNullInfra +'IS NOT NULL ' +' AND'    
       +@colsUnpivotNotEmptyInfra + ' != ''''' + 'AND TimeTickerID IN (' + @SelectTicketsInfoInfra + ')'    
  EXEC sp_executesql @queryInfra;    
  SELECT @queryInfra  
  SET @MinPatternIDInfra =@MinPatternIDInfra +1;    
  DROP TABLE #TicketsFilteredInfra  
  DROP TABLE #AttributeTempByPatternInfra  
  DROP TABLE #TempTMFilteredInfra  
 END    
 --Infra Clustering Algo        
        
 DECLARE @AlgorithmKeyInfra NVARCHAR(25)        
SET @AlgorithmKeyInfra=ISNULL( (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@PROJECTID AND ISNULL(IsActiveTransaction,0)=1 AND IsDeleted=0 AND SupportTypeId=2),'AL002')
IF(@AlgorithmKeyInfra='AL002')        
BEGIN                     
CREATE TABLE #BatchProcessInfra(                    
ticketid nvarchar(100),                    
BatchProcessId bigint ,                    
[Assignment Group] bigint,                            
[Category] nvarchar(max) ,                            
[Cause Code] bigint,                            
[Comments] nvarchar(2000) ,                            
[Flex Field (1)] nvarchar(max) ,                            
[Flex Field (2)] nvarchar(max) ,                            
[Flex Field (3)] nvarchar(max) ,                            
[Flex Field (4)] nvarchar(max) ,                            
[KEDB Available Indicator] bigint  ,                            
[Related Tickets] nvarchar(100),                            
[Release Type] bigint,                      
[Resolution Code] bigint,                            
[Resolution Remarks] nvarchar(max),                            
[Ticket Description] nvarchar(max) ,                            
[Ticket Source] bigint,                            
[Ticket Summary] nvarchar(max),                            
[Ticket Type] bigint);                    
--Get Column Mapping                    
SELECT FN.ITSMColumn     into #tempInfra                     
FROM [ML].[TRN_MLTransaction](NOLOCK) MT                          
JOIN [ML].[TRN_TransactionCategorical](NOLOCK) MD ON MD.MLTransactionId=MT.TransactionId                           
JOIN [MAS].[ML_Prerequisite_FieldMapping](NOLOCK) FN ON FN.FieldMappingId=MD.CategoricalFieldId                           
WHERE ProjectId= @ProjectId  AND ISNULL(MT.IsActiveTransaction,0)=1    AND MT.SupportTypeId=2                      
UNION                          
(SELECT FN.ITSMColumn FROM [ML].[TRN_MLTransaction](NOLOCK) t LEFT join                           
[MAS].[ML_Prerequisite_FieldMapping](NOLOCK) FN ON FN.FieldMappingId=t.IssueDefinitionId                          
or FN.FieldMappingId=t.ResolutionProviderId                           
WHERE t.ProjectId= @ProjectId  AND ISNULL(t.IsActiveTransaction,0)=1 AND t.SupportTypeId=2 )                       
--Get Batch Column                    
SELECT T.ticketid, T.BatchProcessId, T.[AssignmentGroupId] 'Assignment Group',  T.[Category] , T.[CauseCodeMapID] 'Cause Code',  T.[Comments] ,                            
T.[FlexField1]  'Flex Field (1)',T.[FlexField2] 'Flex Field (2)', T.[FlexField3] 'Flex Field (3)', T.[FlexField4] 'Flex Field (4)',                
T.[KEDBAvailableIndicatorMapID] 'KEDB Available Indicator'  , T.[RelatedTickets] 'Related Tickets', T.[ReleaseTypeMapID] 'Release Type',                            
T.[ResolutionCodeMapID] 'Resolution Code',T.[ResolutionRemarks] 'Resolution Remarks',T.[TicketDescription] 'Ticket Description',T.[TicketSourceMapID] 'Ticket Source',                            
T.[TicketSummary] 'Ticket Summary', T.[TicketTypeMapID] 'Ticket Type' INTO #Batchinfra                      
FROM ML.AutoClassificationBatchProcess(NOLOCK) M        
INNER JOIN ML.TicketsforAutoClassification(NOLOCK) T ON M.BatchProcessId=T.BatchProcessId                    
WHERE projectid=@ProjectId AND T.SupportType=2                    
                    
--GET NULL                     
DECLARE @GetQuery1 NVARCHAR(MAX)                    
DECLARE @result1 nvarchar(max)                    
SET @GetQuery1=STUFF((SELECT ' ' + ' ' + QUOTENAME(ITSMColumn)  +' IS  NULL'+' OR'    + QUOTENAME(ITSMColumn)  +'= ''' +''''+' OR '                  
           from #tempInfra (NOLOCK)                         
           FOR XML PATH(''), TYPE                          
           ).value('.', 'NVARCHAR(MAX)')                           
           ,1,0,'')                      
                    
SET @result1=' INSERT  into #BatchProcessInfra SELECT * FROM  #Batchinfra(NOLOCK) WHERE '+@GetQuery1+' '                    
SET @result1=(SELECT left(@result1, len(@result1)-2))                    
EXEC sp_executesql @result1;                    
                    
 UPDATE   T  SET T.TimeTickerID=NULL                    
 FROM #TicketUpdated T                    
 JOIN #BatchProcessInfra B   ON B.ticketid=T.TicketID                    
 WHERE B.ticketid=T.TicketID                    
                    
DROP TABLE #tempInfra                    
DROP TABLE #Batchinfra                     
DROP TABLE #BatchProcessInfra                    
END           
 UPDATE ITD SET ITD.IsAttributeUpdated=0 FROM #TRN_InfraTicketDetails ITD  
 LEFT JOIN #TicketUpdated TU ON ITD.TimeTickerID=TU.TimeTickerID  
 WHERE TU.TimeTickerID IS NULL  
   
 UPDATE ITD SET ITD.IsAttributeUpdated=1 FROM #TRN_InfraTicketDetails ITD  
 INNER JOIN #TicketUpdated TU ON ITD.TimeTickerID=TU.TimeTickerID  
  
 UPDATE TD SET TD.IsAttributeUpdated =T1.IsAttributeUpdated, TD.LastUpdatedDate=GETDATE()    
 FROM #TRN_InfraTicketDetails T1    
 INNER JOIN AVL.TK_TRN_InfraTicketDetail TD    
 ON T1.TimeTickerID =TD.TimeTickerID AND T1.ProjectID =TD.ProjectID    
 AND T1.TicketID = TD.TicketID    
    
 UPDATE ATD SET ATD.IsProcessed=1 FROM AVL.TK_TRN_InfraIsAttributeUpdated ATD  
 INNER JOIN #TRN_InfraTicketDetails TD  
 ON ATD.TimeTickerID=TD.TimeTickerID  
  
 --DELETE FROM AVL.TK_TRN_IsAttributeUpdated WHERE Mode=@Mode AND ProjectId=@ProjectId    
 --AND TimeTickerID IN    
 --(SELECT TimeTickerID FROM #TRN_TicketDetails)    
  
END TRY      
    
BEGIN CATCH      
  DECLARE @ErrorMessage VARCHAR(MAX);    
  SELECT @ErrorMessage = ERROR_MESSAGE()      
  EXEC AVL_InsertError '[AVL].[Effort_UpdateTicketIsAttributeFlagByProject]', @ErrorMessage, '',0    
END CATCH      
  SET NOCOUNT OFF;  
END
