/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[ITSM_GetResolutionCodeDetails]
@ProjectId int,
@ITSMConfigStatus CHAR,
@ITSMToolID INT
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
IF (NOT EXISTS(SELECT ResolutionCode FROM [AVL].[DEBT_MAP_ResolutionCode] (NOLOCK) WHERE ProjectID=@ProjectID AND (IsDeleted=0 OR IsDeleted IS NULL)) AND  @ITSMConfigStatus='A')
    BEGIN 
	   SELECT  0 AS'ResolutionId',Value AS 'ResolutionCode',0 AS 'ResolutionStatusID',NULL AS 'HasITSMTool' 
	   FROM [AVL].[MAS_ITSMToolConfiguration] (NOLOCK)
	    WHERE ITSMScreenID=8 AND (IsDeleted=0 OR IsDeleted IS NULL) AND ITSMToolID=@ITSMToolID
	END

	ELSE
    BEGIN 
         SELECT RCMP.ResolutionCode as ResolutionCode,RCMP.ResolutionID as ResolutionId ,RCMP.ResolutionStatusID as ResolutionStatusID,PM.HasRCITSMTool AS  'HasITSMTool'
		 from [AVL].[DEBT_MAP_ResolutionCode] RCMP (NOLOCK) JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON RCMP.ProjectID = PM.ProjectID
         where RCMP.projectid=@ProjectId and (RCMP.IsDeleted=0 OR RCMP.IsDeleted IS NULL) ORDER BY RCMP.CreatedDate DESC
 END
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ITSM_GetResolutionCodeDetails] ', @ErrorMessage,@ProjectId,0
		
	END CATCH  
	SET NOCOUNT OFF;
END
