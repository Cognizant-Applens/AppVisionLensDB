/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[APP_INV_UpdateAppProjectMapping]
	
@AppList AS [AVL].[APP_INV_AppList] READONLY,
@ProjectID bigint ,
@UserID nvarchar(300),
@CustomerID bigint

AS
BEGIN
BEGIN TRY
BEGIN TRANSACTION
DECLARE @DeleteRowCount int 
DECLARE @UpdateRowCount int
DECLARE @InsertRowCount int  
/*******DELETES RECORDS WHICH WERE UNCHECKED********/

		UPDATE 
				AP
		SET 
				AP.IsDeleted=1,
				AP.ModifiedBy=@UserID,
				AP.ModifiedDate=GETDATE()
		FROM 
				AVL.APP_MAP_ApplicationProjectMapping AP
		WHERE
				AP.ApplicationID 
		NOT IN
				(
					SELECT 
							ID 
					FROM 
							@AppList AL 
					UNION 
					SELECT 
							TD.ApplicationID 
					FROM	AVL.TK_TRN_TicketDetail TD
					WHERE	
							TD.ProjectID=@ProjectID
					AND
							TD.IsDeleted=0
				)
		AND 
				AP.ProjectID=@ProjectID


SELECT @DeleteRowCount=@@ROWCOUNT;
/********UPDATES RECORDS WHICH WERE CHECKED********/

		UPDATE 
				AP
		SET 
				AP.IsDeleted=0,
				AP.ModifiedBy=@UserID,
				AP.ModifiedDate=GETDATE()
		FROM 
				AVL.APP_MAP_ApplicationProjectMapping AP
		WHERE
				AP.ApplicationID 
		 IN
				(
					SELECT 
							ID 
					FROM 
							@AppList AL 
				)
		AND 
				AP.ProjectID=@ProjectID





SELECT @UpdateRowCount=@@ROWCOUNT;
/*********INSERTS RECORDS ********/

		INSERT 
				INTO 
						AVL.APP_MAP_ApplicationProjectMapping 
						(
						ProjectID
						,ApplicationID
						,IsDeleted
						,CreatedBy
						,CreatedDate)
		SELECT 
				
				@ProjectID,
				AL.ID,
				0,
				@UserID,
				GETDATE()
		FROM
				 @AppList AL
		WHERE
				 AL.ID 
		NOT IN 
				(
					SELECT 
							A.ApplicationID 
					FROM
							AVL.APP_MAP_ApplicationProjectMapping A
					WHERE 
							A.ProjectID=@ProjectID
					)


SELECT @InsertRowCount=@@ROWCOUNT;	
SELECT @DeleteRowCount AS 'DELETED',@UpdateRowCount AS 'UPDATED',@InsertRowCount AS 'INSERTED';




COMMIT TRANSACTION			
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
	DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		 
		EXEC AVL_InsertError '[AVL].[APP_INV_UpdateAppProjectMapping]', @ErrorMessage, @UserID, @ProjectID 
END CATCH
END
