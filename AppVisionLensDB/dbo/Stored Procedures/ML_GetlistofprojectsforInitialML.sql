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
--MODIFICATION HISTORY-------------
--USER        MODIFICATION DATE      REASON
--[dbo].[ML_GetlistofprojectsforInitialML] 10337,'2019-02-19','2019-08-20','471742'  
-- [dbo].[ML_GetlistofprojectsforInitialMLTest] 105188,'2019-01-02','2019-08-08','471742' 
--[dbo].[ML_GetlistofprojectsforInitialML] 105188,'2019-01-02','2019-08-08','471742'  
--MENAKA S    29-5-2019              Included MultiLingual code
-- =============================================  
CREATE PROCEDURE [dbo].[ML_GetlistofprojectsforInitialML] 
  @ProjectID BIGINT, 
  @DateFrom  DATE, 
  @DateTo    DATE, 
  @UserId    NVARCHAR(10) 
AS 
  BEGIN 
      BEGIN TRY 
          SET NOCOUNT ON; 

          DECLARE @IsSMTicket BIT 
          DECLARE @IsDARTTicket BIT 
          DECLARE @OptFieldID INT 
          DECLARE @initiallearningID INT 
		  DECLARE @CustomerID BIGINT;
		DECLARE @IsCognizant INT;
		SET @CustomerID =(SELECT CustomerID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID AND ISNULL(IsDeleted,0)=0)
		SET @IsCognizant=(SELECT ISNULL(IsCognizant,0) FROM AVL.Customer(NOLOCK)  WHERE CustomerID=@CustomerID)
          --Getting the latest initial learning id for respective projectid 
          SET @initiallearningID=(SELECT TOP 1 ID 
                                  FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                                  WHERE  ProjectID = @ProjectID 
                                  ORDER  BY id DESC) 
          --Optional field id for the project 
          SET @OptFieldID=(SELECT OptionalFieldID 
                           FROM   AVL.ML_MAP_OPTIONALPROJMAPPING 
                           WHERE  ProjectId = @ProjectID 
                                  AND IsActive = 1) 

--Get the Flag for MultiLingual enabled for the project
DECLARE @IsMultiLingualEnabled int = 0

SET @IsMultiLingualEnabled = (SELECT ISNULL(PM.IsMultilingualEnabled,0) FROM AVL.MAS_ProjectMaster PM
WHERE PM.ProjectID = @ProjectID
AND PM.IsDeleted = 0)


SELECT MLT.ID,MLT.TimeTickerID,MLT.TicketDescription,MLT.IsTicketDescriptionUpdated,MLT.ResolutionRemarks,MLT.TicketSummary,MLT.Category,MLT.Comments,
MLT.IsCategoryUpdated,MLT.IsCommentsUpdated,MLT.IsTicketSummaryUpdated,MLT.IsFlexField1Updated,
MLT.IsFlexField2Updated,MLT.IsFlexField3Updated,MLT.IsFlexField4Updated,MLT.IsTypeUpdated,T.TicketID
INTO
#tmpMultilingualTranslatedValues 
FROM [AVL].TK_TRN_Multilingual_TranslatedTicketDetails MLT
JOIN AVL.TK_TRN_TicketDetail T ON MLT.TimeTickerID= T.TimeTickerID 
AND T.ProjectID = @ProjectID
AND T.IsDeleted = 0

