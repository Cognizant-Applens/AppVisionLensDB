/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ConfigerSupportType] 
	@ProjectID nvarchar(100),
	@USERID nvarchar(100),
	@SupportTypeId nvarchar(100)
AS
BEGIN
BEGIN TRY

SET NOCOUNT ON;

DECLARE @CUSTOMERID BIGINT = (SELECT CustomerID FROM AVL.MAS_ProjectMaster WHERE ProjectID =@ProjectID)
DECLARE @screenID bigint = 17
	IF NOT EXISTS (SELECT 1 from AVL.MAP_CustomerScreenMapping where CustomerID = @CUSTOMERID AND ScreenID = @screenID)
	BEGIN
		IF(@SupportTypeId=1)
		BEGIN
			INSERT INTO AVL.MAP_CustomerScreenMapping VALUES(@CUSTOMERID,@screenID,0,0,GETDATE(),@USERID,NULL,NULL)	
		END
		ELSE
		BEGIN
			INSERT INTO AVL.MAP_CustomerScreenMapping VALUES(@CUSTOMERID,@screenID,1,1,GETDATE(),@USERID,NULL,NULL)

		END
	END 
	ELSE
	BEGIN
		IF(@SupportTypeId=1)
		BEGIN
			UPDATE AVL.MAP_CustomerScreenMapping SET IsEnabled = 0, IsActive = 0, ModifiedDate=GETDATE(),ModifiedBy = @USERID where CustomerID = @CUSTOMERID AND ScreenID = @screenID
		END 
		ELSE
		BEGIN
			UPDATE AVL.MAP_CustomerScreenMapping SET IsEnabled = 1, IsActive = 1, ModifiedDate=GETDATE(),ModifiedBy = @USERID  where CustomerID = @CUSTOMERID AND ScreenID = @screenID
		END
	END 

MERGE INTO AVL.MAP_ProjectConfig PC USING (SELECT
		@ProjectID AS ProjectID) PC1 ON PC.PROJECTID = PC1.ProjectID WHEN MATCHED THEN 
		UPDATE SET SupportTypeId = ISNULL(@SupportTypeId, PC.SupportTypeId),
ModifiedBy = @USERID,
ModifiedDateTime = GETDATE() WHEN NOT MATCHED THEN INSERT(ProjectID,
CreatedBY,
CreatedDateTime,
SupportTypeId) VALUES(@ProjectID,
@USERID,
GETDATE(),
@SupportTypeId);
	IF @SupportTypeId <> 3
	BEGIN
		UPDATE AVL.TK_MAP_TicketTypeMapping SET SupportTypeID = @SupportTypeId,
		ModifiedDateTime=GETDATE(),
		ModifiedBY = @USERID 
		WHERE ProjectID=@ProjectID AND IsDeleted=0

		UPDATE AVL.BOTAssignmentGroupMapping SET SupportTypeID = @SupportTypeId,
		ModifiedDate=GETDATE(),
		ModifiedBy = @USERID 
		WHERE ProjectID=@ProjectID AND IsDeleted=0
	END

END TRY BEGIN CATCH

DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()


EXEC AVL_InsertError	'[AVL].[ConfigerSupportType]'
						,@ErrorMessage
						,@ProjectID
						,'0'

END CATCH

END
