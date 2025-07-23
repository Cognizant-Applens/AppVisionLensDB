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
-- Author      : 835658             
-- Create date : May 8, 2021              
-- Description : Get the project level role access details                  
-- Revision    :              
-- Revised By  :              
-- =========================================================================================              
      
      
CREATE View RLE.VW_ProjectLevelRoleAccessDetails                              
as                  
        
SELECT DISTINCT ApplensRoleID AS RoleMappingID,Associateid,AssociateName,  
Email,VerticalID,VerticalName,BusinessUnitID,BusinessUnitName,        
ESAProjectID,Projectid,projectname,Customerid,CustomerName,ESACustomerID,        
ApplensRoleID,RoleName,RoleKey,Datasource,0 AS isdeleted,priority,GroupName        
FROM RLE.VW_RoleDataAccessWithAllHierarchy  WITH (NOLOCK)          
WHERE TRIM(GroupName) ='Delivery'
