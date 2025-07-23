/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [AVL].[GetReleaseDropdownValues]  
@ProjectID varchar(20), @Month int  
as   
begin  
begin try  
SELECT distinct  RI.ReleaseInfoId,RI.ReleaseId,   
--(select top 1 IsDeploymentCompleted from [ReleaseCertification].[RC].[Release_Deployment_Details] RDD 
--inner join [ReleaseCertification].[RC].[Release_Requirement_Info] RRI on
--RRI.ReleaseRequirementInfoId = RDD.ReleaseRequirementInfoId
--and (select ASD.ReleaseInfoId from [ADM].[ALM_TRN_Sprint_Details] ASD where ASD.ReleaseInfoId = @ReleaseInfoId) = RRI.ReleaseInfoId
--) 
null AS DeploymentStatus,RI.DeploymentDate  
FROM [ReleaseCertification].[RC].[Release_Info] RI 
where CHARINDEX(@ProjectID, RI.ProjectId) > 0 and MONTH(RI.DeploymentDate) >= @Month
--inner join [ReleaseCertification].[RC].[Release_Deployment_Details] RD on CHARINDEX(CONVERT(varchar,@ProjectID), RI.ProjectId) > 0 and RD.ReleaseInfoId = RI.ReleaseInfoId and RD.IsDeleted = 0 and RI.IsDeleted = 0  
--left join ReleaseCertification.RC.Release_Requirement_Info RR on RR.ReleaseInfoId = RI.ReleaseInfoId  
--and RR.ProjectId = @ProjectID  
  
--select WT.WorkTypeId,WT.WorkTypeName from [PP].[ALM_MAS_WorkType] WT where WT.IsDeleted = 0 and (REPLACE(LOWER(WT.WorkTypeName),' ','') = 'userstory' or REPLACE(LOWER(WT.WorkTypeName),' ','') = 'task' or REPLACE(LOWER(WT.WorkTypeName),' ','') = 'bug')  
end try 
begin catch  
DECLARE @Message VARCHAR(MAX);    
DECLARE @ErrorSource VARCHAR(MAX);        
          
  SELECT @Message = ERROR_MESSAGE()  
  select @ErrorSource = ERROR_STATE()    
EXEC AVL_InsertError '[AVL].[GetReleaseDropdownValues]',@Message,'',0           
end catch  
end
