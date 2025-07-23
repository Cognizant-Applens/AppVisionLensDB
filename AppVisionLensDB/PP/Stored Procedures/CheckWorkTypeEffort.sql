CREATE PROCEDURE [PP].[CheckWorkTypeEffort] 
	@ProjectId BIGINT,
	@WorkTypeId BIGINT
AS
BEGIN
	SELECT  CASE WHEN COUNT(WD.WorkItem_Id) > 0 THEN 1 ELSE 0 END AS EffortTracked
	FROM adm.ALM_TRN_WorkItem_Details(NOLOCK) WD
	JOIN PP.ALM_MAP_WorkType(NOLOCK) WT 
	ON WD.WorkTypeMapId = WT.WorkTypeMapId 
	AND WD.Project_Id = WT.ProjectId AND	WD.IsDeleted = 0
	WHERE WD.Project_Id = @ProjectId AND 
	WT.WorkTypeId = @WorkTypeId AND 
	WorkProfilerEffort > 0 
END