/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
 
 CREATE PROCEDURE GetEpicDetails (@ProjectID BIGINT) 
 AS 
 BEGIN 
 BEGIN TRY   
     SELECT WI.Project_Id,WI.WorkItemDetailsId,
		    WI.WorkItem_Title AS WorkItemTitle,
			WI.CreatedDate,WI.ModifiedDate,
			WI.WorkItem_Id AS WorkItemId,
			SM.StatusId,WI.[Order],
			WI.ServiceId FROM ADM.ALM_TRN_WorkItem_Details WI WITH(NOLOCK)  
		 JOIN PP.ALM_MAP_WorkType WMT WITH(NOLOCK) ON WMT.WorkTypeMapId = WI.WorkTypeMapId  
		 JOIN PP.ALM_MAS_WorkType WT WITH(NOLOCK) ON WT.WorkTypeId = WT.WorkTypeId  
		 JOIN ADM.MAS_Source S WITH(NOLOCK) ON WI.AdmsourceId = S.SourceId   
		 JOIN  PP.ALM_MAP_Status ST WITH(NOLOCK) ON WI.StatusMapId = ST.StatusMapId  
		 JOIN PP.ALM_MAS_Status SM WITH(NOLOCK) ON ST.StatusId = SM.StatusId  
		WHERE  WI.Project_Id = @ProjectID 
					AND WI.IsDeleted =0 
					AND WMT.IsDeleted =0 
					AND WT.WorkTypeId = 1 
					AND ST.IsDeleted =0
					AND WMT.projectId = @ProjectID 
				    AND S.IsDeleted = 0  
				   AND ST.ProjectId = @ProjectID 
                         
         ORDER BY WI.ModifiedDate DESC  
        
     END TRY BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[GetEpicDetails] ', @ErrorMessage, @ProjectID  
    
END CATCH  END
