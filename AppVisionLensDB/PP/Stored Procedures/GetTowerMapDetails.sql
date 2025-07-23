/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE  PROCEDURE [PP].[GetTowerMapDetails]  --10569   ,'G'               
(                
@ProjectID BIGINT ,                  
@Mode VARCHAR(5)                
)                    
AS                    
BEGIN                    
SET NOCOUNT ON                    
DECLARE @ShowITSMConfig BIT=0,      
@ShowALMConfig BIT=0,-- Consider this param for Tower map check;      
@IsAssignmentGroupInfra BIT=0  
                    
IF(@Mode='P')/*project Scope Details(CIS) */                
BEGIN                
/* AttributeID =1 = ProjectScope*/                    
  SELECT PAV.AttributeValueID as 'AttributeValueID', ppav.AttributeValueName as 'AttributeValueName'                    
  INTO #ScopeDetails                    
  FROM PP.ProjectAttributeValues PAV                    
  JOIN MAS.PPAttributeValues ppav on pav.AttributeID=ppav.AttributeID                     
    and PAV.AttributeValueID=ppav.AttributeValueID and ppav.IsDeleted=0 and ppav.AttributeID=1                    
  WHERE PAV.AttributeID=1 and PAV.ProjectID=@ProjectID AND PAV.IsDeleted=0                    
--Is CIS Check                 
IF EXISTS ( SELECT TOP 1 1 FROM #ScopeDetails)                    
BEGIN                    
IF EXISTS(SELECT TOP 1 1 FROM #ScopeDetails WHERE AttributeValueID in (3))                    
BEGIN                    
SET @ShowITSMConfig=1                    
END                               
END        
--Is Assignment Group Infra mapped Check  
IF EXISTS (SELECT TOP 1 ProjectId FROM  AVl.BOTAssignmentGroupMapping where Projectid=@ProjectID and IsDeleted=0  and Supporttypeid=2)      
BEGIN      
SET @IsAssignmentGroupInfra =1;      
END      
 --Is Towera mapped Check     
IF EXISTS (SELECT TOP 1 ProjectId FROM  AVl.InfraTowerProjectMapping where Projectid=@ProjectID and IsEnabled=1)    and @IsAssignmentGroupInfra =1  
BEGIN      
SET @ShowALMConfig =1;      
END      
                    
SELECT @ShowITSMConfig AS 'ShowITSMConfig' ,@ShowALMConfig as 'ShowALMConfig'                  
END           
        
IF(@Mode='G')/*Grid Loads in Tower Mapping*/        
BEGIN        
BEGIN TRY          
          
SELECT DISTINCT    
PM.EsaProjectID as ESAProjectID,   
TAG.ProjectID as ProjectID,  
PM.ProjectName,   
Ag.AssignmentGroupName,   
TDT.TowerName    
from PP.TowerAssignmentGroupMapping TAG    
join AVL.MAS_ProjectMaster PM on PM.ProjectID = TAG.ProjectID   
join AVL.BOTAssignmentGroupMapping AG  on AG.AssignmentGroupMapID = TAG.AssignmentGroupMapId  and  AG.SupportTypeID=2       
Join AVL.InfraTowerDetailsTransaction TDT on TAG.TowerID = TDT.InfraTowerTransactionID     
where TAG.IsDeleted = 0 and AG.IsDeleted = 0 and TDT.IsDeleted = 0 and TAG.ProjectID = @projectid         
ORDER by Ag.AssignmentGroupName           
          
END TRY           
BEGIN CATCH          
DECLARE @ErrorMessage VARCHAR(MAX);          
SELECT          
 @ErrorMessage = ERROR_MESSAGE()          
EXEC AVL_InsertError '[PP].[GetTowerMapDetails]'          
      ,@ErrorMessage          
      ,0          
      ,0          
END CATCH         
END        
END
