





--select * from [dbo].[VW_ProjectOnboarding]


CREATE VIEW [dbo].[VW_ProjectOnboarding]

AS

/****** Object:  View [dbo].[VW_ProjectOnboarding]    Script Date: 9/18/2023 12:55:11 PM ******/







WITH [SumFTECount] (ProjectID,SumFTE)
      AS
      (
            SELECT ProjectID,sum(TRY_CONVERT(decimal(18,4),AllocationPercent))/100
            FROM ESA.ProjectAssociates
           group by ProjectID
      ),
 [ApplensExemptionDetails](ProjectID,IsApplensExempt,ApplensRequesterComments,ApplensExemptionReasonID,[Applens Exemption Reason])
AS
(
	   SELECT distinct A.AccessLevelID as AccessLevelID
,'Yes' AS IsApplensExempt
,A.RequesterComments
,CASE 
WHEN B.ID IS NULL		THEN 1
		ELSE B.ID
		END AS ReasonID
	,CASE 
		WHEN B.ID IS NULL
			THEN 'Others'
		ELSE Reason
		END AS Reason
FROM [$(SmartGovernanceDB)].[dbo].ApplensExemptionDetails A
LEFT JOIN [$(SmartGovernanceDB)].[dbo].ModuleExemptionDetails ME on ME.ApplensExemptionID = A.ID
LEFT JOIN [$(SmartGovernanceDB)].[dbo].ExemptionActivityLog EA ON A.AccessLevelID = EA.AccessLevelID
	AND EA.ID = (
		SELECT MAX(ID)
		FROM [$(SmartGovernanceDB)].[dbo].[ExemptionActivityLog]
		WHERE AccessLevelID = A.AccessLevelID
			AND IsDeleted = 0
			AND EA.OptedFor = 'Exemption' AND Status = 'Approved' AND (ModuleID = 1 OR ModuleID = 4)
		)
LEFT JOIN [$(SmartGovernanceDB)].[MAS].[ExemptionReason] B ON B.ID = (
		CASE 
			WHEN A.ReasonID IS NULL
				OR A.ReasonID = 0
				THEN EA.ReasonID
			ELSE A.ReasonID
			END
		)
	AND (B.ModuleID = 1 AND B.ModuleID=4)
WHERE (A.IsDeleted = 0 AND A.CurrentlyExempted = 1 AND A.OptedFor = 'Exemption')
OR (ME.ModuleID=4 AND ME.OptedFor='Exemption' AND ME.Status = 'Approved' AND ME.CurrentlyExempted = 1  AND ME.IsDeleted=0)
),
[DebtExemptionDetails](EsaProjectID,IsDebtExempt,DebtRequesterComments,DebtExemptionReasonID,[Debt Exemption Reason])
AS
(
SELECT A.AccessLevelID as AccessLevelID
,'Yes' AS IsDebtExempt
,A.RequesterComments
,CASE 
WHEN B.ID IS NULL		THEN 1
		ELSE B.ID
		END AS ReasonID
	,CASE 
		WHEN B.ID IS NULL
			THEN 'Others'
		ELSE B.Reason
		END AS Reason
FROM [$(SmartGovernanceDB)].[dbo].ApplensExemptionDetails A
LEFT JOIN [$(SmartGovernanceDB)].[dbo].ModuleExemptionDetails ME on ME.[ApplensExemptionID] = A.ID
LEFT JOIN [$(SmartGovernanceDB)].[dbo].ExemptionActivityLog EA ON A.AccessLevelID = EA.AccessLevelID
	AND EA.ID = (
		SELECT MAX(ID)
		FROM [$(SmartGovernanceDB)].[dbo].[ExemptionActivityLog]
		WHERE AccessLevelID = A.AccessLevelID
			AND IsDeleted = 0
			AND EA.OptedFor = 'Exemption' AND Status = 'Approved' AND (ModuleID = 1 OR ModuleID = 5)
		)
LEFT JOIN [$(SmartGovernanceDB)].[MAS].[ExemptionReason] B ON B.ID = (
		CASE 
			WHEN A.ReasonID IS NULL
				OR A.ReasonID = 0
				THEN EA.ReasonID
			ELSE A.ReasonID
			END
		)
	AND (B.ModuleID = 1 AND B.ModuleID=5)
WHERE (A.IsDeleted = 0 AND A.CurrentlyExempted = 1 AND A.OptedFor = 'Exemption')
OR (ME.ModuleID=5 AND ME.OptedFor='Exemption' AND ME.Status = 'Approved' AND ME.CurrentlyExempted = 1  AND ME.IsDeleted=0)
),
[WorkItem](ProjectID,WorkItems)
As
(
 SELECT distinct Project_ID,
	Count(WorkItem_Id) as WorkItems
FROM ADM.ALM_TRN_WorkItem_Details(NOLOCK)
where Isdeleted=0
Group by Project_ID
),
[TicketItem](ProjectID,Tickets)
As
(
 SELECT distinct ProjectID,
	Count(TicketID) as Tickets
FROM AVL.TK_TRN_TicketDetail(NOLOCK)
where Isdeleted=0
Group by ProjectID
),
[Archetype](ProjectID,ProjectTypeID,Archetype)
AS
(
select distinct A.ProjectID, A.ProjectTypeID, B.AttributeValueName from pp.scopeofwork A
join mas.PPAttributevalues B on A.ProjectTypeID = B.AttributeValueID
Where A.IsDeleted = 0 and B.IsDeleted = 0 and B.AttributeID = 4
),
[DEScope](ESA_Project_ID,Project_Owning_Unit,DE_Scope,[Tracking Mode],[Project_Ported_Date],[Is Performance data Sharing restricted as per contract])
AS
(SELECT  Distinct "ESA_Project_ID",
    Project_Owning_Unit,
    (CASE 
    WHEN Final_Scope = 'In Scope' THEN 'In scope'
    WHEN Final_Scope = 'Not In Scope' THEN 'Not in scope'
    ELSE Final_Scope END) AS Final_Scope,
    "Tracking Mode",
    DATEADD(MINUTE,30,DATEADD(HOUR,5,"Project_Ported_Date")),
    "Is Performance data Sharing restricted as per contract"
FROM dbo.OPLMasterdata (NOLOCK)),
[ProjectScope](ProjectID,ProjectScope)
As
(
select distinct A.ProjectID as ProjectID, string_agg(B.AttributeValueName, ', ') as ProjectScope
FROM pp.ProjectAttributeValues  A
Join mas.PPAttributeValues B on A.AttributeValueID = B.AttributeValueID
where A.AttributeID = 1 and B.AttributeID = 1 and A.IsDeleted = 0 and B.IsDeleted = 0
group by A.ProjectID
),
[Projecttype](ProjectID,ProjectType)
As
(
select distinct P.EsaProjectID,CASE WHEN PS.ProjectScope like'%Development%' and PS.ProjectScope not like '%Maintenance%' then 'AD'
WHEN PS.ProjectScope like'%Development%' and PS.ProjectScope  like '%Maintenance%' then 'ADM' 
WHEN PS.ProjectScope like'%Maintenance%' and PS.ProjectScope  not like '%Development%' then 'AMS' 
WHEN PS.ProjectScope like'%CIS%' and PS.ProjectScope  not like '%Development%' and PS.ProjectScope not like '%Maintenance%'then 'CIS' 
WHEN A.Archetype in('Development') or A.Archetype in('Modernization') then 'AD'
WHEN  A.Archetype in('Enhancement and Support') then 'AMS'
WHEN PS.ProjectScope is not null then 'Others'
WHEN PS.ProjectScope is  null and A.Archetype is not null then 'Others' else
'NA' end as Projecttype from AVL.MAS_ProjectMaster(NOLOCK)  P
left join  [ProjectScope] PS ON PS.ProjectID=P.ProjectID
left join [Archetype] A ON A.ProjectID=P.ProjectID
--where P.isdeleted=0
),
[DebtEnabled](ProjectID,DebtEnabled)
AS
(
SELECT distinct Proj.ESAProjectID,
CASE WHEN ((DED.IsDebtExempt is null or DED.IsDebtExempt='N')and(Proj.IsDebtEnabled ='N' or Proj.IsDebtEnabled is null)and (AED.IsApplensExempt is null 
or AED.IsApplensExempt='N')) 
and (DS.[DE_Scope] = 'Not in scope' or Ds.[DE_Scope] = 'Yet to scope' or
DS.[Is Performance data Sharing restricted as per contract] = 'Yes' or
PT.ProjectType in('AD','Others','NA') or(datediff(day,DATEADD(MINUTE,30,DATEADD(HOUR,5,Project_Ported_Date)),DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())))) < 30 or SF.SumFTE < 5 OR SF.SumFTE is null or 
P.BillabilityType ='NBL' or P.ProjectType='EXANT') THEN 'Not Applicable' ELSE CASE WHEN AED.IsApplensExempt is not null then 'Exempted'
WHEN DED.IsDebtExempt is not null then 'Exempted'
WHEN Proj.IsDebtEnabled='Y' then 'Enabled' else 'Not Enabled' end end as DebtEnabled
from AVL.MAS_ProjectMaster(NOLOCK)  Proj 
left join [SumFTECount] SF ON SF.ProjectID=Proj.ESAProjectID
left join [ApplensExemptionDetails]  AED ON AED.ProjectID=Proj.ESAProjectID
left JOIN [DebtExemptionDetails] DED ON DED.EsaProjectID=Proj.ESAProjectID
left JOIN ESA.Projects (NOLOCK) P ON P.ID=Proj.ESAProjectID
--left join AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.ESAProjectID=Proj.ESAProjectID
left Join [DEScope] DS ON DS.ESA_Project_ID=Proj.ESAProjectID
left Join [Projecttype] PT ON PT.ProjectID=Proj.ESAProjectID
WHERE Proj.Isdeleted=0 and P.ProjectStatus='A'

),
[Threshold](EsaProjectID,ThresholdCount)
AS
(
select distinct PDD.EsaProjectID as EsaProjectID,max(ThresholdCount) from 
AVL.DEBT_MAS_HealProjectThresholdMaster Thres,
AVL.MAS_ProjectDebtDetails PDD 
where Thres.IsDeleted = 0 and PDD.IsDeleted = 0
and PDD.ProjectID = Thres.ProjectID
Group by PDD.EsaProjectID,ThresholdCount
)
 
