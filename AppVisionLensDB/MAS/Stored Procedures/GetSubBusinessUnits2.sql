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
-- Create date: 09-24-2020
-- Description:	EXEC [MAS].[GetSubBusinessUnits2] - Get All SubBusinessunits 2 Or Get Sub business units 2 by SBU1 ID Or by SBU1 Name
-- =============================================
CREATE PROCEDURE [MAS].[GetSubBusinessUnits2] 

AS
BEGIN
	
	SET NOCOUNT ON

	SELECT	SBU2.SBU2ID,SBU2.SBU2Name
			,SBU1.SBU1ID,SBU1Name
	
	FROM	MAS.SubBusinessUnits2 SBU2
			JOIN MAS.SubBusinessUnits1 SBU1 ON SBU1.SBU1ID = SBU2.SBU1ID  AND SBU1.IsDeleted = 0
	WHERE	SBU2.IsDeleted = 0
			
  
END
