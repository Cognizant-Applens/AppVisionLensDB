/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- Author:		 Dhivya        
-- Create Date:  Feb 1 2019
-- Description:  Takes data from Data Dictionary error table with last uploaded data
-- DB Name :     AppVisionlens

-- ============================================================================ 


CREATE PROCEDURE [AVL].[DD_GetErrorLogData]
(
@ProjectID NVARCHAR(100)
) 
AS
BEGIN
	BEGIN TRY

		SELECT ApplicationName,CauseCode,ResolutionCode,DebtCategory AS DebtClassification,AvoidableFlag,
		ResidualFlag AS ResidualDebt,ReasonForResidual,
		ExpectedCompletionDate,Remarks  from [AVL].[Debt_TRN_DataDictionaryErrorTemp](NOLOCK) WHERE ProjectID=@ProjectID

	END TRY
BEGIN CATCH
	DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
	EXEC AVL_InsertError '[AVL].[DD_GetErrorLogData]',@ErrorMessage,0,0	
END CATCH
END
