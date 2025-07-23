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
-- Author:  683989  
-- Create date: 14-Feb-2020  
-- Description: Update Standard CC and RC Migration  
-- =============================================  
CREATE PROCEDURE [ML].[GetMigrationProjectFroRCCC]   
  
AS  
  
BEGIN  
  
 BEGIN TRY  
     
  select distinct CC.ProjectID   
  from avl.DEBT_MAP_CauseCode(nolock) CC  
  join avl.MAS_ProjectMaster(nolock) PM  
   on PM.ProjectID=CC.ProjectID  
   where isnull(PM.IsMultilingualEnabled,0)=0  
   and CC.CauseStatusID is null 
   and CC.IsDeleted=0
   and PM.IsDeleted=0
  union  
  select distinct RC.ProjectID   
  from [AVL].[DEBT_MAP_ResolutionCode] (nolock) RC  
  join avl.MAS_ProjectMaster(nolock) PM  
   on PM.ProjectID=RC.ProjectID  
   where isnull(PM.IsMultilingualEnabled,0)=0  
   and RC.ResolutionStatusID is null  
   and RC.IsDeleted=0
   and PM.IsDeleted=0
      
   
     END TRY  
  
  BEGIN CATCH  
      DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  ROLLBACK TRAN  
  --INSERT Error      
  EXEC AVL_InsertError '[ML].[GetMigrationProjectFroRCCC] ', @ErrorMessage, 0 ,''  
    
  END CATCH  
   
 SET NOCOUNT OFF;  
  
END
