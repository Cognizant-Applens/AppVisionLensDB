/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/****** Object:  StoredProcedure [dbo].[ML_GetNoiseEliminationData]    Script Date: 3/4/2019 10:29:11 AM ******/


-- ============================================= 
-- Author:    627384 
-- Create date: 11-FEB-2019 
-- Description:   SP for Initial Learning 

-- =============================================  
CREATE PROCEDURE [dbo].[ML_GetNoiseEliminationData] (@Selection VARCHAR(200), 
                                                    @Filter    INT, 
                                                    @ProjectID INT) 
AS 
  BEGIN 
      BEGIN TRY 
	  DECLARE @Top VARCHAR(50)='Top'
	  DECLARE @Bottom VARCHAR(50)='Bottom'
          IF( @Filter >= 1 ) 
            BEGIN 
                --@Filter-count of data required 
                IF( @Selection = @Top ) 
                  BEGIN 
                      SELECT TOP (SELECT @Filter) ID,ProjectID,OptionalFieldNoiseWord,Frequency,IsActive,CreatedDate,CreatedBy
                      FROM   AVL.ML_OptionalFieldNoiseWords_Dump 
                      WHERE  ProjectID  = @ProjectID 

                      SELECT TOP (SELECT @Filter) ID,ProjectID,TicketDescNoiseWord,Frequency,IsActive,CreatedDate,CreatedBy 
                      FROM   AVL.ML_TicketDescNoiseWords_Dump 
                      WHERE  ProjectID  = @ProjectID 

                      SELECT COUNT(*) AS totalopt 
                      FROM   AVL.ML_OptionalFieldNoiseWords_Dump 
                      WHERE  ProjectID = @ProjectID 

                      SELECT COUNT(*) AS totalDesc 
                      FROM   AVL.ML_TicketDescNoiseWords_Dump 
                      WHERE  ProjectID = @ProjectID 
                  END 
                ELSE 
                  BEGIN 
                      IF( @Selection = @Bottom ) 
                        BEGIN 
                            SELECT TOP (SELECT @Filter) ID,ProjectID,OptionalFieldNoiseWord,Frequency,IsActive,CreatedDate,CreatedBy 
                            FROM   AVL.ML_OptionalFieldNoiseWords_Dump 
                            WHERE  ProjectID = @ProjectID 
                            ORDER  BY ID DESC 

                            SELECT TOP (SELECT @Filter) ID,ProjectID,TicketDescNoiseWord,Frequency,IsActive,CreatedDate,CreatedBy 
                            FROM   AVL.ML_TicketDescNoiseWords_Dump 
                            WHERE  ProjectID = @ProjectID 
                            ORDER  BY ID DESC 

                            SELECT COUNT(*) AS totalopt 
                            FROM   AVL.ML_OptionalFieldNoiseWords_Dump 
                            WHERE  ProjectID = @ProjectID 

                            SELECT COUNT(*) AS totalDesc 
                            FROM   AVL.ML_TicketDescNoiseWords_Dump 
                            WHERE  ProjectID = @ProjectID 
                        END 
                  END 
            END 

          IF( @Filter = 0 ) 
            BEGIN 
                IF( @Selection = @Top ) 
                  BEGIN 
                      SELECT ID,ProjectID,OptionalFieldNoiseWord,Frequency,IsActive,CreatedDate,CreatedBy 
                      FROM   AVL.ML_OptionalFieldNoiseWords_Dump 
                      WHERE  ProjectID = @ProjectID 

                      SELECT ID,ProjectID,TicketDescNoiseWord,Frequency,IsActive,CreatedDate,CreatedBy
                      FROM   AVL.ML_TicketDescNoiseWords_Dump 
                      WHERE  ProjectID = @ProjectID 

                      SELECT COUNT(*) AS totalopt 
                      FROM   AVL.ML_OptionalFieldNoiseWords_Dump 
                      WHERE  ProjectID = @ProjectID 

                      SELECT COUNT(*) AS totalDesc 
                      FROM   AVL.ML_TicketDescNoiseWords_Dump 
                      WHERE  ProjectID = @ProjectID 
                  END 
                ELSE 
                  BEGIN 
                      IF( @Selection = @Bottom ) 
                        BEGIN 
                            SELECT ID,ProjectID,OptionalFieldNoiseWord,Frequency,IsActive,CreatedDate,CreatedBy 
                            FROM   AVL.ML_OptionalFieldNoiseWords_Dump 
                            WHERE  ProjectID = @ProjectID 
                            ORDER  BY id DESC 

                            SELECT ID,ProjectID,TicketDescNoiseWord,Frequency,IsActive,CreatedDate,CreatedBy
                            FROM   AVL.ML_TicketDescNoiseWords_Dump 
                            WHERE  ProjectID = @ProjectID 
                            ORDER  BY id DESC 

                            SELECT COUNT(*) AS totalopt 
                            FROM   AVL.ML_OptionalFieldNoiseWords_Dump 
                            WHERE  ProjectID = @ProjectID 

                            SELECT COUNT(*) AS totalDesc 
                            FROM   AVL.ML_TicketDescNoiseWords_Dump 
                            WHERE  ProjectID  = @ProjectID 
                        END 
                  END 
            END 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          DECLARE @ErrorSeverity INT; 
          DECLARE @ErrorState INT; 

          SELECT @ErrorMessage = Error_message() 

          SELECT @ErrorSeverity = Error_severity() 

          SELECT @ErrorState = Error_state() 

          SELECT @ErrorMessage = Error_message() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC Avl_inserterror 
            '[dbo].[ML_GetNoiseEliminationData]', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
