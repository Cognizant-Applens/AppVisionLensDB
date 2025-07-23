/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
CREATE PROCEDURE [AVL].[Effort_GetUseCaseDetails_Customer]   
@ProjectID  BIGINT,  
@HealTicketID NVARCHAR(200),  
@ATicketType int  
AS   
  BEGIN   
      BEGIN TRY   
  SET NOCOUNT ON;  
  
    
  
  IF(@ATicketType=1)  
  BEGIN  
  
  SELECT DISTINCT UC.ID, AU.UseCaseSolutionMapId AS UseCaseDetailID,UC.UseCaseId,UC.UseCaseTitle,AU.HealingTicketID,AD.ApplicationName AS ApplicationName  
  ,PT.PrimaryTechnologyName AS Technology,SUPPORT.ServiceLevelName AS SupportLevel  
  ,AU.IsMappedSolution,CAT.ServiceName AS Category,UC.AutomationFeasibility,TOOL.SolutionTypeName AS ToolClassification,UC.ToolName  
  ,round(UC.OverallEffortSpent,2)AS OverallEffortSpent,H.DARTStatusID AS [Status],TD.Tag as Tags,BU.BUName AS SBUNAME,CUS.CustomerName AS ACCOUNT  
  ,UC.ReferenceID,UR.Rating INTO #UCListSepTagSystem  
   FROM AVL.UseCaseDetails UC With (NOLOCK)  
  INNER JOIN avl.DEBT_UseCaseSolutionIdentificationDetails AU (NOLOCK) ON AU.UseCaseID = UC.UseCaseId  
  INNER JOIN AVL.DEBT_TRN_HealTicketDetails H (NOLOCK) ON H.HealingTicketID = AU.HealingTicketID and H.IsDeleted=0 AND ISNULL(H.ManualNonDebt,0) = 0  
    INNER JOIN AVL.DEBT_PRJ_HealParentChild NDC (NOLOCK) ON NDC.ProjectPatternMapID = H.ProjectPatternMapID and ndc.IsDeleted=0 and ndc.MapStatus=1  
  LEFT JOIN AVL.Effort_UseCaseRatings UR (NOLOCK) ON UR.UseCaseDetailID = AU.UseCaseSolutionMapId AND UR.HealingTicketID = H.HealingTicketID  
  LEFT JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) on UC.ApplicationID=AD.ApplicationID  
     LEFT JOIN AVL.APP_MAS_PrimaryTechnology PT (NOLOCK) on UC.TechnologyID=PT.PrimaryTechnologyID   
  LEFT JOIN [AVL].[UseCaseSolutionTypeDetail] STD (NOLOCK) ON STD.UseCaseDetailId=UC.Id  
  LEFT JOIN AVL.MAS_ServiceLevel SUPPORT (NOLOCK) ON SUPPORT.ServiceLevelID=STD.SolutionTypeID  
  LEFT JOIN AVL.TK_MAS_Service CAT (NOLOCK) ON CAT.ServiceID=UC.ServiceID  
  LEFT JOIN [AVL].[UseCaseServiceLevelDetails] SLD (NOLOCK) ON SLD.UseCaseDetailId=UC.ID  
  LEFT JOIN AVL.TK_MAS_SolutionType TOOL (NOLOCK) ON TOOL.SolutionTypeID=SLD.ServiceLevelID  
  LEFT JOIN AVL.UseCaseTagDetail TD  (NOLOCK) ON TD.UseCaseDetailId=UC.Id  
  LEFT JOIN ESA.BusinessUnits BU (NOLOCK) ON UC.BUID=BU.BUID  
     LEFT JOIN AVL.Customer CUS  (NOLOCK) ON CUS.CustomerID=UC.CustomerID  
  WHERE AU.HealingTicketID = @HealTicketID AND AU.ProjectID = @ProjectID   
  
  SELECT DISTINCT U.UseCaseDetailID,U.UseCaseID,U.UseCaseTitle,Au.HealingTicketID,U.ApplicationName,U.Technology,U.BusinessProcess,  
  U.SubBusinessProcess,SupportLevel,au.IsMappedSolution,U.Category,U.AutomationFeasibility,u.ToolClassification,u.ToolName,  
  round(U.OverallEffortSpent,2)AS OverallEffortSpent,H.DARTStatusID AS [Status],U.Tags as Tags,U.SBUName,U.AccountName,U.ReferenceID,UR.Rating  
  INTO #FINALUSECASEDETAILS  
  FROM AVL.Effort_UseCaseDetails U With (NOLOCK)   
  INNER JOIN avl.DEBT_UseCaseSolutionIdentificationDetails AU (NOLOCK) ON AU.UseCaseID = U.UseCaseID  
  INNER JOIN AVL.DEBT_TRN_HealTicketDetails H (NOLOCK) ON H.HealingTicketID = AU.HealingTicketID and H.IsDeleted=0 AND ISNULL(H.ManualNonDebt,0) = 0  
  INNER JOIN AVL.DEBT_PRJ_HealParentChild NDC (NOLOCK) ON NDC.ProjectPatternMapID = H.ProjectPatternMapID and ndc.IsDeleted=0 and ndc.MapStatus=1  
  LEFT JOIN AVL.Effort_UseCaseRatings UR (NOLOCK) ON UR.UseCaseDetailID = U.UseCaseDetailID AND UR.HealingTicketID = H.HealingTicketID  
  WHERE H.HealingTicketID = @HealTicketID AND AU.ProjectID = @ProjectID   
    
  UNION ALL  
  
  SELECT DISTINCT UCST.UseCaseDetailID,UCST.UseCaseId,UCST.UseCaseTitle,UCST.HealingTicketID,UCST.ApplicationName  
  ,UCST.Technology,X.SupportType SupportLevel  
  ,UCST.IsMappedSolution,UCST.Category,UCST.AutomationFeasibility,Z.ToolsClassification ToolClassification,UCST.ToolName  
  ,round(UCST.OverallEffortSpent,2)AS OverallEffortSpent,UCST.[Status],Y.Tag as Tags,UCST.SBUNAME,UCST.ACCOUNT  
  ,UCST.ReferenceID,UCST.Rating From #UCListSepTagSystem UCST With (NOLOCK)  
  
  CROSS APPLY  
    (  
     SELECT STUFF (  
      (   
       SELECT ',' +sl.ServiceLevelName FROM AVL.UseCaseSolutionTypeDetail ST With (NOLOCK)  
       JOIN AVL.MAS_ServiceLevel sl (NOLOCK) on st.SolutionTypeID=sl.ServiceLevelID  
       WHERE ST.UseCaseDetailId=UCST.Id  
       FOR XML PATH('')   
      )  
     ,1,1,'') as SupportType  
    ) as X  
    CROSS APPLY  
    (  
     SELECT STUFF (  
      (   
       SELECT ',' +ST.Tag FROM AVL.UseCaseTagDetail ST With (NOLOCK)   
       WHERE ST.UseCaseDetailId=UCST.Id  
       FOR XML PATH('')   
      )  
     ,1,1,'') as Tag  
    ) as Y  
    CROSS APPLY  
    (  
     SELECT STUFF (  
      (   
       SELECT ',' +sl.SolutionTypeName FROM AVL.UseCaseServiceLevelDetails ST With (NOLOCK)   
       JOIN AVL.TK_MAS_SolutionType sl (NOLOCK) on st.ServiceLevelID=sl.SolutionTypeID  
       WHERE ST.UseCaseDetailId=UCST.Id  
       FOR XML PATH('')   
      )  
     ,1,1,'') as ToolsClassification  
    ) as Z  
    
  ORDER BY IsMappedSolution DESC,U.SBUName,U.AccountName,U.ApplicationName,U.Technology,U.AutomationFeasibility DESC,UR.Rating  
     DROP TABLE #UCListSepTagSystem  
  SELECT    
  UC.UseCaseDetailID,UC.UseCaseId,UC.UseCaseTitle,UC.HealingTicketID,UC.ApplicationName  
  ,UC.Technology,UC.BusinessProcess,UC.SubBusinessProcess,UC.SupportLevel  
  ,UC.IsMappedSolution,UC.Category,UC.AutomationFeasibility,UC.ToolClassification,UC.ToolName  
  ,round(UC.OverallEffortSpent,2)AS OverallEffortSpent,UC.[Status],UC.Tags,UC.SBUNAME,  
  UC.AccountName,UC.ReferenceID,UC.Rating  
  FROM #FINALUSECASEDETAILS UC With (NOLOCK)  
  ORDER BY IsMappedSolution DESC,UC.SBUName,UC.AccountName,UC.ApplicationName,UC.Technology,UC.AutomationFeasibility DESC,UC.Rating  
          
  DROP TABLE #FINALUSECASEDETAILS  
  END  
  ELSE IF(@ATicketType=2)  
  BEGIN  
  
  SELECT DISTINCT UC.ID, AU.UseCaseSolutionMapId AS UseCaseDetailID,UC.UseCaseId,UC.UseCaseTitle,AU.HealingTicketID,AD.ApplicationName AS ApplicationName  
  ,PT.PrimaryTechnologyName AS Technology,SUPPORT.ServiceLevelName AS SupportLevel  
  ,AU.IsMappedSolution,CAT.ServiceName AS Category,UC.AutomationFeasibility,TOOL.SolutionTypeName AS ToolClassification,UC.ToolName  
  ,round(UC.OverallEffortSpent,2)AS OverallEffortSpent,H.DARTStatusID AS [Status],TD.Tag as Tags,BU.BUName AS SBUNAME,CUS.CustomerName AS ACCOUNT  
  ,UC.ReferenceID,UR.Rating INTO #UCListSepTagManual  
   FROM AVL.UseCaseDetails UC With (NOLOCK)  
  INNER JOIN avl.DEBT_UseCaseSolutionIdentificationDetails AU (NOLOCK) ON AU.UseCaseID = UC.UseCaseId  
  INNER JOIN AVL.DEBT_TRN_HealTicketDetails H (NOLOCK) ON H.HealingTicketID = AU.HealingTicketID and H.IsDeleted=0 AND ISNULL(H.ManualNonDebt,0) = 1  
     INNER JOIN AVL.DEBT_PRJ_NonDebtParentChild NDC (NOLOCK) ON NDC.ProjectPatternMapID = H.ProjectPatternMapID and ndc.IsDeleted=0 and ndc.MapStatus=1  
  LEFT JOIN AVL.Effort_UseCaseRatings UR (NOLOCK) ON UR.UseCaseDetailID = AU.UseCaseSolutionMapId AND UR.HealingTicketID = H.HealingTicketID  
  LEFT JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) on UC.ApplicationID=AD.ApplicationID  
     LEFT JOIN AVL.APP_MAS_PrimaryTechnology PT (NOLOCK) on UC.TechnologyID=PT.PrimaryTechnologyID  
  LEFT JOIN [AVL].[UseCaseSolutionTypeDetail] STD (NOLOCK) ON STD.UseCaseDetailId=UC.Id  
  LEFT JOIN AVL.MAS_ServiceLevel SUPPORT (NOLOCK) ON SUPPORT.ServiceLevelID=STD.SolutionTypeID  
  LEFT JOIN AVL.TK_MAS_Service CAT (NOLOCK) ON CAT.ServiceID=UC.ServiceID  
  LEFT JOIN [AVL].[UseCaseServiceLevelDetails] SLD (NOLOCK) ON SLD.UseCaseDetailId=UC.ID  
  LEFT JOIN AVL.TK_MAS_SolutionType TOOL (NOLOCK) ON TOOL.SolutionTypeID=SLD.ServiceLevelID  
  LEFT JOIN AVL.UseCaseTagDetail TD (NOLOCK) ON TD.UseCaseDetailId=UC.Id  
  LEFT JOIN ESA.BusinessUnits BU (NOLOCK) ON UC.BUID=BU.BUID  
     LEFT JOIN AVL.Customer CUS (NOLOCK) ON CUS.CustomerID=UC.CustomerID  
  WHERE AU.HealingTicketID = @HealTicketID AND AU.ProjectID = @ProjectID   
  
  
  SELECT DISTINCT U.UseCaseDetailID,U.UseCaseID,U.UseCaseTitle,Au.HealingTicketID,U.ApplicationName,U.Technology,U.BusinessProcess,  
  U.SubBusinessProcess,SupportLevel,au.IsMappedSolution,U.Category,U.AutomationFeasibility,u.ToolClassification,u.ToolName,  
  round(U.OverallEffortSpent,2) AS OverallEffortSpent,H.DARTStatusID AS [Status],U.Tags as Tags,U.SBUName,U.AccountName,U.ReferenceID,UR.Rating  
  INTO #FINALUSECASEDETAILSManual  
  FROM AVL.Effort_UseCaseDetails U With (NOLOCK)  
  INNER JOIN avl.DEBT_UseCaseSolutionIdentificationDetails AU (NOLOCK) ON AU.UseCaseID = U.UseCaseID  
  INNER JOIN AVL.DEBT_TRN_HealTicketDetails H (NOLOCK) ON H.HealingTicketID = AU.HealingTicketID AND ISNULL(H.ManualNonDebt,0) = 1 AND H.IsDeleted=0  
  INNER JOIN AVL.DEBT_PRJ_NonDebtParentChild NDC (NOLOCK) ON NDC.ProjectPatternMapID = H.ProjectPatternMapID  
  LEFT JOIN AVL.Effort_UseCaseRatings UR (NOLOCK) ON UR.UseCaseDetailID = U.UseCaseDetailID AND UR.HealingTicketID = H.HealingTicketID  
  WHERE H.HealingTicketID = @HealTicketID AND AU.ProjectID = @ProjectID  
    
  
  UNION ALL  
  
  SELECT DISTINCT UCST.UseCaseDetailID,UCST.UseCaseId,UCST.UseCaseTitle,UCST.HealingTicketID,UCST.ApplicationName  
  ,UCST.Technology,
  x.SupportType SupportLevel  
  ,UCST.IsMappedSolution,UCST.Category,UCST.AutomationFeasibility,Z.ToolsClassification ToolClassification,UCST.ToolName  
  ,round(UCST.OverallEffortSpent,2)AS OverallEffortSpent,UCST.[Status],Y.Tag as Tags,UCST.SBUNAME,UCST.ACCOUNT  
  ,UCST.ReferenceID,UCST.Rating From #UCListSepTagManual UCST  
  CROSS APPLY  
    (  
     SELECT STUFF (  
      (   
       SELECT ',' +sl.ServiceLevelName FROM AVL.UseCaseSolutionTypeDetail ST With (NOLOCK)  
       JOIN AVL.MAS_ServiceLevel sl (NOLOCK) on st.SolutionTypeID=sl.ServiceLevelID  
       WHERE ST.UseCaseDetailId=UCST.Id  
       FOR XML PATH('')   
      )  
     ,1,1,'') as SupportType  
    ) as X  
    CROSS APPLY  
    (  
     SELECT STUFF (  
      (   
       SELECT ',' +ST.Tag FROM AVL.UseCaseTagDetail ST With (NOLOCK)  
       WHERE ST.UseCaseDetailId=UCST.Id  
       FOR XML PATH('')   
      )  
     ,1,1,'') as Tag  
    ) as Y  
    CROSS APPLY  
    (  
     SELECT STUFF (  
      (   
       SELECT ',' +sl.SolutionTypeName FROM AVL.UseCaseServiceLevelDetails ST With (NOLOCK)   
       JOIN AVL.TK_MAS_SolutionType sl (NOLOCK) on st.ServiceLevelID=sl.SolutionTypeID  
       WHERE ST.UseCaseDetailId=UCST.Id  
       FOR XML PATH('')   
      )  
     ,1,1,'') as ToolsClassification  
    ) as Z  
    
    
  ORDER BY IsMappedSolution DESC,U.SBUName,U.AccountName,U.ApplicationName,U.Technology,U.AutomationFeasibility DESC,UR.Rating  
  DROP TABLE #UCListSepTagManual  
  
  SELECT  distinct  
  UCM.UseCaseDetailID,UCM.UseCaseId,UCM.UseCaseTitle,UCM.HealingTicketID,UCM.ApplicationName  
  ,UCM.Technology,UCM.BusinessProcess,UCM.SubBusinessProcess,UCM.SupportLevel  
  ,UCM.IsMappedSolution,UCM.Category,UCM.AutomationFeasibility,UCM.ToolClassification,UCM.ToolName  
  ,round(UCM.OverallEffortSpent,2)AS OverallEffortSpent,UCM.[Status],UCM.Tags,UCM.SBUNAME,  
  UCM.AccountName,UCM.ReferenceID,UCM.Rating  
  FROM #FINALUSECASEDETAILSManual UCM With (NOLOCK)  
  ORDER BY IsMappedSolution DESC,UCM.SBUName,UCM.AccountName,UCM.ApplicationName,UCM.Technology,UCM.AutomationFeasibility DESC,UCM.Rating  
  
        DROP TABLE #FINALUSECASEDETAILSManual  
  END  
  SET NOCOUNT OFF  
      END TRY   
      BEGIN CATCH   
          DECLARE @ErrorMessage VARCHAR(MAX);   
          SELECT @ErrorMessage = ERROR_MESSAGE()     
          EXEC AVL_INSERTERROR '[AVL].[Effort_GetUseCaseDetails]',  @ErrorMessage, @ProjectID,  0   
      END CATCH   
  END
