/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/*****
Created By		: 471742 Dhivya Bharathi M
Created Date	: 30th July 2019
Comment			: 
*****/

--AVL.ML_GetTopFilters  10337,1
--AVL.ML_GetTopFilters  240,2
CREATE PROCEDURE [AVL].[ML_GetTopFilters] 
@ProjectID BIGINT, 
@SupportTypeID INT 
AS 
  BEGIN
	  SET NOCOUNT ON; 
      BEGIN TRY 
	  IF @SupportTypeID =1
	  BEGIN
			SELECT TOP 1 PDB.ProjectID,StartDate,EndDate,ISNULL(PDB.IsAutoClassified,'N') AS IsAutoClassified,
			ISNULL(OPM.OptionalFieldID,0) AS OptionalFieldID,ISNULL(PDB.IsMLSignOff,'N')AS IsMLSignOff
			FROM AVL.MAS_ProjectMaster(NOLOCK)  PM  
			LEFT JOIN AVL.ML_PRJ_InitialLearningState(NOLOCK)  PLS ON PM.ProjectID=PLS.ProjectID
			LEFT JOIN AVL.MAS_ProjectDebtDetails(NOLOCK)  PDB ON PM.ProjectID=PDB.ProjectID
			LEFT JOIN AVL.ML_MAP_OptionalProjMapping(NOLOCK)  OPM ON PM.ProjectID=OPM.ProjectId AND OPM.IsActive=1
			 WHERE PM.ProjectID=@ProjectID
			 ORDER BY PLS.ID DESC
		END
		ELSE
		BEGIN
			SELECT TOP 1  PDB.ProjectID,StartDate,EndDate,ISNULL(PDB.IsAutoClassifiedInfra,'N') AS IsAutoClassified,
			ISNULL(OPM.OptionalFieldID,0) AS OptionalFieldID,
			ISNULL(PDB.IsMLSignOffInfra,'N')AS IsMLSignOff 
			FROM AVL.MAS_ProjectMaster(NOLOCK)  PM  
			LEFT JOIN AVL.ML_PRJ_InitialLearningStateInfra(NOLOCK) PLS ON PM.ProjectID=PLS.ProjectID
			LEFT JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDB ON PM.ProjectID=PDB.ProjectID
			LEFT JOIN AVL.ML_MAP_OptionalProjMappingInfra(NOLOCK) OPM ON PM.ProjectID=OPM.ProjectId AND OPM.IsDeleted=0
			 WHERE PM.ProjectID=@ProjectID
			 ORDER BY PLS.ID DESC
		END

		SELECT DISTINCT OP.ID, OP.OptionalFields  AS OptFieldName
		FROM   AVL.ITSM_PRJ_SSISCOLUMNMAPPING (NOLOCK) SSIS 
		JOIN AVL.ML_MAS_OPTIONALFIELDS (NOLOCK) OP 
		ON SSIS.ServiceDartColumn = OP.OptionalFields 
		WHERE  SSIS.ProjectID = @ProjectID  and SSIS.IsDeleted=0  and op.IsDeleted=0

	  END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = ERROR_MESSAGE() 
          --INSERT Error     
          EXEC AVL_INSERTERROR 'AVL.ML_GetTopFilters',  @ErrorMessage, '',  @ProjectID 
      END CATCH 
  END
