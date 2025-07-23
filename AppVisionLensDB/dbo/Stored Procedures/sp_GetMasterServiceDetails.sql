/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[sp_GetMasterServiceDetails]-- 'General', 3831  
@ServType VARCHAR(50) ,  
@projectid INT  
AS   
BEGIN             
SET NOCOUNT ON;  

	SELECT   
	SM.ServiceID,  
	ST.ServiceTypeName,  
	LTRIM(RTRIM(SM.ServiceName))as ServiceName    
	FROM avl.TK_MAS_ServiceActivityMapping SM 
	JOIN avl.TK_MAS_ServiceType ST on ST.ServiceTypeID = SM.ServiceTypeID
	WHERE     
		ST.ServiceTypeName = @ServType  
		AND SM.ServiceID<>41
		AND SM.IsDeleted = 0  
		AND ST.Isdeleted = 0
		AND NOT EXISTS (SELECT  SAM.ServiceID   
								FROM avl.TK_MAS_ServiceType ST
								JOIN avl.TK_MAS_Service S ON S.ServiceType = ST.ServiceTypeID
								JOIN avl.TK_MAS_ServiceActivityMapping SAM ON SAM.ServiceTypeID = ST.ServiceTypeID AND SAM.ServiceID = S.ServiceID
								JOIN avl.TK_PRJ_ProjectServiceActivityMapping SPM ON SPM.ServiceMapID = SAM.ServiceMappingID 
								WHERE     
									ST.ServiceTypeName = @ServType  
									AND ProjectID = @projectid  
									AND SM.ServiceID = SAM.Serviceid  
									AND ST.IsDeleted = 0 
									AND S.IsDeleted = 0   
									AND SAM.IsDeleted = 0   
									AND SPM.IsDeleted = 0     
									GROUP BY SAM.ServiceID )  
	GROUP BY ServiceID, ServiceTypeName, ServiceName  
	ORDER BY ServiceName    
SET NOCOUNT OFF;              
END
