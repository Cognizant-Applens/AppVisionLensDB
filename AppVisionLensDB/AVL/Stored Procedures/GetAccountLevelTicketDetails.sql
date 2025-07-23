/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetAccountLevelTicketDetails]
(
@EsaAccountID VARCHAR(MAX) = NULL,
@UserId VARCHAR(20),
@PageNumber INT
)
AS
BEGIN  
BEGIN TRY   

SET NOCOUNT ON; 

   DECLARE @AccountID BIGINT =0  
   DECLARE @RowsOfPage AS INT
   SET @RowsOfPage=5000
  
      SELECT DISTINCT VP.ESA_AccountID,PM.ProjectID,PM.EsaProjectID AS EsaProjId,VP.CustomerID,TD.TicketID,TD.ApplicationID,AD.ApplicationName,
      TD.EffortTillDate,TD.OpenDateTime,TD.Closeddate,DS.DARTStatusID,DS.DARTStatusName,TD.ServiceID, TT.TicketTypeID,tt.TicketTypeName,
      EA.SupportWindowID,SW.SupportWindowName,SC.SupportCategoryID,SC.SupportCategoryName,BC.BusinessCriticalityID,BC.BusinessCriticalityName,CC.CauseID,
      CC.CauseCode,RC.ResolutionID,Rc.ResolutionCode, CL.ClusterID AS 'CauseClusterID',CL.ClusterName AS 'CauseClusterName',
      CL.IsPerformanceIssue AS 'CauseIssueCategory',CLL.ClusterID AS 'ResolutionClusterID',CLL.ClusterName AS 'ResolutionClusterName',
      CLL.IsPerformanceIssue AS 'ResolutionIssueCategory',mc.CategoryID AS 'CauseCategoryID',MC.CategoryName AS 'CauseCategoryName',  
      MCC.CategoryID AS 'ResolutionCategoryID',MCC.CategoryName AS 'ResolutionCategoryName'  
      FROM AVL.TK_TRN_TicketDetail(NOLOCK) AS TD  
              INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AS AD ON TD.ApplicationID=AD.ApplicationID  
              INNER JOIN AVL.APP_MAS_BusinessCriticality(NOLOCK) AS BC ON AD.BusinessCriticalityID=BC.BusinessCriticalityID  
              INNER JOIN AVL.TK_MAS_DARTTicketStatus(NOLOCK) AS DS ON TD.DARTStatusID=DS.DARTStatusID              
              INNER JOIN AVL.TK_MAP_TicketTypeMapping(NOLOCK) AS TM ON TD.TicketTypeMapID=TM.TicketTypeMappingID  
              INNER JOIN AVL.TK_MAS_TicketType(NOLOCK) AS TT ON TM.AVMTicketType=TT.TicketTypeID  
              LEFT JOIN  AVL.DEBT_MAP_CauseCode(NOLOCK) AS CC ON TD.causecodemapid=CC.CauseID  
              LEFT JOIN  AVL.DEBT_MAP_ResolutionCode(NOLOCK) AS Rc ON TD.ResolutionCodeMapID=rc.ResolutionID  
              INNER JOIN AVL.APP_MAS_Extended_ApplicationDetail(NOLOCK) EA ON AD.ApplicationID=EA.ApplicationID  
              LEFT JOIN  AVL.APP_MAS_SupportWindow(NOLOCK) SW ON EA.SupportWindowID=SW.SupportWindowID  
              LEFT JOIN  AVL.APP_MAS_SupportCategory(NOLOCK) SC ON EA.SupportCategoryID=SC.SupportCategoryID  
              INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) AS PM ON PM.ProjectID=TD.ProjectID  
              INNER JOIN AVL.Customer(NOLOCK) AS VP ON VP.customerid=PM.customerid  
              LEFT JOIN  MAS.Cluster(NOLOCK) AS CL ON CC.CauseStatusID=CL.ClusterID  
              LEFT JOIN  MAS.Cluster(NOLOCK) AS CLL ON RC.ResolutionStatusID=CLL.ClusterID  
              LEFT JOIN  MAS.ClusterCategory(NOLOCK) AS MC ON CL.CategoryID=MC.CategoryID  
              LEFT JOIN  MAS.ClusterCategory(NOLOCK) AS MCC ON CLL.CategoryID=MCC.CategoryID  
      WHERE VP.ESA_AccountID = @EsaAccountID AND VP.IsDeleted=0 AND TD.IsDeleted=0 AND AD.IsActive=1 AND BC.IsDeleted=0 AND DS.IsDeleted=0 
      AND TM.IsDeleted=0 AND TT.IsDeleted=0  AND PM.IsDeleted=0 AND TD.OpenDateTime> DATEADD(year,-1,GETDATE())   
      AND DS.DARTStatusID NOT IN (5,7) AND TT.supporttypeid=3  ORDER BY TD.ApplicationID
        OFFSET (@PageNumber-1)*@RowsOfPage ROWS
        FETCH NEXT @RowsOfPage ROWS ONLY
        SET @PageNumber = @PageNumber + 1
  
  
END TRY    
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[GetAccountLevelTicketDetails]',@ErrorMessage,@UserId,0  
    
 END CATCH  
 SET NOCOUNT OFF;
END
