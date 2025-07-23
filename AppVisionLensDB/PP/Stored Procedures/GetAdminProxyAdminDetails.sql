/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetAdminProxyAdminDetails] --'10337'       
(          
@projectid INT         
)          
AS          
BEGIN TRY        
  SET NOCOUNT ON;      
  Declare @esaprojectid int        
      
 set @esaprojectid = (select EsaProjectID from avl.MAS_ProjectMaster (NOLOCK) where ProjectID = @projectid)      
      
 select distinct AssociateId, AssociateName, Email into #Temp from  RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK)         
 where rolekey in ('RLE004','RLE005') and  esaprojectid = @esaprojectid      
       
 SELECT         
 distinct          
 AssociateId as EmployeeID,          
 AssociateName as EmployeeName,        
 Email as EmployeeEmail           
 FROM #Temp    
SET NOCOUNT OFF;        
END TRY          
        
BEGIN CATCH          
        
 DECLARE @ErrorMessage VARCHAR(MAX);        
        
 SELECT @ErrorMessage = ERROR_MESSAGE()        
        
 EXEC AVL_InsertError '[PP].[sp_GetAdminProxyAdminDetails]', @ErrorMessage, @projectid,0        
        
END CATCH
