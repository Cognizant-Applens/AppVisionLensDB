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
-- author:      
-- create date:     
-- Modified by : 835658    
-- Modified For: RHMS New Role API    
-- description: getting customer is cognizant or not    
-- =============================================    
-- EXEC [dbo].[CheckCustomerIsCognizant] '237927','5464'    
CREATE procedure [dbo].[CheckCustomerIsCognizant]          
(          
@employeeid nvarchar(50),          
@customerid bigint          
)          
as           
  begin          
begin try     
  
SELECT ESACustomerID 'ESACustomerID' INTO #temproletable FROM [RLE].[VW_ProjectLevelRoleAccessDetails] PL(NOLOCK) Where PL.Associateid=@employeeid  
           
 SELECT           
 Distinct c.iscognizant,c.customerid,c.customername,c.isnonesamappingallowed          
 FROM          
 avl.customer c with (nolock)            
 join #temproletable PRA on PRA.ESACustomerID = c.Esa_AccountId                    
 where C.CustomerId=@customerid and c.isdeleted=0          
               
end try          
begin catch          
          
 DECLARE @ErrorMessage VARCHAR(MAX);          
          
 SELECT @ErrorMessage = ERROR_MESSAGE()          
          
 --INSERT Error          
          
 EXEC AVL_InsertError 'dbo.CheckCustomerIsCognizant',@ErrorMessage,0,@customerid          
             
end catch          
end
