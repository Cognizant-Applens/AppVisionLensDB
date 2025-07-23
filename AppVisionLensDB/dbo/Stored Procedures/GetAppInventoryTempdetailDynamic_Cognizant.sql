/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
--[dbo].[GetAppInventoryTempdetailDynamic_Cognizant] 7097
CREATE PROCEDURE [dbo].[GetAppInventoryTempdetailDynamic_Cognizant]
	@CustomerId int =NULL
AS
BEGIN
	BEGIN TRY
	SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#tempT') IS NOT NULL DROP TABLE #tempT 
DECLARE @isCognizant int=0;
IF @CustomerId IS NOT NULL
BEGIN
SELECT @isCognizant=IsCognizant from avl.Customer  (NOLOCK) WHERE CustomerID=@CustomerID;
END
--Unique ApplicationName check for a customer

SELECT Count(ApplicationName) AS AppCount,ApplicationName,CustomerId INTO #AppInventoryUpload FROM MAS.AppInventoryUpload (NOLOCK) WHERE [CustomerId] =@CustomerId
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
--IF EXISTS(SELECT CustomerScreenMapID FROM AVL.MAP_CustomerScreenMapping WHERE CustomerID = @CustomerID AND ScreenID = 5)
--BEGIN
--		UPDATE MAS.AppInventoryUpload set IsValid = 'N'
--		where [CustomerId] =@CustomerId     
--		and (DebtcontrolScopeName is null or DebtcontrolScopeName='' AND DebtcontrolScopeName
--		NOT IN (SELECT 
--						DS.DebtcontrolScopeName
--				FROM
--						AVL.APP_MAS_DebtcontrolScope DS
--						WITH(NOLOCK)
--				WHERE
--						DS.IsDeleted=0))
--						END

--ELSE IF EXISTS(SELECT 1 FROM MAS.AppInventoryUpload WHERE CustomerId=@CustomerId AND DebtcontrolScopeName IS NOT NULL OR DebtcontrolScopeName!='')
--BEGIN
--	UPDATE MAS.AppInventoryUpload set IsValid = 'N'
--		where [CustomerId] =@CustomerId  
		   
--		and (DebtcontrolScopeName
--		NOT IN (SELECT 
--						DS.DebtcontrolScopeName
--				FROM
--						AVL.APP_MAS_DebtcontrolScope DS
--						WITH(NOLOCK)
--				WHERE
--						DS.IsDeleted=0))
--						END

						

----SupportWindowName
		--UPDATE MAS.AppInventoryUpload  set IsValid = 'N' from [ADM].[AppInventoryCognizant_Upload] ACU
		--where ApplicationName=ACU.ApplicationName and [CustomerId] =@CustomerId and  ACU. ApplicationScope like '%Support%'    
		--and (SupportWindowName is null or SupportWindowName=''
		--or SupportWindowName NOT IN ( SELECT 
		--			SW.SupportWindowName 
		--	FROM 
		--			AVL.APP_MAS_SupportWindow SW 
		--			WITH(NOLOCK)
		--	WHERE 
		--			SW.IsDeleted=0)) AND isCognizant=1

----[SupportCategoryName] 
--		UPDATE MAS.AppInventoryUpload set IsValid = 'N'
--		where [CustomerId] =@CustomerId     
--		and (SupportCategoryName is null or SupportCategoryName='' or 
--		SupportCategoryName NOT IN (SELECT 
--					SC.SupportCategoryName 
--			FROM 
--					AVL.APP_MAS_SupportCategory SC 
--					WITH(NOLOCK)
--			WHERE 
--					SC.IsDeleted=0)) AND isCognizant=1



		UPDATE  AIU set IsValid = 'N' from MAS.AppInventoryUpload AS AIU inner join [ADM].[AppInventoryCognizant_Upload] ACU on 
		AIU.ApplicationName=ACU.ApplicationName
		where  AIU.[CustomerId] =@CustomerId and  ACU. ApplicationScope like '%Support%'    
		and (AIU.SupportWindowName is null or AIU.SupportWindowName=''
		or AIU.SupportWindowName NOT IN ( SELECT 
					SW.SupportWindowName 
			FROM 
					AVL.APP_MAS_SupportWindow SW 
					WITH(NOLOCK)
			WHERE 
					SW.IsDeleted=0)) AND AIU.isCognizant=1


		UPDATE AIU set IsValid = 'N'  from MAS.AppInventoryUpload AS AIU inner join [ADM].[AppInventoryCognizant_Upload] ACU on 
		AIU.ApplicationName=ACU.ApplicationName
		where AIU.[CustomerId] =@CustomerId  and  ACU. ApplicationScope like '%Support%'     
		and (AIU.SupportCategoryName is null or AIU.SupportCategoryName='' or 
		AIU.SupportCategoryName NOT IN (SELECT 
					SC.SupportCategoryName 
			FROM 
					AVL.APP_MAS_SupportCategory SC 
					WITH(NOLOCK)
			WHERE 
					SC.IsDeleted=0)) AND AIU.isCognizant=1



					
