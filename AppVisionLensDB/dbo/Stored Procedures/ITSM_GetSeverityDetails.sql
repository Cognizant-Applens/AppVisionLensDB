/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE  PROCEDURE [dbo].[ITSM_GetSeverityDetails] --[dbo].[ITSM_GetSeverityDetails] 4
@ProjectID bigint,
@ITSMConfigStatus CHAR,
@ITSMToolID INT
AS
BEGIN
SET NOCOUNT ON;
IF (NOT EXISTS(SELECT SeverityName FROM [AVL].[TK_MAP_SeverityMapping] (NOLOCK) WHERE ProjectID=@ProjectID AND (IsDeleted=0 OR IsDeleted IS NULL)) AND  @ITSMConfigStatus='A')
    BEGIN 
	   SELECT  0 AS'SeverityIDMapID',0 AS 'SeverityID',Value AS 'SeverityName',0 AS 'ProjectID',NULL AS 'IsDefaultSeverity' 
	   FROM [AVL].[MAS_ITSMToolConfiguration] (NOLOCK)
	   WHERE ITSMScreenID=5 AND (IsDeleted=0 OR IsDeleted IS NULL) AND ITSMToolID=@ITSMToolID
	END
	ELSE 
	  BEGIN
            select SM.SeverityIDMapID,SM.SeverityID,SM.SeverityName,SM.ProjectID,SM.IsDefaultSeverity
			 from  AVL.TK_MAP_SeverityMapping SM (NOLOCK)
             where  SM.ProjectID=@ProjectID AND (SM.IsDeleted=0 OR SM.IsDeleted IS NULL) ORDER BY SM.CreatedDateTime DESC
      END
    SET NOCOUNT OFF;
END
