/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetExecutionMethodByProjectID]
(  
@ProjectID BIGINT   
)  
AS  
BEGIN  
SET NOCOUNT ON  
  
  SELECT DISTINCT PPAV.AttributeValueID as 'ExecutionID',PPAV.AttributeValueName as 'ExecutionName'  
  FROM PP.ProjectAttributeValues PAV   
  JOIN MAS.PPAttributeValues PPAV on PAV.AttributeID=PPAV.AttributeID   
  AND   
  PAV.AttributeValueID=PPAV.AttributeValueID  
  WHERE PAV.ProjectID=@ProjectID AND PAV.AttributeID=3  
  AND PPAV.IsDeleted=0 AND PAV.IsDeleted=0 AND PPAV.IsDeleted=0  
  
  Select GWC.WorkItemTypeId,AMW.WorkTypeName as ProjectWorkTypeName,GWC.ProjectId,GWC.ExecutionId,GWC.ParentHierarchyId,GWC.IsParentMandate,GWC.IsEffortTracking,GWC.IsEstimationPoints,AMW.WorkTypeOrder   FROM [PP].[ALM_MAP_GenericWorkItemConfig] GWC   
  left join [PP].[ALM_MAS_WorkType] AMW on AMW.WorkTypeId=GWC.WorkItemTypeId  WHERE GWC.IsDeleted=0   and GWC.ProjectId=@ProjectID ORDER by AMW.WorkTypeOrder ASC 

  
SET NOCOUNT OFF   
END
