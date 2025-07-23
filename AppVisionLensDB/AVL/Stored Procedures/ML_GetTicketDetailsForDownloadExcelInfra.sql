/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================ 
-- Author:           Dhivya Bharathi M 
-- Create date:      31 July 2019
-- Description:      SP for Initial Learning Download Infra
-- Test:             [dbo].[ML_GetTicketDetailsForDownloadExcel] 276 
-- ============================================================================ 

--[AVL].[ML_GetTicketDetailsForDownloadExcelInfra]  44639
CREATE PROCEDURE [AVL].[ML_GetTicketDetailsForDownloadExcelInfra] --276 
  @ProjectID BIGINT 
AS 
  BEGIN 
      BEGIN TRY 
          DECLARE  @optid    INT 
          DECLARE @IniID  BIGINT

          SET @IniID=(SELECT TOP 1  ID FROM   AVL.ML_PRJ_InitialLearningStateInfra 
					  WHERE  ProjectID = @ProjectID AND IsDeleted = 0)

          SET  @optid =(SELECT TOP 1 OptionalFieldID 
						FROM   AVL.ML_MAP_OptionalProjMappingInfra OPM WHERE  projectid = @ProjectID AND OPM.IsDeleted=0)

          IF( @optid = 1 ) 
            BEGIN 
                SELECT DTV.TicketID  AS 'Ticket ID',
				CASE  WHEN DTV.TicketDescription IS NOT NULL AND DTV.TicketDescription <> '' THEN '***' 
					ELSE DTV.TicketDescription
                       END  AS 'Ticket Description', 
				TM.TowerName  AS [Tower Name],DC.DebtClassificationName AS 'Debt Classification', 
				AF.AvoidableFlagName    AS 'Avoidable Flag',RD.[ResidualDebtName]    AS 'Residual Debt', 
				DeptCC.[CauseCode]  AS 'Cause Code',DRC.RESOLUTIONCODE  AS 'Resolution Code',
				DTV.OptionalFieldProj AS 'Resolution Remarks' 
				FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) DTV 
				LEFT JOIN [AVL].InfraTowerDetailsTransaction(NOLOCK) TM ON TM.InfraTowerTransactionID = DTV.TowerID
				LEFT JOIN [AVL].DEBT_MAS_DebtClassificationInfra(NOLOCK) DC  ON DC.DebtClassificationID = DTV.[DebtClassificationId] 
				LEFT JOIN AVL.DEBT_MAS_AVOIDABLEFLAG(NOLOCK) AF ON AF.AvoidableFlagID = DTV.[AvoidableFlagID] 
				LEFT JOIN [AVL].DEBT_MAS_ResidualDebt(NOLOCK) RD ON RD.ResidualDebtID = DTV.[ResidualDebtID] 
				LEFT JOIN [AVL].DEBT_MAP_CauseCode(NOLOCK) DeptCC  ON DTV.ProjectID=DeptCC.ProjectID AND 
															  DTV.CauseCodeID = DeptCC.CAUSEID  AND DeptCC.IsDeleted = 0 
				LEFT JOIN [AVL].DEBT_MAP_ResolutionCode(NOLOCK) DRC ON DTV.ProjectID=DRC.ProjectID AND DRC.RESOLUTIONID = DTV.ResolutionCodeID  
																AND DRC.IsDeleted = 0 
				INNER JOIN AVL.ML_MAP_OptionalProjMappingInfra(NOLOCK) OPM  ON OPM.ProjectId = DTV.ProjectID AND OPM.IsDeleted = 0  AND DTV.IsDeleted = 0  
				LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails(NOLOCK) REG ON DTV.ProjectID=REG.ProjectID
							AND REG.TowerID = DTV.TowerID AND REG.InitialLearningID = @IniID 
				AND REG.IsDeleted = 0 
				WHERE DTV.ProjectID = @ProjectID 
            END 
          ELSE 
			BEGIN 
			SELECT DTV.TicketID  AS 'Ticket ID',
			CASE  WHEN DTV.TicketDescription IS NOT NULL AND DTV.TicketDescription <> '' THEN '***' 
					ELSE DTV.TicketDescription
                       END  AS 'Ticket Description',
			TM.TowerName  AS [Tower Name],DC.DebtClassificationName AS 'Debt Classification', 
			AF.AvoidableFlagName    AS 'Avoidable Flag',RD.[ResidualDebtName]    AS 'Residual Debt', 
			DeptCC.[CauseCode]  AS 'Cause Code',DRC.RESOLUTIONCODE  AS 'Resolution Code'
			FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) DTV 
			LEFT JOIN [AVL].InfraTowerDetailsTransaction(NOLOCK) TM ON TM.InfraTowerTransactionID = DTV.TowerID
			LEFT JOIN [AVL].DEBT_MAS_DebtClassificationInfra(NOLOCK) DC  ON DC.DebtClassificationID = DTV.[DebtClassificationId] 
			LEFT JOIN AVL.DEBT_MAS_AVOIDABLEFLAG(NOLOCK) AF ON AF.AvoidableFlagID = DTV.[AvoidableFlagID] 
			LEFT JOIN [AVL].DEBT_MAS_ResidualDebt(NOLOCK) RD ON RD.ResidualDebtID = DTV.[ResidualDebtID] 
			LEFT JOIN [AVL].DEBT_MAP_CauseCode(NOLOCK) DeptCC  ON DTV.ProjectID=DeptCC.ProjectID AND 
														  DTV.CauseCodeID = DeptCC.CAUSEID  AND DeptCC.IsDeleted = 0 
			LEFT JOIN [AVL].DEBT_MAP_ResolutionCode(NOLOCK) DRC ON DTV.ProjectID=DRC.ProjectID AND DRC.RESOLUTIONID = DTV.ResolutionCodeID  AND DRC.IsDeleted = 0 
			INNER JOIN AVL.ML_MAP_OptionalProjMappingInfra(NOLOCK) OPM  ON OPM.ProjectId = DTV.ProjectID AND OPM.IsDeleted = 0  AND DTV.IsDeleted = 0  
			LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails(NOLOCK) REG ON DTV.ProjectID=REG.ProjectID
							AND REG.TowerID = DTV.TowerID AND REG.InitialLearningID = @IniID 
			WHERE DTV.ProjectID = @ProjectID 
            END 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR  '[AVL].[ML_GetTicketDetailsForDownloadExcelInfra]', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
