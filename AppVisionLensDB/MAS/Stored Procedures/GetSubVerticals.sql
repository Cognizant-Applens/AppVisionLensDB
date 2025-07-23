/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =====================================================================================
-- Author:		Team SunRays
-- Create date: 09-24-2020
-- Description:	EXEC [MAS].[GetSubVerticals] - Get All SubVerticals or Get SubVerticals by Vertical ID or VerticalName
-- =====================================================================================
CREATE PROCEDURE [MAS].[GetSubVerticals] 

AS
BEGIN
	
	SET NOCOUNT ON

	SELECT	SV.SubVerticalId,SV.SubVerticalName
			,V.VerticalId,VerticalName 

	FROM	MAS.SubVerticals SV
			JOIN MAS.Verticals V ON V.VerticalId = SV.VerticalID AND V.IsDeleted = 0
	WHERE	SV.IsDeleted = 0 
			


END
