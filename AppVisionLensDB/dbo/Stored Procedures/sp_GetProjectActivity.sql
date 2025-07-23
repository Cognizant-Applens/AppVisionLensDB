/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[sp_GetProjectActivity]-- 10,10,19100,1    
    @serviceid INT ,      
    @projectid INT ,    
    @flag INT    
AS     
    BEGIN        
 SET NOCOUNT ON;    
        IF ( @flag = 0 )     
            BEGIN    
    
                SELECT DISTINCT    
                        SM.ActivityID ,    
                        SM.ActivityName ,                          
                        SM.ActivityName StdActName ,    
                        SM.ActivityID StdActID   
       --                 (SELECT COUNT(*)     
							--FROM avl.TK_PRJ_ProjectServiceActivityMapping    
							--WHERE     
							--ServiceID=SPM.ServiceID               
							--AND ActivityID=SPM.ActivityID    
							--AND ProjectID=SPM.ProjectID     
							--AND IsDeleted = 0    
							--AND ISNULL(IsHidden,0)=0) AS UnHiddenCount    
						FROM    avl.TK_PRJ_ProjectServiceActivityMapping SPM    
							JOIN avl.TK_MAS_ServiceActivityMapping SM ON SM.ServiceMappingID = SPM.ServiceMapID                                                       
							WHERE   SM.ServiceID = ( CASE @serviceid    
														WHEN 0 THEN SM.ServiceID    
														ELSE @serviceid    
													 END )                            
							AND ProjectID = @projectid    
							AND SPM.IsDeleted = 0   
							AND SM.IsDeleted = 0  
                ORDER BY ActivityName        
            END      
        ELSE     
            BEGIN      
      

			 SELECT DISTINCT    
									0 ActivityID ,    
									'' ActivityName ,    									  
									SM.ActivityName StdActName ,    
									SM.ActivityID StdActID 
							FROM    avl.TK_MAS_ServiceActivityMapping SM 
							LEFT JOIN avl.TK_PRJ_ProjectServiceActivityMapping SPM    
									 ON SM.ServiceMappingID = SPM.ServiceMapID   AND   SM.ServiceID = @serviceid 																 															  
							WHERE   SM.ServiceID = ( CASE @serviceid  
													   WHEN 0 THEN SM.ServiceID    
													   ELSE @serviceid   
													 END )                                                   
									AND SPM.IsDeleted = 0   
									AND SM.IsDeleted = 0  
							ORDER BY ActivityName          
            END    
 SET NOCOUNT OFF;    
    END