/*DebtcontrolScopeName*/
IF EXISTS(SELECT CustomerScreenMapID FROM AVL.MAP_CustomerScreenMapping WHERE CustomerID = @CustomerID AND ScreenID = 5)
BEGIN
		UPDATE AIU set IsValid = 'N'  from MAS.AppInventoryUpload AS AIU inner join [ADM].[AppInventoryCognizant_Upload] ACU on 
		AIU.ApplicationName=ACU.ApplicationName
		where AIU.[CustomerId] =@CustomerId  and  ACU. ApplicationScope like '%Support%'  
		and (AIU.DebtcontrolScopeName is null or AIU.DebtcontrolScopeName='' AND AIU.DebtcontrolScopeName
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
	   UPDATE AIU set IsValid = 'N'  from MAS.AppInventoryUpload AS AIU inner join [ADM].[AppInventoryCognizant_Upload] ACU on 
		AIU.ApplicationName=ACU.ApplicationName
		where AIU.[CustomerId] =@CustomerId  and  ACU. ApplicationScope like '%Support%'  
		and (AIU.DebtcontrolScopeName
		NOT IN (SELECT 
						DS.DebtcontrolScopeName
				FROM
						AVL.APP_MAS_DebtcontrolScope DS
						WITH(NOLOCK)
				WHERE
						DS.IsDeleted=0))
						END


						-------
						
		UPDATE AIU set IsValid = 'N'  from MAS.AppInventoryUpload AS AIU inner join [ADM].[AppInventoryCognizant_Upload] ACU on 
		AIU.ApplicationName=ACU.ApplicationName
		where AIU.[CustomerId] =@CustomerId  and  ACU. ApplicationScope ='Development/Testing'
		and (DebtcontrolScopeName!='')and (AIU.DebtcontrolScopeName
		IN (SELECT 
						DS.DebtcontrolScopeName
				FROM
						AVL.APP_MAS_DebtcontrolScope DS
						WITH(NOLOCK)
				WHERE
						DS.IsDeleted=0))


		UPDATE  AIU set IsValid = 'N' from MAS.AppInventoryUpload AS AIU inner join [ADM].[AppInventoryCognizant_Upload] ACU on 
		AIU.ApplicationName=ACU.ApplicationName
		where  AIU.[CustomerId] =@CustomerId and  ACU. ApplicationScope ='Development/Testing'   
		and (AIU.SupportWindowName is not null or AIU.SupportWindowName !=''
		or AIU.SupportWindowName IN ( SELECT 
					SW.SupportWindowName 
			FROM 
					AVL.APP_MAS_SupportWindow SW 
					WITH(NOLOCK)
			WHERE 
					SW.IsDeleted=0)) AND AIU.isCognizant=1


		UPDATE AIU set IsValid = 'N'  from MAS.AppInventoryUpload AS AIU inner join [ADM].[AppInventoryCognizant_Upload] ACU on 
		AIU.ApplicationName=ACU.ApplicationName
		where AIU.[CustomerId] =@CustomerId  and  ACU. ApplicationScope ='Development/Testing'   
		and (AIU.SupportCategoryName is not null or AIU.SupportCategoryName!='' or 
		AIU.SupportCategoryName IN (SELECT 
					SC.SupportCategoryName 
			FROM 
					AVL.APP_MAS_SupportCategory SC 
					WITH(NOLOCK)
			WHERE 
					SC.IsDeleted=0)) AND AIU.isCognizant=1


			UPDATE [ADM].[AppInventoryCognizant_Upload] SET IsValid='N'
			where [CustomerId] =@CustomerId 
			AND (AvailabilityPercent IS not NULL) AND ApplicationScope ='Development/Testing'   


			UPDATE [ADM].[AppInventoryCognizant_Upload] SET IsValid='N'
			where [CustomerId] =@CustomerId 
			AND (IsAppAvailable IS not NULL) AND ApplicationScope ='Development/Testing' 

						-------
					
--[HostedEnvironmentName] 
UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId     
		and (HostedEnvironmentName is null or HostedEnvironmentName='' or HostedEnvironmentName NOT IN
		(SELECT HostedEnvironmentName FROM AVL.APP_MAS_HostedEnvironment)) AND isCognizant=1
UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId     
		and (HostedEnvironmentName!='' AND HostedEnvironmentName NOT IN
		(SELECT HostedEnvironmentName FROM AVL.APP_MAS_HostedEnvironment)) AND isCognizant=0

--[CloudServiceProvider] 

		UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId AND
		HostedEnvironmentName='Cloud SAAS- Software as a Service' 
		AND (CloudServiceProvider IS NULL OR CloudModel IS NULL)

		UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId AND
		HostedEnvironmentName='Cloud IAAS-Infrastructure as a Service' 
		AND (CloudServiceProvider IS NULL OR CloudModel IS NULL)

		UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId AND
		HostedEnvironmentName='Cloud PAAS- Platform as a Service' 
		AND (CloudServiceProvider IS NULL OR CloudModel IS NULL)

		UPDATE MAS.AppInventoryUpload set IsValid = 'N'
		where [CustomerId] =@CustomerId AND
		HostedEnvironmentName='Physical Server' 
		AND CloudServiceProvider IS NOT NULL

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

        UPDATE AIU set IsValid = 'N'  from MAS.AppInventoryUpload AS AIU inner join [ADM].[AppInventoryCognizant_Upload] ACU on 
		AIU.ApplicationName=ACU.ApplicationName
		where AIU.[CustomerId] =@CustomerId  and  ACU. ApplicationScope like '%Support%' AND
		SupportWindowName='Others' AND (ISNULL(OtherWindow,'')='' OR
		LOWER(LTRIM(RTRIM(OtherWindow))) IN(SELECT LOWER(LTRIM(RTRIM(ExcludedWordName))) FROM MAS.ExcludedWords) AND AIU.isCognizant=1)

		UPDATE AIU set IsValid = 'N'  from MAS.AppInventoryUpload AS AIU inner join [ADM].[AppInventoryCognizant_Upload] ACU on 
		AIU.ApplicationName=ACU.ApplicationName
		where AIU.[CustomerId] =@CustomerId  and  ACU. ApplicationScope like '%Support%'  AND SupportWindowName='Others' AND
		LOWER(LTRIM(RTRIM(OtherWindow))) IN(SELECT LOWER(LTRIM(RTRIM(SupportWindowName))) FROM avl.APP_MAS_SupportWindow)
		----Clearing values when selected value is not 'Others'  

		UPDATE MAS.AppInventoryUpload SET OtherTechnology='' 
		WHERE CustomerId=@CustomerId AND PrimaryTechnologyName<>'Others'
		
		UPDATE MAS.AppInventoryUpload SET OtherServiceProvider='' 
		WHERE CustomerId=@CustomerId AND CloudServiceProvider<>'Others'

		UPDATE MAS.AppInventoryUpload SET OtherWindow=''
		WHERE CustomerId=@CustomerId AND SupportWindowName<>'Others' and isCognizant=1
		
		-- Application Scope check
		UPDATE [ADM].[AppInventoryCognizant_Upload] SET IsValid='N'
		where [CustomerId] =@CustomerId 
		AND ( ApplicationScope IS NULL or ApplicationScope='')

		-- Functional Knowledge check
		UPDATE [ADM].[AppInventoryCognizant_Upload] SET IsValid='N'
		where [CustomerId] =@CustomerId 
		AND ( FunctionalKnowledge IS NULL or FunctionalKnowledge='')

		 
			SELECT ProjectID INTO #Projects FROM AVL.MAS_ProjectMaster
			WHERE CustomerID=@CustomerId
			
			DECLARE @ExecutionCount INT

			SELECT @ExecutionCount = COUNT(DISTINCT AttributeValueID)  
			FROM PP.ProjectAttributeValues(NOLOCK) WHERE AttributeID=3 And IsDeleted=0
			AND ProjectID IN (SELECT ProjectID FROM #Projects) 
			
			IF (@ExecutionCount=2)
			BEGIN 
				-- Execution Method check (Conditional Mandatory)
				UPDATE [ADM].[AppInventoryCognizant_Upload] SET IsValid='N'
				where [CustomerId] =@CustomerId AND ApplicationScope!='Support'
				AND (ExecutionMethod IS NULL or ExecutionMethod='')

				-- Execution Method check (Conditional Mandatory)
				UPDATE [ADM].[AppInventoryCognizant_Upload] SET IsValid='N'
				where [CustomerId] =@CustomerId AND ApplicationScope!='Support'
				AND LOWER(ExecutionMethod)='other' and (ISNULL(OtherExecutionMethod,'')='' OR
				--(LOWER(LTRIM(RTRIM(OtherExecutionMethod))) IN(SELECT LOWER(LTRIM(RTRIM(ExecutionMethodName))) FROM ADM.ExecutionMethod) )
				(LOWER(LTRIM(RTRIM(OtherExecutionMethod))) IN(SELECT LOWER(LTRIM(RTRIM(PPA.AttributeValueName))) FROM Mas.PPAttributeValues (NOLOCK) PPA
			INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0
			WHERE AttributeName = 'ExecutionMethod') )
				OR LOWER(LTRIM(RTRIM(OtherExecutionMethod))) ='other' OR LOWER(LTRIM(RTRIM(OtherExecutionMethod))) ='others'
				OR LOWER(LTRIM(RTRIM(OtherExecutionMethod))) ='na'OR LOWER(LTRIM(RTRIM(OtherExecutionMethod))) ='null'
				OR LOWER(LTRIM(RTRIM(OtherExecutionMethod))) ='no data' OR LOWER(LTRIM(RTRIM(OtherExecutionMethod))) ='invalid'
				)


			END
			--ELSE 
			--BEGIN
			--	-- Other Execution Method check 
			--	UPDATE [ADM].[AppInventoryCognizant_Upload] SET IsValid='N'
			--	where [CustomerId] =@CustomerId 
			--	AND LOWER(ExecutionMethod)!='other' and (ISNULL(OtherExecutionMethod,'')!='' ) 
				
			--END

			-- SourceCode Availability check 
			UPDATE [ADM].[AppInventoryCognizant_Upload] SET IsValid='N'
			where [CustomerId] =@CustomerId 
			AND (SourceCodeAvailability IS NULL or SourceCodeAvailability='')

			-- Regulatory Body is selected as other check 
			UPDATE [ADM].[AppInventoryCognizant_Upload] SET IsValid='N'
			where [CustomerId] =@CustomerId 
			AND LOWER(RegulatoryBody) like '%other%'  AND  (ISNULL(OtherRegulatoryBody,'')='' OR
			(LOWER(LTRIM(RTRIM(OtherRegulatoryBody))) IN(SELECT LOWER(LTRIM(RTRIM(RegulatoryBodyName))) FROM ADM.RegulatoryBody))
			OR LOWER(LTRIM(RTRIM(OtherRegulatoryBody))) ='other' OR LOWER(LTRIM(RTRIM(OtherRegulatoryBody))) ='others'
			OR LOWER(LTRIM(RTRIM(OtherRegulatoryBody))) ='na'OR LOWER(LTRIM(RTRIM(OtherRegulatoryBody))) ='null'
			OR LOWER(LTRIM(RTRIM(OtherRegulatoryBody))) ='no data' OR LOWER(LTRIM(RTRIM(OtherRegulatoryBody))) ='invalid'
			)

			-- Regulatory Body is selected as other check 
			UPDATE [ADM].[AppInventoryCognizant_Upload] SET IsValid='N'
			where [CustomerId] =@CustomerId 
			AND LOWER(IsAppAvailable) ='yes'  AND (AvailabilityPercent IS NULL or AvailabilityPercent<=0) AND ApplicationScope like '%Support%'

			UPDATE [ADM].[AppInventoryCognizant_Upload] SET IsValid='N'
			where [CustomerId] =@CustomerId 
			AND LOWER(IsAppAvailable) !='yes'  AND (AvailabilityPercent IS NOT NULL) AND ApplicationScope like '%Support%'

			DECLARE @ErrorResult VARCHAR(5)


--Newly Added
IF EXISTS (SELECT  TOP 1 ApplicationName FROM MAS.AppInventoryUpload WHERE  [CustomerId] =@CustomerId   AND IsValid='D')                          
BEGIN
			SET @ErrorResult = '2'
END
Else IF EXISTS (SELECT  TOP 1 ApplicationName FROM MAS.AppInventoryUpload WHERE  [CustomerId] =@CustomerId  AND IsValid='N')
BEGIN
			SET @ErrorResult = '1'
END
ELSE IF EXISTS (SELECT TOP 1 ApplicationName FROM [ADM].[AppInventoryCognizant_Upload] WHERE  [CustomerId] =@CustomerId  AND IsValid='N')
BEGIN
			SET @ErrorResult = '1'
END
ELSE 
BEGIN
			SET @ErrorResult = '0'
END

SET NOCOUNT OFF; 

			SELECT @ErrorResult

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[GetAppInventoryTempdetailDynamic_Cognizant]  ', @ErrorMessage, 0,@CustomerId
		
	END CATCH  
	Set NoCount off;

END
