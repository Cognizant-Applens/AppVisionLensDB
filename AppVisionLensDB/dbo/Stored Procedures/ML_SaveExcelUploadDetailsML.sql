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
-- Description:    SP for Initial Learning 
-- MODIFICATION HISTORY 
-- USERID    NAME     DATE             REASON 
-- 687591    MENAKA   29-5-2019        Included MultiLingual code
-- ============================================================================ 
CREATE PROCEDURE [dbo].[ML_SaveExcelUploadDetailsML] (@UserID                        VARCHAR(50), 
                                                @ProjectID                     VARCHAR(200), 
                                                @TVP_lstDebtExcelUploadTickets TVP_SAVEDEBTUPLOADTICKETS READONLY,
                                                @OptionalFieldId               INT) 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

		 DECLARE @InitialID BIGINT; 

	     SET @InitialID = (SELECT TOP 1 ISNULL(ID, 0) 
                            FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE (NOLOCK) 
                            WHERE  ProjectID = @ProjectID 
                                   AND IsDeleted = 0 
                            ORDER  BY ID DESC) 

          CREATE TABLE #DEBTUPLOADTICKETS 
            ( 
               TicketId           VARCHAR(1000) NULL, 
               TicketDescription  NVARCHAR(MAX) NULL, 
               ApplicationName    VARCHAR(500) NULL, 
               DebtClassification VARCHAR(500) NULL, 
               AvoidableFlag      VARCHAR(500) NULL, 
               CauseCode          VARCHAR(500) NULL, 
               ResolutionCode     VARCHAR(500) NULL, 
               ResidualDebt       VARCHAR(500) NULL, 
               OptionalFieldProj  NVARCHAR(4000) NULL,
			   IsTicketSummaryUpdated BIT NULL,
			   IsTicketDescriptionUpdated BIT NULL 
            ) 

          INSERT INTO #DEBTUPLOADTICKETS 
          SELECT TicketId, 
                 TicketDescription, 
                 ApplicationName, 
                 DebtClassification, 
                 AvoidableFlag, 
                 CauseCode, 
                 ResolutionCode, 
                 ResidualDebt, 
                 OptionalFieldProj,
				 IsTicketDescriptionUpdated,
				 IsTicketSummaryUpdated
				  
          FROM   @TVP_lstDebtExcelUploadTickets 

 /*****************************Multilingual******************************/
DECLARE @isMultiLingual INT=0;
		DECLARE @IsResolutionRemarks [BIT]=0,
				@IsComments [BIT] =0,
				--@IsCauseCode [BIT],
				--@IsResolutionCode [BIT],
				@IsFlexField1 [BIT]=0,
				@IsFlexField2[BIT]=0,
				@IsFlexField3 [BIT]=0,
				@IsFlexField4 [BIT]=0,
				@IsCategory [BIT]=0,
				@IsType [BIT]=0;

	SELECT @isMultiLingual=1 FROM AVL.MAS_ProjectMaster WITH (NOLOCK) WHERE ProjectID=@projectid AND
	IsDeleted=0 AND IsMultilingualEnabled=1;
	
	IF(@isMultiLingual=1)
		BEGIN
		PRINT 'Inside Multilingual 1';
		SELECT DISTINCT MCM.ColumnID INTO #Columns FROM AVL.MAS_MultilingualColumnMaster MCM WITH (NOLOCK) 
		JOIN AVL.PRJ_MultilingualColumnMapping MCP WITH(NOLOCK) ON MCM.ColumnID=MCP.ColumnID
		WHERE MCM.IsActive=1 AND MCP.IsActive=1
		AND MCP.ProjectID=@projectid;

		--SELECT * FROM #Columns;
		SELECT @IsResolutionRemarks=1 FROM #Columns WHERE ColumnID=3;
			SELECT @IsComments=1 FROM #Columns WHERE ColumnID=4;
				SELECT @IsFlexField1=1 FROM #Columns WHERE ColumnID=7;
					SELECT @IsFlexField2=1 FROM #Columns WHERE ColumnID=8;
						SELECT @IsFlexField3=1 FROM #Columns WHERE ColumnID=9;
							SELECT @IsFlexField4=1 FROM #Columns WHERE ColumnID=10;
								SELECT @IsCategory=1 FROM #Columns WHERE ColumnID=11;
								SELECT @IsType=1 FROM #Columns WHERE ColumnID=12;

		
		SELECT ITD.[TicketID],TD.TimeTickerID,ITD.IsTicketSummaryUpdated,ITD.IsTicketDescriptionUpdated,
