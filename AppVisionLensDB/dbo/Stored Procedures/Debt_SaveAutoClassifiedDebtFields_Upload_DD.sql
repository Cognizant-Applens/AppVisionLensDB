/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
    
CREATE PROCEDURE [dbo].[Debt_SaveAutoClassifiedDebtFields_Upload_DD]             
@PROJECTID INT,                
@CogID VARCHAR(50),              
@lstTicketsCollection TVP_TicketDetails READONLY,              
@IsAutoClassified VARCHAR(2),               
@IsDDAutoClassified VARCHAR(2),
@BatchProcessId Bigint=NULL             
AS              
BEGIN              
               
 SET NOCOUNT ON;   
 SELECT TD.TicketID,TD.ProjectID,TD.TicketTypeMapID,TD.TimeTickerID,TD.ApplicationID,TD.DebtClassificationMode,TD.CauseCodeMapID,TD.ResolutionCodeMapID
INTO #TK_TRN_TicketDetail
FROM @lstTicketsCollection A
JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON A.TicketID=TD.TicketID AND TD.ProjectID=@PROJECTID
AND TD.IsDeleted=0           
              
Declare @DDCausecode INT;              
Declare @DDResolution INT;              
Declare @DDCausecodeML INT;              
Declare @DDResolutioncodeML INT;              
DECLARE @IsDebtEnabled NVARCHAR(10);              
DECLARE @CustomerID BIGINT;              
DECLARE @IsCognizant INT;              
DECLARE @ISTicketTypeApplicable INT              
              
SET @CustomerID=(SELECT CustomerID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0 )              
SET @IsDebtEnabled=(SELECT IsDebtEnabled FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0)              
SET @IsCognizant=(SELECT IsCognizant FROM AVL.Customer(NOLOCK) WHERE CustomerID=@CustomerID AND IsDeleted=0)              
--SET @ISTicketTypeApplicable=(SELECT COUNT(TTM.TicketTypeMappingID) FROM AVL.TK_MAP_TicketTypeMapping TTM               
--        INNER JOIN AVL.TK_ImportTicketDumpDetails ITD               
--        ON TTM.TicketType=ITD.[Ticket Type] AND ITD.ProjectID=@ProjectID               
--        WHERE TTM.IsDeleted=0 AND TTM.DebtConsidered='Y' AND ITD.[Ticket ID]=@TicketID)              
                  
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
              
SET @ISTicketTypeApplicable=(SELECT count(TTM.TicketTypeMappingID)               
       FROM AVL.TK_MLClassification_TicketUpload(NOLOCK) ML               
       JOIN #TK_TRN_TicketDetail(NOLOCK) TD ON ML.ProjectID=TD.ProjectID AND ML.[Ticket ID]=TD.TicketID              
       JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TD.ProjectID=TTM.ProjectID AND TD.TicketTypeMapID=TTM.TicketTypeMappingID              
       WHERE TTM.DebtConsidered='Y' AND TTM.IsDeleted=0)              
              
IF  (@IsDebtEnabled ='Y' AND ((@IsCognizant=1)) OR (@ISTicketTypeApplicable > 0 AND @IsCognizant=0) )              
BEGIN              
IF((@IsDDAutoClassified = 'Y') AND (@IsAutoClassified = 'N') )               
BEGIN              
            
UPDATE TDF SET TDF.DebtClassificationID = DIC.DebtClassificationID,              
    TDF.AvoidableFlagID = DIC.AvoidableFlagID,              
       TDF.ResidualDebtID = DIC.ResidualDebtID,              
       TDF.ByMLorDD = 'DD'               
