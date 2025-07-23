/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- Author:      Prakash     
-- Create date:      23 Nov 2018
-- Description:   get user details
-- AppVisionLens - App Lens DB, [AVMDART] - AVM DART DB
--   EXEC  [AVL].[Mini_SaveSessionDetails] '471742','UPDATE',25753,'47174215Nov201811','','11/15/2018 5:01:17 AM',null,false,55,754,null,0,false,null,true,0,null,60,null,0,3,111,10115,845,null,false,'11/15/2018 3:31:29 PM'

-- ============================================================================ 

CREATE PROCEDURE [AVL].[Mini_SaveSessionDetails]
(
@EmployeeID NVARCHAR(50),
@Mode NVARCHAR(20),
@ProjectID bigint = null, 
@UserID bigint = null,
@TicketID nvarchar(50) = null,
@TicketDesc nvarchar(max)=null,
@TicketOpenDate datetime = null,
@StartTime datetime = null,
@IsAuto bit = null,
@ActivityID int =null,
@ApplicationID bigint = null,
@EndTime datetime=null,
@Hours int =null,
@IsNonDelivery bit = null,
@IsProcessed int = null,
@IsSDTicket bit = null,
@Minutes int = null,
@NonDeliveryActivityType int = null,
@PriorityMapID bigint = null,
@RequestSource int = null,
@Seconds int = null,
@ServiceID int = null,
@TicketStatusMapID bigint = null,
@TicketTypeMapID bigint = null,
@SessionID bigint = null,
@IsRunning bit = null,
@NonTicketDescription NVARCHAR(250) =NULL,
@UserDateTime DATETIME =NULL,
@SuggestedActivity VARCHAR(50) = NULL
)
AS 
BEGIN
BEGIN TRY  
BEGIN TRAN
SET NOCOUNT ON;     
	DECLARE @Curent_sessionID bigint
	--DECLARE @IsSDTicket INT=NULL;
SET @UserID=(SELECT TOP 1 UserID FROM AVL.MAS_LoginMaster(NOLOCK) WHERE EmployeeID=@EmployeeID AND ProjectID=@ProjectID
			AND IsDeleted=0 ORDER BY UserID DESC)
--IF UPPER(@Mode)='DART INSERT'
--BEGIN
--	set @TicketID= CONVERT(VARCHAR(MAX),'No Ticket')
--END

