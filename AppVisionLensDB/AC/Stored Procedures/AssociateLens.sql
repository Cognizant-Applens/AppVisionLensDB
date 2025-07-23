CREATE PROCEDURE [AC].[AssociateLens]
AS BEGIN
SELECT DISTINCT EASA.AssociateName, ALC.CertificationId, ALC.CategoryId,ALC.AwardId, ALC.EmployeeId,ALC.AccountId,
ALC.EsaProjectId,ALC.ProjectID,
ALC.Designation,ALC.CertificationMonth	,ALC.CertificationYear	,ALC.NoOfATicketsClosed,ALC.NoOfHTicketsClosed,
ALC.IncReductionMonth,ALC.EffortReductionMonth,ALC.SolutionIdentified,ALC.NoOfKEDBCreatedApproved,
ALC.NoOfCodeAssetContributed,ALC.Isdeleted,
DATEADD(MINUTE,30,DATEADD(HOUR,5,ALC.CreatedDate)) AS CreatedDate,ALC.CreatedBy,
DATEADD(MINUTE,30,DATEADD(HOUR,5,ALC.ModifiedDate)) AS ModifiedDate,ALC.ModifiedBy,ALC.IsRated
from AC.[TRN_Associate_Lens_Certification] (NOLOCK) ALC 
LEFT JOIN ESA.Associates (NOLOCK) EASA ON EASA.Associateid=ALC.EmployeeId AND ALC.ISDeleted=0
END


