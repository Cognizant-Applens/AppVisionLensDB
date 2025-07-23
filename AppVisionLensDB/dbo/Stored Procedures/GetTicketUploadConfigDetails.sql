/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
 
 -- ====================================================================
-- author:		
-- create date: 
-- Modified by : 686186
-- Modified For: RHMS CR
-- description: getting ticket upload config details using customerID,projectID and employeeid
-- ====================================================================

-- EXEC [dbo].[GetTicketUploadConfigDetails] '104559',11999,7297

CREATE proc [dbo].[GetTicketUploadConfigDetails] --'827309',10337,7097      
@EmployeeID varchar(20)=null,      
@ProjectID bigint=null,      
@CustomerID int=null      
as      
begin      
BEGIN TRY      
BEGIN TRAN   

IF OBJECT_ID('tempdb..#tempAssociateDetails') IS NOT NULL
begin
    DROP TABLE #tempAssociateDetails
End 

  SELECT Associateid, Esaprojectid, EsaCustomerId into #tempAssociateDetails from   
  [RLE].[VW_ProjectLevelRoleAccessDetails] PL (NOLOCK)  
  where PL.AssociateId = @Employeeid  
Declare @EsaAccount_Id nvarchar(50)    
    
SELECT @EsaAccount_Id=Esa_AccountId from AVL.Customer C (NOLOCK) where CustomerId=@CustomerID and Isdeleted=0    
    
 select      
 ITSM.ITSMName as ITSMName,      
  TUPC.IsManualOrAuto as IsManualOrAuto,      
 TUPC.SharePath as SharePath,      
 TUPC.Ismailer as Ismailer,      
 TUPC.TicketSharePathUsers as TicketSharePathUsers,      
 ISNULL(PC.TimeZoneId,0) AS ProjectTimeZoneId      
 from [AVL].[MAS_ProjectMaster] B (NOLOCK)         
 left join AVL.MAS_ITSMTools ITSM (NOLOCK) on ITSM.ITSMID=B.ITSMID      
 LEFT JOIN #tempAssociateDetails plra (NOLOCK) on  plra.ESAProjectID=B.ESAProjectId and plra.ESACustomerID = @EsaAccount_Id    
 left join TicketUploadProjectConfiguration TUPC (NOLOCK)  on TUPC.ProjectID=@ProjectID      
 LEFT JOIN AVL.MAP_ProjectConfig PC (NOLOCK) ON B.ProjectID=PC.ProjectID      
 where B.ProjectID=@ProjectID  and B.isdeleted=0      
 COMMIT TRAN      
END TRY        
BEGIN CATCH        
      
  DECLARE @ErrorMessage VARCHAR(MAX);      
      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
  ROLLBACK TRAN      
  --INSERT Error          
  EXEC AVL_InsertError 'dbo.GetTicketUploadConfigDetails ', @ErrorMessage, @EmployeeID ,@CustomerID      
        
 END CATCH        
end
