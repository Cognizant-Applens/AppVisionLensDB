/***************************************************************************      
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET      
*Copyright [2018] – [2021] Cognizant. All rights reserved.      
*NOTICE: This unpublished material is proprietary to Cognizant and      
*its suppliers, if any. The methods, techniques and technical      
  concepts herein are considered Cognizant confidential and/or trade secret information.       
        
*This material may be covered by U.S. and/or foreign patents or patent applications.       
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.      
***************************************************************************/      
      
-- ============================================================================------      
-- Author: Dhivya Bharathi M                
--  Create date:    April 16 2019         
--  EXEC    [AVL].[Infra_GetTemplateHeaderValues] 10901      
-- ============================================================================      
CREATE PROCEDURE [AVL].[Infra_GetTemplateHeaderValues] --  1,'Default'    
(      
 @CustomerID BIGINT,      
 @Mode varchar(100) = 'Default'      
)      
AS      
BEGIN      
      
 BEGIN TRY      
      
  CREATE TABLE #Attributes        
  (        
   [ID] INT identity(1,1),      
   AttributeName NVARCHAR(265) NULL        
  )        
  SELECT HierarchyOneDefinition,HierarchyTwoDefinition,HierarchyThreeDefinition,        
  HierarchyFourDefinition,HierarchyFiveDefinition,HierarchySixDefinition INTO #TempHierarchy         
  FROM AVL.InfraClusterDefinition(NOLOCK) WHERE CustomerID=@CustomerID        
        
  INSERT INTO  #Attributes         
  SELECT Concat(AttributeName, ' *') FROM #TempHierarchy        
  UNPIVOT(AttributeName For ColumnName IN (HierarchyOneDefinition,HierarchyTwoDefinition,HierarchyThreeDefinition,        
  HierarchyFourDefinition,HierarchyFiveDefinition,HierarchySixDefinition)) AS Levels        
  IF(@Mode = 'Default')        
  BEGIN        
        
   INSERT INTO  #Attributes         
   SELECT AttributeName FROM  AVL.InfraTemplateMaster(NOLOCK)        
  END        
      
   --SELECT AttributeName FROM #Attributes WHERE AttributeName !='' AND AttributeName != ' *'        
      
  ;WITH Attributes AS      
 (      
    SELECT id,AttributeName,AttributeName AS Rank FROM #Attributes WHERE AttributeName !='' AND AttributeName != ' *'        
      
 )      
 SELECT AttributeName        
 FROM Attributes      
    
      
 DROP TABLE #Attributes      
      
 END TRY        
 BEGIN CATCH        
   DECLARE @ErrorMessage VARCHAR(MAX);      
   SELECT @ErrorMessage = ERROR_MESSAGE()      
   EXEC AVL_InsertError ' [AVL].[Infra_GetTemplateHeaderValues]', @ErrorMessage, 0,0      
 END CATCH        
END
