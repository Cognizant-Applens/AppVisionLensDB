CREATE PROCEDURE [ML].[Infra_GetMLPatternTickets]
(
@ProjectID BIGINT 
)
AS
BEGIN
	BEGIN TRY 
          BEGIN TRAN 
		  SET NOCOUNT ON;
			DECLARE @IsDeleted INT = 0 ;
			DECLARE @CustomerID INT= 0;
			SET @CustomerID=(SELECT TOP 1 CustomerID 
                           FROM   AVL.MAS_LoginMaster (NOLOCK)
                           WHERE  ProjectID = @ProjectID 
                                  AND IsDeleted = @IsDeleted) 

					SELECT DISTINCT MV.id,
                          ISNULL(MV.InitialLearningID, 0)           AS InitialLearningID, 
                          ISNULL(AM.TowerName, '')            AS Tower, 
                          TicketPattern AS DescriptionBasePattern, 
						  CASE WHEN MV.subPattern!= '0' THEN ISNULL(MV.subPattern, '') ELSE '' END AS DescriptionSubPattern,
						  CASE WHEN MV.additionalPattern != '0' THEN ISNULL(MV.additionalPattern, '')   ELSE '' END AS ResolutionRemarksBasePattern,
						  CASE WHEN MV.additionalSubPattern != '0' THEN ISNULL(MV.additionalSubPattern, '') ELSE '' END AS  ResolutionRemarksSubPattern,
                          ISNULL(AFM.[DebtClassificationName], '')  AS DebtClassification, 
                          ISNULL(AFMM.[ResidualDebtName], '')       AS ResidualFlag, 
                          ISNULL(AFMF.[AvoidableFlagName], '')      AS AvoidableFlag,
                          ISNULL(DCC.[CauseCode], '')               AS CauseCode, 
                          ISNULL(DRC.[ResolutionCode],'')                       AS ResolutionCode	
						  INTO #TempPatternValidation
				 FROM   [ML].[InfraTRN_PatternValidation](nolock) MV 				
                 LEFT JOIN [AVL].[InfraTowerDetailsTransaction](NOLOCK) AM 
                        ON MV.TowerID = AM.InfraTowerTransactionID 
                 LEFT JOIN [AVL].[InfraTowerProjectMapping](NOLOCK) AP 
                         ON AP.TowerID = MV.TowerID 
                            AND AP.ProjectID = @ProjectID 
                 LEFT JOIN [AVL].[DEBT_MAS_DebtClassificationInfra](NOLOCK) AFM 
                        ON MV.MLDebtClassificationID = AFM.[DebtClassificationID] 
                 LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] (NOLOCK) AFMM 
                        ON MV.MLResidualFlagID = AFMM.[ResidualDebtID] 
                 LEFT JOIN [AVL].[Debt_MAS_AvoidableFlag] (NOLOCK) AFMF 
                        ON MV.MLAvoidableFlagID = AFMF.[AvoidableFlagID] 
				 LEFT JOIN [AVL].[DEBT_MAP_CauseCode](NOLOCK) DCC 
                        ON MV.MLCauseCodeID = DCC.causeid 
						AND DCC.ProjectID = @ProjectID 
                        AND DCC.IsDeleted = @IsDeleted
                 LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode](NOLOCK) DRC 
                        ON DRC.ResolutionID = MV.MLResolutionCode 
                           AND DRC.ProjectID = @ProjectID 
                           AND DRC.IsDeleted = @IsDeleted
				 WHERE  MV.ProjectID = @ProjectID 
                 AND MV.IsDeleted = @IsDeleted
                 AND AM.IsDeleted = @IsDeleted 

				 SELECT PM.ProjectName  AS [Project Name],
				 BD.TicketID  AS [Ticket ID],
				 BD.TowerName  AS [Tower Name],
				 BD.DebtClassification  AS [Debt Classification],
				 BD.AvoidableFlag AS [Avoidable Flag],
				 BD.ResidualDebt AS [Residual Debt],
				 BD.CauseCode AS [Cause Code],
				 BD.ResolutionCode AS [Resolution Code],
				 BD.TicketDescriptionPattern AS [Ticket Description Pattern],
				 BD.TicketDescriptionSubPattern AS [Ticket Description Sub Pattern],
				 BD.OptionalFieldpattern  AS [Resolution Remarks Base Pattern],
				 BD.OptionalFieldSubPattern  AS [Resolution Remarks Sub Pattern],
				 ISNULL(TPV.id,'') AS [Rule ID]
				 FROM ML.InfraBaseDetails(NOLOCK) BD  
				 LEFT JOIN avl.[MAS_ProjectMaster](NOLOCK) PM
						 ON BD.ProjectID = PM.ProjectID 
						 AND PM.IsDeleted = @IsDeleted
				 LEFT JOIN #TempPatternValidation TPV
						 ON BD.InitialLearningID = TPV.InitialLearningID
						 AND BD.TicketDescriptionPattern = TPV.DescriptionBasePattern
						 AND BD.TicketDescriptionSubPattern = TPV.DescriptionSubPattern
						 AND BD.OptionalFieldpattern = TPV.ResolutionRemarksBasePattern
						 AND BD.OptionalFieldSubPattern = TPV.ResolutionRemarksSubPattern
						 AND BD.TowerName = TPV.[Tower]
						 AND BD.DebtClassification = TPV.DebtClassification
						 AND BD.ResidualDebt = TPV.ResidualFlag 
						 AND BD.AvoidableFlag = TPV.AvoidableFlag
						 AND BD.CauseCode = TPV.CauseCode 
						 AND BD.ResolutionCode = TPV.ResolutionCode				 
						 WHERE BD.ProjectID = @ProjectID 
						 AND BD.Isdeleted = @IsDeleted			  


		  SET NOCOUNT OFF;
          COMMIT TRAN 
      END TRY 
	  BEGIN CATCH 

          DECLARE @ErrorMessage VARCHAR(max); 

          SELECT @ErrorMessage = Error_message() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC Avl_inserterror 
            '[ML].[Infra_GetMLPatternTickets]', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
END
