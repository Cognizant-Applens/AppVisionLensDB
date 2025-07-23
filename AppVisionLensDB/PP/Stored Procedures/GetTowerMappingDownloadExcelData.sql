/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetTowerMappingDownloadExcelData] --'10569','D'                 
(                  
@ProjectID VARCHAR(20),                  
@Mode VARCHAR(5)                  
)                  
AS                  
BEGIN                  
IF(@Mode='D')                  
BEGIN                  
BEGIN TRY                   
                  
    
SELECT DISTINCT  AG.AssignmentGroupName 'Assignment Group Name',ISNULL(RTRIM(LTRIM(TowerName)),'') AS 'Tower Name'      
FROM AVL.BOTAssignmentGroupMapping AG     
LEFT JOIN PP.Towerassignmentgroupmapping TP  ON TP.AssignmentGroupMapId=AG.AssignmentGroupMapId AND TP.ProjectId = @ProjectID AND TP.IsDeleted=0    
LEFT JOIN  AVL.InfraTowerDetailsTransaction TM  ON TM.InfraTowerTransactionID= TP.TowerId       
WHERE AG.ProjectId=@ProjectID and AG.IsDeleted=0  and AG.SupportTypeID=2  
    
        
                
SELECT TM.TowerName 'Tower Name'FROM AVL.InfraTowerProjectMapping TMap                
JOIN AVL.InfraTowerDetailsTransaction TM ON TM.InfraTowerTransactionID=TMap.TowerID                 
WHERE projectid=@ProjectID AND IsEnabled=1 AND TMap.IsDeleted=0                
                
END TRY                     
BEGIN CATCH                    
DECLARE @ErrorMessage VARCHAR(MAX);                    
SELECT                    
 @ErrorMessage = ERROR_MESSAGE()                    
EXEC AVL_InsertError '[PP].[GetTowerMappingDownloadExcelData]'                    
      ,@ErrorMessage                    
      ,0                    
      ,0                    
END CATCH                   
                  
END                  
END
