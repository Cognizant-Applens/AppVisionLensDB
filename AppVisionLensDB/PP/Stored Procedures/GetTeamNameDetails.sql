/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE PP.GetTeamNameDetails
(
@ProjectID BIGINT
)
AS
BEGIN 
SET NOCOUNT ON

	SELECT PODDetailID as 'TeamNameID',ProjectID as 'ProjectID',PODName as 'TeamName' FROM PP.Project_PODDetails WHERE IsDeleted=0 AND ProjectID=@ProjectID 
	ORDER BY CreatedDate Desc
END
