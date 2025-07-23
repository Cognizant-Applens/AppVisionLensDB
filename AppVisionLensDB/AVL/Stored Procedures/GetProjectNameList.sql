CREATE procedure [AVL].[GetProjectNameList](
@TVP_GovernanceData AVL.TVP_ProjectName READONLY )
AS
BEGIN
BEGIN TRY
CREATE TABLE #tempGovernanceData(
[ProjectName] [varchar](1000) NOT NULL,
)
Insert into #tempGovernanceData
select * from @TVP_GovernanceData 

select ProjectName as 'Project Name' from  #tempGovernanceData  where ProjectName Not in
(select PM.ProjectName FROM [AVL].[MAS_ProjectMaster] PM where PM.IsDeleted = 0)

END TRY
BEGIN CATCH
DECLARE @Message VARCHAR(MAX);
DECLARE @ErrorSource VARCHAR(MAX);

SELECT @Message = ERROR_MESSAGE()
select @ErrorSource = ERROR_STATE()
EXEC dbo.AVL_InsertError '[AVL].[GetProjectNameList]',@ErrorSource,@Message,0
END CATCH
END
