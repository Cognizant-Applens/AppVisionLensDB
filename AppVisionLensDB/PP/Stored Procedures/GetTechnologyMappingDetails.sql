/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetTechnologyMappingDetails] --1230511
	@AccountId varchar(50),
	@IsEmpty BIT,
	@AppList Nvarchar(max)
AS
BEGIN
begin try
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

set @AccountId = (select Esa_AccountID  from avl.Customer where CustomerID = @AccountId)

IF @IsEmpty = 1
BEGIN
SELECT '' [Application Name],'' [Infra Type],'' [Infra Details],'' [Version],'' AS [Infra Detail Others],'' [Version Others],'' AS [Delete],'' Remarks
	,'' AS [Error Description],'' ApplicationId
END
ELSE
BEGIN
SELECT * INTO #TmpApp FROM(
SELECT Distinct ApplicationId, ApplicationName
	FROM OPENJSON(@AppList)
	 WITH (
			ApplicationId bigint '$.ApplicationId',
			ApplicationName Nvarchar(250) '$.ApplicationName'
)T)T
SELECT
	App.ApplicationName [Application Name]
	,IT.InfraTypeName [Infra Type]
	,ID.InfraDetailName [Infra Details]
	,IV.InfraVersionName [Version]
	,'' AS [Infra Detail Others]
	,'' [Version Others]
	,'' AS [Delete]
	,A.Remarks
	,'' AS [Error Description]
	,A.ApplicationId
	--,@AccountId as AccountId
FROM PP.TechnologyMappingTransaction(NOLOCK) A
INNER JOIN pp.MasterTableOfEOLDetails(NOLOCK) B ON A.EolId=B.Id
INNER JOIN pp.TechCurrencyInfraType(NOLOCK) IT ON B.InfraTypeId=IT.InfraTypeId
INNER JOIN pp.TechCurrencyInfraDetail(NOLOCK) ID ON B.InfraDetailId =ID.InfraDetailId
INNER JOIN pp.TechCurrencyInfraVersion(NOLOCK) IV ON B.InfraVersionId=IV.InfraVersionId
INNER JOIN #TmpApp App ON A.ApplicationId=App.ApplicationId
WHERE A.AccountId = @AccountId AND A.IsDeleted=0 AND B.IsDeleted=0 AND IT.IsDeleted=0
AND ID.IsDeleted=0 AND IV.IsDeleted=0 
END
--select ApplicationId,ApplicationName, ApplicationShortName
--  from #applensApps ORDER BY ApplicationName ASC


SELECT DISTINCT
	InfraTypeName
FROM TechcurrencyInfraType(nolock) where IsDeleted=0

SELECT IT.InfraTypeName, ID.InfraDetailName, IV.InfraVersionName
FROM  pp.MasterTableOfEOLDetails(NOLOCK) B
INNER JOIN pp.TechCurrencyInfraType(NOLOCK) IT ON B.InfraTypeId=IT.InfraTypeId
INNER JOIN pp.TechCurrencyInfraDetail(NOLOCK) ID ON B.InfraDetailId =ID.InfraDetailId
INNER JOIN pp.TechCurrencyInfraVersion(NOLOCK) IV ON B.InfraVersionId=IV.InfraVersionId
WHERE B.IsDeleted=0 AND IT.IsDeleted=0
AND ID.IsDeleted=0 AND IV.IsDeleted=0 AND B.IsUserCreated = 0
UNION
SELECT IT.InfraTypeName, ID.InfraDetailName, IV.InfraVersionName
FROM TechnologyMappingTransaction(NOLOCK) A
INNER JOIN pp.MasterTableOfEOLDetails(NOLOCK) B ON A.EolId=B.Id
INNER JOIN pp.TechCurrencyInfraType(NOLOCK) IT ON B.InfraTypeId=IT.InfraTypeId
INNER JOIN pp.TechCurrencyInfraDetail(NOLOCK) ID ON B.InfraDetailId =ID.InfraDetailId
INNER JOIN pp.TechCurrencyInfraVersion(NOLOCK) IV ON B.InfraVersionId=IV.InfraVersionId
WHERE A.AccountId = @AccountId AND A.IsDeleted=0 AND B.IsDeleted=0 AND IT.IsDeleted=0
AND ID.IsDeleted=0 AND IV.IsDeleted=0 AND B.IsUserCreated = 1
Order By IT.InfraTypeName, ID.InfraDetailName, IV.InfraVersionName ASC

SELECT CustomerID AS AccountId  from AVL.Customer where ESA_AccountID = @AccountId


END TRY BEGIN CATCH
	  DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
       --INSERT Error     
       EXEC AVL_INSERTERROR  '[PP].[GetTechnologyMappingDetails]', @ErrorMessage,  0, 
        0 
END CATCH
END