--Block 1 for insert to mini sessions
IF (UPPER(@Mode)='INSERT' OR UPPER(@Mode)='DART INSERT')
	BEGIN
			set @TicketID= CONVERT(VARCHAR(MAX),'No Ticket')
			IF(UPPER(@Mode)='DART INSERT')
				BEGIN
				
						DECLARE @Counter AS INT  
						SET @Counter=0  
						SELECT @Counter=count(DISTINCT TicketID) FROM  AVL.TK_Mini_Sessions (NOLOCK) WHERE EmployeeID=@EmployeeID --UserID = @UserID AND ProjectID = @ProjectID 
						AND TicketID LIKE @EmployeeID  + '%' 
						AND DATEDIFF(dd,CONVERT(DATETIME,SUBSTRING(TicketID, 7, 9)),GETDATE()) = 0
						SET @Counter=@Counter+1  
						SET @TicketID= CONVERT(VARCHAR(MAX),@EmployeeID)+REPLACE(CONVERT(VARCHAR, GETDATE(), 106),' ','')+CONVERT(VARCHAR(MAX),@Counter)  
						SET @IsSDTicket=1;
						--SELECT @TicketID
				END

			INSERT INTO AVL.TK_Mini_Sessions(EmployeeID,ProjectID,UserID,TicketID,TicketOpenDate,StartTime,EndTime,IsDeleted, CreatedOn,CreatedBy,IsRunning,IsSDTicket,UserCreatedTimeDate)
			SELECT @EmployeeID,@ProjectID,@UserID,@TicketID, @TicketOpenDate,ISNULL(@StartTime,GETDATE()),NULL,0,GETDATE(),@EmployeeID,0,@IsSDTicket,@UserDateTime
		
		
			SET @Curent_sessionID = @@identity
																																			SELECT SessionID,
				UserID,
				ProjectID,
				TicketID,
				TicketDesc,
				TicketOpenDate,
				ApplicationID,
				ServiceID,
				ActivityID,
				TicketTypeMapID,
				PriorityMapID,
				TicketStatusMapID ,
				StartTime ,
				EndTime,
				IsAuto,
				Hours,
				Minutes,
				Seconds,
				IsProcessed	,
				EmployeeID,
				RequestSource	,
				IsSDTicket,
				IsNonDelivery,
				NonDeliveryActivityType,
				IsDeleted,
				CreatedOn,
				CreatedBy,
				ModifiedOn,
				ModifiedBy,
				TimeTickerID,
				IsRunning,
				NonTicketDescription,
				SuggestedActivityName
				FROM AVL.TK_Mini_Sessions	where SessionID = @Curent_sessionID

	END
	IF (UPPER(@Mode)='AUTOASSIGNINSERT')
	BEGIN
			set @TicketID= @TicketID


			INSERT INTO AVL.TK_Mini_Sessions(EmployeeID,ProjectID,UserID,TicketID,TicketOpenDate,StartTime,EndTime,IsDeleted, CreatedOn,CreatedBy,IsRunning,IsSDTicket,UserCreatedTimeDate)
			SELECT @EmployeeID,@ProjectID,@UserID,@TicketID, @TicketOpenDate,ISNULL(@StartTime,GETDATE()),NULL,0,GETDATE(),@EmployeeID,0,@IsSDTicket,@UserDateTime
		
		
			SET @Curent_sessionID = @@identity
																																			SELECT SessionID,
				UserID,
				ProjectID,
				TicketID,
				TicketDesc,
				TicketOpenDate,
				ApplicationID,
				ServiceID,
				ActivityID,
				TicketTypeMapID,
				PriorityMapID,
				TicketStatusMapID ,
				StartTime ,
				EndTime,
				IsAuto,
				Hours,
				Minutes,
				Seconds,
				IsProcessed	,
				EmployeeID,
				RequestSource	,
				IsSDTicket,
				IsNonDelivery,
				NonDeliveryActivityType,
				IsDeleted,
				CreatedOn,
				CreatedBy,
				ModifiedOn,
				ModifiedBy,
				TimeTickerID,
				IsRunning,
				NonTicketDescription,
				SuggestedActivityName
				FROM AVL.TK_Mini_Sessions	where SessionID = @Curent_sessionID

	END
