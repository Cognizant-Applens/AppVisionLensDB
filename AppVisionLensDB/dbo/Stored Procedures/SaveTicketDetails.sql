/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/




CREATE PROCEDURE [dbo].[SaveTicketDetails]

@TicketID nvarchar(50),
@ApplicationID bigint,
@ProjectID bigint,
@EmployeeID nvarchar(50),
@OpenDate datetime,
@TicketTypeID bigint,
@PriorityID bigint,
@TicketDescription nvarchar(max),
@IsSDTicket bit,
@TicketStatus bigint,
@UserID bigint,
@AssignGroup nvarchar(50),
@IsCognizant int =NULL
AS
BEGIN
BEGIN TRY
BEGIN TRAN
DECLARE @DARTStatusID INT
SET @DARTStatusID=(SELECT ISNULL(TicketStatus_ID,0) FROM AVL.TK_MAP_ProjectStatusMapping WHERE ProjectID=@ProjectID AND StatusID=@TicketStatus)


if(@IsCognizant=1)
begin
INSERT INTO [AVL].[TK_TRN_TicketDetail] (TicketID,ApplicationID,ProjectID,AssignedTo,DARTStatusID,EffortTillDate,ServiceID,IsDeleted,CreatedDate,OpenDateTime,TicketCreateDate,
TicketTypeMapID,PriorityMapID,TicketStatusMapID,TicketDescription,IsSDTicket,CreatedBy,LastUpdatedDate) 
values (@TicketID,@ApplicationID,@ProjectID,@UserID,@DARTStatusID,'0.00',0,0,GETDATE(),ISNULL(@OpenDate,GETDATE()),GETDATE(),
@TicketTypeID,@PriorityID,@TicketStatus,@TicketDescription,@IsSDTicket,@EmployeeID,getdate())
 end

 if(@IsCognizant=0)
 begin
 INSERT INTO [AVL].[TK_TRN_TicketDetail] (TicketID,ApplicationID,ProjectID,AssignedTo,DARTStatusID,EffortTillDate,ServiceID,IsDeleted,CreatedDate,OpenDateTime,TicketCreateDate,
 TicketTypeMapID,PriorityMapID,TicketStatusMapID,TicketDescription,IsSDTicket,CreatedBy,LastUpdatedDate,[AssignmentGroup]) 
values (@TicketID,@ApplicationID,@ProjectID,@UserID,@DARTStatusID,'0.00',0,0,GETDATE(),ISNULL(@OpenDate,GETDATE()),GETDATE(),
@TicketTypeID,@PriorityID,@TicketStatus,@TicketDescription,@IsSDTicket,@EmployeeID,getdate(),@AssignGroup)

 end

 if(@IsSDTicket=1)
 begin
 UPDATE AVL.PRJ_IDGeneration SET NextID=NextID+1 WHERE ProjectID=@ProjectID 
  end
  COMMIT TRAN
  END TRY
  BEGIN CATCH
  	DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[SaveTicketDetails] ', @ErrorMessage, @ProjectID,0
		
  END CATCH

END

 

 --select * from [AVL].[TK_TRN_TicketDetail] where ticketid='DART0001169'
