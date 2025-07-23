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
-- Author      : Sathyanarayanan
-- Modified    : 
-- Create date : Jun 23, 2020
-- Description : Get Copy Project List
-- Revision    :
-- Revised By  :
-- ===========================================================================================

CREATE PROCEDURE [PP].[GetCopyProjectList]
@ProjectID BIGINT,
@TVPSelectedScopeValue as [PP].[TVP_SelectedScopeValue] READONLY 
AS   
  BEGIN   
	BEGIN TRY    
		SET NOCOUNT ON;  
		DECLARE @CustomerID BIGINT = (SELECT CustomerID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0);	
		DECLARE @MonthLimit BIGINT = 6;
	
	--Scope List
			Select DISTINCT PAV.ProjectID,av.AttributeValueName into #ProjectScopeList from PP.ProjectAttributeValues(NOLOCK) PAV
			INNER JOIN MAS.PPAttributeValues(NOLOCK) AV ON PAV.AttributeValueID=AV.AttributeValueID AND AV.IsDeleted=0
			AND PAV.AttributeID = 1 AND PAV.IsDeleted = 0 AND AV.IsDeleted=0
	

 --Project List

			CREATE TABLE #ProjectList
			(
			EsaProjectID BIGINT null,
			ProjectID BIGINT NULL,
			ProjectName NVARCHAR(50) NULL,
			IsActive bit,
			AttributeValueName NVARCHAR(50),
			)

			INSERT INTO #ProjectList
			SELECT DISTINCT PM.EsaProjectID as EsaProjectID,PM.ProjectID,
			TRIM(PM.ProjectName) AS ProjectName,1 AS IsActive,AV.AttributeValueName FROM AVL.MAS_ProjectMaster(NOLOCK) PM 
			INNER JOIN PP.ProjectProfilingTileProgress(NOLOCK) PPTP ON PM.ProjectID = PPTP.ProjectID AND PPTP.TileID=1
				AND PPTP.TileProgressPercentage = 100 AND PPTP.IsDeleted = 0
			INNER JOIN PP.ProjectAttributeValues(NOLOCK) PAV ON PAV.ProjectID = PM.ProjectID 
				AND PAV.AttributeID = 1 AND PAV.IsDeleted = 0 AND PAV.AttributeValueID IN (SELECT ScopeID FROM @TVPSelectedScopeValue)
			INNER JOIN #ProjectScopeList(NOLOCK) AV ON av.ProjectID=PM.ProjectID 
			WHERE PM.CustomerID = @CustomerID AND PM.IsDeleted = 0 AND PM.ProjectID NOT IN (@ProjectID)
			UNION
			SELECT DISTINCT PM.EsaProjectID as EsaProjectID,PM.ProjectID,
			TRIM(PM.ProjectName) AS ProjectName,0 AS IsActive,AV.AttributeValueName FROM AVL.MAS_ProjectMaster(NOLOCK) PM 
			INNER JOIN PP.ProjectProfilingTileProgress(NOLOCK) PPTP ON PM.ProjectID = PPTP.ProjectID AND PPTP.TileID=1
				AND PPTP.TileProgressPercentage = 100 AND PPTP.IsDeleted = 0
			INNER JOIN PP.ProjectAttributeValues(NOLOCK) PAV ON PAV.ProjectID = PM.ProjectID 
				AND PAV.AttributeID = 1 AND PAV.IsDeleted = 0 AND PAV.AttributeValueID IN (SELECT ScopeID FROM @TVPSelectedScopeValue)
			INNER JOIN #ProjectScopeList(NOLOCK) AV ON av.ProjectID=PM.ProjectID 
			WHERE PM.CustomerID = @CustomerID AND PM.IsDeleted = 1 AND PM.ProjectID NOT IN (@ProjectID) 
				AND DATEDIFF(M,PM.ModifiedDate,GETDATE()) <= @MonthLimit
			
			SELECT DISTINCT EsaProjectID,ProjectID,ProjectName,IsActive,
		    STUFF((SELECT DISTINCT ',' + AttributeValueName
			FROM #ProjectList t2
			WHERE t1.EsaProjectID = t2.EsaProjectID and t1.ProjectID = t2.ProjectID
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
			,1,1,'') AttributeValueName
			FROM #ProjectList t1;



			CREATE TABLE #AttributeNames(
			AttributeName varchar(100)
			)

			INSERT INTO  #AttributeNames VALUES
			 ('Project Scope')
			,('Execution method')
			,('Other Execution method')
			,('Work Item Measurement')
			,('Other Work Item Measurement')
			,('Pricing Model')
			,('Other Pricing Model')
			,('Non Cognizant Vendor Presence')
			,('Vendor Name')
			,('Vendor Scope')
			,('How are requirements captured?')
			,('Other requirement capture method')
			,('Whether requirements are baselined and stored?')
			,('Where are requirements baselined and stored?')
			,('Other requirements baselined and stored')

			SELECT AttributeName FROM #AttributeNames
		
 END TRY   
   BEGIN CATCH   
        DECLARE @ErrorMessage VARCHAR(MAX);   
        SELECT @ErrorMessage = ERROR_MESSAGE()   
        --INSERT Error      
        EXEC AVL_INSERTERROR  '[PP].[GetCopyProjectList]', @ErrorMessage,  0,0   
   END CATCH   
END
