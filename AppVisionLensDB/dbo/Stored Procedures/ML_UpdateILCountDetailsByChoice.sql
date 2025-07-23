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
-- Create date: 18-FEB-2019 
-- Description:   SP for Initial Learning 
-- [dbo].[ML_UpdateILCountDetailsByChoice] 202,2 
-- =============================================  
CREATE PROC [dbo].[ML_UpdateILCountDetailsByChoice] --276,1 
  @ProjectID        BIGINT, 
  @TicketConsidered BIGINT, 
  @TicketAnalysed   BIGINT, 
  @SamplingCount    BIGINT, 
  @PatternCount     BIGINT, 
  @ApprovedCount    BIGINT, 
  @MuteCount        BIGINT, 
  @Choice           NVARCHAR(MAX), 
  @userid           NVARCHAR(MAX) 
AS 
  BEGIN 
      BEGIN TRY 
          DECLARE @InitialLearningID BIGINT 
          DECLARE @IsRegenerted BIT 

          --get latest id for initial learning for the projectid 
          SET @InitialLearningID=(SELECT TOP 1 ID 
                                  FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE 
                                  WHERE  ProjectID = @ProjectID 
                                         AND IsDeleted = 0 
                                  ORDER  BY ID DESC) 

          --Choice=1:when sampling grid is loaded 
          --choice=2: when ml patterns grid is loaded before signoff 
          --choice=3:when ml patterns grid is loaded after signoff  
          IF( @Choice = 1 ) 
            BEGIN 
                IF( (SELECT Count(ID) 
                     FROM   AVL.ML_ILCOUNTDETAILS 
                     WHERE  projectid = @ProjectID 
                            AND initiallearningid = @InitialLearningID) > 0 ) 
                  BEGIN 
                      UPDATE AVL.ML_ILCOUNTDETAILS 
                      SET    [TASamplingCount] = @TicketAnalysed, 
                             [TCSamplingCount] = @TicketConsidered, 
                             [SamplingCount] = @SamplingCount, 
                             modifiedby = @userid, 
                             modifieddate = GETDATE() 
                      WHERE  projectid = @projectid 
                             AND InitialLearningID = @InitialLearningID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE AVL.ML_ILCOUNTDETAILS 
                      SET    isdeleted = 1 
                      WHERE  projectid = @projectid 

                      INSERT INTO AVL.ML_ILCOUNTDETAILS 
                                  ([InitialLearningID], 
                                   [ProjectID], 
                                   [TASamplingCount], 
                                   [TCSamplingCount], 
                                   [SamplingCount], 
                                   createdby, 
                                   createddate, 
                                   isdeleted) 
                      VALUES      (@InitialLearningID, 
                                   @projectid, 
                                   @TicketAnalysed, 
                                   @TicketConsidered, 
                                   @SamplingCount, 
                                   @userid, 
                                   GETDATE(), 
                                   0) 
                  END 
            END 
          ELSE IF( @Choice = 2 ) 
            BEGIN 
                IF( (SELECT Count(ID) 
                     FROM   AVL.ML_ILCOUNTDETAILS 
                     WHERE  projectid = @ProjectID 
                            AND initiallearningid = @InitialLearningID) > 0 ) 
                  BEGIN 
                      UPDATE AVL.ML_ILCOUNTDETAILS 
                      SET    [TABeforeML] = @TicketAnalysed, 
                             [TCBeforeML] = @TicketConsidered, 
                             [PatternCount] = @patterncount, 
                             modifiedby = @userid, 
                             modifieddate = GETDATE() 
                      WHERE  projectid = @projectid 
                             AND InitialLearningID = @InitialLearningID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE AVL.ML_ILCOUNTDETAILS 
                      SET    isdeleted = 1 
                      WHERE  projectid = @projectid 

                      INSERT INTO AVL.ML_ILCOUNTDETAILS 
                                  ([InitialLearningID], 
                                   [ProjectID], 
                                   [TABeforeML], 
                                   [TCBeforeML], 
                                   [PatternCount], 
                                   createdby, 
                                   createddate, 
                                   isdeleted) 
                      VALUES      (@InitialLearningID, 
                                   @projectid, 
                                   @TicketAnalysed, 
                                   @TicketConsidered, 
                                   @patterncount, 
                                   @userid, 
                                   GETDATE(), 
                                   0) 
                  END 
            END 
          ELSE IF( @Choice = 3 ) 
            BEGIN 
                IF( (SELECT Count(ID) 
                     FROM   AVL.ML_ILCOUNTDETAILS 
                     WHERE  projectid = @ProjectID 
                            AND initiallearningid = @InitialLearningID) > 0 ) 
                  BEGIN 
                      UPDATE AVL.ML_ILCOUNTDETAILS 
                      SET    [TAAfterML] = @TicketAnalysed, 
                             [TCAfterML] = @TicketConsidered, 
                             [ApprovedCount] = @approvedcount, 
                             [MuteCount] = @mutecount, 
                             modifiedby = @userid, 
                             modifieddate = GETDATE() 
                      WHERE  projectid = @projectid 
                             AND InitialLearningID = @InitialLearningID 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE AVL.ML_ILCOUNTDETAILS 
                      SET    isdeleted = 1 
                      WHERE  projectid = @projectid 

                      INSERT INTO AVL.ML_ILCOUNTDETAILS 
                                  ([InitialLearningID], 
                                   [ProjectID], 
                                   [TAAfterML], 
                                   [TCAfterML], 
                                   [ApprovedCount], 
                                   [MuteCount], 
                                   createdby, 
                                   createddate, 
                                   isdeleted) 
                      VALUES      (@InitialLearningID, 
                                   @projectid, 
                                   @TicketAnalysed, 
                                   @TicketConsidered, 
                                   @approvedcount, 
                                   @mutecount, 
                                   @userid, 
                                   GETDATE(), 
                                   0) 
                  END 
            END 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage1 VARCHAR(MAX); 

          SELECT @ErrorMessage1 = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_UpdateILCountDetailsByChoice] ', 
            @ErrorMessage1, 
            @ProjectID, 
            0 
      END CATCH 
  END