IF(UPPER(@Mode)='UPDATE')
BEGIN
	IF (ISNULL(@SessionID,0)>0 AND ISNULL(@UserID,0)>0 AND ISNULL(@ProjectID,0)>0)
	BEGIN
		--Update block to mini session table
		IF EXISTS (SELECT SessionID from AVL.TK_Mini_Sessions where SessionID=@SessionID)
		BEGIN
			UPDATE AVL.TK_Mini_Sessions 
					SET UserID=@UserID,
						ProjectID=@ProjectID,
						TicketID=@TicketID,
						TicketDesc=@TicketDesc,
						TicketOpenDate=@TicketOpenDate,
						ApplicationID=@ApplicationID,
						ServiceID=@ServiceID,
						ActivityID=@ActivityID,
						TicketTypeMapID=@TicketTypeMapID,
						PriorityMapID=@PriorityMapID,
						TicketStatusMapID=@TicketStatusMapID,
						EndTime=@EndTime,
						IsAuto=@IsAuto,
						--[Hours]=@Hours,
						--[Minutes]=@Minutes,
						--Seconds=@Seconds,
						RequestSource=@RequestSource,
						IsSDTicket=@IsSDTicket,
						IsNonDelivery=@IsNonDelivery,
						NonDeliveryActivityType=@NonDeliveryActivityType,
						ModifiedOn=GETDATE(),
						ModifiedBy=@EmployeeID,
						IsRunning=@IsRunning,
						NonTicketDescription=@NonTicketDescription,
						SuggestedActivityName=@SuggestedActivity
						WHERE  SessionID = @SessionID 

						--Code block when same ticket is changed in different session
						UPDATE AVL.TK_Mini_Sessions 
						SET 
						TicketDesc=@TicketDesc,
						TicketOpenDate=@TicketOpenDate,
						ApplicationID=@ApplicationID,
						TicketTypeMapID=@TicketTypeMapID,
						PriorityMapID=@PriorityMapID,
						TicketStatusMapID=@TicketStatusMapID,
						ModifiedOn=GETDATE(),
						ModifiedBy=@EmployeeID
						WHERE  ProjectID=@ProjectID and TicketID=@TicketID and CreatedBy=@EmployeeID
						and ISNULL(IsNonDelivery,0) =0


						UPDATE AVL.TK_Mini_Sessions 
						SET 
						ServiceID=@ServiceID,
						ActivityID=@ActivityID,
						ModifiedOn=GETDATE(),
						ModifiedBy=@EmployeeID
						WHERE  ProjectID=@ProjectID and TicketID=@TicketID and CreatedBy=@EmployeeID
						and ISNULL(IsNonDelivery,0) =0 AND ServiceID != @ServiceID
				
				DECLARE @TimeTickerID BIGINT
				SET @TimeTickerID = (SELECT TOP 1 TimeTickerID from AVL.TK_TRN_TicketDetail(NOLOCK) 
										WHERE ProjectID=@ProjectID and TicketID=@TicketID and IsDeleted=0)
				
					UPDATE AVL.TK_Mini_Sessions set TimeTickerID=@TimeTickerID 
							where ProjectID=@ProjectID and TicketID=@TicketID 
						--Code Block end

						IF @IsRunning=1
						BEGIN
							UPDATE AVL.TK_Mini_Sessions 
							SET [Hours]=@Hours,
							[Minutes]=@Minutes,
							Seconds=@Seconds
							WHERE  SessionID = @SessionID 

						END

			SELECT SessionID,
				UserID,
				ProjectID,
				TicketID,
				TicketDesc,
				TicketOpenDate,
				ApplicationID,
				ServiceID,
				ActivityID,
				TicketTypeMapID,
				PriorityMapID,
				TicketStatusMapID ,
				StartTime ,
				EndTime,
				IsAuto,
				Hours,
				Minutes,
				Seconds,
				IsProcessed	,
				EmployeeID,
				RequestSource	,
				IsSDTicket,
				IsNonDelivery,
				NonDeliveryActivityType,
				IsDeleted,
				CreatedOn,
				CreatedBy,
				ModifiedOn,
				ModifiedBy,
				TimeTickerID,
				IsRunning,
				NonTicketDescription,
				SuggestedActivityName
				FROM AVL.TK_Mini_Sessions	where SessionID = @SessionID			
		END
		--Update and insert block to ticket details table
		--IF(ISNULL(@ProjectID,0)>0 AND ISNULL(@TicketID,'')<>'')
			--BEGIN
			--	DECLARE @TimeTickerIDSelect BIGINT
			--	SET @TimeTickerIDSelect =(SELECT TimeTickerID from AVL.TK_TRN_TicketDetail WHERE ProjectID=@ProjectID and TicketID=@TicketID and IsDeleted=0)
			--		IF(ISNULL(@TimeTickerIDSelect,0)>0)
						--BEGIN
							--UPDATE	AVL.TK_TRN_TicketDetail 
							--SET ApplicationID=@ApplicationID,
							--AssignedTo=@UserID,
							--ServiceID=@ServiceID,
							--TicketTypeMapID=@TicketTypeMapID,
							--OpenDateTime=@TicketOpenDate,
							--LastUpdatedDate=GETDATE(),
							--ModifiedBy=@EmployeeID,
							--ModifiedDate=GETDATE()
							
							--WHERE TimeTickerID=@TimeTickerID

							--UPDATE AVL.TK_Mini_Sessions set TimeTickerID=@TimeTickerIDSelect 
							--where ProjectID=@ProjectID and TicketID=@TicketID AND @TimeTickerIDSelect >0 

						--END
					--ELSE 
					--	BEGIN
							--INSERT INTO AVL.TK_TRN_TicketDetail
							--(TicketID,ProjectID,ApplicationID,AssignedTo,ServiceID,TicketDescription,EffortTillDate,
							--IsDeleted,PriorityMapID,TicketTypeMapID,TicketStatusMapID,IsSDTicket,DARTStatusID,CreatedBy,CreatedDate,LastUpdatedDate,OpenDateTime)
							--SELECT @TicketID,@ProjectID,@ApplicationID,	@UserID,ISNULL(@ServiceID,0),@TicketDesc,0,0,@PriorityMapID,
							--@TicketTypeMapID,@TicketStatusMapID,@IsSDTicket,1,@EmployeeID,GETDATE(),GETDATE(),@TicketOpenDate

							--DECLARE @NewTimeTickerID BIGINT
							--SET @NewTimeTickerID=SCOPE_IDENTITY()

							--UPDATE AVL.TK_Mini_Sessions set TimeTickerID=@NewTimeTickerID where SessionID=@SessionID			
						
						--END
			--END
	END
	--Block when session id is empty, insert to mini session table
	ELSE
		BEGIN
			IF(@TicketID<>'')
				BEGIN
					INSERT INTO AVL.TK_Mini_Sessions(EmployeeID,ProjectID,UserID,TicketID,TicketDesc, TicketOpenDate,StartTime,EndTime,IsDeleted, CreatedOn,CreatedBy,NonTicketDescription,IsRunning,UserCreatedTimeDate,SuggestedActivityName)
					SELECT @EmployeeID,@ProjectID,@UserID,@TicketID,@TicketDesc, @TicketOpenDate,ISNULL(@StartTime,GETDATE()),NULL,0,GETDATE(),@EmployeeID,@NonTicketDescription,@Isrunning,@UserDateTime,@SuggestedActivity
					
					SET @Curent_sessionID = @@identity
																																			SELECT SessionID,
				UserID,
				ProjectID,
				TicketID,
				TicketDesc,
				TicketOpenDate,
				ApplicationID,
				ServiceID,
				ActivityID,
				TicketTypeMapID,
				PriorityMapID,
				TicketStatusMapID ,
				StartTime ,
				EndTime,
				IsAuto,
				Hours,
				Minutes,
				Seconds,
				IsProcessed	,
				EmployeeID,
				RequestSource	,
				IsSDTicket,
				IsNonDelivery,
				NonDeliveryActivityType,
				IsDeleted,
				CreatedOn,
				CreatedBy,
				ModifiedOn,
				ModifiedBy,
				TimeTickerID,
				IsRunning,
				NonTicketDescription,
				SuggestedActivityName
				FROM AVL.TK_Mini_Sessions	where SessionID = @Curent_sessionID
				
				END
			ELSE
				BEGIN
					INSERT INTO AVL.TK_Mini_Sessions(EmployeeID,ProjectID,UserID,TicketOpenDate,StartTime,EndTime,IsDeleted, CreatedOn,CreatedBy,IsNonDelivery,NonDeliveryActivityType,NonTicketDescription,IsRunning,SuggestedActivityName)
					SELECT @EmployeeID,@ProjectID,@UserID, @TicketOpenDate,ISNULL(@StartTime,GETDATE()),NULL,0,GETDATE(),@EmployeeID,@IsNonDelivery,@NonDeliveryActivityType,@NonTicketDescription,@Isrunning,@SuggestedActivity
					
					SET @Curent_sessionID = @@identity
																																			SELECT SessionID,
				UserID,
				ProjectID,
				TicketID,
				TicketDesc,
				TicketOpenDate,
				ApplicationID,
				ServiceID,
				ActivityID,
				TicketTypeMapID,
				PriorityMapID,
				TicketStatusMapID ,
				StartTime ,
				EndTime,
				IsAuto,
				Hours,
				Minutes,
				Seconds,
				IsProcessed	,
				EmployeeID,
				RequestSource	,
				IsSDTicket,
				IsNonDelivery,
				NonDeliveryActivityType,
				IsDeleted,
				CreatedOn,
				CreatedBy,
				ModifiedOn,
				ModifiedBy,
				TimeTickerID,
				IsRunning,
				NonTicketDescription,
				SuggestedActivityName
				FROM AVL.TK_Mini_Sessions	where SessionID = @Curent_sessionID
				END
		END