CASE WHEN (@IsResolutionRemarks =1 AND (( ITD.[OptionalFieldProj]=TD.ResolutionRemarks) 
			OR (ITD.[OptionalFieldProj]='') OR (ITD.[OptionalFieldProj] IS NULL)))
			OR (@IsResolutionRemarks !=1) OR (@OptionalFieldId != 1)
			THEN 0 ELSE 1 END AS 'IsResolutionRemarksModified',
CASE WHEN (@IsComments =1 AND (( ITD.OptionalFieldProj=TD.Comments) OR (ITD.OptionalFieldProj='') OR 
			(ITD.OptionalFieldProj IS NULL))) OR (@IsComments !=1)  OR (@OptionalFieldId != 3)
			THEN 0 ELSE 1 END AS 'IsCommentsModified'
INTO #MultilingualTbl2
FROM  #DEBTUPLOADTICKETS ITD LEFT JOIN AVL.TK_TRN_TicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.[TicketID] 
AND TD.ProjectID=@projectid AND TD.IsDeleted=0;

UPDATE ITD SET ITD.TimeTickerID=TD.TimeTickerID
FROM #MultilingualTbl2 ITD JOIN AVL.TK_TRN_TicketDetail TD WITH (NOLOCK) ON TD.TicketID=ITD.[TicketID] 
AND TD.ProjectID=@projectid AND TD.IsDeleted=0;

