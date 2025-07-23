/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_SaveAndDeleteSeverity]
(
@Type VARCHAR(30),
@ProjectID INT,
@SeverityIDMapID VARCHAR(100)=NULL,
@SeverityID VARCHAR(100)=NULL,
@SeverityName VARCHAR(100)='',
@CreatedBy VARCHAR(100)=''
)
AS
BEGIN
 SET NOCOUNT ON; 
  
 IF(@SeverityID='0')
  BEGIN
  SET @SeverityID=NULL;
  END
	BEGIN TRY
	  BEGIN TRANSACTION

	  IF(@Type='save')
	     BEGIN
		    IF (EXISTS(SELECT SeverityName FROM [AVL].[TK_MAP_SeverityMapping] WHERE SeverityName=@SeverityName AND ProjectID=@ProjectID AND IsDeleted!=1))
			  BEGIN
			    SELECT 'Severity already exist.Please enter valid Severity' AS 'Result'
			  END
          ELSE
		  BEGIN
		    INSERT INTO [AVL].[TK_MAP_SeverityMapping] (SeverityID,SeverityName,ProjectID,IsDeleted,CreatedDateTime,CreatedBy) VALUES
			                            (@SeverityID,@SeverityName,@ProjectID,0,GETDATE(),@CreatedBy)
		   SELECT 'Severity saved successfully. ' AS 'Result'
          END
		    END
     ELSE IF (@Type='update')
	  IF (EXISTS(SELECT SeverityName FROM [AVL].[TK_MAP_SeverityMapping] WHERE SeverityName=@SeverityName AND ProjectID=@ProjectID AND IsDeleted=0 AND CreatedBY=@CreatedBy))
			  BEGIN
			    SELECT 'Severity already exist.Please enter valid Severity' AS 'Result'
			  END
          ELSE
	     BEGIN
	       UPDATE [AVL].[TK_MAP_SeverityMapping] SET SeverityName=@SeverityName,ModifiedDateTime=getdate(),ModifiedBy=@CreatedBy WHERE ProjectID=@ProjectID
		   AND SeverityIDMapID=@SeverityIDMapID
		    SELECT 'Severity updated successfully. ' AS 'Result'
	    END

		ELSE IF(@Type='delete')
		  BEGIN

		   IF (EXISTS(SELECT SeverityMapID FROM [AVL].[TK_TRN_TicketDetail] WHERE SeverityMapID=@SeverityIDMapID AND ProjectID=@ProjectID AND IsDeleted<>1))
			  BEGIN

			    SELECT 'Severity is already mapped. So cannot delete the record' AS 'Result'
			  END
	
          ELSE
		      UPDATE [AVL].[TK_MAP_SeverityMapping] SET IsDeleted=1,ModifiedDateTime=getdate(),ModifiedBy=@CreatedBy WHERE SeverityName=@SeverityName AND ProjectID=@ProjectID
			   SELECT 'Severity deleted successfully. ' AS 'Result'
		    END

	 COMMIT TRANSACTION

     END TRY

	 BEGIN CATCH
	    	DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ITSM_SaveAndDeleteSeverity] ', @ErrorMessage, @ProjectID,0
		
	 END CATCH

	SET NOCOUNT OFF;
END



--select * from AVL.TK_MAP_SeverityMapping where ProjectID=4
