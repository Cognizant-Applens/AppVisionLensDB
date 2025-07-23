/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


            
-- =============================================                                    
-- Author:  <SanthanaLakshmi>                                    
-- Create date: <23.03.2015>                                    
-- Description: <For Dashboard Dump export>                                    
-- =============================================                    
--EXEC [KTM].[usp_App_Level_GetDashboarddumpdetails] '711','561855'                                 
CREATE PROCEDURE [AVL].[Get_ProjectList]                                    
                                    
AS                                    
BEGIN                               
BEGIN TRY            
        SELECT     
	       PM.EsaProjectID,PM.ProjectName
       FROM 
       AVL.MAS_ProjectMaster PM WITH (NOLOCK)
       INNER JOIN AVL.PRJ_ConfigurationProgress CP WITH (NOLOCK) ON CP.ProjectID = PM.ProjectID 
       AND CP.ScreenID = 2 
       AND CP.ITSMScreenId = 11 
       AND CP.CompletionPercentage = 100 
       AND CP.IsDeleted = 0 
       AND PM.IsDeleted = 0 
       AND PM.IsESAProject = 1 
       INNER JOIN AVL.PRJ_ConfigurationProgress CP1 ON CP1.ProjectID = PM.ProjectID 
       AND CP1.ScreenID = 4 
       AND CP1.CompletionPercentage = 100 
       AND cp1.IsDeleted = 0 
          WHERE PM.EsaProjectID NOT IN (0,3,'1000224884','1000180258','1000180251')
          ORDER BY PM.EsaProjectID

              
END TRY                                  
                                   
BEGIN CATCH                            
                                      
 DECLARE @ErrorMessage NVARCHAR(4000);                                      
 DECLARE @ErrorSeverity INT;                                      
 DECLARE @ErrorState INT;                                      
                                      
select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();                                      
        
   --INSERT Error                                      
   EXEC AVL_InsertError '[AVL].[Get_ProjectList]',@ErrorMessage ,0,0                                               
                                  
END CATCH                                   
END