MERGE [AVL].[TK_TRN_Multilingual_TranslatedTicketDetails] AS TARGET
USING #MultilingualTbl2 AS SOURCE
ON (Target.TimeTickerID=SOURCE.TimeTickerID)
WHEN MATCHED  
THEN 
UPDATE SET TARGET.IsTicketDescriptionUpdated=(CASE WHEN SOURCE.IsTicketDescriptionUpdated=1 THEN 1 ELSE TARGET.IsTicketDescriptionUpdated END),
TARGET.IsTicketSummaryUpdated=(CASE WHEN SOURCE.IsTicketSummaryUpdated=1 THEN 1 ELSE TARGET.IsTicketSummaryUpdated END),
TARGET.IsResolutionRemarksUpdated=(CASE WHEN SOURCE.IsResolutionRemarksModified=1 THEN 1 ELSE TARGET.IsResolutionRemarksUpdated END),
TARGET.IsCommentsUpdated=(CASE WHEN SOURCE.IsCommentsModified=1 THEN 1 ELSE TARGET.IsCommentsUpdated END),
TARGET.ModifiedBy=@UserID,
TARGET.ModifiedDate=GETDATE(),
TARGET.TicketCreatedType=4,
TARGET.ReferenceID = @InitialID
WHEN NOT MATCHED BY TARGET 
THEN 
INSERT (TimeTickerID,IsTicketDescriptionUpdated,IsResolutionRemarksUpdated,IsTicketSummaryUpdated,
IsCommentsUpdated,Isdeleted,CreatedBy,CreatedDate,TicketCreatedType,ReferenceID ) 
VALUES (SOURCE.TimeTickerID,SOURCE.IsTicketDescriptionUpdated,SOURCE.IsResolutionRemarksModified,
SOURCE.IsTicketSummaryUpdated,SOURCE.IsCommentsModified,0,@UserID,GETDATE(),4,@InitialID);
end

	/**********************************************************************/


          SELECT ProjectID, 
                 TicketID, 
                 TicketDescription, 
                 DebtClassificationID, 
                 AvoidableFlagID, 
                 ResolutionCodeID, 
                 CauseCodeID, 
                 ResidualDebtID 
          INTO   #TEMPFORTICKETDESCRIPTION 
          FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) 
          WHERE  ProjectID = @ProjectID 
                 AND ( TicketDescription IS NULL 
                        OR TicketDescription = '' 
                           AND TicketDescription != '***' ) 

          IF ( @OptionalFieldId = 2 ) 
            BEGIN 
                SELECT ProjectID, 
                       TicketID, 
                       TicketDescription, 
                       DebtClassificationID, 
                       AvoidableFlagID, 
                       ResolutionCodeID, 
                       CauseCodeID, 
                       ResidualDebtID, 
                       OptionalFieldProj 
                INTO   #TEMPFORTICKETSUMMARY 
                FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) 
                WHERE  ProjectID = @ProjectID 
                       AND ( OptionalFieldProj IS NULL 
                              OR OptionalFieldProj = '' 
                                 AND OptionalFieldProj != '***' ) 
            END 
          ELSE IF ( @OptionalFieldId <> 4 ) 
            BEGIN 
                SELECT ProjectID, 
                       TicketID, 
                       TicketDescription, 
                       DebtClassificationID, 
                       AvoidableFlagID, 
                       ResolutionCodeID, 
                       CauseCodeID, 
                       ResidualDebtID, 
                       OptionalFieldProj 
                INTO   #TEMPFOROPTREST 
                FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) 
                WHERE  ProjectID = @ProjectID 
                       AND ( OptionalFieldProj IS NULL 
                              OR OptionalFieldProj = '' ) 
            END 

          UPDATE X2 
          SET    X2.TicketDescription = debt.TicketDescription, 
                 X2.[ModifiedBy] = @UserID, 
                 X2.[ModifiedDate] = GETDATE() 
          FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) X2 
                 JOIN #DEBTUPLOADTICKETS (NOLOCK) debt 
                   ON debt.TicketId = X2.TicketID 
          WHERE  X2.PROJECTID = @ProjectID 
                 AND ( X2.TicketDescription IS NULL 
                        OR X2.TicketDescription = '' ) 
                 AND debt.TicketDescription <> '***' 

          UPDATE X2 
          SET    X2.OptionalFieldProj = debt.OptionalFieldProj, 
                 X2.[ModifiedBy] = @UserID, 
                 X2.[ModifiedDate] = GETDATE() 
          FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) X2 
                 JOIN #DEBTUPLOADTICKETS (NOLOCK) debt 
                   ON debt.TicketId = X2.TicketID 
          WHERE  X2.PROJECTID = @ProjectID 
                 AND ( X2.OptionalFieldProj IS NULL 
                        OR X2.OptionalFieldProj = '' ) 
                 AND debt.OptionalFieldProj <> '***' 

          UPDATE ticket 
          SET    ticket.[TicketDescription] = debt.TicketDescription, 
                 ticket.[ModifiedBy] = @UserID, 
                 ticket.[ModifiedDate] = GETDATE(),
				 ticket.LastUpdatedDate=GETDATE()
          FROM   [AVL].[TK_TRN_TICKETDETAIL] (NOLOCK) ticket 
                 JOIN #TEMPFORTICKETDESCRIPTION (NOLOCK) X5 
                   ON ticket.TicketId = X5.TicketID 
                 JOIN #DEBTUPLOADTICKETS debt 
                   ON debt.TicketId = X5.TicketID 
          WHERE  ticket.PROJECTID = @ProjectID 
                 AND ( X5.TicketDescription IS NULL 
                        OR X5.TicketDescription = '' ) 
                 AND debt.TicketDescription <> '***' 

          IF ( @OptionalFieldId = 2 ) 
            BEGIN 
                UPDATE ticket 
                SET    ticket.TicketSummary = debt.OptionalFieldProj, 
                       ticket.[ModifiedBy] = @UserID, 
                       ticket.[ModifiedDate] = GETDATE(),
					   ticket.LastUpdatedDate=GETDATE()
                FROM   [AVL].[TK_TRN_TICKETDETAIL] (NOLOCK) ticket 
                       JOIN #TEMPFORTICKETSUMMARY (NOLOCK) X5 
                         ON ticket.TicketId = X5.TicketID 
                       JOIN #DEBTUPLOADTICKETS debt 
                         ON debt.TicketId = X5.TicketID 
                WHERE  ticket.PROJECTID = @ProjectID 
                       AND ( X5.OptionalFieldProj IS NULL 
                              OR X5.OptionalFieldProj = '' ) 
                       AND debt.OptionalFieldProj <> '***' 
            END 
          ELSE IF ( @OptionalFieldId = 1 ) 
            BEGIN 
                UPDATE ticket 
                SET    ticket.ResolutionRemarks = debt.OptionalFieldProj, 
                       ticket.[ModifiedBy] = @UserID, 
                       ticket.[ModifiedDate] = GETDATE(),
					   ticket.LastUpdatedDate=GETDATE()
                FROM   [AVL].[TK_TRN_TICKETDETAIL] (NOLOCK) ticket 
                       JOIN #TEMPFOROPTREST (NOLOCK) X5 
                         ON ticket.TicketId = X5.TicketID 
                       JOIN #DEBTUPLOADTICKETS (NOLOCK) debt 
                         ON debt.TicketId = X5.TicketID 
                WHERE  ticket.PROJECTID = @ProjectID 
                       AND ( ticket.ResolutionRemarks IS NULL 
                              OR ticket.ResolutionRemarks = '' ) 
            END 
          ELSE IF ( @OptionalFieldId = 3 ) 
            BEGIN 
                UPDATE ticket 
                SET    ticket.Comments = debt.OptionalFieldProj, 
                       ticket.[ModifiedBy] = @UserID, 
                       ticket.[ModifiedDate] = GETDATE(),
					   ticket.LastUpdatedDate=GETDATE()
                FROM   [AVL].[TK_TRN_TICKETDETAIL] (NOLOCK) ticket 
                       JOIN #TEMPFOROPTREST (NOLOCK) X5 
                         ON ticket.TicketId = X5.TicketID 
                       JOIN #DEBTUPLOADTICKETS (NOLOCK) debt 
                         ON debt.TicketId = X5.TicketID 
                WHERE  ticket.PROJECTID = @ProjectID 
                       AND ( ticket.Comments IS NULL 
                              OR ticket.Comments = '' ) 
            END 

          UPDATE X2 
          SET    X2.DebtClassificationId = x3.[DebtClassificationID], 
                 X2.[ModifiedBy] = @UserID, 
                 X2.[ModifiedDate] = GETDATE() 
          FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) X2 
                 JOIN #DEBTUPLOADTICKETS (NOLOCK) debt 
                   ON debt.TicketId = X2.TicketID 
                 JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] (NOLOCK) X3 
                   ON debt.DebtClassification = X3.[DebtClassificationName] 
          WHERE  X2.ProjectID = @ProjectID 
                 AND ( X2.DebtClassificationId IS NULL 
                        OR X2.DebtClassificationId = 0 
                        OR X2.DebtClassificationId = '' ) 
                 AND X3.IsDeleted = 0 

          UPDATE X5 
          SET    X5.[DebtClassificationMapID] = x3.[DebtClassificationID], 
                 X5.[ModifiedBy] = @UserID, 
                 X5.[ModifiedDate] = GETDATE(),
				 X5.LastUpdatedDate=GETDATE()
          FROM   [AVL].[TK_TRN_TICKETDETAIL] (NOLOCK) X5 
                 JOIN #DEBTUPLOADTICKETS debt 
                   ON debt.TicketId = X5.TicketID 
                 JOIN [AVL].[DEBT_MAS_DEBTCLASSIFICATION] (NOLOCK) X3 
                   ON debt.DebtClassification = X3.[DebtClassificationName] 
          WHERE  X5.ProjectID = @ProjectID 
                 AND ( X5.[DebtClassificationMapID] IS NULL 
                        OR X5.[DebtClassificationMapID] = 0 
                        OR X5.[DebtClassificationMapID] = '' ) 

          UPDATE X2 
          SET    X2.[AvoidableFlagID] = x3.AvoidableFlagID, 
                 X2.[ModifiedBy] = @UserID, 
                 X2.[ModifiedDate] = GETDATE() 
          FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) X2 
                 JOIN #DEBTUPLOADTICKETS debt 
                   ON debt.TicketId = X2.TicketID 
                 JOIN AVL.DEBT_MAS_AVOIDABLEFLAG (NOLOCK) X3 
                   ON debt.AvoidableFlag = X3.AvoidableFlagName 
          WHERE  X2.ProjectID = @ProjectID 
                 AND ( X2.[AvoidableFlagID] IS NULL 
                        OR X2.[AvoidableFlagID] = 0 
                        OR X2.[AvoidableFlagID] = '' ) 
                 AND X3.IsDeleted = 0 

          UPDATE X5 
          SET    X5.[AvoidableFlag] = x3.AvoidableFlagID, 
                 X5.[ModifiedBy] = @UserID, 
                 X5.[ModifiedDate] = GETDATE(),
				 X5.LastUpdatedDate=GETDATE()
          FROM   [AVL].[TK_TRN_TICKETDETAIL] (NOLOCK) X5 
                 JOIN #DEBTUPLOADTICKETS debt 
                   ON debt.TicketId = X5.TicketID 
                 JOIN AVL.DEBT_MAS_AVOIDABLEFLAG (NOLOCK) X3 
                   ON debt.AvoidableFlag = X3.AvoidableFlagName 
          WHERE  X5.ProjectID = @ProjectID 
                 AND ( X5.[AvoidableFlag] IS NULL 
                        OR X5.[AvoidableFlag] = 0 
                        OR X5.[AvoidableFlag] = '' ) 

          UPDATE X2 
          SET    X2.ResidualDebtID = x3.[ResidualDebtID], 
                 X2.[ModifiedBy] = @UserID, 
                 X2.[ModifiedDate] = GETDATE() 
          FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) X2 
                 JOIN #DEBTUPLOADTICKETS debt 
                   ON debt.TicketId = X2.TicketID 
                 JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] (NOLOCK) X3 
                   ON debt.ResidualDebt = X3.[ResidualDebtName] 
    WHERE  X2.ProjectID = @ProjectID 
                 AND ( X2.[ResidualDebtID] IS NULL 
                        OR X2.[ResidualDebtID] = 0 
                        OR X2.[ResidualDebtID] = '' ) 
                 AND X3.IsDeleted = 0 

          UPDATE X5 
          SET    X5.[ResidualDebtMapID] = x3.[ResidualDebtID], 
                 X5.[ModifiedBy] = @UserID, 
                 X5.[ModifiedDate] = GETDATE(),
				 X5.LastUpdatedDate=GETDATE()
          FROM   [AVL].[TK_TRN_TICKETDETAIL] (NOLOCK) X5 
                 JOIN #DEBTUPLOADTICKETS debt 
                   ON debt.TicketId = X5.TicketID 
                 JOIN [AVL].[DEBT_MAS_RESIDUALDEBT] (NOLOCK) X3 
                   ON debt.ResidualDebt = X3.[ResidualDebtName] 
          WHERE  X5.ProjectID = @ProjectID 
                 AND ( X5.[ResidualDebtMapID] IS NULL 
                        OR X5.[ResidualDebtMapID] = 0 
                        OR X5.[ResidualDebtMapID] = '' ) 

          UPDATE X2 
          SET    X2.[CauseCodeID] = x3.[CauseID], 
                 X2.[ModifiedBy] = @UserID, 
                 X2.[ModifiedDate] = GETDATE() 
          FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) X2 
                 JOIN #DEBTUPLOADTICKETS debt 
                   ON debt.TicketId = X2.TicketID 
                 JOIN [AVL].[DEBT_MAP_CAUSECODE] (NOLOCK) X3 
                   ON debt.CauseCode = X3.[CauseCode] 
                      AND X3.IsDeleted = 0 
                      AND X2.ProjectID = X3.ProjectID 
          WHERE  x2.ProjectID = @ProjectID 
                 AND ( X2.[CauseCodeID] IS NULL 
                        OR X2.[CauseCodeID] = 0 
                        OR X2.[CauseCodeID] = '' ) 

          UPDATE X5 
          SET    X5.[CauseCodeMapID] = x3.CauseID, 
                 X5.[ModifiedBy] = @UserID, 
                 X5.[ModifiedDate] = GETDATE(),
				 X5.LastUpdatedDate=GETDATE()
          FROM   [AVL].[TK_TRN_TICKETDETAIL] (NOLOCK) X5 
                 JOIN #DEBTUPLOADTICKETS debt 
                   ON debt.TicketId = X5.TicketID 
                 JOIN [AVL].[DEBT_MAP_CAUSECODE] (NOLOCK) X3 
                   ON debt.CauseCode = X3.CauseCode 
                      AND X3.IsDeleted = 0 
                      AND X5.ProjectID = X3.ProjectID 
          WHERE  X5.ProjectID = @ProjectID 
                 AND ( X5.[CauseCodeMapID] IS NULL 
                        OR X5.[CauseCodeMapID] = 0 
                        OR X5.[CauseCodeMapID] = '' ) 

          UPDATE X2 
          SET    X2.[ResolutionCodeID] = x3.ResolutionID, 
                 X2.[ModifiedBy] = @UserID, 
                 X2.[ModifiedDate] = GETDATE() 
          FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) X2 
                 JOIN #DEBTUPLOADTICKETS debt 
                   ON debt.TicketId = X2.TicketID 
                 JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] (NOLOCK) X3 
                   ON debt.ResolutionCode = X3.ResolutionCode 
                      AND X3.IsDeleted = 0 
                      AND X2.ProjectID = X3.ProjectID 
          WHERE  x2.ProjectID = @ProjectID 
                 AND ( X2.[ResolutionCodeID] IS NULL 
                        OR X2.[ResolutionCodeID] = 0 
                        OR X2.[ResolutionCodeID] = '' ) 

          UPDATE X5 
          SET    X5.[ResolutionCodeMapID] = x3.ResolutionID, 
                 X5.[ModifiedBy] = @UserID, 
                 X5.[ModifiedDate] = GETDATE(),
				 X5.LastUpdatedDate=GETDATE()
          FROM   [AVL].[TK_TRN_TICKETDETAIL] (NOLOCK) X5 
                 JOIN #DEBTUPLOADTICKETS debt 
                   ON debt.TicketId = X5.TicketID 
                 JOIN [AVL].[DEBT_MAP_RESOLUTIONCODE] (NOLOCK) X3 
                   ON debt.ResolutionCode = X3.ResolutionCode 
                      AND X3.IsDeleted = 0 
                      AND X5.ProjectID = X3.ProjectID 
          WHERE  X5.ProjectID = @ProjectID 
                 AND ( X5.[ResolutionCodeMapID] IS NULL 
                        OR X5.[ResolutionCodeMapID] = 0 
                        OR X5.[ResolutionCodeMapID] = '' ) 

          DECLARE @TotalTickets DECIMAL(18, 2); 
          DECLARE @ValidTDescription DECIMAL(18, 2); 
          DECLARE @ValidDebtFields DECIMAL(18, 2); 
      DECLARE @ValidOptional DECIMAL(18, 2); 
          DECLARE @Optfieldupl NVARCHAR(50); 
          DECLARE @NoiseSentorReceived NVARCHAR(500); 
         
          DECLARE @IsRegenerated BIT; 
          DECLARE @ValidTicketDescPercent DECIMAL(18, 2) 
          DECLARE @ValidTicketDebtFieldsPercent DECIMAL(18, 2) 
          DECLARE @ValidOptionalPercent DECIMAL(18, 2) 
          DECLARE @IsConditionMetForTDesc NVARCHAR(10); 
          DECLARE @OptionalField INT; 
          DECLARE @IsConditionMetForDebtFields NVARCHAR(10); 
          DECLARE @IsConditionMetForOptional NVARCHAR(10); 

       
          SET @IsRegenerated = (SELECT TOP 1 ISNULL(IsRegenerated, 0) 
                                FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE (NOLOCK) 
                                WHERE  ProjectID = @ProjectID 
                                       AND IsDeleted = 0 
                                ORDER  BY ID DESC) 

          SELECT @Optfieldupl = OptionalFieldupl, 
                 @NoiseSentorReceived = IsNoiseEliminationSentorReceived 
          FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE (NOLOCK) 
          WHERE  ProjectID = @ProjectID 
                 AND IsDeleted = 0 

          SELECT @OptionalField = OptionalFieldID 
          FROM   AVL.ML_MAP_OPTIONALPROJMAPPING (NOLOCK) 
          WHERE  ProjectId = @ProjectID 

          IF ( @IsRegenerated = 1 ) 
            BEGIN 
                SET @TotalTickets = (SELECT COUNT(IT.TicketID) 
                                     FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) IT 
                                            JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS (NOLOCK) REG
                                              ON IT.ProjectID = REG.ProjectID 
                                                 AND IT.ApplicationID = REG.ApplicationID 
                                                 AND REG.InitialLearningID = @InitialID and reg.IsDeleted=0
                                     WHERE  IT.ProjectID = @ProjectID AND IT.IsDeleted=0); 
                SET @ValidTDescription = (SELECT COUNT(IT.TicketID)
                                          FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) IT 
                                                 JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS (NOLOCK) REG
                                                   ON IT.ProjectID = REG.ProjectID 
                                                      AND IT.ApplicationID = REG.ApplicationID 
                                                      AND REG.InitialLearningID = @InitialID 
                                          WHERE  IT.ProjectID = @ProjectID 
                                                 AND TicketDescription IS NOT NULL 
                                                 AND TicketDescription <> '' 
                                                 AND IT.IsDeleted = 0 
                                                 AND REG.IsDeleted = 0); 
                SET @ValidOptional = (SELECT COUNT(IT.TicketID)
                                      FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) IT 
                                             JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS (NOLOCK) REG
                                               ON IT.ProjectID = REG.ProjectID 
                                                  AND IT.ApplicationID = REG.ApplicationID 
                                                  AND REG.InitialLearningID = @InitialID 
                                      WHERE  IT.ProjectID = @ProjectID 
                                             AND OptionalFieldProj IS NOT NULL 
                                             AND OptionalFieldProj <> '' 
                                             AND IT.IsDeleted = 0 
                                             AND REG.IsDeleted = 0); 
                SET @ValidDebtFields = (SELECT COUNT(IT.TicketID)
                                        FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) IT 
                         JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS (NOLOCK) REG
                                                 ON IT.ProjectID = REG.ProjectID 
                                                    AND IT.ApplicationID = REG.ApplicationID 
                                                    AND REG.InitialLearningID = @InitialID 
                                        WHERE  IT.ProjectID = @ProjectID 
                                               AND REG.IsDeleted = 0 
                                               AND IT.IsDeleted = 0 
                                               AND DebtClassificationId IS NOT NULL 
                                               AND AvoidableFlagID IS NOT NULL 
                                               AND CauseCodeID IS NOT NULL 
                                               AND ResolutionCodeID IS NOT NULL 
                                               AND ResidualDebtId IS NOT NULL) 
            END 
          ELSE 
            BEGIN 
                SET @TotalTickets = (SELECT COUNT(TicketID)
                                     FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) 
                                     WHERE  ProjectID = @ProjectID AND IsDeleted=0); 
                SET @ValidTDescription = (SELECT COUNT(TicketID)
                                          FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) 
                                          WHERE  ProjectID = @ProjectID  and IsDeleted=0
                                                 AND TicketDescription IS NOT NULL 
                                                 AND TicketDescription <> ''); 
                SET @ValidOptional = (SELECT COUNT(TicketID)
                                      FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) 
                                      WHERE  ProjectID = @ProjectID and IsDeleted=0
                                             AND OptionalFieldProj IS NOT NULL 
                                             AND OptionalFieldProj <> '' 
                                             AND IsDeleted = 0); 
                SET @ValidDebtFields = (SELECT COUNT(TicketID) 
                                        FROM   AVL.ML_TRN_TICKETVALIDATION (NOLOCK) 
                                        WHERE  ProjectID = @ProjectID and IsDeleted=0
                                               AND DebtClassificationId IS NOT NULL 
                                               AND AvoidableFlagID IS NOT NULL 
                                               AND CauseCodeID IS NOT NULL 
                                               AND ResolutionCodeID IS NOT NULL 
                                               AND ResidualDebtId IS NOT NULL) 
            END 

          SET @ValidTicketDescPercent = ( ( @ValidTDescription / @TotalTickets ) * 100 ); 
          SET @ValidOptionalPercent = ( ( @ValidOptional / @TotalTickets ) * 100 ); 
          SET @ValidTicketDebtFieldsPercent = ( ( @ValidDebtFields / @TotalTickets ) * 100 ); 

          IF @ValidTicketDescPercent >= 80 
            BEGIN 
                SET @IsConditionMetForTDesc = 'Y' 
            END 
          ELSE 
            BEGIN 
                SET @IsConditionMetForTDesc = 'N' 
            END 

          IF @ValidOptionalPercent >= 80 
            BEGIN 
                SET @IsConditionMetForOptional = 'Y' 
            END 
          ELSE 
            BEGIN 
                IF( @OptionalField = 4 
                     OR @OptionalField IS NULL ) 
                  BEGIN 
                      SET @IsConditionMetForOptional = 'Y' 
  END 
                ELSE 
                  BEGIN 
                      SET @IsConditionMetForOptional = 'N' 
                  END 
            END 

          IF @ValidTicketDebtFieldsPercent >= 80 
            BEGIN 
                SET @IsConditionMetForDebtFields = 'Y' 
            END 
