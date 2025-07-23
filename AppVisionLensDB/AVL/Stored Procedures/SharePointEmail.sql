


CREATE    PROCEDURE [AVL].[SharePointEmail]

    @EmpID VARCHAR(50),  

    @ProjectID VARCHAR(50),

    @MailSubject VARCHAR(500),

    @MailContent VARCHAR(MAX) = NULL

AS

SET NOCOUNT ON;

  BEGIN

      BEGIN try

        --set @EmpID='825231';

        --set @ProjectID='337888';
 
        DECLARE @EmployeeName VARCHAR(500);

        DECLARE @EmployeeEmail VARCHAR(500);

        DECLARE @ManagerEmail VARCHAR(500);
 
        -- Get the email ID

        SELECT top 1 @EmployeeName = E.EmployeeName, @EmployeeEmail = E.EmployeeEmail,@ManagerEmail=M.EmployeeEmail

        FROM 

            [AVL].[MAS_LoginMaster] E(nolock) 

            LEFT JOIN [AVL].[MAS_LoginMaster] M(nolock) ON E.HcmSupervisorID = M.EmployeeID

        WHERE E.EmployeeID = @EmpID and E.ProjectID= @ProjectID;

        -- Send the email

        SET @MailContent = REPLACE(@MailContent, '{UserName}', @EmployeeName);
 
      EXEC [AVL].[SendDBEmail] @From='ApplensSupport@cognizant.com',@To=@EmployeeEmail, @CC=@ManagerEmail, @Subject=@MailSubject, @Body=@MailContent
 
      END try
 
      BEGIN catch

          DECLARE @ErrorMessage VARCHAR(5000);

          SELECT @ErrorMessage = Error_message()

          EXEC AVL_InsertError '[AVL].[SharePointEmail]', @ErrorMessage, 0,0   

      END catch

      SET NOCOUNT OFF;

  END



