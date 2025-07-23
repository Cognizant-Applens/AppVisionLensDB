CREATE FUNCTION [dbo].[fn_DataMigrationGet_ValidUsers] 
(
	@TicketSharepathUsers NVARCHAR(100),
	@ProjectID BIGINT,
	@CustomerID BIGINT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE @TicketSharepath NVARCHAR(MAX)
	DECLARE @EmployeeID AS TVP_Employee

	INSERT INTO @EmployeeID (EmployeeID)
	  SELECT * FROM SPLIT(@TicketSharepathUsers, ';')

	DECLARE @loopcount BIGINT,
			@CountForTS BIGINT,
			@IsHCMSuperVisor BIT,
			@IsTSApprover BIT

	SET @loopcount = (select TOP 1 ID FROM @EmployeeID ORDER BY ID ASC)
	SET @CountForTS = (select TOP 1 ID FROM @EmployeeID ORDER BY ID DESC)

	WHILE (@loopcount <= @CountForTS)
	BEGIN

		SET @IsHCMSuperVisor = 0
		SET @IsTSApprover = 0

		SELECT @IsTSApprover = 1 
		FROM AVL.MAS_LoginMaster (NOLOCK) LM 
		JOIN @EmployeeID EMP ON LM.TSApproverID = EMP.EmployeeID 
		WHERE LM.PROJECTID = @ProjectID AND LM.CustomerID = @CustomerID AND LM.ISDELETED = 0 AND EMP.ID = @loopcount

		SELECT @IsHCMSuperVisor = 1 FROM AVL.MAS_LoginMaster (NOLOCK) LM 
		JOIN @EmployeeID EMP ON LM.HcmSupervisorID = EMP.EmployeeID 
		WHERE LM.PROJECTID = @ProjectID AND LM.CustomerID = @CustomerID AND LM.ISDELETED = 0 AND EMP.ID = @loopcount

		IF (@IsTSApprover = 0 AND @IsHCMSuperVisor = 0)
		BEGIN

			DELETE FROM @EmployeeID WHERE ID = @loopcount

		END
		
		SET @loopcount = @loopcount + 1

	END

	DECLARE @CountForTSU AS BIGINT 
	SET @CountForTSU = (SELECT COUNT(*) FROM @EmployeeID)
	
	IF (@CountForTSU = 0)
	BEGIN

		INSERT INTO @EmployeeID (EmployeeID)

		SELECT DISTINCT TOP 4 CASE WHEN LM.TSApproverID IS NOT NULL THEN LM.TSApproverID 
								   WHEN LM.HcmSupervisorID IS NOT NULL AND LM.TSApproverID IS NULL THEN LM.HcmSupervisorID END AS TicketSharePathUser
		FROM AVL.MAS_LoginMaster (NOLOCK) LM 
		JOIN AVL.MAS_LoginMaster (NOLOCK) LM1 
			ON LM1.EmployeeID = (CASE WHEN LM.TSApproverID IS NOT NULL THEN LM.TSApproverID 
									  WHEN LM.HcmSupervisorID IS NOT NULL AND LM.TSApproverID IS NULL THEN LM.HcmSupervisorID END )
				AND LM1.CustomerID = @CustomerID AND LM1.ProjectID = @ProjectID AND LM1.IsDeleted = 0 
		WHERE LM.CustomerID = @CustomerID AND LM.ProjectID = @ProjectID AND LM.HcmSupervisorID IS NOT NULL AND LM.TSApproverID IS NOT NULL 
			AND LM.IsDeleted = 0 

	END

	SET @CountForTSU = (SELECT COUNT(*) FROM @EmployeeID)

	IF (@CountForTSU = 1)
	BEGIN

		SELECT @TicketSharepath = ISNULL(STUFF((SELECT DISTINCT ';' + COALESCE(REPLACE(LM.EmployeeID, ' ', ''), '')+';0'
		FROM AVL.MAS_LoginMaster (NOLOCK) LM 
		INNER JOIN @EmployeeID emp 
			ON LM.employeeid = emp.EmployeeID 
		WHERE LM.CustomerID = @CustomerID AND LM.ProjectID = @ProjectID AND LM.IsDeleted = 0
		FOR XML PATH(''), TYPE).value('.[1]', 'NVARCHAR(MAX)'), 1, 1, ''), '0')

	END
	ELSE
	BEGIN

		SELECT @TicketSharepath = ISNULL(STUFF((SELECT DISTINCT ';' + COALESCE(REPLACE(LM.EmployeeID, ' ', ''), '')
		FROM AVL.MAS_LoginMaster (NOLOCK) LM 
		INNER JOIN @EmployeeID emp 
			ON LM.employeeid = emp.EmployeeID 
		WHERE LM.CustomerID = @CustomerID AND LM.ProjectID = @ProjectID AND LM.IsDeleted = 0
		FOR XML PATH(''), TYPE).value('.[1]', 'NVARCHAR(MAX)'), 1, 1, ''), '0')

	END

	RETURN (SELECT @TicketSharepath)
	 
END




