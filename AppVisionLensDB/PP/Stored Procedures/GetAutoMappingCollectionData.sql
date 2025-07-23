/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetAutoMappingCollectionData]
 
AS
 BEGIN
 SET NOCOUNT ON
 BEGIN TRY
   
 
  SELECT ALM_MAS_SCM.ColumnMatchingId, REPLACE(REPLACE(ALM_MAS_CM.ALMColumnName,'\',' or '),'/',' or ') as ALMColumnName, ALM_MAS_SCM.ColumnMappingId,
  ALM_MAS_SCM.PriorityMappingId, ALM_MAS_SCM.MatchingKeyword, ALM_MAS_SCM.IsDeleted
       
    FROM        
    [PP].[ALM_MAS_Standard_Column_Matching] ALM_MAS_SCM inner join [PP].[ALM_MAS_Priority_ColumnMapping] ALM_MAS_PCM ON
	 ALM_MAS_PCM.PriorityMappingId=ALM_MAS_SCM.PriorityMappingId
	 INNER JOIN  [PP].[ALM_MAS_ColumnName]  ALM_MAS_CM ON ALM_MAS_CM.ALMColID=ALM_MAS_SCM.ColumnMappingId
	 where ALM_MAS_SCM.IsDeleted=0
  
 END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[PP].[GetAutoMappingCollectionData]', @ErrorMessage, 0 ,0
  END CATCH

END
