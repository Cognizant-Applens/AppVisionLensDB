/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : Shobana
-- Create date : 3 Dec 2019
-- Description : Procedure to Get ML Enabled Details               
-- Test        : [ML].[GetProjectMLDetails] 10337
-- Revision    : 17 Jul 2020
-- Revised By  : Boopathi
-- =========================================================================================
CREATE PROCEDURE [ML].[GetProjectMLDetails]
(
	@ID BIGINT --ProjectID
)
AS
BEGIN
  BEGIN TRY
     SET NOCOUNT ON; 		
		SELECT 
		CASE WHEN (UPPER(ISNULL(IsAutoClassified,'N'))='Y') 
			 THEN CAST( 1 AS BIT) ELSE CAST(0 AS BIT) END AS IsMLEnabled,		
		CASE WHEN (UPPER(ISNULL(IsMLSignOff,'0'))='1') 
		     THEN CAST( 1 AS BIT) ELSE CAST(0 AS BIT) END AS IsMLSignOff,
		MLSignOffDate,
		CASE WHEN (UPPER(ISNULL(IsAutoClassifiedInfra,'N'))='Y') 
			 THEN CAST( 1 AS BIT) ELSE CAST(0 AS BIT) END AS IsMLEnabledInfra,		
		CASE WHEN (UPPER(ISNULL(IsMLSignOffInfra,'0'))='1') 
		     THEN CAST( 1 AS BIT) ELSE CAST(0 AS BIT) END AS IsMLSignOffInfra,
		MLSignOffDateInfra
		FROM AVL.MAS_ProjectDebtDetails(NOLOCK) 
		WHERE ProjectId = @ID   
  
   END TRY
	BEGIN CATCH
       DECLARE @ErrorMessage1 VARCHAR(MAX); 

          SELECT @ErrorMessage1 = ERROR_MESSAGE() 

          --INSERT Error      
          EXEC AVL_INSERTERROR 
            '[ML].[GetProjectMLDetails]', 
            @ErrorMessage1, 
            @ID, 
            0 
		              
    END CATCH

END
