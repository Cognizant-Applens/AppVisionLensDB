/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- EXEC AVL.USP_GetBUAccountDetails 683989
-- EXEC AVL.USP_GetCTSAccountDetails '536555', '10'
-- EXEC AVL.USP_GetCTSAccountDetails @AssociateID='536555', @AccountID= '1230511'
-- EXEC AVL.USP_GetCTSAccountDetails @AssociateID='536555', @BUID='10', @AccountID= '1230511'
CREATE PROCEDURE [AVL].[USP_GetBUAccountDetails]
	-- Add the parameters for the stored procedure here
	@AssociateID VARCHAR(100),
	@BUID VARCHAR(100) = '',
	@AccountID VARCHAR(100) = ''
AS
BEGIN
--SET @AssociateID  = '622764'
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- SELECT statements for procedure here
	IF @AssociateID <> '' AND @BUID = '' AND @AccountID = ''
	BEGIN
		SELECT 
			distinct cast(BU.BUID as int) as BUID, BU.PracticeCode AS BUName 
		FROM 
			ESA.ProjectAssociates PA
		INNER JOIN
			ESA.Projects P
		ON
			P.ID = PA.ProjectID
		INNER JOIN 
			ESA.BUAccounts A
		ON 
			A.AccountID = P.AccountID
		INNER JOIN
			ESA.BusinessUnits BU
		ON
			BU.BUID = A.BUID
		WHERE 
			PA.AssociateID = @AssociateID AND @BUID = '' AND @AccountID = ''
	END
	ELSE IF @AssociateID <> '' AND  @BUID <> '' AND @AccountID = ''
	BEGIN
		SELECT 
			ROW_NUMBER() OVER(ORDER BY PA.ID ASC) AS ID, BU.BUID, BU.PracticeCode AS BUName, A.AccountID, A.AccountName,P.ID AS ProjectID, P.Name AS ProjectName 
		FROM 
			ESA.ProjectAssociates PA
		INNER JOIN
			ESA.Projects P
		ON
			P.ID = PA.ProjectID
		INNER JOIN 
			ESA.BUAccounts A
		ON 
			A.AccountID = P.AccountID
		INNER JOIN
			ESA.BusinessUnits BU
		ON
			BU.BUID = A.BUID
		WHERE 
			PA.AssociateID = @AssociateID AND @BUID <> '' AND @AccountID = ''
	END
	ELSE IF @AssociateID <> '' AND  @BUID = '' AND @AccountID <> ''
	BEGIN
		SELECT 
			ROW_NUMBER() OVER(ORDER BY PA.ID ASC) AS ID, BU.BUID, BU.PracticeCode AS BUName, A.AccountID, A.AccountName,P.ID AS ProjectID, P.Name AS ProjectName 
		FROM 
			ESA.ProjectAssociates PA
		INNER JOIN
			ESA.Projects P
		ON
			P.ID = PA.ProjectID
		INNER JOIN 
			ESA.BUAccounts A
		ON 
			A.AccountID = P.AccountID
		INNER JOIN
			ESA.BusinessUnits BU
		ON
			BU.BUID = A.BUID
		WHERE 
			PA.AssociateID = @AssociateID AND @BUID = '' AND @AccountID <> ''
	END
	ELSE IF @AssociateID <> '' AND @BUID <> '' AND @AccountID <> ''
	BEGIN
		SELECT 
			ROW_NUMBER() OVER(ORDER BY PA.ID ASC) AS ID, BU.BUID, BU.PracticeCode AS BUName, A.AccountID, A.AccountName,P.ID AS ProjectID, P.Name AS ProjectName 
		FROM 
			ESA.ProjectAssociates PA
		INNER JOIN
			ESA.Projects P
		ON
			P.ID = PA.ProjectID
		INNER JOIN 
			ESA.BUAccounts A
		ON 
			A.AccountID = P.AccountID
		INNER JOIN
			ESA.BusinessUnits BU
		ON
			BU.BUID = A.BUID
		WHERE 
			PA.AssociateID = @AssociateID AND @AssociateID <> '' AND @BUID <> '' AND @AccountID <> ''
	END
END
