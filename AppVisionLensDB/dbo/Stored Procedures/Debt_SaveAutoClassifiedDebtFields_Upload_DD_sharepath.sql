/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Debt_SaveAutoClassifiedDebtFields_Upload_DD_sharepath]
@PROJECTID INT,  
@CogID VARCHAR(50),
@lstTicketsCollection TVP_TicketDetails READONLY,
@IsAutoClassified VARCHAR(2), 
@IsDDAutoClassified VARCHAR(2) 
AS
BEGIN
	
	SET NOCOUNT ON;

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

 DECLARE @AlgorithmKey nvarchar(6);    
  SET @AlgorithmKey=(SELECT TOP 1 AlgorithmKey FROM [ML].[TRN_MLTransaction] WHERE ProjectId =@projectid AND IsActiveTransaction=1 AND IsDeleted=0) 


--SET @ISTicketTypeApplicable=(SELECT COUNT(TTM.TicketTypeMappingID) FROM AVL.TK_MAP_TicketTypeMapping TTM 
--								INNER JOIN AVL.TK_ImportTicketDumpDetails ITD 
--								ON TTM.TicketType=ITD.[Ticket Type] AND ITD.ProjectID=@ProjectID 
--								WHERE TTM.IsDeleted=0 AND TTM.DebtConsidered='Y' AND ITD.[Ticket ID]=@TicketID)
IF(@AlgorithmKey='AL001')  
BEGIN
IF  (@IsDebtEnabled ='Y' AND ((@IsCognizant=1)) --OR (@ISTicketTypeApplicable > 0 AND @IsCognizant=0) 
)
BEGIN
IF((@IsDDAutoClassified = 'Y') AND (@IsAutoClassified = 'N') ) 
BEGIN


SELECT TD.TimeTickerID,ISNULL(MLTK.DebtClassificationId,PD.DebtClassificationID) AS UserDebtClassificationID,
ISNULL(MLTK.AvoidableFlagID,PD.AvoidableFlagID) AS UserAvoidableFlagID,
ISNULL(MLTK.ResidualDebtID,PD.ResidualDebtID) AS UserResidualDebtID,PD.DebtClassificationID AS 'SystemDebtClassification',PD.AvoidableFlagID as 'SystemAvoidableFlag'
,Pd.ResidualDebtID AS 'SystemResidualDebtID', CASE WHEN PD.DebtClassificationID  IS NULL  AND PD.AvoidableFlagID IS NULL AND PD.ResidualDebtID IS  NULL
THEN NULL
WHEN PD.DebtClassificationID=ISNULL(MLTK.DebtClassificationId,PD.DebtClassificationID)
 AND PD.AvoidableFlagID=ISNULL(MLTK.AvoidableFlagID,PD.AvoidableFlagID) AND PD.ResidualDebtID=ISNULL(MLTK.ResidualDebtID,PD.ResidualDebtID)
THEN 3
ELSE
4 
END AS 'DebtClassificationMode',3 AS SourcePattern,
MLTK.CauseCodeID AS CauseCode,MLTK.[Resolution Code ID] AS ResolutionCode

INTO #TmpDDData
 FROM AVL.TK_TRN_TicketDetail TD JOIN AVL.TK_MLClassification_TicketUpload  MLTK
        ON TD.TicketID=MLTK.[Ticket ID] AND TD.ProjectID=MLTK.ProjectID
		AND TD.ProjectID=@ProjectID AND TD.IsDeleted=0 
		
		LEFT JOIN AVL.Debt_MAS_ProjectDataDictionary PD ON PD.ApplicationID=TD.ApplicationID
		AND PD.CauseCodeID=MLTK.CauseCodeID  AND PD.ResolutionCodeID=MLTK.[Resolution Code ID]
		AND PD.ProjectID=MLTK.ProjectID 
		AND PD.IsDeleted=0 
		LEFT JOIN AVL.TK_TRN_TicketDetail_RuleID TR ON TR.TimeTickerID=TD.TimeTickerID
		WHERE TR.ID IS NULL
		--AND ISNULL(TD.DebtClassificationMode,0) NOT IN(2,4)

UPDATE TDF SET TDF.DebtClassificationID = DIC.DebtClassificationID,
	   TDF.AvoidableFlagID = DIC.AvoidableFlagID,
       TDF.ResidualDebtID = DIC.ResidualDebtID,
       TDF.ByMLorDD = 'DD' 
