/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[ml_getadd_textfordebt] --1188    
 @projectid varchar(max),    
 @SupportTypeID int= null     
as    
BEGIN    
SET NOCOUNT ON; 
BEGIN TRY    
Declare @CountForAddPattern BIGINT    
if(@SupportTypeID=1)    
begin    
 select @CountForAddPattern=COUNT(DISTINCT ID) from ML.TRN_PatternValidation (NOLOCK) where ProjectID=@projectid and IsDeleted=0 and IsApprovedOrMute=1    
 and additionalPattern<>'0'    
end    
else    
begin     
 select @CountForAddPattern=COUNT(DISTINCT ID) from ML.InfraTRN_PatternValidation (NOLOCK) where ProjectID=@projectid and IsDeleted=0 and IsApprovedOrMute=1    
 and additionalPattern<>'0'    
end    
    
    
IF(@CountForAddPattern>0)  
BEGIN  
 IF(@SupportTypeID=1 OR @SupportTypeID=2)  
 BEGIN    
  SELECT 'Resolution Remarks' AS optionalfields    
 END  
 --ELSE IF(@SupportTypeID=2)  
 --BEGIN  
 -- SELECT OptionalFields FROM AVL.ML_MAS_OptionalFields WHERE ID=1 AND IsDeleted=0  
 --END  
END  
ELSE  
BEGIN  
 SELECT 'NA' AS optionalfields  
END    
 --select op.optionalfields from avl.ml_map_optionalprojmapping opm     
 --join avl.ml_mas_optionalfields op on opm.optionalfieldid=op.id    
 -- where opm.projectid=@projectid  and opm.optionalfieldid=op.id and opm.isactive=1 and op.isdeleted=0    
      
END TRY    
BEGIN CATCH    
    
 DECLARE @ErrorMessage VARCHAR(MAX);    
    
 SELECT @ErrorMessage = ERROR_MESSAGE()    
    
 --INSERT Error    
    
 EXEC AVL_InsertError 'dbo.ML_Getadd_textforDebt',@ErrorMessage,0,0    
       
END CATCH    
SET NOCOUNT OFF; 
END
