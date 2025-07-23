/***************************************************************************      
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET      
*Copyright [2018] – [2021] Cognizant. All rights reserved.      
*NOTICE: This unpublished material is proprietary to Cognizant and      
*its suppliers, if any. The methods, techniques and technical      
  concepts herein are considered Cognizant confidential and/or trade secret information.       
        
*This material may be covered by U.S. and/or foreign patents or patent applications.       
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.      
***************************************************************************/      
      
-- =========================================================================================      
-- Author      :       
-- Create date : 01/07/2020      
-- Description : Procedure to Push OPL Data from OPLSheet to OPL Master Table      
-- Revision    :      
-- Revised By  :      
-- =========================================================================================       
      
CREATE PROCEDURE [PP].[OplDataPush](      
@TvpOplDataList AS PP.TVP_OplDataDetails READONLY      
)      
AS      
BEGIN      
SET NOCOUNT ON;      
BEGIN TRY      
BEGIN TRAN      
DECLARE @ExecutionMethod INT = 3      
DECLARE @Billability INT = 7      
DECLARE @ADM INT = 85      
      
         
  CREATE TABLE #OplEsaData        
  (          
   ID BIGINT  IDENTITY(1,1) NOT NULL PRIMARY KEY,        
   ProjectID BIGINT NOT NULL,        
   ProjectScope NVARCHAR(3000) NULL,        
   ProjectScopeID INT,        
   ServiceLinesInvolved NVARCHAR(3000) NULL,        
   ExecutionMethod NVARCHAR(3000) NULL ,        
   ExecutionMethodID INT,        
   Billability  NVARCHAR(3000) NULL ,        
   BillabilityID INT,        
   ProjectCategory NVARCHAR(3000) NULL,        
   DeliveryEngagementModel NVARCHAR(3000) NULL,        
   ContractYear NVARCHAR(3000) NULL,        
   EndDate  DATETIME NULL,        
   [Total_FTE]  NVARCHAR(100) NULL,        
   [FTE_Onsite]  NVARCHAR(100) NULL,        
   [FTE_Offshore]  NVARCHAR(100) NULL,        
   FTE DECIMAL(10,2) NULL,        
   Onsite DECIMAL(10,2) NULL,        
   Offshore DECIMAL(10,2) NULL,        
   Vertical NVARCHAR(3000) NULL,        
   OwningBU  NVARCHAR(3000) NULL,        
   SkillDetails NVARCHAR(3000) NULL,        
   Projectowningunit NVARCHAR(3000) NULL,        
   HorizontalID BIGINT NULL,        
   SubVertical NVARCHAR(3000) NULL,        
   Parentaccount  NVARCHAR(3000) NULL,        
   Technology NVARCHAR(4000) NULL,        
   [IsDeleted] BIT NOT NULL,        
   [CreatedBy] NVARCHAR (50) NOT NULL,        
   [CreatedDate] DATETIME NOT NULL,        
   [ModifiedBy] NVARCHAR (50) NULL,        
   [ModifiedDate] DATETIME NULL ,       
   [Market Unit] NVARCHAR(3000) NULL,        
   [BU] NVARCHAR(3000) NULL      
  )        
  INSERT INTO #OplEsaData        
  ([ProjectID],[ProjectScope],[ProjectScopeID],[ServiceLinesInvolved],[ExecutionMethod],[ExecutionMethodID],        
   [Billability],[BillabilityID],[ProjectCategory],[DeliveryEngagementModel],[ContractYear],[EndDate],[FTE],        
   [Onsite],[Offshore],[Total_FTE],[FTE_Onsite],[FTE_Offshore],[Vertical],[OwningBU],[SkillDetails],[Projectowningunit] ,[HorizontalID],[SubVertical],        
   [Parentaccount],[Technology],[IsDeleted],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate],[Market Unit],[BU])        
        
  SELECT PM.ProjectID,ODL.[Process_Service_Line] AS ProjectScope,NULL AS ProjectScopeID,ODL.[Service_Type] AS ServiceLinesInvolved,ODL.Methodologies,NULL AS ExecutionMethodID,        
      ODL.Billability,NULL AS BillabilityID,ODL.[ESA_Project_category] AS ProjectCategory,ODL.[Delivery_Eng_Model] AS DeliveryEngagementModel,NULL,ODL.[Project_End_Date] AS EndDate,      
   ODL.[Total_FTE], ODL.[FTE_Onsite] AS Onsite,ODL.[FTE_Offshore] AS Offshore,0,0,0,NULL,NULL,NULL,ODL.[Project_Owning_Unit] AS Projectowningunit,NULL,ODL.[Sub_Vertical] AS SubVertical,        
      ODL.[Parent_account] AS Parentaccount,ODL.[Technology],0,'Opl Job',GETDATE(),NULL,NULL ,ODL.[Market_Unit],ODL.[BU]      
  FROM @TvpOplDataList ODL        
  JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.EsaProjectID=ODL.[ESA_Project_ID]        
  WHERE PM.IsDeleted = 0        
      
        
  UPDATE OT SET ExecutionMethodID = AV.AttributeValueID        
  FROM #OplEsaData OT        
  JOIN MAS.PPAttributeValues AV on AV.AttributeValueName = OT.ExecutionMethod         
  JOIN MAS.PPAttributes A on A.AttributeID = AV.AttributeID        
  WHERE A.AttributeID = @ExecutionMethod        
        
  UPDATE OT SET BillabilityID = AV.AttributeValueID        
  FROM #OplEsaData OT        
  JOIN MAS.PPAttributeValues AV ON AV.AttributeValueName = OT.Billability         
  JOIN MAS.PPAttributes A ON A.AttributeID = AV.AttributeID        
  WHERE A.AttributeID = @Billability        
        
  UPDATE #OplEsaData SET         
  ProjectScopeID = (CASE WHEN ProjectScope = 'AD' THEN 1  WHEN ProjectScope = 'AVM'         
        THEN 2 WHEN ProjectScope = 'CIS' THEN 3 WHEN ProjectScope = 'Testing' THEN 4 ELSE NULL END)        
        
  UPDATE #OplEsaData SET DeliveryEngagementModel = NULL WHERE DeliveryEngagementModel = '-'        
        
  UPDATE #OplEsaData SET HorizontalID = @ADM  WHERE projectowningunit = 'ADM'        
        
  UPDATE #OplEsaData         
  SET [Total_FTE] = FTE         
  WHERE ISNUMERIC(FTE)=1         
        
  UPDATE  #OplEsaData         
  SET [FTE_Onsite] = Onsite        
  WHERE ISNUMERIC(Onsite)=1        
        
  UPDATE  #OplEsaData         
  SET [FTE_Offshore] = Offshore         
  WHERE ISNUMERIC(Offshore)=1         
      
      
 TRUNCATE TABLE [dbo].[OPLMasterdata]

 INSERT INTO [dbo].[OPLMasterdata]        
 ([ESA_Project_ID],[Merge_Status],[ESA_Project_Name],[Mainspring_Project_ID],[Execution_Project_Name],[Main_Sub_Project_Flag],[Project_Start_Date],[Project_End_Date],      
[Project_Ported_Date],[Is_mainspring_Ported],[ESA_PM_ID],[ESA_PM_name],[Project Owner Id],[Project Owner Name],[Project Owner Location],[Project Owner / ESA PM department],      
[Service_line_(LOS)],[Project_Owning_Unit],[Other_Practice_Involved],[No_Practice_Involved],[Client_ID],[Client_Name],[Parent_Account ID],[Parent_Account],[Account_Segmentation],      
[Vertical],[Sub_Vertical],[Primary Market],[Primary Market unit],[Primary BU],[Market],[Market_Unit],[BU],[SBU1],[SBU2],[ESA_Project_Location],[ESA_Project_City],[ESA_Project_Country],      
[PL_ID],[PL_Name],[Project_Type_Conversion_Date],[ESA_Project_Type],[Billability],[ESA_Project_category],[FTE_Offshore],[FTE_Onsite],[Total_FTE],[Technology],[AD_Qualifier],      
[Delivery_Eng_Model],[Rhythm],[Solution_Area],[Sub_Solution_Area],[Solution_type],[Methodologies],[OrgProcessPackageName],[Process_Service_Line],[Capability_Services],[Service_Type],      
[Language],[Front_End],[Back_End],[Operating_System],[Third_Party_Tools],[Internal_Tools],[Hardware],[AVMSBUFlag],[MedicalDevice],[DevOpsApplicability],[First_Audit_date_after_KickoffFRS_Excluding_startup],      
[Last PreAudit Check_FRS Date],[Last_Audit_Date],[Last_Auditor],[Last_Audit_Type],[Opportunity ID],[PursuitCategory],[Final_Scope],[Reason_For_Scope_Change],[TAT(Scoping)],      
[Final_Category],[Automation_Applicability],[Type_Of_Automation],[Automation_Details],[CDE_-_Data_Restriction],[CDE_-_Client_Tool_Used],[CDE_-_Project_Scope_Involved],      
[CDE_-_Architectural_Considerations],[CDE_-_Team_Composition_Consists_Of],[CDE_-_Methodology_Followed],[CDE_-_CustomerBuildOrDefine],[IsDeleted],[CreatedBy],      
[CreatedDate],[ModifiedBy],[ModifiedDate])        
         
  SELECT [ESA_Project_ID],[Merge_Status],[ESA_Project_Name],[Mainspring_Project_ID],[Execution_Project_Name],[Main_Sub_Project_Flag],[Project_Start_Date],[Project_End_Date],      
