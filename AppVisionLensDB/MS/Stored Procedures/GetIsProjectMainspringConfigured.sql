/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [MS].[GetIsProjectMainspringConfigured]
	@ProjectID INT
AS 
BEGIN
SET NOCOUNT ON;
	DECLARE @IsMainspringConfigured CHAR;
	SET @IsMainspringConfigured=(SELECT IsMainSpringConfigured FROM 
								AVL.MAS_ProjectMaster(NOLOCK)
								 WHERE ProjectID=@ProjectID)
	IF @IsMainspringConfigured ='Y'
	BEGIN
		SELECT 1 AS IsMainspringConfigured
	END
	ELSE 
	BEGIN
		SELECT 0 AS IsMainspringConfigured
	END
	
SET NOCOUNT OFF;
END