from [AVL].[Debt_MAS_ProjectDataDictionary] DIC 
Inner Join AVL.TK_MLClassification_TicketUpload  TDF
ON DIC.ProjectID = TDF.ProjectID AND DIC.ApplicationID = TDF.ApplicationID 
INNER JOIN AVL.TK_TRN_TicketDetail TD on TDF.ProjectID=TD.ProjectID AND TDF.[Ticket ID]=TD.TicketID
INNER JOIN [AVL].[DEBT_MAP_CauseCode] MC on MC.ProjectID = TDF.ProjectID and MC.CauseCode = TDF.[Cause code]
INNER JOIN [AVL].[DEBT_MAP_ResolutionCode] MR on MR.ProjectID = TDF.ProjectID and MR.ResolutionCode = TDF.[Resolution Code]
LEFT JOIN AVL.TK_TRN_TicketDetail_RuleID TR ON TR.TimeTickerID=TD.TimeTickerID
where TR.ID IS NULL AND DIC.CauseCodeID = Mc.CauseID and DIC.ResolutionCodeID = MR.ResolutionID
AND ISNULL(DIC.IsDeleted,0)=0



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
   DebtClassficationMode,SourceForPattern,Isdeleted,CreatedBy,CreatedDate,CauseCodeID,ResolutionCodeID,SystemCauseCodeID,SystemResolutionCodeID
   
   )
  SELECT DISTINCT DD.TimeTickerID,DD.SystemDebtClassification,DD.SystemAvoidableFlag,DD.SystemResidualDebtID,DD.UserDebtClassificationID,DD.UserAvoidableFlagID,
   DD.UserResidualDebtID,DD.DebtClassificationMode,DD.SourcePattern,0,@CogID,GETDATE(),DD.CauseCode,DD.ResolutionCode,NULL,NULL from AVL.TRN_DebtClassificationModeDetails DCM
 RIGHT JOIN #TmpDDData DD ON DCM.TimeTickerID=DD.TimeTickerID
AND DCM.Isdeleted=0
WHERE DCM.ID IS NULL AND DD.DebtClassificationMode IS NOT NULL

--Newly added Bug Fix
UPDATE TD SET TD.DebtClassificationMode =DCMD.DebtClassficationMode FROM AVL.TK_TRN_TicketDetail TD 
JOIN #TmpDDData MLTK
ON MLTK.TimeTickerID=TD.TimeTickerID and TD.Isdeleted=0 AND TD.ProjectID=@ProjectID
JOIN AVL.TRN_DebtClassificationModeDetails DCMD ON DCMD.TimeTickerID=TD.TimeTickerID AND DCMD.Isdeleted=0
--WHERE ISNULL(TD.DebtClassificationMode,0) NOT IN(2,4)


UPDATE TD  SET TD.DebtClassificationMapID=ML.DebtClassificationId,
TD.ResidualDebtMapID=ML.ResidualDebtID,
TD.AvoidableFlag=ML.AvoidableFlagID
FROM AVL.TK_TRN_TicketDetail TD JOIN AVL.TK_MLClassification_TicketUpload ML
ON TD.ProjectID=ML.ProjectID AND TD.TicketID=ML.[Ticket ID]
LEFT JOIN AVL.TK_TRN_TicketDetail_RuleID TR ON TR.TimeTickerID=TD.TimeTickerID

WHERE  TR.ID IS NULL 
--AND ISNULL(TD.DebtClassificationMode,0) NOT IN(2,4)



END
END
END

