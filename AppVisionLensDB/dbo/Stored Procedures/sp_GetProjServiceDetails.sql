/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[sp_GetProjServiceDetails] --35606
 @projectid INT 
AS   
    BEGIN       
	 BEGIN TRY
BEGIN TRAN
	SET NOCOUNT ON;		
			DECLARE @IsMainspringConfig CHAR; 
			set @IsMainspringConfig = (Select ISNULL(IsMainSpringConfigured,'N') from AVL.MAS_ProjectMaster where ProjectID = @ProjectID)
			
			IF(@IsMainspringConfig = 'Y')
			BEGIN
				SELECT   
						SM.ServiceID ,  
						SM.ServiceName ,  
						SM.ServiceShortName  
				FROM    AVL.TK_MAS_ServiceActivityMapping SM
				JOIN	AVL.TK_PRJ_ProjectServiceActivityMapping SPM  ON SPM.ServiceMapID = SM.ServiceMappingID 
				WHERE   SPM.ProjectID = @projectid 
						AND SPM.IsDeleted = 0  
						AND SM.IsDeleted = 0
						AND SM.ServiceTypeID not in ('4')
						and SM.ServiceID<>41
						AND (SELECT COUNT(*) 
								FROM AVL.TK_PRJ_ProjectServiceActivityMapping
								WHERE 
									ServiceMapID=SPM.ServiceMapID
									AND ProjectID=SPM.ProjectID
									AND IsDeleted = 0 
									AND ISNULL(IsHidden,0)=0)>0 
						GROUP BY SM.ServiceID ,  
						SM.ServiceName ,  
						SM.ServiceShortName  
				ORDER BY SM.ServiceName    
			END
			ELSE
			BEGIN
					SELECT   
						SM.ServiceID ,  
						SM.ServiceName ,  
						SM.ServiceShortName  
				FROM    AVL.TK_MAS_ServiceActivityMapping SM
				JOIN	AVL.TK_PRJ_ProjectServiceActivityMapping SPM  ON SPM.ServiceMapID = SM.ServiceMappingID 
				WHERE   SPM.ProjectID = @projectid 
						AND SPM.IsDeleted = 0  
						AND SM.IsDeleted = 0
						and SM.ServiceID<>41
						--AND SM.ServiceTypeID not in ('4')
						AND (SELECT COUNT(*) 
								FROM AVL.TK_PRJ_ProjectServiceActivityMapping
								WHERE 
									ServiceMapID=SPM.ServiceMapID
									AND ProjectID=SPM.ProjectID
									AND IsDeleted = 0 
									AND ISNULL(IsHidden,0)=0)>0 
						GROUP BY SM.ServiceID ,  
						SM.ServiceName ,  
						SM.ServiceShortName  
				ORDER BY SM.ServiceName 
			END
		SET NOCOUNT OFF;
		COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'dbo.sp_GetProjServiceDetails ', @ErrorMessage, 0 ,@projectid
		
	END CATCH  
    END
