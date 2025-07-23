
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
-- Create date : Apr 7, 2021
-- Description : Get Steady state Project details By ESAProjectID    
-- Revision    :
-- Revised By  :
-- =========================================================================================

CREATE PROCEDURE [PP].[PPGetSteadyStateDetailsByEsaProjectIDs]
@TVP_ProjectDetailsTemp as [PP].[TVP_ProjectDetails] Readonly

AS 
  BEGIN 
	BEGIN TRY 
		SET NOCOUNT ON;
			IF OBJECT_ID('tempdb..#tempProjectDetails') IS NOT NULL
			BEGIN
			DROP TABLE #tempProjectDetails
			END
			SELECT temp.ID,temp.ESAProjectID, temp.LevelID, temp.ParentID, temp.RoleID, temp.[Name], PD.ProjectId  INTO #tempProjectDetails  FROM AVL.MAS_ProjectMaster(NOLOCK) PM 
			INNER JOIN @TVP_ProjectDetailsTemp AS temp ON temp.EsaProjectID = PM.ESAProjectID
			INNER JOIN PP.ProjectDetails (NOLOCK) PD ON PD.ProjectId = PM.ProjectId
			WHERE PM.IsDeleted=0 AND PD.IsDeleted = 0 AND temp.LevelID=3

			--Steady State initiated Projects
			SELECT temp.ID,temp.ESAProjectID, temp.LevelID, temp.ParentID, temp.RoleID, temp.[Name] FROM @TVP_ProjectDetailsTemp AS temp where temp.LevelID!=3
			Union
			SELECT temp.ID,temp.ESAProjectID, temp.LevelID, temp.ParentID, temp.RoleID, temp.[Name] FROM #tempProjectDetails AS temp 

			--Steady State not initiated Projects
			SELECT temp.ID,temp.ESAProjectID, temp.LevelID, temp.ParentID, temp.RoleID, temp.[Name] FROM @TVP_ProjectDetailsTemp AS temp where temp.LevelID=3
			EXCEPT
			SELECT temp.ID,temp.ESAProjectID, temp.LevelID, temp.ParentID, temp.RoleID, temp.[Name] FROM #tempProjectDetails AS temp

			

	END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error     
        EXEC AVL_INSERTERROR  '[PP].[PPGetSteadyStateDetailsByEsaProjectIDs]', @ErrorMessage,  0, 
        0 
    END CATCH 
  END
