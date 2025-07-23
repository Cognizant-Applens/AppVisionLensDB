/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE GetWorkItemColMap (@ProjectID BIGINT)   
AS   
BEGIN   
BEGIN TRY    
	 SELECT mas.ALMColumnName as MasterColumn,  
	   map.ProjectColumn as MappedColumn   
	  FROM [PP].[ALM_MAP_ColumnName] map WITH(NOLOCK)   
	  JOIN  [PP].[ALM_MAS_ColumnName] mas WITH(NOLOCK) ON map.ALMColID = mas.ALMColID AND mas.ALMColID <> 24 AND mas.IsDeleted = 0 AND map.IsDeleted = 0    
	 WHERE map.ProjectId = @ProjectID   
END TRY   
BEGIN CATCH      
    
  DECLARE @ErrorMessage VARCHAR(MAX);    
    
  SELECT @ErrorMessage = ERROR_MESSAGE()    
    
  --INSERT Error        
  EXEC AVL_InsertError 'GetWorkItemColMap ', @ErrorMessage, @ProjectID    
      
END CATCH  
END
