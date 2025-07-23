/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =================================================================================
-- Author:		Team SunRays
-- Create date: 09-23-2020
-- Description: EXEC [MAS].[GetMarketUnits] - Get All Market Units or Get Market units by MarketID or Market Name
-- ==================================================================================
CREATE PROCEDURE [MAS].[GetMarketUnits]

AS
BEGIN

		SET NOCOUNT ON

		SELECT	MU.MarketUnitID,MU.MarketUnitName
				,M.MarketID,M.MarketName 
		
		FROM	MAS.MarketUnits MU
				JOIN MAS.Markets M ON M.MarketID = MU.MarketID AND M.IsDeleted = 0 
		WHERE	MU.IsDeleted = 0 												

END
