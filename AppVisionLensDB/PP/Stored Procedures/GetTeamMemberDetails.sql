/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE PP.GetTeamMemberDetails
(
@PODDetailID BIGINT
)
AS
BEGIN
SET NOCOUNT ON

		SELECT AA.Id as 'PODUserMapID', AA.UserID, LM.EmployeeID + ' - '+LM.EmployeeName as 'EmployeeName', 
		AA.PODDetailID, AA.CCARole as 'ADMRoleID',AA.UserCapacity  as 'UserCapacity',
		rm.RoleName as 'ADMRoleName'
		FROM ADM.AssociateAttributes AA
		JOIN AVL.MAS_LoginMaster LM on aa.UserId=Lm.UserID and LM.IsDeleted=0
		LEFT JOIN PP.ALM_RoleMaster rm on AA.CCARole=rm.RoleID
		WHERE AA.PODDetailID=@PODDetailID AND AA.IsDeleted=0

END
