/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
  
  
CREATE PROCEDURE [AVL].[TK_GetTicketType]  
  
AS  
BEGIN 
 SET NOCOUNT ON;
BEGIN TRY  
  
 SELECT TicketTypeMappingID,TicketType FROM AVL.TK_MAP_TicketTypeMapping (NOLOCK) WHERE IsDeleted = 0  
 END TRY    
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError ' [AVL].[TK_GetTicketType] ', @ErrorMessage, 0,0  
    
 END CATCH    
 SET NOCOUNT OFF;
END
