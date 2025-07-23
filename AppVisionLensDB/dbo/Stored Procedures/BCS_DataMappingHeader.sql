/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[BCS_DataMappingHeader]
@EmployeID int,
@esaprojectid bigint
AS
  select b.ApplensColumnID,b.ApplensColumns,[RemedyColumn]
      ,[ServiceNowColumn]
      ,[OtherITSMColumn],a.CreatedAt FROM [BCS].[ColumnMapping] a
         join BCS.TicketTemplateApplensColumns b on a.ApplensColumnID = b.ApplensColumnID 
         where UserId=@EmployeID and ESAProjectID=@esaprojectid and
         CreatedAt = (select distinct top(1) CreatedAt as CreatedAt from [BCS].[ColumnMapping] where UserId=@EmployeID and ESAProjectID=@esaprojectid order by CreatedAt desc);