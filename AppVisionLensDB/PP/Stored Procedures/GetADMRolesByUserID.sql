/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetADMRolesByUserID]
(
@UserID BIGINT,
@ProjectID BIGINT
)
AS
BEGIN

SET NOCOUNT ON

SELECT AA.CCARole as 'ADMRole', '' as 'CCARole', 
		AA.UserCapacity as 'UserCapacity' , LM.MandatoryHours as 'MandatoryHours'
	FROM PP.Project_PODDetails pd 
	JOIN ADM.AssociateAttributes AA ON PD.PODDetailID=AA.PODDetailID and 
									 AA.IsDeleted=0
	LEFT JOIN AVL.MAS_LoginMaster LM ON AA.UserId = LM.UserID AND LM.IsDeleted=0
	WHERE AA.UserId=@UserID AND PD.IsDeleted=0 AND PD.ProjectID=@ProjectID
END