ELSE 
            BEGIN 
                SET @IsConditionMetForDebtFields = 'N' 
            END 

          -- Block to check whether for sampling or for ticket upload/download or ML 
          IF @IsConditionMetForTDesc = 'Y' 
             AND @IsConditionMetForDebtFields = 'Y' 
            BEGIN 
                IF @IsConditionMetForOptional = 'N' 
                   AND ( @Optfieldupl IS NULL 
                          OR @Optfieldupl = 'M' ) 
                  BEGIN 
                      SELECT 'OExcel' AS CriteriaMet 
                  END 
                ELSE 
                  BEGIN 
                      IF @NoiseSentorReceived IS NULL 
                          OR @NoiseSentorReceived = 'Sent' 
                        BEGIN 
						IF(@isMultiLingual=1)
	                 	BEGIN
						  SELECT 'MultiLingual' AS CriteriaMet 
						END
						ELSE
						BEGIN
						 
                            SELECT 'Noise' AS CriteriaMet 
                        END 
						END
                      ELSE 
                        BEGIN 
                            SELECT 'ML' AS CriteriaMet 

                            IF ( @ValidTicketDescPercent > @ValidTicketDebtFieldsPercent ) 
                              BEGIN 
                                  SELECT @ValidTicketDebtFieldsPercent AS ValidTicketPercentage 

                                  SELECT @ValidTicketDescPercent AS ValidTicketPercentagefordescription
                              END 
                            ELSE 
                              BEGIN 
                                  SELECT @ValidTicketDebtFieldsPercent AS ValidTicketPercentage 

                                  SELECT @ValidTicketDescPercent AS ValidTicketPercentagefordescription
                              END 
                        END 
                  --Direct ML 
                  END 
            END 
          ELSE IF @IsConditionMetForTDesc = 'Y' 
             AND @IsConditionMetForDebtFields = 'N' 
            BEGIN 
                IF @IsConditionMetForOptional = 'N' 
                   AND ( @Optfieldupl IS NULL 
                          OR @Optfieldupl = 'M' ) 
                  BEGIN 
                      SELECT 'OExcel' AS CriteriaMet 
                  END 
                ELSE 
                  BEGIN 
                      IF @NoiseSentorReceived IS NULL 
                          OR @NoiseSentorReceived = 'Sent' 
                        BEGIN 
						IF(@isMultiLingual=1)
	                 	BEGIN
						  SELECT 'MultiLingual' AS CriteriaMet 
						END
						ELSE
						BEGIN
                            SELECT 'Noise' AS CriteriaMet 
                        END
						END 
                      ELSE 
                        BEGIN 
                            SELECT 'Sampling' AS CriteriaMet 
                        --Sampling 
                        END 
                  END 
            END 
          ELSE 
            BEGIN 
                IF @IsConditionMetForTDesc = 'N' 
                   AND @IsConditionMetForOptional = 'N' 
                  BEGIN 
                      SELECT 'TExcel' AS CriteriaMet 
                  END 
                ELSE IF @IsConditionMetForTDesc = 'N' 
                  BEGIN 
                      SELECT 'Excel' AS CriteriaMet 
                  END 
            --Download/Upload 
            END 

          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          -- Insert Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_SaveExcelUploadDetailsML] ', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
