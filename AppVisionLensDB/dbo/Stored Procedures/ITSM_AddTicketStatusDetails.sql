/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_AddTicketStatusDetails] 
(	     
@ProjectID INT,
@ITSMTicketStatusList TVP_ITSMTicketStatusList READONLY,
@CustomerID int=null,
@CreatedBy VARCHAR(100)=NULL
)
AS

BEGIN
DECLARE @result bit=0,@ITSMScreenId INT=6,@IsCognizant INT;
DECLARE @CompletionPercentage DECIMAL(18,2)
    SET NOCOUNT ON; 
	BEGIN TRY
	  BEGIN TRANSACTION

	   SELECT 	@IsCognizant=C.IsCognizant FROM AVL.Customer C WHERE CustomerID=@CustomerID
	  IF @IsCognizant=1
	   BEGIN 
	   SET @ITSMScreenId=7
	   END
	   ELSE
	    BEGIN
		SET @ITSMScreenId=6
		END

	  --SELECT @CompletionPercentage=CompletionPercentage FROM [AVL].[PRJ_ConfigurationProgress] where ProjectID=@ProjectID and ITSMScreenId=@ITSMScreenId and customerid=@CustomerID and screenid=2 and IsDeleted=0 
	  --IF EXISTS(SELECT StatusID FROM [AVL].[TK_MAP_ProjectStatusMapping] WHERE TicketStatus_ID = 8 AND ProjectID = @ProjectID AND IsDeleted=0)
	  --BEGIN
		IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] where ITSMScreenId=@ITSMScreenId and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
			BEGIN
				INSERT INTO [AVL].[PRJ_ConfigurationProgress]  (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)
				values (@CustomerID,@ProjectID,2,@ITSMScreenId,NULL,0,@CreatedBy,getdate())
			END  
		 IF (EXISTS(SELECT DARTStatusID FROM @ITSMTicketStatusList WHERE DARTStatusID=8))
			begin
			  update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate(),CompletionPercentage=100 
			      where ProjectID=@ProjectID and ITSMScreenId=@ITSMScreenId and customerid=@CustomerID and screenid=2 and IsDeleted=0 
			end  
         
		 ELSE IF ((SELECT COUNT(StatusID) FROM [AVL].[TK_MAP_ProjectStatusMapping] WHERE TicketStatus_ID = 8 AND ProjectID = @ProjectID AND IsDeleted=0)>1) 
		  BEGIN
		  update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate(),CompletionPercentage=100 where ProjectID=@ProjectID 
		          and ITSMScreenId=@ITSMScreenId and customerid=@CustomerID and screenid=2 and IsDeleted=0 
		  END
         ELSE IF ((SELECT COUNT(PS.StatusID) FROM [AVL].[TK_MAP_ProjectStatusMapping] PS
		                   JOIN @ITSMTicketStatusList CP ON PS.StatusID=CP.StatusID
		                   WHERE PS.TicketStatus_ID = 8 AND PS.ProjectID = @ProjectID AND PS.IsDeleted=0 AND CP.DARTStatusID<>8)=1) 
            BEGIN
			update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate(),CompletionPercentage=NULL
			    where ProjectID=@ProjectID and ITSMScreenId=@ITSMScreenId and customerid=@CustomerID and screenid=2 and IsDeleted=0 
			END

		ELSE IF (NOT EXISTS(SELECT StatusID FROM [AVL].[TK_MAP_ProjectStatusMapping] WHERE TicketStatus_ID = 8 AND ProjectID = @ProjectID AND IsDeleted=0))
			begin
			  update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate(),CompletionPercentage=NULL 
			       where ProjectID=@ProjectID and ITSMScreenId=@ITSMScreenId and customerid=@CustomerID and screenid=2 and IsDeleted=0 
			end  
       
		 --ELSE IF (NOT EXISTS(SELECT StatusID FROM [AVL].[TK_MAP_ProjectStatusMapping] WHERE TicketStatus_ID = 8 AND ProjectID = @ProjectID AND IsDeleted=0))
			--BEGIN
			--update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate(),CompletionPercentage=NULL where ProjectID=@ProjectID and ITSMScreenId=@ITSMScreenId and customerid=@CustomerID and screenid=2 and IsDeleted=0 
			--END
	 -- END
	 -- ELSE
		--BEGIN
		--	UPDATE [AVL].[PRJ_ConfigurationProgress] SET 	CompletionPercentage = NULL  where ProjectID=@ProjectID and ITSMScreenId=6 and customerid=@CustomerID and screenid=2 and IsDeleted=0
		--END
	  INSERT INTO [AVL].[TK_MAP_ProjectStatusMapping]
	  (StatusName,TicketStatus_ID,ProjectID,IsDeleted,CreatedDate,CreatedBy) 
		   SELECT StatusName,DARTStatusID,@ProjectID,0,GETDATE(),@CreatedBy
		    FROM @ITSMTicketStatusList WHERE StatusID=0


       UPDATE [AVL].[TK_MAP_ProjectStatusMapping]
	   SET StatusName=t2.StatusName,TicketStatus_ID=t2.DARTStatusID,ModifiedDate=GETDATE(),ModifiedBy=@CreatedBy
	         FROM [AVL].[TK_MAP_ProjectStatusMapping]t1
			 JOIN @ITSMTicketStatusList t2 ON t1.StatusID=t2.StatusID AND  t2.StatusID<>0

	SET @result=1
   COMMIT TRANSACTION

	 -- SELECT 	@IsCognizant=C.IsCognizant FROM AVL.Customer C WHERE CustomerID=@CustomerID
	 -- IF @IsCognizant=1
	 --  BEGIN 
	 --  SET @ITSMScreenId=7
	 --  END

	 -- SELECT @CompletionPercentage=CompletionPercentage FROM [AVL].[PRJ_ConfigurationProgress] where ProjectID=@ProjectID and ITSMScreenId=6 and customerid=@CustomerID and screenid=2 and IsDeleted=0 
	 -- IF EXISTS(SELECT 1 FROM [AVL].[TK_MAP_ProjectStatusMapping] WHERE TicketStatus_ID = 8 AND ProjectID = @ProjectID)
	 -- BEGIN
		--IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] where ITSMScreenId=6 and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
		--	BEGIN
		--		INSERT INTO [AVL].[PRJ_ConfigurationProgress]  (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)
		--		values (@CustomerID,@ProjectID,2,@ITSMScreenId,NULL,0,@CreatedBy,getdate())
		--	END  
		--ELSE IF ((@CompletionPercentage IS NULL) AND EXISTS(SELECT DARTStatusID FROM @ITSMTicketStatusList WHERE DARTStatusID=8))
		--	begin
		--	update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate(),CompletionPercentage=100 where ProjectID=@ProjectID and ITSMScreenId=6 and customerid=@CustomerID and screenid=2 and IsDeleted=0 
		--	end  
		--ELSE
		--	BEGIN
		--	update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate() where ProjectID=@ProjectID and ITSMScreenId=6 and customerid=@CustomerID and screenid=2 and IsDeleted=0 
		--	END
	 -- END
	 -- ELSE
		--BEGIN
		--	UPDATE [AVL].[PRJ_ConfigurationProgress] SET 	CompletionPercentage = NULL  where ProjectID=@ProjectID and ITSMScreenId=6 and customerid=@CustomerID and screenid=2 and IsDeleted=0
		--END
	 -- INSERT INTO [AVL].[TK_MAP_ProjectStatusMapping]
	 -- (StatusName,TicketStatus_ID,ProjectID,IsDeleted,CreatedDate,CreatedBy) 
		--   SELECT StatusName,DARTStatusID,@ProjectID,0,GETDATE(),@CreatedBy
		--    FROM @ITSMTicketStatusList WHERE StatusID=0


  --     UPDATE [AVL].[TK_MAP_ProjectStatusMapping]
	 --  SET StatusName=t2.StatusName,TicketStatus_ID=t2.DARTStatusID,ModifiedDate=GETDATE(),ModifiedBy=@CreatedBy
	 --        FROM [AVL].[TK_MAP_ProjectStatusMapping]t1
		--	 JOIN @ITSMTicketStatusList t2 ON t1.StatusID=t2.StatusID AND  t2.StatusID<>0
	
	 --SET @result=1


     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError ' [dbo].[ITSM_AddTicketStatusDetails]', @ErrorMessage, 0 ,@CustomerID
		  SET @result=1
	 END CATCH
	
	SET NOCOUNT OFF;
	SELECT @result AS 'Result'
END
