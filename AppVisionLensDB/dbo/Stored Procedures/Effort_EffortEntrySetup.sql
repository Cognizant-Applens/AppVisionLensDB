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
-- Modified by : Boopathi
-- Modified For: PP work Profile configuration CR
-- description: getting effort entry details using customerID, projectID and userID
-- =============================================

--exec [dbo].[Effort_EffortEntrySetup] '308965','8245','17320'
CREATE PROCEDURE [dbo].[Effort_EffortEntrySetup] --'827309','7097','10337'    
@userid NVARCHAR(MAX),    
@customerid NVARCHAR(MAX),    
@projectid NVARCHAR(MAX)    
AS    
BEGIN    
SET NOCOUNT ON;
BEGIN TRY    
 SELECT EsaprojectId, EsaCustomerId, AssociateId into #tempAssociatedetails from   
  [RLE].[VW_ProjectLevelRoleAccessDetails] (NOLOCK)  
  WHERE associateid = @userid  
  SELECT     
   c.iseffortconfigured,    
   c.efforttrackingmethod,    
   c.isdaily,    
   c.timezoneid,    
   c.sdticketformat,    
   0 AS proconfigid,    
   pm.projectid,    
   EU.IsMailEnabled AS defaultermail,    
   pc.approvalmail,    
   c.customerid,    
   c.iscognizant,    
   EU.SharePathName AS SharePath,   
   TUPC.TicketSharePathUsers,    
   ISNULL(c.isefforttrackactivitywise,1) AS isefforttrackactivitywise,    
   SC.ALMTimeZoneId,    
   EU.EffortUploadType    
   FROM avl.customer c (NOLOCK)   
    LEFT JOIN avl.mas_projectmaster pm (NOLOCK) on c.customerid=pm.customerid    
    LEFT JOIN avl.map_projectconfig pc (NOLOCK) on  pm.projectid=pc.projectid    
    LEFT JOIN #tempAssociatedetails plra with (NOLOCK) on plra.ESAProjectID = pm.EsaProjectID and C.ESA_AccountID = plra.ESACustomerID    
    LEFT JOIN TicketUploadProjectConfiguration TUPC (NOLOCK) on TUPC.ProjectID=@ProjectID    
    LEFT JOIN AVL.EffortUploadConfiguration AS EU (NOLOCK) ON EU.ProjectID = @ProjectID    
    LEFT JOIN PP.ScopeOfWork SC (NOLOCK) ON SC.ProjectID = @ProjectID    
    WHERE c.isdeleted=0 and c.customerid= @customerid and plra.Associateid = @userid and pm.projectid = @projectid and pm.isdeleted=0    
END TRY    
BEGIN CATCH    
 DECLARE @ErrorMessage VARCHAR(MAX);    
 SELECT @ErrorMessage = ERROR_MESSAGE()    
 --INSERT Error    
 EXEC AVL_InsertError 'dbo.Effort_EffortEntrySetup',@ErrorMessage,@userid,@customerid       
END CATCH   
SET NOCOUNT OFF;
END
