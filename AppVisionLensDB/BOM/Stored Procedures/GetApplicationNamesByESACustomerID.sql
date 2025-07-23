 /***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

 CREATE PROCEDURE [BOM].[GetApplicationNamesByESACustomerID]                  
 @CustomerID BIGINT        
  
AS          
BEGIN          
 BEGIN TRY        
      
 Create table #temp      
 (AccountId INT)      
      
 IF EXISTS (SELECT ParentId FROM [BusinessOutcome].[TRN].[AccountListMapping] WHERE ParentId=@CustomerID and UseParent=1)      
 BEGIN      
      
 INSERT INTO #temp      
 SELECT CustomerID from [ESA].[BUParentAccounts] WHERE ParentCustomerID=@CustomerID      
       
 END      
 ELSE      
 BEGIN      
      
 INSERT INTO #temp values(@CustomerID)      
      
 END      
            
SELECT DISTINCT AL.ApplicationID,AL.ApplicationName,AL.ApplicationShortName          
 FROM           
		[AVL].[APP_MAS_ApplicationDetails] AL          
   JOIN [AVL].[app_map_applicationprojectmapping] APM ON (APM.applicationid = AL.ApplicationID AND AL.ISActive=1)
   JOIN [AVL].[MAS_ProjectMaster] PM ON (APM.ProjectID = PM.ProjectID AND  APM.IsDeleted = 0 AND PM.IsDeleted = 0)
   JOIN [AVL].[Customer] AC ON (AC.CustomerID = PM.CustomerID AND AC.IsDeleted = 0)
   WHERE PM.CustomerID IN (SELECT AccountId FROM #temp )
   
 END TRY            
 BEGIN CATCH           
 DECLARE @ErrorMessage VARCHAR(4000);          
          
  SELECT @ErrorMessage = ERROR_MESSAGE()          
          
  --INSERT Error              
  EXEC AVL_InsertError '[BOM].[GetApplicationNamesByESACustomerID]', @ErrorMessage, @CustomerID           
            
 END CATCH            
END
