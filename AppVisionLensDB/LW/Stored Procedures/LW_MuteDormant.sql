/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [LW].[LW_MuteDormant]    
@flag VARCHAR(20),  
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
					   [LW].[RuleTransaction].[RuleStatusInd] = 2,    
					   [LW].[RuleTransaction].[ModifiedBy] = ('+ @UserID +'),    
					   [LW].[RuleTransaction].[ModifiedDate] = GETDATE()    
                 WHERE [LW].[RuleTransaction].[RecordID] IN (' + @RuleID + ')';    
    EXEC sp_executesql @sql1;    
        
        
    set @sql2 = 'UPDATE [LW].[RuleUsage] SET     
						[LW].[RuleUsage].[IsDormant] = 0,    
						[LW].[RuleUsage].[ModifiedBy] = ('+ @UserID +'),    
						[LW].[RuleUsage].[ModifiedDate] = GETDATE()    
                  WHERE	[LW].[RuleUsage].[TransRecordID] IN (' + @RuleID + ')';    
    EXEC sp_executesql @sql2;    
    
 set @sql3 = 'UPDATE [LW].[RuleApprovalDetails] SET     
					 [LW].[RuleApprovalDetails].[RuleStatus] = 2,    
					 [LW].[RuleApprovalDetails].[MutedBy] = ('+ @UserID +'),    
					 [LW].[RuleApprovalDetails].[MutedDate] = GETDATE(),    
					 [LW].[RuleApprovalDetails].[ModifiedBy] = ('+ @UserID +'),    
					 [LW].[RuleApprovalDetails].[ModifiedDate] = GETDATE()    
               WHERE [LW].[RuleApprovalDetails].[TransRecordID] IN (' + @RuleID + ')';    
    EXEC sp_executesql @sql3;    
END  
  
IF(@flag= 'Commercial')    
BEGIN   
  
set @sql1 = 'UPDATE [bid].[RuleTransaction] SET     
                    [bid].[RuleTransaction].[RuleStatusInd] = 2,    
					[bid].[RuleTransaction].[ModifiedBy] = ('+ @UserID +'),    
					[bid].[RuleTransaction].[ModifiedDate] = GETDATE()    
              WHERE [bid].[RuleTransaction].[RecordID] IN (' + @RuleID + ')';    
    EXEC sp_executesql @sql1;    
        
        
    set @sql2 = 'UPDATE [bid].[RuleTransaction] SET     
						[bid].[RuleTransaction].[IsDormant] = 0,    
						[bid].[RuleTransaction].[ModifiedBy] = ('+ @UserID +'),    
						[bid].[RuleTransaction].[ModifiedDate] = GETDATE()    
				  WHERE [bid].[RuleTransaction].[RecordID] IN (' + @RuleID + ')';    
    EXEC sp_executesql @sql2;    
    
 set @sql3 = 'UPDATE [bid].[RuleTransaction] SET     
					 [bid].[RuleTransaction].[RuleStatusInd] = 2,    
					 [bid].[RuleTransaction].[MutedBy] = ('+ @UserID +'),    
					 [bid].[RuleTransaction].[MutedDate] = GETDATE(),    
					 [bid].[RuleTransaction].[ModifiedBy] = ('+ @UserID +'),    
					 [bid].[RuleTransaction].[ModifiedDate] = GETDATE()    
               WHERE [bid].[RuleTransaction].[RecordID] IN (' + @RuleID + ')';    
    EXEC sp_executesql @sql3;  
  
END  
END TRY    
BEGIN CATCH    
 DECLARE @ErrorMessage VARCHAR(MAX);    
    
 SELECT    
  @ErrorMessage = ERROR_MESSAGE()    
    
 --INSERT Error          
 EXEC AVL_INSERTERROR '[LW].[LW_MuteDormant]'    
       ,@ErrorMessage    
       ,@UserID    
       ,0    
 END CATCH    
END