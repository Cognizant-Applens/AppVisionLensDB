  
/***************************************************************************      
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET      
*Copyright [2018] – [2021] Cognizant. All rights reserved.      
*NOTICE: This unpublished material is proprietary to Cognizant and      
*its suppliers, if any. The methods, techniques and technical      
  concepts herein are considered Cognizant confidential and/or trade secret information.       
        
*This material may be covered by U.S. and/or foreign patents or patent applications.       
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.      
***************************************************************************/      

CREATE PROCEDURE [AVL].[ML_UpdateAPIOutputDebtFields]    
@BatchProcessId Bigint,    
@ProjectID BigInt    
    
AS    
BEGIN    
BEGIN TRY    
DECLARE @SupportType Int;    
DECLARE @UserId VARCHAR(MAX);    
DECLARE @AppAlgorithmKey nvarchar(6);      
  DECLARE @InfraAlgorithmKey nvarchar(6);      
  IF((SELECT Count(AlgorithmKey) FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0) > 0 )    
  BEGIN     
  IF EXISTS(SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=1)    
  BEGIN    
  SET @AppAlgorithmKey = (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=1)    
  END    
  IF EXISTS(SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=2)    
  BEGIN    
  SET @InfraAlgorithmKey = (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@ProjectID AND IsActiveTransaction=1 AND IsDeleted=0 AND SupportTypeId=2)    
  END    
  END    
  ELSE    
  BEGIN    
  SET @AppAlgorithmKey ='AL002'    
  SET @InfraAlgorithmKey='AL002'    
  END               
IF(@AppAlgorithmKey='AL001' OR @InfraAlgorithmKey='AL001')        
BEGIN     
Set @SupportType = (SELECT DISTINCT SupportTypeId FROM ML.DebtAutoClassificationBatchProcess(NOLOCK) WHERE BatchProcessId = @BatchProcessId);    
Set @UserId = (SELECT DISTINCT CreatedBy FROM ML.DebtAutoClassificationBatchProcess(NOLOCK) WHERE BatchProcessId = @BatchProcessId);    
    
                -- SET NOCOUNT ON added to prevent extra result sets from    
                -- interfering with SELECT statements.    
                SET NOCOUNT ON;     
    DECLARE @AutoClassificationType TINYINT;    
    set @AutoClassificationType = (SELECT TOP 1 DebtAttributeId FROM [ML].[ConfigurationProgress] (NOLOCK)    
        WHERE PROJECTID=@ProjectID     
        and IsDeleted=0    
        ORDER BY ID ASC)    
     CREATE TABLE #MLClassification_TicketUpload (    
      [EsaProjectID] [bigint] NOT NULL,    
      [ApplicationID] [bigint] NULL,    
      [Ticket ID] [varchar](50) NOT NULL,    
      [CauseCodeID] [bigint] NULL,    
      [ResolutionCodeID] [bigint] NULL,    
      [DebtClassificationID] INT NULL,    
      [AvoidableID] INT NULL,    
      [ResidualID] INT NULL,    
      [RuleID] [bigint] NULL,    
      [LWRuleID] [bigint] NULL,    
      [LWRuleLevel] [varchar](50) NULL    
     )    
     INSERT INTO #MLClassification_TicketUpload    
     SELECT @ProjectID,ApplicationId,TicketId,    
     CauseCodeId,ResolutionCodeId,    
     DebtClassificationId,AvoidableFlagId,    
     ResidualFlagId,RuleId,LWRuleId,LWRuleLevel    
     FROM     
     --@UpdateAPI_OP_DebtFields    
     ML.TicketsForClassification(NOLOCK)    
     WHERE BatchProcessId = @BatchProcessId     
     AND StatusId in(15,16)    
         
    
IF(@SupportType = 1 AND @AppAlgorithmKey='AL001')    
BEGIN    
                UPDATE AVL.TK_TRN_TicketDetail set DebtClassificationMapID = MR.DebtClassificationId, AvoidableFlag = MR.[AvoidableID],    
                ResidualDebtMapID = MR.[ResidualID],    
    CauseCodeMapID = CASE WHEN @AutoClassificationType = 2 THEN MR.[CauseCodeID] ELSE CauseCodeMapID END,    
    ResolutionCodeMapID = CASE WHEN @AutoClassificationType = 2 THEN MR.[ResolutionCodeID] ELSE ResolutionCodeMapID END,    
    LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE(),    
    ModifiedBy=@UserId    
                from #MLClassification_TicketUpload as MR    
                where AVL.TK_TRN_TicketDetail.TicketID = MR.[Ticket ID] and AVL.TK_TRN_TicketDetail.ProjectID = MR.[EsaProjectID]     
                 and ( MR.[RuleID] <> 0 OR MR.LWRuleID <> 0) 
				 AND ISNULL(AVL.TK_TRN_TicketDetail.DebtClassificationMode,0)<>5	--Restrict Override the Manual tickets
                -- AND ISNULL(AVL.TK_TRN_TicketDetail.DebtClassificationMode,0) NOT IN (2,4)    
    
                SELECT TD.TimeTickerID,ISNULL(MKTU.DebtClassificationId,API.DebtClassificationId) AS 'UserDebtClassification',ISNULL(MKTU.AvoidableFlagID,API.[AvoidableID]) AS 'UserAvoidableFlag',    
                ISNULL(MKTU.ResidualDebtID,API.[ResidualID]) AS 'UserResidualDebt',API.DebtClassificationId AS 'SystemDebtClassification'    
                ,API.[AvoidableID] AS 'SystemAvoidableFlag',API.[ResidualID]  AS 'SystemResidualDebtID',    
    ISNULL(MKTU.CauseCodeID,API.CauseCodeID) AS 'CauseCodeID', ISNULL(MKTU.[Resolution Code ID],API.ResolutionCodeID) AS 'ResolutionCodeID',    
    API.[CauseCodeID] AS 'SystemCauseCodeID', API.[ResolutionCodeID] AS 'SystemResolutionCodeID',    
                CASE    
                WHEN  (API.DebtClassificationId IS NULL OR API.DebtClassificationID=0) AND (API.[AvoidableID] IS NULL or api.AvoidableID=0) AND (API.[ResidualID] IS NULL OR API.ResidualID=0) THEN NULL    
                WHEN (@AutoClassificationType = 1 AND (ISNULL(MKTU.DebtClassificationId,API.DebtClassificationID)=API.DebtClassificationId AND ISNULL(MKTU.AvoidableFlagID,API.AvoidableID)=API.[AvoidableID]     
    AND ISNULL(MKTU.ResidualDebtID,API.ResidualID)=API.[ResidualID])) OR    
      (@AutoClassificationType = 2 AND (ISNULL(MKTU.CauseCodeID,API.CauseCodeID)=API.CauseCodeID AND ISNULL(MKTU.[Resolution Code ID],API.ResolutionCodeID)=API.ResolutionCodeID AND     
      ISNULL(MKTU.DebtClassificationId,API.DebtClassificationID)=API.DebtClassificationId AND ISNULL(MKTU.AvoidableFlagID,API.AvoidableID)=API.[AvoidableID] AND ISNULL(MKTU.ResidualDebtID,API.ResidualID)=API.[ResidualID]))    
 THEN 1    
                ELSE     
                2    
                END AS 'DebtClassificatioMode',2 AS 'SourceMode'    
    
