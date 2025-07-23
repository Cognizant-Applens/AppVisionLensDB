/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ==========================================================================================   
-- Author: Karunapriya    
-- Create date: 28-Sep-2020   
-- Description: Update the Generic Work item configuration details with Is Parent Mandate,    
--              Is Estimation Points and Is Effort Tracking
-- ==========================================================================================    
--exec [PP].[GetALMMAPWorkType]     
CREATE PROCEDURE [PP].[UpdateGenericWorkItemConfig]     
	@ProjectID			INT,    
	@ALMGenericWorkItem [PP].[TVP_UpdateGenericWorkItem] READONLY,    
	@CustomerID			INT				=	NULL,    
	@CreatedBy			VARCHAR(100)	=	NULL    
AS        
BEGIN      
 BEGIN TRY    
      
	UPDATE [PP].[ALM_MAP_GenericWorkItemConfig] 
	SET WorkItemTypeId		= t2.WorkItemTypeId,    
		ParentHierarchyId	= t2.ParentHierarchyId,    
		IsParentMandate		= t2.IsParentMandate,    
		IsEffortTracking	= t2.IsEffortTracking,    
		IsEstimationPoints  = t2.IsEstimationPoints,    
		ModifiedBy			= @CreatedBy,    
		ModifiedDate		= GETDATE()    
   FROM [PP].[ALM_MAP_GenericWorkItemConfig] t1    
   JOIN @ALMGenericWorkItem t2 
	ON t1.ProjectID = t2.ProjectID AND t1.ExecutionId =	t2.ExecutionId AND t1.WorkItemTypeId = t2.WorkItemTypeId   
   
   -- Save ALM configuration progress percentage (Applens as ALM) in Project Profiling tile progress table
   EXEC [PP].[SaveAdapterTileProgressPercentage] @ProjectID, @CreatedBy
 
 END TRY    
 BEGIN CATCH
 
	DECLARE @ErrorMessage VARCHAR(MAX);    
	SELECT @ErrorMessage = ERROR_MESSAGE()    
 
	--INSERT Error        
	EXEC AVL_InsertError '[PP].[UpdateGenericWorkItemConfig]', @ErrorMessage, '', ''    
	RETURN @ErrorMessage
 
 END CATCH   
 
END
