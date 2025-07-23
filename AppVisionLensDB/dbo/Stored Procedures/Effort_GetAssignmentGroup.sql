/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--select * from [AVL].[MAS_AssignmentGroup]


CREATE PROCEDURE [dbo].[Effort_GetAssignmentGroup] --4
@ProjectID BIGINT 
AS
BEGIN
SELECT AG.AssignmentGroupMapID ,AG.AssignmentGroupName
 from [AVL].[MAP_AssignmentGroupMapping] AG WHERE ProjectID=@ProjectID

END


--select * from  [AVL].[MAP_AssignmentGroupMapping]

--insert into  [AVL].[MAP_AssignmentGroupMapping] values(5,'AG3',7,GETDATE(),NULL,NULL,0)
--UPDATE  [AVL].[MAP_AssignmentGroupMapping] SET PROJECTID=4

--where  assignmentgroupmapid=3
--SELECT * FROM
--[AVL].[MAS_ProjectMaster]
