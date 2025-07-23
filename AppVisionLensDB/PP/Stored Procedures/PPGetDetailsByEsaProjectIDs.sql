/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : Ajai. J
-- Create date : Feb 18, 2021
-- Description : Get BU, Account, Project details By ESAProjectID    
-- Revision    :
-- Revised By  :
-- =========================================================================================

CREATE PROCEDURE [PP].[PPGetDetailsByEsaProjectIDs]
@TVP_ESAProjectDetailsTemp as [PP].[TVP_ESAProjectDetails] Readonly

AS 
  BEGIN 
	BEGIN TRY 
		SET NOCOUNT ON;

			--BU
			CREATE TABLE #BUAccountProjectDetails
			(
			BUID BIGINT NULL,
			BUName NVARCHAR(50) NULL,
			CustomerID BIGINT NULL,
			CustomerName NVARCHAR(50) null,
			ProjectID BIGINT NULL,
			ProjectName NVARCHAR(50) NULL,
			RoleID INT null,
			EsaProjectID BIGINT null
			)

			INSERT INTO #BUAccountProjectDetails
			SELECT DISTINCT BU.BusinessUnitID,BU.BusinessUnitName,C.CustomerID,C.CustomerName,PM.ProjectID,PM.ProjectName,7 as RoleID,PM.EsaProjectID
			FROM AVL.MAS_ProjectMaster(NOLOCK) PM 
			INNER JOIN AVL.Customer(NOLOCK) C ON PM.CustomerID=C.CustomerID AND C.IsDeleted=0
			INNER JOIN [MAS].[BusinessUnits](NOLOCK) BU ON C.BusinessUnitID=BU.BusinessUnitID AND BU.IsDeleted=0
			INNER JOIN @TVP_ESAProjectDetailsTemp AS temp ON temp.EsaProjectID = PM.ESAProjectID
			WHERE PM.IsDeleted=0 
			
			SELECT DISTINCT 0 AS ParentID,BUID AS ID,BUName AS [Name], 1 AS LevelID,RoleID,0 as EsaProjectID,'' as IsTransition FROM #BUAccountProjectDetails
			UNION
			SELECT DISTINCT BUID as ParentID,CustomerID AS ID,CustomerName AS [Name],2 AS LevelID,RoleID,0 AS EsaProjectID,'' as IsTransition  FROM #BUAccountProjectDetails
			UNION
			SELECT DISTINCT CustomerID as ParentID,ProjectID AS ID,ProjectName  AS [Name],3 AS LevelID,RoleID,EsaProjectID,CAST('TRUE' AS BIT) as IsTransition FROM #BUAccountProjectDetails 
			WHERE EsaProjectID != '0'

			SELECT 
			RoleID 
			,RoleName
			,Priority
			FROM [AVL].[RoleMaster] 
			where IsActive = 1 AND RoleId in (SELECT DISTINCT RoleId FROM #BUAccountProjectDetails(NOLOCK) WHERE  RoleId IN (7) )

			

	END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error     
        EXEC AVL_INSERTERROR  '[PP].[PPGetDetailsByEsaProjectIDs]', @ErrorMessage,  0, 
        0 
    END CATCH 
  END
