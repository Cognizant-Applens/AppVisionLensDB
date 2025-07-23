/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/



CREATE PROCEDURE [dbo].[GetAppInventoryTempdetailDynamic_PP]  
	@CustomerId int =NULL
AS
BEGIN
	BEGIN TRY
	SET NOCOUNT ON;
	IF OBJECT_ID('tempdb..#tempT') IS NOT NULL DROP TABLE #tempT 
DECLARE @isCognizant int=0;
IF @CustomerId IS NOT NULL
BEGIN
SELECT @isCognizant=IsCognizant from avl.Customer WHERE CustomerID=@CustomerID;
END
--Unique ApplicationName check for a customer

SELECT Count(ApplicationName) AS AppCount,ApplicationName,CustomerId INTO #AppInventoryUpload FROM MAS.AppInventoryUpload WHERE [CustomerId] =@CustomerId
GROUP BY
    ApplicationName,CustomerId
HAVING 
    COUNT(ApplicationName) > 1

UPDATE A  SET A.IsValid='D'
FROM #AppInventoryUpload T JOIN MAS.AppInventoryUpload A
ON A.ApplicationName=T.ApplicationName AND A.CustomerId=@CustomerId AND T.CustomerId=@CustomerId
WHERE T.AppCount <> 0

--SELECT * FROM MAS.AppInventoryUpload
--SELECT * FROM #AppInventoryUpload
DROP TABLE #AppInventoryUpload
 
--ApplicationName
	 Update MAS.AppInventoryUpload set IsValid = 'N'         
	 where [CustomerId] =@CustomerId       
	and ([ApplicationName] is null or [ApplicationName]='') 

--ApplicationShortName
	UPDATE MAS.AppInventoryUpload set IsValid = 'N'
	 where [CustomerId] =@CustomerId       
	and (ApplicationShortName is null or ApplicationShortName='') 

--SubBusinessCluster Name
	UPDATE MAS.AppInventoryUpload set IsValid = 'N'
	 where [CustomerId] =@CustomerId       
	and (BusinessClusterName is null or BusinessClusterName='' OR BusinessClusterName 
	NOT IN  (SELECT 
					BC.BusinessClusterBaseName
			FROM
					AVL.BusinessClusterMapping BC
					WITH(NOLOCK)

			WHERE
					BC.Isdeleted=0 
			AND
					BC.CustomerID=@CustomerId
			AND	
					BC.BusinessClusterID IS NOT NULL
			AND 
					BC.ParentBusinessClusterMapID IS NOT NULL
			AND
					BC.IsHavingSubBusinesss=0)) 

--CodeOwnerShip
	UPDATE MAS.AppInventoryUpload set IsValid = 'N'
	 where [CustomerId] =@CustomerId       
	and (CodeOwnerShip is null or CodeOwnerShip='' Or CodeOwnerShip NOT IN (
	SELECT 
						
						OD.ApplicationTypename
				FROM
						AVL.APP_MAS_OwnershipDetails OD
						WITH(NOLOCK)
				WHERE
						OD.IsDeleted=0))

--BusinessCriticalityName
	UPDATE MAS.AppInventoryUpload set IsValid = 'N'
	 where [CustomerId] =@CustomerId       
	and (BusinessCriticalityName is null or BusinessCriticalityName=''
	or BusinessCriticalityName NOT IN (SELECT 
						BC.BusinessCriticalityName
				FROM
						AVL.APP_MAS_BusinessCriticality BC
						WITH(NOLOCK)
				WHERE
						BC.IsDeleted=0))

--PrimaryTechnologyName
	UPDATE MAS.AppInventoryUpload set IsValid = 'N'
	 where [CustomerId] =@CustomerId       
	and (PrimaryTechnologyName is null or PrimaryTechnologyName='' or 
	PrimaryTechnologyName NOT IN (SELECT 
							PT.PrimaryTechnologyName
					FROM
							AVL.APP_MAS_PrimaryTechnology PT
							WITH(NOLOCK)
					WHERE 
							PT.IsDeleted=0))