SELECT distinct
proj.ESAProjectID,
SF.SumFTE as 'FTE',
DATEADD(MINUTE,30,DATEADD(HOUR,5,PDD.[DebtEnablementDate])) as [DebtEnablementDate],
DATEADD(MINUTE,30,DATEADD(HOUR,5,PDD.[DebtControlDate]))as [DebtControlDate],
PDD.[DebtControlFlag],
PDD.[IsAutoClassified],
DATEADD(MINUTE,30,DATEADD(HOUR,5,PDD.[AutoClassificationDate]))as [AutoClassificationDate],
PDD.[IsMLSignOff],
PDD.IsMLSignOffInfra,
PDD.[AutoClassifiedBy],
PDD.[IsDDAutoClassified],
PDD.IsDDAutoClassifiedInfra,
DATEADD(MINUTE,30,DATEADD(HOUR,5,PDD.[IsDDAutoClassifiedDate]))as [IsDDAutoClassifiedDate],
PDD.[DebtControlMethod],
CP.[ScreenID],
CP.[CompletionPercentage],
AED.IsApplensExempt, 
AED.ApplensRequesterComments,
AED.ApplensExemptionReasonID,
AED.[Applens Exemption Reason],
DED.IsDebtExempt, 
DED.DebtRequesterComments,
DED.DebtExemptionReasonID,
DED.[Debt Exemption Reason],
P.ProjectManagerID, 
P.AccountManagerID,
WI.WorkItems,
TI.Tickets,
CASE WHEN CP.[ScreenID] is not null then 'Y' 
ELSE 'N' end as ApplensOnboardedT,
CASE WHEN AED.IsApplensExempt is not null then 'Y' ELSE 'N' end as ApplensExemptedT,
CASE WHEN Proj.IsDebtEnabled='Y' then 'Y' ELSE 'N' end as DebtEnabledT,
CASE WHEN DED.IsDebtExempt is not null then 'Y' ELSE 'N' end as DebtExemptedT,
CASE WHEN AED.IsApplensExempt is not null then 'Exempted' 
WHEN CP.[ScreenID] is not null then 'Onboarded' else 'Not Onboarded' end as ApplensOnboardedP,
CASE WHEN AED.IsApplensExempt is not null then AED.[Applens Exemption Reason] end as [Applens ExemptionReason],
CASE WHEN AED.IsApplensExempt is not null then 'Exempted'
WHEN DED.IsDebtExempt is not null then 'Exempted'
WHEN Proj.IsDebtEnabled='Y' then 'Enabled' else 'Not Enabled' end as DebtEnabledP,
CASE WHEN AED.IsApplensExempt is not null then 'Applens Exempted' 
WHEN DED.IsDebtExempt is not null then DED.[Debt Exemption Reason] end as [Debt ExemptionReason],
CASE WHEN PDD.[IsMLSignOff]=1 or PDD.IsMLSignOffInfra=1 then 'Machine Learning'
WHEN PDD.[IsDDAutoClassified]='Y' or PDD.IsDDAutoClassifiedInfra=1 then 'Data Dictionary'
ELSE 'Manual' end as [Debt Classification Mode],
CASE WHEN A.Archetype is null and ((SF.SumFTE < 5 OR SF.SumFTE is null) or  P.BillabilityType ='NBL' or P.ProjectType='EXANT')
then 'Not Mandated' ELSE case when A.Archetype is null then 'Not Onboarded' else 'Onboarded' end end as PPOnboarded,
CASE WHEN (AED.IsApplensExempt is null and CP.[ScreenID] is null) and (DS.[DE_Scope] = 'Not in scope' or DS.[DE_Scope] = 'Yet to scope' 
or DS.[Is Performance data Sharing restricted as per contract] = 'Yes'
or (datediff(day,DATEADD(MINUTE,30,DATEADD(HOUR,5,Project_Ported_Date)),DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())))) < 30 or SF.SumFTE < 5 OR SF.SumFTE is null or P.BillabilityType ='NBL' or P.ProjectType='EXANT') 
THEN 'Not Mandated' ELSE CASE WHEN AED.IsApplensExempt is not null then 'Exempted' 
WHEN CP.[ScreenID] is not null then 'Onboarded' else 'Not Onboarded' end end as ApplensOnboarded,
DET.DebtEnabled,
'Show Project Hierarchy' as [Show Hierarchy],
CASE WHEN ( A.Archetype is null and ((SF.SumFTE < 5 OR SF.SumFTE is null) or  P.BillabilityType ='NBL' or P.ProjectType='EXANT'))
 and (SF.SumFTE < 5 OR SF.SumFTE is null) then 'FTE < 5'
 WHEN (A.Archetype is null and ((SF.SumFTE < 5 OR SF.SumFTE is null) or  P.BillabilityType ='NBL' or P.ProjectType='EXANT'))
 and P.BillabilityType ='NBL'then 'Non Billable' 
 WHEN (A.Archetype is null and ((SF.SumFTE < 5 OR SF.SumFTE is null) or  P.BillabilityType ='NBL' or P.ProjectType='EXANT'))
 and P.ProjectType='EXANT' then 'External Anticipated Project' end as [PP Not Mandated],
 CASE WHEN ((AED.IsApplensExempt is null and CP.[ScreenID] is null) and 
(SF.SumFTE < 5 OR SF.SumFTE is null)) then 'FTE < 5'
 WHEN ((AED.IsApplensExempt is null and CP.[ScreenID] is null) and  
 P.BillabilityType ='NBL') then 'Non Billable'
 WHEN ((AED.IsApplensExempt is null and CP.[ScreenID] is null)  and
P.ProjectType='EXANT') then 'External Anticipated Project'
WHEN ((AED.IsApplensExempt is null and CP.[ScreenID] is null)  and
 (DS.[DE_Scope] = 'Not in scope' )) then 'DE Not in scope'
 WHEN ((AED.IsApplensExempt is null and CP.[ScreenID] is null)  and
 (DS.[DE_Scope] = 'Yet to scope') ) then 'DE Yet to scope'
  WHEN ((AED.IsApplensExempt is null and CP.[ScreenID] is null) and
 DS.[Is Performance data Sharing restricted as per contract] = 'Yes') then 'Data Sharing Restricted'
 WHEN ((AED.IsApplensExempt is null and CP.[ScreenID] is null) and
(datediff(day,DATEADD(MINUTE,30,DATEADD(HOUR,5,Project_Ported_Date)),DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())))) < 30) then '30 Days Holiday Period' end as ApplensNotMandated,
CASE WHEN ((DET.DebtEnabled='Not Applicable') 
and (SF.SumFTE<5 or SF.SumFTE is null)) then 'FTE < 5'
 WHEN ((DET.DebtEnabled='Not Applicable')and
( P.BillabilityType ='NBL')) then 'Non Billable'
 WHEN ((DET.DebtEnabled='Not Applicable') and
(P.ProjectType='EXANT')) then 'External Anticipated Project'
WHEN ((DET.DebtEnabled='Not Applicable')and
 (DS.[DE_Scope] = 'Not in scope' )) then 'DE Not in scope'
 WHEN ((DET.DebtEnabled='Not Applicable') and
 (DS.[DE_Scope] = 'Yet to scope' )) then 'DE Yet to scope'
 WHEN ((DET.DebtEnabled='Not Applicable')and
PT.ProjectType in('AD','Others','NA')) then 'AD/NA/Other Projects'
 WHEN ((DET.DebtEnabled='Not Applicable')  and
DS.[Is Performance data Sharing restricted as per contract] = 'Yes') then 'Data Sharing Restricted'
 WHEN ((DET.DebtEnabled='Not Applicable') and
(datediff(day,DATEADD(MINUTE,30,DATEADD(HOUR,5,Project_Ported_Date)),DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())))) < 30)then '30 Days Holiday Period'
end as DebtNotApplicable,
TC.ThresholdCount as 'Pattern Frequency Threshold'
from AVL.MAS_ProjectMaster(NOLOCK)  Proj 
left join [SumFTECount] SF ON SF.ProjectID=Proj.ESAProjectID
LEFT JOIN [TicketItem] TI ON TI.ProjectID=Proj.ProjectID
left join AVL.MAS_ProjectDebtDetails (NOLOCK) PDD ON PDD.ESAProjectID=Proj.ESAProjectID
left join AVL.PRJ_ConfigurationProgress(NOLOCK) CP ON CP.ProjectID=Proj.ProjectID and ScreenID = 4
AND CompletionPercentage = 100
left join [ApplensExemptionDetails]  AED ON AED.ProjectID=Proj.ESAProjectID
left JOIN [DebtExemptionDetails] DED ON DED.EsaProjectID=Proj.ESAProjectID
left JOIN ESA.Projects (NOLOCK) P ON P.ID=Proj.ESAProjectID
----left join AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.ESAProjectID=Proj.ESAProjectID
left JOIN [WorkItem] WI ON WI.ProjectID=Proj.ProjectID
--LEFT JOIN [TicketItem] TI ON TI.ProjectID=Proj.ProjectID
left Join [Archetype] A ON A.ProjectID=Proj.ProjectID
left Join [DEScope] DS ON DS.ESA_Project_ID=Proj.ESAProjectID
left Join [Projecttype] PT ON PT.ProjectID=Proj.ESAProjectID
left Join [DebtEnabled] DET ON DET.ProjectID=Proj.ESAProjectID
left Join [Threshold]TC ON TC.EsaProjectID=Proj.EsaProjectID
WHERE Proj.Isdeleted=0  and DATEADD(MINUTE,30,DATEADD(HOUR,5,Proj.ProjectEndDate))>=DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))
