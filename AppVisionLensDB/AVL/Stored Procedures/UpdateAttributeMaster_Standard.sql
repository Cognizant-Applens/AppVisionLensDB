/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[UpdateAttributeMaster_Standard]    
    @AttributeMaster dbo.TVP_UpdateAttributeMasterDetails READONLY    
AS     
	BEGIN  
	BEGIN TRY
	BEGIN TRAN    
	SET NOCOUNT ON;    
	DECLARE @IsMainspring Char(1)
	DECLARE @ProjectID BIGINT
	DECLARE @UserID VARCHAR(10)    

		
	SELECT @UserID=UserID,@ProjectID=ProjectID
	FROM @AttributeMaster

	SET @IsMainspring = (SELECT ISNULL(IsMainSpringConfigured,'N') FROM [AVL].[MAS_ProjectMaster] With (NOLOCK) WHERE ProjectID=@ProjectId)
	
	IF(@IsMainspring='Y')
	BEGIN
		IF NOT EXISTS (SELECT TOP(1) 1 FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] A With (NOLOCK)
		JOIN @AttributeMaster B ON A.Projectid=B.[ProjectID]
		WHERE A.IsDeleted=0  
	)   
	BEGIN

		
		INSERT INTO [AVL].[PRJ_MainspringAttributeProjectStatusMaster]
		SELECT
			[ServiceID],
			ServiceName,
			AttributeID,
			AttributeName,
            [StatusID],
            [StatusName],
			FieldType,
			GETDATE(),
			@UserID,
			NULL,
			NULL,
			IsDeleted,
			@ProjectID,
			[TicketDetailFields]			 
		FROM [AVL].[MAS_MainspringAttributeStatusMaster] With (NOLOCK)		
		WHERE IsDeleted=0
	END
		 
	UPDATE  A    
	SET     A.FieldType=B.IsMandatory ,    
	A.ModifiedBY = B.UserID ,    
	A.ServiceId= B.ServiceId,    
	A.ModifiedDateTime = GETDATE()    
	FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] A ,    
	@AttributeMaster B    
	WHERE   A.ProjectID = B.ProjectID   
	AND A.ServiceId= B.ServiceId
	AND A.StatusID=B.StatusID
	AND A.AttributeID=B.AttributeID  
    AND A.IsDeleted =0  
	--AND A.AttributeName=B.AttributeName  
	END


ELSE
	BEGIN

	IF NOT EXISTS (SELECT TOP(1) 1 FROM [AVL].[PRJ_StandardAttributeProjectStatusMaster] A With (NOLOCK) 
		JOIN @AttributeMaster B ON A.Projectid=B.ProjectID 
		WHERE A.IsDeleted=0  
	)   
	BEGIN 
		


		INSERT INTO [AVL].[PRJ_StandardAttributeProjectStatusMaster] 
		SELECT
			ServiceID,
			ServiceName,
			AttributeID,
			AttributeName,
			StatusID,
			StatusName,
			FieldType,
			GETDATE(),
			@UserID,
			NULL,
			NULL,
			IsDeleted,
			@ProjectID,
			TicketMasterFields 
		FROM [AVL].[MAS_StandardAttributeStatusMaster] With (NOLOCK)	
		WHERE IsDeleted=0
	END
		 
	UPDATE  A    
	SET     A.FieldType=B.IsMandatory ,    
	A.ModifiedBY = B.UserID ,    
	A.ServiceId= B.ServiceId,    
	A.ModifiedDate = GETDATE()    
	FROM    [AVL].[PRJ_StandardAttributeProjectStatusMaster] A ,    
	@AttributeMaster B    
	WHERE   A.ProjectID = B.ProjectID   
	AND A.ServiceId= B.ServiceId  
	AND A.StatusID=B.StatusID     
	AND A.AttributeID=B.AttributeID
	AND A.IsDeleted =0    
	--AND A.AttributeName=B.AttributeName    
        

 
	END		
	SET NOCOUNT OFF; 
	COMMIT TRAN
SET NOCOUNT OFF
END TRY     
BEGIN CATCH  

    DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT; 

    SELECT @ErrorMessage = ERROR_MESSAGE()
    SELECT @ErrorSeverity = ERROR_SEVERITY()
    SELECT @ErrorState =  ERROR_STATE()

    ROLLBACK TRAN

    --INSERT Error    
    EXEC AVL_InsertError '[AVL].[UpdateAttributeMaster_Standard]', @ErrorMessage, 0 ,0
         
              
END CATCH  
 
END
