/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE View [dbo].[VW_Applens_AccountLevel_TicketDetails]
AS
select distinct VP.ESA_AccountID,vp.CustomerID,TD.TicketID,TD.ApplicationID,AD.ApplicationName,td.EffortTillDate,td.OpenDateTime,td.Closeddate,
	   TD.CreatedDate,TD.ModifiedDate,DS.DARTStatusID,DS.DARTStatusName, TD.ServiceID, TT.TicketTypeID,tt.TicketTypeName,
	   EA.SupportWindowID,SW.SupportWindowName,SC.SupportCategoryID,SC.SupportCategoryName,EA.CreatedDate as 'EA_CreatedDate',
	   EA.ModifiedDate as 'EA_ModifiedDate',BC.BusinessCriticalityID,BC.BusinessCriticalityName,cc.CauseID,cc.CauseCode,
       RC.ResolutionID,Rc.ResolutionCode, cl.ClusterID as 'CauseClusterID',cl.ClusterName as 'CauseClusterName',cll.ClusterID as 'ResolutionClusterID',
       cll.ClusterName as 'ResolutionClusterName',mc.CategoryID as 'CauseCategoryID',mc.CategoryName as 'CauseCategoryName',
       mcc.CategoryID as 'ResolutionCategoryID',mcc.CategoryName as 'ResolutionCategoryName'
        from avl.TK_TRN_TicketDetail(NOLOCK) as TD
              inner join avl.APP_MAS_ApplicationDetails(NOLOCK) as AD on TD.ApplicationID=AD.ApplicationID
              inner join avl.APP_MAS_BusinessCriticality(NOLOCK) as BC on AD.BusinessCriticalityID=BC.BusinessCriticalityID
              inner join avl.TK_MAS_DARTTicketStatus(NOLOCK) as DS on TD.DARTStatusID=DS.DARTStatusID            
              inner join avl.TK_MAP_TicketTypeMapping(NOLOCK) as TM on TD.TicketTypeMapID=TM.TicketTypeMappingID
              inner join avl.TK_MAS_TicketType(NOLOCK) as TT on TM.AVMTicketType=TT.TicketTypeID
              left join avl.DEBT_MAP_CauseCode(NOLOCK) as cc on td.causecodemapid=cc.CauseID
              left join AVL.DEBT_MAP_ResolutionCode(NOLOCK) as Rc on td.ResolutionCodeMapID=rc.ResolutionID
              inner join AVL.APP_MAS_Extended_ApplicationDetail(NOLOCK) EA ON AD.ApplicationID=EA.ApplicationID
			  left join avl.APP_MAS_SupportWindow(NOLOCK) SW on EA.SupportWindowID=SW.SupportWindowID
              left join AVL.APP_MAS_SupportCategory(NOLOCK) SC ON EA.SupportCategoryID=SC.SupportCategoryID
              inner join avl.MAS_ProjectMaster(NOLOCK) as PM on PM.ProjectID=TD.ProjectID
              inner join avl.Customer(NOLOCK) as VP on VP.customerid=PM.customerid
              left join mas.Cluster(NOLOCK) as CL on CC.CauseStatusID=CL.ClusterID
              left join mas.Cluster(nolock) as CLL on RC.ResolutionStatusID=CLL.ClusterID
              left join mas.ClusterCategory(Nolock) as MC on CL.CategoryID=MC.CategoryID
			 left join mas.ClusterCategory(nolock) as MCC on cll.CategoryID=MCC.CategoryID
              where VP.IsDeleted=0 
			   and TD.IsDeleted=0 and AD.IsActive=1 and Bc.IsDeleted=0 and DS.IsDeleted=0 and
              TM.IsDeleted=0 and TT.IsDeleted=0  and PM.IsDeleted=0
