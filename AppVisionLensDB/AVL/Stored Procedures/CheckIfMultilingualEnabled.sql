/*-- =============================================
-- Author:		Sreeya
-- Create date: 8-5-2019
-- Description:	checks if multilingual is enabled
-- =============================================*/

--EXEC [AVL].[CheckIfMultilingualEnabled] 21015 ,'659978'
CREATE PROCEDURE [AVL].[CheckIfMultilingualEnabled]
@ProjectID BIGINT,
@CogID VARCHAR(50)=NULL
AS
BEGIN
BEGIN TRY
		-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM AVL.MAS_ProjectMaster WITH (NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0 AND IsMultilingualEnabled='1')
BEGIN
	
SELECT 'False';
END
ELSE
BEGIN

SELECT 'False';
END
		SET NOCOUNT OFF;
END TRY

BEGIN CATCH
	 DECLARE @ErrorMessage VARCHAR(MAX);  
  
	  SELECT @ErrorMessage = ERROR_MESSAGE()  
	  --INSERT Error      
	  EXEC AVL_InsertError 'AVL.CheckIfMultilingualEnabled', @ErrorMessage, @CogID, @projectID  
END CATCH
END