[Project_Ported_Date],[Is_mainspring_Ported],[ESA_PM_ID],[ESA_PM_name],[Project Owner Id],[Project Owner Name],[Project Owner Location],[Project Owner / ESA PM department],      
[Service_line_(LOS)],[Project_Owning_Unit],[Other_Practice_Involved],[No_Practice_Involved],[Client_ID],[Client_Name],[Parent_Account ID],[Parent_Account],[Account_Segmentation],      
[Vertical],[Sub_Vertical],[Primary Market],[Primary Market unit],[Primary BU],[Market],[Market_Unit],[BU],[SBU1],[SBU2],[ESA_Project_Location],[ESA_Project_City],[ESA_Project_Country],      
[PL_ID],[PL_Name],[Project_Type_Conversion_Date],[ESA_Project_Type],[Billability],[ESA_Project_category],[FTE_Offshore],[FTE_Onsite],[Total_FTE],[Technology],[AD_Qualifier],      
[Delivery_Eng_Model],[Rhythm],[Solution_Area],[Sub_Solution_Area],[Solution_type],[Methodologies],[OrgProcessPackageName],[Process_Service_Line],[Capability_Services],[Service_Type],      
[Language],[Front_End],[Back_End],[Operating_System],[Third_Party_Tools],[Internal_Tools],[Hardware],[AVMSBUFlag],[MedicalDevice],[DevOpsApplicability],[First_Audit_date_after_KickoffFRS_Excluding_startup],      
[Last PreAudit Check_FRS Date],[Last_Audit_Date],[Last_Auditor],[Last_Audit_Type],[Opportunity ID],[PursuitCategory],[Final_Scope],[Reason_For_Scope_Change],[TAT(Scoping)],      
[Final_Category],[Automation_Applicability],[Type_Of_Automation],[Automation_Details],[CDE_-_Data_Restriction],[CDE_-_Client_Tool_Used],[CDE_-_Project_Scope_Involved],      
[CDE_-_Architectural_Considerations],[CDE_-_Team_Composition_Consists_Of],[CDE_-_Methodology_Followed],[CDE_-_CustomerBuildOrDefine],'0','Opl Job',GETDATE(),NULL,NULL FROM @TvpOplDataList         
        
      
UPDATE A SET  A.[FTE_Offshore]=B.Offshore       
FROM dbo.OPLMasterdata A      
JOIN AVL.MAS_ProjectMaster P ON A.ESA_Project_ID=P.EsaProjectID      
JOIN #OplEsaData B ON p.ProjectID=B.ProjectID      
      
