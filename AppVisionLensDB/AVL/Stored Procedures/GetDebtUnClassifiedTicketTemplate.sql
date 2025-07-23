/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
--[AVL].[GetDebtUnClassifiedTicketTemplate] 986      
CREATE PROCEDURE [AVL].[GetDebtUnClassifiedTicketTemplate](@ProjectID BIGINT)        
AS        
BEGIN        
    BEGIN TRY      
DECLARE @FlexField1 VARCHAR(100),@FlexField2 VARCHAR(100),@FlexField3 VARCHAR(100),@FlexField4 VARCHAR(100)            
            
SET @FlexField1 = (SELECT TOP 1            
  SCM.ProjectColumn            
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP            
 JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC            
  ON HPP.ColumnID = MC.ColumnID            
  AND MC.IsActive = 1            
 JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM            
  ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '')            
  AND SCM.ProjectID = @ProjectID AND IsDeleted = 0            
 WHERE HPP.ColumnID = 11            
 AND HPP.IsActive = 1            
 AND HPP.ProjectID = @ProjectID);            
            
SET @FlexField2 = (SELECT TOP 1            
  SCM.ProjectColumn            
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP            
 JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC            
  ON HPP.ColumnID = MC.ColumnID            
 AND MC.IsActive = 1             
 JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM            
  ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '')            
  AND SCM.ProjectID = @ProjectID AND IsDeleted = 0            
 WHERE HPP.ColumnID = 12            
 AND HPP.IsActive = 1             
 AND HPP.ProjectID = @ProjectID);            
            
SET @FlexField3 = (SELECT TOP 1            
  SCM.ProjectColumn            
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP            
 JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC            
  ON HPP.ColumnID = MC.ColumnID            
  AND MC.IsActive = 1            
 JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM            
  ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '')            
  AND SCM.ProjectID = @ProjectID AND IsDeleted = 0            
 WHERE HPP.ColumnID = 13            
 AND HPP.IsActive = 1             
 AND HPP.ProjectID = @ProjectID);            
            
SET @FlexField4 = (SELECT TOP 1            
  SCM.ProjectColumn            
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP            
 JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC            
  ON HPP.ColumnID = MC.ColumnID            
  AND MC.IsActive = 1            
 JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM            
  ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '')            
  AND SCM.ProjectID = @ProjectID AND IsDeleted = 0            
 WHERE HPP.ColumnID = 14            
 AND HPP.IsActive = 1            
 AND HPP.ProjectID = @ProjectID);            
        
        
 select 'Ticket ID' [Ticket ID], 'Debt Classification' [Debt Category],'Cause Code' [Cause Code],        
 'Resolution Code' [Resolution Code] ,'Avoidable Flag' [Avoidable], 'Residual Debt' [Residual],        
 ISNULL(@FlexField1,'') FlexField1,ISNULL(@FlexField2,'') FlexField2,        
 ISNULL(@FlexField3,'') FlexField3,ISNULL(@FlexField4,'') FlexField4      
     
 END TRY     
    
 BEGIN CATCH        
          
  DECLARE @ErrorMessage VARCHAR(4000);          
          
  SELECT @ErrorMessage = ERROR_MESSAGE()          
          
  --INSERT Error                                              
  EXEC AVL_InsertError '[AVL].[GetDebtUnClassifiedTicketTemplate]',@ErrorMessage,0          
          
END CATCH      
 END
