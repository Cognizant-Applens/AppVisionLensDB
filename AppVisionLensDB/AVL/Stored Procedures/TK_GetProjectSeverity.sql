/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[TK_GetProjectSeverity]
(
@ProjectID INT
)

AS
BEGIN
BEGIN TRY
select NULL as SeverityID,'--Select--' as SeverityName
	union
	SELECT  SeverityIDMapID as SeverityID,SeverityName FROM AVL.TK_MAP_SeverityMapping 
	WHERE IsDeleted = 0 AND ProjectID = @ProjectID
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[TK_GetProjectSeverity] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  





END
