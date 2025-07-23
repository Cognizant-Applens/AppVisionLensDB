/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[UpdateAttributeMaster_Mainspring]    
    @AttributeMaster dbo.TVP_UpdateAttributeMasterDetails READONLY     
AS     
	BEGIN      
	SET NOCOUNT ON;    

	IF NOT EXISTS (SELECT TOP(1) 1 FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] A 
		JOIN @AttributeMaster B ON A.Projectid=B.ProjectID 
		WHERE A.IsDeleted=0 
	)   
	BEGIN 
		DECLARE @UserID VARCHAR(10)
		DECLARE @ProjectID INT

		SELECT @UserID=UserID,@ProjectID=ProjectID
		FROM @AttributeMaster

		INSERT INTO [AVL].[PRJ_MainspringAttributeProjectStatusMaster]
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
			TicketDetailFields 
		FROM [AVL].[MAS_MainspringAttributeStatusMaster]		
		WHERE IsDeleted=0
	END
		 
	UPDATE  A    
	SET     A.FieldType=B.IsMandatory ,    
	A.ModifiedBY = B.UserID ,    
	A.ServiceId= B.ServiceId,    
	A.ModifiedDateTime = GETDATE()    
	FROM    [AVL].[PRJ_MainspringAttributeProjectStatusMaster] A ,    
	@AttributeMaster B    
	WHERE   A.ProjectID = B.ProjectID   
	AND A.ServiceId= B.ServiceId  
	AND A.StatusID=B.StatusID     
	AND A.AttributeID=B.AttributeID    
	AND A.AttributeName=B.AttributeName    
    	
	SET NOCOUNT OFF;  
	END
