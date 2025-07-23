/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[InsertUpdateTemplateMappingTransaction]
	@AccountId varchar(50),
	@UserId Nvarchar(50),
	@JsonTemplateData NVARCHAR(MAX)
AS
BEGIN
begin try
begin tran


SET NOCOUNT ON;

SET @AccountId = (SELECT Esa_AccountID FROM avl.Customer WHERE CustomerID = @AccountId)
DECLARE	@Result INT
--Declare @txt nvarchar(max) ='[{"ApplicationId":"68866","ApplicationName":"AWT-ACCESS","InfraType":"Data \u0026 Analytics","InfraDetails":"Others","Version":"Others","InfraDetailOthers":"SQL","VersionOthers":"2016","Delete":null,"Remarks":null,"ErrorDescription":null},{"ApplicationId":"68867","ApplicationName":"AWT-ACCESS-UK","InfraType":"Data \u0026 Analytics","InfraDetails":"SQL Server Reporting Service","Version":"2016","InfraDetailOthers":null,"VersionOthers":null,"Delete":null,"Remarks":null,"ErrorDescription":null}]'

SELECT * INTO #TEMPLATEDATA FROM(
SELECT *, CAST(0 as BIT) as isUserCreated, CAST(0 AS int) AS InfraTypeId, CAST(0 AS int) AS InfraDetailId, CAST(0 AS int) AS InfraVersionId, CAST(0 AS int) AS EOLId
	FROM OPENJSON(@JsonTemplateData)
	 WITH (
			ApplicationId BIGINT '$.ApplicationId',
			ApplicationName VARCHAR(250) '$.ApplicationName',
			InfraType NVARCHAR(250) '$.InfraType',
			InfraDetails NVarchar(250) '$.InfraDetails',
			InfraVersion NVarchar(250) '$.Version',
			InfraDetailOthers Varchar(250) '$.InfraDetailOthers',
			VersionOthers NVarchar(250) '$.VersionOthers',
			Deleted varchar(10) '$.Delete',
			Remarks VARCHAR(max) '$.Remarks',
			ErrorDescription VARCHAR(max) '$.ErrorDescription'
		  )T
)T

--select * from #TEMPLATEDATA InfraDetails

UPDATE #TEMPLATEDATA SET InfraDetails=Ltrim(Rtrim(InfraDetailOthers)) WHERE InfraDetails ='Others'
UPDATE #TEMPLATEDATA SET InfraVersion=Ltrim(Rtrim(VersionOthers)) WHERE InfraVersion ='Others'

--Start Insert New InfraDetail
Select * into #InfraDetail from(
Select  distinct InfraDetails from #TEMPLATEDATA where isnull(Deleted, '') ='' 
)t

UPDATE A SET A.IsDeleted =0, A.ModifiedBy = @UserId, A.ModifiedDate=GETDATE() from TechCurrencyInfraDetail A
INNER JOIN #InfraDetail B ON A.InfraDetailName=B.InfraDetails

Delete A from #InfraDetail A
INNER JOIN PP.TechCurrencyInfraDetail(nolock) B ON A.InfraDetails=B.InfraDetailName

INSERT INTO PP.TechCurrencyInfraDetail(InfraDetailName, IsUserDefined, IsDeleted, CreatedBy, CreatedDate)
SELECT InfraDetails, 1, 0, @UserId, GETDATE() FROM #InfraDetail
--END Insert New InfraDetail

--Start Insert New InfraVersion
Select * into #InfraVersion from(
Select  distinct InfraVersion from #TEMPLATEDATA where isnull(Deleted, '') ='' 
)t

UPDATE A SET A.IsDeleted =0, A.ModifiedBy = @UserId, A.ModifiedDate=GETDATE() from TechCurrencyInfraVersion A
INNER JOIN #InfraVersion B ON A.InfraVersionName=B.InfraVersion

Delete A from #InfraVersion A
INNER JOIN PP.TechCurrencyInfraVersion(nolock) B ON A.InfraVersion=B.InfraVersionName

INSERT INTO PP.TechCurrencyInfraVersion(InfraVersionName, IsUserDefined, IsDeleted, CreatedBy, CreatedDate)
SELECT InfraVersion, 1, 0, @UserId, GETDATE() FROM #InfraVersion
--ENd Insert New InfraVersion

--Update Master Ids
Update A  SET A.InfraTypeId=B.InfraTypeId FROM #TEMPLATEDATA A
INNER JOIN PP.TechCurrencyInfraType(NOLOCK) B ON A.InfraType=B.InfraTypeName

Update A  SET A.InfraDetailId=B.InfraDetailId FROM #TEMPLATEDATA A
INNER JOIN PP.TechCurrencyInfraDetail(NOLOCK) B ON A.InfraDetails=B.InfraDetailName

Update A  SET A.InfraVersionId=B.InfraVersionId FROM #TEMPLATEDATA A
INNER JOIN PP.TechCurrencyInfraVersion(nolock) B ON A.InfraVersion=B.InfraVersionName

--Add Master Mapping Table
Select * into #MasterMapping from(
Select  distinct InfraTypeId, InfraDetailId, InfraVersionId from #TEMPLATEDATA where isnull(Deleted, '') ='' 
)t

