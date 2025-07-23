/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetProjectALMMappingDetails]
(
@ProjectID BIGINT
)
AS 
BEGIN    
SET NOCOUNT ON

	DECLARE @IsConfigured BIT
		SET @IsConfigured=0

	IF EXISTS (SELECT TOP 1 1 FROM PP.ALM_MAP_ColumnName (NOLOCK) WHERE ProjectId=@ProjectID and IsDeleted=0)
	BEGIN
		SET @IsConfigured=1
	END
	IF EXISTS (SELECT TOP 1 1  FROM PP.ALM_MAP_WorkType (NOLOCK) WHERE ProjectId=@ProjectID and IsDeleted=0)
	BEGIN
		SET @IsConfigured=1
	END
	IF EXISTS (SELECT TOP 1 1  FROM PP.ALM_MAP_Priority (NOLOCK) WHERE ProjectId=@ProjectID and IsDeleted=0)
	BEGIN
		SET @IsConfigured=1
	END
	IF EXISTS (SELECT TOP 1 1  FROM PP.ALM_MAP_Severity (NOLOCK) WHERE ProjectId=@ProjectID and IsDeleted=0)
	BEGIN
		SET @IsConfigured=1
	END
	IF EXISTS (SELECT TOP 1 1  FROM PP.ALM_MAP_Status (NOLOCK) WHERE ProjectId=@ProjectID and IsDeleted=0)
	BEGIN
		SET @IsConfigured=1
	END

	SELECT sw.ProjectID, sw.IsApplensAsALM as 'IsApplensAsALM', sw.IsExternalALM as 'IsExternalALM', 
		sw.ALMToolID as 'ALMToolID', @IsConfigured as 'IsConfigured'
    FROM PP.ScopeOfWork sw (NOLOCK)
      -- LEFT JOIN MAS.ALMTools al on sw.ALMToolID=al.ALMToolID and al.IsDeleted=0
    WHERE sw.IsDeleted=0 AND sw.ProjectID=@ProjectID
SET NOCOUNT OFF
END
