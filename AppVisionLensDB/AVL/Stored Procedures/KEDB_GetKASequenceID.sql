/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--declare @KASequenceId nvarchar(50) 
--exec [AVL].[KEDB_GetKASequenceID]  10337,'KA' ,'260879', @KASequenceId output
--print @KASequenceId

CREATE Procedure [AVL].[KEDB_GetKASequenceID] -- 10337,'KA' , @KASequenceId    
 (       
 @ProjectID BIGINT,      
 @Type  NVarchar(20), 
 @CreatedBy NVarchar(50),
 @KASequenceId NVarchar(50) OUTPUT           
 )      
        
AS        
    SET NOCOUNT ON;    
BEGIN        
        
 BEGIN TRY        
      
 DECLARE @NextVal  bigint      
 DECLARE @ESAId  BIGINT      
   
      
 IF EXISTS (SELECT ProjectID  FROM [AVL].[TK_MAP_AHIDGeneration]     
   WHERE projectid= @ProjectID  and Category =@Type and isdeleted=0)      
  SELECT @NextVal = isnull(NextId,0)   from [AVL].[TK_MAP_AHIDGeneration]        
     WHERE projectid= @ProjectID  and isdeleted=0 and Category =@Type    
      
  ELSE      
  BEGIN      
            
   SELECT @ESAId = RIGHT(ESAProjectID,5) from  [AVL].[MAS_ProjectMaster] (nolock) WHERE ProjectId = @ProjectID      
        INSERT INTO [AVL].[TK_MAP_AHIDGeneration] (projectid,EsaprojectId,nextid,category,CreatedBy,CreataedDate,IsDeleted)       
       VALUES (@ProjectID,@ESAId,1,@Type,@CreatedBy,getdate(),0)     
      
    SELECT @NextVal =isnull(NextId,0) FROM [AVL].[TK_MAP_AHIDGeneration]     
     WHERE projectid= @ProjectID  and isdeleted=0 and Category =@Type    
 end      
      
       
 SELECT @KASequenceId = (ltrim(rtrim(Category))+CAST(EsaprojectId as VARCHAR(5))+ RIGHT('000000' + CAST(@NextVal AS VARCHAR(6)), 6))       
 from [AVL].[TK_MAP_AHIDGeneration]  where projectId = @ProjectID  and Category = @Type      
      
       
 END TRY          
        
 BEGIN CATCH          
        
  DECLARE @ErrorMessage VARCHAR(4000);
  SELECT @ErrorMessage = ERROR_MESSAGE()      
      
  --INSERT Error              
  --EXEC AVL_InsertError '[AVL].[KEDB_GetKATicketID]', @ErrorMessage,@CreatedBy,@ProjectID  
   
   
        
 END CATCH          
        
        
END
