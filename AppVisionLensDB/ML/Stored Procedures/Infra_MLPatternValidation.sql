-- ============================================= 
-- Author:    835658 
-- Create date: 28-07-2020
-- Description:   SP for Initial Learning 
-- [ML].[Infra_MLPatternValidation]  20027 ,'12/03/2018','1/17/2020','627384' 
-- =============================================  
CREATE PROCEDURE [ML].[Infra_MLPatternValidation] 
(@ProjectID BIGINT, 
 @FromDate  DATETIME =NULL, 
 @ToDate    DATETIME=NULL, 
 @UserID    NVARCHAR(50)=NULL,
 @TVP_InfraDetails TVP_MLInfraDetails READONLY) 
AS  
  BEGIN 
      BEGIN TRY 
	  
          BEGIN TRAN 
		  SET NOCOUNT ON;
          DECLARE @CustomerID INT= 0; 
		  DECLARE @IsDelete INT = 0 ;
          DECLARE @IsCognizantID INT;        
          DECLARE @IsRdSignoff     BIT; 
          SET @CustomerID=(SELECT TOP 1 CustomerID 
                           FROM   AVL.MAS_LoginMaster(NOLOCK) 
                           WHERE  ProjectID = @ProjectID 
                                  AND IsDeleted = @IsDelete) 
          SET @IsCognizantID=(SELECT TOP 1 IsCognizant 
                              FROM   AVL.Customer (NOLOCK)
                              WHERE  CustomerID = @CustomerID 
                                     AND IsDeleted = @IsDelete) 
          SELECT MV.* 
          INTO   #debt_mlpatternvalidation 
          FROM   [ML].[InfraTRN_PatternValidation](nolock) MV
				 JOIN @TVP_InfraDetails TAD 
				       ON MV.TowerID=TAD.TowerID
          WHERE  MV.ProjectID  = @ProjectID 
                 AND MV.IsDeleted = @IsDelete 
		  CREATE TABLE #maxids 
          ( 
               TowerID        NVARCHAR(MAX), 
               ticketpattern        NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS, 
               subpattern           NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS, 
               additionalpattern    NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS, 
               additionalsubpattern NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS, 
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
						TowerID, 
						TicketPattern, 
						subPattern, 
						additionalPattern, 
						additionalSubPattern, 
						MLCauseCodeID, 
						MLResolutionCode,
						MAX(ID) AS TickID
			  FROM #debt_mlpatternvalidation 
			  WHERE TicketPattern <> '0' AND (IsApprovedOrMute = 1 OR IsApprovedOrMute = 2)
			  GROUP  BY TowerID, 
						TicketPattern, 
						subPattern, 
						additionalPattern, 
						additionalSubPattern, 
						MLCauseCodeID, 
						MLResolutionCode
          -- If a pattern is not Approved or Muted, then take the highest accuracy
		   INSERT INTO #maxids
			  SELECT    PV.TowerID, 
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
							 PV.TowerID, 
							 PV.TicketPattern, 
							 PV.subPattern, 
							 PV.additionalPattern, 
							 PV.additionalSubPattern, 
							 MLCauseCodeID, 
							 MLResolutionCode,
							 MAX(MLAccuracy) AS MaxAccuracy
				  FROM #debt_mlpatternvalidation PV
				  LEFT JOIN #maxids MX 
					ON MX.TowerID = PV.TowerID AND MX.TicketPattern = PV.TicketPattern 
						AND MX.subPattern = PV.subPattern AND MX.additionalPattern = PV.additionalPattern 
						AND MX.additionalSubPattern = PV.additionalSubPattern AND MX.causecode = PV.mlcausecodeid 
						AND MX.resolutioncode = PV.MLResolutionCode
				  WHERE  PV.TicketPattern <> '0' AND MX.TowerID IS NULL
				  GROUP  BY  PV.TowerID, 
							 PV.TicketPattern, 
							 PV.subPattern, 
							 PV.additionalPattern, 
							 PV.additionalSubPattern, 
							 MLCauseCodeID, 
							 MLResolutionCode
			) AS MA 
				ON MA.TowerID = PV.TowerID AND MA.TicketPattern = PV.TicketPattern 
					AND MA.subPattern = PV.subPattern AND MA.additionalPattern = PV.additionalPattern 
					AND MA.additionalSubPattern = PV.additionalSubPattern AND MA.MLCauseCodeID = PV.mlcausecodeid 
					AND MA.MLResolutionCode = PV.MLResolutionCode AND MA.MaxAccuracy = PV.MLAccuracy
			GROUP BY  PV.TowerID, 
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
                               FROM   [ML].[InfraTRN_PatternValidation]
                               WHERE  ProjectID  = @ProjectID 
                                      AND IsDeleted = @IsDelete
                                      AND OverridenPatternCount = 1)           
          UPDATE PVD
		  SET PVD.OverridenPatternTotalCount = @OveridenCount
		  FROM [ML].[InfraTRN_PatternValidation] PVD
				 JOIN @TVP_InfraDetails TAD
					  ON PVD.TowerID = TAD.TowerID
						 AND PVD.IsDeleted=0
          --Checking whether the patters are regenerated,if it is then gets the latest ID from Initial Learning state.
          UPDATE p 
          SET    p.IsMLSignoff = CASE 
                                 WHEN PD.IsMLSignOffInfra = '1' THEN 1 
                                 ELSE 0 
                                 END 
          FROM   [ML].[InfraTRN_PatternValidation] p 
                       LEFT JOIN [AVL].[MAS_ProjectDebtDetails] PD 
                              ON PD.ProjectID = p.ProjectID
					   JOIN @TVP_InfraDetails TAD
		                      ON p.TowerID = TAD.TowerID
          WHERE  p.ProjectID = @ProjectID 
                       AND p.IsDeleted = @IsDelete 
                       AND PD.IsDeleted = @IsDelete
          --select * from #tempMaxIDs where ticketpattern='apslp0169 message id'  
          SELECT DISTINCT MV.id, 
                          ISNULL(MV.InitialLearningID, 0)           AS InitialLearningID, 
                          ISNULL(MV.TowerId, 0)                     AS TowerID, 
                          ISNULL(AMR.TowerName, '')				    AS [Tower],                          
                          TicketPattern AS DescriptionBasePattern, 
                          OverridenPatternTotalCount, 
                          ISNULL(MLDebtClassificationID, 0)         AS MLDebtClassificationID, 
                          ISNULL(DC.[DebtClassificationName], '')  AS DebtClassification, 
                          ISNULL(MLResidualFlagID, 0)               AS MLResidualFlagID, 
                          ISNULL(AFMM.[ResidualDebtName], '')       AS ResidualFlag, 
                          ISNULL(MLAvoidableFlagID, 0)              AS MLAvoidableFlagID, 
                          ISNULL(AFMF.[AvoidableFlagName], '')      AS AvoidableFlag, 
                          ISNULL(MLCauseCodeID, 0)                  AS MLCauseCodeID, 
                          ISNULL(DCC.[CauseCode], '')               AS CauseCode, 
                          MLAccuracy                                AS MLAccuracy, 
						  TicketOccurence,        
						  ISNULL(IsApprovedOrMute, 0)				AS IsApprovedOrMute,
						  CASE WHEN ISNULL(IsApprovedOrMute, 0) = 1 
							   THEN CAST(1 AS BIT)		
							   ELSE CAST(0 AS BIT)		END				AS IsApproved,
						  CASE WHEN ISNULL(IsApprovedOrMute, 0) = 1 THEN 'Approve'     
							   WHEN ISNULL(IsApprovedOrMute, 0) = 2 THEN 'Mute'  
							   WHEN ISNULL(IsApprovedOrMute, 0) = 0 THEN ''   
						       END AS ApprovedOrMute,					
                          ISNULL(MLResolutionCode, '')              AS MLResolutionCodeID, 
                          DRC.ResolutionCode                        AS ResolutionCode,
						  CASE WHEN MV.subPattern!= '0' THEN ISNULL(MV.subPattern, '') ELSE '' END AS DescriptionSubPattern,
						  CASE WHEN MV.additionalPattern != '0' THEN ISNULL(MV.additionalPattern, '')   ELSE '' END AS ResolutionRemarksBasePattern,
						  CASE WHEN MV.additionalSubPattern != '0' THEN ISNULL(MV.additionalSubPattern, '') ELSE '' END AS  ResolutionRemarksSubPattern,
                          ISNULL(MV.IsMLSignoff, 0)                 AS ISMLSignoff,
						  ISNULL(MV.MLOverriddenId, 0)              AS MLOverriddenRule,
						  MV.CreatedDate,
						  MV.CreatedBy                            
          INTO   #temp 
          FROM   [ML].[InfraTRN_PatternValidation](nolock) MV 
				LEFT JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) AMR
					ON MV.TowerID = AMR.InfraTowerTransactionID
				INNER JOIN AVL.InfraHierarchyMappingTransaction(NOLOCK) IHT
					ON IHT.CustomerID=AMR.CustomerID
					AND IHT.InfraTransMappingID=AMR.InfraTransMappingID
					AND ISNULL(IHT.IsDeleted,0)=0  
				INNER JOIN  AVL.InfraHierarchyOneTransaction(NOLOCK) IOT
					ON IHT.CustomerID=IOT.CustomerID 
					AND IHT.HierarchyOneTransactionID=IOT.HierarchyOneTransactionID 
					AND IOT.IsDeleted=0
				INNER JOIN AVL.InfraHierarchyTwoTransaction(NOLOCK) ITT 
					ON IHT.CustomerID=ITT.CustomerID 
					AND IHT.HierarchyTwoTransactionID=ITT.HierarchyTwoTransactionID 
					AND ITT.IsDeleted=0 
				INNER JOIN AVL.InfraTowerProjectMapping(NOLOCK) IPM  
					ON AMR.InfraTowerTransactionID=IPM.TowerID
				LEFT JOIN [AVL].DEBT_MAS_DebtClassificationInfra(NOLOCK) DC
					ON MV.MLDebtClassificationID = DC.DebtClassificationID
				LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] (NOLOCK) AFMM 
                    ON MV.MLResidualFlagID = AFMM.[ResidualDebtID] 
				LEFT JOIN [AVL].[Debt_MAS_AvoidableFlag](NOLOCK) AFMF 
                    ON MV.MLAvoidableFlagID = AFMF.[AvoidableFlagID] 
				LEFT JOIN [AVL].[DEBT_MAP_CauseCode](NOLOCK) DCC 
                    ON MV.MLCauseCodeID = DCC.causeid 
				    AND DCC.ProjectID = @ProjectID 
                    AND DCC.IsDeleted = @IsDelete
				LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode](NOLOCK) DRC 
                    ON DRC.ResolutionID = MV.MLResolutionCode 
                    AND DRC.ProjectID = @ProjectID 
                    AND DRC.IsDeleted = @IsDelete		
				JOIN @TVP_InfraDetails TAD 
				    ON MV.TowerID=TAD.TowerID
				    AND MV.ProjectID=@ProjectID
				    AND MV.IsDeleted=0

		WHERE  MV.ProjectID = @ProjectID 
					AND MV.IsDeleted = @IsDelete 
					AND ticketpattern <> '0' 
					AND ( MV.MLCauseCodeID IS NOT NULL 
                        AND MV.mlcausecodeid <> 0 ) 
					AND ( MV.MLResolutionCode IS NOT NULL 
                        AND MV.MLResolutionCode <> 0 ) 
					AND ( MV.MLDebtClassificationID IS NOT NULL 
                        AND MV.MLDebtClassificationID <> 0 ) 
					AND ( MV.MLAvoidableFlagID IS NOT NULL 
                        AND MV.MLAvoidableFlagID <> 0 ) 
					AND ( MV.MLResidualFlagID IS NOT NULL 
                        AND MV.MLResidualFlagID <> 0 )                 
					AND IHT.CustomerID = @CustomerID 
					AND ( ISNULL(@FromDate,'')=''  OR CONVERT(date, @FromDate) <=  CONVERT(date, Mv.CreatedDate))
					AND ( ISNULL(@ToDate,'')='' OR  CONVERT(date, @ToDate) >=  CONVERT(date, Mv.CreatedDate))
		ORDER by MV.CreatedDate DESC

		SELECT * FROM   #temp ORDER BY ID DESC

		SET NOCOUNT OFF;

          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(max); 
          SELECT @ErrorMessage = Error_message() 
          ROLLBACK TRAN 
          --INSERT Error     
   EXEC Avl_inserterror 
            '[ML].[Infra_MLPatternValidation]', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