ELSE IF(@AlgorithmKey='AL002')    
 BEGIN    
  SET @ISTicketTypeApplicable=(SELECT count(TTM.TicketTypeMappingID)       
     FROM ML.TicketsforAutoClassification ML       
     JOIN AVL.TK_TRN_TicketDetail TD ON ML.[TicketId]=TD.TicketID AND (SELECT DISTINCT ACB.ProjectId FROM ML.AutoClassificationBatchProcess ACB     
     JOIN ML.TicketsforAutoClassification TAC ON ACB.BatchProcessId=TAC.BatchProcessId)=TD.ProjectID--AND ML.ProjectID=TD.ProjectID     
     JOIN AVL.TK_MAP_TicketTypeMapping TTM ON TD.ProjectID=TTM.ProjectID AND TD.TicketTypeMapID=TTM.TicketTypeMappingID      
     WHERE TTM.DebtConsidered='Y' AND TTM.IsDeleted=0)      
      
  IF  (@IsDebtEnabled ='Y' AND ((@IsCognizant=1)) OR (@ISTicketTypeApplicable > 0 AND @IsCognizant=0) )      
  BEGIN      
   IF((@IsDDAutoClassified = 'Y') AND (@IsAutoClassified = 'N') )       
   BEGIN      
   SELECT TD.TimeTickerID,ISNULL(TAC.DebtClassificationId,PD.DebtClassificationID) AS UserDebtClassificationID,      
   ISNULL(TAC.AvoidableFlagId,PD.AvoidableFlagID) AS UserAvoidableFlagID,      
   ISNULL(TAC.ResidualFlagId,PD.ResidualDebtID) AS UserResidualDebtID,PD.DebtClassificationID AS 'SystemDebtClassification',PD.AvoidableFlagID as 'SystemAvoidableFlag'      
   ,Pd.ResidualDebtID AS 'SystemResidualDebtID', CASE WHEN PD.DebtClassificationID  IS NULL  AND PD.AvoidableFlagID IS NULL AND PD.ResidualDebtID IS  NULL      
   THEN NULL      
   WHEN PD.DebtClassificationID=ISNULL(TAC.DebtClassificationId,PD.DebtClassificationID)      
    AND PD.AvoidableFlagID=ISNULL(TAC.AvoidableFlagID,PD.AvoidableFlagID) AND PD.ResidualDebtID=ISNULL(TAC.ResidualFlagId,PD.ResidualDebtID)      
   THEN 3      
   ELSE      
   4       
   END AS 'DebtClassificationMode',2 AS SourcePattern,      
   TAC.CauseCodeMapID AS CauseCode,TAC.ResolutionCodeMapID AS ResolutionCode      
      
   INTO #TmpDDData1     
    FROM AVL.TK_TRN_TicketDetail TD JOIN ML.TicketsforAutoClassification  TAC      
     ON TD.TicketID=TAC.TicketId AND TD.ProjectID=(SELECT DISTINCT ACB.ProjectId FROM ML.AutoClassificationBatchProcess ACB     
     JOIN ML.TicketsforAutoClassification TAC ON ACB.BatchProcessId=TAC.BatchProcessId)--AND TD.ProjectID=MLTK.ProjectID      
     AND TD.ProjectID=@ProjectID AND TD.IsDeleted=0       
        
     LEFT JOIN AVL.Debt_MAS_ProjectDataDictionary PD ON PD.ApplicationID=TD.ApplicationID      
     AND PD.CauseCodeID=TAC.CauseCodeMapID  AND PD.ResolutionCodeID=TAC.ResolutionCodeMapID      
     AND PD.ProjectID=(SELECT DISTINCT ACB.ProjectId FROM ML.AutoClassificationBatchProcess ACB     
     JOIN ML.TicketsforAutoClassification TAC ON ACB.BatchProcessId=TAC.BatchProcessId)    
     --AND PD.ProjectID=TAC.ProjectID       
     AND PD.IsDeleted=0      
     LEFT JOIN AVL.TK_TRN_TicketDetail_RuleID TR ON TR.TimeTickerID=TD.TimeTickerID      
     WHERE TR.ID IS NULL      
     --Newly added      
     --AND ISNULL(TD.DebtClassificationMode,0) NOT IN(2,4)      
      
   UPDATE TC SET TC.DebtClassificationID = DIC.DebtClassificationID,      
    TC.AvoidableFlagID = DIC.AvoidableFlagID,      
       TC.ResidualFlagId = DIC.ResidualDebtID,  
       TC.ByMLorDD = 'DD'       
   from [AVL].[Debt_MAS_ProjectDataDictionary] DIC       
   Inner Join ML.TicketsforAutoClassification  TC      
   ON DIC.ProjectID = (SELECT DISTINCT ACB.ProjectId FROM ML.AutoClassificationBatchProcess ACB     
     JOIN ML.TicketsforAutoClassification TAC ON ACB.BatchProcessId=TAC.BatchProcessId) AND DIC.ApplicationID = TC.ApplicationID       
   INNER JOIN AVL.TK_TRN_TicketDetail TD on (SELECT DISTINCT ACB.ProjectId FROM ML.AutoClassificationBatchProcess ACB     
     JOIN ML.TicketsforAutoClassification TAC ON ACB.BatchProcessId=TAC.BatchProcessId)=TD.ProjectID AND TC.[TicketId]=TD.TicketID      
   INNER JOIN [AVL].[DEBT_MAP_CauseCode] MC on MC.ProjectID = (SELECT DISTINCT ACB.ProjectId FROM ML.AutoClassificationBatchProcess ACB     
     JOIN ML.TicketsforAutoClassification TAC ON ACB.BatchProcessId=TAC.BatchProcessId) and MC.CauseID = TC.CauseCodeMapID      
   INNER JOIN [AVL].[DEBT_MAP_ResolutionCode] MR on MR.ProjectID = (SELECT DISTINCT ACB.ProjectId FROM ML.AutoClassificationBatchProcess ACB     
     JOIN ML.TicketsforAutoClassification TAC ON ACB.BatchProcessId=TAC.BatchProcessId) and MR.ResolutionCode = TC.ResolutionCodeMapID      
   LEFT JOIN AVL.TK_TRN_TicketDetail_RuleID TR ON TR.TimeTickerID=TD.TimeTickerID      
   WHERE TR.ID IS NULL AND DIC.CauseCodeID = Mc.CauseID and DIC.ResolutionCodeID = MR.ResolutionID AND ISNULL(DIC.IsDeleted,0)=0      
      
      
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
   JOIN #TmpDDData1 DD ON DCM.TimeTickerID=DD.TimeTickerID      
   AND DCM.Isdeleted=0       
      
        
      
        
      
    INSERT INTO AVL.TRN_DebtClassificationModeDetails (TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,      
      DebtClassficationMode,SourceForPattern,Isdeleted,CreatedBy,CreatedDate,CauseCodeID,ResolutionCodeID, SystemCauseCodeID, SystemResolutionCodeID      
         
      )      
     SELECT DISTINCT DD.TimeTickerID,DD.SystemDebtClassification,DD.SystemAvoidableFlag,DD.SystemResidualDebtID,DD.UserDebtClassificationID,DD.UserAvoidableFlagID,      
      DD.UserResidualDebtID,DD.DebtClassificationMode,DD.SourcePattern,0,@CogID,GETDATE(),DD.CauseCode,DD.ResolutionCode,NULL,NULL from AVL.TRN_DebtClassificationModeDetails DCM      
    RIGHT JOIN #TmpDDData1 DD ON DCM.TimeTickerID=DD.TimeTickerID      
   AND DCM.Isdeleted=0      
   WHERE DCM.ID IS NULL AND DD.DebtClassificationMode IS NOT NULL      
      
      
      
    UPDATE TD SET TD.DebtClassificationMode =DCMD.DebtClassficationMode,      
    TD.LastUpdatedDate=GETDATE(),      
    TD.ModifiedDate=GETDATE(),      
    TD.ModifiedBy=@CogID      
    FROM AVL.TK_TRN_TicketDetail TD JOIN #TmpDDData1 MLTK      
    ON MLTK.TimeTickerID=TD.TimeTickerID and TD.Isdeleted=0 AND TD.ProjectID=@ProjectID      
    JOIN AVL.TRN_DebtClassificationModeDetails DCMD ON DCMD.TimeTickerID=TD.TimeTickerID AND DCMD.Isdeleted=0      
    --WHERE ISNULL(TD.DebtClassificationMode,0) NOT IN(2,4)      
      
   UPDATE TD  SET TD.DebtClassificationMapID=ML.DebtClassificationId,      
    TD.ResidualDebtMapID=ML.ResidualFlagId,      
    TD.AvoidableFlag=ML.AvoidableFlagID,      
    TD.LastUpdatedDate=GETDATE(),      
    TD.ModifiedDate=GETDATE(),      
    TD.ModifiedBy=@CogID      
   FROM AVL.TK_TRN_TicketDetail TD JOIN ML.TicketsforAutoClassification ML      
   ON TD.ProjectID=(SELECT DISTINCT ACB.ProjectId FROM ML.AutoClassificationBatchProcess ACB     
     JOIN ML.TicketsforAutoClassification TAC ON ACB.BatchProcessId=TAC.BatchProcessId) AND TD.TicketID=ML.[TicketId]      
   LEFT JOIN AVL.TK_TRN_TicketDetail_RuleID TR ON TR.TimeTickerID=TD.TimeTickerID      
   WHERE TR.ID IS NULL      
  END    
 END    
  END 
END
