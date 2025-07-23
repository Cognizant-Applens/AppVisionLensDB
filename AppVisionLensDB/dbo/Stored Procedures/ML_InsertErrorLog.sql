/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/****** Object:  StoredProcedure [dbo].[ML_InsertErrorLog]    Script Date: 3/4/2019 4:58:22 PM ******/ 

-- ============================================= 
-- Author:    627384 
-- Create date: 11-FEB-2019 
-- Description:   SP for Inserting error log

-- =============================================  
CREATE PROCEDURE [dbo].[ML_InsertErrorLog] @ProjectID    INT=NULL, 
                                      @step         VARCHAR(MAX)=NULL, 
                                      @ErrorMessage VARCHAR(MAX)=NULL, 
                                      @UserID       VARCHAR(MAX)=NULL 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

          INSERT INTO AVL.ML_TRN_ErrorLog 
          VALUES     (@ProjectID, 
                      @step, 
                      @ErrorMessage, 
                      GETDATE(), 
                      @UserID) 

          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage1 VARCHAR(MAX); 

          SELECT @ErrorMessage1 = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            'AV[dbo].[ML_InsertErrorLog] ', 
            @ErrorMessage1, 
            @ProjectID, 
            0 
      END CATCH 
  END
