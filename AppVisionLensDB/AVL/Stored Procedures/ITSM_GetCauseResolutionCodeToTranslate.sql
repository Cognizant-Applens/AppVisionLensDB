/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[ITSM_GetCauseResolutionCodeToTranslate] 
	@ProjectId BIGINT,		
	@Mode NVARCHAR(100)
AS
BEGIN
	BEGIN TRY

IF(@Mode='Cause')
BEGIN
IF EXISTS(SELECT CauseCode FROM [AVL].[DEBT_MAP_CauseCode] WHERE ProjectID=@ProjectID AND (IsDeleted=0 OR IsDeleted IS NULL))
    
    BEGIN 
     SELECT CCMP.CauseID as CauseId,CCMP.CauseCode,CCMP.CauseStatusID AS CauseStatusId,NULL AS MCauseCode FROM [AVL].[DEBT_MAP_CauseCode] CCMP    
      WHERE projectid=@ProjectId and (CCMP.IsDeleted=0 OR CCMP.IsDeleted IS NULL) 	  
	   ORDER BY CCMP.CreatedDate DESC
	  END
 END
 ELSE IF(@Mode='Resolution')
 BEGIN 
	 SELECT RCMP.ResolutionCode as ResolutionCode,RCMP.ResolutionID as ResolutionId ,RCMP.ResolutionStatusID as ResolutionStatusID ,NULL AS MResolutionCode
		 from [AVL].[DEBT_MAP_ResolutionCode] RCMP    
         where projectid=@ProjectId and (RCMP.IsDeleted=0 OR RCMP.IsDeleted IS NULL)		 
		  ORDER BY RCMP.CreatedDate DESC
 END
 END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError 'AVL.ITSM_GetCauseResolutionCodeToTranslate', @ErrorMessage, @ProjectId,0
		
	END CATCH  
END
