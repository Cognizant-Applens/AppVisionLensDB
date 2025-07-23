/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetUserDetailsByProjectID]
(
@ProjectID varchar(100)
)
AS
BEGIN
SET NOCOUNT ON

SELECT UserID as 'UserID',EmployeeID + ' - '+EmployeeName as 'EmployeeName', 
		ProjectID as 'ProjectID', '' as 'CCARole'	
	FROM 
	AVL.MAS_LoginMaster
	WHERE IsDeleted=0
	AND ProjectID=@ProjectID

END
