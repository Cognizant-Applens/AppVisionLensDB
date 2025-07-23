/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetCapacityByUserID]
(
@UserID BIGINT,
@ProjectID BIGINT
)
AS
BEGIN

SET NOCOUNT ON

SELECT DISTINCT MandatoryHours as 'Capacity' FROM AVL.MAS_LoginMaster LM
	WHERE UserId=@UserID AND ProjectID=@ProjectID AND LM.IsDeleted=0
END
