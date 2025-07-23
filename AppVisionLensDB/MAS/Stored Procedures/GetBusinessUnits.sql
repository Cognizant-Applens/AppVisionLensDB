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
-- Description:	EXEC [MAS].[GetBusinessUnits] - Get all the Market Master details
-- =============================================

CREATE PROCEDURE [MAS].[GetBusinessUnits] 

AS
BEGIN
	
	SET NOCOUNT ON; 

	SELECT	BU.BusinessUnitID,BU.BusinessUnitName
			,MU.MarketUnitID,MU.MarketUnitName

	FROM	MAS.BusinessUnits BU (NOLOCK)
			JOIN MAS.MarketUnits MU (NOLOCK) ON MU.MarketUnitID = BU.MarketUnitID AND MU.IsDeleted = 0
	WHERE	BU.IsDeleted = 0 
			
	SET NOCOUNT OFF;		
END
