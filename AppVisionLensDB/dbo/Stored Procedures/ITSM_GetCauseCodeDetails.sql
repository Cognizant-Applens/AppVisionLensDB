/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[ITSM_GetCauseCodeDetails] 
@ProjectId int,
@ITSMConfigStatus CHAR,
@ITSMToolID INT
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY

IF (NOT EXISTS(SELECT CauseCode FROM [AVL].[DEBT_MAP_CauseCode] (NOLOCK) WHERE ProjectID=@ProjectID AND (IsDeleted=0 OR IsDeleted IS NULL)) AND  @ITSMConfigStatus='A')
    BEGIN 
	   SELECT  0 AS'CauseId',Value AS 'CauseCode',0 AS 'CauseStatusId',NULL AS 'HasITSMTool' FROM [AVL].[MAS_ITSMToolConfiguration] (NOLOCK) 
	    WHERE ITSMScreenID=7 AND (IsDeleted=0 OR IsDeleted IS NULL)  AND ITSMToolID=@ITSMToolID
	END

	ELSE
    BEGIN 
     select CCMP.CauseID as CauseId,CCMP.CauseCode,CCMP.CauseStatusID as CauseStatusId,PM.HasCCITSMTool AS HasITSMTool from [AVL].[DEBT_MAP_CauseCode] CCMP (NOLOCK) JOIN AVL.MAS_ProjectMaster PM
	 ON CCMP.ProjectID = PM.ProjectID
      WHERE CCMP.projectid=@ProjectId and (CCMP.IsDeleted=0 OR CCMP.IsDeleted IS NULL) ORDER BY CCMP.CreatedDate DESC

 END
 END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ITSM_GetCauseCodeDetails]  ', @ErrorMessage, @ProjectId,0
		
	END CATCH  


	SET NOCOUNT OFF;
END
