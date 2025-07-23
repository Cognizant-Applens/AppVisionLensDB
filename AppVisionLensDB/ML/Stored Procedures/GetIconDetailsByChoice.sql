-- =============================================  
-- Author:    627384  
-- Create date: 11-FEB-2019  
-- Description:   SP for Initial Learning  
-- [ML].[GetIconDetailsByChoice] 8354,2
-- =============================================  
CREATE PROCEDURE [ML].[GetIconDetailsByChoice] 
  @ID BIGINT, --ProjectId, 
  @Choice INT,
  @IsRegenerate BIT
AS 
  BEGIN 
      BEGIN TRY 
	  SET NOCOUNT ON;
		  DECLARE @StartDate DATETIME,@EndDate DATETIME,
                @IsTicketDescOpt BIT,@DebtAttributes TINYINT,
				@MlCount SMALLINT;

		  CREATE TABLE #InitialLearningDetails(
			InitialLearningID BIGINT
		  )
		  SET @MlCount = (SELECT COUNT(*) FROM ML.ConfigurationProgress(NOLOCK)
										WHERE ProjectID = @ID AND IsDeleted = 0)
		  IF(@IsRegenerate=0 AND @MlCount > 1)
		  BEGIN
				INSERT INTO #InitialLearningDetails
						SELECT ID FROM ML.ConfigurationProgress (NOLOCK)
                           				WHERE PROJECTID = @ID 
										AND ISDELETED = 0 
								 		AND ISNULL(IsMLSentOrReceived,'') = 'Received'
								 
		  END
		  ELSE
		  BEGIN
				INSERT INTO #InitialLearningDetails
						SELECT TOP 1 ID FROM  ML.ConfigurationProgress (NOLOCK)
										WHERE  PROJECTID = @ID 
											   AND ISDELETED = 0 
										ORDER  BY ID DESC
		  END

		  SELECT @IsTicketDescOpt = IsTicketDescriptionOpted,@DebtAttributes = DebtAttributeId
				FROM ML.ConfigurationProgress(NOLOCK) WHERE  PROJECTID = @ID 
													 AND ISDELETED = 0 
                                                     ORDER  BY ID DESC

		  IF(@IsRegenerate=0 AND @MlCount > 1)
		  BEGIN
				SET @StartDate = (SELECT MIN(FromDate) FROM ml.ConfigurationProgress(NOLOCK)
														WHERE ProjectID=@ID 
														AND IsDeleted=0
														AND ISNULL(IsMLSentOrReceived,'')='Received')

				SET @EndDate = (SELECT MAX(ToDate) FROM ml.ConfigurationProgress(NOLOCK)
												   WHERE ProjectID=@ID 
												   AND IsDeleted=0 
												   AND ISNULL(IsMLSentOrReceived,'')='Received')
		  END
		  ELSE
		  BEGIN
				SELECT TOP 1 @StartDate = FromDate,@EndDate=ToDate
				FROM ML.ConfigurationProgress (NOLOCK)
				WHERE  PROJECTID = @ID 
                AND ISDELETED = 0 
                ORDER  BY ID DESC
		  END

          ---Getting the ticket details for the specific project into temp table  
          SELECT TD.TICKETID                AS TicketID, 
                 TD.PROJECTID            AS ProjectID, 
                 TD.DEBTCLASSIFICATIONMAPID AS DebtClassificationId, 
                 TD.AVOIDABLEFLAG           AS AvoidableFlagID, 
                 TD.RESIDUALDEBTMAPID       AS ResidualDebtID, 
                 TD.CAUSECODEMAPID          AS CauseCodeID, 
                 TD.RESOLUTIONCODEMAPID     AS ResolutionCodeID, 
                 TD.APPLICATIONID        AS ApplicationID 
          INTO   #TMPCOUNT 
          FROM AVL.TK_TRN_TicketDetail(NOLOCK) TD
				JOIN ML.TicketValidation(NOLOCK) TV ON TV.TicketID = TD.TicketID
					AND TV.ProjectID = TD.ProjectID
					JOIN #InitialLearningDetails ILD ON ILD.InitialLearningID = TV.InitialLearningID
					WHERE TD.Projectid = @ID
					AND TD.Isdeleted = 0 AND TV.IsDeleted = 0
					AND	((@IsTicketDescOpt = 1 AND ((TD.DARTStatusID = 8 AND TD.Closeddate BETWEEN @StartDate AND @EndDate)
					OR (TD.DARTStatusID = 9 AND TD.CompletedDateTime BETWEEN @StartDate AND @EndDate)))
					OR (@IsTicketDescOpt = 0))


          --Choice=1:when sampling grid is loaded  
          --choice=2: when ml patterns grid is loaded 
          IF ( @Choice = 1 ) 
            BEGIN 
                DECLARE @TicketAnalysed   BIGINT = 0, 
                        @TicketConsidered BIGINT = 0, 
                        @SamplingCount    BIGINT = 0 
                                         
                      --count of tickets  from ticket validation  
                      SET @TicketAnalysed = (SELECT COUNT(DISTINCT TV.TICKETID) 
                                             FROM   ML.TICKETVALIDATION (NOLOCK) TV
                                                                             JOIN #TMPCOUNT TD ON TV.ProjectID= TD.ProjectID AND TV.IsDeleted=0
                                                                           AND TV.TicketID=TD.TicketID
																		   JOIN #InitialLearningDetails ILD
																				ON TV.InitialLearningId =ILD.InitialLearningID
                                             WHERE  TV.PROJECTID = @ID 
                                    AND TV.ISDELETED = 0) 
                      --COUNT of tickets  ticket desc is not null or ticket desc is not empty  
                      SET @TicketConsidered = (SELECT COUNT(DISTINCT TV.TICKETID) 
                                               FROM   ML.TICKETVALIDATION(NOLOCK) TV
                                                                               JOIN #TMPCOUNT TD ON TV.ProjectID=TD.ProjectID AND TV.IsDeleted=0
                                                                           AND TV.TicketID=TD.TicketID
																		   JOIN #InitialLearningDetails ILD
													ON TV.InitialLearningID =ILD.InitialLearningID
                                               WHERE  TV.PROJECTID = @ID 
                                                      AND TV.ISDELETED = 0 
                                                    AND ((@IsTicketDescOpt = 1 AND TV.TICKETDESCRIPTION IS NOT NULL 
                                                            AND TV.TICKETDESCRIPTION <> '' ) OR
                                        (@IsTicketDescOpt = 0 AND TV.TicketDescriptionBasePattern IS NOT NULL 
                AND TV.TicketDescriptionBasePattern <> '0' ))) 
                      --COUNT of sampled tickets in Ticketsaftersampling table  
                      SET @SamplingCount = (SELECT COUNT(DISTINCT TS.TICKETID) 
                                            FROM   ML.TRN_TicketsAfterSampling(NOLOCK) TS
                                                                           JOIN #TMPCOUNT TD ON TS.ProjectID=TD.ProjectID AND TS.IsDeleted=0
                                                                           AND TS.TicketID=TD.TicketID
																		   JOIN #InitialLearningDetails ILD
													ON TS.InitialLearningId =ILD.InitialLearningID
													WHERE  TS.PROJECTID = @ID 
													AND TS.ISDELETED = 0 
													AND TS.DESC_BASE_WORKPATTERN <> '0'
													AND TS.DebtClassifiedBy = 2) 
                  

                SELECT @TicketAnalysed   AS 'TicketAnalysed', 
            @TicketConsidered AS 'TicketConsidered', 
                       @SamplingCount    AS 'SamplingCount', 
                       0                 AS 'PatternCount', 
                       0                 AS 'ApprovedCount', 
                       0                 AS 'MuteCount' 
            END 
          ELSE IF ( @Choice = 2 ) 
            BEGIN 
                --No Regeneration concept here as last grid contain all the pattern irrespective of application id
                           DECLARE @TicketAnalysedTC     BIGINT = 0, 
                        @TicketConsideredML   BIGINT = 0, 
                        @PatternCount         BIGINT = 0, 
                        @TicketAnalysedTS     BIGINT = 0, 
                        @TicketConsideredMLTC BIGINT = 0,
                                         @ApprovedCount BIGINT = 0, 
                        @MuteCount     BIGINT = 0,
                                         @PendingReviewCount         BIGINT = 0 

                --PRINT @InitialLearningID 

                SET @TicketAnalysedTS = (SELECT COUNT(DISTINCT TS.TICKETID) 
                                         FROM   [ML].[TRN_TicketsAfterSampling](NOLOCK) TS 
                                                JOIN [ML].[ConfigurationProgress](NOLOCK) IL 
                                                  ON IL.PROJECTID = TS.PROJECTID 
   AND IL.ISDELETED = 0 
             AND IL.ISSAMPLINGINPROGRESS IS NOT NULL
												JOIN #InitialLearningDetails ILD
												  ON il.ID =ILD.InitialLearningID
                                                JOIN #TMPCOUNT TC 
                                                  ON TC.TICKETID = TS.TICKETID 
            AND TC.PROJECTID = TS.PROJECTID 
                                                     AND TC.APPLICATIONID = TS.APPLICATIONID 
                                         WHERE  IL.PROJECTID = @ID 
                     AND TS.ISDELETED = 0 AND TS.DebtClassifiedBy = 2
                                             ) 

                PRINT @TicketAnalysedTS 

                IF ( @TicketAnalysedTS = 0 ) 
                  BEGIN 
                      SET @TicketAnalysedTC = (SELECT COUNT(DISTINCT TV.TICKETID) 
                                               FROM   ML.TICKETVALIDATION (NOLOCK) TV 
                                                      JOIN #TMPCOUNT TC 
                                                        ON TC.TICKETID = TV.TICKETID 
                                                           AND TC.PROJECTID = TV.PROJECTID 
                                                           AND TC.APPLICATIONID = TV.APPLICATIONID
                                               WHERE  TV.PROJECTID = @ID AND TV.TicketSourceFrom = 'ML'
                             AND TV.ISDELETED = 0) 
                                         
                                         SET @TicketAnalysedTC = @TicketAnalysedTC + (SELECT COUNT(DISTINCT TV.TICKETID) 
           FROM   ML.TICKETVALIDATION (NOLOCK) TV 
                                                      --JOIN #TMPCOUNT TC 
                                                      --  ON TC.TICKETID = TV.TICKETID 
                                                      --     AND TC.PROJECTID = TV.PROJECTID 
                                                      --     AND TC.APPLICATIONID = TV.APPLICATIONID
                                               WHERE  TV.PROJECTID = @ID 
                                                      AND TV.ISDELETED = 0 AND TV.TicketSourceFrom = 'CL')
                  END 
                ELSE 
                  BEGIN 
                      SET @TicketAnalysedTC = (SELECT COUNT(DISTINCT TV.TICKETID) 
                                               FROM   ML.TICKETVALIDATION (NOLOCK) TV 
                                                      JOIN #TMPCOUNT TC 
                                                        ON TC.TICKETID = TV.TICKETID 
                                                           AND TC.PROJECTID = TV.PROJECTID 
                                                           AND TC.APPLICATIONID = TV.APPLICATIONID
                                               WHERE  TV.PROJECTID = @ID 
                                                      AND TV.ISDELETED = 0 AND TV.TicketSourceFrom = 'ML'
                                                      AND NOT EXISTS (SELECT DISTINCT TS.TicketID
                                                           FROM   [ML].[TRN_TicketsAfterSampling] (NOLOCK) TS
                                                                      WHERE  TS.TICKETID = TV.TICKETID
                                                                                                                                  AND TS.ISDELETED = 0                                                                      
                                                                             AND TV.PROJECTID = TS.PROJECTID
																			 AND TS.DebtClassifiedBy = 2))

                                         SET @TicketAnalysedTC = @TicketAnalysedTC + (SELECT COUNT(DISTINCT TV.TICKETID) 
                                               FROM   ML.TICKETVALIDATION (NOLOCK) TV 
                                                      --JOIN #TMPCOUNT TC 
    --  ON TC.TICKETID = TV.TICKETID 
                                         --     AND TC.PROJECTID = TV.PROJECTID 
                --     AND TC.APPLICATIONID = TV.APPLICATIONID
                                               WHERE  TV.PROJECTID = @ID 
                                                      AND TV.ISDELETED = 0 AND TV.TicketSourceFrom = 'CL')
                  END 

                PRINT @TicketAnalysedTC 

                PRINT @TicketAnalysedTS 
                
                SET @TicketConsideredML = (SELECT COUNT(DISTINCT TS.TICKETID) 
                                           FROM   ML.TRN_TicketsAfterSampling(NOLOCK) TS 
                                                  JOIN ML.ConfigurationProgress(NOLOCK) IL 
                                                    ON IL.PROJECTID = TS.PROJECTID 
                                                       AND IL.IsDeleted=0
												  JOIN #InitialLearningDetails ILD
													ON il.ID =ILD.InitialLearningID
                                                  JOIN #TMPCOUNT TC 
                                                    ON TC.PROJECTID = TS.PROJECTID 
                                                       AND TS.TICKETID = TC.TICKETID 
                                                       AND IL.ISDELETED = 0 
                                                       AND IL.ISSAMPLINGINPROGRESS IS NOT NULL 
                                           WHERE  TS.PROJECTID = @ID 
                                                  AND TS.ISDELETED = 0 
												  AND TS.DebtClassifiedBy = 2
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
                                                   FROM   ML.TICKETVALIDATION(NOLOCK) TV
               JOIN #TMPCOUNT TC 
          ON TC.TICKETID = TV.TICKETID 
                                                               AND TC.PROJECTID = TV.PROJECTID 
                                                           AND TC.APPLICATIONID = TV.APPLICATIONID
                   WHERE  TV.PROJECTID = @ID 
                       AND TV.ISDELETED = 0 
                                                          AND ((@IsTicketDescOpt =1
                                         AND TV.TICKETDESCRIPTION IS NOT NULL
                                                                AND TV.TICKETDESCRIPTION <> '' )
                                                                                                 OR  (@IsTicketDescOpt =0
                                                                                                              AND TV.TicketDescriptionBasePattern IS NOT NULL
                                                                AND TV.TicketDescriptionBasePattern <> '0' ))
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
                                                   FROM   ML.BaseDetails (NOLOCK) MB
                                                          JOIN #TMPCOUNT TC 
                                                            ON TC.TICKETID = MB.TICKETID 
                                                               AND TC.PROJECTID = MB.PROJECTID 
                                                              -- AND TC.APPLICATIONID = TV.APPLICATIONID
                                                    WHERE  MB.PROJECTID = @ID 
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
                                                                                                  AND ( MB.TICKETDESCRIPTIONPATTERN IS NOT NULL 
                                                                AND MB.TICKETDESCRIPTIONPATTERN <> '' ) 
                                                                               AND MB.InitialLearningID IS NOT NULL
                            AND NOT EXISTS (SELECT DISTINCT TS.TicketID 
                                                                          FROM   [ML].[TRN_TicketsAfterSampling](NOLOCK) TS
     WHERE  TS.PROJECTID = MB.PROJECTID
     AND TS.TICKETID = MB.TICKETID    
                                       AND TS.ISDELETED = 0 AND TS.DebtClassifiedBy = 2                                                                                                               
                                                                                                                                          ))
                 SET @TicketConsideredMLTC = @TicketConsideredMLTC + (SELECT COUNT(DISTINCT MB.TICKETID) 
                                                   FROM   ML.BaseDetails (NOLOCK) MB
                                                   --       JOIN #TMPCOUNT TC 
                                                   --         ON TC.TICKETID = MB.TICKETID 
                                                   --AND TC.PROJECTID = MB.PROJECTID 
                                                              -- AND TC.APPLICATIONID = TV.APPLICATIONID
            WHERE  MB.PROJECTID = @ID 
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
                                                          AND ( MB.TICKETDESCRIPTIONPATTERN IS NOT NULL 
                                                                AND MB.TICKETDESCRIPTIONPATTERN <> '' ) 
                                                                                                  AND MB.InitialLearningID IS NULL AND MB.ContinuousLearningID IS NOT NULL)
                  END 
                            print  @TicketConsideredML
                PRINT @TicketConsideredMLTC 
				IF(@DebtAttributes = 1)
				BEGIN
                           SET @PatternCount = (SELECT COUNT(*) as patterncount from 
                                                (SELECT ApplicationID,MLCauseCodeID,MLResolutionCode,
                                                TicketPattern,subPattern,additionalPattern,additionalSubPattern
                            FROM   ML.TRN_PATTERNVALIDATION (NOLOCK) 
                            WHERE  PROJECTID = @ID
                                AND ISDELETED = 0                                 
								AND ISNULL(ApplicationID,0) <> 0
								AND ISNULL(MLCauseCodeID,'') <> ''
								AND ISNULL(MLResolutionCode,'') <> ''
								AND ISNULL(TicketPattern,'0') <> '0'                                             group by ApplicationID,MLCauseCodeID,MLResolutionCode,
                                                TicketPattern,subPattern,additionalPattern,additionalSubPattern      ) as patterns)   
				END
				ELSE
				BEGIN
						SET @PatternCount = (SELECT COUNT(*) as patterncount from 
                                                (SELECT ApplicationID,
                                     TicketPattern,subPattern,additionalPattern,additionalSubPattern
   FROM   ML.TRN_PATTERNVALIDATION (NOLOCK) 
                            WHERE  PROJECTID = @ID 
                                AND ISDELETED = 0                                 
								AND ISNULL(ApplicationID,0) <> 0								
								AND ISNULL(TicketPattern,'0') <> '0'
                                                group by ApplicationID,
                                                TicketPattern,subPattern,additionalPattern,additionalSubPattern      ) as patterns)
				END

                           SET @ApprovedCount=  (SELECT COUNT(*)
                                      FROM   ML.TRN_PATTERNVALIDATION (NOLOCK)
         WHERE  ISDELETED = 0 
                                             AND PROJECTID = @ID 
                                             AND ISAPPROVEDORMUTE = 1
                                             AND TICKETPATTERN <> '0')                                               
                                                

                           SET @MuteCount = (SELECT COUNT(*)
                                      FROM   ML.TRN_PATTERNVALIDATION (NOLOCK)
                                      WHERE  ISDELETED = 0 
                                             AND PROJECTID = @ID 
                                             AND ISAPPROVEDORMUTE = 2
                                             AND TICKETPATTERN <> '0')                                                            
                                         
                           SET @PendingReviewCount = @PatternCount - (@ApprovedCount + @MuteCount)
                           

                --Approve and mutecount from ui  
               SELECT  @ApprovedCount                              AS 'ApprovedCount', 
                       @MuteCount                                  AS 'MuteCount', 
                       @PatternCount                               AS 'PatternCount',
                       @TicketConsideredML + @TicketConsideredMLTC AS 'TicketConsidered', 
					   @TicketAnalysedTS + @TicketAnalysedTC       AS 'TicketAnalysed',
					   @PendingReviewCount                         AS 'PendingReviewCount',
                       0                                           AS 'SamplingCount', 
                       0                                           AS 'MuteCount' 
            END   
		SET NOCOUNT OFF
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage1 VARCHAR(MAX); 

          SELECT @ErrorMessage1 = ERROR_MESSAGE() 

          --INSERT Error      
          EXEC AVL_INSERTERROR 
            '[ML].[GetIconDetailsByChoice]', 
            @ErrorMessage1, 
            @ID, 
            0 
     END CATCH 
  END