--ProductMarketName#
	UPDATE MAS.AppInventoryUpload set IsValid = 'N'
	where [CustomerId] =@CustomerId  AND CodeOwnerShip IN('COTS','COTS modified')     
	and (ProductMarketName is null or ProductMarketName='') 
		

   UPDATE MAS.AppInventoryUpload set IsValid = 'N'
   WHERE [CustomerId] =@CustomerId
   AND LOWER(LTRIM(RTRIM(ProductMarketName))) IN(SELECT LOWER(LTRIM(RTRIM(ExcludedWordName))) FROM MAS.ExcludedWords)


--ApplicationDescription
		UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId     
		and (ApplicationDescription is null or ApplicationDescription='')

--ApplicationCommisionDate
		UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId     
		and (ApplicationCommisionDate is null or ApplicationCommisionDate='')


--RegulatoryCompliantName
		UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId     
		and (RegulatoryCompliantName is null or RegulatoryCompliantName='' OR 
		RegulatoryCompliantName NOT IN (
		SELECT 
						RC.RegulatoryCompliantName
				FROM
						AVL.APP_MAS_RegulatoryCompliant RC
						WITH(NOLOCK)
				WHERE
						RC.IsDeleted=0))
 
/*DebtcontrolScopeName*/
IF EXISTS(SELECT CustomerScreenMapID FROM AVL.MAP_CustomerScreenMapping WHERE CustomerID = @CustomerID AND ScreenID = 5)
BEGIN
		UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId     
		and (DebtcontrolScopeName is null or DebtcontrolScopeName='' AND DebtcontrolScopeName
		NOT IN (SELECT 
						DS.DebtcontrolScopeName
				FROM
						AVL.APP_MAS_DebtcontrolScope DS
						WITH(NOLOCK)
				WHERE
						DS.IsDeleted=0))
						END

ELSE IF EXISTS(SELECT 1 FROM MAS.AppInventoryUpload WHERE CustomerId=@CustomerId AND DebtcontrolScopeName IS NOT NULL OR DebtcontrolScopeName!='')
BEGIN
	UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId  
		   
		and (DebtcontrolScopeName
		NOT IN (SELECT 
						DS.DebtcontrolScopeName
				FROM
						AVL.APP_MAS_DebtcontrolScope DS
						WITH(NOLOCK)
				WHERE
						DS.IsDeleted=0))
						END

						

--SupportWindowName
		UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId     
		and (SupportWindowName is null or SupportWindowName=''
		or SupportWindowName NOT IN ( SELECT 
					SW.SupportWindowName 
			FROM 
					AVL.APP_MAS_SupportWindow SW 
					WITH(NOLOCK)
			WHERE 
					SW.IsDeleted=0)) AND isCognizant=1

--[SupportCategoryName] 
		UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId     
		and (SupportCategoryName is null or SupportCategoryName='' or 
		SupportCategoryName NOT IN (SELECT 
					SC.SupportCategoryName 
			FROM 
					AVL.APP_MAS_SupportCategory SC 
					WITH(NOLOCK)
			WHERE 
					SC.IsDeleted=0)) AND isCognizant=1
					
--[HostedEnvironmentName] 
--UPDATE MAS.AppInventoryUpload set IsValid = 'N'
--		where [CustomerId] =@CustomerId     
--		and (HostedEnvironmentName is null or HostedEnvironmentName='' or HostedEnvironmentName NOT IN
--		(SELECT HostedEnvironmentName FROM AVL.APP_MAS_HostedEnvironment)) AND isCognizant=1
--UPDATE MAS.AppInventoryUpload set IsValid = 'N'
--		where [CustomerId] =@CustomerId     
--		and (HostedEnvironmentName!='' AND HostedEnvironmentName NOT IN
--		(SELECT HostedEnvironmentName FROM AVL.APP_MAS_HostedEnvironment)) AND isCognizant=0

