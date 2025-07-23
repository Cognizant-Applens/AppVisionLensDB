

/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW [dbo].[vw_GMSPMO_Associate]
AS
SELECT GA.[Associate_ID]
      ,[Associate_Name]
      ,[Project_ID]
      ,[Assignment_Id]
      ,[AccountID]
      ,[Allocation_Percentage]
      ,[Assignment_Status]
      ,[Dept_Name]
      ,[Designation]
      ,[Project_Manager_ID]
      ,[PM_Name]
      ,[Pool_ID]
      ,[Pool_Description]
      ,[Horizontal]
      ,[Grade]
      ,[Supervisor_ID]
      ,[Supervisor_Name]
      ,[Associate_Billability_Type]
      ,[Assignment_Location]
      ,[City]
      ,[Country]
      ,[State]
      ,[Offshore_Onsite]
      ,[IsVerticalHorizontal]
      ,[LocationDescription]
      ,[AssignmentStartDate]
      ,[AssignmentEndDate]      
      ,[FinDept_Id]
      ,[EMail_ID]
      ,[AssociateFirstName]
      ,[AssociateLastName]
      ,[Jobcode]
      ,[Business_Unit]
      ,[HR_Status]
	  ,CAG.GradeDescription 
	  ,CAG.JobCodeDescription 
	  ,CAG.Job_Family
	  ,CAG.JobfamilyDescription AS JobFamilyDescription
  FROM [$(AVMCOEESADB)].[dbo].[GMSPMO_Associate] GA
  JOIN [$(AVMCOEESADB)].[dbo].[vw_CentralRepository_Associate_GradeDetails]  CAG
	ON GA.Associate_ID = CAG.Associate_ID
