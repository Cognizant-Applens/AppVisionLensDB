/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[GetAssignmentGroupByProjectID] --10337,'627384'
@ProjectID BIGINT,
@UserID NVARCHAR(100)
AS
BEGIN
 
 DECLARE @supportType bigint
 set @supportType=(SELECT isnull(SupportTypeId,1) from AVL.MAP_ProjectConfig where ProjectID=@ProjectID )
 

 SELECT AssignmentGroupMapID,AssignmentGroupName from AVL.BOTAssignmentGroupMapping WHERE ProjectID=@ProjectID and IsDeleted=0 and 
(@supportType=3 OR (SupportTypeID=@supportType)) AND IsBOTGroup=0


END
