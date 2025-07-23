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
--EXEC APP_INV_GetServiceorDebtEnableInfobyCustomerID 8, '575633'
CREATE PROCEDURE [dbo].[APP_INV_GetServiceorDebtEnableInfobyCustomerID]
	@CustomerID BIGINT,
	@UserId		VARCHAR(MAX)
AS
BEGIN
	BEGIN TRY
	
		DECLARE @IsDebtEnabled INT
		DECLARE @IsServiceAnalyticsEnabled INT
	
		DECLARE @IsDebtEnabledScreenID INT
		DECLARE @IsServiceAnalyticsEnabledScreenID INT
		
		SET @IsDebtEnabled = 0
		SET @IsServiceAnalyticsEnabled = 0		
		
		SET @IsDebtEnabledScreenID = 5
		SET @IsServiceAnalyticsEnabledScreenID = 9	

		IF EXISTS(SELECT CustomerScreenMapID FROM AVL.MAP_CustomerScreenMapping WHERE CustomerID = @CustomerID AND ScreenID = @IsDebtEnabledScreenID)
			SET @IsDebtEnabled = 1		
		
		IF EXISTS(SELECT CustomerScreenMapID FROM AVL.MAP_CustomerScreenMapping WHERE CustomerID = @CustomerID AND ScreenID = @IsServiceAnalyticsEnabledScreenID)
			SET @IsServiceAnalyticsEnabled = 1
			
		SELECT @IsDebtEnabled AS IsDebtEnabled, @IsServiceAnalyticsEnabled AS IsServiceAnalyticsEnabled

	END TRY  
	BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[KTM].[APP_INV_GetServiceorDebtEnableInfobyCustomerID]', @ErrorMessage, @UserId, @CustomerID 
		
	END CATCH  
END
