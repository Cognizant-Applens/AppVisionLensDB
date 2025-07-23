/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE StoreWorkItemUploadStatus (  
 @UploadedFileName NVARCHAR(100),  
 @ProjectID BIGINT,  
 @UploadMode NVARCHAR(50),  
 @TemplateType NVARCHAR(50),  
 @TotalWorkItems INT,  
 @UploadedStartTime DATETIME,  
 @UploadedEndTime DATETIME,  
 @Status NVARCHAR(50),  
 @ErrorFileName NVARCHAR(200) = NULL,  
 @CreatedBy NVARCHAR(50))    
AS     
BEGIN TRAN 
BEGIN TRY    
  INSERT INTO ADM.ALM_TRN_WorkItemUploadStatus (    
    UploadedFileName,    
    ProjectID,    
    UploadMode,    
    TemplateType,    
    TotalWorkItems,    
    UploadedStartTime,    
    UploadedEndTime,    
    [Status],    
    ErrorFileName,    
    CreatedBy,    
    CreatedDate)    
  VALUES (@UploadedFileName,    
    @ProjectID,    
    @UploadMode,    
    @TemplateType,    
    @TotalWorkItems,    
    @UploadedStartTime,    
    @UploadedEndTime,    
    @Status,    
    @ErrorFileName,    
    @CreatedBy,    
    GETDATE())    
   COMMIT TRAN 
END TRY   
BEGIN CATCH      
    ROLLBACK 
  DECLARE @ErrorMessage VARCHAR(MAX);    
    
  SELECT @ErrorMessage = ERROR_MESSAGE()    
    
  --INSERT Error        
  EXEC AVL_InsertError '[StoreWorkItemUploadStatus] ', @ErrorMessage, @ProjectID    
      
END CATCH
