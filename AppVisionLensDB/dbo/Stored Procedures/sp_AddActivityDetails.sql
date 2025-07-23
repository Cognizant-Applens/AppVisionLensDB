/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[sp_AddActivityDetails]      
@Serviceid VARCHAR(50),    
@ActivityId VARCHAR(50),      
@ProjectID INT,    
@UserID VARCHAR(50),    
@IsDeleted VARCHAR(50)    
AS       
    BEGIN                                               
        SET NOCOUNT ON;    
			
			DECLARE @ServiceActivityCount int
			SET @ServiceActivityCount = (SELECT  COUNT(*) FROM avl.TK_MAS_ServiceType ST
											JOIN avl.TK_MAS_Service S ON S.ServiceType = ST.ServiceTypeID
											JOIN avl.TK_MAS_ServiceActivityMapping SAM ON SAM.ServiceTypeID = ST.ServiceTypeID AND SAM.ServiceID = S.ServiceID
											JOIN avl.TK_PRJ_ProjectServiceActivityMapping SPM ON SPM.ServiceMapID = SAM.ServiceMappingID
											WHERE SPM.ProjectID = @ProjectID          
											      AND SAM.ServiceID = @Serviceid
												  AND SPM.Isdeleted = 0)
			IF NOT EXISTS (    
			SELECT 1 from AVL.TM_TRN_TimesheetDetail NOLOCK where ProjectId = @ProjectID     
			and ServiceId = @Serviceid     
			and ActivityId = @ActivityId    
						)    
					BEGIN    
					--DELETE FROM AVL.TK_PRJ_ProjectServiceActivityMapping  
					IF (NOT EXISTS (SELECT 1 from AVL.TK_MAP_TicketTypeServiceMapping NOLOCK where ProjectId = @ProjectID     
									and ServiceId = @Serviceid) OR 
									 (EXISTS (SELECT 1 from AVL.TK_MAP_TicketTypeServiceMapping NOLOCK where ProjectId = @ProjectID     
									and ServiceId = @Serviceid) AND (@ServiceActivityCount > 1)))
								BEGIN


									UPDATE AVL.TK_PRJ_ProjectServiceActivityMapping  
									SET  IsDeleted = 1,   
										 ModifiedDateTime = GETDATE(),
										 ModifiedBY  =  @UserID  
									WHERE ServProjMapID IN(SELECT  SPM.ServProjMapID FROM avl.TK_MAS_ServiceType ST
															JOIN avl.TK_MAS_Service S ON S.ServiceType = ST.ServiceTypeID
															JOIN avl.TK_MAS_ServiceActivityMapping SAM ON SAM.ServiceTypeID = ST.ServiceTypeID AND SAM.ServiceID = S.ServiceID
															JOIN avl.TK_PRJ_ProjectServiceActivityMapping SPM ON SPM.ServiceMapID = SAM.ServiceMappingID
															WHERE (SAM.ActivityID = @ActivityId  OR  @ActivityId = '0')      
																  AND SPM.ProjectID = @ProjectID          
																  AND SAM.ServiceID = @Serviceid)          
										SELECT 3 AS OUTPUT           
								END 
								ELSE
									BEGIN
										SELECT 2 AS OUTPUT 
									END	
					END					   
			ELSE    
					BEGIN    
						SELECT 1 AS OUTPUT    
					END    
			--END            
SET NOCOUNT OFF;          
END