from [AVL].[Debt_MAS_ProjectDataDictionary] DIC               
Inner Join AVL.TK_MLClassification_TicketUpload  TDF              
ON DIC.ProjectID = TDF.ProjectID AND DIC.ApplicationID = TDF.ApplicationID               
INNER JOIN #TK_TRN_TicketDetail TD on TDF.ProjectID=TD.ProjectID AND TDF.[Ticket ID]=TD.TicketID              
INNER JOIN [AVL].[DEBT_MAP_CauseCode] MC on MC.ProjectID = TDF.ProjectID and MC.CauseCode = TDF.[Cause code]              
INNER JOIN [AVL].[DEBT_MAP_ResolutionCode] MR on MR.ProjectID = TDF.ProjectID and MR.ResolutionCode = TDF.[Resolution Code]              
LEFT JOIN AVL.TK_TRN_TicketDetail_RuleID TR ON TR.TimeTickerID=TD.TimeTickerID              
WHERE TR.ID IS NULL AND DIC.CauseCodeID = Mc.CauseID and DIC.ResolutionCodeID = MR.ResolutionID AND ISNULL(DIC.IsDeleted,0)=0              
            
            
SELECT TD.TimeTickerID,ISNULL(MLTK.DebtClassificationId,PD.DebtClassificationID) AS UserDebtClassificationID,              
ISNULL(MLTK.AvoidableFlagID,PD.AvoidableFlagID) AS UserAvoidableFlagID,              
ISNULL(MLTK.ResidualDebtID,PD.ResidualDebtID) AS UserResidualDebtID,PD.DebtClassificationID AS 'SystemDebtClassification',PD.AvoidableFlagID as 'SystemAvoidableFlag'              
,Pd.ResidualDebtID AS 'SystemResidualDebtID', CASE WHEN PD.DebtClassificationID  IS NULL  AND PD.AvoidableFlagID IS NULL AND PD.ResidualDebtID IS  NULL              
THEN NULL              
WHEN PD.DebtClassificationID=ISNULL(MLTK.DebtClassificationId,PD.DebtClassificationID)              
 AND PD.AvoidableFlagID=ISNULL(MLTK.AvoidableFlagID,PD.AvoidableFlagID) AND PD.ResidualDebtID=ISNULL(MLTK.ResidualDebtID,PD.ResidualDebtID)              
THEN 3              
WHEN TD.DebtClassificationMode=3 THEN             
4               
END AS 'DebtClassificationMode',2 AS SourcePattern,              
MLTK.CauseCodeID AS CauseCode,MLTK.[Resolution Code ID] AS ResolutionCode              
              
INTO #TmpDDData              
 FROM #TK_TRN_TicketDetail(NOLOCK) TD JOIN AVL.TK_MLClassification_TicketUpload(NOLOCK)  MLTK              
        ON TD.TicketID=MLTK.[Ticket ID] AND TD.ProjectID=MLTK.ProjectID              
  AND TD.ProjectID=@ProjectID               
                
  LEFT JOIN AVL.Debt_MAS_ProjectDataDictionary(NOLOCK) PD ON PD.ApplicationID=TD.ApplicationID              
  AND PD.CauseCodeID=MLTK.CauseCodeID  AND PD.ResolutionCodeID=MLTK.[Resolution Code ID]              
  AND PD.ProjectID=MLTK.ProjectID               
  AND PD.IsDeleted=0              
  LEFT JOIN AVL.TK_TRN_TicketDetail_RuleID(NOLOCK) TR ON TR.TimeTickerID=TD.TimeTickerID              
  WHERE TR.ID IS NULL              
  --Newly added              
  --AND ISNULL(TD.DebtClassificationMode,0) NOT IN(2,4)              
              
            
              
              
--declare @DebtClassificationFlag NVARCHAR(MAX),@AvoidableFlag NVARCHAR(max),@ResidualDebt NVARCHAR(MAX)              
--select @DebtClassificationFlag=ISNULL(DebtClassificationId,'0'),@ResidualDebt=ISNULL(ResidualDebtID,'0'),@AvoidableFlag              
--=ISNULL(AvoidableFlagID,'0') from AVL.TK_MLClassification_TicketUpload where  TicketID=@TicketID              
              
              
UPDATE DCM SET DCM.SystemDebtclassification=DD.SystemDebtClassification,DCM.SystemAvoidableFlag=DD.SystemAvoidableFlag,              
   DCM.SystemResidualDebtFlag=DD.SystemResidualDebtID,DCM.UserDebtClassificationFlag=DD.UserDebtClassificationID,              
   DCM.UserAvoidableFlag=DD.UserAvoidableFlagID,DCM.UserResidualDebtFlag=DD.UserResidualDebtID,              
   DCM.DebtClassficationMode=DD.DebtClassificationMode ,DCM.SourceForPattern=DD.SourcePattern,       
   ModifiedDate=GETDATE(),ModifiedBy=@CogID,DCM.CauseCodeID=DD.CauseCode,DCM.ResolutionCodeID=DD.ResolutionCode,              
   DCM.SystemCauseCodeID = NULL, DCM.SystemResolutionCodeID = NULL              
   FROM AVL.TRN_DebtClassificationModeDetails  DCM              
