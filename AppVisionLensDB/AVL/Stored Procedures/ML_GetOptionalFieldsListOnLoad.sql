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
-- Create date:      22 June 2018 
-- Description:      To get optional fields for the project based on column mapping 
-- Test:             EXEC [AVL].[ML_GetOptionalFieldsListOnLoad]  9352 
-- ============================================================================ 
CREATE PROC [AVL].[ML_GetOptionalFieldsListOnLoad] (@ProjectID BIGINT) 
AS 
  BEGIN 
      BEGIN TRY 
          SELECT DISTINCT OP.ID, 
                          OP.OptionalFields 
          FROM   AVL.ITSM_PRJ_SSISCOLUMNMAPPING (NOLOCK) SSIS 
                 JOIN AVL.ML_MAS_OPTIONALFIELDS (NOLOCK) OP 
                   ON SSIS.ServiceDartColumn = OP.OptionalFields 
          WHERE  SSIS.ProjectID = @ProjectID  and SSIS.IsDeleted=0  and op.IsDeleted=0
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          -- Insert Error     
          EXEC AVL_INSERTERROR 
            ' [AVL].[ML_GetOptionalFieldsListOnLoad]', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
