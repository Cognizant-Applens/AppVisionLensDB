/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[Debt_GetIdentificationDetails]  
(
	@CustomerID INT,
	@UserID nvarchar(50),
	@ProjectID INT
)
AS
BEGIN
BEGIN TRY
DECLARE @SupportTypeId INT;
DECLARE @ScopeCount INT;
SET @ScopeCount = (Select count(1) from [PP].[ProjectAttributeValues]  where ProjectID=@ProjectID  and Attributeid=1 and attributevalueid in (2,3) and Isdeleted = 0)
if(@ScopeCount =2)
Begin
Set @SupportTypeId =3
End
Else Begin
Select @SupportTypeId = case when Attributevalueid =2 then 1 when Attributevalueid =3 then 2 end from [PP].[ProjectAttributeValues]  where ProjectID=@ProjectID  and Attributeid=1 and attributevalueid in (2,3) and Isdeleted = 0
End


	DECLARE @ISTicketDescription NVARCHAR(10) ='N'
	IF EXISTS(SELECT 1 FROM AVL.ITSM_PRJ_SSISColumnMapping (NOLOCK) WHERE ProjectID =@ProjectID AND IsDeleted=0 
	AND (ServiceDartColumn = 'TicketDescription' OR ServiceDartColumn = 'Ticket Description'))
	BEGIN
		SET @ISTicketDescription = 'Y'
	END
	ELSE
	BEGIN
		SET @ISTicketDescription = 'N'
	END

	DECLARE @CLEffectiveDate DATETIME = NULL, @ILSignOffDate DATETIME = NULL, @StartDateTime DATETIME = NULL

	SELECT TOP 1 @CLEffectiveDate = JobDate, @StartDateTime = StartDateTime 
	FROM ML.CL_ProjectJobDetails (NOLOCK)  CL 
	WHERE CL.ProjectID = @ProjectID AND CL.IsDeleted = 0
    
	IF (@CLEffectiveDate is null OR @CLEffectiveDate = '')
	  BEGIN
	   SELECT @ILSignOffDate=MLSignOffDate FROM  AVL.MAS_ProjectDebtDetails (NOLOCK)  PDD WHERE PDD.ProjectID = @ProjectID AND PDD.IsDeleted = 0
	     IF (@ILSignOffDate IS NOT NULL AND @ILSignOffDate <> '')
		   BEGIN
			 --DECLARE @day int
    --         SET @day = (SELECT DATEPART(dd, @ILSignOffDate));
    --         IF(@day<=10)
    --          BEGIN
    --           SET @CLEffectiveDate=@ILSignOffDate
    --          END
    --         ELSE
    --          BEGIN
    --           SET @CLEffectiveDate=@ILSignOffDate
    --          END
			  UPDATE ML.CL_ProjectJobDetails SET JobDate=@ILSignOffDate WHERE ProjectID=@ProjectID AND IsDeleted=0
		   END
	  END

	DECLARE @DDCount INT
	SELECT @DDCount = COUNT(1) from avl.Debt_MAS_ProjectDataDictionary (NOLOCK)  where ProjectID = @ProjectID AND EffectiveDate IS NOT NULL

	 SELECT TOP 1 
	 (SELECT [AVL].[GetBlendedRateByProjectSupportTypeId](@ProjectID,CASE WHEN @SupportTypeId = 1 OR @SupportTypeId = 3 THEN 1 ELSE 0 END)) AS BlendedRate
	,(SELECT [AVL].[GetBlendedRateByProjectSupportTypeId](@ProjectID,CASE WHEN @SupportTypeId = 2 OR @SupportTypeId = 3 THEN 2 ELSE 0 END)) AS InfraBlendedRate
	,PDD.IsAutoClassified AS IsMLSignOff
	,PDD.MLSignOffDate
	,PDD.IsAutoClassified
	,PDD.AutoClassificationDate
	,PDD.ManualDate
	,PDD.IsDDAutoClassified
	,PDD.IsDDAutoClassifiedDate
	,CU.IsEffortConfigured 
	,PDD.IsManual AS IsDebtEnabled
	,PDD.IsCostTracked
	,PDD.IsTicketApprovalNeeded
	,Isnull(@SupportTypeId,0) as SupportTypeId
	,PDD.MLSignOffDateInfra
	,PDD.IsAutoClassifiedInfra
	,PDD.IsAutoClassifiedInfra AS IsMLSignOffInfra
	--,CASE WHEN IL.IsSamplingSentOrReceived = 'Received' AND IL.IsMLSentOrReceived IS NULL THEN 'Pending Sampling' 
	 --WHEN IL.IsMLSentOrReceived = 'Received' AND PDD.IsMLSignOff IS NULL OR PDD.IsMLSignOff = '0' THEN 'Pending Initial Review'
	 ,CASE WHEN PDD.IsAutoClassified='Y' AND PDD.IsMLSignOff IS NULL OR PDD.IsMLSignOff = '0' THEN 'Pending Review'
	 WHEN PDD.IsMLSignOff = '1' THEN 'Active' 
	 ELSE '-' END AS MLStatusName
	 ,CASE WHEN PDD.IsAutoClassifiedInfra='Y' AND PDD.IsMLSignOffInfra IS NULL OR PDD.IsMLSignOffInfra = '0' THEN 'Pending Review'
	 WHEN PDD.IsMLSignOffInfra = '1' THEN 'Active' 
	 ELSE '-' END AS MLStatusNameInfra,
	 CASE WHEN pdd.IsDDAutoClassified = 'Y' and (((PDD.IsDDAutoClassifiedDate IS NOT NULL AND @DDCount = 0) OR (PDD.IsDDAutoClassifiedDate IS NULL AND @DDCount > 0)) OR (PDD.IsDDAutoClassifiedDate IS NULL AND @DDCount = 0)) THEN 'Pending Review' 
	 WHEN PDD.IsDDAutoClassifiedDate IS NOT NULL AND @DDCount > 0 THEN 'Active'
	 ELSE '-' END AS DDStatusName,
	 @ISTicketDescription AS ISTicketDescription,
	 PM.IsDebtEnabled AS DebtEnabled,
	 PDD.DebtEnablementDate AS DebtDate,
	 PDD.ISCLSIGNOFF AS 'IsCLSignOff',
	 PDD.CLSIGNOFFDATE AS 'CLSignOffDate',
	 CL.JobDate AS 'CLEffectiveDate',
	 PDD.IsCLAutoClassified AS 'IsCLAutoClassified',
	 PFP.TileProgressPercentage as CompletionPercentage,
	 PDD.OptionalAttributeType
	 FROM 
	AVL.Customer CU  	
	LEFT JOIN AVL.MAS_ProjectMaster (NOLOCK)  PM ON CU.CustomerID = PM.CustomerID AND PM.IsDeleted = 0 AND CU.IsDeleted = 0 
	LEFT JOIN AVL.MAS_ProjectDebtDetails (NOLOCK)  PDD ON PDD.ProjectID = PM.ProjectID AND CU.IsDeleted = 0	
	LEFT JOIN AVL.ML_PRJ_InitialLearningState (NOLOCK)  IL ON IL.ProjectID = PM.ProjectID AND IL.IsDeleted = 0
    LEFT JOIN ML.CL_ProjectJobDetails (NOLOCK)  CL ON CL.ProjectID=PDD.ProjectID AND CL.IsDeleted=0
	LEFT JOIN PP.ProjectProfilingTileProgress (NOLOCK)  PFP ON PDD.ProjectID = PFP.ProjectID AND PFP.TileID = 10 AND PFP.IsDeleted = 0
	WHERE CU.CustomerID = @CustomerID and PM.projectid=@ProjectID
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Debt_GetIdentificationDetails]', @ErrorMessage, @UserID,@CustomerID
		
	END CATCH  

END
