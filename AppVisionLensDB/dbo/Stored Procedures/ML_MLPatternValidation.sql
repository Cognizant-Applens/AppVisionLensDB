/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


-- ============================================= 
-- Author:    627384 
-- Create date: 11-FEB-2019 
-- Description:   SP for Initial Learning 
-- [ML_MLPatternValidation] 1188 ,'10/22/2018','1/21/2019','627384' 
-- =============================================  
CREATE PROCEDURE [dbo].[ML_MLPatternValidation] 

(@ProjectID NVARCHAR(200), 
 @DateFrom  DATETIME =NULL, 
 @DateTo    DATETIME=NULL, 
 @UserID    NVARCHAR(50)) 
AS 
  
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

          DECLARE @CustomerID INT=0; 
          DECLARE @IsCognizantID INT; 
          DECLARE @IsRegeneratedML BIT, 
                  @InitID          BIGINT, 
                  @IsRdSignoff     BIT; 

          SET @IsRegeneratedML=(SELECT TOP 1 ISNULL(IsRegenerated, 0) 
                                FROM   AVL.ML_PRJ_InitialLearningState 
                                WHERE  ProjectID = @ProjectID and IsDeleted=0 
                                ORDER  BY ID DESC) 
          SET @InitID=(SELECT TOP 1 ID 
                       FROM   avl.ML_PRJ_InitialLearningState
                       WHERE  ProjectID = @ProjectID and IsDeleted=0
                       ORDER  BY ID DESC) 
          SET @IsRdSignoff=(SELECT TOP 1 ISNULL(IsMLSignOff, 0) 
                            FROM   AVL.ML_TRN_RegeneratedApplicationDetails 
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

          SELECT * 
          INTO   #debt_mlpatternvalidation 
          FROM   AVL.ML_TRN_MLPatternValidation(nolock) MV 
          WHERE  MV.ProjectID  = @ProjectID 
                 AND MV.IsDeleted = 0 
				
		  CREATE TABLE #maxids 
          ( 
               ApplicationID        NVARCHAR(MAX), 
               ticketpattern        NVARCHAR(MAX), 
               subpattern           NVARCHAR(MAX), 
               additionalpattern    NVARCHAR(MAX), 
               additionalsubpattern NVARCHAR(MAX), 
               causecode            INT, 
               resolutioncode       INT,
			   TickID               BIGINT
            ) 
				 
		  CREATE TABLE #tempmaxids
		  (
				TickID BIGINT
		  )

		  -- Give precedence to Approved or Mute patterns to show as base pattern
		  INSERT INTO #maxids
			  SELECT 
						ApplicationID, 
						TicketPattern, 
						subPattern, 
						additionalPattern, 
						additionalSubPattern, 
						MLCauseCodeID, 
						MLResolutionCode,
						MAX(ID) AS TickID
			  FROM #debt_mlpatternvalidation 
			  WHERE TicketPattern <> '0' AND (IsApprovedOrMute = 1 OR IsApprovedOrMute = 2)
			  GROUP  BY ApplicationID, 
						TicketPattern, 
						subPattern, 
						additionalPattern, 
						additionalSubPattern, 
						MLCauseCodeID, 
						MLResolutionCode
						
          -- If a pattern is not Approved or Muted, then take the highest accuracy
		   INSERT INTO #maxids
			  
			  SELECT    PV.ApplicationID, 
						PV.TicketPattern, 
						PV.subPattern, 
						PV.additionalPattern, 
						PV.additionalSubPattern, 
						PV.MLCauseCodeID, 
						PV.MLResolutionCode,
						MAX(ID) AS TickID
			  FROM #debt_mlpatternvalidation PV
			  JOIN 
			  (
				  SELECT 
							 PV.ApplicationID, 
							 PV.TicketPattern, 
							 PV.subPattern, 
							 PV.additionalPattern, 
							 PV.additionalSubPattern, 
							 MLCauseCodeID, 
							 MLResolutionCode,
							 MAX(MLAccuracy) AS MaxAccuracy
				  FROM #debt_mlpatternvalidation PV
				  LEFT JOIN #maxids MX 
					ON MX.ApplicationID = PV.ApplicationID AND MX.TicketPattern = PV.TicketPattern 
						AND MX.subPattern = PV.subPattern AND MX.additionalPattern = PV.additionalPattern 
						AND MX.additionalSubPattern = PV.additionalSubPattern AND MX.causecode = PV.mlcausecodeid 
						AND MX.resolutioncode = PV.MLResolutionCode
				  WHERE  PV.TicketPattern <> '0' AND MX.ApplicationID IS NULL
				  GROUP  BY  PV.ApplicationID, 
							 PV.TicketPattern, 
							 PV.subPattern, 
							 PV.additionalPattern, 
							 PV.additionalSubPattern, 
							 MLCauseCodeID, 
							 MLResolutionCode
			) AS MA 
				ON MA.ApplicationID = PV.ApplicationID AND MA.TicketPattern = PV.TicketPattern 
					AND MA.subPattern = PV.subPattern AND MA.additionalPattern = PV.additionalPattern 
					AND MA.additionalSubPattern = PV.additionalSubPattern AND MA.MLCauseCodeID = PV.mlcausecodeid 
					AND MA.MLResolutionCode = PV.MLResolutionCode AND MA.MaxAccuracy = PV.MLAccuracy
			GROUP BY  PV.ApplicationID, 
					  PV.TicketPattern, 
					  PV.subPattern, 
				      PV.additionalPattern, 
					  PV.additionalSubPattern, 
				      PV.MLCauseCodeID, 
					  PV.MLResolutionCode

		  INSERT INTO #tempmaxids
			SELECT DISTINCT TickID FROM #maxids

          --Getting the overriden count for the patterns 
          DECLARE @OveridenCount INT 
          DECLARE @IsRegenerated CHAR(1) 

          SET @OveridenCount= (SELECT COUNT(OverridenPatternCount) 
                               FROM   AVL.ML_TRN_MLPatternValidation 
                               WHERE  ProjectID  = @ProjectID 
                                      AND IsDeleted = 0 
                                      AND OverridenPatternCount = 1) 
          SET @IsRegenerated = (SELECT TOP 1 ISNULL(IsRegenerated, 0) 
                                FROM   [AVL].[ML_PRJ_InitialLearningState] 
                                WHERE  ProjectID  = @ProjectID 
                                       AND IsDeleted = 0 
                                ORDER  BY ID DESC) 

          UPDATE AVL.ML_TRN_MLPatternValidation 
          SET    OverridenPatternTotalCount = @OveridenCount 

          --Checking whether the patters are regenerated,if it is then gets the latest ID from Initial Learning state.
          IF( @IsRegenerated = 1 ) 
            BEGIN 
                DECLARE @LatestID INT 

                SET @LatestID = (SELECT TOP 1 ID 
                                 FROM   [AVL].[ML_PRJ_InitialLearningState] 
                                 WHERE  ProjectID = @ProjectID 
                                        AND IsDeleted = 0 
                                 ORDER  BY ID DESC) 

                --updating ML sign off based on regenerated patterns sign off 
                UPDATE p 
                SET    p.IsMLSignoff = CASE 
                                         WHEN rg.IsMLSignoff = 1 THEN 1 
                                         ELSE 0 
                                       END 
                FROM   AVL.ML_TRN_MLPatternValidation p 
                       LEFT JOIN avl.ML_TRN_RegeneratedApplicationDetails rg 
                              ON rg.ProjectID  = p.ProjectID  
                                 AND rg.initiallearningid = @LatestID 
                WHERE  p.ProjectID  = @ProjectID  
                       AND p.IsDeleted = 0 
                       AND rg.IsDeleted = 0 

                --updating isdeleted =1 in pattern validation if same application exists in regenerated applications.
                UPDATE P 
                SET    P.IsDeleted = 1 
                FROM   AVL.ML_TRN_MLPatternValidation P 
                       LEFT JOIN avl.ML_TRN_RegeneratedApplicationDetails rg 
                              ON rg.ProjectID  = p.ProjectID  
                                 AND rg.ApplicationID = p.ApplicationID 
                WHERE  rg.IsDeleted = 0 
                       AND P.IsDeleted = 0 
                       AND P.ProjectID = @ProjectID 
                       AND P.initiallearningid <> @LatestID 
            END 
          ELSE 
            BEGIN 
                UPDATE p 
                SET    p.IsMLSignoff = CASE 
                                         WHEN PD.IsMLSignoff = 1 THEN 1 
                                         ELSE 0 
                                       END 
                FROM   AVL.ML_TRN_MLPatternValidation p 
                       LEFT JOIN [AVL].[MAS_ProjectDebtDetails] PD 
                              ON PD.ProjectID = p.ProjectID 
                WHERE  p.ProjectID = @ProjectID 
                       AND p.IsDeleted = 0 
                       AND PD.IsDeleted = 0 
            END 

          --select * from #tempMaxIDs where ticketpattern='apslp0169 message id'  
          SELECT DISTINCT MV.id, 
                          ISNULL(MV.InitialLearningID, 0)           AS InitialLearningID, 
                          ISNULL(MV.ApplicationID, 0)               AS ApplicationID, 
                          ISNULL(AM.ApplicationName, '')            AS ApplicationName, 
                          ISNULL(MV.ApplicationTypeID, 0)           AS ApplicationTypeID, 
                          ISNULL(AT.ApplicationTypeName, '')        AS ApplicationTypeName, 
                          ISNULL(MV.TechnologyID, 0)                AS TechnologyID, 
                          ISNULL(MT.[PrimaryTechnologyName], '')    AS TechnologyName, 
                          TicketPattern, 
                          OverridenPatternTotalCount, 
                          ISNULL(MLDebtClassificationID, 0)         AS MLDebtClassificationID, 
                          ISNULL(AFM.[DebtClassificationName], '')  AS MLDebtClassificationName, 
                          ISNULL(MLResidualFlagID, 0)               AS MLResidualFlagID, 
                          ISNULL(AFMM.[ResidualDebtName], '')       AS MLResidualFlagName, 
                          ISNULL(MLAvoidableFlagID, 0)              AS MLAvoidableFlagID, 
                          ISNULL(AFMF.[AvoidableFlagName], '')      AS MLAvoidableFlagName, 
                          ISNULL(MLCauseCodeID, 0)                  AS MLCauseCodeID, 
                          ISNULL(DCC.[CauseCode], '')               AS MLCauseCodeName, 
                          MLAccuracy                                AS MLAccuracy, 
                          TicketOccurence, 
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
                          ISNULL(MLResolutionCode, '')              AS MLResolutionCodeID, 
                          DRC.ResolutionCode                        AS MLResolutionCodeName, 
                          ISNULL(MV.subPattern, '')                 AS SubPattern, 
                          ISNULL(MV.additionalPattern, '')          AS AdditionalPattern, 
                          ISNULL(MV.additionalSubPattern, '')       AS AdditionalSubPattern, 
                          ISNULL(MV.IsMLSignoff, 0)                 AS ISMLSignoff, 
                          ISNULL(@IsRegenerated, 0)                 AS IsRegenerated 
          INTO   #temp 
          FROM   AVL.ML_TRN_MLPatternValidation(nolock) MV 
                 LEFT JOIN avl.[App_MAS_ApplicationDetails] AM 
                        ON MV.ApplicationID = AM.ApplicationID 
                 LEFT JOIN avl.BusinessClusterMapping BCM 
                        ON AM.SubBusinessClustermapid = BCM.BusinessClusterMapID
                           AND BCM.IsDeleted = 0 
                           AND BCM.customerid = @CustomerID 
                 INNER JOIN [AVL].[App_MAP_ApplicationProjectMapping] AP 
                         ON AP.ApplicationID = MV.ApplicationID 
                            AND AP.ProjectID = @ProjectID 
                 LEFT JOIN avl.[APP_MAS_OwnershipDetails] AT 
                        ON AM.[CodeOwnerShip] = AT.ApplicationTypeID 
                 LEFT JOIN avl.[APP_MAS_PrimaryTechnology] MT 
                        ON AM.[PrimaryTechnologyID] = MT.[PrimaryTechnologyID] 
                 LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] AFM 
                        ON MV.MLDebtClassificationID = AFM.[DebtClassificationID] 
                 LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] AFMM 
                        ON MV.MLResidualFlagID = AFMM.[ResidualDebtID] 
                 LEFT JOIN [AVL].[Debt_MAS_AvoidableFlag] AFMF 
                        ON MV.MLAvoidableFlagID = AFMF.[AvoidableFlagID] 
                 LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC 
                        ON MV.MLCauseCodeID = DCC.causeid 
                           AND DCC.ProjectID = @ProjectID 
                           AND DCC.IsDeleted = 0 
                 LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC2 
                        ON MV.AnalystCauseCodeID = DCC2.[CauseID] 
                           AND DCC2.ProjectID = @ProjectID 
                           AND DCC2.IsDeleted = 0 
                 LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] DRC 
                        ON DRC.ResolutionID = MV.MLResolutionCode 
                           AND DRC.ProjectID = @ProjectID 
                           AND DRC.IsDeleted = 0 
                 LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] DRC1 
                        ON MV.AnalystResolutionCodeID = DRC1.[ResolutionID] 
                           AND DRC1.ProjectID = @ProjectID 
                           AND DRC1.IsDeleted = 0 
                 LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] AFM1 
                        ON MV.AnalystDebtClassificationID = AFM1.[DebtClassificationID] 
                 LEFT JOIN [AVL].[Debt_MAS_AvoidableFlag] AFMF2 
                        ON MV.AnalystAvoidableFlagID = AFMF2.[AvoidableFlagID] 
                 LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] AFM3 
                        ON MV.SMEDebtClassificationID = AFM3.[DebtClassificationID] 
                 LEFT JOIN [AVL].[Debt_MAS_AvoidableFlag] AFMF4 
                        ON MV.SMEAvoidableFlagID = AFMF4.[AvoidableFlagID] 
                 LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] AFMF5 
                        ON MV.SMEResidualFlagID = AFMF5.[ResidualDebtID] 
                 LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC1 
                        ON MV.SMECauseCodeID = DCC1.[CauseID] 
                           AND DCC1.ProjectID = @ProjectID 
                           AND DCC1.IsDeleted = 0 
                 LEFT JOIN avl.ML_TRN_RegeneratedApplicationDetails REG 
                        ON REG.InitialLearningID = @InitID 
                           AND REG.ApplicationID = MV.ApplicationID 
                           AND REG.IsDeleted = 0 
          WHERE  MV.ProjectID = @ProjectID 
                 AND MV.IsDeleted = 0 
                 AND MV.id IN(SELECT tickid 
                              FROM   #tempmaxids) 
                 AND ticketpattern <> '0' 
                 AND ( MV.MLCauseCodeID IS NOT NULL 
                        OR MV.mlcausecodeid <> 0 ) 
                 AND ( MV.MLResolutionCode IS NOT NULL 
                        OR MV.MLResolutionCode <> 0 ) 
                 AND ( MV.MLDebtClassificationID IS NOT NULL 
                        OR MV.MLDebtClassificationID <> 0 ) 
                 AND ( MV.MLAvoidableFlagID IS NOT NULL 
                        OR MV.MLAvoidableFlagID <> 0 ) 
                 AND ( MV.MLResidualFlagID IS NOT NULL 
                        OR MV.MLResidualFlagID <> 0 ) 
                 AND ( ( @IsRegeneratedML = 1 
                         AND REG.id IS NOT NULL 
                         AND @IsRdSignoff = 0 ) 
                        OR ( @IsRdSignoff = 1 ) 
                        OR ( @IsRegeneratedML = 0 ) ) 
                 AND BCM.CustomerID = @CustomerID 
                 AND AM.isactive = 1 
				 ORDER by MV.ID DESC

          DECLARE @RowCount INT 
          DECLARE @ApproveCount INT 
          DECLARE @MuteCOunt INT 

          SET @RowCount=(SELECT COUNT(*) 
                         FROM   #temp) 
          SET @ApproveCount =(SELECT COUNT(*) 
                              FROM   #temp 
                              WHERE  IsApprovedOrMute = 1) 
          SET @MuteCOunt =(SELECT COUNT(*) 
                           FROM   #temp 
                           WHERE  IsApprovedOrMute = 2) 

          IF( @RowCount = @ApproveCount ) 
            BEGIN 
                SELECT *, 
                       1 AS IsApproved 
                FROM   #temp ORDER BY ID DESC
            --select 1 as IsApproved 
            END 
          ELSE IF( @RowCount = @MuteCOunt ) 
            BEGIN 
                SELECT *, 
                       2 AS IsApproved 
                FROM   #temp 
				ORDER  BY ID DESC
            END 
          ELSE 
            BEGIN 
                SELECT *, 
                       0 AS IsApproved 
                FROM   #temp ORDER BY ID DESC
            END 

          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(max); 

          SELECT @ErrorMessage = Error_message() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC Avl_inserterror 
            '[dbo].[ML_MLPatternValidation] ', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
