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
-- Author:		Team SunRays
-- Create date: 09-25-2020
-- Description:	EXEC [MAS].[GetMarketDetails] - Get all the Market Master details
-- =============================================
CREATE PROCEDURE [MAS].[GetMarketDetails]
AS
BEGIN
		SET NOCOUNT ON

		SELECT	MarketID,MarketName
		
		FROM	MAS.Markets 
		WHERE	IsDeleted = 0
END
