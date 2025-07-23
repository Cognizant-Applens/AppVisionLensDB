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
-- Test:             EXEC [dbo].[ML_GetMLDetailsOnLoad] 10337,'AfterProcess' 
-- ============================================================================ 
CREATE PROCEDURE [dbo].[ML_GetMLDetailsOnLoad] 
  @ProjectID INT=NULL, 
  @Step      NVARCHAR(1000) 
AS 
  BEGIN 
      BEGIN TRY 
          DECLARE @ErrorMessage NVARCHAR(MAX); 
          DECLARE @MlReceiveddate NVARCHAR(MAX); 
          DECLARE @NoiseSentDate NVARCHAR(MAX); 
          DECLARE @TransactionID INT 
          DECLARE @LatestID INT=0 
          DECLARE @RegStartDate DATETIME, 
                  @RegEndDate   DATETIME 

          --Getting the latest initial learning id 
          SET @LatestID = (SELECT TOP 1 ID 
                           FROM   [AVL].[ML_PRJ_INITIALLEARNINGSTATE] 
                           WHERE  projectid = @ProjectID 
                                  AND IsDeleted = 0 
                           ORDER  BY id DESC) 
          SET @RegStartDate=(SELECT TOP 1 FromDate 
                             FROM   AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS 
                             WHERE  InitialLearningID = @LatestID 
                                    AND IsDeleted = 0) 
          SET @RegEndDate=(SELECT TOP 1 ToDate 
                           FROM   AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS 
                           WHERE  InitialLearningID = @LatestID 
                                  AND IsDeleted = 0) 

          IF @Step = 'AfterProcess' 
            BEGIN 
                --- To get the on load details of a project 
                DECLARE @TotalPatternCount INT; 
                DECLARE @ApprovedCount INT; 
                DECLARE @MuteCount INT; 
                DECLARE @RegenerateCount INT; 

                --to get the flag which represent whether the present initial learning trn is regenerated one 
                SET @RegenerateCount = (SELECT TOP 1 ISNULL(IsRegenerated, 0) 
                                        FROM   [AVL].[ML_PRJ_INITIALLEARNINGSTATE] 
                                        WHERE  projectid = @ProjectID 
                                               AND ID = @LatestID) 
                SET @TransactionID=(SELECT TOP 1 ID 
                                    FROM   [AVL].[ML_TRN_MLSAMPLINGJOBSTATUS] 
                                    WHERE  ProjectID = @ProjectID 
                                    ORDER  BY ID DESC) 
                SET @ErrorMessage=(SELECT TOP 1 MBS.JobMessage 
                                   FROM   [AVL].[ML_PRJ_INITIALLEARNINGSTATE] ISS 
                                          INNER JOIN [AVL].[ML_TRN_MLSAMPLINGJOBSTATUS] MBS 
                                                  ON ISS.ProjectID = MBS.ProjectID 
                                                     AND ISS.ID = MBS.InitialLearningID 
                                   WHERE  ISS.ProjectID = @ProjectID 
                                          AND MBS.ID = @TransactionID 
                                          AND MLSamplingStatus = 'KILLED' 
                                          AND IsDARTProcessed = 'Y' 
                                          AND ISS.IsDeleted = 0) 
                SET @MlReceiveddate=(SELECT TOP 1 ISNULL(CONVERT(VARCHAR(10), ModifiedOn, 110), '') AS ModifiedOn 
                                     FROM   [AVL].[ML_TRN_MLSAMPLINGJOBSTATUS] 
                                     WHERE  jobtype = 'ML' 
                                            AND PROJECTID = @ProjectID 
                                     ORDER  BY ID DESC) 
                SET @NoiseSentDate=(SELECT TOP 1 ISNULL(CONVERT(VARCHAR(10), CreatedOn, 110), '') AS CreatedOn 
                                    FROM   [AVL].[ML_TRN_MLSAMPLINGJOBSTATUS] 
                                    WHERE  jobtype = 'NoiseEl' 
                                           AND PROJECTID = @ProjectID 
                                    ORDER  BY ID DESC) 

                IF( EXISTS(SELECT * 
                           FROM   AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                           WHERE  projectid = @ProjectID 
                                  AND jobtype = 'Sampling' 
                                  AND IsDeleted = 0 
                                  AND InitialLearningId = @LatestID) ) 
                  BEGIN 
                      SELECT ISNULL(CONVERT(VARCHAR(10), stat.[StartDate], 110), '') AS [StartDate], 
                             CONVERT(VARCHAR(10), stat.[EndDate], 110)               AS [EndDate], 
                             stat.[IsSDTicket], 
                             stat.[IsDartTicket], 
                             ISNULL(stat.IsMLSentOrReceived, 'N')                    AS MLStatus,
                             ISNULL(stat.IsSamplingInProgress, 'N')                  AS SamplingInProgressStatus,
                             ISNULL(stat.IsSamplingSentOrReceived, 'N')              AS SamplingSentOrReceivedStatus,
                             ISNULL(stat.IsNoiseEliminationSentorReceived, 'N')      AS IsNoiseEliminationSentorReceived,
                             ISNULL(@ErrorMessage, '')                               AS ErrorMessage,
                             ISNULL(stat.IsRegenerated, 0)                           AS IsRegenerated,
                             @RegStartDate                                           AS RegStartDate,
                             @RegEndDate                                             AS RegEndDate,
                             (SELECT TOP 1 Employeename 
                              FROM   [AVL].[MAS_LOGINMASTER] loginmas 
                              WHERE  loginmas.UserID = stat.SentBy 
                                     AND loginmas.isdeleted = 0 
                                     AND stat.IsDeleted = 0)                         AS MLSentBy,
                             ISNULL(CONVERT(VARCHAR(10), stat.SentOn, 110), '')      AS MLSentDate,
                             ISNULL(CONVERT(VARCHAR(10), job. createdOn, 110), '')   AS SamplingSentDate,
                             @NoiseSentDate                                          AS NoiseSentDate,
                             ISNULL(@NoiseSentDate, Getdate())                       AS DataValidationDate,
                             (SELECT TOP 1 LOGINMAS.EmployeeName 
                              FROM   [AVL].[MAS_LOGINMASTER] loginmas 
                              WHERE  loginmas.UserID = job.createdby 
                                     AND loginmas.isdeleted = 0 
                                     AND stat.IsDeleted = 0)                         AS SamplingSentBy,
                             @MlReceiveddate                                         AS MlReceiveddate,
                             CASE WHEN OM.ID is NULL then 4 ELSE  OP.OptionalFieldID END                                    AS 'OptionalFieldID'
                      FROM   [AVL].[ML_PRJ_INITIALLEARNINGSTATE] stat 
                             JOIN [AVL].[ML_TRN_MLSAMPLINGJOBSTATUS] job 
                               ON stat.ProjectID = job.ProjectID 
                             JOIN AVL.ML_MAP_OPTIONALPROJMAPPING OP 
                               ON OP.ProjectId = job.ProjectID 
                                  AND stat.ProjectID = OP.ProjectId 
                                  AND OP.IsActive = 1 
								  LEFT JOIN AVL.ML_MAS_OptionalFields OM ON OM.ID=OP.OptionalFieldID
								  AND OM.IsDeleted=0
                      WHERE  stat.ProjectID = @ProjectID 
                             AND job.jobtype = 'Sampling' 
                             AND stat.IsDeleted = 0 
                             AND job.id = @TransactionID 
                             AND stat.ID = @LatestID 

                      SET @TotalPatternCount=(SELECT COUNT(DMPV.ID) 
                                              FROM   AVL.ML_TRN_MLPATTERNVALIDATION(NOLOCK) DMPV
                                              WHERE  DMPV.ProjectId = @ProjectID 
                                                     AND DMPV.IsDeleted = 0) 
                      SET @ApprovedCount=(SELECT COUNT(DMPV.ID) 
                                          FROM   AVL.ML_TRN_MLPATTERNVALIDATION(NOLOCK) DMPV 
                                          WHERE  DMPV.ProjectId = @ProjectID 
                                                 AND DMPV.IsApprovedOrMute = 1 
                                                 AND DMPV.IsDeleted = 0) 
                      SET @MuteCount=(SELECT COUNT(DMPV.ID) AS IsMute 
                                      FROM   AVL.ML_TRN_MLPATTERNVALIDATION(NOLOCK) DMPV 
                                      WHERE  DMPV.ProjectId = @ProjectID 
                                             AND DMPV.IsApprovedOrMute = 2 
                                             AND DMPV.IsDeleted = 0) 

                      SELECT @TotalPatternCount AS TotalPatternCount, 
                             @ApprovedCount     AS ApprovedCount, 
                             @MuteCount         AS MuteCount 

                      SELECT CONVERT(VARCHAR(10), MLSignOffDate, 110) AS AutoclassificationDate,
                             IsAutoClassified, 
                             ISNULL(P.IsMLSignOff, 0)                 AS IsMLSignOff, 
                             ISNULL(rg.isMLsignoff, 0)                AS IsRegMLsignOff, 
                             ISNULL(@RegenerateCount, 0)              AS RegenerateCount 
                      FROM   [AVL].[MAS_PROJECTDEBTDETAILS](NOLOCK) P 
                             LEFT JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS rg 
                                    ON rg.projectid = P.ProjectID 
                                       AND rg.IsDeleted = 0 
                                       AND rg.InitialLearningID = @LatestID 
                      WHERE  P.ProjectID = @ProjectID 
                             AND P.isdeleted = 0 
                  END 
                ELSE 
                  BEGIN 
                      SELECT ISNULL(CONVERT(VARCHAR(10), stat.[StartDate], 110), '') AS [StartDate], 
                             CONVERT(VARCHAR(10), stat.[EndDate], 110)               AS [EndDate], 
                             stat.[IsSDTicket], 
                             stat.[IsDartTicket], 
                             ISNULL(stat.IsMLSentOrReceived, 'N')                    AS MLStatus,
                             ISNULL(stat.IsSamplingInProgress, 'N')                  AS SamplingInProgressStatus,
                             ISNULL(stat.IsSamplingSentOrReceived, 'N')              AS SamplingSentOrReceivedStatus,
                             ISNULL(stat.IsNoiseEliminationSentorReceived, 'N')      AS IsNoiseEliminationSentorReceived,
                             ISNULL(stat.IsRegenerated, 0)                           AS IsRegenerated,
                             @RegStartDate                                           AS RegStartDate,
                             @RegEndDate                                             AS RegEndDate,
                             ISNULL(@ErrorMessage, '')                               AS ErrorMessage,
                             @NoiseSentDate                                          AS NoiseSentDate,
                             ISNULL(@NoiseSentDate, GETDATE())                       AS DataValidationDate,
                             (SELECT TOP 1 EmployeeName 
                              FROM   [AVL].[MAS_LOGINMASTER] loginmas 
                              WHERE  loginmas.UserID = stat.SentBy 
                                     AND loginmas.isdeleted = 0 
                                     AND stat.IsDeleted = 0)                         AS MLSentBy,
                             ISNULL(CONVERT(VARCHAR(10), stat.SentOn, 110), '')      AS MLSentDate,
                             ISNULL(CONVERT(VARCHAR(10), stat.SentOn, 110), '')      AS SamplingSentDate,
                             (SELECT TOP 1 EmployeeName 
                              FROM   [AVL].[MAS_LOGINMASTER] loginmas 
                              WHERE  loginmas.Userid = stat.SentBy 
                                     AND loginmas.isdeleted = 0 
                                     AND stat.IsDeleted = 0)                         AS SamplingSentBy,
                             @MlReceiveddate                                         AS MlReceiveddate,
                            CASE WHEN  OM.ID IS NULL THEN 4 ELSE OP.OptionalFieldID END                                     AS 'OptionalFieldID'
                      FROM   [AVL].[ML_PRJ_INITIALLEARNINGSTATE] stat 
                             JOIN AVL.ML_MAP_OPTIONALPROJMAPPING OP 
                               ON stat.ProjectID = OP.ProjectId 
                                  AND OP.IsActive = 1 
								  LEFT JOIN AVL.ML_MAS_OptionalFields OM ON OM.ID=OP.OptionalFieldID AND OM.IsDeleted=0
                      WHERE  stat.ProjectID = @ProjectID 
                             AND stat.IsDeleted = 0 
                             AND stat.Id = @LatestID 

                      SET @TotalPatternCount=(SELECT COUNT(DMPV.ID) 
                                              FROM   AVL.ML_TRN_MLPATTERNVALIDATION(NOLOCK) DMPV
                                              WHERE  DMPV.ProjectId = @ProjectID 
                                                     AND DMPV.IsDeleted = 0) 
                      SET @ApprovedCount=(SELECT COUNT(DMPV.ID) 
                                          FROM   AVL.ML_TRN_MLPATTERNVALIDATION(NOLOCK) DMPV 
                                          WHERE  DMPV.ProjectId = @ProjectID 
                                                 AND DMPV.IsApprovedOrMute = 1 
                                                 AND DMPV.IsDeleted = 0) 
                      SET @MuteCount=(SELECT COUNT(DMPV.ID) AS IsMute 
                                      FROM   AVL.ML_TRN_MLPATTERNVALIDATION(NOLOCK) DMPV 
                                      WHERE  DMPV.ProjectId = @ProjectID 
                                             AND DMPV.IsApprovedOrMute = 2 
                                             AND DMPV.IsDeleted = 0) 

                      SELECT @TotalPatternCount AS TotalPatternCount, 
                             @ApprovedCount     AS ApprovedCount, 
                             @MuteCount         AS MuteCount 

                      SELECT CONVERT(VARCHAR(10), MLSignOffDate, 110) AS AutoclassificationDate,
                             IsAutoClassified, 
                             ISNULL(P.IsMLSignOff, 0)                 AS IsMLSignOff, 
                             ISNULL(rg.isMLsignoff, 0)                AS IsRegMLsignOff, 
                             ISNULL(@RegenerateCount, 0)              AS RegenerateCount 
                      FROM   [AVL].[MAS_PROJECTDEBTDETAILS](NOLOCK) P 
                             LEFT JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS rg 
                                    ON rg.projectid = P.ProjectID 
                                       AND rg.IsDeleted = 0 
                                       AND rg.InitialLearningID = @LatestID 
                      WHERE  P.ProjectID = @ProjectID 
                             AND P.isdeleted = 0 
                  END 
            --declare @esaprojectid nvarchar(max); 
            --set @esaprojectid=(select esaprojectid from [AVL].[MAS_ProjectMaster] where projectid=@ProjectID 
            --          AND IsDeleted=0) 
            END 
          ELSE 
            BEGIN 
                --To get the mljobid/samplingjobid/noiseeliminationjobid for that project(present transaction)      
                DECLARE @InitialLearningId INT; 
                DECLARE @IsMLProcessingRequired NVARCHAR(MAX); 
                DECLARE @IsSamplingProcessingRequired NVARCHAR(MAX); 
                DECLARE @MLJobId NVARCHAR(MAX); 
                DECLARE @NoiseEliminationJobId NVARCHAR(MAX); 
                DECLARE @SamplingJobId NVARCHAR(MAX); 
				DECLARE @MLBaseCount BIGINT;

                SET @TransactionID=(SELECT TOP 1 ID 
                                    FROM   [AVL].[ML_TRN_MLSAMPLINGJOBSTATUS] 
                                    WHERE  ProjectID = @ProjectID 
                                    ORDER  BY ID DESC) 
                SET @ErrorMessage=(SELECT TOP 1 MBS.JobMessage 
                                   FROM   [AVL].[ML_PRJ_INITIALLEARNINGSTATE] ISS 
                                          INNER JOIN [AVL].[ML_TRN_MLSAMPLINGJOBSTATUS] MBS 
                                                  ON ISS.ProjectID = MBS.ProjectID 
                                                     AND ISS.ID = MBS.InitialLearningID 
                                   WHERE  ISS.ProjectID = @ProjectID 
                                          AND MBS.ID = @TransactionID 
                                          AND MLSamplingStatus = 'KILLED' 
                                          AND IsDARTProcessed = 'Y' 
                                          AND ISS.IsDeleted = 0) 
										  SET @MLBaseCount=(SELECT COUNT(DISTINCT TicketID) from ML_MLBaseDetails where ProjectID=@ProjectID and Isdeleted=0)
                SET @InitialLearningId=(SELECT ID 
                                        FROM   [AVL].[ML_PRJ_INITIALLEARNINGSTATE] 
                                        WHERE  ProjectID = @ProjectID 
                                               AND IsDeleted = 0 
                                               AND id = @LatestID) 
                SET @IsMLProcessingRequired=(SELECT 'Y' 
                                             FROM   [AVL].[ML_TRN_MLSAMPLINGJOBSTATUS] 
                                             WHERE  ProjectID = @ProjectID 
                                                    AND ( IsDARTProcessed = 'N' 
                                                           OR IsDARTProcessed IS NULL ) 
                                                    AND JobType = 'ML' 
                                                    AND id = @TransactionID 
                                                    AND InitialLearningID = @InitialLearningId) 
                SET @IsSamplingProcessingRequired=(SELECT 'Y' 
                                                   FROM   [AVL].[ML_TRN_MLSAMPLINGJOBSTATUS] 
                                                   WHERE  ProjectID = @ProjectID 
                                                          AND (( IsDARTProcessed = 'N' 
                                                                 OR IsDARTProcessed IS NULL ) )
                                                          AND JobType = 'Sampling' 
                                                          AND id = @TransactionID 
                                                          AND InitialLearningID = @InitialLearningId)
                SET @MLJobId=(SELECT JobIdFromML 
                              FROM   [AVL].[ML_TRN_MLSAMPLINGJOBSTATUS] 
                              WHERE  ProjectID = @ProjectID 
                                     AND (( IsDARTProcessed = 'N' 
                                            OR IsDARTProcessed IS NULL )OR @MLBaseCount=0 )
                                     AND JobType = 'ML' 
                                     AND id = @TransactionID 
                                     AND InitialLearningID = @InitialLearningId) 
                SET @NoiseEliminationJobId=(SELECT JobIdFromML 
                                            FROM   [AVL].[ML_TRN_MLSAMPLINGJOBSTATUS] 
                                            WHERE  ProjectID = @ProjectID 
                                                   AND ( IsDARTProcessed = 'N' 
                                                          OR IsDARTProcessed IS NULL ) 
                                                   AND JobType = 'NoiseEl' 
                                                   AND id = @TransactionID 
                                                   AND InitialLearningID = @InitialLearningId) 
                SET @SamplingJobId=(SELECT JobIdFromML 
                                    FROM   [AVL].[ML_TRN_MLSAMPLINGJOBSTATUS] 
                                    WHERE  ProjectID = @ProjectID 
                                           AND ( IsDARTProcessed = 'N' 
                                                  OR IsDARTProcessed IS NULL ) 
                                           AND JobType = 'Sampling' 
                                           AND id = @TransactionID 
                                           AND InitialLearningID = @InitialLearningId) 

                DECLARE @IsSamplingSent NVARCHAR(10); 
                DECLARE @IsMLSent NVARCHAR(10); 
                DECLARE @IsNoiseEliminationSent NVARCHAR(10); 

                SET @IsMLSent=(SELECT TOP 1 'Y' 
                               FROM   [AVL].[ML_PRJ_INITIALLEARNINGSTATE] 
                               WHERE  ProjectID = @ProjectID 
                                      AND IsMLSentOrReceived = 'Sent' 
                                      AND ID = @InitialLearningId 
                                      AND ( IsDeleted = 0 
                                             OR IsDeleted IS NULL ) 
                               ORDER  BY ID DESC) 
                SET @IsSamplingSent=(SELECT TOP 1 'Y' 
                                     FROM   [AVL].[ML_PRJ_INITIALLEARNINGSTATE] 
                                     WHERE  ProjectID = @ProjectID 
                                            AND IsSamplingSentOrReceived = 'Sent' 
                                            AND ID = @InitialLearningId 
                                            AND ( IsDeleted = 0 
                                                   OR IsDeleted IS NULL ) 
                                     ORDER  BY ID DESC) 
                SET @IsNoiseEliminationSent=(SELECT TOP 1 'Y' 
                                             FROM   [AVL].[ML_PRJ_INITIALLEARNINGSTATE] 
                                             WHERE  ProjectID = @ProjectID 
                                                    AND IsNoiseEliminationSentorReceived = 'Sent'
                                                    AND ID = @InitialLearningId 
                                                    AND ( IsDeleted = 0 
                                                           OR IsDeleted IS NULL ) 
                                             ORDER  BY ID DESC) 

                SELECT ISNULL(@IsMLSent, 'N')                     AS IsMLSent, 
                       ISNULL(@IsSamplingSent, 'N')               AS IsSamplingSent, 
                       ISNULL(@IsMLProcessingRequired, 'N')       AS IsMLProcessingRequired, 
                       ISNULL(@IsSamplingProcessingRequired, 'N') AS IsSamplingProcessingRequired,
                       @MLJobId                                   AS MLJobId, 
                       @SamplingJobId                             AS SamplingJobId, 
                       ISNULL(@ErrorMessage, '')                  AS ErrorMessage, 
                       ISNULL(@IsNoiseEliminationSent, 'N')       AS NoiseEliminationSent, 
                       @NoiseEliminationJobId                     AS NoiseEliminationJobId 
            END 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage1 VARCHAR(MAX); 

          SELECT @ErrorMessage1 = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_GetMLDetailsOnLoad] ', 
            @ErrorMessage1, 
            @ProjectID, 
            0 
      END CATCH 
  END
