CREATE Procedure [dbo].[GetSharepathExcelDeleteDetails]  
AS  
BEGIN    
BEGIN TRY   
SET NOCOUNT ON;

SELECT * FROM [dbo].[SharepathExcelDeleteDetails] NOLOCK WHERE isdeleted=0 ORDER BY createddate asc
 
END TRY  
  BEGIN CATCH  
DECLARE @ErrorMessage VARCHAR(8000);  
SELECT @ErrorMessage = ERROR_MESSAGE()  
  --INSERT Error      
  EXEC [dbo].AVL_InsertError '[dbo].[GetExcelDumpArchiveSharepathDetails]', @ErrorMessage, '',''  
  RETURN @ErrorMessage  
  END CATCH     
END 