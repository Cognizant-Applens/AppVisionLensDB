

/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [AVL].[GetOPLMasterdata]  
 AS  
BEGIN    
 SET NOCOUNT ON;    
 BEGIN TRY   
   
      SELECT DISTINCT ESA_Project_ID as ESAProjectID FROM  [dbo].[OPLMasterdata](NOLOCK) WHERE IsDeleted = 0 
	  
 SET NOCOUNT OFF; 
 END TRY    
 BEGIN CATCH    
 DECLARE @errorMessage VARCHAR(MAX);    
    
   SELECT @errorMessage = ERROR_MESSAGE()    
    
   --INSERT Error        
   EXEC AVL_InsertError '[AVL].[GetOPLMasterdata]',@errorMessage,'',0    
 END CATCH    
End