--MKTU.CauseCodeID AS CauseCode,MKTU.[Resolution Code ID] AS ResolutionCode    
    
                    
                INTO #DebtClassfication    
                    
                FROM AVL.TK_TRN_TicketDetail TD JOIN AVL.TK_MLClassification_TicketUpload MKTU ON    
                TD.TicketID=MKTU.[Ticket ID] AND TD.ProjectID=MKTU.ProjectID    
                AND TD.IsDeleted=0 AND TD.ProjectID=@ProjectID    
                JOIN #MLClassification_TicketUpload API ON API.[Ticket ID]=MKTU.[Ticket ID] AND API.[EsaProjectID]=TD.ProjectID    
                WHERE MKTU.SupportType = 1    
                    
    
    
                UPDATE DCM  SET DCM.SystemDebtclassification=MLTK.SystemDebtClassification,DCM.SystemAvoidableFlag=MLTK.SystemAvoidableFlag,    
                DCM.SystemResidualDebtFlag=MLTK.SystemResidualDebtID,DCM.UserDebtClassificationFlag= MLTK.UserDebtClassification     
                    
                ,    
                DCM.UserAvoidableFlag= MLTK.UserAvoidableFlag     
    
   ,DCM.UserResidualDebtFlag= MLTK.UserResidualDebt     
                      
                   ,    
                DCM.DebtClassficationMode=MLTK.DebtClassificatioMode,DCM.SourceForPattern=MLTK.SourceMode,    
                ModifiedDate=GETDATE(),ModifiedBy=@UserId,    
                DCM.CauseCodeID= MLTK.CauseCodeID          ,    
                DCM.ResolutionCodeID=MLTK.ResolutionCodeID,    
    DCM.SystemCauseCodeID= CASE WHEN @AutoClassificationType = 2 THEN MLTK.SystemCauseCodeID ELSE DCM.SystemCauseCodeID END          ,    
                DCM.SystemResolutionCodeID=CASE WHEN @AutoClassificationType = 2 THEN MLTK.SystemResolutionCodeID ELSE DCM.SystemResolutionCodeID END    
    FROM    
                AVL.TRN_DebtClassificationModeDetails DCM JOIN #DebtClassfication MLTK    
                ON MLTK.TimeTickerID=DCM.TimeTickerID and DCM.Isdeleted=0    
               
    
                INSERT INTO AVL.TRN_DebtClassificationModeDetails    
(TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,    
                DebtClassficationMode,SourceForPattern,CreatedDate,CreatedBy,Isdeleted,CauseCodeID,ResolutionCodeID,SystemCauseCodeID,SystemResolutionCodeID    
                )    
                SELECT MLTK.TimeTickerID,MLTK.SystemDebtClassification,MLTK.SystemAvoidableFlag,MLTK.SystemResidualDebtID,MLTK.UserDebtClassification    
    ,MLTK.UserAvoidableFlag,MLTK.UserResidualDebt,MLTK.DebtClassificatioMode,MLTK.SourceMode,GETDATE(),@UserId,0,MLTK.CauseCodeID,MLTK.ResolutionCodeID,    
    CASE WHEN @AutoClassificationType = 2 THEN MLTK.SystemCauseCodeID ELSE NULL END,    
    CASE WHEN @AutoClassificationType = 2 THEN MLTK.SystemResolutionCodeID ELSE NULL END    
    FROM AVL.TRN_DebtClassificationModeDetails DCM RIGHT JOIN #DebtClassfication MLTK    
                ON MLTK.TimeTickerID=DCM.TimeTickerID and DCM.Isdeleted=0    
                WHERE DCM.ID IS NULL     
                AND MLTK.DebtClassificatioMode IS NOT NULL    
    
                UPDATE TD SET TD.DebtClassificationMode =DCMD.DebtClassficationMode,    
    TD.LastUpdatedDate=GETDATE(),TD.ModifiedDate=GETDATE(),    
    TD.ModifiedBy=@UserId    
                FROM AVL.TK_TRN_TicketDetail TD JOIN #DebtClassfication MLTK    
                ON MLTK.TimeTickerID=TD.TimeTickerID and TD.Isdeleted=0 AND TD.ProjectID=@ProjectID    
                JOIN AVL.TRN_DebtClassificationModeDetails DCMD ON DCMD.TimeTickerID=TD.TimeTickerID AND DCMD.Isdeleted=0 
				AND ISNULL(TD.DebtClassificationMode,0)<>5	--Restrict Override the Manual tickets
    
    
                UPDATE AVL.TK_MLClassification_TicketUpload set DebtClassificationId = MR.[DebtClassificationID], AvoidableFlagID = MR.[AvoidableID],    
                ResidualDebtID = MR.[ResidualID], [Rule ID]= MR.[RuleID],    
    CauseCodeID = CASE WHEN @AutoClassificationType = 2 THEN MR.CauseCodeID ELSE AVL.TK_MLClassification_TicketUpload.CauseCodeID END,    
    [Resolution Code ID] = CASE WHEN @AutoClassificationType = 2 THEN MR.ResolutionCodeID ELSE AVL.TK_MLClassification_TicketUpload.[Resolution Code ID] END    
                from #MLClassification_TicketUpload as MR    
                where MR.[Ticket ID] = AVL.TK_MLClassification_TicketUpload.[Ticket ID]    
                and MR.[EsaProjectID] = AVL.TK_MLClassification_TicketUpload.ProjectID and (MR.[RuleID] <> 0 OR MR.LWRuleID <> 0)    
    
        
                DELETE from AVL.TK_TRN_TicketDetail_RuleId where TimeTickerID in (select td.TimeTickerID from #MLClassification_TicketUpload as MR    
                INNER join AVL.TK_TRN_TicketDetail td on td.TicketID = MR.[Ticket ID] and td.ProjectID = MR.[EsaProjectID]    
                where MR.[Ticket ID] = td.TicketID and MR.[EsaProjectID] = td.ProjectID and ( MR.[RuleID] <> 0 OR MR.LWRuleID <> 0))    
        
                insert into AVL.TK_TRN_TicketDetail_RuleId    
                select td.TimeTickerID,MR.[RuleID],td.CreatedBy,GETDATE(),LWRuleID,LWRuleLevel,NULL,NULL    
                from #MLClassification_TicketUpload as MR    
                INNER join AVL.TK_TRN_TicketDetail td on td.TicketID = MR.[Ticket ID] and td.ProjectID = MR.[EsaProjectID]    
                where MR.[Ticket ID] = td.TicketID and MR.[EsaProjectID] = td.ProjectID and ( MR.[RuleID] <> 0 OR MR.LWRuleID <> 0) --and td.TimeTickerID not in (select TimetickerID from AVL.TK_TRN_TicketDetail_RuleId)    
    
                      
    
               select DISTINCT        
    ML.[Ticket ID],            
                ML.ProjectID,            
                ML.ApplicationID,            
                ML.ApplicationName,   
                ML.[Ticket Description],            
                ML.[Additional Text],            
                ML.CauseCodeID,            
                ML.[Cause code],            
                ML.[Resolution Code ID],            
                ML.[Resolution Code],            
                ML.[Rule ID] from AVL.TK_MLClassification_TicketUpload(NOLOCK) ML              
                JOIN ML.TicketsForClassification TC ON ML.[Ticket ID] = TC.TicketId AND TC.StatusId IN (14,15,16)          
                JOIN ML.DebtAutoClassificationBatchProcess DCBP ON ML.ProjectID = DCBP.ProjectId AND DCBP.BatchProcessId = TC.BatchProcessId              
                where ML.[Rule ID] is NULL AND ML.ProjectID=@ProjectID AND TC.BatchProcessId = @BatchProcessId AND ML.SupportType = 1     
