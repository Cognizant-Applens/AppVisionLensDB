/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ML].[Infra_GetDebtSamplingDetails] --10337,1
  @ProjectID BIGINT,
  @IsRegenerate BIT
AS 
   BEGIN    
     
      BEGIN TRY     
          DECLARE @CountForTicketValidates INT    
     
          DECLARE @countforoptnull INT    
     
          DECLARE @CountForTicketSampling INT    
     
          DECLARE @countforresnull INT    
     
          DECLARE @OptionalFieldID INT;    
     
          DECLARE @PresenceOfOptional BIT;    
     
          DECLARE  @INIID BIGINT = 0;    
    
    DECLARE @Isdelete INT = 0;    
    
    DECLARE @IsTicketDescriptionOpted BIT=0;    
    
    DECLARE @ILIDCount INT = 0;    
     
 SET @IsTicketDescriptionOpted=(SELECT top 1 ISNULL(IsTicketDescriptionOpted,0) FROM ML.InfraConfigurationProgress WHERE ProjectID=@ProjectID    
         AND IsDeleted = 0 order by ID desc)    
 --Get the Flag for MultiLingual enabled for the project    
 DECLARE @IsMultiLingualEnabled int = 0    
    
 SET @IsMultiLingualEnabled = (SELECT ISNULL(PM.IsMultilingualEnabled,0) FROM AVL.MAS_ProjectMaster PM    
 WHERE PM.ProjectID = @ProjectID    
 AND PM.IsDeleted = 0)    
    
    
 --------------------------------------------------------------    
    
 --Optional field id      
 SET @OptionalFieldID = (SELECT TOP 1    
   IsOptionalField    
  FROM ML.InfraConfigurationProgress    
  WHERE projectid = @ProjectID    
  AND IsDeleted = 0    
  ORDER BY ID DESC)    
 --Regenerated transaction id or not      
    
 --latest initial learning transaction id      
 SET @INIID = (SELECT Max(ID) FROM   ML.InfraConfigurationProgress     
       WHERE  ProjectID = @ProjectID AND IsDeleted = 0     
       AND ISNULL(IsMLSentOrReceived,'') <>'Received')    
    
 SET @ILIDCount = (SELECT COUNT(ID) FROM ML.InfraConfigurationProgress WHERE ProjectID = @ProjectID)    
    
  DECLARE @StartDate DATETIME,@EndDate DATETIME    
  IF(@IsRegenerate = 1)    
  BEGIN    
   SELECT TOP 1 @StartDate=FromDate,@EndDate=ToDate FROM [ML].InfraConfigurationProgress WHERE ProjectID=@ProjectID AND IsDeleted=0 ORDER BY ID DESC    
  END    
  ELSE    
  BEGIN    
   SET @StartDate = (SELECT  MIN(FromDate) from ML.InfraConfigurationProgress WHERE ProjectID=@ProjectID AND IsDeleted=0)     
   SET @EndDate = (SELECT MAX(ToDate) from ML.InfraConfigurationProgress WHERE ProjectID=@ProjectID AND IsDeleted=0)    
  END    
    
 SELECT    
  TD.TicketID    
  ,TD.TowerID    
  ,TD.DebtClassificationMapID    
  ,TD.ResidualDebtMapID    
  ,TD.AvoidableFlag    
  ,TD.CauseCodeMapID    
  ,TD.ResolutionCodeMapID INTO #TmpTicketDetails    
 FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD    
 JOIN ML.InfraTicketValidation(NOLOCK) TV ON TV.TicketID = TD.TicketID    
 JOIN ML.InfraConfigurationProgress CP ON CP.ID = TV.InitialLearningID    
  AND TV.ProjectID = TD.ProjectID    
  WHERE TD.Projectid = @ProjectID    
  AND TD.Isdeleted = 0 AND TV.IsDeleted = 0    
  AND ((@IsTicketDescriptionOpted = 1 AND (TD.DARTStatusID = 8    
  AND TD.Closeddate BETWEEN @StartDate AND @EndDate) OR (TD.DARTStatusID = 9 AND TD.CompletedDateTime BETWEEN @StartDate AND @EndDate))    
  OR (@IsTicketDescriptionOpted = 0))    
  AND  ((@IsRegenerate = 0 AND @ILIDCount = 1)     
  OR (@IsRegenerate = 0 AND @ILIDCount > 1 AND CP.IsMLSentOrReceived = 'Received')      
  OR(@IsRegenerate = 1 AND ISNULL(CP.IsMLSentOrReceived,'') <> 'Received'  AND CP.ID = @INIID))    
 IF (@OptionalFieldID = 0)    
 BEGIN    
  SET @PresenceOfOptional = 0    
 END    
 ELSE    
 BEGIN    
  SET @PresenceOfOptional = 1     
 END    
 --if both counts are equal even if optional field is defined or optional field is not defined      
     
    
 SELECT    
  DISTINCT    
  TD.TicketId    
  ,TV.TicketDescription    
  ,TV.OptionalField AS AdditionalText    
  ,TD.TowerID    
  ,IDTT.TowerName    
  ,DTV.projectid    
  ,TD.debtclassificationmapid AS debtclassificationid    
  ,ATTRFM.debtclassificationname AS DebtClassificationName    
  ,TD.avoidableflag AS avoidableflagid    
  ,ATTRFM1.avoidableflagname AS AvoidableFlagName    
  ,TD.residualdebtmapid AS residualdebtid    
  ,ATTRFM2.[residualdebtname] AS ResidualDebt    
  ,TD.causecodemapid AS causecodeid    
  ,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DeptCC.MCauseCode,'') != '' THEN DeptCC.MCauseCode ELSE DeptCC.CauseCode END AS [CauseCode]    
  ,TD.resolutioncodemapid AS resolutioncodeid    
  ,CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(DRC.MResolutionCode,'') != '' THEN DRC.MResolutionCode ELSE DRC.ResolutionCode END AS [ResolutionCode]     
  ,CASE    
   WHEN DTV.desc_base_workpattern = '0' THEN ''    
   ELSE DTV.desc_base_workpattern    
  END AS TicketDescriptionPattern    
  ,CASE    
   WHEN DTV.desc_sub_workpattern = '0' THEN ''    
   ELSE DTV.desc_sub_workpattern    
  END AS TicketDescriptionSubPattern    
  ,CASE    
   WHEN DTV.res_base_workpattern = '0' THEN ''    
   ELSE DTV.res_base_workpattern    
  END AS RemarksPatternsResolution    
  ,CASE    
   WHEN DTV.res_sub_workpattern = '0' THEN ''    
   ELSE DTV.res_sub_workpattern    
  END AS ResolutionRemarkssubPattern    
  ,OPM.IsOptionalField AS optionalfieldid    
  ,@PresenceOfOptional AS PresenceOfOptioanl    
 FROM #TmpTicketDetails TD    
  JOIN ML.InfraTRN_TicketsAfterSampling(NOLOCK) DTV    
  ON DTV.ticketid = TD.ticketid    
  AND DTV.projectid = @ProjectID    
  AND DTV.isdeleted = 0    
  AND DTV.TowerID = TD.TowerID    
  join ML.InfraTicketValidation TV    
  ON DTV.ticketid = TV.ticketid    
  AND TV.isdeleted = 0    
  AND DTV.isdeleted = 0    
  AND TV.projectid = @ProjectID    
  AND DTV.projectid = @ProjectID    
  join ML.InfraConfigurationProgress OPM    
  ON DTV.projectid = OPM.projectid    
  AND OPM.IsDeleted = 0    
  AND OPM.projectid = @ProjectID    
 LEFT JOIN [AVL].[DEBT_MAS_DebtClassificationInfra] ATTRFM    
  ON ATTRFM.debtclassificationid = TD.DebtClassificationMapID    
 LEFT JOIN AVL.DEBT_MAS_AVOIDABLEFLAG ATTRFM1    
  ON ATTRFM1.avoidableflagid = TD.AvoidableFlag    
 LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] ATTRFM2    
  ON ATTRFM2.residualdebtid = TD.ResidualDebtMapID    
 LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE](NOLOCK) DeptCC    
  ON TD.CauseCodeMapID = DeptCC.causeid    
  AND DeptCC.projectid = @ProjectID    
  AND DeptCC.isdeleted = 0    
 LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE](NOLOCK) DRC    
  ON DRC.resolutionid = TD.ResolutionCodeMapID    
  AND DRC.projectid = @ProjectID    
  AND DRC.isdeleted = 0    
 LEFT JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) IDTT    
  ON TD.TowerID = IDTT.InfraTowerTransactionID    
  AND IDTT.IsDeleted = 0    
 WHERE DTV.projectid = @ProjectID    
 AND DTV.isdeleted = 0    
 AND DTV.desc_base_workpattern <> '0'    
 AND DTV.DebtClassifiedBy = 2    
 AND DTV.InitialLearningId=@INIID    
     
    
  SELECT  CauseID,CauseCode FROM AVL.DEBT_MAP_CauseCode     
  WHERE ProjectID = @ProjectID    
  AND IsDeleted = @Isdelete ORDER BY CauseCode ASC    
    
  --SELECT ResolutionCodeID,ResolutionCodeName FROM AVL.DEBT_MAS_ResolutionCode(NOLOCK)    
    
  SELECT ResolutionID,ResolutionCode FROM AVL.DEBT_MAP_ResolutionCode(NOLOCK)    
  WHERE ProjectID = @ProjectID    
  AND IsDeleted = @Isdelete ORDER BY ResolutionCode ASC    
    
  SELECT DebtClassificationID,DebtClassificationName FROM [AVL].[DEBT_MAS_DebtClassificationInfra](NOLOCK)    
  WHERE IsDeleted = @Isdelete    
    
  SELECT AvoidableFlagID,AvoidableFlagName FROM AVL.DEBT_MAS_AvoidableFlag(NOLOCK)    
  WHERE IsDeleted = @Isdelete    
         
  SELECT ResidualDebtID,ResidualDebtName FROM AVL.DEBT_MAS_ResidualDebt(NOLOCK)    
  WHERE IsDeleted = @Isdelete    
    
  DROP TABLE #TmpTicketDetails    
 END TRY     
    
 BEGIN CATCH    
 DECLARE @ErrorMessage VARCHAR(MAX);    
    
 SELECT    
  @ErrorMessage = ERROR_MESSAGE()    
    
 --INSERT Error          
 EXEC AVL_INSERTERROR '[ML].[Infra_GetDebtSamplingDetails]'    
       ,@ErrorMessage    
       ,@ProjectID    
       ,0    
 END CATCH    
 END