JOIN #TmpDDData DD ON DCM.TimeTickerID=DD.TimeTickerID              
AND DCM.Isdeleted=0               
              
                
              
                
              
 INSERT INTO AVL.TRN_DebtClassificationModeDetails (TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,              
   DebtClassficationMode,SourceForPattern,Isdeleted,CreatedBy,CreatedDate,CauseCodeID,ResolutionCodeID, SystemCauseCodeID, SystemResolutionCodeID              
                 
   )              
  SELECT DISTINCT DD.TimeTickerID,DD.SystemDebtClassification,DD.SystemAvoidableFlag,DD.SystemResidualDebtID,DD.UserDebtClassificationID,DD.UserAvoidableFlagID,              
   DD.UserResidualDebtID,DD.DebtClassificationMode,DD.SourcePattern,0,@CogID,GETDATE(),DD.CauseCode,DD.ResolutionCode,NULL,NULL from AVL.TRN_DebtClassificationModeDetails(NOLOCK) DCM              
 RIGHT JOIN #TmpDDData(NOLOCK) DD ON DCM.TimeTickerID=DD.TimeTickerID              
AND DCM.Isdeleted=0              
WHERE DCM.ID IS NULL AND DD.DebtClassificationMode IS NOT NULL              
              
              
              
 UPDATE TD SET TD.DebtClassificationMode =DCMD.DebtClassficationMode,              
 TD.LastUpdatedDate=GETDATE(),              
 TD.ModifiedDate=GETDATE(),              
 TD.ModifiedBy=@CogID              
 FROM AVL.TK_TRN_TicketDetail TD JOIN #TmpDDData MLTK              
 ON MLTK.TimeTickerID=TD.TimeTickerID and TD.Isdeleted=0 AND TD.ProjectID=@ProjectID              
 JOIN AVL.TRN_DebtClassificationModeDetails DCMD ON DCMD.TimeTickerID=TD.TimeTickerID AND DCMD.Isdeleted=0 
 AND ISNULL(TD.DebtClassificationMode,0)<>5 AND ISNULL(DCMD.DebtClassficationMode,0)<>0
--WHERE ISNULL(TD.DebtClassificationMode,0) NOT IN(2,4)              
              
UPDATE TD  SET TD.DebtClassificationMapID=ML.DebtClassificationId,              
 TD.ResidualDebtMapID=ML.ResidualDebtID,              
 TD.AvoidableFlag=ML.AvoidableFlagID,              
 TD.LastUpdatedDate=GETDATE(),              
 TD.ModifiedDate=GETDATE(),              
 TD.ModifiedBy=@CogID              
