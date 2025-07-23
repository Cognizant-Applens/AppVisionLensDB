CREATE FUNCTION [ADM].[GetDevDefects] 
(	
	@sprintId BIGINT
)

RETURNS INT 
AS
BEGIN
DECLARE @countOfDevDefects int = 0;	
	WITH cteUserStories AS(
	SELECT WDS.WorkItemDetailsId,WDS.WorkItem_Id FROM adm.alm_trn_workitem_details WDS WITH(NOLOCK)
	INNER JOIN pp.ALM_MAp_WorkType WTP WITH(NOLOCK) ON WDS.WorkTypeMapId = WTP.WorkTypeMapId
	INNER JOIN  pp.ALM_MAs_WorkType WTS WITH(NOLOCK) ON WTS.WorkTypeId =  WTP.WorkTypeId
	WHERE WDS.SprintDetailsId = @sprintId AND WTP.WorkTypeId = 2
	),

	cteBugPhaseType1 AS(
	SELECT WD.workItem_Id FROM adm.alm_trn_workitem_details WD WITH(NOLOCK)
	INNER JOIN pp.ALM_MAp_WorkType WTP WITH(NOLOCK) ON WD.WorkTypeMapId = WTP.WorkTypeMapId
	INNER JOIN  pp.ALM_MAs_WorkType WTS WITH(NOLOCK) ON WTS.WorkTypeId =  WTP.WorkTypeId
	WHERE WTP.WorkTypeId = 4 and WD.BugPhaseTypeMapId = 1
	AND EXISTS (SELECT workItem_Id from cteUserStories WHERE workItem_Id = WD.Linked_ParentID )
	),

	cteBugPhaseWorkType2 AS(
	SELECT WD.workItem_Id FROM adm.alm_trn_workitem_details WD WITH(NOLOCK)
	INNER JOIN pp.ALM_MAp_WorkType WTP WITH(NOLOCK) ON WD.WorkTypeMapId = WTP.WorkTypeMapId
	INNER JOIN  pp.ALM_MAs_WorkType WTS WITH(NOLOCK) ON WTS.WorkTypeId =  WTP.WorkTypeId
	WHERE WD.SprintDetailsId = @sprintId AND WTP.WorkTypeId = 4 and WD.BugPhaseTypeMapId = 1
	)
	 SELECT @countOfDevDefects = COUNT(*) FROM (
     SELECT * FROM cteBugPhaseType1
	 UNION
	 SELECT * FROM cteBugPhaseWorkType2) AS DevDefects

	 RETURN @countOfDevDefects
END
