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
-- Description : Procedure to check whether Resolution remarks in configured for the Project               
-- Test        : [ML].[CheckColumnValidation]
-- Revision    :
-- Revised By  :
-- [ML].[CheckColumnValidation] 10337
-- [ML].[CheckColumnValidation] 105188
-- =========================================================================================
CREATE PROCEDURE [ML].[CheckColumnValidation]
(
	@ID BIGINT --ProjectID
)
AS
BEGIN
  BEGIN TRY
     SET NOCOUNT ON; 
	 IF EXISTS (SELECT [name] FROM AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) ISM
		 JOIN AVL.ITSM_MAS_Columnname(NOLOCK) ICM
			ON RTRIM(UPPER(ICM.[name])) = RTRIM(UPPER(ISM.ServiceDartColumn))
		 WHERE ColID=89 AND ProjectID=@ID AND ISM.IsDeleted = 0 AND ICM.Isdeleted = 0)
		 BEGIN 
		  Select [name] as ColumnName,CAST(1 AS BIT) As ColumnStatus from  AVL.ITSM_MAS_Columnname where ColID = 89
		 END
		 ELSE
		 BEGIN
		  Select [name] as ColumnName,CAST(0 AS BIT) As ColumnStatus from  AVL.ITSM_MAS_Columnname where ColID = 89
		 END
		
   END TRY

	BEGIN CATCH
       
		DECLARE @ErrorMessage VARCHAR(MAX);
		
		-- Log the error message
		SELECT @ErrorMessage = ERROR_MESSAGE()
		              
   END CATCH

END
