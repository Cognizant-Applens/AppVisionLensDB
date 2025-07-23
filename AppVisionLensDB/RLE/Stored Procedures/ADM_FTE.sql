
CREATE procedure [RLE].[ADM_FTE]
as
begin
--ADM1

CREATE TABLE #ADM1
(
ProjectID Bigint,
ADM_Project_Owning_Unit nvarchar(max)
)

insert into #ADM1

SELECT Distinct ProjectID, 'ADM' as 'ADM Project Owning Unit'
FROM [$(SmartGovernanceDB)].[dbo].[ActiveReleaseProjects] (NOLOCK)
WHERE ((((Year(GETDATE()) - 1) * 12)) + Month(GETDATE())) - (((Active_Year - 1) * 12) + Active_Month) <=1

UNION

SELECT Distinct ESAProjectID as ProjectID,'ADM' as "ADM Project Owning Unit"
FROM dbo.AVM_Project_list (NOLOCK)
WHERE PracticeOwnerId = 28 
AND ESAProjectID NOT IN(
SELECT Distinct ProjectID
FROM [$(SmartGovernanceDB)].[dbo].[ActiveReleaseProjects] (NOLOCK)
WHERE ((((Year(GETDATE()) - 1) * 12)) + Month(GETDATE())) - (((Active_Year - 1) * 12) + Active_Month) <=1);

--ADM2

CREATE TABLE #ADM2
(
ProjectID Bigint,
DEScopeId nvarchar(max),
PracticeOwnerId nvarchar(max),
ADM_Project_Owning_Unit nvarchar(max)
)

insert into #ADM2

SELECT  distinct a.ProjectID,b.DEScopeId,c.BUID as PracticeOwnerId
,c.BUName as 'ADM Project Owning Unit'
FROM ESA.ProjectAssociates a
Inner Join dbo.AVM_Project_list b 
on a.ProjectID=b.ESAProjectID 
Inner Join AVL.BusinessUnit c 
on c.BUID=b.PracticeOwnerId
Where Left(a.Dept_Name,3) = 'ADM'
and a.projectid not in (select projectid from #adm1)


--ADM
CREATE TABLE #ADM
(
ESAProjectID Bigint,
ADM_Project_Owning_Unit nvarchar(max),
Flag2 nvarchar(max)
)
insert into #ADM

select ProjectID as ESAProjectID, ADM_Project_Owning_Unit,'ADM' as Flag2
from #ADM1
Union
select ProjectID as ESAProjectID, ADM_Project_Owning_Unit,'ADM' as Flag2
from #ADM2

--select * from #adm

select a.ESAProjectID,a.ADM_Project_Owning_Unit,a.Flag2,
b.AllocationPercent,b.Dept_Name
from #ADM a left join ESA.ProjectAssociates b on a.ESAProjectID=b.projectid


drop table #ADM
drop table #ADM1
drop table #ADM2
end

