/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[APP_INV_UpdateAppCatProjectMapping]

@AppCategoryList AS [AVL].[APP_INV_AppCatInScopeList]  READONLY,
@ProjectID BIGINT ,
@UserID NVARCHAR(300),
@CustomerID BIGINT

AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;
	BEGIN TRANSACTION
		DECLARE @DeleteRowCount INT 
		DECLARE @UpdateRowCount INT
		DECLARE @InsertRowCount INT 
		DECLARE @IsDeleted		INT = 0 
		DECLARE @IsActive		INT = 0
		/*******DELETES RECORDS WHICH WERE UNCHECKED********/
	
		SELECT DISTINCT AP.ApplicationID INTO #AppProjectMapping 
		FROM AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) AP
		JOIN @AppCategoryList  AL
			ON AL.AppID=AP.ApplicationID AND AP.ProjectID=@ProjectID
		WHERE AP.IsDeleted <> AL.isDeleted	
			
	
	    
		UPDATE AP
		SET AP.IsDeleted = 1,
		InActivatedDate=GETDATE(),
		AP.ModifiedBy=@UserID,
		AP.ModifiedDate=GETDATE()
		FROM AVL.APP_MAP_ApplicationProjectMapping AP
		INNER JOIN @AppCategoryList AL ON AP.ProjectID=@ProjectID AND AP.ApplicationID=AL.AppID
		WHERE AL.IsDeleted = 1 AND AP.IsDeleted = @IsDeleted
		SET @DeleteRowCount=@@ROWCOUNT;  

		UPDATE AP 
		SET AP.IsDeleted=AL.IsDeleted,	InActivatedDate=NULL,
		AP.ModifiedBy=@UserID,
		AP.ModifiedDate=GETDATE(),
		AP.MainspringSUPPORTCATEGORYID=AL.CatID 
		FROM AVL.APP_MAP_ApplicationProjectMapping AP
		INNER JOIN @AppCategoryList AL ON AP.ProjectID=@ProjectID AND AP.ApplicationID=AL.AppID
		WHERE AL.IsDeleted = @IsDeleted

		---Update Application as Inactive 			

		UPDATE AM SET AM.IsActive = @IsActive
		FROM AVL.APP_MAS_ApplicationDetails (NOLOCK) AM
		JOIN AVL.BusinessClusterMapping (NOLOCK) BCM
			ON BCM.BusinessClusterMapID = AM.SubBusinessClusterMapID AND BCM.IsHavingSubBusinesss = 0
        JOIN #AppProjectMapping (NOLOCK) APM
			ON APM.ApplicationID=AM.ApplicationID 
		LEFT JOIN AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) AP
			ON AM.ApplicationID = AP.ApplicationID AND AP.IsDeleted = @IsDeleted
		WHERE BCM.CustomerID = @CustomerID AND AM.IsActive = 1 AND AP.ApplicationID IS NULL		
		

		SET @UpdateRowCount=@@ROWCOUNT;  
/*********INSERTS RECORDS ********/

		INSERT INTO AVL.APP_MAP_ApplicationProjectMapping 
						(ProjectID,ApplicationID,MainspringSUPPORTCATEGORYID,IsDeleted,CreatedBy,CreatedDate)
		SELECT  @ProjectID,AL.AppID,AL.CatID,0,@UserID,GETDATE()
		FROM @AppCategoryList AL
		LEFT JOIN AVL.APP_MAP_ApplicationProjectMapping A
		ON AL.AppID=A.ApplicationID AND A.ProjectID=@ProjectID
		WHERE ISNULL(AL.IsDeleted,0) = @IsDeleted AND  A.ApplicationID IS NULL



		SET @InsertRowCount=@@ROWCOUNT;   
		SELECT @DeleteRowCount AS 'DELETED',@UpdateRowCount AS 'UPDATED',@InsertRowCount AS 'INSERTED'; 
		
		EXEC [PP].[ProjectAttributeBasedOnCloudService]  @ProjectID,NULL,@UserID
	COMMIT TRANSACTION		
	
			
	
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
	DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[APP_INV_UpdateAppCatProjectMapping]', @ErrorMessage, @UserID, @ProjectID 
END CATCH
END