UPDATE A SET  A.[FTE_Onsite]=B.Onsite       
FROM dbo.OPLMasterdata A      
JOIN AVL.MAS_ProjectMaster P ON A.ESA_Project_ID=P.EsaProjectID      
JOIN #OplEsaData B ON p.ProjectID=B.ProjectID      
      
UPDATE A SET  A.[Total_FTE]=B.FTE       
FROM dbo.OPLMasterdata A      
JOIN AVL.MAS_ProjectMaster P ON A.ESA_Project_ID=P.EsaProjectID      
JOIN #OplEsaData B ON p.ProjectID=B.ProjectID      
      
        
  TRUNCATE TABLE [PP].[OplEsaData]     
        
  INSERT INTO [PP].[OplEsaData] (ProjectID,ProjectScope,ServiceLinesInvolved,ExecutionMethod,Billability,ProjectCategory,        
  DeliveryEngagementModel,ContractYear,EndDate,FTE,Onsite,Offshore,Vertical,Projectowningunit,OwningBU,        
  SkillDetails,HorizontalID,SubVertical,Parentaccount,Technology,IsDeleted,        
  CreatedBy,CreatedDate,[MarketUnit],[BU])        
  SELECT  ProjectID,ProjectScopeID,LEFT(ServiceLinesInvolved,100),ExecutionMethodID,BillabilityID,LEFT(ProjectCategory,250),        
    LEFT(DeliveryEngagementModel,100),ContractYear,EndDate,[Total_FTE],[FTE_Onsite],[FTE_Offshore],LEFT(Vertical,250),        
    LEFT(Projectowningunit,250),LEFT(Projectowningunit,250),LEFT(SkillDetails,250),HorizontalID,LEFT(SubVertical,250),        
    LEFT(Parentaccount,250),LEFT(Technology,4000),IsDeleted,CreatedBy,CreatedDate ,[Market Unit],[BU]      
  FROM #OplEsaData         
        
  IF OBJECT_ID('tempdb..#OplEsaData') IS NOT NULL         
  BEGIN         
   DROP TABLE #OplEsaData         
  END        
        
COMMIT TRAN        
END TRY        
  BEGIN CATCH        
  ROLLBACK TRAN        
      DECLARE @ErrorMessage VARCHAR(MAX);        
   SELECT @ErrorMessage = ERROR_MESSAGE()        
  EXEC AVL_InsertError '[PP].[OplDataPush]', @ErrorMessage, 0 ,''        
  END CATCH        
  END 