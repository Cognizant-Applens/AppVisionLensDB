/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE  PROCEDURE [PP].[GetScopeDetailsByProjectID]-- 10769
(
@ProjectID BIGINT 
)
AS
BEGIN
SET NOCOUNT ON
DECLARE @CustomerID BIGINT;
SELECT @CustomerID=CustomerID FROM AVL.MAS_ProjectMaster where ProjectID=@ProjectID AND IsDeleted=0

		SELECT DISTINCT PAV.AttributeValueID as 'ProjectScopeID', ppav.AttributeValueName as 'ProjectScopeName'		
		FROM PP.ProjectAttributeValues PAV
		JOIN MAS.PPAttributeValues ppav on pav.AttributeID=ppav.AttributeID 
		AND PAV.AttributeValueID=ppav.AttributeValueID and ppav.IsDeleted=0 and ppav.AttributeID=1
		WHERE PAV.AttributeID=1 AND PAV.AttributeValueID   IN (1,2,4)
		AND PAV.ProjectID IN (SELECT ProjectID FROM AVL.MAS_ProjectMaster WHERE CustomerID=@CustomerID AND IsDeleted=0)
		AND PAV.IsDeleted=0

END
