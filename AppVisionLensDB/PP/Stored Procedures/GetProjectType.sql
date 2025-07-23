/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE pp.GetProjectType 
(
@ProjectID BIGINT
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @IsCognizantDetails bit
	SELECT @IsCognizantDetails= IsCoginzant  FROM AVL.MAS_ProjectMaster 
	WHERE IsDeleted=0 and ProjectID=@ProjectID
	
	SELECT @IsCognizantDetails as IsCognizant
	SET NOCOUNT OFF;
END