--[CloudServiceProvider] 

		--UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		--where [CustomerId] =@CustomerId AND
		--HostedEnvironmentName='Cloud SAAS- Software as a Service' 
		--AND (CloudServiceProvider IS NULL OR CloudModel IS NULL)

		--UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		--where [CustomerId] =@CustomerId AND
		--HostedEnvironmentName='Cloud IAAS-Infrastructure as a Service' 
		--AND (CloudServiceProvider IS NULL OR CloudModel IS NULL)

		--UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		--where [CustomerId] =@CustomerId AND
		--HostedEnvironmentName='Cloud PAAS- Platform as a Service' 
		--AND (CloudServiceProvider IS NULL OR CloudModel IS NULL)

		--UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		--where [CustomerId] =@CustomerId AND
		--HostedEnvironmentName='Physical Server' 
		--AND CloudServiceProvider IS NOT NULL

		UPDATE MAS.AppInventoryUpload SET IsValid='N'
		WHERE CustomerId=@CustomerId AND
		PrimaryTechnologyName='Others' AND (ISNULL(OtherTechnology,'')='' OR
		LOWER(LTRIM(RTRIM(OtherTechnology))) IN(SELECT LOWER(LTRIM(RTRIM(ExcludedWordName))) FROM MAS.ExcludedWords))

		UPDATE MAS.AppInventoryUpload SET IsValid='N'
		WHERE CustomerId=@CustomerId AND PrimaryTechnologyName='Others' AND
		LOWER(LTRIM(RTRIM(OtherTechnology))) IN(SELECT LOWER(LTRIM(RTRIM(PrimaryTechnologyName))) FROM AVL.APP_MAS_PrimaryTechnology)

		UPDATE MAS.AppInventoryUpload SET IsValid='N'
		WHERE CustomerId=@CustomerId AND
		CloudServiceProvider='Others' AND (ISNULL(OtherServiceProvider,'')='' OR
		LOWER(LTRIM(RTRIM(OtherServiceProvider))) IN(SELECT LOWER(LTRIM(RTRIM(ExcludedWordName))) FROM MAS.ExcludedWords))

		UPDATE MAS.AppInventoryUpload SET IsValid='N'
		WHERE CustomerId=@CustomerId AND CloudServiceProvider='Others' AND
		LOWER(LTRIM(RTRIM(OtherServiceProvider))) IN(SELECT LOWER(LTRIM(RTRIM(CloudServiceProviderName))) FROM avl.APP_MAS_CloudServiceProvider)

		UPDATE MAS.AppInventoryUpload SET IsValid='N'
		WHERE CustomerId=@CustomerId AND
		SupportWindowName='Others' AND (ISNULL(OtherWindow,'')='' OR
		LOWER(LTRIM(RTRIM(OtherWindow))) IN(SELECT LOWER(LTRIM(RTRIM(ExcludedWordName))) FROM MAS.ExcludedWords) AND isCognizant=1)

		UPDATE MAS.AppInventoryUpload SET IsValid='N'
		WHERE CustomerId=@CustomerId AND SupportWindowName='Others' AND
		LOWER(LTRIM(RTRIM(OtherWindow))) IN(SELECT LOWER(LTRIM(RTRIM(SupportWindowName))) FROM avl.APP_MAS_SupportWindow)
		----Clearing values when selected value is not 'Others'  

		UPDATE MAS.AppInventoryUpload SET OtherTechnology='' 
		WHERE CustomerId=@CustomerId AND PrimaryTechnologyName<>'Others'
		
		UPDATE MAS.AppInventoryUpload SET OtherServiceProvider='' 
		WHERE CustomerId=@CustomerId AND CloudServiceProvider<>'Others'

		UPDATE MAS.AppInventoryUpload SET OtherWindow=''
		WHERE CustomerId=@CustomerId AND SupportWindowName<>'Others' and isCognizant=1
		

--Newly Added
IF EXISTS (SELECT  TOP 1 ApplicationName FROM MAS.AppInventoryUpload WHERE  [CustomerId] =@CustomerId   AND IsValid='D')                          
		BEGIN
			SELECT '2'
		 END
--END

Else IF EXISTS (SELECT  TOP 1 ApplicationName FROM MAS.AppInventoryUpload WHERE  [CustomerId] =@CustomerId   AND IsValid='N')                          
		BEGIN
			SELECT '1'
		 END
ELSE 
			SELECT '0'
SET NOCOUNT OFF; 

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[GetAppInventoryTempdetailDynamic_PP]  ', @ErrorMessage, 0,@CustomerId
		
	END CATCH  



END
