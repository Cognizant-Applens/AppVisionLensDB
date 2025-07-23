/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_AddSeverityDetails] 
(	     
@IsCognizant INT,           
@ProjectID INT,
@ITSMSeverityList TVP_ITSMSeverityList READONLY,
@CustomerID int=null,
@CreatedBy VARCHAR(100)=NULL
)
AS

BEGIN
DECLARE @result bit=0,@ITSMScreenId INT=5;
    SET NOCOUNT ON; 
	BEGIN TRY
	  BEGIN TRANSACTION
	   IF @IsCognizant=1
	  BEGIN
	  SET @ITSMScreenId=6
	  END
	 
     IF (EXISTS (SELECT IsDefaultSeverity FROM @ITSMSeverityList WHERE IsDefaultSeverity='Y'))
	  BEGIN
	     UPDATE [AVL].[TK_MAP_SeverityMapping]   SET IsDefaultSeverity=NULL
		  WHERE ProjectID=@ProjectID AND IsDeleted=0
	  END

     IF @IsCognizant=0
	  BEGIN 
	  
	    IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] where ITSMScreenId=5 and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
        begin
        INSERT INTO [AVL].[PRJ_ConfigurationProgress] 
       (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate,IsDefaultPriority)
       values(@CustomerID,@ProjectID,2,@ITSMScreenId,100,0,@CreatedBy,getdate(),0)
       end  
    else
      begin
       update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate() 
       where ProjectID=@ProjectID and ITSMScreenId=5 and customerid=@CustomerID and screenid=2 and IsDeleted=0 
       end

	  INSERT INTO [AVL].[TK_MAP_SeverityMapping] 
		 (SeverityName,ProjectID,IsDeleted,CreatedDateTime,CreatedBy,IsDefaultSeverity)
		   SELECT SeverityName,@ProjectID,0,GETDATE(),@CreatedBy,IsDefaultSeverity
		    FROM @ITSMSeverityList WHERE SeverityIDMapID=0

       UPDATE [AVL].[TK_MAP_SeverityMapping]  
	   SET SeverityName=t2.SeverityName,
			IsDefaultSeverity=t2.IsDefaultSeverity,ModifiedDateTime=GETDATE(),ModifiedBY=@CreatedBy
	         FROM [AVL].[TK_MAP_SeverityMapping] t1
			 JOIN @ITSMSeverityList t2 ON t1.SeverityIDMapID=t2.SeverityIDMapID AND  t2.SeverityIDMapID<>0
	  END

	  ELSE IF  @IsCognizant=1
	    BEGIN
		 IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] where ITSMScreenId=6 and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
        begin
        INSERT INTO [AVL].[PRJ_ConfigurationProgress] 
       (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate,IsDefaultPriority)
       values(@CustomerID,@ProjectID,2,@ITSMScreenId,100,0,@CreatedBy,getdate(),0)
       end  
    else
      begin
       update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate() 
       where ProjectID=@ProjectID and ITSMScreenId=6 and customerid=@CustomerID and screenid=2 and IsDeleted=0 
       end
		  INSERT INTO [AVL].[TK_MAP_SeverityMapping] 
		 (SeverityID,SeverityName,ProjectID,IsDeleted,CreatedDateTime,CreatedBy,IsDefaultSeverity)
		   SELECT SeverityID,SeverityName,@ProjectID,0,GETDATE(),@CreatedBy,IsDefaultSeverity
		    FROM @ITSMSeverityList WHERE SeverityIDMapID=0

       UPDATE [AVL].[TK_MAP_SeverityMapping]  
	   SET SeverityID=t2.SeverityID,SeverityName=t2.SeverityName,
			IsDefaultSeverity=t2.IsDefaultSeverity,ModifiedDateTime=GETDATE(),ModifiedBY=@CreatedBy
	         FROM [AVL].[TK_MAP_SeverityMapping] t1
			 JOIN @ITSMSeverityList t2 ON t1.SeverityIDMapID=t2.SeverityIDMapID AND  t2.SeverityIDMapID<>0
		END
	 SET @result=1
	 COMMIT TRANSACTION
     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError ' [dbo].[ITSM_AddSeverityDetails]', @ErrorMessage, 0 ,@CustomerID
		  SET @result=1
	 END CATCH
	
	SET NOCOUNT OFF;
	SELECT @result AS 'Result'
END
