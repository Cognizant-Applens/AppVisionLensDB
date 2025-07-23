

/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW [dbo].[vw_GMSPMO_Project]
AS
SELECT [Project_ID]
      ,[Project_Start_Date]
      ,[Project_End_Date]
      ,[Project_Small_Desc]
      ,[Project_region]
      ,[ACCOUNT_ID]
      ,[ACCOUNT_NAME]
      ,[Project_Type]
      ,[Billability_Type]
      ,[ProjectOwningDept]
      ,[SubVertical_Description]
      ,[Category]
      ,[Project_Technology]
      ,[Sbu1_Name]
      ,[Sbu2_Name]
      ,[ProjectOwningPractice]
      ,[Customer_ID]
      ,[subsolution_Area]
      --,[AVM_SBU]
      --,[AVM_SBU_Description]
      ,[Solution_Type_Code]
      ,[Sub_Solution_Type_Code]
      ,[ProjectHorizontalCode1]
      --,[Project_Manager]
      ,[Opportunity_ID]
      ,[ProjectHorizontalCode2]
      ,[ProjectHorizontalCode3]
      ,[Account_Manager_ID]
      ,[BUSINESS_UNIT]
      ,[CTS_VERTICAL]
      ,[CTS_TECHNOLOGY]
      ,[Project_Category]
      ,[Sub_Category]
      --,[Practice_Owner]
      ,[Project_Owner]
      --,[IsHorizontal]
      ,[Status]
      --,[Practice_Owner_Updated]
      ,[BusinessID]
      --,[BusinessName]
  FROM  [$(AVMCOEESADB)].[dbo].[GMSPMO_Project]
