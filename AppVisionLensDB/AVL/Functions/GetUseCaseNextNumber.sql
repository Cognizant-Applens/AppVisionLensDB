/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE FUNCTION [AVL].[GetUseCaseNextNumber]
(
@BUID BIGINT,
@AccountID BIGINT
)
RETURNS NVARCHAR(50)
AS 
BEGIN

DECLARE @BUCode NVARCHAR(10)
DECLARE @ESA_AccountID NVARCHAR(10)
DECLARE @NextNumber bigint
DECLARE @USECASEID NVARCHAR(50)

		SELECT @BUCode= BusinessUnitName FROM [MAS].[BusinessUnits] Where BusinessUnitID=@BUID

		SELECT @ESA_AccountID=ESA_AccountID FROM AVL.Customer Where CustomerID=@AccountID

		SELECT @NextNumber = NextNumber FROM [AVL].[UseCaseIDFrequency] WHERE AccountID=@AccountID AND BUID=@BUID
				
		IF @NextNumber IS NULL
		BEGIN
			SET @NextNumber=1
		END
		ELSE
		BEGIN
			SET @NextNumber=@NextNumber + 1 
		END		

		DECLARE @UseCaseString varchar(10)
		IF(LEN(@NextNumber)=1)
		BEGIN 
			SET @UseCaseString='UC0000'+CONVERT(varchar(10),@NextNumber)
		END
		ELSE IF(LEN(@NextNumber)=2)
		BEGIN 
			SET @UseCaseString='UC000'+CONVERT(varchar(10),@NextNumber)
		END
		ELSE IF(LEN(@NextNumber)=3)
		BEGIN 
			SET @UseCaseString='UC00'+CONVERT(varchar(10),@NextNumber)
		END
		ELSE IF(LEN(@NextNumber)=4)
		BEGIN 
			SET @UseCaseString='UC0'+CONVERT(varchar(10),@NextNumber)
		END
		ELSE IF(LEN(@NextNumber)=5)
		BEGIN 
			SET @UseCaseString='UC'+CONVERT(varchar(10),@NextNumber)
		END
		
		SET @USECASEID = LEFT(@BUCode,4)+'-'+LEFT(@ESA_AccountID,10)+'-'+@UseCaseString

		RETURN @USECASEID

END
