
--EXEC [ML].[GetMailerDetails] 'IL_Clustering_Services',26
CREATE PROCEDURE [ML].[GetMailerDetails]
(@JobName NVARCHAR(200),
@Id BIGINT
)
AS
BEGIN
DECLARE @ToUsers NVARCHAR(MAX);


DECLARE @JobId BIGINT = (SELECT JobId FROM MAS.JobMaster(NOLOCK) where JobName=@JobName AND IsDeleted = 0)

DECLARE @TransactionId BIGINT = (SELECT DISTINCT TransactionId  FROM TrackDetails(NOLOCK) where Id = @Id AND IsDeleted = 0)

SELECT DISTINCT CreatedBy,ProjectId,TransactionId  INTO #ToUsers FROM ML.TRN_MLTransaction(NOLOCK) WHERE TransactionId = @TransactionId

IF (@JobName = 'IL_Classification_Services' OR @JobName = 'IL_Clustering_Services')
BEGIN
	SELECT DISTINCT EA.AssociateId, EA.AssociateName,EA.Email,PM.ProjectId, PM.ProjectName, TU.TransactionId
	FROM ESA.Associates(NOLOCK) EA
	JOIN #ToUsers(NOLOCK) TU
	ON TU.CreatedBy = EA.AssociateID AND EA.IsActive = 1
	JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
	ON PM.ProjectId = TU.ProjectId AND PM.IsDeleted = 0
END
ELSE
BEGIN

  SELECT DISTINCT EA.AssociateId, EA.AssociateName,EA.Email,PM.ProjectId, PM.ProjectName, TU.TransactionId
  FROM RLE.VW_ProjectLevelRoleAccessDetails PL(NOLOCK)     
  JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
  ON PM.ESAProjectId = PL.ESAProjectId AND PM.IsDeleted = 0
  JOIN #ToUsers (NOLOCK) TU
  ON TU.ProjectId = PM.ProjectID 
  JOIN ESA.Associates(NOLOCK) EA
  ON PL.Associateid = EA.AssociateID AND EA.IsActive = 1
  WHERE RoleKey in ('RLE003' ) --AND EA.AssociateId IN('674078','2038108')


END

END


