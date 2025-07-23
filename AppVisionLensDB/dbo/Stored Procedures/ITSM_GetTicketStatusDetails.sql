/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[ITSM_GetTicketStatusDetails] 
(
@ProjectID int,
@ITSMConfigStatus CHAR,
@ITSMToolID INT
)

 AS 
 BEGIN 
 SET NOCOUNT ON;
 BEGIN TRY

 IF (NOT EXISTS(SELECT StatusName FROM [AVL].[TK_MAP_ProjectStatusMapping] (NOLOCK) WHERE ProjectID=@ProjectID AND (IsDeleted=0 OR IsDeleted IS NULL)) AND  @ITSMConfigStatus='A')
    BEGIN 
	   SELECT  0 AS'StatusID',Value AS 'StatusName',NULL AS 'DARTStatusID' FROM [AVL].[MAS_ITSMToolConfiguration]
	    WHERE ITSMScreenID=6 AND (IsDeleted=0 OR IsDeleted IS NULL) AND ITSMToolID=@ITSMToolID
	END
	ELSE 
    BEGIN 
     SELECT StatusID,StatusName,TicketStatus_ID AS 'DARTStatusID' FROM [AVL].[TK_MAP_ProjectStatusMapping] (NOLOCK)
	 WHERE  ProjectID=@ProjectID AND (IsDeleted=0 OR IsDeleted IS NULL) ORDER BY CreatedDate DESC
    END
    END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ITSM_GetTicketStatusDetails] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  


	SET NOCOUNT OFF;
 END
