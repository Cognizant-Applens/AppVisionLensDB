/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[ML_MLPatternValidationInfra] --10337,'627384'
@ProjectID NVARCHAR(200), 
 
 @UserID    NVARCHAR(50)
 as
 begin

 Begin try

     DECLARE @CustomerID INT=0; 
          DECLARE @IsCognizantID INT; 
          DECLARE @IsRegeneratedML BIT, 
                  @InitID          BIGINT, 
                  @IsRdSignoff     BIT; 



				   SET @IsRegeneratedML=(SELECT TOP 1 ISNULL(IsRegenerated, 0) 
                                FROM   AVL.ML_PRJ_InitialLearningStateInfra 
                                WHERE  ProjectID = @ProjectID and IsDeleted=0 
                                ORDER  BY ID DESC) 
          SET @InitID=(SELECT TOP 1 ID 
                       FROM   AVL.ML_PRJ_InitialLearningStateInfra
                       WHERE  ProjectID = @ProjectID and IsDeleted=0
                       ORDER  BY ID DESC) 
          SET @IsRdSignoff=(SELECT TOP 1 ISNULL(IsMLSignOff, 0) 
                            FROM   AVL.ML_TRN_RegeneratedTowerDetails
                            WHERE  ProjectID = @ProjectID 
                                   AND InitialLearningID = @InitID 
                                   AND IsDeleted = 0) 
          SET @CustomerID=(SELECT TOP 1 CustomerID 
                           FROM   AVL.MAS_LoginMaster 
                           WHERE  ProjectID = @ProjectID 
                                  AND IsDeleted = 0) 
          SET @IsCognizantID=(SELECT TOP 1 IsCognizant 
                              FROM   AVL.Customer 
                              WHERE  CustomerID = @CustomerID 
                                     AND IsDeleted = 0) 

 select ID,ProjectID,TowerID,InitialLearningID, MLResidualFlagID, MLDebtClassificationID, MLAvoidableFlagID, MLResolutionCode
 
 ,MLCauseCodeID,TicketPattern,TicketOccurence,MLAccuracy,SubPattern,AdditionalPattern,AdditionalSubPattern
 into #tmpInfraInitialLearningGrid
  from AVL.ML_TRN_MLPatternValidationInfra where ProjectID=@ProjectID and IsDeleted=0 and TicketPattern<>'0'


  SELECT TowerID, MLResolutionCode
 
 ,MLCauseCodeID,TicketPattern,SubPattern,AdditionalPattern,AdditionalSubPattern,max(MLAccuracy) as  MLAccuracy,max(TicketOccurence) as TicketOccurence,max(ID) as ID into #tmpgrpbyacc from #tmpInfraInitialLearningGrid
  GROUP BY
    MLResolutionCode
 
 ,MLCauseCodeID,TicketPattern,SubPattern,AdditionalPattern,AdditionalSubPattern,TowerID
 --SELECT * from #tmpgrpbyacc

 SELECT tmpinitial.ID,tmpinitial.TowerID,tmpinitial.InitialLearningID, tmpinitial.MLResidualFlagID, tmpinitial.MLDebtClassificationID, tmpinitial.MLAvoidableFlagID, tmpinitial.MLResolutionCode
 
 ,tmpinitial.MLCauseCodeID,tmpinitial.TicketPattern,tmpinitial.TicketOccurence,tmpinitial.MLAccuracy,tmpinitial.SubPattern,tmpinitial.AdditionalPattern,tmpinitial.AdditionalSubPattern
 into #Maxids
 from 
 #tmpInfraInitialLearningGrid tmpinitial JOIN #tmpgrpbyacc tmpgrp
 ON tmpinitial.ID=tmpgrp.ID

  DECLARE @OveridenCount INT 

          DECLARE @IsRegenerated CHAR(1) 

         
          SET @IsRegenerated = (SELECT TOP 1 ISNULL(IsRegenerated, 0) 
                                FROM   AVL.ML_PRJ_InitialLearningStateInfra
                                WHERE  ProjectID  = @ProjectID 
                                       AND IsDeleted = 0 
                                ORDER  BY ID DESC) 

      
          SET @OveridenCount= (SELECT COUNT(OverridenPatternCount) 
                               FROM   AVL.ML_TRN_MLPatternValidationInfra
                               WHERE  ProjectID  = @ProjectID 
                                      AND IsDeleted = 0 
                                      AND OverridenPatternCount = 1) 
     
          UPDATE AVL.ML_TRN_MLPatternValidationInfra 
          SET    OverridenPatternTotalCount = @OveridenCount 

		  ---Analyst and sme debt fields may or may not be present therefore left join is used.
		  if(@IsRegenerated=0)
		  BEGIN
		  UPDATE Infra set IsMLSignOff=ISNULL(Debt.IsMLSignOffInfra,0)
		  FROM AVL.ML_TRN_MLPatternValidationInfra Infra JOIN AVL.MAS_ProjectDebtDetails Debt
		  ON Infra.ProjectID=Debt.ProjectID
		  where Debt.ProjectID=@ProjectID AND Debt.IsDeleted=0 AND Infra.IsDeleted=0
		  END
		  ELSE
		  BEGIN

		   DECLARE @LatestID INT 

                SET @LatestID = (SELECT TOP 1 ID 
                                 FROM   AVL.ML_PRJ_InitialLearningStateInfra
                                 WHERE  ProjectID = @ProjectID 
                                        AND IsDeleted = 0 
                                 ORDER  BY ID DESC) 

                --updating ML sign off based on regenerated patterns sign off 
                UPDATE p 
                SET    p.IsMLSignoff = CASE 
                                         WHEN rg.IsMLSignoff = 1 THEN 1 
                                         ELSE 0 
                                       END 
                FROM   AVL.ML_TRN_MLPatternValidationInfra  p 
                       LEFT JOIN avl.ML_TRN_RegeneratedTowerDetails rg 
                              ON rg.ProjectID  = p.ProjectID  
                                 AND rg.initiallearningid = @LatestID 
                WHERE  p.ProjectID  = @ProjectID  
                       AND p.IsDeleted = 0 
                       AND rg.IsDeleted = 0 

                --updating isdeleted =1 in pattern validation if same application exists in regenerated applications.
                UPDATE P 
                SET    P.IsDeleted = 1 
                FROM   AVL.ML_TRN_MLPatternValidationInfra P 
                       LEFT JOIN avl.ML_TRN_RegeneratedTowerDetails rg 
                              ON rg.ProjectID  = p.ProjectID  
                                 AND rg.TowerID = p.TowerID 
                WHERE  rg.IsDeleted = 0 
                       AND P.IsDeleted = 0 
                       AND P.ProjectID = @ProjectID 
                       AND P.initiallearningid <> @LatestID 

		  END

		  SELECT DISTINCT INFRA.ID, 
                          ISNULL(Infra.InitialLearningID, 0)           AS InitialLearningID, 
                          ISNULL(Infra.TowerID, 0)               AS TowerID, 
                          ISNULL(TD.TowerName, '')            AS TowerName, 
                         
                          INFRA.TicketPattern, 
                          OverridenPatternTotalCount, 
                          ISNULL( infra.MLDebtClassificationID, 0)         AS MLDebtClassificationID, 
                          ISNULL(AFM.[DebtClassificationName], '')  AS MLDebtClassificationName, 
                          ISNULL( infra.MLResidualFlagID, 0)               AS MLResidualFlagID, 
                          ISNULL(AFMM.[ResidualDebtName], '')       AS MLResidualFlagName, 
                          ISNULL( infra.MLAvoidableFlagID, 0)              AS MLAvoidableFlagID, 
                          ISNULL(AFMF.[AvoidableFlagName], '')      AS MLAvoidableFlagName, 
                          ISNULL( infra.MLCauseCodeID, 0)                  AS MLCauseCodeID, 
                          ISNULL(DCC.[CauseCode], '')               AS MLCauseCodeName, 
                          infra.MLAccuracy                                AS MLAccuracy, 
                           infra.TicketOccurence, 
                          ISNULL(AnalystResolutionCodeID, 0)        AS AnalystResolutionCodeID,
                          ISNULL(DRC1.[resolutioncode], '')         AS AnalystResolutionCodeName, 
                          ISNULL(analystcausecodeid, 0)             AS AnalystCauseCodeID, 
                          ISNULL(DCC2.[causecode], '')              AS AnalystCauseCodeName, 
                          ISNULL(analystdebtclassificationid, 0)    AS AnalystDebtClassificationID,
                          ISNULL(AFM1.[debtclassificationname], '') AS AnalystDebtClassificationName, 
                          ISNULL(analystavoidableflagid, 0)         AS AnalystAvoidableFlagID, 
                          ISNULL(AFMF2.[avoidableflagname], '')     AS AnalystAvoidableFlagName, 
                          ISNULL(SMEComments, '')                   AS SMEComments, 
                          ISNULL(SMEResidualFlagID, 0)              AS SMEResidualFlagID, 
                          ISNULL(AFMF5.[ResidualDebtName], '')      AS SMEResidualFlagName, 
                          ISNULL(SMEDebtClassificationID, 0)        AS SMEDebtClassificationID,
                          ISNULL(AFM3.[debtclassificationname], '') AS SMEDebtClassificationName, 
                          ISNULL(SMEAvoidableFlagID, 0)             AS SMEAvoidableFlagID, 
                          AFMF4.[AvoidableFlagName]                 AS SMEAvoidableFlagName, 
                          ISNULL(SMECauseCodeID, 0)                 AS SMECauseCodeID, 
                          ISNULL(IsApprovedOrMute, 0)               AS IsApprovedOrMute, 
                          DCC1.[CauseCode]                          AS SMECauseCodeName, 
                          ISNULL( infra.MLResolutionCode, '')              AS MLResolutionCodeID, 
                          DRC.ResolutionCode                        AS MLResolutionCodeName, 
                          ISNULL(Infra.subPattern, '')                 AS SubPattern, 
                          ISNULL(Infra.additionalPattern, '')          AS AdditionalPattern, 
                          ISNULL(Infra.additionalSubPattern, '')       AS AdditionalSubPattern, 
                          ISNULL(Infra.IsMLSignoff, 0)                 AS ISMLSignoff ,
						  0 as IsRegenerated
                       
						   FROM AVL.ML_TRN_MLPatternValidationInfra Infra JOIN #Maxids Id 
		  on infra.ID=Id.ID and Infra.ProjectID=@ProjectID and Infra.IsDeleted=0
		  JOIN AVL.InfraTowerDetailsTransaction TD ON TD.InfraTowerTransactionID=Infra.TowerID AND TD.IsDeleted=0
		  JOIN AVL.InfraTowerProjectMapping TPM ON TPM.TowerID=TD.InfraTowerTransactionID AND TPM.IsDeleted=0
		  AND TPM.IsEnabled=1
		 LEFT JOIN [AVL].DEBT_MAS_DebtClassificationInfra AFM 
                        ON Infra.MLDebtClassificationID = AFM.[DebtClassificationID] 
                 LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] AFMM 
                        ON Infra.MLResidualFlagID = AFMM.[ResidualDebtID] 
                 LEFT JOIN [AVL].[Debt_MAS_AvoidableFlag] AFMF 
                        ON Infra.MLAvoidableFlagID = AFMF.[AvoidableFlagID] 
                 LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC 
                        ON Infra.MLCauseCodeID = DCC.causeid 
                           AND DCC.ProjectID = @ProjectID 
                           AND DCC.IsDeleted = 0 
                 LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC2 
                        ON Infra.AnalystCauseCodeID = DCC2.[CauseID] 
                           AND DCC2.ProjectID = @ProjectID 
                           AND DCC2.IsDeleted = 0 
                 LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] DRC 
                        ON DRC.ResolutionID = Infra.MLResolutionCode 
                           AND DRC.ProjectID = @ProjectID 
                           AND DRC.IsDeleted = 0 
                 LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] DRC1 
                        ON Infra.AnalystResolutionCodeID = DRC1.[ResolutionID] 
                           AND DRC1.ProjectID = @ProjectID 
                           AND DRC1.IsDeleted = 0 
                 LEFT JOIN [AVL].DEBT_MAS_DebtClassificationInfra AFM1 
                        ON Infra.AnalystDebtClassificationID = AFM1.[DebtClassificationID] 
                 LEFT JOIN [AVL].[Debt_MAS_AvoidableFlag] AFMF2 
                        ON Infra.AnalystAvoidableFlagID = AFMF2.[AvoidableFlagID] 
                 LEFT JOIN [AVL].DEBT_MAS_DebtClassificationInfra AFM3 
                        ON Infra.SMEDebtClassificationID = AFM3.[DebtClassificationID] 
                 LEFT JOIN [AVL].[Debt_MAS_AvoidableFlag] AFMF4 
                        ON Infra.SMEAvoidableFlagID = AFMF4.[AvoidableFlagID] 
                 LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] AFMF5 
                        ON Infra.SMEResidualFlagID = AFMF5.[ResidualDebtID] 
                 LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC1 
                        ON Infra.SMECauseCodeID = DCC1.[CauseID] 
                           AND DCC1.ProjectID = @ProjectID 
                           AND DCC1.IsDeleted = 0 
						   LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails RTD 
						   ON RTD.TowerID=Infra.TowerID AND RTD.IsDeleted=0
                AND RTD.InitialLearningID=@InitID AND RTD.ProjectID=@ProjectID
						   AND RTD.ProjectID=Infra.ProjectID
						   
						      WHERE  Infra.ProjectID = @ProjectID 
                 AND Infra.IsDeleted = 0 
				AND ( ( @IsRegeneratedML = 1 
                         AND RTD.id IS NOT NULL 
                         AND @IsRdSignoff = 0 ) 
                        OR ( @IsRdSignoff = 1 ) 
                        OR ( @IsRegeneratedML = 0 ) )
                 AND Infra.ticketpattern <> '0' 
                 AND ( Infra.MLCauseCodeID IS NOT NULL 
                        OR Infra.mlcausecodeid <> 0 ) 
                 AND ( Infra.MLResolutionCode IS NOT NULL 
                        OR Infra.MLResolutionCode <> 0 ) 
                 AND ( Infra.MLDebtClassificationID IS NOT NULL 
                        OR Infra.MLDebtClassificationID <> 0 ) 
                 AND ( Infra.MLAvoidableFlagID IS NOT NULL 
                        OR Infra.MLAvoidableFlagID <> 0 ) 
                 AND ( Infra.MLResidualFlagID IS NOT NULL 
                        OR Infra.MLResidualFlagID <> 0 ) 
          
				 ORDER by Infra.ID DESC



End TRY

BEGIN CATCH

DECLARE @ErrorMessage VARCHAR(max); 

          SELECT @ErrorMessage = Error_message() 

         
          --INSERT Error     
          EXEC Avl_inserterror 
            '[dbo].[ML_MLPatternValidation] ', 
            @ErrorMessage, 
            @ProjectID, 
            0 
END CATCH


 end
