/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE PP.DeleteTeamDetails
(
@TeamID BIGINT,
@ProjectID BIGINT
)
AS
BEGIN

	IF EXISTS (select 1 from pp.Project_PODDetails WHERE PODDetailID=@TeamID)
	BEGIN
			DELETE FROM pp.Project_PODDetails WHERE PODDetailID=@TeamID and ProjectID=@ProjectID

			DELETE FROM ADM.AssociateAttributes WHERE PODDetailID =@TeamID
	END

END
