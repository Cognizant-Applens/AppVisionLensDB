-- ============================================= 
-- Author:    683989 
-- Create date: 06-JAN-2020
-- Description:   SP for Initial Learning 
-- [ML].[MLPatternValidation]  20027 ,'12/03/2018','1/17/2020','627384' 
-- =============================================  
CREATE PROCEDURE [ML].[MLPatternValidation] 
(@ProjectID BIGINT, 
 @FromDate  DATETIME =NULL, 
 @ToDate    DATETIME=NULL, 
 @UserID    NVARCHAR(50)=NULL,
 @TVP_ApplicationDetails TVP_MLApplicationDetails READONLY) 
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
          FROM   [ML].[TRN_PatternValidation](nolock) MV
				 JOIN @TVP_ApplicationDetails TAD 
				       ON MV.ApplicationID=TAD.ApplicationID
          WHERE  MV.ProjectID  = @ProjectID 
                 AND MV.IsDeleted = @IsDelete 
				
		  CREATE TABLE #maxids 
          ( 
               ApplicationID        NVARCHAR(MAX), 
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
                               FROM   [ML].[TRN_PatternValidation](NOLOCK)
                               WHERE  ProjectID  = @ProjectID 
                                      AND IsDeleted = @IsDelete
                                      AND OverridenPatternCount = 1)           

          UPDATE PVD
		  SET PVD.OverridenPatternTotalCount = @OveridenCount
		  FROM [ML].[TRN_PatternValidation] PVD
				 JOIN @TVP_ApplicationDetails TAD
					  ON PVD.ApplicationID = TAD.ApplicationID
						 AND PVD.IsDeleted=0

          --Checking whether the patters are regenerated,if it is then gets the latest ID from Initial Learning state.
    
          UPDATE p 
          SET    p.IsMLSignoff = CASE 
                                 WHEN PD.IsMLSignoff = '1' THEN 1 
                                 ELSE 0 
                                 END 
          FROM   [ML].[TRN_PatternValidation] p 
                       LEFT JOIN [AVL].[MAS_ProjectDebtDetails] PD 
                              ON PD.ProjectID = p.ProjectID
					   JOIN @TVP_ApplicationDetails TAD
		                      ON p.ApplicationID = TAD.ApplicationID
          WHERE  p.ProjectID = @ProjectID 
                       AND p.IsDeleted = @IsDelete 
                       AND PD.IsDeleted = @IsDelete
					   
          --select * from #tempMaxIDs where ticketpattern='apslp0169 message id'  
          SELECT DISTINCT MV.id, 
                          ISNULL(MV.InitialLearningID, 0)           AS InitialLearningID, 
                          ISNULL(MV.ApplicationID, 0)               AS ApplicationID, 
                          ISNULL(AM.ApplicationName, '')            AS [Application], 
                          ISNULL(MV.ApplicationTypeID, 0)           AS ApplicationTypeID, 
                          ISNULL(AT.ApplicationTypeName, '')        AS ApplicationTypeName, 
                          ISNULL(MV.TechnologyID, 0)                AS TechnologyID, 
                          ISNULL(MT.[PrimaryTechnologyName], '')    AS TechnologyName, 
                          TicketPattern AS DescriptionBasePattern, 
                          OverridenPatternTotalCount, 
                          ISNULL(MLDebtClassificationID, 0)         AS MLDebtClassificationID, 
                          ISNULL(AFM.[DebtClassificationName], '')  AS DebtClassification, 
                          ISNULL(MLResidualFlagID, 0)               AS MLResidualFlagID, 
                          ISNULL(AFMM.[ResidualDebtName], '')       AS ResidualFlag, 
                          ISNULL(MLAvoidableFlagID, 0)              AS MLAvoidableFlagID, 
                          ISNULL(AFMF.[AvoidableFlagName], '')      AS AvoidableFlag, 
                          ISNULL(MLCauseCodeID, 0)                  AS MLCauseCodeID, 
                          ISNULL(DCC.[CauseCode], '')               AS CauseCode, 
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
						  ISNULL(IsApprovedOrMute, 0)				AS IsApprovedOrMute,
						  CASE WHEN ISNULL(IsApprovedOrMute, 0) = 1 
							THEN CAST(1 AS BIT)		
							ELSE CAST(0 AS BIT)		END				AS IsApproved,
							CASE WHEN ISNULL(IsApprovedOrMute, 0) = 1 THEN 'Approve'     
							   WHEN ISNULL(IsApprovedOrMute, 0) = 2 THEN 'Mute'  
							   WHEN ISNULL(IsApprovedOrMute, 0) = 0 THEN ''   
						  END AS ApprovedOrMute,					
                          DCC1.[CauseCode]                          AS SMECauseCodeName, 
                          ISNULL(MLResolutionCode, '')              AS MLResolutionCodeID, 
                          DRC.ResolutionCode                        AS ResolutionCode,
						  CASE WHEN MV.subPattern!= '0' THEN ISNULL(MV.subPattern, '') ELSE '' END AS DescriptionSubPattern,
						  CASE WHEN MV.additionalPattern != '0' THEN ISNULL(MV.additionalPattern, '')   ELSE '' END AS ResolutionRemarksBasePattern,
						  CASE WHEN MV.additionalSubPattern != '0' THEN ISNULL(MV.additionalSubPattern, '') ELSE '' END AS  ResolutionRemarksSubPattern,
                          --ISNULL(MV.subPattern, '')                 AS DescriptionSubPattern, 
                          --ISNULL(MV.additionalPattern, '')          AS ResolutionRemarksBasePattern, 
                         -- ISNULL(MV.additionalSubPattern, '')       AS ResolutionRemarksSubPattern, 
                          ISNULL(MV.IsMLSignoff, 0)                 AS ISMLSignoff,
						  ISNULL(MV.MLOverriddenId, 0)              AS MLOverriddenRule,
						  MV.CreatedDate,
						  MV.CreatedBy                            
          INTO   #temp 
          FROM   [ML].[TRN_PatternValidation](nolock) MV 
                 LEFT JOIN avl.[App_MAS_ApplicationDetails](NOLOCK) AM 
                        ON MV.ApplicationID = AM.ApplicationID 
                 LEFT JOIN avl.BusinessClusterMapping (NOLOCK)BCM 
                        ON AM.SubBusinessClustermapid = BCM.BusinessClusterMapID
                           AND BCM.IsDeleted = @IsDelete
                           AND BCM.customerid = @CustomerID 
                 LEFT JOIN [AVL].[App_MAP_ApplicationProjectMapping] (NOLOCK)AP 
                         ON AP.ApplicationID = MV.ApplicationID 
                            AND AP.ProjectID = @ProjectID 
                 LEFT JOIN avl.[APP_MAS_OwnershipDetails](NOLOCK) AT 
                        ON AM.[CodeOwnerShip] = AT.ApplicationTypeID 
                 LEFT JOIN avl.[APP_MAS_PrimaryTechnology](NOLOCK) MT 
          ON AM.[PrimaryTechnologyID] = MT.[PrimaryTechnologyID] 
                 LEFT JOIN [AVL].[DEBT_MAS_DebtClassification](NOLOCK) AFM 
                        ON MV.MLDebtClassificationID = AFM.[DebtClassificationID] 
                 LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt](NOLOCK) AFMM 
                        ON MV.MLResidualFlagID = AFMM.[ResidualDebtID] 
                 LEFT JOIN [AVL].[Debt_MAS_AvoidableFlag](NOLOCK) AFMF 
                        ON MV.MLAvoidableFlagID = AFMF.[AvoidableFlagID] 
        LEFT JOIN [AVL].[DEBT_MAP_CauseCode] (NOLOCK)DCC 
                        ON MV.MLCauseCodeID = DCC.causeid 
              AND DCC.ProjectID = @ProjectID 
                           AND DCC.IsDeleted = @IsDelete
    LEFT JOIN [AVL].[DEBT_MAP_CauseCode] (NOLOCK)DCC2 
                        ON MV.AnalystCauseCodeID = DCC2.[CauseID] 
                           AND DCC2.ProjectID = @ProjectID 
  AND DCC2.IsDeleted = @IsDelete
                 LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] (NOLOCK)DRC 
                        ON DRC.ResolutionID = MV.MLResolutionCode 
                           AND DRC.ProjectID = @ProjectID 
                           AND DRC.IsDeleted = @IsDelete
                 LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] (NOLOCK)DRC1 
                        ON MV.AnalystResolutionCodeID = DRC1.[ResolutionID] 
                           AND DRC1.ProjectID = @ProjectID 
                           AND DRC1.IsDeleted = @IsDelete
                 LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] (NOLOCK)AFM1 
                        ON MV.AnalystDebtClassificationID = AFM1.[DebtClassificationID] 
                 LEFT JOIN [AVL].[Debt_MAS_AvoidableFlag] (NOLOCK)AFMF2 
                        ON MV.AnalystAvoidableFlagID = AFMF2.[AvoidableFlagID] 
                 LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] (NOLOCK) AFM3 
                        ON MV.SMEDebtClassificationID = AFM3.[DebtClassificationID] 
                 LEFT JOIN [AVL].[Debt_MAS_AvoidableFlag] (NOLOCK) AFMF4 
                        ON MV.SMEAvoidableFlagID = AFMF4.[AvoidableFlagID] 
                 LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] (NOLOCK)AFMF5 
                        ON MV.SMEResidualFlagID = AFMF5.[ResidualDebtID] 
                 LEFT JOIN [AVL].[DEBT_MAP_CauseCode] (NOLOCK)DCC1 
                        ON MV.SMECauseCodeID = DCC1.[CauseID] 
                           AND DCC1.ProjectID = @ProjectID 
                           AND DCC1.IsDeleted = @IsDelete 
				 JOIN @TVP_ApplicationDetails TAD 
						ON MV.ApplicationID=TAD.ApplicationID
						AND MV.ProjectID=@ProjectID
						AND MV.IsDeleted=0
          WHERE  MV.ProjectID = @ProjectID 
                 AND MV.IsDeleted = @IsDelete 
                 --AND MV.id IN(SELECT tickid 
                 --             FROM   #tempmaxids) 
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
                 AND BCM.CustomerID = @CustomerID 
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
            '[ML].[MLPatternValidation]', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
