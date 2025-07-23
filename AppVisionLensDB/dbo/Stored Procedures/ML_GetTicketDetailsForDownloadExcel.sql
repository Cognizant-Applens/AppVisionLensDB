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
-- Author:           Devika 
-- Create date:      11 FEB 2018 
-- Description:      SP for Initial Learning 
-- Test:             [dbo].[ML_GetTicketDetailsForDownloadExcel] 276 
-- ============================================================================ 
CREATE PROCEDURE [dbo].[ML_GetTicketDetailsForDownloadExcel] --276 
  @ProjectID INT 
AS 
  BEGIN 
      BEGIN TRY 
          DECLARE @optfield NVARCHAR(MAX), 
                  @optid    INT 
          DECLARE @IniID         BIGINT, 
                  @IsRegenerated BIT 

          SELECT TOP 1 @IniID = ID, 
                       @IsRegenerated = ISNULL(IsRegenerated, 0) 
          FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
          WHERE  ProjectID = @ProjectID 
                 AND IsDeleted = 0 
          ORDER  BY ID DESC 

          PRINT @IniID 

          PRINT @IsRegenerated 

          SELECT @optfield = OptionalFields, 
                 @optid = OptionalFieldID 
          FROM   AVL.ML_MAP_OPTIONALPROJMAPPING OPM 
                 JOIN AVL.ML_MAS_OPTIONALFIELDS MASOp 
                   ON MASOp.ID = opm.OptionalFieldID 
          WHERE  projectid = @ProjectID 

         IF( @optid = 1 ) 
            BEGIN 
                SELECT DTV.TicketID                  AS 'Ticket ID', 
                       CASE 
                         WHEN DTV.TicketDescription IS NULL 
                               OR DTV.TicketDescription = '' THEN DTV.TicketDescription 
                         WHEN DTV.TicketDescription IS NOT NULL 
                               AND DTV.TicketDescription <> '' THEN '***' 
                       END                           AS 'Ticket Description', 
                       AM.ApplicationName            AS [Application Name], 
                       ATTRFM.DebtClassificationName AS 'Debt Classification', 
                       ATTRFM1.AvoidableFlagName     AS 'Avoidable Flag', 
                       ATTRFM2.[ResidualDebtName]    AS 'Residual Debt', 
                       DeptCC.[CauseCode]            AS 'Cause Code', 
                       DRC.RESOLUTIONCODE            AS 'Resolution Code', 
                       CASE 
                         WHEN OPM.OptionalFieldID = 1 THEN DTV.OptionalFieldProj 
                       END                           AS 'Resolution Remarks' 
                FROM   AVL.ML_TRN_TICKETVALIDATION DTV 
                       LEFT JOIN [AVL].[APP_MAS_APPLICATIONDETAILS] AM 
                              ON AM.ApplicationID = DTV.ApplicationID 
                       LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] ATTRFM 
                              ON ATTRFM.DebtClassificationID = DTV.[DebtClassificationId] 
                       LEFT JOIN AVL.DEBT_MAS_AVOIDABLEFLAG ATTRFM1 
                              ON ATTRFM1.AvoidableFlagID = DTV.[AvoidableFlagID] 
                       LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] ATTRFM2 
                              ON ATTRFM2.ResidualDebtID = DTV.[ResidualDebtID] 
                       LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE] DeptCC 
                              ON DTV.CauseCodeID = DeptCC.CAUSEID 
                                 AND DeptCC.ProjectID = @ProjectID 
                                 AND DeptCC.IsDeleted = 0 
                       LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] DRC 
                              ON DRC.RESOLUTIONID = DTV.ResolutionCodeID 
                                 AND DRC.ProjectID = @ProjectID 
                                 AND DRC.IsDeleted = 0 
                       JOIN AVL.ML_MAP_OPTIONALPROJMAPPING OPM 
                         ON OPM.ProjectId = DTV.ProjectID 
                            AND OPM.IsActive = 1 
                            AND DTV.IsDeleted = 0 
                            AND dtv.ProjectID = @ProjectID 
                       LEFT JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS REG 
                              ON REG.ApplicationID = DTV.ApplicationID 
                                 AND REG.InitialLearningID = @IniID 
                                 AND DTV.ProjectID = REG.ProjectID 
                                 AND REG.IsDeleted = 0 
                                 AND REG.ProjectID = @ProjectID 
                WHERE  ( ( @IsRegenerated = 1 
                           AND REG.ID IS NOT NULL ) 
                          OR ( @IsRegenerated = 0 ) ) 
            END 
          ELSE 
            BEGIN 
                SELECT DTV.TicketID                  AS 'Ticket ID', 
                       CASE 
                         WHEN DTV.TicketDescription IS NULL 
                               OR DTV.TicketDescription = '' THEN DTV.TicketDescription 
                         WHEN DTV.TicketDescription IS NOT NULL 
                               AND DTV.TicketDescription <> '' THEN '***' 
                       END                           AS 'Ticket Description', 
                       AM.ApplicationName            AS [Application Name], 
                       ATTRFM.DebtClassificationName AS 'Debt Classification', 
                       ATTRFM1.AvoidableFlagName     AS 'Avoidable Flag', 
                       ATTRFM2.[ResidualDebtName]    AS 'Residual Debt', 
                       DeptCC.[CauseCode]            AS 'Cause Code', 
                       DRC.RESOLUTIONCODE            AS 'Resolution Code ' 
                FROM   AVL.ML_TRN_TICKETVALIDATION DTV 
                       LEFT JOIN [AVL].[APP_MAS_APPLICATIONDETAILS] AM 
                              ON AM.ApplicationID = DTV.ApplicationID 
                       LEFT JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] ATTRFM 
                              ON ATTRFM.DebtClassificationID = DTV.[DebtClassificationId] 
                       LEFT JOIN AVL.DEBT_MAS_AVOIDABLEFLAG ATTRFM1 
                              ON ATTRFM1.AvoidableFlagID = DTV.[AvoidableFlagID] 
                       LEFT JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] ATTRFM2 
                              ON ATTRFM2.ResidualDebtID = DTV.[ResidualDebtID] 
                       LEFT JOIN [AVL].[DEBT_MAP_CAUSECODE] DeptCC 
                              ON DTV.CauseCodeID = DeptCC.CAUSEID 
                                 AND DeptCC.ProjectID = @ProjectID 
                                 AND DeptCC.IsDeleted = 0 
                       LEFT JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] DRC 
                              ON DRC.RESOLUTIONID = DTV.ResolutionCodeID 
                                 AND DRC.ProjectID = @ProjectID 
                                 AND DRC.IsDeleted = 0 
                       JOIN AVL.ML_MAP_OPTIONALPROJMAPPING OPM 
                         ON OPM.ProjectId = DTV.ProjectID 
                            AND OPM.IsActive = 1 
                            AND DTV.IsDeleted = 0 
                            AND dtv.ProjectID = @ProjectID 
                       LEFT JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS REG 
                              ON REG.ApplicationID = DTV.ApplicationID 
                                 AND REG.InitialLearningID = @IniID 
                                 AND DTV.ProjectID = REG.ProjectID 
                                 AND REG.IsDeleted = 0 
                                 AND REG.ProjectID = @ProjectID 
                WHERE  ( ( @IsRegenerated = 1 
                           AND REG.ID IS NOT NULL ) 
                          OR ( @IsRegenerated = 0 ) ) 
            END 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_GetTicketDetailsForDownloadExcel] ', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
