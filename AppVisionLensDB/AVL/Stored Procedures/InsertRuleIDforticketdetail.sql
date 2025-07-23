/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[InsertRuleIDforticketdetail]   
  
@TimeTickerID bigint,  
@Ruleid bigint=NULL,  
@UserId varchar(max),  
@SupportTypeID int,  
@lwruleid BIGINT=NULL,  
@lwrulelevel VARCHAR(50)=NULL,
@ProjectID bigint=NULL,
@clusterDesc BIGINT=NULL,
@clusterReso BIGINT=NULL
AS  
BEGIN  
BEGIN TRY  
SET NOCOUNT ON;  
DECLARE @AlgorithmKey nvarchar(6);        
SET @AlgorithmKey=(SELECT TOP 1 AlgorithmKey FROM [ML].[TRN_MLTransaction] WHERE ProjectId =@ProjectID AND SupportTypeId = @SupportTypeID AND IsActiveTransaction=1 AND IsDeleted=0)        
    
IF(@AlgorithmKey = 'AL001')  
BEGIN  
 if(@SupportTypeID=1)  
 BEGIN  
  if(@Ruleid != '0' OR ISNULL(@lwruleid,0)!= 0)  
  BEGIN  
   if NOT EXISTS(select * from AVL.TK_TRN_TicketDetail_RuleID (NOLOCK) WHERE TimeTickerID = @TimeTickerID)  
   BEGIN  
   insert INTO AVL.TK_TRN_TicketDetail_RuleID   (TimeTickerID,RuleID,Createdby,CreatedDate,LWRuleID,LWRuleLevel)
   values(@TimeTickerID,@Ruleid,@UserId,GETDATE(),@lwruleid,@lwrulelevel)  
   END  
   ELSE  
   BEGIN  
    update AVL.TK_TRN_TicketDetail_RuleID   
    set RuleID = @Ruleid,LWRuleID=@lwruleid,LWRuleLevel=@lwrulelevel   
    WHERE TimeTickerID = @TimeTickerID  
   END  
  END  
  ELSE  
  BEGIN  
   if EXISTS(select * from AVL.TK_TRN_TicketDetail_RuleID (NOLOCK) WHERE TimeTickerID = @TimeTickerID)  
   BEGIN  
   DELETE FROM AVL.TK_TRN_TicketDetail_RuleID WHERE TimeTickerID = @TimeTickerID  
   END   
  END  
 END  
 ELSE  
 BEGIN  
   if(@Ruleid != '0' OR ISNULL(@lwruleid,0)!= 0)  
  BEGIN  
   if NOT EXISTS(select * from AVL.TK_TRN_InfraTicketDetail_RuleID (NOLOCK) WHERE TimeTickerID = @TimeTickerID)  
   BEGIN  
    insert INTO AVL.TK_TRN_InfraTicketDetail_RuleID   (TimeTickerID,RuleID,Createdby,CreatedDate,LWRuleID,LWRuleLevel)
    values(@TimeTickerID,@Ruleid,@UserId,GETDATE(),@lwruleid,@lwrulelevel)  
   END  
   ELSE  
   BEGIN  
    update AVL.TK_TRN_InfraTicketDetail_RuleID   
    set RuleID = @Ruleid,LWRuleID=@lwruleid,LWRuleLevel=@lwrulelevel   
    WHERE TimeTickerID = @TimeTickerID  
   END  
  END  
  ELSE  
  BEGIN  
   if EXISTS(select * from AVL.TK_TRN_InfraTicketDetail_RuleID (NOLOCK) WHERE TimeTickerID = @TimeTickerID)  
   BEGIN  
   DELETE FROM AVL.TK_TRN_InfraTicketDetail_RuleID WHERE TimeTickerID = @TimeTickerID  
   END   
  END  
 END   
END
ELSE
BEGIN
	 if(@SupportTypeID=1)  
 BEGIN  
  if(@clusterReso != '0' OR ISNULL(@clusterDesc,0)!= 0)  
  BEGIN  
   if NOT EXISTS(select * from AVL.TK_TRN_TicketDetail_RuleID (NOLOCK) WHERE TimeTickerID = @TimeTickerID)  
   BEGIN  
   insert INTO AVL.TK_TRN_TicketDetail_RuleID   (TimeTickerID,Createdby,CreatedDate,ClusterID_Desc,ClusterID_Resolution)
   values(@TimeTickerID,@UserId,GETDATE(),@clusterDesc,@clusterReso)  
   END  
   ELSE  
   BEGIN  
    update AVL.TK_TRN_TicketDetail_RuleID   
    set ClusterID_Desc= @clusterDesc,ClusterID_Resolution=@clusterReso
    WHERE TimeTickerID = @TimeTickerID  
   END  
  END  
  ELSE  
  BEGIN  
   if EXISTS(select * from AVL.TK_TRN_TicketDetail_RuleID (NOLOCK) WHERE TimeTickerID = @TimeTickerID)  
   BEGIN  
   DELETE FROM AVL.TK_TRN_TicketDetail_RuleID WHERE TimeTickerID = @TimeTickerID  
   END   
  END  
 END  
 ELSE  
 BEGIN  
   if(@clusterReso != '0' OR ISNULL(@clusterDesc,0)!= 0)
  BEGIN  
   if NOT EXISTS(select * from AVL.TK_TRN_InfraTicketDetail_RuleID (NOLOCK) WHERE TimeTickerID = @TimeTickerID)  
   BEGIN  
    insert INTO AVL.TK_TRN_InfraTicketDetail_RuleID    (TimeTickerID,Createdby,CreatedDate,ClusterID_Desc,ClusterID_Resolution)  
    values(@TimeTickerID,@UserId,GETDATE(),@clusterDesc,@clusterReso)  
   END  
   ELSE  
   BEGIN  
    update AVL.TK_TRN_InfraTicketDetail_RuleID   
    set ClusterID_Desc= @clusterDesc,ClusterID_Resolution=@clusterReso
    WHERE TimeTickerID = @TimeTickerID  
   END  
  END  
  ELSE  
  BEGIN  
   if EXISTS(select * from AVL.TK_TRN_InfraTicketDetail_RuleID (NOLOCK) WHERE TimeTickerID = @TimeTickerID)  
   BEGIN  
   DELETE FROM AVL.TK_TRN_InfraTicketDetail_RuleID WHERE TimeTickerID = @TimeTickerID  
   END   
  END  
 END   
END
SET NOCOUNT OFF;  
END TRY  
BEGIN CATCH  
DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[InsertRuleIDforticketdetail]', @ErrorMessage ,''  
END CATCH  
END
