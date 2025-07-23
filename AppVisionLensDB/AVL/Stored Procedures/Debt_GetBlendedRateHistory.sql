/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[Debt_GetBlendedRateHistory]
(
@ProjectID VARCHAR(50),
@SupportTypeId  INT
)
AS
BEGIN
BEGIN TRY

	SELECT  TOP 10 EffectiveFromDate,EffectiveToDate,BlendedRate,CreatedBy,CreatedDate 
	FROM AVL.Debt_BlendedRateCardDetails(NOLOCK)
	WHERE ProjectId = @ProjectID AND IsDeleted = 0 AND ((@SupportTypeId = 1 AND IsAppOrInfra = 1)
												    OR (@SupportTypeId = 2 AND IsAppOrInfra = 2))
	ORDER BY BlendedRateID DESC

	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Debt_GetBlendedRateHistory] ', @ErrorMessage, 0,@ProjectID
		
	END CATCH  

END