END

IF(UPPER(@Mode)='STOP')
BEGIN
		UPDATE AVL.TK_Mini_Sessions 
					SET UserID=@UserID,
						ProjectID=@ProjectID,
						--TicketID=@TicketID,
						TicketDesc=@TicketDesc,
						--TicketOpenDate=@TicketOpenDate,
						ApplicationID=@ApplicationID,
						ServiceID=@ServiceID,
						ActivityID=@ActivityID,
						TicketTypeMapID=@TicketTypeMapID,
						PriorityMapID=@PriorityMapID,
						TicketStatusMapID=@TicketStatusMapID,
						EndTime=@EndTime,
						IsAuto=@IsAuto,
						[Hours]=@Hours,
						[Minutes]=@Minutes,
						Seconds=@Seconds,
						RequestSource=@RequestSource,
						IsSDTicket=@IsSDTicket,
						IsNonDelivery=@IsNonDelivery,
						NonDeliveryActivityType=@NonDeliveryActivityType,
						ModifiedOn=GETDATE(),
						ModifiedBy=@EmployeeID,
						IsRunning=1
						WHERE  SessionID = @SessionID
END

IF(UPPER(@Mode)='DESTROY')
BEGIN
		UPDATE AVL.TK_Mini_Sessions 
					SET EndTime=@EndTime,
					[Hours]=@Hours,
					[Minutes]=@Minutes,
					Seconds=@Seconds,
					IsRunning=0
					WHERE  SessionID = @SessionID
