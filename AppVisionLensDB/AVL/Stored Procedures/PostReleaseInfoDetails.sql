/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [AVL].[PostReleaseInfoDetails]        
@sprintDetailId bigint, @releaseinfoid bigint  , @projectId bigint, @workItemId smallint, @workTypeMapId nvarchar(4000), @userID nvarchar(10)
as      
begin          
      
begin try         

declare @requirementId varchar(100), @count int, @i int
set @requirementId = null
set @count = 0
set @i = 0

create table #tempWorkItemDetails
(
requirementId varchar(100),
requirementDescription varchar(2000)
)

create table #tempWorkItemMapDetails
(
sprintDetailId bigint,
workTypeMapId int
)

insert into #tempWorkItemDetails select WorkItem_Id, WorkItem_Description from ADM.ALM_TRN_WorkItem_Details where Project_Id = @projectId and WorkTypeMapId = @workItemId and SprintDetailsId = @sprintDetailId

update adm.ALM_TRN_Sprint_Details set ReleaseInfoId = @releaseinfoid where SprintDetailsId = @sprintDetailId      

--select @count = COUNT(*) from #tempWorkItemDetails

--while @i<@count
--begin

--end

insert into ReleaseCertification.RC.Release_Requirement_Info   
select @releaseinfoid,temp.requirementId,null,
CASE
    WHEN temp.requirementDescription is NULL THEN ' '
    WHEN temp.requirementDescription is not NULL THEN temp.requirementDescription
END as WorkItem_Description
,1,1, null, null,null,null,null,null,null,0,1,@projectId,11,null,null,null,null,null,null,GETDATE(),null,GETDATE(),null,3,null from #tempWorkItemDetails temp    -- multiple inserts  

insert into #tempWorkItemMapDetails values
(
@sprintDetailId,
(select Item from dbo.SplitString(@workTypeMapId,','))
)

insert into AVL.ReleaseWorkItemMapping
select @sprintDetailId, temp.workTypeMapId,0,GETDATE(),@userID,GETDATE(),@userID from #tempWorkItemMapDetails temp

drop table #tempWorkItemDetails
drop table #tempWorkItemMapDetails

end try    
begin catch      
DECLARE @Message VARCHAR(MAX);        
DECLARE @ErrorSource VARCHAR(MAX);            
              
  SELECT @Message = ERROR_MESSAGE()      
  select @ErrorSource = ERROR_STATE()        
EXEC AVL_InsertError '[AVL].[PostReleaseInfoDetails]',@ErrorSource,@Message,0         
end catch
end
