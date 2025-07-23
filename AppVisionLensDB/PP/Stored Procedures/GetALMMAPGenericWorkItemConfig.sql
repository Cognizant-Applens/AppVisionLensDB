/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetALMMAPGenericWorkItemConfig]
@projectId INT,
@executionId INT
AS
BEGIN
BEGIN TRY
SELECT
GW.ProjectId
,GW.ExecutionId
,GW.WorkItemTypeId
,GW.ParentHierarchyId
,GW.IsParentMandate
,GW.IsEffortTracking
,GW.IsEstimationPoints,  
 
SUM(CASE when APPDET.executionMethod is null  
then 0 else  
CASE WHEN WD.WorkTypeMapId is null then 0 else 1 end
end) AS WorkItemCount
 
FROM [PP].[ALM_MAP_GenericWorkItemConfig] GW
JOIN [PP].[Generic_MAP_WorkType] MW on MW.WorkTypeId = GW.WorkItemTypeId
LEFT JOIN [ADM].[ALM_TRN_WorkItem_Details] WD on GW.ProjectId = WD.Project_Id and WD.WorkTypeMapId=MW.WorkTypeMapId AND WD.IsDeleted=0
 
 left join [ADM].[ALM_TRN_WorkItem_ApplicationMapping] WP on WD.WorkItemDetailsID=WP.WorkItemDetailsID
 left join ADM.ALMApplicationDetails APPDET on APPDET.applicationid = WP.application_id  and gw.ExecutionId= APPDET.executionMethod
 
WHERE GW.ProjectId=@projectId AND GW.ExecutionId=@executionId AND MW.IsDefault='Y' AND GW.IsDeleted=0 AND MW.IsDeleted=0
GROUP BY GW.ProjectId,GW.ExecutionId,GW.WorkItemTypeId,GW.ParentHierarchyId,GW.IsParentMandate,GW.IsEffortTracking,GW.IsEstimationPoints
 
 
END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);
SELECT @ErrorMessage = ERROR_MESSAGE()
--INSERT Error
EXEC AVL_InsertError '[PP].[GetALMMAPGenericWorkItemConfig]'  , @ErrorMessage, '',''  
RETURN @ErrorMessage
END CATCH
END
