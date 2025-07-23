/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[BCS_MappedDataPopulate]
@esaprojectid bigint
AS
select a.UserId,a.ESAProjectID,b.PriorityName,a.RemedyData,a.ServiceData,a.OtherData from [BCS].[DataMapping] a left join
[AVL].[TK_MAS_Priority] b on a.AppLensDataID=b.PriorityID where a.ApplensColumnID=13  and a.ESAProjectID=@esaprojectid
and a.CreatedAt = (select distinct top(1) CreatedAt as ColumnCreatedAt from [BCS].[DataMapping]  where ESAProjectID=@esaprojectid order by CreatedAt desc)

select a.UserId,a.ESAProjectID,b.DARTStatusName,a.RemedyData,a.ServiceData,a.OtherData from [BCS].[DataMapping] a left join
[AVL].[TK_MAS_DARTTicketStatus] b on a.AppLensDataID=b.DARTStatusID where a.ApplensColumnID=5  and a.ESAProjectID=@esaprojectid
and a.CreatedAt = (select distinct top(1) CreatedAt as ColumnCreatedAt from [BCS].[DataMapping]  where ESAProjectID=@esaprojectid order by CreatedAt desc)

select a.UserId,a.ESAProjectID,b.TicketTypeName,a.RemedyData,a.ServiceData,a.OtherData from [BCS].[DataMapping] a left join
[AVL].[TK_MAS_TicketType] b on a.AppLensDataID=b.TicketTypeID where a.ApplensColumnID=4 and a.ESAProjectID=@esaprojectid
and a.CreatedAt = (select distinct top(1) CreatedAt as ColumnCreatedAt from [BCS].[DataMapping]  where ESAProjectID=@esaprojectid order by CreatedAt desc)