---------------------------------------------------------------------------------------

          IF EXISTS (SELECT 1 
                     FROM   AVL.ML_TRN_TICKETVALIDATION 
                     WHERE  PROJECTID = @ProjectID) 
            BEGIN 
                IF( (SELECT ISNULL(IsRegenerated ,0)
                     FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                     WHERE  PROJECTID = @ProjectID 
                            AND ID = @initiallearningID) = 1 ) 
                  BEGIN 
                      --If it is regenerated intial learning transaction then only tickets which belong to specfic application id 
                      --will be deleted based on projectid 
                      DELETE TV 
                      FROM   AVL.ML_TRN_TICKETVALIDATION tv 
                             JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS RAD 
                               ON tv.ApplicationID = rad.ApplicationID 
                                  AND RAD.ProjectID = tv.ProjectID 
                                  AND rad.ProjectID = @ProjectID 
                                  AND rad.IsDeleted = 0 
                  END 
                ELSE 
                  BEGIN 
                      --all tickets under that project will be deleted from ticketvalidation 
                      DELETE FROM AVL.ML_TRN_TICKETVALIDATION 
                      WHERE  PROJECTID = @ProjectID 
                  END 
            END 

		 CREATE TABLE #ML_TRN_TicketValidation(
			[ProjectID] [bigint] NOT NULL,
			[TicketID] [nvarchar](50) NULL,
			[TicketDescription] [nvarchar](max) NULL,
			[ApplicationID] [bigint] NULL,
			[DebtClassificationID] [int] NULL,
			[AvoidableFlagID] [int] NULL,
			[ResidualDebtID] [int] NULL,
			[CauseCodeID] [bigint] NULL,
			[ResolutionCodeID] [bigint] NULL,
			[CreatedBy] [nvarchar](50) NULL,
			[CreatedDate] DATETIME NULL,
			[IsDeleted] BIT NULL,
			[OptionalFieldProj] [nvarchar](max) NULL,
			TicketTypeID BIGINT NULL,
			ServiceID INT NULL
			)
          IF( (SELECT ISNULL(IsRegenerated ,0)
               FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
               WHERE  PROJECTID = @ProjectID 
                      AND ID = @initiallearningID) = 1 ) 
            BEGIN 
                --If it is regenerated intial learning transaction then only tickets which belong to specfic application id 
                --will be only inserted in ticketvalidation table based on projectid 

				INSERT INTO #ML_TRN_TicketValidation
                      SELECT 
                             TD.ProjectID,TD.TicketID, 
                             CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(MLT.TicketDescription,'') != ''  
							 THEN MLT.TicketDescription ELSE TD.TicketDescription END AS TicketDescription, 
                             TD.ApplicationID, 
                             TD.DebtClassificationMapID AS DebtClassificationID, 
                             TD.AvoidableFlag             AS [AvoidableFlagID], 
                             [ResidualDebtMapID]       AS [ResidualDebtID], 
                             [CauseCodeMapID]          AS CauseCodeID, 
                             [ResolutionCodeMapID]     AS ResolutionCodeID, 
							 @UserId, 
                             Getdate(), 
                             0,
                             CASE 
                               WHEN @OptFieldID = 1 AND  @IsMultiLingualEnabled = 1 AND ISNULL(MLT.ResolutionRemarks,'') != ''   THEN MLT.ResolutionRemarks 
							   WHEN @OptFieldID = 1 AND @IsMultiLingualEnabled = 1 AND ISNULL(MLT.ResolutionRemarks,'') = ''   THEN TD.ResolutionRemarks
							   WHEN @OptFieldID = 1 AND  @IsMultiLingualEnabled = 0 THEN  TD.ResolutionRemarks
                               WHEN @OptFieldID = 4 THEN NULL 
                             END                       AS OptionalFieldProj,
							 TD.TicketTypeMapID,TD.ServiceID 
                      FROM   [AVL].[TK_TRN_TICKETDETAIL](NOLOCK) TD 
                             JOIN AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS RAD 
                               ON RAD.ApplicationID = TD.ApplicationID 
                                  AND RAD.ProjectID = TD.ProjectID 
							 LEFT JOIN #tmpMultilingualTranslatedValues MLT
                              ON  MLT.TimeTickerID = TD.TimeTickerID
	                         AND MLT.TicketID = TD.TicketID
                      WHERE  TD.ProjectID = @ProjectID 
                             AND RAD.isdeleted = 0 
                             AND TD.IsDeleted = 0 
                             AND TD.DARTStatusID = 8 
                             AND TD.ClosedDate BETWEEN @DateFrom AND @DateTo 
						
					IF @IsCognizant = 1
					BEGIN
						DELETE  FROM #ML_TRN_TicketValidation
						WHERE ServiceID NOT IN (1,4,5,6,7,8,10) 
					END
					
					ELSE
					BEGIN
						DELETE TV  FROM #ML_TRN_TicketValidation TV
						INNER JOIN AVL.TK_MAP_TicketTypeMapping TVM
						ON TV.TicketTypeID=TVM.TicketTypeMappingID AND TVM.DebtConsidered ! ='Y'
					END	
						     
                      INSERT INTO AVL.ML_TRN_TICKETVALIDATION 
                                  (ProjectID, 
                                   TicketID, 
                                   TicketDescription, 
                                   ApplicationID, 
                                   DebtClassificationID, 
                                   AvoidableFlagID, 
                                   ResidualDebtID, 
                                   CauseCodeID, 
                                   ResolutionCodeID, 
                                   CreatedBy, 
                                   CreatedDate, 
                                   IsDeleted, 
                                   OptionalFieldProj) 
                      SELECT TD.ProjectID, 
                             TD.TicketID, 
                             TD.TicketDescription, 
                             TD.ApplicationID, 
                             TD.DebtClassificationID, 
                             TD.AvoidableFlagID, 
                             TD.[ResidualDebtID], 
                             TD.CauseCodeID, 
                             TD.ResolutionCodeID, 
                             @UserId, 
                             Getdate(), 
                             0,  OptionalFieldProj 
                      FROM   #ML_TRN_TicketValidation TD
            END 
          ELSE 
            BEGIN 
				      INSERT INTO  #ML_TRN_TicketValidation
                      SELECT TD.ProjectID,TD.TicketID, 
                             CASE WHEN @IsMultiLingualEnabled = 1 AND ISNULL(MLT.TicketDescription,'') != ''  THEN MLT.TicketDescription ELSE TD.TicketDescription END AS TicketDescription, 
                             ApplicationID, 
                             [DebtClassificationMapID] AS DebtClassificationID, 
                             AvoidableFlag             AS [AvoidableFlagID], 
                             [ResidualDebtMapID]       AS [ResidualDebtID], 
                             [CauseCodeMapID]          AS CauseCodeID, 
                             [ResolutionCodeMapID]     AS ResolutionCodeID, 
							 @UserId, 
                             Getdate(), 
                             0,
                             CASE 
                               WHEN @OptFieldID = 1 AND  @IsMultiLingualEnabled = 1 AND ISNULL(MLT.ResolutionRemarks,'') != ''   THEN MLT.ResolutionRemarks 
							   WHEN @OptFieldID = 1 AND @IsMultiLingualEnabled = 1 AND ISNULL(MLT.ResolutionRemarks,'') = ''   THEN TD.ResolutionRemarks
							   WHEN @OptFieldID = 1 AND  @IsMultiLingualEnabled = 0 THEN  TD.ResolutionRemarks
                               WHEN @OptFieldID = 4 THEN NULL 
                             END                       AS OptionalFieldProj,
							 TD.TicketTypeMapID,TD.ServiceID 
                      FROM   [AVL].[TK_TRN_TICKETDETAIL] TD(NOLOCK) 
					  LEFT JOIN #tmpMultilingualTranslatedValues MLT
                              ON  MLT.TimeTickerID = TD.TimeTickerID
	                         AND MLT.TicketID = TD.TicketID
                      WHERE  TD.ProjectID = @ProjectID 
                             AND IsDeleted = 0 
                             AND DARTStatusID = 8 
                             AND ClosedDate BETWEEN @DateFrom AND @DateTo 
                             AND IsDeleted = 0 
						
					IF @IsCognizant = 1
					BEGIN
						DELETE  FROM #ML_TRN_TicketValidation
						WHERE ServiceID NOT IN (1,4,5,6,7,8,10) 
					END
					
					ELSE
					BEGIN
						DELETE TV  FROM #ML_TRN_TicketValidation TV
						INNER JOIN AVL.TK_MAP_TicketTypeMapping TVM
						ON TV.TicketTypeID=TVM.TicketTypeMappingID AND TVM.DebtConsidered ! ='Y'
					END	    
                      INSERT INTO AVL.ML_TRN_TICKETVALIDATION 
                                  (ProjectID, 
                                   TicketID, 
                                   TicketDescription, 
                                   ApplicationID, 
                                   DebtClassificationID, 
                                   AvoidableFlagID, 
                                   ResidualDebtID, 
                                   CauseCodeID, 
                                   ResolutionCodeID, 
                                   CreatedBy, 
                                   CreatedDate, 
                                   IsDeleted, 
                                   OptionalFieldProj) 
                      SELECT TD.ProjectID, 
                             TD.TicketID, 
                             TicketDescription, 
                             ApplicationID, 
                             DebtClassificationID, 
                             AvoidableFlagID, 
                             [ResidualDebtID], 
                             CauseCodeID, 
                             ResolutionCodeID, 
                             @UserId, 
                             Getdate(), 
                             0,OptionalFieldProj 
                      FROM   #ML_TRN_TicketValidation TD




            END 

						SELECT @OptFieldID AS OptionalFieldId, TD.ProjectID, 
                             TD.TicketID, 
                             TicketDescription, 
                             ApplicationID, 
                             DebtClassificationID, 
                             AvoidableFlagID, 
                             [ResidualDebtID], 
                             CauseCodeID, 
                             ResolutionCodeID, 
                             OptionalFieldProj 
                      FROM   #ML_TRN_TicketValidation TD

      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_GetlistofprojectsforInitialML]  ', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
