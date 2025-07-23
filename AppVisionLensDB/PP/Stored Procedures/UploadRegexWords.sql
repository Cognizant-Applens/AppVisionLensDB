/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[UploadRegexWords]
@ProjectID BIGINT,
@CreatedBy NVARCHAR(50),
@json NVARCHAR(MAX)	
AS
 BEGIN
	BEGIN TRY  
	   BEGIN TRAN
		SET NOCOUNT ON;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	

	CREATE TABLE #TempRegexWords
			(				
				RegexWord	NVARCHAR(max)
			)

	INSERT INTO #TempRegexWords
	SELECT RegexWord FROM OPENJSON(@json)
	WITH(
	RegexWord NVARCHAR(MAX) '$.RegexWords'
	
	)AS JSONVALUES	

	UPDATE AVL.RegexWords SET IsDeleted=1,ModifiedDate = GETDATE(),ModifiedBy = @CreatedBy WHERE ProjectID=@ProjectID AND RegexWord NOT IN (SELECT RegexWord FROM #TempRegexWords)	

	MERGE AVL.RegexWords  AS TARGET
		USING #TempRegexWords AS SOURCE
			ON TARGET.RegexWord = SOURCE.RegexWord  AND TARGET.ProjectID = @ProjectID AND TARGET.IsDeleted = 0
		WHEN NOT MATCHED BY TARGET 
		THEN
			INSERT (ProjectID,RegexWord,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
			VALUES (@ProjectID,SOURCE.RegexWord,0,@CreatedBy,GETDATE(),NULL,NULL);	
			
DROP TABLE #TempRegexWords;

		COMMIT TRAN
	END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error   
		ROLLBACK TRAN
        EXEC AVL_INSERTERROR  '[PP].[UploadRegexWords]', @ErrorMessage,  0, 
        0 
    END CATCH 
  END
