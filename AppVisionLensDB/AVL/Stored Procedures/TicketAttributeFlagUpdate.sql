/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[TicketAttributeFlagUpdate] --19100,0  
 @projectid INT,  
 @flag INT   
 AS  
 BEGIN  
 DECLARE @Integration VARCHAR(10)  
   
  -- To get the configuration  
  IF(@flag = 0)  
  BEGIN  
  SET @Integration = (SELECT TAI.Integrationid AS RESULT FROM [AVL].[MAS_TicketAttributesIntegartionMaster](NOLOCK) AS TAI  
   INNER JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) AS PM ON TAI.IntegrationID = PM.TicketAttributeIntegartion  
   WHERE PM.ProjectID = @projectid)  
   IF (@Integration= '' OR @Integration IS NULL)  
   BEGIN  
    SELECT '1' AS RESULT  
   END  
   ELSE  
   BEGIN  
    SELECT @Integration AS RESULT  
   END  
  END  
  -- To get the configuration name for Project configuration page  
  ELSE IF (@flag = 10)  
  BEGIN  
  SET @Integration =( SELECT TAI.Integartion AS RESULT FROM [AVL].[MAS_TicketAttributesIntegartionMaster](NOLOCK) AS TAI  
   INNER JOIN [AVL].[MAS_ProjectMaster] (NOLOCK) AS PM ON TAI.IntegrationID = PM.TicketAttributeIntegartion  
   WHERE PM.ProjectID = @projectid)  
   IF(@Integration = '' OR @Integration IS NULL)  
   BEGIN  
    SELECT Integartion  AS RESULT FROM  [AVL].[MAS_TicketAttributesIntegartionMaster](NOLOCK) WHERE IntegrationID = 1  
   END  
   ELSE  
   BEGIN  
    SELECT @Integration AS RESULT  
   END  
  END  
  -- To update Project Master table with selected configaration type  
  ELSE  
  BEGIN  
   UPDATE [AVL].[MAS_ProjectMaster] SET TicketAttributeIntegartion = @flag WHERE ProjectID = @projectid     
   SELECT 'update' AS RESULT  
   IF(@flag = 2)  
   BEGIN  
  --  UPDATE [AVL].[MAS_ProjectMaster] SET IsC20MappingCompleted = 'N',IsC2AppServiceMapCompleted='N',C20MappingCompletedTimestamp=NULL,C20AppServiceMapCompletedTimestamp = NULL
	 --WHERE ProjectID = @projectid  
    EXEC [AVL].[InsertTicketAttributeToProject_NewProjectInsert_Mainspring] @projectid
   END
 --  ELSE IF(@flag = 3) 
 --  BEGIN
    
 --   UPDATE MAS.ProjectMaster SET IsC20MappingCompleted = 'Y',IsC2AppServiceMapCompleted='Y',C20MappingCompletedTimestamp=NULL,C20AppServiceMapCompletedTimestamp = NULL WHERE ProjectID = @projectid 
	--EXEC [dbo].[C20_InsertTicketAttributeToProject] @projectid
 --  END 
   ELSE
	BEGIN
		EXEC [AVL].[InsertTicketAttributeToProject_NewProjectInsert_Standard] @projectid
	END
  END  
 END