END    
IF(@SupportType=2 AND @InfraAlgorithmKey='AL001')    
BEGIN    
set @AutoClassificationType = (SELECT TOP 1 DebtAttributeId FROM [ML].[InfraConfigurationProgress] (NOLOCK)      
        WHERE PROJECTID=@ProjectID       
        and IsDeleted=0      
        ORDER BY ID ASC)    
    
                UPDATE AVL.TK_TRN_InfraTicketDetail set DebtClassificationMapID = MR.DebtClassificationId, AvoidableFlag = MR.[AvoidableID],    
                ResidualDebtMapID = MR.[ResidualID],    
  CauseCodeMapID = CASE WHEN @AutoClassificationType = 2 THEN MR.[CauseCodeID] ELSE CauseCodeMapID END,    
    ResolutionCodeMapID = CASE WHEN @AutoClassificationType = 2 THEN MR.[ResolutionCodeID] ELSE ResolutionCodeMapID END,    
    LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE(),    
    ModifiedBy=@UserId    
                from #MLClassification_TicketUpload as MR    
                where AVL.TK_TRN_InfraTicketDetail.TicketID = MR.[Ticket ID] and AVL.TK_TRN_InfraTicketDetail.ProjectID = MR.[EsaProjectID]     
                 and (MR.[RuleID] <> 0 OR MR.LWRuleID <> 0) 
				 AND ISNULL(AVL.TK_TRN_InfraTicketDetail.DebtClassificationMode,0)<>5	--Restrict Override the Manual tickets
                -- AND ISNULL(AVL.TK_TRN_TicketDetail.DebtClassificationMode,0) NOT IN (2,4)    
    
                SELECT TD.TimeTickerID,ISNULL(MKTU.DebtClassificationId,API.DebtClassificationId) AS 'UserDebtClassification',ISNULL(MKTU.AvoidableFlagID,API.[AvoidableID]) AS 'UserAvoidableFlag',    
                ISNULL(MKTU.ResidualDebtID,API.[ResidualID]) AS 'UserResidualDebt',API.DebtClassificationId AS 'SystemDebtClassification'    
                ,API.[AvoidableID] AS 'SystemAvoidableFlag',API.[ResidualID]  AS 'SystemResidualDebtID',    
    ISNULL(MKTU.CauseCodeID,API.CauseCodeID) AS 'CauseCodeID', ISNULL(MKTU.[Resolution Code ID],API.ResolutionCodeID) AS 'ResolutionCodeID',    
    API.[CauseCodeID] AS 'SystemCauseCodeID', API.[ResolutionCodeID] AS 'SystemResolutionCodeID',    
                CASE    
                WHEN  (API.DebtClassificationId IS NULL OR API.DebtClassificationID=0) AND (API.[AvoidableID] IS NULL or api.AvoidableID=0) AND (API.[ResidualID] IS NULL OR API.ResidualID=0) THEN NULL    
                WHEN (@AutoClassificationType = 1 AND (ISNULL(MKTU.DebtClassificationId,API.DebtClassificationID)=API.DebtClassificationId AND ISNULL(MKTU.AvoidableFlagID,API.AvoidableID)=API.[AvoidableID]     
    AND ISNULL(MKTU.ResidualDebtID,API.ResidualID)=API.[ResidualID])) OR    
      (@AutoClassificationType = 2 AND (ISNULL(MKTU.CauseCodeID,API.CauseCodeID)=API.CauseCodeID AND ISNULL(MKTU.[Resolution Code ID],API.ResolutionCodeID)=API.ResolutionCodeID AND     
      ISNULL(MKTU.DebtClassificationId,API.DebtClassificationID)=API.DebtClassificationId AND ISNULL(MKTU.AvoidableFlagID,API.AvoidableID)=API.[AvoidableID] AND ISNULL(MKTU.ResidualDebtID,API.ResidualID)=API.[ResidualID]))    
 THEN 1    
                ELSE     
                2    
                END AS 'DebtClassificatioMode',2 AS 'SourceMode'    
    
               -- MKTU.CauseCodeID AS CauseCode,MKTU.[Resolution Code ID] AS ResolutionCode    
    
                    
                INTO #DebtClassficationInfra    
                    
                FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD JOIN AVL.TK_MLClassification_TicketUpload(NOLOCK) MKTU ON    
                TD.TicketID=MKTU.[Ticket ID] AND TD.ProjectID=MKTU.ProjectID    
                AND TD.IsDeleted=0 AND TD.ProjectID=@ProjectID    
                JOIN #MLClassification_TicketUpload API ON API.[Ticket ID]=MKTU.[Ticket ID] AND API.[EsaProjectID]=TD.ProjectID    
                WHERE MKTU.SupportType = 2    
                    
    
    
                UPDATE DCM  SET DCM.SystemDebtclassification=MLTK.SystemDebtClassification,DCM.SystemAvoidableFlag=MLTK.SystemAvoidableFlag,    
                DCM.SystemResidualDebtFlag=MLTK.SystemResidualDebtID,DCM.UserDebtClassificationFlag= MLTK.UserDebtClassification     
                    
                ,    
                DCM.UserAvoidableFlag= MLTK.UserAvoidableFlag     
    
                  ,DCM.UserResidualDebtFlag= MLTK.UserResidualDebt     
                      
                   ,    
                DCM.DebtClassficationMode=MLTK.DebtClassificatioMode,DCM.SourceForPattern=MLTK.SourceMode,    
                DCM.ModifiedDate=GETDATE(),DCM.ModifiedBy=@UserId,    
                DCM.CauseCodeID= MLTK.CauseCodeID          ,    
                DCM.ResolutionCodeID=MLTK.ResolutionCodeID,    
    DCM.SystemCauseCodeID= CASE WHEN @AutoClassificationType = 2 THEN MLTK.SystemCauseCodeID ELSE DCM.SystemCauseCodeID END          ,    
                DCM.SystemResolutionCodeID=CASE WHEN @AutoClassificationType = 2 THEN MLTK.SystemResolutionCodeID ELSE DCM.SystemResolutionCodeID END    
    FROM    
                AVL.TRN_InfraDebtClassificationModeDetails DCM JOIN #DebtClassficationInfra MLTK    
                ON MLTK.TimeTickerID=DCM.TimeTickerID and DCM.Isdeleted=0    
                    
    
                INSERT INTO AVL.TRN_InfraDebtClassificationModeDetails    
(TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,    
                DebtClassficationMode,SourceForPattern,CreatedDate,CreatedBy,Isdeleted,CauseCodeID,ResolutionCodeID,SystemCauseCodeID,SystemResolutionCodeID    
                )    
                SELECT MLTK.TimeTickerID,MLTK.SystemDebtClassification,MLTK.SystemAvoidableFlag,MLTK.SystemResidualDebtID,MLTK.UserDebtClassification    
,MLTK.UserAvoidableFlag,MLTK.UserResidualDebt,MLTK.DebtClassificatioMode,MLTK.SourceMode,GETDATE(),@UserId,0,MLTK.CauseCodeID,MLTK.ResolutionCodeID,    
    CASE WHEN @AutoClassificationType = 2 THEN MLTK.SystemCauseCodeID ELSE NULL END,    
    CASE WHEN @AutoClassificationType = 2 THEN MLTK.SystemResolutionCodeID ELSE NULL END    
