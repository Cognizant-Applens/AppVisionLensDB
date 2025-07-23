/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE pROCEDURE [LW].[LW_RulesApproval]    
@flag varchar(20),  
    
@RuleID VARCHAR(1000),    
@UserID VARCHAR(50)    
    
AS    
BEGIN    
   
BEGIN TRY    
  IF(@flag= 'Delivery')      
BEGIN     
DECLARE @sql1 AS NVARCHAR(750);      
DECLARE @sql2 AS NVARCHAR(750);      
DECLARE @sql3 AS NVARCHAR(750);    
    
   set @sql1 = 'UPDATE [LW].[RuleTransaction] SET     
					   [LW].[RuleTransaction].[RuleStatusInd] = 1,    
					   [LW].[RuleTransaction].[ModifiedBy] = ('+ @UserID +'),    
					   [LW].[RuleTransaction].[ModifiedDate] = GETDATE()    
				 WHERE [LW].[RuleTransaction].[RecordID] IN  (' + @RuleID + ')' ;    
           
	EXEC sp_executesql @sql1;     
      
   set @sql2 = 'UPDATE [LW].[RuleTransaction] SET     
					   [LW].[RuleTransaction].[IsOveridden] = 1,    
					   [LW].[RuleTransaction].[ModifiedBy] = ('+ @UserID +'),    
					   [LW].[RuleTransaction].[ModifiedDate] = GETDATE()    
				 WHERE [LW].[RuleTransaction].[IsOveridden] = 2 AND    
					   [LW].[RuleTransaction].[NewRuleReferanceID] IN (' + @ruleId + ')' ;    
    
    EXEC sp_executesql @sql2;    
      
   set @sql3 = 'UPDATE [LW].[RuleApprovalDetails] SET     
					   [LW].[RuleApprovalDetails].[RuleStatus] = 1,    
					   [LW].[RuleApprovalDetails].[ApprovedBy] = (' + @UserID + '),    
					   [LW].[RuleApprovalDetails].[ApprovedDate] = GETDATE(),    
					   [LW].[RuleApprovalDetails].[ModifiedDate] = (' + @UserID + '),    
					   [LW].[RuleApprovalDetails].[ModifiedBy] = GETDATE()    
                 WHERE [LW].[RuleApprovalDetails].[TransRecordID] IN (' + @ruleId + ')';    
    EXEC sp_executesql @sql3;    
END 
 IF(@flag= 'Commercial')      
BEGIN    
 	set @sql1 =  'update bid.RuleTransaction  
				  set RuleStatusInd=4,  
				  [BID].[RuleTransaction].[ModifiedBy] = ('+ @UserID +'),    
				  [BID].[RuleTransaction].[ModifiedDate] = GETDATE()    
				  where RecordID in (select RecordID from bid.RuleTransaction   
				  where RuleReferanceID>0 and RuleStatusInd=1 and RuleReferanceID in   
				  (select RuleReferanceID from bid.RuleTransaction where RecordID IN (' + @ruleId + ')))';
	 EXEC sp_executesql @sql1; 

    set @sql2 = 'UPDATE [BID].[RuleTransaction] SET     
					    [BID].[RuleTransaction].[RuleStatusInd] = 1,    
					    [BID].[RuleTransaction].[ApprovedBy] = (' + @UserID + '),    
					    [BID].[RuleTransaction].[ApprovedDate] = GETDATE(),   
					    [BID].[RuleTransaction].[ModifiedBy] = ('+ @UserID +'),    
					    [BID].[RuleTransaction].[ModifiedDate] = GETDATE()    
				  WHERE [BID].[RuleTransaction].[RecordID] IN  (' + @RuleID + ')' ;         
      EXEC sp_executesql @sql2; 

END  
END TRY    
    
BEGIN CATCH    
DECLARE @ErrorMessage VARCHAR(MAX);    
    
              SELECT @ErrorMessage = ERROR_MESSAGE()    
    
              --INSERT Error        
              EXEC AVL_InsertError  '[LW].[LW_RulesApproval]',@ErrorMessage, @UserID ,0    
    
END CATCH    
END