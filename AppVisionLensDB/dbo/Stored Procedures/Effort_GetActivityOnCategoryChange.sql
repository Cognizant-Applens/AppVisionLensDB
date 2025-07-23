/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[Effort_GetActivityOnCategoryChange] --4,2,2
@projectId INT=null,
@serviceId int=null,
@CategoryId int=null 

--@TsDate Date  
AS   
    BEGIN   
	BEGIN TRY	
	
 SET NOCOUNT ON;      
 
 DECLARE @IsMainspringConfig CHAR;
	SET @IsMainspringConfig=(SELECT IsMainSpringConfigured FROM AVL.MAS_ProjectMaster 
							 WHERE ProjectID=@ProjectID)
							 
							 IF @IsMainspringConfig = 'Y'
	BEGIN
	       SELECT DISTINCT  
                    SPM.ActivityID ,  
                    SPM.ActivityName                     
            FROM    AVL.TK_PRJ_ServiceProjectMapping SPM  
                    JOIN AVL.TK_MAS_ServiceMapping SM ON SM.ServiceID = SPM.ServiceID  
                                                 -- AND SM.ServiceMappingID = SPM.ServiceMapID  
            WHERE   SPM.ServiceID=@serviceId-- IN ( SELECT  Item FROM    dbo.Split(@serviceid, ','))   
                        AND  SPM.CategoryID=@CategoryId-- IN ( SELECT  Item FROM    dbo.Split(@CategoryId, ',')) 
                    AND ProjectID = @projectId  
                    --AND SPM.IsDeleted = 'N'  and  SPM.IsMainspringData='Y'
                  --AND (ISNULL(SPM.IsHidden,0) = 0 OR(ISNULL(SPM.IsHidden,0) = 1 AND Convert(date,SPM.EffectiveDate) > Convert(date,@TsDate)))                                    
            ORDER BY  SPM.ActivityName   
     
	END
	ELSE
	BEGIN
            SELECT DISTINCT  
                    SPM.ActivityID ,  
                    SPM.ActivityName                     
            FROM   AVL.TK_PRJ_ServiceProjectMapping SPM  
                    JOIN AVL.TK_MAS_ServiceMapping SM ON SM.ServiceID = SPM.ServiceID  
                                                  --AND SM.ServiceMappingID = SPM.ServiceMapID  
            WHERE   SPM.ServiceID=@serviceId --IN ( SELECT  Item FROM    dbo.Split(@serviceid, ','))   
                        AND  SPM.CategoryID=@CategoryId-- IN ( SELECT  Item FROM    dbo.Split(@CategoryId, ',')) 
                    AND ProjectID = @projectId  
                  --  AND SPM.IsDeleted = 'N'   
                 -- AND (ISNULL(SPM.IsHidden,0) = 0 OR(ISNULL(SPM.IsHidden,0) = 1 AND Convert(date,SPM.EffectiveDate) > Convert(date,@TsDate)))                                    
            ORDER BY  SPM.ActivityName   
            
     END                   
    
  SET NOCOUNT OFF;  
           
    
--select distinct SPM.ActivityID,SPM.ActivityName from AVL.TK_TRN_TicketDetail TD 
--join AVL.APP_MAP_ApplicationProjectMapping APM on TD.ApplicationProjectMapID=APM.Project_Application_MapID
--join AVL.TK_PRJ_ServiceProjectMapping SPM on APM.ProjectID=SPM.ProjectID where TD.ApplicationProjectMapID=@AppPrjMapID
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[Effort_GetActivityOnCategoryChange] ', @ErrorMessage, @projectId,0
		
	END CATCH 

END