FROM AVL.TRN_InfraDebtClassificationModeDetails DCM RIGHT JOIN #DebtClassficationInfra MLTK    
                ON MLTK.TimeTickerID=DCM.TimeTickerID and DCM.Isdeleted=0    
                WHERE DCM.ID IS NULL     
                AND MLTK.DebtClassificatioMode IS NOT NULL    
    
                UPDATE TD SET TD.DebtClassificationMode =DCMD.DebtClassficationMode,    
    TD.LastUpdatedDate=GETDATE(),TD.ModifiedDate=GETDATE(),    
    TD.ModifiedBy=@UserId    
                FROM AVL.TK_TRN_InfraTicketDetail TD JOIN #DebtClassficationInfra MLTK    
                ON MLTK.TimeTickerID=TD.TimeTickerID and TD.Isdeleted=0 AND TD.ProjectID=@ProjectID    
                JOIN AVL.TRN_InfraDebtClassificationModeDetails DCMD ON DCMD.TimeTickerID=TD.TimeTickerID AND DCMD.Isdeleted=0 
				AND ISNULL(TD.DebtClassificationMode,0)<>5	--Restrict Override the Manual tickets
    
                UPDATE AVL.TK_MLClassification_TicketUpload set DebtClassificationId = MR.[DebtClassificationID], AvoidableFlagID = MR.[AvoidableID],    
                ResidualDebtID = MR.[ResidualID], [Rule ID]= MR.[RuleID],    
    CauseCodeID = CASE WHEN @AutoClassificationType = 2 THEN MR.CauseCodeID ELSE AVL.TK_MLClassification_TicketUpload.CauseCodeID END,    
    [Resolution Code ID] = CASE WHEN @AutoClassificationType = 2 THEN MR.ResolutionCodeID ELSE AVL.TK_MLClassification_TicketUpload.[Resolution Code ID] END    
                from #MLClassification_TicketUpload as MR    
                where MR.[Ticket ID] = AVL.TK_MLClassification_TicketUpload.[Ticket ID]    
                and MR.[EsaProjectID] = AVL.TK_MLClassification_TicketUpload.ProjectID and (MR.[RuleID] <> 0 OR MR.LWRuleID <> 0)    
    
                DELETE from AVL.TK_TRN_InfraTicketDetail_RuleID where TimeTickerID in (select td.TimeTickerID from #MLClassification_TicketUpload as MR    
                INNER join AVL.TK_TRN_InfraTicketDetail td on td.TicketID = MR.[Ticket ID] and td.ProjectID = MR.[EsaProjectID]    
                where MR.[Ticket ID] = td.TicketID and MR.[EsaProjectID] = td.ProjectID and (MR.[RuleID] <> 0 OR MR.LWRuleID <> 0))    
    
                insert into AVL.TK_TRN_InfraTicketDetail_RuleID    
                select td.TimeTickerID,MR.[RuleID],td.CreatedBy,GETDATE(),LWRuleID,LWRuleLevel,NULL,NULL    
                from #MLClassification_TicketUpload as MR    
                INNER join AVL.TK_TRN_InfraTicketDetail td on td.TicketID = MR.[Ticket ID] and td.ProjectID = MR.[EsaProjectID]    
                where MR.[Ticket ID] = td.TicketID and MR.[EsaProjectID] = td.ProjectID and (MR.[RuleID] <> 0 OR MR.LWRuleID <>0)     
    
                      
    
               select DISTINCT        
    ML.[Ticket ID],            
                ML.ProjectID,            
                ML.ApplicationID,            
                ML.ApplicationName,            
                ML.[Ticket Description],            
                ML.[Additional Text],            
                ML.CauseCodeID,            
                ML.[Cause code],            
                ML.[Resolution Code ID],            
                ML.[Resolution Code],            
                ML.[Rule ID] from AVL.TK_MLClassification_TicketUpload(NOLOCK) ML             
    JOIN ML.TicketsForClassification(NOLOCK) TC ON ML.[Ticket ID] = TC.TicketId AND TC.StatusId IN (14,15,16)          
    JOIN ML.DebtAutoClassificationBatchProcess(NOLOCK) DCBP ON ML.ProjectID = DCBP.ProjectId AND DCBP.BatchProcessId = TC.BatchProcessId              
                where ML.[Rule ID] is NULL AND ML.ProjectID=@ProjectID AND TC.BatchProcessId = @BatchProcessId AND ML.SupportType = 2    
    
    
END    
    
UPDATE ML  SET StatusId = 17    
FROM ML.TicketsForClassification ML    
JOIN #MLClassification_TicketUpload MLT    
ON MLT.[Ticket ID] = ML.TicketId    
    
UPDATE ML.DebtAutoClassificationBatchProcess SET StatusId = 17 WHERE BatchProcessId = @BatchProcessId    
END    
IF(@AppAlgorithmKey='AL002' OR @InfraAlgorithmKey='AL002')              
BEGIN              
 DECLARE @SupportTypeString NVARCHAR(60);              
 Set @SupportTypeString = STUFF((SELECT distinct''+''+cast(SupportType as varchar(20))+',' FROM ML.TicketsforAutoClassification(NOLOCK) WHERE BatchProcessId = @BatchProcessId FOR XML PATH(''), TYPE              
    ).value('.', 'NVARCHAR(MAX)')              
    ,1,0,'')                
 Set @UserId = (SELECT DISTINCT CreatedBy FROM ML.AutoClassificationBatchProcess(NOLOCK) WHERE BatchProcessId = @BatchProcessId);                
 ----              
     CREATE TABLE #MLClassification_TicketUpload1 (                
      [EsaProjectID] [bigint] NOT NULL,                
      [ApplicationID] [bigint] NULL,                
      [Ticket ID] [varchar](50) NOT NULL,                
      [CauseCodeID] [bigint] NULL,                
      [ResolutionCodeID] [bigint] NULL,                
      [DebtClassificationID] INT NULL,                
      [AvoidableID] INT NULL,                
      [ResidualID] INT NULL,                
      [ClusterID_Desc] INT NULL,            
      [ClusterID_Resolution] INT NULL,    
      [SupportType] INT NULL    
     )                
     INSERT INTO #MLClassification_TicketUpload1               
     SELECT @ProjectID,ApplicationId,TicketId,                
     CauseCodeMapID,ResolutionCodeMapID,                
     DebtClassificationId,AvoidableFlagId,                
     ResidualFlagId,            
     ClusterID_Desc,            
     ClusterID_Resolution,    
     SupportType    
 FROM                 
     ML.TicketsforAutoClassification(NOLOCK)                
     WHERE BatchProcessId = @BatchProcessId                 
     AND StatusId in(15,16)                
