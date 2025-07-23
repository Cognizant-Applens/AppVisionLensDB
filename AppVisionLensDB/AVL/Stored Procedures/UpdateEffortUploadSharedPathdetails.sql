
CREATE   PROCEDURE [AVL].[UpdateEffortUploadSharedPathdetails]
(
 @ID BIGINT
,@ProjectID char(50)
,@SharedPath VARCHAR(6000)
,@SharedPathType char(100)
)
AS
SET NOCOUNT ON;
  BEGIN
      BEGIN try
  
        UPDATE EUC
			set
			EUC.SharePathName=@SharedPath,
			EUC.ModifiedBy=825231,
			EUC.ModifiedDate =getdate()
		from AVL.EffortUploadConfiguration EUC
		where
            EUC.ID=@ID

      END try

      BEGIN catch
          DECLARE @ErrorMessage VARCHAR(5000);
          SELECT @ErrorMessage = Error_message()
          EXEC AVL_InsertError '[AVL].[UpdateTicketUploadSharedPathdetails]', @ErrorMessage, 0,0   
      END catch
      SET NOCOUNT OFF;
  END
