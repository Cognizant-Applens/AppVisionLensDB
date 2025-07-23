
CREATE PROC [AVL].[GetErroredTicketsCount] 
	@employeeid NVARCHAR(50),
	@customerid INT
AS
BEGIN
	BEGIN TRY
	SET NOCOUNT ON
	DECLARE @custid INT
	DECLARE @TicketCount INT
	IF(@customerid=0)
		BEGIN
			SET @customerid=(select TOP 1 customerid FROM AVL.MAS_LoginMaster With (NOLOCK) WHERE EmployeeID=@employeeid and IsDeleted=0)
		END
		IF EXISTS(SELECT TOP 1 ECT.ID FROM AVL.ErrorLogCorrectionTickets  ECT With (NOLOCK)
					INNER JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON ECT.EmployeeID=LM.EmployeeID AND ECT.ProjectID=LM.ProjectID
					WHERE LM.EmployeeID=@employeeid AND LM.CustomerID=@customerid AND ECT.SupporttypeID in (1,2) AND ISNULL(LM.IsDeleted,0)=0)
			BEGIN
				SET @TicketCount=1;
			END
		SELECT ISNULL(@TicketCount,0) AS [Count]
    SET NOCOUNT OFF
	END TRY
	BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[GetErroredTicketsCount]', @ErrorMessage, @employeeid,0
	END CATCH  
END
