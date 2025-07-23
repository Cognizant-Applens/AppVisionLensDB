
CREATE   PROCEDURE [AVL].[GetEmailID]
(
    @EmployeeId VARCHAR(500)
)
AS
SET NOCOUNT ON;
  BEGIN
      BEGIN try
  
        SELECT
            LM.EmployeeName,LM.EmployeeEmail
        FROM [AVL].[MAS_LoginMaster] LM(nolock) 
        WHERE
            RTRIM(LTRIM(EmployeeID))=RTRIM(LTRIM(@EmployeeId))

      END try

      BEGIN catch
          DECLARE @ErrorMessage VARCHAR(5000);
          SELECT @ErrorMessage = Error_message()
          EXEC AVL_InsertError '[AVL].[GetEmailID]', @ErrorMessage, 0,0   
      END catch
      SET NOCOUNT OFF;
  END
