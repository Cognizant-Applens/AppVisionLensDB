 /***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

 CREATE PROCEDURE [ML].[CheckMultiAlgorithmConfigured] --10337                   
 @projectid bigint                            
AS                            
BEGIN                         
 DECLARE @Esaprojectid nvarchar(50);                  
 Select @Esaprojectid = Esaprojectid from avl.mas_projectmaster WITH(NOLOCK)               
 where projectid = @projectid and isdeleted = 0                          
 SET NOCOUNT ON;                            
 BEGIN TRY                    
 IF EXISTS(select Top 1 Algorithmid as isMultiAlgoEnabled from pp.MLMultiAlgoConfiguration WITH(NOLOCK)     
 where projectid=@projectid and Isdeleted=0)                  
 BEGIN                  
 select 1  as 'isMultiAlgoEnabled'                   
 END                  
 ELSE                  
 BEGIN                  
 SELECT 0 as 'isMultiAlgoEnabled'             
 --select top 2 AssociateId from RLE.VW_ProjectLevelRoleAccessDetails where rolekey = 'RLE052' and Esaprojectid = @Esaprojectid            
 END                  
    select string_agg(AssociateId, ',')  as AssociateId            
 from (select distinct top 5 associateId from RLE.VW_ProjectLevelRoleAccessDetails WITH(NOLOCK)     
 where rolekey = 'RLE052' and isdeleted=0    
 and Esaprojectid = @Esaprojectid) TempView            
END TRY                            
BEGIN CATCH                            
 SELECT                            
  ERROR_NUMBER() AS ErrorNumber,                            
  ERROR_STATE() AS ErrorState,                            
  ERROR_SEVERITY() AS ErrorSeverity,                            
  ERROR_PROCEDURE() AS ErrorProcedure,                            
  ERROR_LINE() AS ErrorLine,                            
  ERROR_MESSAGE() AS ErrorMessage;                            
END CATCH;                            
END
