/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
  
CREATE PROCEDURE [AVL].[GetTicketDetailsForServiceClassification]   
  
  
AS   
  BEGIN  
  SET NOCOUNT ON;
      BEGIN TRY   
  
  SELECT distinct TD.TimeTickerID,TD.TicketID,  
  CASE WHEN PM.IsMultilingualEnabled = 1 AND ((SELECT AVL.CheckIfMultilingualColumnsActiveOrNot( PM.ProjectID ,1,1)) = 1)  
   AND   
    MLT.IsTicketDescriptionUpdated = 0 AND ISNULL(MLT.TicketDescription,'')!='' THEN   
    MLT.TicketDescription   
   ELSE   
    TD.TicketDescription        
  END AS TicketDescription,  
  C.ClusterName AS CauseCode,  
  D.ClusterName AS ResolutionCode    
  FROM AVL.TK_TRN_TicketDetail TD (NOLOCK) INNER JOIN AVL.MAS_ProjectMaster PM  (NOLOCK)
  ON PM.ProjectID = TD.ProjectID   
  AND PM.IsDeleted=0  
  INNER JOIN AVL.ServiceAutoClassification_TicketUpload TP  (NOLOCK) 
  ON TP.PROJECTID =  TD.ProjectID  
  AND TP.[Ticket ID] = TD.TicketID  
  AND TD.IsDeleted = 0  
  LEFT JOIN [AVL].[debt_map_causecode] DC  (NOLOCK)
  ON TD.CauseCodeMapID = DC.CauseID   
  AND TD.ProjectID = DC.ProjectID   
  LEFT JOIN MAS.Cluster C  (NOLOCK) 
  ON DC.CauseStatusID = C.ClusterID       
  LEFT JOIN [AVL].[debt_map_resolutioncode] RC  (NOLOCK)
  ON TD.ResolutionCodeMapID = RC.ResolutionID   
  AND TD.ProjectID = RC.ProjectID   
  LEFT JOIN MAS.Cluster D  (NOLOCK) 
  ON RC.ResolutionStatusID = D.ClusterID    
  LEFT JOIN [AVL].TK_TRN_Multilingual_TranslatedTicketDetails MLT  (NOLOCK)
  ON MLT.TimeTickerID = TD.TimeTickerID  
  LEFT JOIN AVL.PRJ_MultilingualColumnMapping MCP (NOLOCK) ON MCP.ProjectID =TP.PROJECTID   
  LEFT JOIN AVL.MAS_MultilingualColumnMaster MCM (NOLOCK) ON  MCM.ColumnID=MCP.ColumnID AND  
  MCM.IsActive=1 AND MCP.IsActive = 1 AND MCP.ColumnID =1   
  LEFT JOIN ML.ConfigurationProgress CP (NOLOCK) ON  PM.ProjectID = CP.ProjectID AND CP.IsDeleted = 0   
  WHERE   
  ISNULL(TD.ServiceID,0) =0  
  AND TD.ServiceClassificationMode = 3  
    AND TD.CREATEDDATE = GetDate()
    
   END TRY   
  
   BEGIN CATCH   
          DECLARE @ErrorMessage1 VARCHAR(MAX);   
  
          SELECT @ErrorMessage1 = ERROR_MESSAGE()   
  
          --INSERT Error       
          EXEC AVL_INSERTERROR   
            '[AVL].[GetTicketDetailsForServiceClassification]',   
            @ErrorMessage1,   
           NULL,  
            0   
      END CATCH  
	  SET NOCOUNT OFF;
  END
