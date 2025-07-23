/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetProjectScopeDetails] 
(
@ProjectID BIGINT
)
AS
BEGIN
SET NOCOUNT ON
DECLARE @ShowALMConfig BIT =0
DECLARE @ShowITSMConfig BIT=0
DECLARE @ShowBothConfig BIT=0

/* AttributeID =1 = ProjectScope*/
		SELECT PAV.AttributeValueID as 'AttributeValueID', ppav.AttributeValueName as 'AttributeValueName'
		INTO #ScopeDetails
		FROM PP.ProjectAttributeValues PAV  with(nolock)
		JOIN MAS.PPAttributeValues ppav  with(nolock) on pav.AttributeID=ppav.AttributeID 
				and PAV.AttributeValueID=ppav.AttributeValueID and ppav.IsDeleted=0 and ppav.AttributeID=1
		WHERE PAV.AttributeID=1 and PAV.ProjectID=@ProjectID AND PAV.IsDeleted=0

IF EXISTS ( SELECT TOP 1 1 FROM #ScopeDetails  with(nolock))
BEGIN
	
	IF EXISTS(SELECT TOP 1 1 FROM #ScopeDetails with(nolock) WHERE AttributeValueID in (1,4))
	BEGIN 
		SET @ShowALMConfig=1
	END
	IF EXISTS(SELECT TOP 1 1 FROM #ScopeDetails  with(nolock) WHERE AttributeValueID in (2,3))
	BEGIN
		SET @ShowITSMConfig=1
	END

	

END
drop table #ScopeDetails

SELECT @ShowALMConfig AS 'ShowALMConfig',@ShowITSMConfig AS 'ShowITSMConfig'

END
