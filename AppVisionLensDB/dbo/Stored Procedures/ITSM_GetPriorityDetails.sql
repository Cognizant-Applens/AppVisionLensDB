/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_GetPriorityDetails] --[dbo].[ITSM_GetPriorityDetails] 4
@ProjectID bigint,
@ITSMConfigStatus CHAR,
@ITSMToolID INT
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY
IF (NOT EXISTS(SELECT PriorityName FROM AVL.TK_MAP_PriorityMapping (NOLOCK) WHERE ProjectID=@ProjectID AND (IsDeleted=0 OR IsDeleted IS NULL)) AND  @ITSMConfigStatus='A')
    BEGIN 

	 SELECT 0 AS 'PriorityIDMapID' ,0 AS'PriorityID',Value AS 'PriorityName',0 AS 'ProjectID',
	 NULL AS 'IsDefaultPriority',NULL AS 'MainspringProjectPriorityID' FROM [AVL].[MAS_ITSMToolConfiguration](NOLOCK)
	    WHERE ITSMScreenID=4 AND (IsDeleted=0 OR IsDeleted IS NULL) AND ITSMToolID=@ITSMToolID
	END

 ELSE 
   BEGIN 
         select PM.PriorityIDMapID,PM.PriorityID,PM.PriorityName,
		 PM.ProjectID,PM.IsDefaultPriority,PM.MainspringProjectPriorityID 
		 from AVL.TK_MAP_PriorityMapping PM (NOLOCK)
            where PM.ProjectID=@ProjectID AND (IsDeleted=0 OR IsDeleted IS NULL) ORDER BY PM.CreatedDateTime DESC
    END
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ITSM_GetPriorityDetails] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  
		SET NOCOUNT OFF;
END
