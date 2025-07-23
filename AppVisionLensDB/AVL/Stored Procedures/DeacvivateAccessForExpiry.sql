/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[DeacvivateAccessForExpiry]  
AS       
 BEGIN  
  BEGIN TRY  
  
   DECLARE @CurrentDate DATE = FORMAT(GetDate(), 'yyyy-MM-dd')  
   DECLARE @ModifiedDate VARCHAR(50) = GetDate()  
   DECLARE @ModifiedBy VARCHAR(50) = 'System'  
  
   UPDATE  [AVL].[UserRoleMapping] SET  
   IsActive = 0,  
   ModifiedBy = @ModifiedBy,  
   ModifiedDate = @ModifiedDate  
   WHERE (DataSource = 'UI' OR DataSource = 'Manual')
   AND [Valid Till Date] IS NOT NULL
   AND [Valid Till Date] != '1900-01-01'
   AND [Valid Till Date] < @CurrentDate   
   AND IsActive = 1  
  
  END TRY  
  BEGIN CATCH  
  
 DECLARE @ErrorMessage VARCHAR(MAX);  
  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  
 --INSERT Error  
  
 EXEC AVL_InsertError '[AVL].[DeacvivateAccessForExpiry]',@ErrorMessage,0,0  
     
  END CATCH  
END
