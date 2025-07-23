/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE View [dbo].[VW_Applens_Accountlevel_TicketDetailsWithService]
AS


select distinct TD.TicketID,TMD.TimeTickerID,TD.CreatedBy,TD.CreatedDate,TD.ModifiedDate,TT.TicketTypeName,TD.EffortTillDate, TMD.Hours ,
				TD.OpenDateTime,TD.Closeddate,TD.DARTStatusID,DS.DARTStatusName,TMD.ServiceID,MS.ServiceName,TMD.ActivityID,SAM.ActivityName,
				AD.ApplicationId,AD.ApplicationName,VP.CustomerId,VP.ESA_AccountID
                from avl.TK_TRN_TicketDetail(NOLOCK) as TD             
              inner join avl.APP_MAS_ApplicationDetails(NOLOCK) as AD on TD.ApplicationID=AD.ApplicationID
              inner join avl.TM_TRN_TimesheetDetail(NOLOCK) as TMD on TD.TimeTickerID=TMD.TimeTickerID
              inner join avl.TK_MAS_DARTTicketStatus(NOLOCK) as DS on TD.DARTStatusID=DS.DARTStatusID
              inner join avl.TK_MAS_Service(NOLOCK) as MS on TMD.ServiceID=MS.ServiceID
              inner join avl.TK_MAS_ServiceActivityMapping(NOLOCK) as SAM on TMD.ActivityId=SAM.ActivityID
              inner join avl.TK_MAP_TicketTypeMapping(NOLOCK) as TM on TD.TicketTypeMapID=TM.TicketTypeMappingID
              inner join avl.TK_MAS_TicketType(NOLOCK) as TT on TM.AVMTicketType=TT.TicketTypeID             
              inner join avl.MAS_ProjectMaster(NOLOCK) as PM on PM.ProjectID=TD.ProjectID
              inner join avl.Customer(NOLOCK) as VP on VP.customerid=PM.customerid
              where /*TD.TicketID='BTIR00240993' and*/ TD.IsDeleted=0 and TMD.IsDeleted=0 and DS.IsDeleted=0 and TM.IsDeleted=0 and TT.IsDeleted=0
