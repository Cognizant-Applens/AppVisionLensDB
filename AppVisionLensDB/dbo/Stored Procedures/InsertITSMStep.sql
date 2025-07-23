/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[InsertITSMStep]
@projectID INT=NULL,
@ITSMScreenId NVARCHAR(MAX)=NULL,
@UserID NVARCHAR(MAX)=NULL,
@CustomerID INT=NULL

AS
BEGIN
BEGIN TRY
BEGIN TRAN

    DECLARE @IsCognizant SMALLINT = 1
	SELECT @IsCognizant = IsCoginzant FROM AVL.MAS_ProjectMaster WHERE ProjectID = @ProjectID

	IF @IsCognizant = 0 AND (@ITSMScreenId BETWEEN 4 AND 9)
	BEGIN

		SET @ITSMScreenId = @ITSMScreenId - 1

	END
  
	IF (NOT EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] where ITSMScreenId=@ITSMScreenId and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))  
	BEGIN  
		INSERT INTO [AVL].[PRJ_ConfigurationProgress] values(@CustomerID,@ProjectID,2,@ITSMScreenId,100,0,@UserID,getdate(),null,null,null,null)  
	END    
	ELSE  
	BEGIN  
		UPDATE [AVL].[PRJ_ConfigurationProgress]  set CompletionPercentage=100,ModifiedBy=@UserID,ModifiedDate=getdate() where ProjectID=@ProjectID and ITSMScreenId=@ITSMScreenId and customerid=@CustomerID and screenid=2 and IsDeleted=0   
	END  
	
    COMMIT TRAN  
END TRY  
BEGIN CATCH  

              DECLARE @ErrorMessage VARCHAR(MAX);

              SELECT @ErrorMessage = ERROR_MESSAGE()
              ROLLBACK TRAN
              --INSERT Error    
              EXEC AVL_InsertError '[dbo].[InsertITSMStep] ', @ErrorMessage, @ProjectID,@CustomerID
              
       END CATCH  
END
