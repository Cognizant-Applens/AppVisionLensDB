  
CREATE PROCEDURE [AVL].[UploadAndUpdateDebtReview]   
 -- @LeadId int =null,  
  @ProjectID nvarchar(100),  
  @EmployeeID nvarchar (100)  
 -- @DebitReviewDetailsUpload DebitReviewDetailsUpload READONLY    
AS  
BEGIN  
BEGIN TRY  
SET NOCOUNT ON;    
DECLARE @result bit  
DECLARE @AlgorithmKey nvarchar(6);    
  SET @AlgorithmKey =ISNULL( (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@PROJECTID AND ISNULL(IsActiveTransaction,0)=1 AND IsDeleted=0 AND SupportTypeId=1),'AL002')  
IF(@AlgorithmKey='AL001')  
BEGIN  
 EXEC [AVL].[UploadAndUpdateDebtReviewAlgoOne] @ProjectID,@EmployeeID  
END  
ELSE BEGIN  
 EXEC [AVL].[UploadAndUpdateDebtReviewAlgoTwo] @ProjectID,@EmployeeID  
END  
SET NOCOUNT OFF;  
END TRY  
BEGIN CATCH  
  
DECLARE @ErrorMessage VARCHAR(MAX);  
  
SELECT  
 @ErrorMessage = ERROR_MESSAGE()  
PRINT @ErrorMessage  
TRUNCATE TABLE DebtReviewTemp  
ROLLBACK TRAN  
--INSERT Error      
EXEC AVL_InsertError '[AVL].[UploadAndUpdateDebtReview]'  
      ,@ErrorMessage  
      ,0  
  
END CATCH  
END
