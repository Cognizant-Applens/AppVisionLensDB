/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[Effort_GetCategoryOnServiceChange] --2,4
@ServiceID int=null,
@ProjectID int=null
--@AppPrjMapID int=null
as 
begin
BEGIN TRY
--select distinct SPM.CategoryID,SPM.CategoryName from AVL.TK_TRN_TicketDetail TD 
--join AVL.APP_MAP_ApplicationProjectMapping APM on TD.ApplicationProjectMapID=APM.Project_Application_MapID
--join AVL.TK_PRJ_ServiceProjectMapping SPM on APM.ProjectID=SPM.ProjectID where TD.ApplicationProjectMapID=@AppPrjMapID


DECLARE @IsMainspringConfig CHAR;
	SET @IsMainspringConfig=(SELECT IsMainSpringConfigured FROM AVL.MAS_ProjectMaster 
							 WHERE ProjectID=@ProjectID)
		--Mainspring Integration Code
	IF @IsMainspringConfig = 'Y'
	BEGIN
	
	          SELECT DISTINCT  
                    SPM.CategoryID ,  
                    SPM.CategoryName                     
            FROM    AVL.TK_PRJ_ServiceProjectMapping SPM  
                    JOIN AVL.TK_MAS_ServiceMapping SM ON --SM.ServiceID = SPM.ServiceID  
                                                   SM.ServiceMappingID = SPM.ServiceMapID  
            WHERE   SPM.ServiceID= @ServiceID--IN ( SELECT  Item  FROM    dbo.Split(@serviceid, ','))   
                    AND ProjectID = @projectid -- AND spm.IsMainspringData='Y'
                   -- AND SPM.IsDeleted = 'N'                            
            ORDER BY  SPM.CategoryName                      
    
	END
	ELSE
	BEGIN
	
	
	          SELECT DISTINCT  
                    SPM.CategoryID ,  
                    SPM.CategoryName                     
            FROM    AVL.TK_PRJ_ServiceProjectMapping SPM  
                    JOIN AVL.TK_MAS_ServiceMapping SM ON --SM.ServiceID = SPM.ServiceID  
                                                 SM.ServiceMappingID = SPM.ServiceMapID  
            WHERE   SPM.ServiceID=@ServiceID-- IN ( SELECT  Item FROM    dbo.Split(@serviceid, ','))   
                    AND ProjectID = @projectid  
                    --AND SPM.IsDeleted = 'N'   
                  -- AND (ISNULL(SPM.IsHidden,0) = 0 OR(ISNULL(SPM.IsHidden,0) = 1 AND Convert(date,SPM.EffectiveDate) > Convert(date,@TsDate)))                                
            ORDER BY  SPM.CategoryName      

end
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[dbo].[Effort_GetCategoryOnServiceChange] ', @ErrorMessage, @ProjectID,0
	END CATCH  
End
