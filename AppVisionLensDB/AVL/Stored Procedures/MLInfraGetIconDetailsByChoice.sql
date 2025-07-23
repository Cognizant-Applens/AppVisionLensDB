/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

 
CREATE PROC [AVL].[MLInfraGetIconDetailsByChoice]  --10337,2
  @ProjectID BIGINT, 
  @Choice    bigint
AS 
  BEGIN 
      BEGIN TRY 
          DECLARE @InitialLearningID BIGINT ,@StartDate DATETIME,@EndDate DATETIME
          DECLARE @IsRegenerted BIT 

          --get latest id for initial learning for the projectid  
          SET @InitialLearningID = (SELECT TOP 1 ID 
                                    FROM   AVL.ML_PRJ_InitialLearningStateInfra 
                                    WHERE  PROJECTID = @ProjectID 
                                           AND ISDELETED = 0 
                                    ORDER  BY ID DESC) 
          --whether it is a regenerated initial learning transaction id  
          SET @IsRegenerted = (SELECT ISNULL(ISREGENERATED, 0) 
                               FROM   AVL.ML_PRJ_InitialLearningStateInfra 
                               WHERE  PROJECTID = @ProjectID 
                                      AND ISDELETED = 0 
                                      AND ID = @InitialLearningID) 
		 SELECT @StartDate=StartDate,@EndDate=EndDate FROM AVL.ML_PRJ_InitialLearningStateInfra WHERE ID=@InitialLearningID

          ---Getting the ticket details for the specific project into temp table  
          SELECT TICKETID                AS TicketID, 
                 TD.PROJECTID            AS ProjectID, 
                 DEBTCLASSIFICATIONMAPID AS DebtClassificationId, 
                 AVOIDABLEFLAG           AS AvoidableFlagID, 
                 RESIDUALDEBTMAPID       AS ResidualDebtID, 
                 CAUSECODEMAPID          AS CauseCodeID, 
                 RESOLUTIONCODEMAPID     AS ResolutionCodeID, 
                 TD.TowerID              AS TowerID 
          INTO   #TMPCOUNT 
          FROM   AVL.TK_TRN_InfraTicketDetail TD 
                 LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails RAD 
                        ON RAD.INITIALLEARNINGID = @InitialLearningID 
                           AND RAD.ISDELETED = 0 
                           AND RAD.PROJECTID = @ProjectID 
						   AND TD.DARTStatusID=8 
						   AND TD.Closeddate BETWEEN @StartDate AND @EndDate
                           AND TD.TowerID = RAD.TowerID 
          WHERE  TD.PROJECTID = @ProjectID 
                 AND TD.ISDELETED = 0 
                 AND DARTSTATUSID = 8 
                 AND ( ( @IsRegenerted = 0 ) 
                        OR ( @IsRegenerted = 1 
                             AND RAD.ID IS NOT NULL ) 
                        OR ( @Choice = 3 ) ) 

          --Choice=1:when sampling grid is loaded  
          -- choice=2: when ml patterns grid is loaded before signoff  
          --choice=3:when ml patterns grid is loaded after signoff   
          IF ( @Choice = 1 ) 
            BEGIN 
                DECLARE @TicketAnalysed   BIGINT = 0, 
                        @TicketConsidered BIGINT = 0, 
                        @SamplingCount    BIGINT = 0 

                --check if initial learning id is regenerated or not  
                IF ( @IsRegenerted = 1 ) 
                  BEGIN 
                      --count of tickets with application id which matches the regenerated application id from ticket validation
                      SET @TicketAnalysed = (SELECT COUNT(DISTINCT TV.TICKETID) 
                                             FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) TV 
											 JOIN #TMPCOUNT TD ON TV.ProjectID=@ProjectID AND TV.IsDeleted=0
											 AND TV.TicketID=TD.TicketID
                                                    JOIN AVL.ML_TRN_RegeneratedTowerDetails REG
                                                      ON REG.TowerID = TV.TowerID 
                                                         AND REG.ISDELETED = 0 
                                                         AND REG.INITIALLEARNINGID = @InitialLearningID
                                                         AND REG.PROJECTID = TV.PROJECTID 
                                             WHERE  TV.PROJECTID = @ProjectID 
                                                    AND TV.ISDELETED = 0) 
                      --count of tickets with application id which matches the regenerated application id and ticket desc is not null or ticket desc is not empty
                      SET @TicketConsidered = (SELECT COUNT(DISTINCT TD.TICKETID) 
                                               FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) TV 
											    JOIN #TMPCOUNT TD ON TV.ProjectID=@ProjectID AND TV.IsDeleted=0
											 AND TV.TicketID=TD.TicketID
                                                      JOIN AVL.ML_TRN_RegeneratedTowerDetails REG
                                                        ON REG.TowerID = TV.TowerID
                                                           AND REG.ISDELETED = 0 
                                                           AND REG.INITIALLEARNINGID = @InitialLearningID
                                                           AND REG.PROJECTID = TV.PROJECTID 
                                               WHERE  TV.PROJECTID = @ProjectID 
                                                      AND TV.ISDELETED = 0 
                                                      AND ( TICKETDESCRIPTION IS NOT NULL 
                                                            AND TICKETDESCRIPTION <> '' )) 
                      --Count of sampled tickets in Ticketsaftersampling table with application id which matches the regenerated application id 
                      SET @SamplingCount = (SELECT COUNT(DISTINCT TD.TICKETID) 
                                            FROM   AVL.ML_TRN_TicketsAfterSamplingInfra(NOLOCK) TS 
											 JOIN #TMPCOUNT TD ON TS.ProjectID=@ProjectID AND TS.IsDeleted=0
											 AND TS.TicketID=TD.TicketID
                                                   JOIN AVL.ML_TRN_RegeneratedTowerDetails RA
                                                     ON TS.TowerID = RA.TowerID 
                                                        AND RA.INITIALLEARNINGID = @InitialLearningID
                                                        AND RA.ISDELETED = 0 
                                                        AND TS.PROJECTID = RA.PROJECTID 
                                            WHERE  TS.PROJECTID = @ProjectID 
                                                   AND TS.ISDELETED = 0 
                                                   AND DESC_BASE_WORKPATTERN <> '0') 
                  END 
                ELSE 
                  BEGIN 
                      --count of tickets  from ticket validation  
                      SET @TicketAnalysed = (SELECT COUNT(TV.TICKETID) 
                                             FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) TV
											  JOIN #TMPCOUNT TD ON TV.ProjectID=@ProjectID AND TV.IsDeleted=0
											 AND TV.TicketID=TD.TicketID
                                             WHERE  TV.PROJECTID = @ProjectID 
                                                    AND ISDELETED = 0) 
                      --COUNT of tickets  ticket desc is not null or ticket desc is not empty  
                      SET @TicketConsidered = (SELECT COUNT(TV.TICKETID) 
                                               FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) TV
											    JOIN #TMPCOUNT TD ON TV.ProjectID=@ProjectID AND TV.IsDeleted=0
											 AND TV.TicketID=TD.TicketID
                                               WHERE  TV.PROJECTID = @ProjectID 
                                                      AND ISDELETED = 0 
                                                      AND ( TICKETDESCRIPTION IS NOT NULL 
                                                            AND TICKETDESCRIPTION <> '' )) 
                      --COUNT of sampled tickets in Ticketsaftersampling table  
                      SET @SamplingCount = (SELECT COUNT(TS.TICKETID) 
                                            FROM   AVL.ML_TRN_TicketsAfterSamplingInfra(NOLOCK) TS
											 JOIN #TMPCOUNT TD ON TS.ProjectID=@ProjectID AND TS.IsDeleted=0
											 AND TS.TicketID=TD.TicketID
                                            WHERE  TS.PROJECTID = @ProjectID 
                                                   AND TS.ISDELETED = 0 
                                                   AND TS.DESC_BASE_WORKPATTERN <> '0') 
                  END 

                SELECT @TicketAnalysed   AS 'TicketAnalysed', 
                       @TicketConsidered AS 'TicketConsidered', 
                       @SamplingCount    AS 'SamplingCount', 
                       0                 AS 'PatternCount', 
                       0                 AS 'ApprovedCount', 
                       0                 AS 'MuteCount' 
            END 
          ELSE IF ( @Choice = 2 ) 
            BEGIN 
                DECLARE @TicketAnalysedTC     BIGINT = 0, 
                        @TicketConsideredML   BIGINT = 0, 
                        @PatternCount         BIGINT = 0, 
                        @TicketAnalysedTS     BIGINT = 0, 
                        @TicketConsideredMLTC BIGINT = 0 

                -- if it regenerated initial learning id  
                --if the project has undergone sampling then count of tickets in ticketsaftersampling for the regenerated application and workpattern<>0
                SET @TicketAnalysedTS = (SELECT COUNT(DISTINCT TS.TICKETID) 
                                         FROM   AVL.ML_TRN_TicketsAfterSamplingInfra(NOLOCK) TS 
                                                JOIN AVL.ML_PRJ_InitialLearningStateInfra IL 
                                                  ON IL.PROJECTID = TS.PROJECTID 
                                                     AND IL.ISDELETED = 0 
                                                     AND IL.ISSAMPLINGINPROGRESS IS NOT NULL 
                                                     AND IL.ID = @InitialLearningID 
                                                JOIN #TMPCOUNT TC 
                                                  ON TC.TICKETID = TS.TICKETID 
                                                     AND TC.PROJECTID = TS.PROJECTID 
                                                     AND TC.TowerID = TS.TowerID 
                                         WHERE  IL.PROJECTID = @ProjectID 
                                                AND TS.ISDELETED = 0 
                                                AND TS.DESC_BASE_WORKPATTERN <> '0') 

                -- if it has not been to sampling then only ticket validation table count will be taken for project or else it will sum of both
                IF ( @TicketAnalysedTS = 0 ) 
                  BEGIN 
                      --not undergone sampling case  
                      --count of tickets in ticket validation table with applicatio id are regenerated applications  
                      SET @TicketAnalysedTC = (SELECT COUNT(DISTINCT TV.TICKETID) 
                                               FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) TV 
                                                      JOIN #TMPCOUNT TC 
                                                        ON TC.TICKETID = TV.TICKETID 
                                                           AND TC.PROJECTID = TV.PROJECTID 
                                                           AND TC.TowerID = TV.TowerID)
                  END 
                ELSE 
                  BEGIN 
                      --count of tickets in ticket validation table with applicatio id are regenerated applications and ticket id should not be present in sampling table
                      SET @TicketAnalysedTC = (SELECT COUNT(DISTINCT TV.TICKETID) 
                                               FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) TV 
                                                      JOIN #TMPCOUNT TC 
                                                        ON TC.TICKETID = TV.TICKETID 
                                                           AND TC.PROJECTID = TV.PROJECTID 
                                                           AND TC.TowerID = TV.TowerID
                                               WHERE  TV.PROJECTID = @ProjectID 
                                                      AND TV.ISDELETED = 0 
                                                      AND NOT EXISTS (SELECT * 
                                                                      FROM   AVL.ML_TRN_TicketsAfterSamplingInfra TS
                                                                      WHERE  TS.TICKETID = TV.TICKETID
                                                                             AND TS.ISDELETED = 0
                                                                             AND TS.DESC_BASE_WORKPATTERN <> '0'
                                                                             AND TV.PROJECTID = TS.PROJECTID))
                  END 

                --if the project has undergone sampling then count of tickets in ticketsaftersampling for the regenerated application and workpattern<>0 and debt fields are filled
                SET @TicketConsideredML = (SELECT COUNT(DISTINCT TS.TICKETID) 
                                           FROM   AVL.ML_TRN_TicketsAfterSamplingInfra(NOLOCK) TS 
                                                  JOIN AVL.ML_PRJ_InitialLearningStateInfra IL 
                                                    ON IL.PROJECTID = TS.PROJECTID 
                                                       AND IL.ISDELETED = 0 
                                                       AND IL.ISSAMPLINGINPROGRESS IS NOT NULL 
                                                       AND IL.ID = @InitialLearningID 
                                                  JOIN #TMPCOUNT TC 
                                                    ON TC.TICKETID = TS.TICKETID 
                                                       AND TC.PROJECTID = TS.PROJECTID 
                                                       AND TC.TowerID = TS.TowerID 
                                           WHERE  ts.PROJECTID = @ProjectID 
                                                  AND ts.ISDELETED = 0 
                                                  AND ( TS.TICKETDESCRIPTION IS NOT NULL 
                                                        AND TS.TICKETDESCRIPTION <> '' ) 
                                                  AND ( TC.DEBTCLASSIFICATIONID IS NOT NULL 
                                                        AND TC.DEBTCLASSIFICATIONID <> 0 ) 
                                                  AND ( TC.AVOIDABLEFLAGID IS NOT NULL 
                                                        AND TC.AVOIDABLEFLAGID <> 0 ) 
                                                  AND ( TC.CAUSECODEID IS NOT NULL 
                                                        AND TC.CAUSECODEID <> 0 ) 
                                                  AND ( TC.RESOLUTIONCODEID IS NOT NULL 
                                                        AND TC.RESOLUTIONCODEID <> 0 ) 
                                                  AND ( TC.RESIDUALDEBTID IS NOT NULL 
                                                        AND TC.RESIDUALDEBTID <> 0 )
														AND TS.Desc_Base_WorkPattern<>'0') 

                IF ( @TicketConsideredML = 0 ) 
                  BEGIN 
                      --not undergone sampling case  
                      --count of tickets in ticket validation table with applicatio id are regenerated applications and debt fields are filled
                      PRINT '0' 

                      SET @TicketConsideredMLTC = (SELECT COUNT(DISTINCT TV.TICKETID) 
                                                   FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) TV
                                                          JOIN #TMPCOUNT TC 
                                                            ON TC.TICKETID = TV.TICKETID 
                                                               AND TC.PROJECTID = TV.PROJECTID 
                                                               AND TC.TowerID = TV.TowerID
                                                   WHERE  TV.PROJECTID = @ProjectID 
                                                          AND TV.ISDELETED = 0 
                                                          AND ( TV.TICKETDESCRIPTION IS NOT NULL
                                                                AND TV.TICKETDESCRIPTION <> '' )
                                                          AND ( TV.DEBTCLASSIFICATIONID IS NOT NULL
                                                                AND TV.DEBTCLASSIFICATIONID <> 0 )
                                                          AND ( TV.AVOIDABLEFLAGID IS NOT NULL 
                                                                AND TV.AVOIDABLEFLAGID <> 0 ) 
                                                          AND ( TV.CAUSECODEID IS NOT NULL 
                                                                AND TV.CAUSECODEID <> 0 ) 
                                                          AND ( TV.RESOLUTIONCODEID IS NOT NULL
                                                                AND TV.RESOLUTIONCODEID <> 0 ) 
                                                          AND ( TV.RESIDUALDEBTID IS NOT NULL 
                                                                AND TV.RESIDUALDEBTID <> 0 )) 
                  END 
                ELSE 
                  BEGIN 
                      PRINT 'not 0' 

                      --count of tickets in ticket validation table with applicatio id are regenerated applications and ticket id should not be present in sampling table and debt fields are filled
                      SET @TicketConsideredMLTC = (SELECT COUNT(DISTINCT MB.TICKETID) 
                                                   FROM   [AVL].[ML_MLBaseDetailsInfra] (NOLOCK) MB
                                                          JOIN #TMPCOUNT TC 
                                                            ON TC.TICKETID = MB.TICKETID 
                                                               AND TC.PROJECTID = MB.PROJECTID 
                                                              -- AND TC.APPLICATIONID = MB.APPLICATIONID
                                                   WHERE  MB.PROJECTID = @ProjectID 
                                                          AND MB.ISDELETED = 0 
                                                          AND ( MB.DEBTCLASSIFICATION IS NOT NULL
                                                                AND MB.DEBTCLASSIFICATION <> '')
                                                          AND ( MB.AVOIDABLEFLAG IS NOT NULL 
                                                                AND MB.AVOIDABLEFLAG <> '' ) 
                                                          AND ( MB.CAUSECODE IS NOT NULL 
                                                                AND MB.CAUSECODE <> '' ) 
                                                          AND ( MB.RESOLUTIONCODE IS NOT NULL
                                                                AND MB.RESOLUTIONCODE <> '' ) 
                                                          AND ( MB.RESIDUALDEBT IS NOT NULL 
                                                                AND MB.RESIDUALDEBT <> '' ) 
                                                          AND ( TICKETDESCRIPTIONPATTERN IS NOT NULL 
                                                                AND TICKETDESCRIPTIONPATTERN <> '' ) 
																AND MB.InitialLearningID = @InitialLearningID
                                                          AND NOT EXISTS (SELECT * 
                                                                          FROM   AVL.ML_TRN_TicketsAfterSamplingInfra TS
                                                                          WHERE  TS.PROJECTID = MB.PROJECTID
                                                                                 AND TS.TICKETID = MB.TICKETID
                                                                                 AND TS.ISDELETED = 0))
                  END 

                -- PatternCount is taken from ui grid count  
                SET @PatternCount = (SELECT COUNT(DISTINCT ID) 
                                     FROM   AVL.ML_TRN_MLPatternValidationInfra(NOLOCK) 
                                     WHERE  PROJECTID = @ProjectID 
                                            AND ISDELETED = 0 
                                            AND TICKETPATTERN <> '0') 

                SELECT @TicketAnalysedTC + @TicketAnalysedTS       AS 'TicketAnalysed', 
                       @TicketConsideredML + @TicketConsideredMLTC AS 'TicketConsidered', 
                       @PatternCount                               AS 'PatternCount', 
                       0                                           AS 'SamplingCount', 
                       0                                           AS 'ApprovedCount', 
                       0                                           AS 'MuteCount' 
            END 
          ELSE IF ( @Choice = 3 ) 
            BEGIN 
                --No Regeneration concept here as last grid contain all the pattern irrespective of application id
                DECLARE @ApprovedCount BIGINT = 0, 
                        @MuteCount     BIGINT = 0 

                PRINT @InitialLearningID 

                SET @TicketAnalysedTS = (SELECT COUNT(DISTINCT TS.TICKETID) 
                                         FROM   AVL.ML_TRN_TicketsAfterSamplingInfra(NOLOCK) TS 
                                                JOIN AVL.ML_PRJ_InitialLearningStateInfra IL 
                                                  ON IL.PROJECTID = TS.PROJECTID 
                                                     AND IL.ID = @InitialLearningID 
                                                     AND IL.ISDELETED = 0 
                                                     AND IL.ISSAMPLINGINPROGRESS IS NOT NULL 
                                                JOIN #TMPCOUNT TC 
                                                  ON TC.TICKETID = TS.TICKETID 
                                                     AND TC.PROJECTID = TS.PROJECTID 
                                                     AND TC.TowerID = TS.TowerID 
                                         WHERE  IL.PROJECTID = @ProjectID 
                                                AND TS.ISDELETED = 0 
                                             ) 

                PRINT @TicketAnalysedTS 

                IF ( @TicketAnalysedTS = 0 ) 
                  BEGIN 
                      SET @TicketAnalysedTC = (SELECT COUNT(DISTINCT TV.TICKETID) 
                                               FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) TV 
                                                      JOIN #TMPCOUNT TC 
                                                        ON TC.TICKETID = TV.TICKETID 
                                                           AND TC.PROJECTID = TV.PROJECTID 
                                                           AND TC.TowerID = TV.TowerID
                                               WHERE  TV.PROJECTID = @ProjectID 
                                                      AND TV.ISDELETED = 0) 
                  END 
                ELSE 
                  BEGIN 
                      SET @TicketAnalysedTC = (SELECT COUNT(DISTINCT TV.TICKETID) 
                                               FROM   AVL.ML_TRN_TicketValidationInfra (NOLOCK) TV 
                                                      JOIN #TMPCOUNT TC 
                                                        ON TC.TICKETID = TV.TICKETID 
                                                           AND TC.PROJECTID = TV.PROJECTID 
                                                           AND TC.TowerID = TV.TowerID
                                               WHERE  TV.PROJECTID = @ProjectID 
                                                      AND TV.ISDELETED = 0 
                                                      AND NOT EXISTS (SELECT DISTINCT TS.TicketID
                                                                      FROM   AVL.ML_TRN_TicketsAfterSamplingInfra TS
                                                                      WHERE  TS.TICKETID = TV.TICKETID
                                                                             AND TS.ISDELETED = 0
                                                                      
                                                                             AND TV.PROJECTID = TS.PROJECTID))
                  END 

                PRINT @TicketAnalysedTC 

                PRINT @TicketAnalysedTS 

                SET @ApprovedCount = (SELECT COUNT(DISTINCT ID) 
                                      FROM   AVL.ML_TRN_MLPatternValidationInfra 
                                      WHERE  ISDELETED = 0 
                                             AND PROJECTID = @ProjectID 
                                             AND ISAPPROVEDORMUTE = 1 
                                             AND TICKETPATTERN <> '0') 
                SET @TicketConsideredML = (SELECT COUNT(DISTINCT TS.TICKETID) 
                                           FROM   AVL.ML_TRN_TicketsAfterSamplingInfra(NOLOCK) TS 
                                                  JOIN AVL.ML_PRJ_InitialLearningStateInfra IL 
                                                    ON IL.PROJECTID = TS.PROJECTID 
                                                       AND il.ID = @InitialLearningID 
													   and IL.IsDeleted=0
                                                  JOIN #TMPCOUNT TC 
                                                    ON TC.PROJECTID = TS.PROJECTID 
                                                       AND TS.TICKETID = TC.TICKETID 
                                                       AND IL.ISDELETED = 0 
                                                       AND IL.ISSAMPLINGINPROGRESS IS NOT NULL 
                                           WHERE  TS.PROJECTID = @ProjectID 
                                                  AND TS.ISDELETED = 0 
                                                  AND ( TS.TICKETDESCRIPTION IS NOT NULL 
                                                        AND TS.TICKETDESCRIPTION <> '' ) 
                                                  AND ( TC.DEBTCLASSIFICATIONID IS NOT NULL 
                                                        AND TC.DEBTCLASSIFICATIONID <> 0 ) 
                                                  AND ( TC.AVOIDABLEFLAGID IS NOT NULL 
                                                        AND TC.AVOIDABLEFLAGID <> 0 ) 
                                                  AND ( TC.CAUSECODEID IS NOT NULL 
                                                        AND TC.CAUSECODEID <> 0 ) 
                                                  AND ( TC.RESOLUTIONCODEID IS NOT NULL 
                                                        AND TC.RESOLUTIONCODEID <> 0 ) 
                                                  AND ( TC.RESIDUALDEBTID IS NOT NULL 
                                                        AND TC.RESIDUALDEBTID <> 0 )
														
														and ts.Desc_Base_WorkPattern<>'0'
														) 

                PRINT @TicketConsideredML 

                IF ( @TicketConsideredML = 0 ) 
                  BEGIN 
                      SET @TicketConsideredMLTC = (SELECT COUNT(DISTINCT TV.TICKETID) 
                                                   FROM   AVL.ML_TRN_TicketValidationInfra(NOLOCK) TV
                                                          JOIN #TMPCOUNT TC 
                                                            ON TC.TICKETID = TV.TICKETID 
                                                               AND TC.PROJECTID = TV.PROJECTID 
                                                               AND TC.TowerID = TV.TowerID
                                                   WHERE  TV.PROJECTID = @ProjectID 
                                                          AND TV.ISDELETED = 0 
                                                          AND ( TV.TICKETDESCRIPTION IS NOT NULL
                                                                AND TV.TICKETDESCRIPTION <> '' )
                                                          AND ( TV.DEBTCLASSIFICATIONID IS NOT NULL
                                                                AND TV.DEBTCLASSIFICATIONID <> 0 )
                                                          AND ( TV.AVOIDABLEFLAGID IS NOT NULL 
                                                                AND TV.AVOIDABLEFLAGID <> 0 ) 
                                                          AND ( TV.CAUSECODEID IS NOT NULL 
                                                                AND TV.CAUSECODEID <> 0 ) 
                                                          AND ( TV.RESOLUTIONCODEID IS NOT NULL
                                                                AND TV.RESOLUTIONCODEID <> 0 ) 
                                                          AND ( TV.RESIDUALDEBTID IS NOT NULL 
                                                                AND TV.RESIDUALDEBTID <> 0 )
														
																) 
                  END 
                ELSE 
                  BEGIN 
                      SET @TicketConsideredMLTC = (SELECT COUNT(DISTINCT MB.TICKETID) 
                                                   FROM   [AVL].[ML_MLBaseDetailsInfra](NOLOCK) MB
                                                          JOIN #TMPCOUNT TC 
                                                            ON TC.TICKETID = MB.TICKETID 
                                                               AND TC.PROJECTID = MB.PROJECTID 
                                                              -- AND TC.APPLICATIONID = TV.APPLICATIONID
                                                    WHERE  MB.PROJECTID = @ProjectID 
                                                          AND MB.ISDELETED = 0 
                                                          AND ( MB.DEBTCLASSIFICATION IS NOT NULL
                                                                AND MB.DEBTCLASSIFICATION <> '')
                                                          AND ( MB.AVOIDABLEFLAG IS NOT NULL 
                                                                AND MB.AVOIDABLEFLAG <> '' ) 
                                                          AND ( MB.CAUSECODE IS NOT NULL 
                                                                AND MB.CAUSECODE <> '' ) 
                                                          AND ( MB.RESOLUTIONCODE IS NOT NULL
                                                                AND MB.RESOLUTIONCODE <> '' ) 
                                                          AND ( MB.RESIDUALDEBT IS NOT NULL 
                                                                AND MB.RESIDUALDEBT <> '' ) 
                                                          AND ( TICKETDESCRIPTIONPATTERN IS NOT NULL 
                                                                AND TICKETDESCRIPTIONPATTERN <> '' ) 
                                                          AND NOT EXISTS (SELECT DISTINCT TS.TicketID 
                                                                          FROM   AVL.ML_TRN_TicketsAfterSamplingInfra TS
                                                                          WHERE  TS.PROJECTID = MB.PROJECTID
                                                                                 AND TS.TICKETID = MB.TICKETID
                                                                               
                                                                                 AND TS.ISDELETED = 0
																				 
																				
																				 
																				 ))
                  END 
				 print  @TicketConsideredML
                PRINT @TicketConsideredMLTC 

                SET @MuteCount = (SELECT COUNT(DISTINCT ID) 
                                  FROM   AVL.ML_TRN_MLPatternValidationInfra 
                                  WHERE  ISDELETED = 0 
                                         AND PROJECTID = @ProjectID 
                                         AND ISAPPROVEDORMUTE = 2 
                                         AND TICKETPATTERN <> '0') 

                --Approve and mutecount from ui  
                SELECT @ApprovedCount                              AS 'ApprovedCount', 
                       @MuteCount                                  AS 'MuteCount', 
                       @TicketConsideredML + @TicketConsideredMLTC AS 'TicketConsidered', 
                       @TicketAnalysedTS + @TicketAnalysedTC       AS 'TicketAnalysed', 
                       0                                           AS 'SamplingCount', 
                       0                                           AS 'PatternCount' 
            END 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage1 VARCHAR(MAX); 

          SELECT @ErrorMessage1 = ERROR_MESSAGE() 

          --INSERT Error      
          EXEC AVL_INSERTERROR 
            '[AVL].[MLInfraGetIconDetailsByChoice]', 
            @ErrorMessage1, 
            @ProjectID, 
            0 
      END CATCH 
  END
