/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [PP].[GetCauseResolutionDetail](@ProjectId BIGINT)    
AS    
BEGIN    
 BEGIN TRY      
   BEGIN TRANSACTION     
    
DECLARE @CCount INT    
DECLARE @RCount INT    
    
SET @CCount=(SELECT COUNT(CauseID) FROM [AVL].[DEBT_MAP_CauseCode] where projectid=@ProjectId AND ISDELETED=0 AND causecode<>'NA')    
   
SET @RCount=(SELECT COUNT(ResolutionID) FROM [AVL].[DEBT_MAP_ResolutionCode] where projectid=@ProjectId AND ISDELETED=0 AND ResolutionCode<>'NA')    
    
IF(@CCount>0 AND @RCount>0)    
BEGIN    
SELECT 'Y' Result    
END    
    
ELSE    
BEGIN    
SELECT 'N' Result    
END    
  COMMIT TRANSACTION      
     END TRY     
  BEGIN CATCH      
      DECLARE @ErrorMessage VARCHAR(MAX);      
      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
  ROLLBACK TRAN      
  --INSERT Error          
  EXEC AVL_InsertError '[PP].[GetCauseResolutionDetail]', @ErrorMessage, 0 ,@ProjectId      
  END CATCH      
    
END
