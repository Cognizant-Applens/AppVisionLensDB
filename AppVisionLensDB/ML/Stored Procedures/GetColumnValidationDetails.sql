-- =========================================================================================
-- Author      : Shobana
-- Create date : 3 Dec 2019
-- Description : Procedure to check whether Resolution remarks in configured for the Project               
-- Test        :[ML].[GetColumnValidationDetails]
-- Revision    :
-- Revised By  :
-- [ML].[GetColumnValidationDetails] 10337
-- [ML].[GetColumnValidationDetails] 105188
-- =========================================================================================
CREATE PROCEDURE [ML].[GetColumnValidationDetails]
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
		  Select [name] as ColumnName,CAST(1 AS BIT) As ColumnStatus from  AVL.ITSM_MAS_Columnname(NOLOCK) where ColID = 89
		 END
		 ELSE
		 BEGIN
		  Select [name] as ColumnName,CAST(0 AS BIT) As ColumnStatus from  AVL.ITSM_MAS_Columnname(NOLOCK) where ColID = 89
		 END
   SET NOCOUNT OFF	
   END TRY

	BEGIN CATCH
       
		DECLARE @ErrorMessage VARCHAR(MAX);
		
		-- Log the error message
		SELECT @ErrorMessage = ERROR_MESSAGE()
		              
   END CATCH

END
