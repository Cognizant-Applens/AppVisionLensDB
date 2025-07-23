-- =============================================    
-- Author:  699158    
-- Create date: 17/09/2022    
-- Description: Values for python    
-- =============================================    
CREATE PROCEDURE ML.GetTicketEncDetailsForPython     
 -- Add the parameters for the stored procedure here    
 @TransactionId bigint    
AS    
BEGIN    
BEGIN TRY    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
    
 DECLARE @ISApp BIT    
    
   IF(SELECT COUNT(*) FROM ML.TRN_MLTRANSACTION(NOLOCK) WHERE TRANSACTIONID =@TransactionId AND SupportTypeId=1) > 0    
   BEGIN    
 SELECT TicketId,TicketDescription AS EncryptedTicketDescription,    
  '' AS DecryptedTicketDescription,TicketSummary As EncryptedSummaryDescription,    
  '' As DecryptedSummaryDescription  FROM ML.TRN_ClusteringTicketValidation_App(nolock)    
 WHERE MLTRANSACTIONID=@TransactionId AND (ClusterID_Desc is null OR ClusterID_Desc =0)    
   END    
   ELSE    
   BEGIN    
   SELECT TicketId,TicketDescription AS EncryptedTicketDescription,    
    '' AS DecryptedTicketDescription,TicketSummary As EncryptedSummaryDescription,    
    '' As DecryptedSummaryDescription  FROM ML.TRN_ClusteringTicketValidation_Infra(nolock)    
   WHERE MLTRANSACTIONID=@TransactionId AND (ClusterID_Desc is null OR ClusterID_Desc =0)    
   END    
    
   END TRY    
   BEGIN CATCH    
     DECLARE @ErrorMessage VARCHAR(MAX);    
    SELECT @ErrorMessage = ERROR_MESSAGE()                               
  --INSERT Error                              
 EXEC AVL_InsertError '[ML].[GetAppTicketEncDetailsForPython] ', @ErrorMessage, '',0     
   END CATCH    
END
