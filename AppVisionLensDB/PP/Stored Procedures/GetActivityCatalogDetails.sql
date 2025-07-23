/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : Dhivya Bharathi M
-- Create date : Mar 30, 2020
-- Description : Get Activity Catalog Details]
-- Revision    :
-- Revised By  :
-- [PP].[GetActivityCatalogDetails] 4705
-- ===========================================================================================

CREATE PROCEDURE [PP].[GetActivityCatalogDetails]
@ProjectID BIGINT
AS 
  BEGIN 
	BEGIN TRY 
		SET NOCOUNT ON;

			CREATE TABLE #ServicesList
				(
				ServProjMapID BIGINT NULL,
				ServiceMapID INT NULL,
				ServiceID INT NULL,
				ServiceName NVARCHAR(100) NULL,
				ActivityID INT NULL,
				ActivityName NVARCHAR(200) NULL,
				IsMainspringData NVARCHAR(10) NULL,
				[Status] NVARCHAR(100) NULL,
				IsTicketTypeMapped INT NULL
				)

		
        INSERT INTO #ServicesList
		SELECT PAM.ServProjMapID,PAM.ServiceMapID,SAM.ServiceID,SAM.ServiceName,
		SAM.ActivityID,SAM.ActivityName,IsMainspringData,
		CASE WHEN PAM.EffectiveDate IS NOT NULL AND PAM.EffectiveDate <= GETDATE() THEN 'InActive'
		else 'Active' 
		END AS [Status],0 AS IsTicketTypeMapped
		FROM AVL.TK_PRJ_ProjectServiceActivityMapping PAM
		INNER JOIN AVL.TK_MAS_ServiceActivityMapping  SAM
		ON PAM.ServiceMapID=SAM.ServiceMappingID AND ISNULL(PAM.IsDeleted,0)=0 and 
		ISNULL(SAM.IsDeleted,0)=0
		WHERE PAM.ProjectID=@ProjectID
		ORDER BY SAM.ServiceName,SAM.ActivityName ASC
		        
		UPDATE SL
		SET SL.IsTicketTypeMapped=1 
		FROM #ServicesList SL
		INNER JOIN AVL.TK_MAP_TicketTypeServiceMapping(NOLOCK) TTS ON SL.ServiceID=TTS.ServiceID
		WHERE TTS.ProjectID = @ProjectID AND ISNULL(TTS.IsDeleted,0)=0

		SELECT ServProjMapID,ServiceMapID,ServiceID,ServiceName,ActivityID,
		ActivityName,IsMainspringData,[Status],IsTicketTypeMapped 
		FROM #ServicesList
    ORDER BY ServiceName,ActivityName ASC

		END TRY
    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
		ROLLBACK TRAN
        --INSERT Error     
        EXEC AVL_INSERTERROR  '[PP].[GetActivityCatalogDetails]', @ErrorMessage,  0, 0 
    END CATCH 
  END
