/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[InsertDebtClassificationModeDetails_ML] 
	@ProjectID VARCHAR(MAX),
	@TimeTickerID  nvarchar(max),
@UserID nvarchar(max),
@causecode nvarchar(max) = NULL,
@resolutioncode nvarchar(max) = NULL,
@debt nvarchar(max)=NULL,          
@avoidable nvarchar(max)=NULL,          
@residual nvarchar(max)=NULL,          
@SupportTypeID int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
if(@SupportTypeID=1)
BEGIN
	IF NOT EXISTS(SELECT TimeTickerID from AVL.TRN_DebtClassificationModeDetails (NOLOCK) where TimeTickerID=@TimeTickerID)
	BEGIN
		insert into AVL.TRN_DebtClassificationModeDetails 
		(TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,
		UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode,
		SystemCauseCodeID,SystemResolutionCodeID, CauseCodeID, ResolutionCodeID) 
		values(@TimeTickerID,@debt,@avoidable,@residual,NULL,null,NULL,1,0,@UserID,GETDATE(),1,@causecode, @resolutioncode, NULL,NULL)
	END
    ELSE
	 BEGIN
		 UPDATE AVL.TRN_DebtClassificationModeDetails SET SystemDebtclassification=@debt,SystemAvoidableFlag=@avoidable,SystemResidualDebtFlag=@residual
		 ,UserDebtClassificationFlag=NULL,UserAvoidableFlag=NULL,UserResidualDebtFlag=NULL,SourceForPattern=1,DebtClassficationMode=1,
		 SystemCauseCodeID = @causecode, SystemResolutionCodeID = @resolutioncode, CauseCodeID = case when @causecode is not null then null else CauseCodeID end,
		 ResolutionCodeID = case when @resolutioncode is not null then null else ResolutionCodeID end,
		 ModifiedBy=@UserID,ModifiedDate=GETDATE() where TimeTickerID=@TimeTickerID

		 UPDATE TD SET TD.DebtClassificationMode =DCMD.DebtClassficationMode, TD.ResidualDebtMapID=DCMD.SystemResidualDebtFlag,  
   TD.AvoidableFlag=DCMD.SystemAvoidableFlag,TD.DebtClassificationMapID=DCMD.SystemDebtclassification,  
    TD.LastUpdatedDate=GETDATE(),TD.ModifiedDate=GETDATE(),        
    TD.ModifiedBy=@UserId        
                FROM [AVL].[TK_TRN_TicketDetail]  TD       
                JOIN AVL.TRN_DebtClassificationModeDetails DCMD ON DCMD.TimeTickerID=TD.TimeTickerID AND DCMD.Isdeleted=0    
    WHERE TD.TimeTickerID=@TimeTickerID

	 END
END
ELSE
BEGIN
	IF NOT EXISTS(SELECT TimeTickerID from AVL.TRN_InfraDebtClassificationModeDetails (NOLOCK) where TimeTickerID=@TimeTickerID)
	BEGIN
		insert into AVL.TRN_InfraDebtClassificationModeDetails 
		(TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,
		UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode,
		SystemCauseCodeID,SystemResolutionCodeID, CauseCodeID, ResolutionCodeID) 
		values(@TimeTickerID,@debt,@avoidable,@residual,NULL,null,NULL,1,0,@UserID,GETDATE(),1,@causecode, @resolutioncode, NULL,NULL)
	END
    ELSE
	 BEGIN
		 UPDATE AVL.TRN_InfraDebtClassificationModeDetails SET SystemDebtclassification=@debt,SystemAvoidableFlag=@avoidable,SystemResidualDebtFlag=@residual
		 ,UserDebtClassificationFlag=NULL,UserAvoidableFlag=NULL,UserResidualDebtFlag=NULL,SourceForPattern=1,DebtClassficationMode=1,
		 SystemCauseCodeID = @causecode, SystemResolutionCodeID = @resolutioncode, CauseCodeID = case when @causecode is not null then null else CauseCodeID end,
		 ResolutionCodeID = case when @resolutioncode is not null then null else ResolutionCodeID end,
		 ModifiedBy=@UserID,ModifiedDate=GETDATE() where TimeTickerID=@TimeTickerID

		  UPDATE TD SET TD.DebtClassificationMode =DCMD.DebtClassficationMode, TD.ResidualDebtMapID=DCMD.SystemResidualDebtFlag,  
   TD.AvoidableFlag=DCMD.SystemAvoidableFlag,TD.DebtClassificationMapID=DCMD.SystemDebtclassification,     
    TD.LastUpdatedDate=GETDATE(),TD.ModifiedDate=GETDATE(),        
    TD.ModifiedBy=@UserId        
                FROM [AVL].[TK_TRN_InfraTicketDetail]  TD       
                JOIN AVL.TRN_InfraDebtClassificationModeDetails DCMD ON DCMD.TimeTickerID=TD.TimeTickerID AND DCMD.Isdeleted=0    
    WHERE TD.TimeTickerID=@TimeTickerID  

	 END
END
 SET NOCOUNT OFF; 
END
