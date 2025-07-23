/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [dbo].[ML_MasterValuesForPatternValidation] --42548
(
@ProjectID NVARCHAR(200),
@SupportType INT
)
AS 
BEGIN
BEGIN TRY

CREATE TABLE #DebtClassification
(
DebtClassificationID BIGINT,
DebtClassificationName NVARCHAR(50)
)

IF(@SupportType=1)
BEGIN
INSERT INTO #DebtClassification
SELECT DebtClassificationID,DebtClassificationName 
	 FROM [AVL].[DEBT_MAS_DebtClassification] 
END
ELSE IF(@SupportType=2)
BEGIN
INSERT INTO #DebtClassification
SELECT DebtClassificationID,DebtClassificationName 
	 FROM [AVL].[DEBT_MAS_DebtClassificationInfra] 
END

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
SELECT 'Reason for Residual' AS AttributeType,0 AS AttributeTypeId,'--Select--' AS AttributeTypeValue
UNION
	SELECT 'Debt Classification',DebtClassificationID AS AttributeTypeId,DebtClassificationName AS AttributeTypeValue
	 FROM #DebtClassification	
	UNION
	SELECT 'Avoidable Flag',AvoidableFlagID AS AttributeTypeId,AvoidableFlagName AS AttributeTypeValue
	 FROM AVL.DEBT_MAS_AvoidableFlag WHERE IsDeleted =0 and AvoidableFlagName!='DNA'	
	 UNION
	 SELECT 'Residual Debt',ResidualDebtID AS AttributeTypeId,[ResidualDebtName] AS AttributeTypeValue
	 FROM [AVL].[DEBT_MAS_ResidualDebt]
	 UNION
	SELECT 'Cause Code' AttributeType,CauseId AS AttributeTypeId,
	CauseCode AS AttributeTypeValue FROM [AVL].[DEBT_MAP_CauseCode](NOLOCK) where projectid=@ProjectID AND IsDeleted=0
	AND CauseCode<>'No Data Available'
	UNION
	select 'Resolution Code' AttributeType,ResolutionID AS AttributeTypeId,
	ResolutionCode AS AttributeTypeValue from [AVL].[DEBT_MAP_ResolutionCode](NOLOCK)  where projectid=@ProjectID and IsDeleted=0
	AND ResolutionCode<>'No Data Available'
	UNION
	SELECT 'Reason for Residual' AttributeType,ReasonResidualID AS AttributeTypeId,

	ReasonResidualName AS AttributeTypeValue FROM [AVL].[TK_MAS_ReasonForResidual] (NOLOCK)
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ML_MasterValuesForPatternValidation] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  

END
