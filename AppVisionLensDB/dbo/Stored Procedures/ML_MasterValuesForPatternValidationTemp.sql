/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE  PROCEDURE [dbo].[ML_MasterValuesForPatternValidationTemp] 
(
@ProjectID NVARCHAR(200)
)
AS 
BEGIN

SELECT 'Debt Classification' AS AttributeType,0 AS AttributeTypeId,'--Select--' AS AttributeTypeValue
UNION
SELECT 'Avoidable Flag' AS AttributeType,0 AS AttributeTypeId,'--Select--' AS AttributeTypeValue
UNION
SELECT 'Residual Debt' AS AttributeType,0 AS AttributeTypeId,'--Select--' AS AttributeTypeValue
UNION
SELECT 'Cause Code' AS AttributeType,0 AS AttributeTypeId,'--Select--' AS AttributeTypeValue
UNION
SELECT 'Resolution Code' AS AttributeType,0 AS AttributeTypeId,'--Select--' AS AttributeTypeValue
UNION
SELECT 'Reason For Residual' AS AttributeType,0 AS AttributeTypeId,'--Select--' AS AttributeTypeValue
UNION
	SELECT 'Debt Classification',DebtClassificationID AS AttributeTypeId,DebtClassificationName AS AttributeTypeValue
	 FROM [AVL].[DEBT_MAS_DebtClassification]	
	UNION
	SELECT 'Avoidable Flag',AvoidableFlagID AS AttributeTypeId,AvoidableFlagName AS AttributeTypeValue
	 FROM AVL.DEBT_MAS_AvoidableFlag	
	 UNION
	 SELECT 'Residual Debt',ResidualDebtID AS AttributeTypeId,[ResidualDebtName] AS AttributeTypeValue
	 FROM [AVL].[DEBT_MAS_ResidualDebt]
	 UNION
	SELECT 'Cause Code' AttributeType,CauseId AS AttributeTypeId,
	CauseCode AS AttributeTypeValue FROM [AVL].[DEBT_MAP_CauseCode](NOLOCK) where projectid=@ProjectID
	UNION
	select 'Resolution Code' AttributeType,ResolutionID AS AttributeTypeId,
	ResolutionCode AS AttributeTypeValue from [AVL].[DEBT_MAP_ResolutionCode](NOLOCK)  where projectid=@ProjectID
	UNION
	select 'Reason For Residual' AttributeType,ReasonID AS AttributeTypeId,
	ReasonName AS AttributeTypeValue from AVL.CL_MAS_ResidualReason(NOLOCK)  where IsDeleted=0 and ismaster=1




END
