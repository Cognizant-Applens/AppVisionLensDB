/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetEOLTechMappingTransactionDetails] 
@AccountId VARCHAR(100)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN

		BEGIN
			SET NOCOUNT ON;
			DECLARE @LatestVersion AS VARCHAR(100);
			DECLARE @CreatedDate AS VARCHAR(25);

			SELECT *
			INTO #temp
			FROM (
				SELECT DISTINCT A.AccountId
					,IT.InfraTypeName ProductType
					,ID.InfraDetailName Product
					,A.ApplicationId
					,IV.InfraVersionName [version]
					,B.EOL
					,B.extendedDate
					,A.isDeleted
					,@LatestVersion LatestVersion
					,@CreatedDate CreatedDate
				FROM TechnologyMappingTransaction(NOLOCK) A
				INNER JOIN PP.MasterTableOfEOLDetails(NOLOCK) B ON A.EolId = B.Id
				INNER JOIN PP.TechCurrencyInfraType(NOLOCK) IT ON B.InfraTypeId = IT.InfraTypeId
				INNER JOIN PP.TechCurrencyInfraDetail(NOLOCK) ID ON B.InfraDetailId = ID.InfraDetailId
				INNER JOIN PP.TechCurrencyInfraVersion(NOLOCK) IV ON B.InfraVersionId = IV.InfraVersionId
				WHERE A.AccountId = @AccountId
					AND A.IsDeleted = 0
					AND B.IsDeleted = 0
					AND IT.IsDeleted = 0
					AND ID.IsDeleted = 0
					AND IV.IsDeleted = 0
				) t

			SELECT *
			INTO #tempws
			FROM (
				SELECT ProductName
					,max(MaxVersion) LatestVersion
				FROM (
					SELECT ProductName
						,cast(max(cast(version AS FLOAT)) AS NVARCHAR(50)) AS MaxVersion
					FROM [PP].[EOS_WebScrappingOutput]
					WHERE ISNUMERIC(version) = 1
					GROUP BY ProductName
					
					UNION
					
					SELECT ProductName
						,max(version) AS MaxVersionfrom
					FROM [PP].[EOS_WebScrappingOutput]
					WHERE ISNUMERIC(version) <> 1
					GROUP BY ProductName
					) t
				GROUP BY ProductName
				) t1

			UPDATE A
			SET LatestVersion = ws.LatestVersion
				,CreatedDate = eos.CreatedDate
			FROM #tempws ws
			INNER JOIN #temp A ON ws.ProductName = A.Product
			INNER JOIN [PP].[EOS_WebScrappingOutput] eos ON eos.ProductName = A.Product
				AND eos.Version = ws.LatestVersion

			SELECT *
			FROM #temp
		END

		SET NOCOUNT OFF;

		COMMIT TRAN
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN

		--INSERT INTO Error_Log (Exception)
		--VALUES (ERROR_MESSAGE());
	END CATCH
END
