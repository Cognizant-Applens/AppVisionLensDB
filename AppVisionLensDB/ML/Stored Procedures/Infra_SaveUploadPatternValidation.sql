/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ML].[Infra_SaveUploadPatternValidation]  
(  
@UserId NVARCHAR(10)=null,  
@ProjectID NVARCHAR(200)=null,  
@lstApprovedPatternValidation ML.TVP_Infra_SaveApprovedUploadPatternValidation READONLY  
)  
AS   
BEGIN  
BEGIN TRY  
BEGIN TRAN  
   
  
   
 CREATE TABLE #DebtApprovedPVTickets  
 (  
 [TowerID] BIGINT,  
 [Tower][nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS null,  
 [DescriptionBasePattern] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
 [DebtClassification] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
 [ResidualFlag] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
 [AvoidableFlag] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
 [CauseCode] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
 [MLAccuracy] decimal NULL,  
 [TicketOccurence] int NULL,  
 [IsApprovedOrMute] int NULL,  
 [ResolutionCode] [nvarchar](500) NULL,  
 [DescriptionSubPattern] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
 [ResolutionRemarkBasePattern] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
 [ResolutionRemarksSubPattern] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL   
 )  
 INSERT INTO #DebtApprovedPVTickets  
 SELECT   
 AP.InfraTowerTransactionID,  
 AP.TowerName,  
 DescriptionBasePattern,  
 DC.DebtClassificationID AS DebtClassification,  
 RD.ResidualDebtID AS ResidualFlag,  
 AF.AvoidableFlagID AS AvoidableFlag,  
 CC.CauseID AS CauseCode,  
 MLAccuracy,  
 TicketOccurence,  
 CASE WHEN ISNULL(ApprovedOrMute, '') = 'Approve' THEN 1      
   WHEN ISNULL(ApprovedOrMute, '') = 'Mute' THEN 2    
   WHEN ISNULL(ApprovedOrMute, '') = 'Invalid' THEN -1 
   WHEN ISNULL(ApprovedOrMute, '') = '' THEN 0 END   
 AS ApprovedOrMute,  
 RC.ResolutionID AS ResolutionCode,  
 case when isnull(DescriptionSubPattern,'0')='' THEN '0' else DescriptionSubPattern END as DescriptionSubPattern,  
 case when isnull(ResolutionRemarkBasePattern,'0')='' THEN '0' else ResolutionRemarkBasePattern END as ResolutionRemarkBasePattern,    
 case when isnull(ResolutionRemarksSubPattern,'0')='' THEN '0' else ResolutionRemarksSubPattern END as ResolutionRemarksSubPattern     FROM @lstApprovedPatternValidation PV  
 JOIN [AVL].[DEBT_MAS_DebtClassificationInfra](NOLOCK) DC  
  ON DC.DebtClassificationName=PV.DebtClassification  
  AND DC.IsDeleted = 0  
    JOIN [AVL].[DEBT_MAS_ResidualDebt](NOLOCK) RD  
  ON RD.ResidualDebtName=PV.ResidualFlag  
  AND RD.IsDeleted = 0  
 JOIN [AVL].[Debt_MAS_AvoidableFlag] AF  
  ON AF.AvoidableFlagName=PV.AvoidableFlag  
  AND AF.IsDeleted = 0  
 JOIN [AVL].[DEBT_MAP_CauseCode] CC  
  ON CC.ProjectID = @ProjectID  
  AND CC.CauseCode=PV.CauseCode  
  AND CC.IsDeleted = 0  
    JOIN [AVL].[DEBT_MAP_ResolutionCode](NOLOCK) RC  
  ON RC.ProjectID=@ProjectID  
  AND RC.ResolutionCode=PV.ResolutionCode  
  AND RC.IsDeleted =0  
 JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) AP  
   ON PV.Tower = AP.TowerName  
  AND AP.IsDeleted=0  
  JOIN AVL.InfraTowerProjectMapping(NOLOCK) IPM    
   ON AP.InfraTowerTransactionID=IPM.TowerID  
  AND IPM.ProjectID = @ProjectID  
  
 UPDATE D set D.IsApprovedOrMute = (case when V.IsApprovedOrMute =-1 then D.IsApprovedOrMute else 0 end) 
 FROM ML.InfraTRN_PatternValidation D  
 JOIN #DebtApprovedPVTickets V  
  ON  V.DescriptionBasePattern=D.TicketPattern  
  AND   V.DescriptionSubPattern=D.subPattern and  
  V.ResolutionRemarkBasePattern=D.additionalPattern and  
  V.ResolutionRemarksSubPattern=D.additionalSubPattern    
  AND V.TowerID=D.TowerID      
  AND V.AvoidableFlag=D.MLAvoidableFlagID    
  AND V.ResidualFlag =D.MLResidualFlagID    
  AND V.CauseCode = D.MLCauseCodeID     
  AND V.DebtClassification=D.MLDebtClassificationID     
  AND V.ResolutionCode=D.MLResolutionCode     
 WHERE D.ProjectID = @ProjectID   
   
  
 UPDATE D set D.IsApprovedOrMute = (case when V.IsApprovedOrMute =-1 then D.IsApprovedOrMute else V.IsApprovedOrMute end),  
     D.ModifiedBy=@UserId,  
     D.ModifiedDate = GETDATE()  
 FROM ML.InfraTRN_PatternValidation D  
 JOIN #DebtApprovedPVTickets V  
  ON  V.DescriptionBasePattern=D.TicketPattern  
  AND V.DescriptionSubPattern=D.subPattern and  
  V.ResolutionRemarkBasePattern=D.additionalPattern and  
  V.ResolutionRemarksSubPattern=D.additionalSubPattern   
  AND V.TowerID=D.TowerID      
  AND V.AvoidableFlag=D.MLAvoidableFlagID    
  AND V.ResidualFlag =D.MLResidualFlagID    
  AND V.CauseCode = D.MLCauseCodeID    
  AND V.ResolutionCode=D.MLResolutionCode     
  AND V.DebtClassification=D.MLDebtClassificationID     
  WHERE D.ProjectID = @ProjectID  
   
  
COMMIT TRAN  
END TRY    
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  ROLLBACK TRAN  
  --INSERT Error      
  EXEC AVL_InsertError '[ML].[Infra_SaveUploadPatternValidation]', @ErrorMessage, @ProjectID,0  
    
 END CATCH    
  
END
