/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


--[AVL].[ML_InsertValidTicketsInfra] 44639,'2019/02/22','2019/08/22','471742'
-- ============================================= 
-- Author:    471742 
-- Create date: 2-Aug-2019 
-- Description:   SP for Initial Learning 

--[AVL].[ML_InsertValidTicketsInfra]   44639,'2019-02-19','2019-08-20','471742'

--[AVL].[ML_InsertValidTicketsMLInfra]   10337,'2019-02-05','2019-08-04','471742'
CREATE PROCEDURE [AVL].[ML_InsertValidTicketsInfra] 
  @ProjectID BIGINT, 
  @DateFrom  DATE, 
  @DateTo    DATE, 
  @UserId    NVARCHAR(50) 
AS 
  BEGIN 
      BEGIN TRY 
          SET NOCOUNT ON; 
	DECLARE @OptFieldID INT 
	DECLARE @initiallearningID INT 
	DECLARE @IsMultiLingualEnabled int = 0
	DECLARE @CustomerID BIGINT;
	DECLARE @IsCognizant INT;
	SET @CustomerID =(SELECT CustomerID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID AND ISNULL(IsDeleted,0)=0)
	SET @IsCognizant=(SELECT ISNULL(IsCognizant,0) FROM AVL.Customer(NOLOCK)  WHERE CustomerID=@CustomerID)
	--Getting the latest initial learning id for respective projectid 
	SET @initiallearningID=(SELECT TOP 1 ID 
							FROM   AVL.ML_PRJ_InitialLearningStateInfra(NOLOCK) 
							WHERE  ProjectID = @ProjectID 
							ORDER  BY id DESC) 
	--Optional field id for the project 
	SET @OptFieldID=(SELECT OptionalFieldID 
					FROM   AVL.ML_MAP_OptionalProjMappingInfra(NOLOCK) 
					WHERE  ProjectId = @ProjectID 
					AND IsDeleted = 0) 
	SET @IsMultiLingualEnabled = (SELECT ISNULL(PM.IsMultilingualEnabled,0) FROM AVL.MAS_ProjectMaster(NOLOCK) PM
									WHERE PM.ProjectID = @ProjectID	AND PM.IsDeleted = 0)
		SELECT MLT.ID,MLT.TimeTickerID,MLT.TicketDescription,MLT.IsTicketDescriptionUpdated,MLT.ResolutionRemarks,T.TicketID
		INTO #tmpMultilingualTranslatedValues 
		FROM [AVL].TK_TRN_Multilingual_TranslatedInfraTicketDetails(NOLOCK) MLT
		INNER JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) T ON MLT.TimeTickerID= T.TimeTickerID 
		AND T.ProjectID = @ProjectID AND T.IsDeleted = 0

          IF EXISTS (SELECT 1 FROM AVL.ML_TRN_TicketValidationInfra WHERE  PROJECTID = @ProjectID AND IsDeleted=0) 
            BEGIN 
                IF((SELECT ISNULL(IsRegenerated ,0) FROM AVL.ML_PRJ_InitialLearningStateInfra 
                     WHERE  PROJECTID = @ProjectID AND ID = @initiallearningID) = 1 ) 
                  BEGIN 
                      --If it is regenerated intial learning transaction then only tickets which belong to specfic application id 
                      DELETE TV  FROM   AVL.ML_TRN_TicketValidationInfra TV 
                            INNER JOIN AVL.ML_TRN_RegeneratedTowerDetails RAD 
							ON TV.TowerID = RAD.TowerID AND RAD.ProjectID = TV.ProjectID
							 WHERE TV.ProjectID = @ProjectID AND RAD.IsDeleted = 0 
                  END 
                ELSE 
                  BEGIN

                      --all tickets under that project will be deleted from ticketvalidation 
                      DELETE FROM AVL.ML_TRN_TicketValidationInfra WHERE  PROJECTID = @ProjectID 
                  END 
            END 
			CREATE TABLE #ML_TRN_TicketValidationInfra(
			[ProjectID] [bigint] NOT NULL,
			[TicketID] [nvarchar](50) NULL,
			[TicketDescription] [nvarchar](max) NULL,
			[TowerID] [bigint] NULL,
			[DebtClassificationID] [int] NULL,
			[AvoidableFlagID] [int] NULL,
			[ResidualDebtID] [int] NULL,
			[CauseCodeID] [bigint] NULL,
			[ResolutionCodeID] [bigint] NULL,
			[CreatedBy] [nvarchar](50) NULL,
			[CreatedDate] DATETIME NULL,
			[IsDeleted] BIT NULL,
			[OptionalFieldProj] [nvarchar](max) NULL,
			TicketTypeID BIGINT NULL
			)
          IF( (SELECT ISNULL(IsRegenerated ,0)
               FROM AVL.ML_PRJ_InitialLearningStateInfra WHERE  PROJECTID = @ProjectID AND ID = @initiallearningID) = 1 ) 
            BEGIN 
                --If it is regenerated intial learning transaction then only tickets which belong to specfic application id 
                --will be only inserted in ticketvalidation table based on projectid     
                      INSERT INTO #ML_TRN_TicketValidationInfra
                      SELECT  TD.ProjectID,TD.TicketID, 
                             CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(MLT.TicketDescription,'') != '' 
							  THEN MLT.TicketDescription ELSE TD.TicketDescription END AS TicketDescription, 
                             TD.TowerID, TD.[DebtClassificationMapID] AS DebtClassificationID, 
                             TD.AvoidableFlag,TD.[ResidualDebtMapID]    AS [ResidualDebtID], 
                             TD.[CauseCodeMapID]       AS CauseCodeID,TD.[ResolutionCodeMapID]  AS ResolutionCodeID, 
                             @UserId,GETDATE(),0, 
                             CASE 
                               WHEN @OptFieldID = 1 AND  @IsMultiLingualEnabled = 1 AND ISNULL(MLT.ResolutionRemarks,'') != ''   THEN MLT.ResolutionRemarks 
							   WHEN (@OptFieldID = 1 AND @IsMultiLingualEnabled = 1 AND ISNULL(MLT.ResolutionRemarks,'') = '')
							   OR (@OptFieldID = 1 AND  @IsMultiLingualEnabled = 0)  THEN TD.ResolutionRemarks
                               WHEN @OptFieldID = 4 THEN NULL 
                             END                          AS OptionalFieldProj,TD.TicketTypeMapID-- ,@OptFieldID
                      FROM   [AVL].TK_TRN_InfraTicketDetail(NOLOCK) TD 
                            LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails RAD 
                               ON RAD.ProjectID = TD.ProjectID AND RAD.TowerID = TD.TowerID   
						     LEFT JOIN #tmpMultilingualTranslatedValues MLT
                              ON  MLT.TimeTickerID = TD.TimeTickerID AND MLT.TicketID = TD.TicketID
                             JOIN AVL.InfraTowerProjectMapping IPM
							 ON IPM.TowerID=TD.TowerID AND IPM.ProjectID=TD.ProjectID AND IPM.IsDeleted=0 AND IPM.IsEnabled=1
                      WHERE  TD.ProjectID = @ProjectID 
                             AND RAD.IsDeleted = 0  AND TD.IsDeleted = 0 
                             AND TD.DARTStatusID = 8 
                             AND TD.ClosedDate BETWEEN @DateFrom AND @DateTo  
					IF @IsCognizant = 0
					BEGIN
						DELETE TV  FROM #ML_TRN_TicketValidationInfra TV
						INNER JOIN AVL.TK_MAP_TicketTypeMapping TVM
						ON TV.TicketTypeID=TVM.TicketTypeMappingID AND TVM.DebtConsidered ! ='Y'
					END

					SELECT TD.ProjectID,TD.TicketID, TD.TicketDescription, 
                             TD.TowerID,TD.DebtClassificationID,TD.AvoidableFlagID, TD.[ResidualDebtID], 
                              TD.CauseCodeID, TD.ResolutionCodeID, 
                             @UserId,GETDATE(),0 AS OptionalFieldId, OptionalFieldProj 
                      FROM   #ML_TRN_TicketValidationInfra TD 
                            
				END 
          ELSE 
            BEGIN 
                      INSERT INTO #ML_TRN_TicketValidationInfra
                      SELECT TD.ProjectID, 
                             TD.TicketID, 
                             CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(MLT.TicketDescription,'') != ''  THEN MLT.TicketDescription ELSE TD.TicketDescription END AS TicketDescription, 
                             TD.TowerID AS TowerID,[DebtClassificationMapID] AS DebtClassificationID, 
                             AvoidableFlag,[ResidualDebtMapID]       AS [ResidualDebtID], 
                             [CauseCodeMapID]          AS CauseCodeID, 
                             [ResolutionCodeMapID]     AS ResolutionCodeID, 
                             @UserId,GETDATE(), 0, 
                             CASE 
                               WHEN @OptFieldID = 1 AND  @IsMultiLingualEnabled = 1 AND ISNULL(MLT.ResolutionRemarks,'') != ''   THEN MLT.ResolutionRemarks 
							   WHEN @OptFieldID = 1 AND @IsMultiLingualEnabled = 1 AND ISNULL(MLT.ResolutionRemarks,'') = ''   THEN TD.ResolutionRemarks
							   WHEN @OptFieldID = 1 AND  @IsMultiLingualEnabled = 0 THEN  TD.ResolutionRemarks
                               WHEN @OptFieldID = 4 THEN NULL 
                             END                       AS OptionalFieldProj ,TD.TicketTypeMapID
                      FROM   [AVL].TK_TRN_InfraTicketDetail(NOLOCK)  TD
					   LEFT JOIN #tmpMultilingualTranslatedValues MLT
                              ON  MLT.TimeTickerID = TD.TimeTickerID
	                         AND MLT.TicketID = TD.TicketID
                        JOIN AVL.InfraTowerProjectMapping IPM
					         ON IPM.ProjectID=TD.ProjectID
							 AND IPM.TowerID=TD.TowerID
							 AND IPM.IsDeleted=0
							 AND IPM.IsEnabled=1
                      WHERE  TD.ProjectID = @ProjectID 
                             AND TD.IsDeleted = 0  AND TD.DARTStatusID = 8 
                             AND TD.ClosedDate BETWEEN @DateFrom AND @DateTo 

						IF @IsCognizant = 0
					BEGIN

						DELETE TV  FROM #ML_TRN_TicketValidationInfra TV
						INNER JOIN AVL.TK_MAP_TicketTypeMapping TVM
						ON TV.TicketTypeID=TVM.TicketTypeMappingID AND TVM.DebtConsidered ! ='Y'
					END

						SELECT TD.ProjectID, 
                             TD.TicketID,  TD.TicketDescription, 
                             TD.TowerID,TD.DebtClassificationID,TD.AvoidableFlagID, TD.[ResidualDebtID], TD.CauseCodeID, 
                             TD.ResolutionCodeID, 
                             @UserId,GETDATE(), 0 AS OptionalFieldId,OptionalFieldProj 
                      FROM   #ML_TRN_TicketValidationInfra(NOLOCK)  TD

            END 
			INSERT INTO [AVL].[ML_TRN_TicketValidationInfra]
			([ProjectID],[TicketID],[TicketDescription],[TowerID],[DebtClassificationID],
			[AvoidableFlagID],[ResidualDebtID],[CauseCodeID],[ResolutionCodeID],
			[CreatedBy],[CreatedDate],[IsDeleted],[OptionalFieldProj]) 
			SELECT [ProjectID],[TicketID],[TicketDescription],[TowerID],[DebtClassificationID],
			[AvoidableFlagID],[ResidualDebtID],[CauseCodeID],[ResolutionCodeID],
			[CreatedBy],[CreatedDate],[IsDeleted],[OptionalFieldProj]
			FROM #ML_TRN_TicketValidationInfra

	 DROP TABLE #tmpMultilingualTranslatedValues
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = ERROR_MESSAGE() 
          --INSERT Error     
          EXEC AVL_INSERTERROR '[AVL].[ML_InsertValidTicketsInfra]', @ErrorMessage, @ProjectID, 0 
      END CATCH 
  END
