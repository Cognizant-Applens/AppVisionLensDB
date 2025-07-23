
CREATE PROCEDURE [AVL].[KEDB_UpdateKTicketDetails]   
  (              
                   
 @ProjectID VARCHAR(50)  ,  
 @HealingTicketID NVARCHAR(50),  
 @UserId nVARCHAR(50),  
 @PriorityId int,  
 @Description nvarchar(max),  
 @CancelOptionId int=0,  
 @CancelReason nvarchar(max)=null,  
 @CancelDate nvarchar(50)=null  
  )  
AS  
BEGIN    
BEGIN TRY   
  SET NOCOUNT ON;  
  
    
Update [AVL].[DEBT_TRN_HealTicketDetails]  
set PriorityID = @PriorityId,  
TicketDescription = @Description,  
ModifiedBy = @UserId,  
ModifiedDate = GETDATE()  
where HealingTicketID = @HealingTicketID and IsDeleted=0  
  
IF(@CancelOptionId<>0)  
BEGIN   
Update [AVL].[DEBT_TRN_HealTicketDetails] SET DARTStatusID=5,ModifiedBy=@UserId,  
Modifieddate=getdate(),CancellationDate=getDate(),
ReasonForCancellation=(SELECT OptionName FROM [AVL].[MAS_KTicketCancelOptions] WHERE OptionID=@CancelOptionId),
Comments=@CancelReason
WHERE HealingTicketID=@HealingTicketID  
END  

   END TRY  
  BEGIN CATCH  
  DECLARE @ErrorMessage VARCHAR(4000);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[KEDB_UpdateKTicketDetails] ', @ErrorMessage,@UserId,@ProjectID  
  RETURN @ErrorMessage  
  END CATCH     
END  
