/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[BCS_ProjectDetails]
@EmployeID nvarchar(50)
AS
select a.ProjectID,a.EsaProjectID,a.ProjectName from [AVL].[MAS_ProjectMaster] a join
[AVL].[MAS_LoginMaster] b on a.ProjectID = b.ProjectID
where  a.IsDeleted =0 and a.IsCoginzant = 1 and b.IsDeleted =0 
and b.EmployeeID = @EmployeID
