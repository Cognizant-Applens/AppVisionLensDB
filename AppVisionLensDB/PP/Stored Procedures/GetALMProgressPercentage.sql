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
-- Author      :   
-- Create date : 01/03/2021  
-- Description : Procedure to SourceColumn  
-- Revision    :  
-- Revised By  :  
-- =========================================================================================   
CREATE PROCEDURE [PP].[GetALMProgressPercentage]
(  
 @ProjectID BIGINT
)  
AS  
BEGIN    
SET NOCOUNT ON   
BEGIN TRY  
  
   DECLARE @ALMConfigPerc  INT   = 0  
   SET @ALMConfigPerc = [PP].[GetALMConfigurationPercentage] (@ProjectID, 0)    
   select @ALMConfigPerc as ALMConfigPerc

END TRY  
BEGIN CATCH  
        
 DECLARE @ErrorMessage VARCHAR(MAX);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
    
 EXEC AVL_InsertError 'PP.GetALMProgressPercentage', @ErrorMessage, 0 ,''  
    
END CATCH  
  
SET NOCOUNT OFF  
  
END
