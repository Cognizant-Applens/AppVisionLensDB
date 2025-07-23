/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ================================================================================================================
-- Author:		Team SunRays
-- Create date: 09-24-2020
-- Description:	EXEC [MAS].[GetSubBusinessUnits1] - Get All Sub Business Units or Get Sub Business Units by Business Unit Id or By Business Units Name
-- =================================================================================================================
CREATE PROCEDURE [MAS].[GetSubBusinessUnits1] 

AS
BEGIN

	SET NOCOUNT ON

	SELECT	SBU1.SBU1ID,SBU1.SBU1Name
			,BU.BusinessUnitID,BusinessUnitName 

	FROM	MAS.SubBusinessUnits1 SBU1
			JOIN MAS.BusinessUnits BU ON BU.BusinessUnitID = SBU1.BusinessUnitID AND BU.IsDeleted = 0
	WHERE   SBU1.IsDeleted = 0
			

END
