/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[sp_GetProjectService] --'General', 3831  
    @ServType VARCHAR(50) ,        
    @Projectid INT        
AS         
    BEGIN                 
  SET NOCOUNT ON;    
    
        SELECT  DISTINCT    
                SAM.ServiceID ,        
                ST.ServiceTypeName AS ServiceType,        
                LTRIM(RTRIM(SAM.ServiceName)) AS ServiceName    
    --          +  CASE WHEN (SELECT COUNT(*)     
				--	FROM avl.TK_PRJ_ProjectServiceActivityMapping  
				--	WHERE     
				--		ServiceID=SPM.ServiceID    
				--		AND ProjectID=SPM.ProjectID    
				--		AND IsDeleted = 0     
				--		AND ISNULL(IsHidden,0)=0)=0    
				--			THEN ' (Hidden)'    
				--	ELSE ''    
				--	END +    
				--	CASE WHEN (SELECT COUNT(*)       
				--		FROM  avl.TK_PRJ_ProjectServiceActivityMapping       
				--		WHERE       
				--		ServiceID=SPM.ServiceID       
				--		AND ProjectID=@ProjectID      
				--		AND IsDeleted = 0       
				--		--AND ISNULL(IsC20Configured,0)=0
				--		)=0      
				--			THEN ' *'      
				--	ELSE ''      
				--END AS ServiceName     
		--SPM.IsC20Configured AS IsC20Configured  
		,case when  spm.EffectiveDate is null or  SPM.EffectiveDate>=GETDATE()   then 0
		else 1 end as 'IsDisabled'    
		
                    into #servicetemp                    
                     
			FROM  avl.TK_MAS_ServiceType ST (NOLOCK)
				  JOIN avl.TK_MAS_Service S (NOLOCK) ON S.ServiceType = ST.ServiceTypeID
				  JOIN avl.TK_MAS_ServiceActivityMapping SAM (NOLOCK) ON SAM.ServiceTypeID = ST.ServiceTypeID AND SAM.ServiceID = S.ServiceID
				  JOIN avl.TK_PRJ_ProjectServiceActivityMapping SPM (NOLOCK) ON SPM.ServiceMapID = SAM.ServiceMappingID     
			WHERE (ST.ServiceTypeName = @ServType  OR @ServType = '')      
					AND ProjectID = @Projectid        
					AND ST.IsDeleted = 0 
					AND S.IsDeleted = 0 
					AND SAM.IsDeleted = 0 
					AND SPM.IsDeleted = 0    
					AND S.ServiceID<>41 AND S.ScopeID IN(2,3)
			ORDER BY 3     
				SELECT serviceid into #serviceiddup from #Servicetemp (NOLOCK) group by serviceid
			having count(serviceid)>1
			--SELECT * from  #serviceid
			delete from  #Servicetemp where serviceid IN(SELECT serviceid from #serviceiddup (NOLOCK))
			 and isdisabled=1
			 SELECT * from #Servicetemp       
  SET NOCOUNT OFF;    
    END
