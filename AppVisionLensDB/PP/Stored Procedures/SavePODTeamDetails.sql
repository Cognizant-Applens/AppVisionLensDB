/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[SavePODTeamDetails]
(
@ProjectID BIGINT,
@PODDetailID BIGINT=null,
@PODName NVARCHAR(250),
@EmployeeID NVARCHAR(50),
@TVP_UserDetails PP.TVP_PODTeamMembers READONLY
)
AS
BEGIN
	BEGIN TRY
	SET NOCOUNT ON
		IF (@PODDetailID IS NOT NULL AND @PODDetailID !=0)
		BEGIN
				UPDATE PP.Project_PODDetails SET PODName=LTRIM(RTRIM(@PODName)) ,
												IsDeleted=0,
												ModifiedBy=@EmployeeID,
												ModifiedDate=GETDATE()
								WHERE PODDetailID=@PODDetailID AND ProjectID=@ProjectID

				
				DELETE FROM [ADM].[AssociateAttributes] WHERE PODDetailID = @PODDetailID

				INSERT INTO [ADM].[AssociateAttributes] 
						(UserId, PODDetailID, CCARole,UserCapacity,IsDeleted, CreatedBy,CreatedDate)
						SELECT UserID,@PODDetailID,RoleID,Capacity,0,@EmployeeID,GETDATE()
						FROM @TVP_UserDetails --WHERE PODDetailID =@PODDetailID

		END
		ELSE 
		BEGIN
				IF NOT EXISTS (SELECT 1 FROM PP.Project_PODDetails WHERE PODName = LTRIM(RTRIM(@PODName))AND ProjectID=@ProjectID)
				BEGIN
						DECLARE @NeWPODDetailID BIGINT
						DECLARE @PODSize int

						Select @PODSize=COUNT(UserID) FROM @TVP_UserDetails;

						INSERT INTO  PP.Project_PODDetails(PODName,ProjectID,PODSize, IsDeleted,CreatedBy,CreatedDate)
							SELECT LTRIM(RTRIM(@PODName)),@ProjectID,@PODSize, 0,@EmployeeID,GETDATE()

						SET @NeWPODDetailID =@@IDENTITY

						INSERT INTO [ADM].[AssociateAttributes] 
							(UserId, PODDetailID, CCARole,UserCapacity,IsDeleted, CreatedBy,CreatedDate)
							SELECT UserID,@NeWPODDetailID,RoleID,Capacity,0,@EmployeeID,GETDATE()
							FROM @TVP_UserDetails 

				END
				
		END	

	END TRY
	BEGIN CATCH 
			DECLARE @ErrorMessage VARCHAR(MAX);
			SELECT @ErrorMessage = ERROR_MESSAGE()
			ROLLBACK TRAN
				EXEC AVL_InsertError 'PP.SavePODTeamDetails', @ErrorMessage, 0 ,@EmployeeID
	END CATCH
	

END
