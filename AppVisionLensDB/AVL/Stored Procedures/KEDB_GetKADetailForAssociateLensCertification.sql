CREATE  PROCEDURE [AVL].[KEDB_GetKADetailForAssociateLensCertification]
(        
@startDate date,
@endDate date
 ) 
	 
AS
BEGIN
	 
	 BEGIN TRY
	SET NOCOUNT ON;

SELECT  
 'Creation of KEDB articles' as Category
,'The Ultimate Contributor' as Award
,ka.KATicketID, ka.CreatedBy as Employeeid
,pm.EsaProjectID, pm.ProjectName 
 

,DATENAME(month,awl.CreatedOn) as  ApprovedMonth 
,DATENAME(year,awl.CreatedOn) as ApprovedYear 
,awl.CreatedOn as ApprovedDate   

FROM [AVL].[KEDB_TRN_KATicketDetails] ka 
JOIN [AVL].[KEDB_AuditWorkLog] Awl 
	on Awl.kaid = ka.kaid and awl.ProjectId = ka.ProjectId and (awl.Action = 'Approved' OR awl.Action='Submitted')
JOIN [AVL].[MAS_ProjectMaster] pm 
	on pm.projectid = ka.projectid and pm.IsDeleted = 0
where ka.IsDeleted = 0  AND (KA.status = 'Approved' OR KA.status='Submitted')
and awl.createdon between @startDate and @endDate


END try

BEGIN CATCH

	DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()

	--INSERT Error    
	EXEC AVL_InsertError '[AVL].[KEDB_GetKADetailForAssociateLensCertification]', @ErrorMessage, 0,0


	END CATCH

END