FROM AVL.TK_TRN_TicketDetail TD JOIN AVL.TK_MLClassification_TicketUpload ML              
ON TD.ProjectID=ML.ProjectID AND TD.TicketID=ML.[Ticket ID]              
LEFT JOIN AVL.TK_TRN_TicketDetail_RuleID TR ON TR.TimeTickerID=TD.TimeTickerID              
WHERE TR.ID IS NULL AND ISNULL(ML.DebtClassificationId ,0)<>0 AND ISNULL(ML.ResidualDebtID,0)<>0 
AND ISNULL(ML.AvoidableFlagID,0)<>0             
--AND ISNULL(TD.DebtClassificationMode,0) NOT IN(2,4)              
              
              
END              
END              
END                
 IF(@AppAlgorithmKey='AL002' OR @InfraAlgorithmKey='AL002')                
 BEGIN                
  SET @ISTicketTypeApplicable=(SELECT count(TTM.TicketTypeMappingID)                   
     FROM ML.TicketsforAutoClassification(NOLOCK) ML                   
     JOIN #TK_TRN_TicketDetail(NOLOCK) TD ON ML.[TicketId]=TD.TicketID AND @ProjectID=TD.ProjectID--AND ML.ProjectID=TD.ProjectID                 
     JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) TTM ON TD.ProjectID=TTM.ProjectID AND TD.TicketTypeMapID=TTM.TicketTypeMappingID                  
     WHERE TTM.DebtConsidered='Y' AND TTM.IsDeleted=0)              
              
                    
  IF  (@IsDebtEnabled ='Y' AND ((@IsCognizant=1)) OR (@ISTicketTypeApplicable > 0 AND @IsCognizant=0) )                  
  BEGIN                  
   IF((@IsDDAutoClassified = 'Y') AND (@IsAutoClassified = 'N') )                   
   BEGIN            
    UPDATE TC SET TC.DebtClassificationID = DIC.DebtClassificationID,                  
    TC.AvoidableFlagID = DIC.AvoidableFlagID,                  
       TC.ResidualFlagId = DIC.ResidualDebtID,                 
       TC.ByMLorDD = 'DD'                   
   from [AVL].[Debt_MAS_ProjectDataDictionary] DIC                   
   Inner Join ML.TicketsforAutoClassification  TC                  
   ON DIC.ProjectID = @ProjectID AND DIC.ApplicationID = TC.ApplicationID  and TC.IsDeleted=0             
   INNER JOIN #TK_TRN_TicketDetail TD on @ProjectID=TD.ProjectID AND TC.[TicketId]=TD.TicketID                  
   LEFT JOIN AVL.TK_TRN_TicketDetail_RuleID TR ON TR.TimeTickerID=TD.TimeTickerID
    INNER JOIN [AVL].[DEBT_MAP_CauseCode] MC on MC.ProjectID = @ProjectID and MC.CauseID = TC.CausecodeMapID           
              INNER JOIN [AVL].[DEBT_MAP_ResolutionCode] MR on MR.ProjectID = @ProjectID and MR.ResolutionID = TC.ResolutionCodeMapID                  
   WHERE TR.ID IS NULL   
  AND isnull(TC.ClusterID_Desc,0)=0    
  AND isnull(TC.ClusterID_Resolution,0)=0 AND DIC.CauseCodeID = Mc.CauseID and DIC.ResolutionCodeID = MR.ResolutionID               
  AND ISNULL(DIC.IsDeleted,0)=0                
                  
   SELECT TD.TimeTickerID,ISNULL(TAC.DebtClassificationId,PD.DebtClassificationID) AS UserDebtClassificationID,                  
   ISNULL(TAC.AvoidableFlagId,PD.AvoidableFlagID) AS UserAvoidableFlagID,                  
   ISNULL(TAC.ResidualFlagId,PD.ResidualDebtID) AS UserResidualDebtID,PD.DebtClassificationID AS 'SystemDebtClassification',PD.AvoidableFlagID as 'SystemAvoidableFlag'                  
   ,Pd.ResidualDebtID AS 'SystemResidualDebtID', CASE WHEN PD.DebtClassificationID  IS NULL  AND PD.AvoidableFlagID IS NULL AND PD.ResidualDebtID IS  NULL                  
   THEN NULL                  
   WHEN PD.DebtClassificationID=ISNULL(TAC.DebtClassificationId,PD.DebtClassificationID)                  
    AND PD.AvoidableFlagID=ISNULL(TAC.AvoidableFlagID,PD.AvoidableFlagID) AND PD.ResidualDebtID=ISNULL(TAC.ResidualFlagId,PD.ResidualDebtID)                  
   THEN 3                  
   WHEN TD.DebtClassificationMode=3 THEN                  
   4                   
   END AS 'DebtClassificationMode',2 AS SourcePattern,                  
   TAC.CauseCodeMapID AS CauseCode,TAC.ResolutionCodeMapID AS ResolutionCode                  
                  
   INTO #TmpDDData1                 
    FROM #TK_TRN_TicketDetail(NOLOCK) TD JOIN ML.TicketsforAutoClassification(NOLOCK)  TAC               
     ON TD.TicketID=TAC.TicketId AND TD.ProjectID=@ProjectID                 
     AND TAC.BatchProcessId=@BatchProcessId                  
                    
     LEFT JOIN AVL.Debt_MAS_ProjectDataDictionary(NOLOCK) PD ON PD.ApplicationID=TD.ApplicationID                  
     AND PD.CauseCodeID=TAC.CauseCodeMapID  AND PD.ResolutionCodeID=TAC.ResolutionCodeMapID                  
     AND PD.ProjectID=@ProjectID               
     AND PD.IsDeleted=0                  
     LEFT JOIN AVL.TK_TRN_TicketDetail_RuleID(NOLOCK) TR ON TR.TimeTickerID=TD.TimeTickerID                  
     WHERE TR.ID IS NULL                  
     --Newly added                  
     --AND ISNULL(TD.DebtClassificationMode,0) NOT IN(2,4)                  
                  
              
                  
   --declare @DebtClassificationFlag NVARCHAR(MAX),@AvoidableFlag NVARCHAR(max),@ResidualDebt NVARCHAR(MAX)                  
   --select @DebtClassificationFlag=ISNULL(DebtClassificationId,'0'),@ResidualDebt=ISNULL(ResidualDebtID,'0'),@AvoidableFlag                  
   --=ISNULL(AvoidableFlagID,'0') from AVL.TK_MLClassification_TicketUpload where  TicketID=@TicketID                  
                  
                  
   UPDATE DCM SET DCM.SystemDebtclassification=DD.SystemDebtClassification,DCM.SystemAvoidableFlag=DD.SystemAvoidableFlag,                  
      DCM.SystemResidualDebtFlag=DD.SystemResidualDebtID,DCM.UserDebtClassificationFlag=DD.UserDebtClassificationID,                  
      DCM.UserAvoidableFlag=DD.UserAvoidableFlagID,DCM.UserResidualDebtFlag=DD.UserResidualDebtID,                  
      DCM.DebtClassficationMode=DD.DebtClassificationMode ,DCM.SourceForPattern=DD.SourcePattern,                  
      ModifiedDate=GETDATE(),ModifiedBy=@CogID,--DCM.CauseCodeID=DD.CauseCode,DCM.ResolutionCodeID=DD.ResolutionCode,                  
      DCM.SystemCauseCodeID = NULL, DCM.SystemResolutionCodeID = NULL                  
      FROM AVL.TRN_DebtClassificationModeDetails  DCM                  
   JOIN #TmpDDData1 DD ON DCM.TimeTickerID=DD.TimeTickerID                  
   AND DCM.Isdeleted=0                   
                  
                    
                    
                  
    INSERT INTO AVL.TRN_DebtClassificationModeDetails (TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,                  
      DebtClassficationMode,ModifiedBy,SourceForPattern,Isdeleted,CreatedBy,CreatedDate,CauseCodeID,ResolutionCodeID, SystemCauseCodeID, SystemResolutionCodeID                  
                     
      )                  
     SELECT DISTINCT DD.TimeTickerID,DD.SystemDebtClassification,DD.SystemAvoidableFlag,DD.SystemResidualDebtID,DD.UserDebtClassificationID,DD.UserAvoidableFlagID,                  
      DD.UserResidualDebtID,DD.DebtClassificationMode,case when DD.DebtClassificationMode =1 then 'Occurrence 10'ELSE NULL END,DD.SourcePattern,0,@CogID,GETDATE(),DD.CauseCode,DD.ResolutionCode,NULL,NULL from AVL.TRN_DebtClassificationModeDetails(NOLOCK) DCM                  
    RIGHT JOIN #TmpDDData1(NOLOCK) DD ON DCM.TimeTickerID=DD.TimeTickerID                  
   AND DCM.Isdeleted=0                  
   WHERE DCM.ID IS NULL AND DD.DebtClassificationMode IS NOT NULL                  
                  
                  
                  
    UPDATE TD SET TD.DebtClassificationMode =DCMD.DebtClassficationMode,                  
    TD.LastUpdatedDate=GETDATE(),                  
    TD.ModifiedDate=GETDATE(),                  
    TD.ModifiedBy=case when DCMD.DebtClassficationMode =1 then  'Occurrence 11' 
	else
	@CogID
	end
    FROM AVL.TK_TRN_TicketDetail TD JOIN #TmpDDData1 MLTK                  
    ON MLTK.TimeTickerID=TD.TimeTickerID and TD.Isdeleted=0 AND TD.ProjectID=@ProjectID                  
    JOIN AVL.TRN_DebtClassificationModeDetails DCMD ON DCMD.TimeTickerID=TD.TimeTickerID AND DCMD.Isdeleted=0 
    AND ISNULL(TD.DebtClassificationMode,0)<>5 AND ISNULL(DCMD.DebtClassficationMode,0)<>0                  
    --WHERE ISNULL(TD.DebtClassificationMode,0) NOT IN(2,4)                  
                  
   UPDATE TD  SET TD.DebtClassificationMapID=ML.DebtClassificationId,                  
    TD.ResidualDebtMapID=ML.ResidualFlagId,                  
    TD.AvoidableFlag=ML.AvoidableFlagID,                  
    TD.LastUpdatedDate=GETDATE(),                  
    TD.ModifiedDate=GETDATE(),                  
    TD.ModifiedBy=@CogID                  
   FROM AVL.TK_TRN_TicketDetail TD JOIN ML.TicketsforAutoClassification ML                  
   ON TD.ProjectID=@ProjectID AND TD.TicketID=ML.[TicketId]                  
   LEFT JOIN AVL.TK_TRN_TicketDetail_RuleID TR ON TR.TimeTickerID=TD.TimeTickerID                   
   WHERE TR.ID IS NULL AND ISNULL(ML.DebtClassificationId,0)<>0 AND ISNULL(ML.ResidualFlagId,0)<>0 
               AND ISNULL(ML.AvoidableFlagID,0)<>0                  
  END                
 END                
  END                
END
