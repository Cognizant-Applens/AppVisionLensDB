/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE   PROCEDURE [dbo].[GetCentralRepository_RHMS_CustomerGroup]
AS

TRUNCATE TABLE [dbo].[vw_CentralRepository_RHMS_Customer_Group] 
INSERT INTO [dbo].[vw_CentralRepository_RHMS_Customer_Group] 
([GlobalMarketId]
      ,[GlobalMarketName]
      ,[ActiveFlag]
      ,[LastUpdatedDateTime])
      --,[RowLastUpdatedDateTime])
 SELECT [GlobalMarketId]
      ,[GlobalMarketName]
      ,[ActiveFlag]
      ,[LastUpdatedDateTime]
      --,[RowLastUpdatedDateTime]
  FROM [$(AVMCOEESADB)].[dbo].[vw_CentralRepository_RHMS_Customer_Group] as rm WITH (NOLOCK)
