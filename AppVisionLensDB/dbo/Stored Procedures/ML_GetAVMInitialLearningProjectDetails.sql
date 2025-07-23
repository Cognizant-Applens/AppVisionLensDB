/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_GetAVMInitialLearningProjectDetails] @EmployeeID VARCHAR(50), 
                                                               @CustomerID INT 
AS 
  BEGIN
	  SET NOCOUNT ON; 
      BEGIN TRY 
			SELECT DISTINCT PM.ProjectID, 
			PM.ProjectName, 
			PDD.IsAutoClassified,
			PC.SupportTypeId 
			FROM   AVL.MAS_PROJECTMASTER	PM 
			JOIN AVL.MAS_LOGINMASTER		LM	ON LM.ProjectID = PM.ProjectID 
			JOIN AVL.MAS_PROJECTDEBTDETAILS PDD	ON PDD.ProjectID = LM.ProjectID 
			AND LM.CustomerID = @CustomerID AND EmployeeID = @EmployeeID 
			AND LM.IsDeleted = 0 			AND ISNULL(PM.IsDeleted,0) = 0
			JOIN AVL.MAP_ProjectConfig		PC	ON PC.ProjectID=LM.ProjectID 
			AND PC.SupportTypeId IN (2,3)
         
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = ERROR_MESSAGE() 
          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[sp_GetAVMInitialLearningProjectDetails] ', 
            @ErrorMessage, 
            @EmployeeID, 
            @CustomerID 
      END CATCH 
  END
