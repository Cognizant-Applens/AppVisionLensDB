/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[CheckColumnValidation]
(
	@ID BIGINT, --ProjectID
	@ChosenField INT
)
AS
BEGIN
  BEGIN TRY
     SET NOCOUNT ON; 
	 IF(@ChosenField = 11)
	 BEGIN
	  IF EXISTS (SELECT [name] FROM AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) ISM
		 JOIN AVL.ITSM_MAS_Columnname(NOLOCK) ICM
			ON RTRIM(UPPER(ICM.[name])) = RTRIM(UPPER(ISM.ServiceDartColumn))
		 WHERE ColID=12 AND ProjectID=@ID AND ISM.IsDeleted = 0 AND ICM.Isdeleted = 0)
		 BEGIN 
		  Select 1 As ColumnStatus from  AVL.ITSM_MAS_Columnname where ColID = 12
		 END
		 ELSE
		 BEGIN
		  Select 0 As ColumnStatus from  AVL.ITSM_MAS_Columnname where ColID = 12
	 END
	 END
	 IF(@ChosenField = 12)
	 BEGIN
	 IF EXISTS (SELECT [name] FROM AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) ISM
		 JOIN AVL.ITSM_MAS_Columnname(NOLOCK) ICM
			ON RTRIM(UPPER(ICM.[name])) = RTRIM(UPPER(ISM.ServiceDartColumn))
		 WHERE ColID=89 AND ProjectID=@ID AND ISM.IsDeleted = 0 AND ICM.Isdeleted = 0)
		 BEGIN 
		  Select 1 As ColumnStatus from  AVL.ITSM_MAS_Columnname where ColID = 89
		 END
		 ELSE
		 BEGIN
		  Select 0 As ColumnStatus from  AVL.ITSM_MAS_Columnname where ColID = 89
	END
	END
	 IF (@ChosenField = 13)
	BEGIN
	IF EXISTS (SELECT [name] FROM AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) ISM
		 JOIN AVL.ITSM_MAS_Columnname(NOLOCK) ICM
			ON RTRIM(UPPER(ICM.[name])) = RTRIM(UPPER(ISM.ServiceDartColumn))
		 WHERE ColID=44 AND ProjectID=@ID AND ISM.IsDeleted = 0 AND ICM.Isdeleted = 0)
		 BEGIN 
		  Select 1 As ColumnStatus from  AVL.ITSM_MAS_Columnname where ColID = 44
		 END
		 ELSE
		 BEGIN
		  Select 0  As ColumnStatus from  AVL.ITSM_MAS_Columnname where ColID = 44
	END
	END
	 IF (@ChosenField = 14)
	BEGIN
	IF EXISTS (SELECT [name] FROM AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) ISM
		 JOIN AVL.ITSM_MAS_Columnname(NOLOCK) ICM
			ON RTRIM(UPPER(ICM.[name])) = RTRIM(UPPER(ISM.ServiceDartColumn))
		 WHERE ColID=52 AND ProjectID=@ID AND ISM.IsDeleted = 0 AND ICM.Isdeleted = 0)
		 BEGIN 
		  Select 1  As ColumnStatus from  AVL.ITSM_MAS_Columnname where ColID = 52
		 END
		 ELSE
		 BEGIN
		  Select 0  As ColumnStatus from  AVL.ITSM_MAS_Columnname where ColID = 52
	END
	END
		 
		
   END TRY

	BEGIN CATCH
       
		DECLARE @ErrorMessage VARCHAR(MAX);
		
		-- Log the error message
		SELECT @ErrorMessage = ERROR_MESSAGE()
		              
   END CATCH

END