IF(@SupportTypeString LIKE '%1%' AND @AppAlgorithmKey='AL002')                 
 BEGIN                
               
 UPDATE AVL.TK_TRN_TicketDetail set DebtClassificationMapID = MR.DebtClassificationId, AvoidableFlag = MR.[AvoidableID],                
                ResidualDebtMapID = MR.[ResidualID],                
    LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE(),                
    ModifiedBy=@UserId                
                from #MLClassification_TicketUpload1 as MR                
                where AVL.TK_TRN_TicketDetail.TicketID = MR.[Ticket ID] and AVL.TK_TRN_TicketDetail.ProjectID = MR.[EsaProjectID]                 
    AND (ISNULL(MR.[ClusterID_Desc],0)<>0 OR ISNULL(MR.[ClusterID_Resolution],0)<>0) 
	AND ISNULL(AVL.TK_TRN_TicketDetail.DebtClassificationMode,0) <>5	--Restrict Override the Manual tickets
              
 SELECT TD.TimeTickerID,API.DebtClassificationId AS 'UserDebtClassification',API.[AvoidableID] AS 'UserAvoidableFlag',                    
                API.[ResidualID] AS 'UserResidualDebt',API.DebtClassificationId AS 'SystemDebtClassification'                    
                ,API.[AvoidableID] AS 'SystemAvoidableFlag',API.[ResidualID]  AS 'SystemResidualDebtID',                    
    API.CauseCodeID AS 'CauseCodeID', API.ResolutionCodeID AS 'ResolutionCodeID',                    
    API.[CauseCodeID] AS 'SystemCauseCodeID', API.[ResolutionCodeID] AS 'SystemResolutionCodeID',                    
                CASE                    
                WHEN  (API.DebtClassificationId IS NULL OR API.DebtClassificationID=0) AND (API.[AvoidableID] IS NULL or api.AvoidableID=0) AND (API.[ResidualID] IS NULL OR API.ResidualID=0) THEN NULL                    
                ELSE                   
                1                    
                END AS 'DebtClassificatioMode',2 AS 'SourceMode'                    
 INTO #DebtClassfication1                    
                                    
                FROM AVL.TK_TRN_TicketDetail TD JOIN #MLClassification_TicketUpload1 API ON                    
                TD.TicketID=API.[Ticket ID] AND TD.ProjectID=API.[EsaProjectID]                  
                AND TD.IsDeleted=0 AND TD.ProjectID=@ProjectID                    
                WHERE API.SupportType = 1            
              
 UPDATE DCM  SET DCM.SystemDebtclassification=MLTK.SystemDebtClassification,DCM.SystemAvoidableFlag=MLTK.SystemAvoidableFlag,                
 DCM.SystemResidualDebtFlag=MLTK.SystemResidualDebtID,DCM.UserDebtClassificationFlag= MLTK.UserDebtClassification,                
                DCM.UserAvoidableFlag= MLTK.UserAvoidableFlag,              
    DCM.UserResidualDebtFlag= MLTK.UserResidualDebt,                
                DCM.DebtClassficationMode=MLTK.DebtClassificatioMode,DCM.SourceForPattern=MLTK.SourceMode,                
                ModifiedDate=GETDATE(),ModifiedBy=@UserId,                
                DCM.CauseCodeID= MLTK.CauseCodeID,                
                DCM.ResolutionCodeID=MLTK.ResolutionCodeID,                
    DCM.SystemCauseCodeID=MLTK.SystemCauseCodeID,                
                DCM.SystemResolutionCodeID=MLTK.SystemResolutionCodeID                
    FROM                
                AVL.TRN_DebtClassificationModeDetails DCM JOIN #DebtClassfication1 MLTK                
                ON MLTK.TimeTickerID=DCM.TimeTickerID and DCM.Isdeleted=0                
              
 INSERT INTO AVL.TRN_DebtClassificationModeDetails                
    (TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,                
                DebtClassficationMode,SourceForPattern,CreatedDate,CreatedBy,Isdeleted,CauseCodeID,ResolutionCodeID,SystemCauseCodeID,SystemResolutionCodeID                
                )                
                SELECT MLTK.TimeTickerID,MLTK.SystemDebtClassification,MLTK.SystemAvoidableFlag,MLTK.SystemResidualDebtID,MLTK.UserDebtClassification                
     ,MLTK.UserAvoidableFlag,MLTK.UserResidualDebt,MLTK.DebtClassificatioMode,MLTK.SourceMode,GETDATE(),@UserId,0,MLTK.CauseCodeID,MLTK.ResolutionCodeID,                
     MLTK.SystemCauseCodeID ,                
     MLTK.SystemResolutionCodeID                
     FROM AVL.TRN_DebtClassificationModeDetails DCM RIGHT JOIN #DebtClassfication1 MLTK                
     ON MLTK.TimeTickerID=DCM.TimeTickerID and DCM.Isdeleted=0                
     WHERE DCM.ID IS NULL                 
     AND MLTK.DebtClassificatioMode IS NOT NULL                
                 
    UPDATE TD SET TD.DebtClassificationMode =DCMD.DebtClassficationMode,                
                TD.LastUpdatedDate=GETDATE(),TD.ModifiedDate=GETDATE(),                
                TD.ModifiedBy=@UserId                
                FROM AVL.TK_TRN_TicketDetail TD JOIN #DebtClassfication1 MLTK                
                ON MLTK.TimeTickerID=TD.TimeTickerID and TD.Isdeleted=0 AND TD.ProjectID=@ProjectID                
                JOIN AVL.TRN_DebtClassificationModeDetails DCMD ON DCMD.TimeTickerID=TD.TimeTickerID AND DCMD.Isdeleted=0 
				AND ISNULL(TD.DebtClassificationMode,0)<>5	--Restrict Override the Manual tickets
                    
                DELETE from AVL.TK_TRN_TicketDetail_RuleId where TimeTickerID in (select td.TimeTickerID from #MLClassification_TicketUpload1 as MR                
                INNER join AVL.TK_TRN_TicketDetail td on td.TicketID = MR.[Ticket ID] and td.ProjectID = MR.[EsaProjectID]                
                where MR.[Ticket ID] = td.TicketID and MR.[EsaProjectID] = td.ProjectID AND (ISNULL(MR.[ClusterID_Desc],0)<>0 OR ISNULL(MR.[ClusterID_Resolution],0)<>0))             
                    
                insert into AVL.TK_TRN_TicketDetail_RuleId  (TimeTickerID, Createdby,CreatedDate,[ClusterID_Desc],[ClusterID_Resolution])               
                select td.TimeTickerID            
                ,td.CreatedBy,GETDATE(),            
                [ClusterID_Desc],            
                [ClusterID_Resolution]            
                from #MLClassification_TicketUpload1 as MR                
                INNER join AVL.TK_TRN_TicketDetail td on td.TicketID = MR.[Ticket ID] and td.ProjectID = MR.[EsaProjectID]                
                where MR.[Ticket ID] = td.TicketID and MR.[EsaProjectID] = td.ProjectID AND (ISNULL(MR.[ClusterID_Desc],0)<>0 OR ISNULL(MR.[ClusterID_Resolution],0)<>0)       
                
 END              
 ------Infra------                
 IF(@SupportTypeString LIKE '%2%' AND @InfraAlgorithmKey='AL002')            
 BEGIN                
                
                UPDATE AVL.TK_TRN_InfraTicketDetail set DebtClassificationMapID = MR.DebtClassificationId, AvoidableFlag = MR.[AvoidableID],                
                ResidualDebtMapID = MR.[ResidualID],                
                LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE(),                
                ModifiedBy=@UserId                
                from #MLClassification_TicketUpload1 as MR                
                where AVL.TK_TRN_InfraTicketDetail.TicketID = MR.[Ticket ID] and AVL.TK_TRN_InfraTicketDetail.ProjectID = MR.[EsaProjectID]                 
    AND (ISNULL(MR.[ClusterID_Desc],0)<>0 OR ISNULL(MR.[ClusterID_Resolution],0)<>0) 
	AND (ISNULL(AVL.TK_TRN_InfraTicketDetail.DebtClassificationMode,0) <>5)	--Restrict Override the Manual tickets
                -- AND ISNULL(AVL.TK_TRN_TicketDetail.DebtClassificationMode,0) NOT IN (2,4)                
                
                SELECT TD.TimeTickerID,API.DebtClassificationId AS 'UserDebtClassification',API.[AvoidableID] AS 'UserAvoidableFlag',                    
                        API.[ResidualID] AS 'UserResidualDebt',API.DebtClassificationId AS 'SystemDebtClassification'                  
                        ,API.[AvoidableID] AS 'SystemAvoidableFlag',API.[ResidualID]  AS 'SystemResidualDebtID',                    
                        API.CauseCodeID AS 'CauseCodeID', API.ResolutionCodeID AS 'ResolutionCodeID',                    
                        API.[CauseCodeID] AS 'SystemCauseCodeID', API.[ResolutionCodeID] AS 'SystemResolutionCodeID',                    
                        CASE                    
                        WHEN  (API.DebtClassificationId IS NULL OR API.DebtClassificationID=0) AND (API.[AvoidableID] IS NULL or api.AvoidableID=0) AND (API.[ResidualID] IS NULL OR API.ResidualID=0) THEN NULL                    
                                            
                        ELSE                     
                        1                   
                        END AS 'DebtClassificatioMode',2 AS 'SourceMode'                    
                    
                INTO #DebtClassficationInfra1                    
                                    
                FROM AVL.TK_TRN_InfraTicketDetail TD JOIN #MLClassification_TicketUpload1 API ON                    
                    TD.TicketID=API.[Ticket ID] AND TD.ProjectID=API.[EsaProjectID]                   
                    AND TD.IsDeleted=0 AND TD.ProjectID=@ProjectID                    
                WHERE API.SupportType = 2                    
                                
                
                
                UPDATE DCM  SET DCM.SystemDebtclassification=MLTK.SystemDebtClassification,DCM.SystemAvoidableFlag=MLTK.SystemAvoidableFlag,                
                DCM.SystemResidualDebtFlag=MLTK.SystemResidualDebtID,DCM.UserDebtClassificationFlag= MLTK.UserDebtClassification ,                
                DCM.UserAvoidableFlag= MLTK.UserAvoidableFlag ,DCM.UserResidualDebtFlag= MLTK.UserResidualDebt ,                
                DCM.DebtClassficationMode=MLTK.DebtClassificatioMode,DCM.SourceForPattern=MLTK.SourceMode,                
                DCM.ModifiedDate=GETDATE(),DCM.ModifiedBy=@UserId,                
                DCM.CauseCodeID= MLTK.CauseCodeID          ,                
                DCM.ResolutionCodeID=MLTK.ResolutionCodeID,                
                DCM.SystemCauseCodeID= MLTK.SystemCauseCodeID ,                
                DCM.SystemResolutionCodeID=MLTK.SystemResolutionCodeID                
    FROM                
                AVL.TRN_InfraDebtClassificationModeDetails DCM JOIN #DebtClassficationInfra1 MLTK                
                ON MLTK.TimeTickerID=DCM.TimeTickerID and DCM.Isdeleted=0                
                                
                INSERT INTO AVL.TRN_InfraDebtClassificationModeDetails                
       (TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,                
       DebtClassficationMode,SourceForPattern,CreatedDate,CreatedBy,Isdeleted,CauseCodeID,ResolutionCodeID,SystemCauseCodeID,SystemResolutionCodeID                
       )               
                SELECT MLTK.TimeTickerID,MLTK.SystemDebtClassification,MLTK.SystemAvoidableFlag,MLTK.SystemResidualDebtID,MLTK.UserDebtClassification                
      ,MLTK.UserAvoidableFlag,MLTK.UserResidualDebt,MLTK.DebtClassificatioMode,MLTK.SourceMode,GETDATE(),@UserId,0,MLTK.CauseCodeID,MLTK.ResolutionCodeID,                
      MLTK.SystemCauseCodeID ,                
      MLTK.SystemResolutionCodeID             
      FROM AVL.TRN_InfraDebtClassificationModeDetails DCM RIGHT JOIN #DebtClassficationInfra1 MLTK                
      ON MLTK.TimeTickerID=DCM.TimeTickerID and DCM.Isdeleted=0                
      WHERE DCM.ID IS NULL                 
      AND MLTK.DebtClassificatioMode IS NOT NULL                
                
        UPDATE TD SET TD.DebtClassificationMode =DCMD.DebtClassficationMode,                
               TD.LastUpdatedDate=GETDATE(),TD.ModifiedDate=GETDATE(),                
               TD.ModifiedBy=@UserId                
       FROM AVL.TK_TRN_InfraTicketDetail TD JOIN #DebtClassficationInfra1 MLTK                
               ON MLTK.TimeTickerID=TD.TimeTickerID and TD.Isdeleted=0 AND TD.ProjectID=@ProjectID                
               JOIN AVL.TRN_InfraDebtClassificationModeDetails DCMD ON DCMD.TimeTickerID=TD.TimeTickerID AND DCMD.Isdeleted=0 
			   AND ISNULL(TD.DebtClassificationMode,0)<>5	--Restrict Override the Manual tickets
                
                DELETE from AVL.TK_TRN_InfraTicketDetail_RuleID where TimeTickerID in (select td.TimeTickerID from #MLClassification_TicketUpload1 as MR                
                INNER join AVL.TK_TRN_InfraTicketDetail td on td.TicketID = MR.[Ticket ID] and td.ProjectID = MR.[EsaProjectID]                
                where MR.[Ticket ID] = td.TicketID and MR.[EsaProjectID] = td.ProjectID AND (ISNULL(MR.[ClusterID_Desc],0)<>0 OR ISNULL(MR.[ClusterID_Resolution],0)<>0))--and (MR.[RuleID] <> 0 OR MR.LWRuleID <> 0))                
                
                insert into AVL.TK_TRN_InfraTicketDetail_RuleID(TimeTickerID, Createdby,CreatedDate,ClusterID_Desc,ClusterID_Resolution)            
                select td.TimeTickerID,            
                td.CreatedBy,GETDATE(),            
                    [ClusterID_Desc],            
                    [ClusterID_Resolution]            
                from #MLClassification_TicketUpload1 as MR                
                    INNER join AVL.TK_TRN_InfraTicketDetail td on td.TicketID = MR.[Ticket ID] and td.ProjectID = MR.[EsaProjectID]                
                    where MR.[Ticket ID] = td.TicketID and MR.[EsaProjectID] = td.ProjectID AND (ISNULL(MR.[ClusterID_Desc],0)<>0 OR ISNULL(MR.[ClusterID_Resolution],0)<>0) --and (MR.[RuleID] <> 0 OR MR.LWRuleID <>0)                 
        END    

		update ML set ML.CauseCodeMapID=TD.CauseCodeMapID,ML.ResolutionCodeMapID=TD.ResolutionCodeMapID,ML.ModifiedBy='ML Job' from 
			ML.TicketsforAutoClassification ML join [AVL].[TK_TRN_TicketDetail] TD ON ML.TicketId=TD.Ticketid AND TD.ProjectId=@ProjectId 
			JOIN ML.AutoClassificationBatchProcess(NOLOCK) AC ON AC.BatchProcessId = ML.BatchProcessId AND AC.ProjectId=TD.ProjectId 
			where AC.ProjectId=@ProjectId AND ML.BatchProcessId = @BatchProcessId AND ML.SupportType = 1 

    select DISTINCT                        
                ML.[TicketId],                            
                AC.ProjectId,                            
                ML.ApplicationID,                            
                (SELECT TOP 1 AD.ApplicationName from [AVL].[APP_MAP_ApplicationProjectMapping] APM            
    Join [AVL].[APP_MAS_ApplicationDetails] AD on APM.ApplicationID = AD.ApplicationID                    
    where APM.projectID = @ProjectID and APM.isdeleted = 0) as 'ApplicationName',                            
                ML.[TicketDescription],                            
                ML.[ClusterID_Desc]                
    from ML.TicketsforAutoClassification(NOLOCK) ML                             
            JOIN ML.AutoClassificationBatchProcess(NOLOCK) AC ON AC.BatchProcessId = ML.BatchProcessId AND (ML.StatusId IN (14,15,16) OR (ISNULL(AC.TransactionIdApp,0)=0 AND ISNULL(AC.TransactionIdInfra,0)=0)) WHERE                             
            (ISNULL(ML.[ClusterID_Desc],0)=0 AND ISNULL(ML.[ClusterID_Resolution],0)=0) AND               
            AC.ProjectId=@ProjectID AND ML.BatchProcessId = @BatchProcessid AND ML.SupportType = 1        
  UNION        
    select DISTINCT                    
                ML.[TicketId],                        
                AC.ProjectId,                        
                ML.ApplicationID,                        
                (SELECT TOP 1 AD.ApplicationName from [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) APM                
    Join [AVL].[APP_MAS_ApplicationDetails] AD on APM.ApplicationID = AD.ApplicationID                
    where APM.projectID = @ProjectId and APM.isdeleted = 0) as 'ApplicationName',                        
                ML.[TicketDescription],                        
                ML.[ClusterID_Desc]            
    from ML.TicketsforAutoClassification(NOLOCK) ML                         
    JOIN ML.AutoClassificationBatchProcess(NOLOCK) AC ON AC.BatchProcessId = ML.BatchProcessId AND (ML.StatusId IN (14,15,16) OR (ISNULL(AC.TransactionIdApp,0)=0 AND ISNULL(AC.TransactionIdInfra,0)=0)) WHERE                         
         (ISNULL(ML.[ClusterID_Desc],0)=0 AND ISNULL(ML.[ClusterID_Resolution],0)=0) AND           
         AC.ProjectId=@ProjectId AND ML.BatchProcessId = @BatchProcessId AND ML.SupportType = 2                 
    
UPDATE ML  SET StatusId = 17                
FROM ML.TicketsforAutoClassification ML                
JOIN #MLClassification_TicketUpload1 MLT              
ON MLT.[Ticket ID] = ML.TicketId WHERE BatchProcessId = @BatchProcessId                  
                
UPDATE ML.AutoClassificationBatchProcess SET StatusId = 17 WHERE BatchProcessId = @BatchProcessId                
drop table #MLClassification_TicketUpload1   
END         
  
END TRY    
BEGIN CATCH    
DECLARE @ErrorMessage VARCHAR(MAX);    
    
                                SELECT @ErrorMessage = ERROR_MESSAGE()    
    
  --INSERT Error        
  EXEC AVL_InsertError '[AVL].[ML_UpdateAPIOutputDebtFields]', @ErrorMessage ,''    
END CATCH    
END