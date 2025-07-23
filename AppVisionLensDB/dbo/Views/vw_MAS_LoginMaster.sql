/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW [dbo].[vw_MAS_LoginMaster]
AS
SELECT [UserID]
      ,[EmployeeID]
      ,[ClientUserID]
      ,[EmployeeName]
      ,[EmployeeEmail]
      ,[ProjectID]
      ,[CustomerID]
      ,[HcmSupervisorID]
      ,[TSApproverID]
      ,[ManagerID]
      ,[Remarks]
      ,[EffectiveDate]
      ,[TimeZoneId]
      ,[MandatoryHours]
      ,[EffectiveEndDate]
      ,[Billability_type]
      ,[LocationID]
      ,[IsDeleted]
      ,[RoleID]
      ,[IsAutoassignedTicket]
      ,[ServiceLevelID]
      ,[CreatedDate]
      ,[CreatedBy]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[TicketingModuleEnabled]
      ,[IsDefaultProject]
      ,[IsEffortTrackingEnabled]
      ,[Offshore_Onsite]
      ,[IsNonESAAuthorized]
      ,[IsMiniConfigured]
  FROM [AVL].[MAS_LoginMaster]