END
IF(UPPER(@Mode)='DELETE') 
BEGIN	
	-- DELETE FROM AVL.TK_Mini_Sessions WHERE  SessionID = @SessionID
	UPDATE AVL.TK_Mini_Sessions set IsDeleted=1,IsRunning=1,ModifiedOn=GETDATE() WHERE  SessionID = @SessionID
END
IF(UPPER(@Mode)='COPY')
BEGIN

			INSERT INTO AVL.TK_Mini_Sessions
			SELECT UserID,
				ProjectID,
				TicketID,
				TicketDesc,
				TicketOpenDate,
				ApplicationID,
				ServiceID,
				ActivityID,
				TicketTypeMapID,
				PriorityMapID,
				TicketStatusMapID ,
				StartTime ,
				EndTime,
				IsAuto,
				Hours,
				Minutes,
				Seconds,
				NULL	,
				EmployeeID,
				RequestSource	,
				IsSDTicket,
				IsNonDelivery,
				NonDeliveryActivityType,
				IsDeleted,
				CreatedOn,
				CreatedBy,
				ModifiedOn,
				ModifiedBy,
				TimeTickerID,
				0,
				NonTicketDescription,
				@UserDateTime,
				SuggestedActivityName
				 FROM AVL.TK_Mini_Sessions WHERE SessionID = @SessionID 

	SET @Curent_sessionID = @@identity

	SELECT SessionID,
				UserID,
				ProjectID,
				TicketID,
				TicketDesc,
				TicketOpenDate,
				ApplicationID,
				ServiceID,
				ActivityID,
				TicketTypeMapID,
				PriorityMapID,
				TicketStatusMapID ,
				StartTime ,
				EndTime,
				IsAuto,
				Hours,
				Minutes,
				Seconds,
				IsProcessed	,
				EmployeeID,
				RequestSource	,
				IsSDTicket,
				IsNonDelivery,
				NonDeliveryActivityType,
				IsDeleted,
				CreatedOn,
				CreatedBy,
				ModifiedOn,
				ModifiedBy,
				TimeTickerID,
				IsRunning,
				NonTicketDescription,
				SuggestedActivityName
				FROM AVL.TK_Mini_Sessions WHERE SessionID = @Curent_sessionID
	END

