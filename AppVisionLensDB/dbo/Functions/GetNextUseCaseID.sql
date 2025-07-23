/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE FUNCTION [dbo].[GetNextUseCaseID]
(
@BUID BIGINT, 
@Account BIGINT
)  
RETURNS NVARCHAR(50)   
AS   
BEGIN  
    DECLARE @UseCaseID VARCHAR(50) = NULL; 
	DECLARE @ESA_AccountID NVARCHAR(10)
	DECLARE @BUCode NVARCHAR(50) = NULL;

	SELECT @BUCode= BusinessUnitName FROM [MAS].[BusinessUnits] Where BusinessUnitID=@BUID
	SELECT @ESA_AccountID=ESA_AccountID FROM AVL.Customer Where CustomerID=@Account

	DECLARE @NextID VARCHAR(10) = (	
				SELECT
				CASE
					WHEN NextID BETWEEN 1 AND 9
						THEN 'UC0000' + CAST(NextID AS VARCHAR(5))	
					WHEN NextID BETWEEN 10 AND 99
						THEN 'UC000' + CAST(NextID AS VARCHAR(5))
					WHEN NextID BETWEEN 100 AND 999
						THEN 'UC00' + CAST(NextID AS VARCHAR(5))
					WHEN NextID BETWEEN 1000 AND 9999
						THEN 'UC0' + CAST(NextID AS VARCHAR(5))
					ELSE
						'UC' + CAST(NextID AS VARCHAR(5))	
				END As NextuseCaseId
				FROM AVL.TK_MAP_AHIDGeneration WHERE Category ='UC'
				)
     
    SET @UseCaseID = LEFT(@BUCode,4)+ '-' + CAST(@ESA_AccountID AS VARCHAR(10)) + '-'+ @NextID
	

    RETURN @UseCaseID;  
END;
