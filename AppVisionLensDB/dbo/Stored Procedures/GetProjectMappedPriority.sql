/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE GetProjectMappedPriority (@ProjectID  BIGINT)   
AS   
BEGIN   
BEGIN TRY        
	SELECT [PriorityMapId] AS PriorityMapId,[ProjectPriorityName] AS PriorityName FROM [PP].[ALM_MAP_Priority] WITH(NOLOCK)     
	WHERE ProjectId = @ProjectID AND IsDeleted = 0    
END TRY   
BEGIN CATCH      
    
DECLARE @ErrorMessage VARCHAR(MAX);    
    
SELECT @ErrorMessage = ERROR_MESSAGE()    
    
--INSERT Error        
EXEC AVL_InsertError 'GetProjectMappedPriority ', @ErrorMessage, @ProjectID    
      
END CATCH  
END