ELSE IF (UPPER(@Mode)='NONTICKETACTIVITY')
		BEGIN
		SET  @TicketID ='Non Delivery Ticket'

		IF @SessionID >0
		BEGIN
			UPDATE AVL.TK_Mini_Sessions 
					SET UserID=@UserID,
						ProjectID=@ProjectID,
						TicketID=@TicketID,
						TicketDesc=@TicketDesc,
						--TicketOpenDate=@TicketOpenDate,
						ApplicationID=@ApplicationID,
						ServiceID=@ServiceID,
						ActivityID=@ActivityID,
						TicketTypeMapID=@TicketTypeMapID,
						PriorityMapID=@PriorityMapID,
						TicketStatusMapID=@TicketStatusMapID,
						EndTime=@EndTime,
						IsAuto=@IsAuto,
						[Hours]=@Hours,
						[Minutes]=@Minutes,
						Seconds=@Seconds,
						RequestSource=@RequestSource,
						IsSDTicket=@IsSDTicket,
						IsNonDelivery=@IsNonDelivery,
						NonDeliveryActivityType=@NonDeliveryActivityType,
						ModifiedOn=GETDATE(),
						ModifiedBy=@EmployeeID,
						IsRunning=1,
						NonTicketDescription=@NonTicketDescription,
						SuggestedActivityName = @SuggestedActivity
						WHERE  SessionID = @SessionID
		END
		ELSE
			BEGIN
				INSERT INTO AVL.TK_Mini_Sessions(EmployeeID,ProjectID,UserID,TicketID,TicketOpenDate,StartTime,EndTime,IsDeleted, CreatedOn,CreatedBy,IsRunning,IsNonDelivery,NonDeliveryActivityType,Hours,Minutes,NonTicketDescription,UserCreatedTimeDate,SuggestedActivityName)
				SELECT @EmployeeID,@ProjectID,@UserID,@TicketID, GETDATE(),ISNULL(@StartTime,GETDATE()),NULL,0,GETDATE(),@EmployeeID,1,@IsNonDelivery,@NonDeliveryActivityType,@Hours,@Minutes,@NonTicketDescription,@UserDateTime,@SuggestedActivity
				SET @SessionID = @@identity
			END
		
		
			SELECT SessionID,
				UserID,
				ProjectID,
				TicketID,
				TicketDesc,
				TicketOpenDate,
				ApplicationID,
				ServiceID,
				ActivityID,
				TicketTypeMapID,
				PriorityMapID,
				TicketStatusMapID ,
				StartTime ,
				EndTime,
				IsAuto,
				Hours,
				Minutes,
				Seconds,
				IsProcessed	,
				EmployeeID,
				RequestSource	,
				IsSDTicket,
				IsNonDelivery,
				NonDeliveryActivityType,
				IsDeleted,
				CreatedOn,
				CreatedBy,
				ModifiedOn,
				ModifiedBy,
				TimeTickerID,
				IsRunning,
				NonTicketDescription,
				SuggestedActivityName
				FROM AVL.TK_Mini_Sessions	where SessionID = @SessionID

		END


	SET NOCOUNT OFF;   
	COMMIT TRAN   
	
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		-- INSERT Error    
		EXEC AVL_InsertError '[AVL].[Mini_SaveSessionDetails]', @ErrorMessage, @UserID,0
		
	END CATCH  



END
