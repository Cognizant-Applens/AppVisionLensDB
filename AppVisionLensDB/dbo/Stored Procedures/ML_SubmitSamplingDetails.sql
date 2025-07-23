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
-- [dbo].[ML_SubmitSamplingDetails]   
-- MODIFICATION HISTORY 
-- USERID    NAME     DATE             REASON 
-- 687591    MENAKA   20-2-2019        Formatted the procedure 
-- 687591    MENAKA   20-2-2019        saving of sampling details into TicketDetail table after submitting the details 
-- =============================================   
CREATE PROCEDURE [dbo].[ML_SubmitSamplingDetails] (@UserId             NVARCHAR(50), 
                                             @ProjectID          NVARCHAR(200), 
                                             @TVP_lstDebtTickets [AVL].[InfraSaveDebtSampleTickets] READONLY)
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

          --submit sampling details to ticketsafter sampling table  
          DECLARE @LatestID INT=0 
          DECLARE @InitialLearningId INT; 

          SET @LatestID = (SELECT TOP 1 id 
                           FROM   [AVL].[ML_PRJ_INITIALLEARNINGSTATE] 
                           WHERE  projectid = @ProjectID 
                                  AND isdeleted = 0 
                           ORDER  BY id DESC) 
          SET @InitialLearningId=(SELECT id 
                                  FROM   [AVL].[ML_PRJ_INITIALLEARNINGSTATE] 
                                  WHERE  projectid = @ProjectID 
                                         AND isdeleted = 0 
                                         AND id = @LatestID) 

          CREATE TABLE #DEBTSAMPLETICKETS 
            ( 
               ticketid             NVARCHAR(MAX) NULL, 
               ticketdescription    NVARCHAR(MAX) NULL, 
               additionaltext       NVARCHAR(max), 
               debtclassificationid INT NULL, 
               avoidableflagid      INT NULL, 
               residualdebtid       INT NULL, 
               causecodeid          INT NULL, 
               resolutioncodeid     INT NULL, 
               descbaseworkpattern  NVARCHAR(1000), 
               descsubworkpattern   NVARCHAR(1000), 
               resbaseworkpattern   NVARCHAR(1000), 
               ressubworkpattern    NVARCHAR(1000), 
               applicationid        INT NULL 
            ) 

          INSERT INTO #DEBTSAMPLETICKETS 
          SELECT ticketid, 
                 ticketdescription, 
                 additionaltext, 
                 debtclassificationid, 
                 avoidableflagid, 
                 residualdebtid, 
                 causecodeid, 
                 resolutioncodeid, 
                 descbaseworkpattern, 
                 descsubworkpattern, 
                 resbaseworkpattern, 
                 ressubworkpattern, 
                 applicationid 
          FROM   @TVP_lstDebtTickets 

          UPDATE DTS 
          SET    DTS.debtclassificationid = debt.debtclassificationid 
          FROM   AVL.ML_TRN_TICKETSAFTERSAMPLING DTS 
                 JOIN #DEBTSAMPLETICKETS debt 
                   ON DTS.desc_base_workpattern = debt.descbaseworkpattern 
                 
                      AND DTS.ticketid = debt.ticketid 
          WHERE  DTS.projectid = @ProjectID 
                 AND DTS.desc_base_workpattern = debt.descbaseworkpattern 
                  
                 AND DTS.applicationid = debt.applicationid 

          UPDATE DTS 
          SET    DTS.avoidableflagid = debt.avoidableflagid 
          FROM   AVL.ML_TRN_TICKETSAFTERSAMPLING DTS 
                 JOIN #DEBTSAMPLETICKETS debt 
                   ON DTS.desc_base_workpattern = debt.descbaseworkpattern 
                    
                      AND DTS.ticketid = debt.ticketid 
          WHERE  DTS.projectid = @ProjectID 
                 AND DTS.desc_base_workpattern = debt.descbaseworkpattern 
                
                 AND DTS.applicationid = debt.applicationid 

          UPDATE DTS 
          SET    DTS.residualdebtid = debt.residualdebtid 
          FROM   AVL.ML_TRN_TICKETSAFTERSAMPLING DTS 
                 JOIN #DEBTSAMPLETICKETS debt 
                   ON DTS.desc_base_workpattern = debt.descbaseworkpattern 
                      AND DTS.ticketid = debt.ticketid 
          WHERE  DTS.projectid = @ProjectID 
                 AND DTS.desc_base_workpattern = debt.descbaseworkpattern 
                  
                 AND DTS.applicationid = debt.applicationid 

          UPDATE DTS 
          SET    DTS.causecodeid = debt.causecodeid 
          FROM   AVL.ML_TRN_TICKETSAFTERSAMPLING DTS 
                 JOIN #DEBTSAMPLETICKETS debt 
                   ON DTS.desc_base_workpattern = debt.descbaseworkpattern 
                     
                      AND DTS.ticketid = debt.ticketid 
          WHERE  DTS.projectid = @ProjectID 
                 AND DTS.desc_base_workpattern = debt.descbaseworkpattern 
                 AND DTS.applicationid = debt.applicationid 

          UPDATE DTS 
          SET    DTS.resolutioncodeid = debt.resolutioncodeid 
          FROM   AVL.ML_TRN_TICKETSAFTERSAMPLING DTS 
                 JOIN #DEBTSAMPLETICKETS debt 
                   ON DTS.desc_base_workpattern = debt.descbaseworkpattern 
                      AND DTS.ticketid = debt.ticketid 
          WHERE  DTS.projectid = @ProjectID 
                 AND 
              
                 DTS.desc_base_workpattern = debt.descbaseworkpattern 
                 
                 AND DTS.applicationid = debt.applicationid 

          UPDATE TD 
          SET    TD.Causecodemapid = TS.causecodeid, 
                 TD.DebtClassificationMapid = TS.Debtclassificationid, 
                 TD.ResidualdebtMapid = TS.residualdebtid, 
                 TD.Resolutioncodemapid = TS.Resolutioncodeid, 
                 TD.Avoidableflag = TS.Avoidableflagid, 
                 TD.DebtClassificationMode = 7, 
                 TD.ModifiedDate = GETDATE(), 
                 TD.LastUpdatedDate = GETDATE(), 
                 TD.ModifiedBy = @UserId 
          FROM   [AVL].[TK_TRN_TICKETDETAIL] TD 
                 INNER JOIN AVL.ML_TRN_TICKETSAFTERSAMPLING TS 
                         ON TD.ticketid = TS.ticketid 
                            AND TD.projectid = TS.projectid 
                            AND TD.applicationid = TS.applicationid 
          WHERE  TD.projectid = @ProjectID 
                 AND TS.isdeleted = 0 
                 AND TD.isdeleted = 0 

          --updating [IsSamplingInProgress]=Submitted  
          UPDATE AVL.ML_PRJ_INITIALLEARNINGSTATE 
          SET    [issamplinginprogress] = 'Submitted' 
          WHERE  projectid = @ProjectID 
                 AND id = @InitialLearningId 

          UPDATE AVL.ML_PRJ_INITIALLEARNINGSTATE 
          SET    ismlsentorreceived = 'Sent' 
          WHERE  projectid = @ProjectID 
                 AND id = @InitialLearningId 

          --criteria check for ml  
          DECLARE @TotalTickets DECIMAL(18, 2); 
          DECLARE @ValidTDescription DECIMAL(18, 2); 
          DECLARE @ValidDebtFields DECIMAL(18, 2); 
          DECLARE @InitialID BIGINT; 
          DECLARE @IsRegenerated BIT; 
          DECLARE @ValidTicketDescPercent DECIMAL(18, 2) 
          DECLARE @ValidTicketDebtFieldsPercent DECIMAL(18, 2) 
          DECLARE @IsConditionMetForTDesc NVARCHAR(10); 
          DECLARE @IsConditionMetForDebtFields NVARCHAR(10); 

          SET @InitialID=(SELECT TOP 1 ISNULL(id, 0) 
                          FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                          WHERE  projectid = @ProjectID 
                                 AND isdeleted = 0 
                          ORDER  BY id DESC) 
          SET @IsRegenerated=(SELECT TOP 1 ISNULL(isregenerated, 0) 
                              FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                              WHERE  projectid = @ProjectID 
                                     AND isdeleted = 0 
                              ORDER  BY id DESC) 

          IF( @IsRegenerated = 1 ) 
            BEGIN 
                SET @TotalTickets= (SELECT Count(*) 
                                    FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) IT 
                                           JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS REG 
                                             ON IT.projectid = REG.projectid 
                                                AND IT.applicationid = REG.applicationid 
                                                AND REG.initiallearningid = @InitialID 
                                    WHERE  IT.projectid = @ProjectID); 
                SET @ValidTDescription= (SELECT Count(*) 
                                         FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) IT 
                                                JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS REG
                                                  ON IT.projectid = REG.projectid 
                                                     AND IT.applicationid = REG.applicationid 
                                                     AND REG.initiallearningid = @InitialID 
                                         WHERE  IT.projectid = @ProjectID 
                                                AND ticketdescription IS NOT NULL 
                                                AND ticketdescription <> '' 
                                                AND IT.isdeleted = 0 
                                                AND REG.isdeleted = 0); 
                SET @ValidDebtFields= (SELECT Count(*) 
                                       FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) IT 
                                              JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS REG 
                                                ON IT.projectid = REG.projectid 
                                                   AND IT.applicationid = REG.applicationid 
                                                   AND REG.initiallearningid = @InitialID 
                                       WHERE  IT.projectid = @ProjectID 
                                              AND REG.isdeleted = 0 
                                              AND IT.isdeleted = 0 
                                              AND debtclassificationid IS NOT NULL 
                                              AND avoidableflagid IS NOT NULL 
                                              AND causecodeid IS NOT NULL 
                                              AND resolutioncodeid IS NOT NULL 
                                              AND residualdebtid IS NOT NULL) 
            END 
          ELSE 
            BEGIN 
                SET @TotalTickets=(SELECT Count(*) 
                                   FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) 
                                   WHERE  projectid = @ProjectID); 
                SET @ValidTDescription=(SELECT Count(*) 
                                        FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) 
                                        WHERE  projectid = @ProjectID 
                                               AND ticketdescription IS NOT NULL 
                                               AND ticketdescription <> ''); 
                SET @ValidDebtFields=(SELECT Count(*) 
                                      FROM   AVL.ML_TRN_TICKETVALIDATION(NOLOCK) 
                                      WHERE  projectid = @ProjectID 
                                             AND debtclassificationid IS NOT NULL 
                                             AND avoidableflagid IS NOT NULL 
                                             AND causecodeid IS NOT NULL 
                                             AND resolutioncodeid IS NOT NULL 
                                             AND residualdebtid IS NOT NULL) 
            END 

          SET @ValidTicketDescPercent= ( ( @ValidTDescription / @TotalTickets ) * 100 ); 
          SET @ValidTicketDebtFieldsPercent= ( ( @ValidDebtFields / @TotalTickets ) * 100 ); 

          IF @ValidTicketDescPercent >= 80 
            BEGIN 
                SET @IsConditionMetForTDesc='Y' 
            END 
          ELSE 
            BEGIN 
                SET @IsConditionMetForTDesc='N' 
            END 

          IF @ValidTicketDebtFieldsPercent >= 80 
            BEGIN 
                SET @IsConditionMetForDebtFields='Y' 
            END 
          ELSE 
            BEGIN 
                SET @IsConditionMetForDebtFields='N' 
            END 

          --Block to check whether for sampling or for ticket upload/download or ML  
          IF @IsConditionMetForTDesc = 'Y' 
             AND @IsConditionMetForDebtFields = 'Y' 
            BEGIN 
                SELECT 'ML' AS CriteriaMet 
            --Direct ML  
            END 
          ELSE IF @IsConditionMetForTDesc = 'Y' 
             AND @IsConditionMetForDebtFields = 'N' 
            BEGIN 
                SELECT 'Sampling' AS CriteriaMet 
            --Sampling  
            END 
          ELSE 
            BEGIN 
                SELECT 'Excel' AS CriteriaMet 
            --Download/Upload  
            END 

          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          --INSERT Error      
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_SubmitSamplingDetails] ', 
            @ErrorMessage, 
            @ProjectID, 
            @UserId 
      END CATCH 
  END
