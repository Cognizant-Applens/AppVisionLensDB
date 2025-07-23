CREATE FUNCTION [dbo].[GetItsmPercentage] 
(
@ProjectID INT
)
RETURNS INT
AS
BEGIN
		DECLARE @CustomerID int

		SELECT @CustomerID= CustomerID FROM AVL.MAS_ProjectMaster WHERE Projectid=@ProjectID

		Declare @ITSMScreenId DECIMAL(18,2);
	DECLARE @STATUSProgress DECIMAL(18,4);
	DECLARE @IsSeverity INT=NULL,@IsCognizant INT
	DECLARE @ClosedTicketStatus DECIMAL(18,2)=0
	DECLARE @TicketUploadStatus DECIMAL(18,2)=0
	DECLARE @MainIndex int
	DECLARE @SecondMax int
	DECLARE @ScreenCount int
	DECLARE @finalPerc int

	DECLARE @SupportType INT = (SELECT ISNULL(SupportTypeId,0) FROM AVL.MAP_ProjectConfig WHERE ProjectID = @ProjectID)

	SELECT @IsCognizant = C.IsCognizant FROM AVL.Customer C WHERE CustomerID = @CustomerID AND C.IsDeleted = 0

	SET @ITSMScreenId = (SELECT TOP 1 ITSMScreenId FROM [AVL].[PRJ_ConfigurationProgress] 
					     WHERE ProjectID = @ProjectID AND CustomerID = @CustomerID AND ScreenID = 2 AND IsDeleted = 0 
						 ORDER BY ITSMScreenId DESC)

	SET @ScreenCount = CASE WHEN (@SupportType = 1 AND @IsCognizant = 1) THEN 
					   (
									SELECT COUNT(id) FROM AVL.PRJ_ConfigurationProgress 
									WHERE ProjectID = @ProjectID AND CustomerID = @CustomerID AND IsDeleted = 0 AND ScreenID = 2 
									AND ITSMScreenId <> 12
					   ) 
					   WHEN (@SupportType = 1 AND (@IsCognizant = 0 OR @IsCognizant IS NULL)) THEN 
					   (
									SELECT COUNT(id) FROM AVL.PRJ_ConfigurationProgress 
									WHERE ProjectID = @ProjectID AND CustomerID = @CustomerID AND IsDeleted = 0 AND ScreenID = 2 
									AND ITSMScreenId <> 10 -- Assignment Group is not included for App Project
					   )
					   ELSE 
					   (
							SELECT COUNT(id) FROM AVL.PRJ_ConfigurationProgress 
							WHERE ProjectID = @ProjectID AND CustomerID = @CustomerID AND IsDeleted = 0 AND ScreenID = 2
					   ) 
					   END
   
	SELECT @IsSeverity = IsSeverity FROM [AVL].[PRJ_ConfigurationProgress]  
	WHERE ProjectID = @ProjectID AND IsDeleted = 0 AND ScreenID = 2 AND ITSMScreenId = 2

	IF @IsCognizant = 0 OR @IsCognizant IS NULL
	BEGIN

		SET @SecondMax = (SELECT TOP 1 ITSMScreenId FROM [AVL].[PRJ_ConfigurationProgress] 
			WHERE ProjectID = @ProjectID AND CustomerID = @CustomerID AND ScreenID = 2 AND IsDeleted = 0 AND ITSMScreenId <> 10 
			ORDER BY ITSMScreenId DESC)

		SET @MainIndex = (CASE WHEN (@SecondMax = 2 AND @ITSMScreenId = 10) THEN 3 ELSE @SecondMax END)

		SELECT @ClosedTicketStatus = CompletionPercentage FROM [AVL].[PRJ_ConfigurationProgress] 
          WHERE ProjectID = @ProjectID AND CustomerID = @CustomerID AND ScreenID = 2 AND IsDeleted = 0 AND ITSMScreenId = 6

		SELECT @TicketUploadStatus = CompletionPercentage FROM [AVL].[PRJ_ConfigurationProgress] 
          WHERE ProjectID = @ProjectID AND CustomerID = @CustomerID AND ScreenID = 2 AND IsDeleted = 0 AND ITSMScreenId = 9

		IF @IsSeverity = 1 AND (NOT EXISTS(SELECT TOP 1 ITSMScreenId FROM [AVL].[PRJ_ConfigurationProgress] 
          WHERE ProjectID = @ProjectID AND CUSTOMERID = @CustomerID AND ScreenID = 2 AND IsDeleted = 0 AND ITSMScreenId = 5))
		BEGIN
		      IF @ClosedTicketStatus IS NULL AND @TicketUploadStatus IS NULL 
				SET @STATUSProgress = (CONVERT(DECIMAL(18, 2), @ScreenCount-3))/(CASE WHEN @SupportType = 2 OR @SupportType = 3 THEN 10 ELSE 9 END);
			  ELSE IF @ClosedTicketStatus IS NULL OR @TicketUploadStatus IS NULL 
			    SET @STATUSProgress = (CONVERT(DECIMAL(18, 2), @ScreenCount-2))/(CASE WHEN @SupportType = 2 OR @SupportType = 3 THEN 10 ELSE 9 END);
		      ELSE 
			    SET @STATUSProgress = (CONVERT(DECIMAL(18, 2), @ScreenCount-1))/(CASE WHEN @SupportType = 2 OR @SupportType = 3 THEN 10 ELSE 9 END);
              END
       ELSE 
	    BEGIN
	         IF @ClosedTicketStatus IS NULL AND @TicketUploadStatus IS NULL 
			  SET @STATUSProgress = (CONVERT(DECIMAL(18, 2), @ScreenCount-2)*100)/(CASE WHEN @SupportType = 2 OR @SupportType = 3 THEN 1000 ELSE 900 END);
			 ELSE IF @ClosedTicketStatus IS NULL OR @TicketUploadStatus IS NULL
		      SET @STATUSProgress = (CONVERT(DECIMAL(18, 2), @ScreenCount-1)*100)/(CASE WHEN @SupportType = 2 OR @SupportType = 3 THEN 1000 ELSE 900 END);
             ELSE 
	           SET @STATUSProgress = (CONVERT(DECIMAL(18, 2), @ScreenCount)*100)/(CASE WHEN @SupportType = 2 OR @SupportType = 3 THEN 1000 ELSE 900 END);
        END

		SET @finalPerc = (SELECT @STATUSProgress * 100)
		

  END

  IF @IsCognizant = 1
  BEGIN
	SET @SecondMax = (SELECT TOP 1 ITSMScreenId FROM [AVL].[PRJ_ConfigurationProgress] 
					  WHERE ProjectID = @ProjectID AND CustomerID = @CustomerID AND ScreenID = 2 AND IsDeleted = 0 and ITSMScreenId <> 12 
					  ORDER BY ITSMScreenId DESC)
	  
	SET @MainIndex = (CASE WHEN (@SupportType = 2 AND @SecondMax BETWEEN 3 AND 11 and @ITSMScreenId = 12) THEN @SecondMax - 1
					  ELSE CASE WHEN @ScreenCount = 12 THEN @ScreenCount - 2 
					  ELSE CASE WHEN (@SupportType != 2 AND @SecondMax BETWEEN 3 AND 11 and @ITSMScreenId = 12) THEN @SecondMax - 1 
					  ELSE @SecondMax END END END)
	  
	SET @MainIndex = (CASE WHEN (@SecondMax = 2 AND @ITSMScreenId = 12) THEN 3 ELSE @MainIndex END)

	SELECT @ScreenCount = COUNT(DISTINCT ITSMScreenID) FROM [AVL].[PRJ_ConfigurationProgress]   
			  WHERE ProjectID = @ProjectID AND CustomerID = @CustomerID AND ScreenID = 2 
				AND ITSMScreenId <> 3 AND ITSMScreenId <> 12
				AND CompletionPercentage = 100 AND IsDeleted = 0
				
	IF EXISTS (SELECT TOP 1 AssignmentGroupMapID FROM AVL.BOTAssignmentGroupMapping WHERE ProjectID = @ProjectID) 
		AND (@SupportType = 2 OR @SupportType = 3)
	 BEGIN

		SET @ScreenCount = @ScreenCount + 1

	 END

    SET @STATUSProgress = 
         ((CONVERT(DECIMAL(18, 2), @ScreenCount)*100) / (CASE WHEN @SupportType = 2 OR @SupportType = 3 THEN 1100 ELSE 1000 END))   

	SET @finalPerc = (SELECT @STATUSProgress * 100)
	END
	
	DECLARE @FINALRESULT INT

	SET @FINALRESULT = CASE WHEN (@finalPerc) > 100 THEN 100 ELSE @finalPerc END
	

	RETURN @FINALRESULT
				
END
