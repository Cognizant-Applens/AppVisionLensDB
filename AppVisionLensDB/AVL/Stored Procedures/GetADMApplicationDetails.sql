/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ===============================================================  
-- Author  : Shobana  
-- Create date : 21-July-2020  
-- Description : Gets ADM Application Details  
-- Revision  :   
-- Revised By :   
-- Test         : [AVL].[GetADMApplicationDetails] 10337  
-- ===============================================================  
CREATE PROCEDURE [AVL].[GetADMApplicationDetails]  
@ProjectID BIGINT  
AS  
BEGIN 
SET NOCOUNT ON;
 BEGIN TRY  
  
  SELECT DISTINCT APM.ApplicationID,MAD.ApplicationName, 0 AS ExecutionMethod  
  INTO #AppDetails  
  FROM AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) APM  
  JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) MAD   
   ON MAD.ApplicationID = APM.ApplicationID  
  JOIN [ADM].[AppApplicationScope](NOLOCK) AAS  
   ON AAS.ApplicationId = MAD.ApplicationId   
  WHERE ProjectID = @ProjectID AND AAS.ApplicationScopeId = 1  
  AND MAD.IsActive = 1 AND APM.IsDeleted = 0   
  AND AAS.ISDeleted = 0   
  
  UPDATE AD set AD.ExecutionMethod = ISNULL(AAD.ExecutionMethod ,0)  
  FROM #AppDetails AD  
     JOIN ADM.ALMApplicationDetails(NOLOCK) AAD  
   ON AAD.ApplicationID = AD.ApplicationID   
  AND AAD.ISDeleted = 0  
  
  SELECT DISTINCT ApplicationID,ApplicationName,ExecutionMethod   
  FROM #AppDetails(NOLOCK)  
  
 END TRY     
 BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[GetADMApplicationDetails]', @ErrorMessage, 'System',0  
    
 END CATCH
 SET NOCOUNT OFF;
END
