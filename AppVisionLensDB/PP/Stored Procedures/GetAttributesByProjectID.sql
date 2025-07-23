/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE  PROCEDURE [PP].[GetAttributesByProjectID]
(
@CustomerID BIGINT,
@ProjectID BIGINT 
)
AS
BEGIN
SET NOCOUNT ON

		SELECT DISTINCT PM.IsCoginzant,PAV.AttributeValueID as 'ProjectScopeID', PPAV.AttributeValueName as 'ProjectScopeName'		
		FROM AVL.MAS_ProjectMaster PM
		JOIN PP.ProjectAttributeValues PAV on PM.ProjectID=PAV.ProjectID
		JOIN MAS.PPAttributeValues PPAV on PAV.AttributeID=PPAV.AttributeID AND PAV.AttributeValueID=PPAV.AttributeValueID
		WHERE PM.CustomerID=@CustomerID AND PM.ProjectID=@ProjectID AND PAV.AttributeID=1
		AND PM.IsDeleted=0 AND PAV.IsDeleted=0 AND PPAV.IsDeleted=0

SET NOCOUNT OFF	
END