Delete FROM #MasterMapping Where InfraTypeId =0 OR InfraDetailId = 0 AND  InfraVersionId = 0

--UPDATE A SET A.IsDeleted =0, A.ModifiedBy = @UserId, A.ModifiedOn=GETDATE() from MasterTableOfEOLDetails A
--INNER JOIN #MasterMapping B ON A.InfraTypeId=B.InfraTypeId and A.InfraDetailId=B.InfraDetailId and A.InfraVersionId=B.InfraVersionId

Delete A from #MasterMapping A
INNER JOIN PP.MasterTableOfEOLDetails(NOLOCK) B ON A.InfraTypeId=B.InfraTypeId and A.InfraDetailId=B.InfraDetailId and A.InfraVersionId=B.InfraVersionId
WHERE B.IsDeleted=0

INSERT INTO MasterTableOfEOLDetails(InfraTypeId, InfraDetailId, InfraVersionId, IsUserCreated, IsDeleted, CreatedBy, CreatedDate)
SELECT InfraTypeId, InfraDetailId, InfraVersionId, 1, 0, @UserId, GETDATE() FROM #MasterMapping

-- Update Mapping Table Id
UPDATE A SET A.EOLId=B.ID from #TEMPLATEDATA A
INNER JOIN PP.MasterTableOfEOLDetails(nolock)  B ON A.InfraTypeId=B.InfraTypeId and A.InfraDetailId=B.InfraDetailId and A.InfraVersionId=B.InfraVersionId
WHERE B.IsDeleted=0

--Add Master Mapping Table
UPDATE A SET A.Remarks=B.Remarks, A.ModifiedBy=@UserId, A.ModifiedDate=GETDATE() from PP.TechnologyMappingTransaction A
INNER JOIN #TEMPLATEDATA  B ON A.EolId=B.EOLId and A.ApplicationId=B.ApplicationId
where ISNULL(Deleted, '') ='' And A.IsDeleted=0

UPDATE A SET A.IsDeleted = 1, A.Remarks=B.Remarks, A.ModifiedBy=@UserId, A.ModifiedDate=GETDATE() from PP.TechnologyMappingTransaction A
INNER JOIN #TEMPLATEDATA  B ON A.EolId=B.EOLId and A.ApplicationId=B.ApplicationId
where ISNULL(Deleted, '') <>'' And A.IsDeleted=0

DELETE A from #TEMPLATEDATA  A
INNER JOIN PP.TechnologyMappingTransaction  B ON A.EOLId=B.EolId and A.ApplicationId=B.ApplicationId
WHERE B.IsDeleted=0

DELETE FROM #TEMPLATEDATA WHERE ISNULL(Deleted, '') <>'' 

INSERT INTO PP.TechnologyMappingTransaction(ApplicationId, AppicationName,EolId, AccountId, CreatedBy, CreatedDate, isDeleted)
SELECT DISTINCT ApplicationId, ApplicationName,EOLId, @AccountId, @UserId, GETDATE(), 0
FROM  #TEMPLATEDATA

UPDATE A SET A.Remarks=B.Remarks from PP.TechnologyMappingTransaction A
INNER JOIN #TEMPLATEDATA  B ON A.EolId=B.EOLId and A.ApplicationId=B.ApplicationId
where A.IsDeleted=0

--to be remove once twb update api

UPDATE EOL SET EOL.ProductType=IT.InfraTypeName, EOL.ProductName=ID.InfraDetailName, EOL.version=IV.InfraVersionName 
FROM PP.MasterTableOfEOLDetails EOL
INNER JOIN PP.TechCurrencyInfraType(NOLOCK) IT ON EOL.InfraTypeId =IT.InfraTypeId
INNER JOIN PP.TechCurrencyInfraDetail(NOLOCK) ID ON EOL.InfraDetailId =ID.InfraDetailId
INNER JOIN PP.TechCurrencyInfraVersion(NOLOCK) IV ON EOL.InfraVersionId =IV.InfraVersionId
WHERE ISNULL(EOL.ProductType,'') =''

UPDATE TMT SET TMT.ProductType=IT.InfraTypeName, TMT.Product=ID.InfraDetailName, TMT.version=IV.InfraVersionName 
FROM PP.TechnologyMappingTransaction TMT
INNER JOIN PP.MasterTableOfEOLDetails(NOLOCK) EOL ON TMT.EolId = EOL.Id
INNER JOIN PP.TechCurrencyInfraType(NOLOCK) IT ON EOL.InfraTypeId =IT.InfraTypeId
INNER JOIN PP.TechCurrencyInfraDetail(NOLOCK) ID ON EOL.InfraDetailId =ID.InfraDetailId
INNER JOIN PP.TechCurrencyInfraVersion(NOLOCK) IV ON EOL.InfraVersionId =IV.InfraVersionId
WHERE ISNULL(TMT.ProductType,'') =''

--to end


SET @Result =1

COMMIT TRAN
DROP Table #InfraDetail
DROP TABLE #InfraVersion
Drop Table #MasterMapping

RETURN @Result 
END TRY
BEGIN CATCH
ROLLBACK TRAN
INSERT INTO Error_Log(Exception, MethodName) VALUES(ERROR_MESSAGE(), 'INSERT TECH CURRENCY DETAILS');
--SET @Result =0
--RETURN @Result
END CATCH
END
