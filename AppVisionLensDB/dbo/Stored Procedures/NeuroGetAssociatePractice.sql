
CREATE PROCEDURE [dbo].[NeuroGetAssociatePractice]
AS BEGIN 
INSERT INTO [CTSC01165018101].[ITOpsAssessment].[dbo].[NeuroAssociatePractise]
select a.Project_ID as projectID,b.Project_Small_Desc as projectname,
b.ACCOUNT_ID AS AccountID,b.ACCOUNT_NAME as AccountName,
PA.ParentAccountID,PA.ParentAccount,
a.Associate_ID,c.Associate_Name,a.Allocation_Start_Date,a.Allocation_End_Date,
a.Allocation_Percentage,a.Grade,a.Offshore_Onsite,c.Dept_Name,c.Supervisor_ID,c.Supervisor_Name,
b.Status as projectstatus,a.Assignment_Status
--CRS.Practiceid as 'CRS Practice',
from [CPCINCHPV004140].[$(AVMCOEESADB)].[dbo].[CentralRepository_Allocation] a (NOLOCK)
join [CPCINCHPV004140].[$(AVMCOEESADB)].[dbo].[GMSPMO_Project] b (NOLOCK)on b.Project_ID = a.Project_ID
join [CPCINCHPV004140].[$(AVMCOEESADB)].[dbo].[GMSPMO_Associate] c (NOLOCK) on c.Project_ID = b.Project_ID AND c.Associate_ID=a.Associate_ID
JOIN [CPCINCHPV004140].[$(AVMCOEESADB)].[dbo].[MigratedParentAccounts] PA (NOLOCK) ON PA.AccountID = b.ACCOUNT_ID
where c.Assignment_Status ='A'
END
