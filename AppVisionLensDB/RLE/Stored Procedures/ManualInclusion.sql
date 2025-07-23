
Create procedure [RLE].[ManualInclusion]
as
begin
select  
   a.ProjectID,
   a.AssociateID,
   concat(a.ProjectID,a.AssociateID) AS AP,
   a.CodeID,
   a.Comments,
   a.ReleaseDate,
    (CASE 
	WHEN a.Status = 'Submitted' and a.isdeleted=1 then 'Rejected'
	ELSE a.Status
	END) AS Status,
	(CASE 
	WHEN a.IsActive=0 and a.Status ='Submitted' then '1'
	WHEN a.IsActive=0 and a.Status ='Rejected' then '1'
	ELSE a.IsActive
	END) AS IsActive,
	(CASE 
	WHEN a.isdeleted is null then '0'
	ELSE a.isdeleted
	END) AS isdeleted,
   a.ReasonForDeletion as 'Rejection Reason',
   a.BenifitsProvided,
   a.IsDeleted,
   a.ProcessingMonth,
   a.ProcessYear,
   a.ProcessMonth,
   (CASE 
	WHEN a.CodeID = 26 THEN 3
	ELSE a.StrategyID
	END) AS Strategy,
   c.ReleaseCode,
	d.AssociateName,
	d.Designation,
    d.Grade,
	d.Supervisor_ID,
	d.Supervisor_Name,
	e.StrategyName
from [$(SmartGovernanceDB)].dbo.ManualInclusion_Details  a with (nolock) 
join [$(SmartGovernanceDB)].dbo.ReleaseReason_Codes c with (nolock)  on c.CodeID=a.CodeID and a.ProcessYear>='2020' 
left join ESA.Associates d with (nolock)  on d.AssociateID=a.AssociateID
left join [$(SmartGovernanceDB)].dbo.FTE_ReleaseDetails b with (nolock)   
on b.ProjectId=a.ProjectID and b.AssociateID=a.AssociateID
and b.BusinessStatus='Rejected' and b.isActive=1
left join [$(SmartGovernanceDB)].MAS.FTE_Strategy e on e.strategyid=c.strategy
end



