
CREATE   PROCEDURE [AVL].[UpdateTicketUploadSharedPathdetails]
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
  
        UPDATE TUPC
			set
			TUPC.SharePath=@SharedPath,
			TUPC.ModifiedBy=825231,
			TUPC.ModifiedDateTime =getdate()
		from TicketUploadProjectConfiguration TUPC
		where
            TUPC.TicketUploadPrjConfigID=@ID
        
      END try

      BEGIN catch
          DECLARE @ErrorMessage VARCHAR(5000);
          SELECT @ErrorMessage = Error_message()
          EXEC AVL_InsertError '[AVL].[UpdateTicketUploadSharedPathdetails]', @ErrorMessage, 0,0
      END catch
      SET NOCOUNT OFF;
  END
