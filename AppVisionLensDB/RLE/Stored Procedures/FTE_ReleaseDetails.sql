CREATE   PROCEDURE [RLE].[FTE_ReleaseDetails]
as
begin
CREATE TABLE #ESA_ReleaseDetails(
	[AssociateID] [varchar](51) NULL,
	[ProjectID] [bigint] NULL,
	[AssociateName] [varchar](500) NULL,
	[Designation] [varchar](51) NULL,
	[ReleaseFTE] [float] NULL,
	[BilledFTE] [float] NULL,
	[UnbilledFTE] [float] NULL,
	[Location] [varchar](200) NULL,
	[ESALever] [varchar](100) NULL,
	[LocationCode] [varchar](200) NULL,
	[LocationGrouping] [varchar](500) NULL,
	[LocationDescription] [varchar](500) NULL,
	[ProcessingMonth] [varchar](15) NULL,
	[AllocationStartDate] [datetime] NULL,
	[AllocationEndDate] [datetime] NULL,
	[AllocationPercentage] [float] NULL,
	[ProjectName] [varchar](200) NULL,
	[ParentCustomerName] [varchar](200) NULL,
	[AssociateDept] [varchar](200) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [varchar](10) NULL,
	[CreatedDate] [datetime] NULL,
	[ProjectEndDate] [datetime] NULL,
	[ReleaseDate] [datetime] NULL,
	[Offshore_OnSite] [varchar](10) NULL,
	[ProcessMonth] [int] NULL,
	[ProcessYear] [int] NULL
)

insert into #ESA_ReleaseDetails(
AssociateID
,ProjectID
,AssociateName
,Designation
,ReleaseFTE
,BilledFTE
,UnbilledFTE
,Location
,ESALever
,LocationCode
,LocationGrouping
,LocationDescription
,ProcessingMonth
,AllocationStartDate
,AllocationEndDate
,AllocationPercentage
,ProjectName
,ParentCustomerName
,AssociateDept
,IsActive
,CreatedBy
,CreatedDate
,ProjectEndDate
,ReleaseDate
,Offshore_OnSite
,ProcessMonth
,ProcessYear) 
select AssociateID
,ProjectID
,AssociateName
,Designation
,ReleaseFTE
,BilledFTE
,UnbilledFTE
,Location
,ESALever
,LocationCode
,LocationGrouping
,LocationDescription
,ProcessingMonth
,AllocationStartDate
,AllocationEndDate
,AllocationPercentage
,ProjectName
,ParentCustomerName
,AssociateDept
,IsActive
,CreatedBy
,CreatedDate
,ProjectEndDate
,ReleaseDate
,Offshore_OnSite
,ProcessMonth
,ProcessYear from [$(SmartGovernanceDB)].[dbo].[ESA_ReleaseDetails]
--[CPCINCHPV004140].[$(AVMCOEESADB)].dbo.ESA_ReleaseDetails

;with cte as (select 
projectid,associateid,
Row_Number() over(partition by projectid,associateid order by createddate desc) as row_num
from  #ESA_ReleaseDetails)
delete from cte where row_num >1 ;

SELECT  
    a.ActualReleasedMonth, 
	a.AssociateID, 
	a.ProjectId, 
	a.ReleaseFTE, 
	a.ReleaseDate, 
	a.DEStatus, 
	a.BusinessStatus, 
	Coalesce(a.CorrectedCodeID,a.CodeID) as CodeID,
	a.ReplacedAssociateID, 
	a.ReplacedSOID, 
	a.DEComments, 
	a.BusinessComments, 
	a.ProcessingMonth, 
	a.DE_RequestedID, 
	a.Business_RequestedID, 
	a.Full_month_FTE, 
	a.RemainingMonth_FTEBenefit, 
	a.ReleaseMonth_FTEBenefit,
	b.AssociateName,
    b.Designation,
	b.ProjectID, 
    b.AssociateDept,
	b.ProcessingMonth, 
	b.AllocationStartDate, 
	b.AllocationEndDate, 
	b.AllocationPercentage,
	c.ReleaseCode,
	C.strategy,
	d.StrategyName
 FROM [$(SmartGovernanceDB)].dbo.FTE_ReleaseDetails (NOLOCK) a 
left join  #ESA_ReleaseDetails (NOLOCK) b on b.projectid=a.projectid 
 and b.associateid=a.associateid 
join [$(SmartGovernanceDB)].dbo.ReleaseReason_Codes c with (nolock)  
on c.CodeID=a.correctedcodeid
left join [$(SmartGovernanceDB)].MAS.FTE_Strategy d on d.strategyid=c.strategy
where  a.isActive = 1 
AND a.BusinessStatus = 'Approved' AND a.DEStatus = 'Approved' 
and a.ProcessYear>='2020' 

drop table #ESA_ReleaseDetails

end

