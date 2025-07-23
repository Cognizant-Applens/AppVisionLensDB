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
-- Author:  <Author,,Name>    
-- Create date: <Create Date,,>    
-- Description: <Description,,>    
-- =============================================    
CREATE PROCEDURE [AVL].[APP_INV_AddAppHierarchyDetailsToTemp]    
  @CustomerId int =null,    
  @isCognizant int =null,    
  @TVP_AppHierarchyUpload TVP_ApplicationHierarchyDetailsUpload READONLY      
AS    
BEGIN    
 BEGIN TRY    
 BEGIN TRAN    
 SET NOCOUNT ON;    
 TRUNCATE TABLE [dbo].[ApplicationHierarchyTemp]    
    
 INSERT INTO [dbo].[ApplicationHierarchyTemp]    
 (     
 [Hierarchy1]    
 ,[Hierarchy2]    
 ,[Hierarchy3]    
 ,[Hierarchy4]    
 ,[Hierarchy5]    
 ,[Hierarchy6]    
 ,[ApplicationName]    
 ,[CustomerId]    
 )    
 SELECT    
 SUBSTRING([Hierarchy1],1,50)    
 ,SUBSTRING([Hierarchy2],1,50)    
 ,SUBSTRING([Hierarchy3],1,50)    
 ,SUBSTRING([Hierarchy4],1,50)    
 ,SUBSTRING([Hierarchy5],1,50)    
 ,SUBSTRING([Hierarchy6],1,50)    
 ,[ApplicationName]    
 ,[CustomerId]    
 from @TVP_AppHierarchyUpload    
 SET NOCOUNT OFF;    
 COMMIT TRAN    
   END TRY      
BEGIN CATCH      
    
  DECLARE @ErrorMessage VARCHAR(MAX);    
    
  SELECT @ErrorMessage = ERROR_MESSAGE()    
  ROLLBACK TRAN    
      
  EXEC AVL_InsertError '[AVL].[APP_INV_AddAppHierarchyDetailsToTemp]', @ErrorMessage, 0,@CustomerId    
      
 END CATCH      
END 