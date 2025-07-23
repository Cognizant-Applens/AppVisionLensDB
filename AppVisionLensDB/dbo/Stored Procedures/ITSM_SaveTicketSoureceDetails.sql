/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_SaveTicketSoureceDetails]
(
          
@ProjectID INT,
@ITSMTicketSource [dbo].[TVP_ITSMTicketSourceList] READONLY,
@CustomerID int=null,
@CreatedBy VARCHAR(100)=NULL


)

AS
BEGIN
SET NOCOUNT ON;
DECLARE @result bit=0;
    SET NOCOUNT ON; 
	BEGIN TRY
	  BEGIN TRANSACTION
	
			   IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] (NOLOCK) where ITSMScreenId=10 and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
begin
INSERT INTO [AVL].[PRJ_ConfigurationProgress] 
  (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)
values(@CustomerID,@ProjectID,2,10,100,0,@CreatedBy,getdate())
end  
else
begin
update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate() where ProjectID=@ProjectID and ITSMScreenId=9 and customerid=@CustomerID and screenid=2 and IsDeleted=0 

end      

IF (EXISTS (SELECT IsDefaultSource FROM @ITSMTicketSource WHERE IsDefaultSource='Y'))
	  BEGIN
	     UPDATE [AVL].[TK_MAP_SourceMapping]   SET IsDefaultSource='N'
		  WHERE ProjectID=@ProjectID AND IsDeleted=0
	  END

	   INSERT INTO [AVL].[TK_MAP_SourceMapping]
		 (SourceID,SourceName,ProjectID,IsDeleted,CreatedDateTime,CreatedBy,IsDefaultSource) 
		         SELECT SourceID,SourceName,@ProjectID,0,GETDATE(),@CreatedBy,IsDefaultSource FROM @ITSMTicketSource where SourceIDMapID=0

       UPDATE [AVL].[TK_MAP_SourceMapping] SET SourceName=t2.SourceName,SourceID=t2.SourceID,
			IsDefaultSource=t2.IsDefaultSource,ModifiedDateTime=GETDATE(),ModifiedBY=@CreatedBy
	         FROM [AVL].[TK_MAP_SourceMapping] t1
			 JOIN @ITSMTicketSource t2 ON t1.SourceIDMapID=t2.SourceIDMapID and t2.SourceIDMapID<>0
			
		 SET @result=1
		 COMMIT TRANSACTION

     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError ' [dbo].[ITSM_SaveTicketSoureceDetails] ', @ErrorMessage, 0 ,@CustomerID
		  SET @result=1
	 END CATCH
	
	SET NOCOUNT OFF;
	SELECT @result AS 'Result'
END



--select * from  [AVL].[TK_MAP_SourceMapping] 
