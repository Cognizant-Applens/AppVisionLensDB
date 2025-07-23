/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetITSMAutoMappingCollectionData]
 @SupportTypeID INT null   
AS
 BEGIN
 SET NOCOUNT ON
 BEGIN TRY
   
 
  SELECT ITSMMAS_SCM.ColumnMatchingId, REPLACE(REPLACE(ITSMMAS_CM.ColumnName,'\',' or '),'/',' or ') as ITSMColumnName, ITSMMAS_SCM.ColumnMappingId,
  ITSMMAS_SCM.PriorityMappingId, ITSMMAS_SCM.MatchingKeyword, ITSMMAS_SCM.IsDeleted
       
    FROM        
    [PP].[ITSM_MAS_Standard_Column_Matching] ITSMMAS_SCM 
	--inner join [PP].[ITSM_MAS_Priority_ColumnMapping] ITSMMAS_PCM ON
	-- ITSMMAS_PCM.PriorityMappingId=ITSMMAS_SCM.PriorityMappingId
	 INNER JOIN  MAS.ITSM_Columnname  ITSMMAS_CM ON ITSMMAS_CM.ColumnID=ITSMMAS_SCM.ColumnMappingId
	 where ITSMMAS_SCM.IsDeleted=0 and ITSMMAS_CM.SupportTypeID=@SupportTypeID
  

 END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[PP].[GetAutoMappingCollectionData]', @ErrorMessage, 0 ,0
  END CATCH

END
