/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- [AVL].[Debt_GetPreRequisteDetails] 134,141
CREATE PROCEDURE [AVL].[Debt_GetPreRequisteDetails]
@CustomerID BIGINT,
@ProjectID BIGINT	                


AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;  
DECLARE @TicketType INT;
DECLARE @TicketStatus INT;
DECLARE @CauseCode INT;
DECLARE @ResolutionCode INT;
DECLARE @IsCognizant INT;

SET @IsCognizant = (SELECT IsCognizant FROM AVL.Customer WHERE CustomerID = @CustomerID)

IF(@IsCognizant = 0 OR @IsCognizant IS NULL)
BEGIN
	set @TicketType=(SELECT ISNULL(CompletionPercentage,0) FROM AVL.PRJ_ConfigurationProgress WHERE ProjectID=@ProjectID AND CustomerID=@CustomerID
	AND ITSMScreenId=3 AND ScreenID=2)


	set @TicketStatus=(SELECT ISNULL(CompletionPercentage,0) FROM AVL.PRJ_ConfigurationProgress WHERE ProjectID=@ProjectID AND CustomerID=@CustomerID
	AND ITSMScreenId=6 AND ScreenID=2 AND IsDeleted=0)
	IF @TicketStatus>0
	 IF NOT EXISTS(SELECT 1 FROM [AVL].[TK_MAP_ProjectStatusMapping] WHERE ProjectID=@ProjectID AND TicketStatus_ID=8 AND IsDeleted=0)
	 BEGIN
		SET @TicketStatus=0
	 END
	 ELSE 
	 BEGIN
		SET @TicketStatus=100
	 END


	SET @CauseCode=(SELECT ISNULL(CompletionPercentage,0) FROM AVL.PRJ_ConfigurationProgress WHERE ProjectID=@ProjectID AND CustomerID=@CustomerID
	AND ITSMScreenId=7 AND ScreenID=2)

	SET @ResolutionCode=(SELECT ISNULL(CompletionPercentage,0) FROM AVL.PRJ_ConfigurationProgress WHERE ProjectID=@ProjectID AND CustomerID=@CustomerID
	AND ITSMScreenId=8 AND ScreenID=2)
END
ELSE IF(@IsCognizant = 1)
BEGIN
		set @TicketType=(SELECT ISNULL(CompletionPercentage,0) FROM AVL.PRJ_ConfigurationProgress WHERE ProjectID=@ProjectID AND CustomerID=@CustomerID
	AND ITSMScreenId=4 AND ScreenID=2)


	set @TicketStatus=(SELECT ISNULL(CompletionPercentage,0) FROM AVL.PRJ_ConfigurationProgress WHERE ProjectID=@ProjectID AND CustomerID=@CustomerID
	AND ITSMScreenId=7 AND ScreenID=2 AND IsDeleted=0)
	IF @TicketStatus>0
	 IF NOT EXISTS(SELECT 1 FROM [AVL].[TK_MAP_ProjectStatusMapping] WHERE ProjectID=@ProjectID AND TicketStatus_ID=8 AND IsDeleted=0)
	 BEGIN
		SET @TicketStatus=0
	 END
	 ELSE 
	 BEGIN
		SET @TicketStatus=100
	 END


	SET @CauseCode=(SELECT ISNULL(CompletionPercentage,0) FROM AVL.PRJ_ConfigurationProgress WHERE ProjectID=@ProjectID AND CustomerID=@CustomerID
	AND ITSMScreenId=8 AND ScreenID=2)

	SET @ResolutionCode=(SELECT ISNULL(CompletionPercentage,0) FROM AVL.PRJ_ConfigurationProgress WHERE ProjectID=@ProjectID AND CustomerID=@CustomerID
	AND ITSMScreenId=9 AND ScreenID=2)
END



DECLARE @IsTicketTypeFilled NVARCHAR(10) ='N'
DECLARE @IsTicketStatus NVARCHAR(10) ='N'
DECLARE @IsCauseCode NVARCHAR(10) ='N'
DECLARE @IsResolutionCode NVARCHAR(10) ='N'
DECLARE @Overall NVARCHAR(10) ='N'
DECLARE @ISTicketDescription NVARCHAR(10) ='N'
IF @TicketType > 0
SET @IsTicketTypeFilled ='Y'
IF @TicketStatus > 0
SET @IsTicketStatus ='Y'
IF @CauseCode > 0
SET @IsCauseCode ='Y'
IF @ResolutionCode > 0
SET @IsResolutionCode ='Y'
IF EXISTS(SELECT * FROM AVL.ITSM_PRJ_SSISColumnMapping WHERE ProjectID =@ProjectID AND IsDeleted=0 
AND (ServiceDartColumn = 'TicketDescription' OR ServiceDartColumn = 'Ticket Description'))
BEGIN
	SET @ISTicketDescription = 'Y'
END
ELSE
BEGIN
	SET @ISTicketDescription = 'N'
END
IF @IsTicketTypeFilled ='Y' AND @IsTicketStatus='Y' AND @IsCauseCode='Y' AND @IsResolutionCode='Y' --AND @ISTicketDescription = 'Y'
SET @Overall ='Y'	

DECLARE @ISManual VARCHAR(50) = (SELECT IsDebtEnabled FROM AVL.MAS_ProjectMaster WHERE ProjectID = @ProjectID)
DECLARE @DebtDate DATETIME = (SELECT DebtEnablementDate FROM AVL.MAS_ProjectDebtDetails WHERE ProjectID = @ProjectID)

SELECT @IsTicketTypeFilled AS TicketType,@IsTicketStatus AS TicketStatus,@IsCauseCode AS CauseCode,
@IsResolutionCode AS ResolutionCode,
@Overall AS Overall,@ISTicketDescription AS ISTicketDescription,@ISManual AS ISManual,@DebtDate AS DebtDate


SET NOCOUNT OFF; 
     
	 END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Debt_GetPreRequisteDetails]', @ErrorMessage, 0,@CustomerID
		
	END CATCH  

END

--SELECT * FROM AVL.MAS_ITSMScreenMaster
 
 --3 --TICKET TYPE
 --6 --TICKET STATUS
 --7 --CAUSE CODE
 --8 --RESOLUTION CODE

--SELECT * FROM AVL.PRJ_ConfigurationProgress where projectid=41


--SELECT * FROM AVL.MAS_ITSMToolConfiguration
