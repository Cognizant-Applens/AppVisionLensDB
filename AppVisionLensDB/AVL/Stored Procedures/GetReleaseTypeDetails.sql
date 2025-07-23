/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [AVL].[GetReleaseTypeDetails]  
@SprintDetailId bigint, @ProjectId bigint, @isApplensAsAnALMTool bit
as   
begin  
begin try  
select ReleaseInfoId
,(select top 1 IsDeploymentCompleted from [ReleaseCertification].[RC].[Release_Deployment_Details] RDD 
inner join [ReleaseCertification].[RC].[Release_Requirement_Info] RRI on
RRI.ReleaseRequirementInfoId = RDD.ReleaseRequirementInfoId
and (select top 1 ASD.ReleaseInfoId from [ADM].[ALM_TRN_Sprint_Details] ASD where ASD.ReleaseInfoId = ReleaseInfoId) = RRI.ReleaseInfoId
) as DeploymentStatus
,(select top 1 Cast(Actual_Deployment_Date as nvarchar(50)) + '/' + Cast(IsDeploymentCompleted as nvarchar(50)) from [ReleaseCertification].[RC].[Release_Deployment_Details] RDD   
inner join [ReleaseCertification].[RC].[Release_Requirement_Info] RRI on  
RRI.ReleaseRequirementInfoId = RDD.ReleaseRequirementInfoId  
and (select top 1 ASD.ReleaseInfoId from [ADM].[ALM_TRN_Sprint_Details] ASD where ASD.ReleaseInfoId = ReleaseInfoId and ASD.SprintDetailsId = @SprintDetailId) = RRI.ReleaseInfoId  
) as ActualReleaseDate
,(select STUFF((select ',' + CAST(RM.WorkTypeMapId as varchar(10))[text()] from [AVL].[ReleaseWorkItemMapping] RM where  RM.SprintDetailId=@SprintDetailId  FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,1,' ')) as SelectedWorkItems
from adm.ALM_TRN_Sprint_Details where SprintDetailsId= @SprintDetailId

select AWT.WorkTypeMapId,AWT.WorkTypeId, AWT.ProjectWorkTypeName, COUNT(AWT.WorkTypeMapId) as WorkTypeCount from [ADM].[ALM_TRN_WorkItem_Details] AWD      
inner join [PP].[ALM_MAP_WorkType] AWT on AWT.WorkTypeMapId = AWD.WorkTypeMapId and SprintDetailsId = @SprintDetailId and Project_Id = @ProjectId  group by AWT.WorkTypeMapId,AWT.WorkTypeId, AWT.ProjectWorkTypeName 

--if(@isApplensAsAnALMTool = 1)
--begin
--select AWT.WorkTypeMapId,AWT.WorkTypeId, AWT.ProjectWorkTypeName, COUNT(AWT.WorkTypeMapId) as WorkTypeCount from [ADM].[ALM_TRN_WorkItem_Details] AWD    
--inner join [PP].[ALM_MAP_WorkType] AWT on AWT.WorkTypeMapId = AWD.WorkTypeMapId and SprintDetailsId = @SprintDetailId and Project_Id = @ProjectId  group by AWT.WorkTypeMapId,AWT.WorkTypeId, AWT.ProjectWorkTypeName 
--end
--if(@isApplensAsAnALMTool = 0)
--begin
----select AWT.WorkTypeId, COUNT(AWT.WorkTypeId) as WorkTypeCount from [ADM].[ALM_TRN_WorkItem_Details] AWD    
----inner join [PP].[ALM_MAP_WorkType] AWT on AWT.WorkTypeMapId = AWD.WorkTypeMapId and SprintDetailsId = @SprintDetailId and Project_Id = @ProjectId and AWT.IsDefault !='Y' group by AWT.WorkTypeId
--select AWT.WorkTypeMapId,AWT.WorkTypeId, AWT.ProjectWorkTypeName, COUNT(AWT.WorkTypeId) as WorkTypeCount from [PP].[ALM_MAP_WorkType] AWT where  AWT.ProjectId = @ProjectId and WorkTypeId in (select WorkTypeId from [PP].[ALM_MAS_WorkType] WT where (REPLACE(LOWER(WT.WorkTypeName),' ','') = 'userstory' or REPLACE(LOWER(WT.WorkTypeName),' ','') = 'task' or REPLACE(LOWER(WT.WorkTypeName),' ','') = 'bug')) group by AWT.WorkTypeMapId,AWT.WorkTypeId, AWT.ProjectWorkTypeName
--end
end try 
begin catch 
DECLARE @Message VARCHAR(MAX);    
DECLARE @ErrorSource VARCHAR(MAX);        
          
  SELECT @Message = ERROR_MESSAGE()  
  select @ErrorSource = ERROR_STATE()    
EXEC AVL_InsertError '[AVL].[GetReleaseTypeDetails]',@Message,'',0         
end catch end
