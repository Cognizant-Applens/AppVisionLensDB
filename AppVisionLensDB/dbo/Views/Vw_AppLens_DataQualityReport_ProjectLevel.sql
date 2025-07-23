  
Create VIEW [dbo].[Vw_AppLens_DataQualityReport_ProjectLevel]  
AS  
SELECT ESA_Project_ID As ESAProjectID,  
Month  as ReportingMonth,
Status AS ApplensOnboardingStatus,  
Total_MPS_Effort_From_Applens as TotalMPSEffortFromApplens
FROM [dbo].[DataQualityReports] WITH (NOLOCK)  

