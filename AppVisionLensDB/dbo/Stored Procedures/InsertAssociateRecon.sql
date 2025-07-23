CREATE PROCEDURE [dbo].[InsertAssociateRecon] 
AS
BEGIN
BEGIN TRY
DECLARE @Month INT
DECLARE @Year INT
SET @Month = (SELECT DATEPART(m, DATEADD(m, -1, getdate())))
SET @Year = (SELECT FORMAT (getdate(), 'yyyy'))

UPDATE [dbo].[AssociateRecognitionTemplate] SET IsDeleted = 1 
WHERE CertificationMonth  IS NOT NULL AND CertificationMonth ! = '' AND  CertificationYear  IS NOT NULL AND CertificationYear != '' AND
CONCAT(CertificationMonth,CertificationYear) NOT IN (CONCAT(@Month,@Year))
AND IsDeleted = 0

UPDATE [dbo].[AssociateRecognitionTemplate] set isdeleted =1 WHERE isdeleted =0 AND (Remarks IS NULL or Remarks = '')
AND CategoryName = 'Automation Solution' AND ( [NoOfATicketsClosed] is null or NoOfATicketsClosed = 0 )

UPDATE [dbo].[AssociateRecognitionTemplate] set isdeleted =1 WHERE isdeleted =0 AND (Remarks IS NULL or Remarks = '')
AND CategoryName = 'Application Healing Solution' AND ( [NoOfHTicketsClosed] is null or NoOfHTicketsClosed = 0 OR IncReductionMonth is null or IncReductionMonth = 0)

UPDATE [dbo].[AssociateRecognitionTemplate] set isdeleted =1 WHERE isdeleted =0 AND (Remarks IS NULL or Remarks = '')
AND (CategoryName = 'Automation Solution' OR CategoryName = 'Application Healing Solution') AND ( [EffortReductionMonth] is null or EffortReductionMonth = 0 OR SolutionIdentified is null or SolutionIdentified = 0)

UPDATE [dbo].[AssociateRecognitionTemplate] set isdeleted =1 WHERE isdeleted =0 AND (Remarks IS NULL or Remarks = '')
AND CategoryName = 'Creation of KEDB articles'  AND ( [NoOfKEDBCreatedApproved] is null or NoOfKEDBCreatedApproved = 0 )

UPDATE [dbo].[AssociateRecognitionTemplate] set isdeleted =1 WHERE isdeleted =0 AND (Remarks IS NULL or Remarks = '')
AND CategoryName = 'Contribution to code share'  AND ( [NoOfCodeAssetContributed] is null or NoOfCodeAssetContributed = 0 )

CREATE TABLE [dbo].[#tempAssociateRecognition](
	[ID] [int]  NOT NULL,
	[CategoryName] [nvarchar](50) NULL,
	[AwardName] [nvarchar](50) NULL,
	[EmployeeID] [nvarchar](50) NULL,
	[ESAProjectID] [nvarchar](50) NULL,
	[CertificationMonth] [tinyint] NULL,
	[CertificationYear] [smallint] NULL,
	[NoOfATicketsClosed] [int] NULL,
	[NoOfHTicketsClosed] [int] NULL,
	[IncReductionMonth] [int] NULL,
	[EffortReductionMonth] [int] NULL,
	[SolutionIdentified] [int] NULL,
	[NoOfKEDBCreatedApproved] [int] NULL,
	[NoOfCodeAssetContributed] [int] NULL,
	[Remarks] [nvarchar](200) NULL,
	[Isempexist] [bit] NULL,
	[IsCadMapexist] [bit] NULL,
	[CategoryId] [int] NULL,
	[AwardId] [int] NULL,
	[AccountId] [bigint] NULL,
	[ProjectID] [bigint] NULL,
	[Designation] [nvarchar](200) NULL
) 

ALTER TABLE [dbo].[#tempAssociateRecognition] ADD  DEFAULT ((0)) FOR [Isempexist]
ALTER TABLE [dbo].[#tempAssociateRecognition] ADD  DEFAULT ((0)) FOR [IsCadMapexist]

INSERT INTO [dbo].[#tempAssociateRecognition]
(   [ID],
	[CategoryName],
	[AwardName], 
	[EmployeeID],
	[ESAProjectID], 
	[CertificationMonth],
	[CertificationYear], 
	[NoOfATicketsClosed],
	[NoOfHTicketsClosed],
	[IncReductionMonth] ,
	[EffortReductionMonth], 
	[SolutionIdentified], 
	[NoOfKEDBCreatedApproved], 
	[NoOfCodeAssetContributed])

SELECT 
    [AssociateRecogID],
	[CategoryName],
	[AwardName], 
	[EmployeeID],
	[ESAProjectID], 
	[CertificationMonth],
	[CertificationYear], 
	[NoOfATicketsClosed],
	[NoOfHTicketsClosed],
	[IncReductionMonth] ,
	[EffortReductionMonth], 
	[SolutionIdentified], 
	[NoOfKEDBCreatedApproved], 
	[NoOfCodeAssetContributed]
	FROM [dbo].[AssociateRecognitionTemplate] WHERE isdeleted =0 AND (Remarks IS NULL or Remarks = '')

	DECLARE @CategoryAttributeID INT = 0, @AwardAttributeID INT = 0
SET @CategoryAttributeID = (SELECT TOP 1 AttributeID FROM [MAS].[PPAttributes] WHERE IsDeleted = 0 AND AttributeName = 'Category')
SET @AwardAttributeID = (SELECT TOP 1 AttributeID FROM [MAS].[PPAttributes] WHERE IsDeleted = 0 AND AttributeName = 'AwardName')

UPDATE ART SET ART.CategoryId = PPAV.AttributeValueID
FROM [dbo].[#tempAssociateRecognition] ART
INNER JOIN [MAS].[PPAttributeValues] PPAV ON LTRIM(RTRIM(ART.CategoryName)) = LTRIM(RTRIM(PPAV.AttributeValueName))
INNER JOIN [MAS].[PPAttributes] PPA ON PPA.AttributeID = PPAV.AttributeID
WHERE PPA.AttributeID = @CategoryAttributeID AND PPA.IsDeleted = 0 AND PPAV.IsDeleted = 0 --AND ART.IsDeleted = 0

UPDATE ART SET ART.AwardId = PPAV.AttributeValueID
FROM [dbo].[#tempAssociateRecognition] ART
INNER JOIN [MAS].[PPAttributeValues] PPAV ON  LTRIM(RTRIM(ART.AwardName)) = LTRIM(RTRIM(PPAV.AttributeValueName))
INNER JOIN [MAS].[PPAttributes] PPA ON PPA.AttributeID = PPAV.AttributeID
WHERE PPA.AttributeID = @AwardAttributeID AND PPA.IsDeleted = 0 AND PPAV.IsDeleted = 0 --AND ART.IsDeleted = 0

UPDATE ART SET ART.IsCadMapexist = 1
FROM [dbo].[#tempAssociateRecognition] ART
INNER JOIN [MAS].[PPAttributeValues] CAM ON CAM.AttributeValueID=ART.CategoryId AND CAM.ParentID = ART.AwardId
WHERE  CAM.IsDeleted = 0 --AND ART.IsDeleted = 0

UPDATE [dbo].[#tempAssociateRecognition] SET Remarks =  COALESCE(Remarks,'') + 'Category & Award is not mapped correctly;' 
WHERE (CategoryId IS NOT NULL AND CategoryId != '') AND (AwardId IS NOT NULL AND AwardId != '') AND IsCadMapexist = 0 --AND IsDeleted = 0

UPDATE ART SET ART.AccountId = PM.CustomerID,ART.ProjectID = PM.ProjectID
FROM [dbo].[#tempAssociateRecognition] ART
INNER JOIN AVL.MAS_ProjectMaster PM ON LTRIM(RTRIM(ART.ESAProjectID)) = LTRIM(RTRIM(PM.EsaProjectID))
WHERE PM.IsDeleted = 0 --AND ART.IsDeleted = 0 --AND ART.IsDeleted = 0

UPDATE ART SET ART.Isempexist = 1, ART.Designation = EA.Designation
FROM [dbo].[#tempAssociateRecognition] ART
INNER JOIN [AVL].[MAS_LoginMaster] LM ON LTRIM(RTRIM(ART.EmployeeID)) = LTRIM(RTRIM(LM.EmployeeID))
INNER JOIN ESA.Associates EA ON EA.AssociateID = LM.EmployeeID
WHERE LM.IsDeleted = 0 AND EA.IsActive = 1 --AND ART.IsDeleted = 0 

UPDATE [dbo].[#tempAssociateRecognition] SET Remarks =  COALESCE(Remarks,'') + 'Category Name is null or empty;'
WHERE (CategoryName IS NULL OR CategoryName = '') --AND  IsDeleted = 0
 
UPDATE [dbo].[#tempAssociateRecognition] SET Remarks =  COALESCE(Remarks,'') + 'Award Name is null or empty;'
WHERE (AwardName IS NULL OR AwardName = '') --AND IsDeleted = 0
 
UPDATE [dbo].[#tempAssociateRecognition] SET Remarks =  COALESCE(Remarks,'') + 'ESAProjectID is null or empty;' 
WHERE (ESAProjectID IS NULL OR ESAProjectID ='') --AND IsDeleted = 0

UPDATE [dbo].[#tempAssociateRecognition] SET Remarks =  COALESCE(Remarks,'') + 'EmployeeID is null or empty;' 
WHERE (EmployeeID IS NULL OR EmployeeID ='') --AND IsDeleted = 0

UPDATE [dbo].[#tempAssociateRecognition] SET Remarks =  COALESCE(Remarks,'') + 'Category Name does not exist;' 
WHERE CategoryName IS NOT NULL AND CategoryName != '' AND
(CategoryId IS NULL OR CategoryId = '')  --AND IsDeleted = 0

UPDATE [dbo].[#tempAssociateRecognition] SET Remarks =  COALESCE(Remarks,'') + 'Award Name does not exist;' 
WHERE AwardName IS NOT NULL AND AwardName != '' AND 
(AwardId IS NULL OR AwardId = '') --AND IsDeleted = 0

UPDATE [dbo].[#tempAssociateRecognition] SET Remarks =  COALESCE(Remarks,'') + 'ESAProjectId does not exist;' 
WHERE ESAProjectID  IS NOT NULL AND ESAProjectID ! = ''  AND
(ProjectID  IS NULL OR ProjectID = '' OR AccountID  IS NULL OR AccountID = '') --AND IsDeleted = 0

UPDATE [dbo].[#tempAssociateRecognition] SET Remarks =  COALESCE(Remarks,'') + 'EmployeeId does not exist;' 
WHERE EmployeeID  IS NOT NULL AND EmployeeID ! = '' AND  Isempexist = 0 --AND IsDeleted = 0

UPDATE [dbo].[#tempAssociateRecognition] SET Remarks =  COALESCE(Remarks,'') + 'Month is null or empty;' 
WHERE (CertificationMonth  IS NULL OR CertificationMonth = '') --AND IsDeleted = 0

UPDATE [dbo].[#tempAssociateRecognition] SET Remarks =  COALESCE(Remarks,'') + 'Year is null or empty;'  
WHERE (CertificationYear  IS NULL OR CertificationYear = '') --AND IsDeleted = 0

Insert into AC.TRN_Associate_Lens_Certification(      
									   CategoryId,      
									   AwardId,      
									   EmployeeId,      
									   AccountId,      
									   EsaProjectId,      
									   ProjectID,      
									   Designation,      
									   CertificationMonth,      
									   CertificationYear,      
									   NoOfATicketsClosed,      
									   NoOfHTicketsClosed,      
									   IncReductionMonth,      
									   EffortReductionMonth,      
									   SolutionIdentified,      
									   NoOfKEDBCreatedApproved,      
									   NoOfCodeAssetContributed,      
									   Isdeleted,
									   CreatedDate,
									   CreatedBy    
									  )   
									  
		SELECT   
			[CategoryId]
			,[AwardId]
			,[EmployeeID]
			,[AccountId]
			,[ESAProjectID]
			,[ProjectID]
			,[Designation]
			,[CertificationMonth]
			,[CertificationYear]
			,[NoOfATicketsClosed]
			,[NoOfHTicketsClosed]
			,[IncReductionMonth]
			,[EffortReductionMonth]
			,[SolutionIdentified]
			,[NoOfKEDBCreatedApproved]
			,[NoOfCodeAssetContributed]
			,0,Getdate(),'System' FROM (
		SELECT 
			 [CategoryId]
			,[AwardId]
			,[EmployeeID]
			,[AccountId]
			,[ESAProjectID]
			,[ProjectID]
			,[Designation]
			,[CertificationMonth]
			,[CertificationYear]
			,[NoOfATicketsClosed]
			,[NoOfHTicketsClosed]
			,[IncReductionMonth]
			,[EffortReductionMonth]
			,[SolutionIdentified]
			,[NoOfKEDBCreatedApproved]
			,[NoOfCodeAssetContributed]
			,ROW_NUMBER() OVER (PARTITION BY CategoryId,AwardId,AccountId,ProjectID,ESAProjectID,CertificationMonth,CertificationYear,EmployeeID
			ORDER BY ID)
			AS row_num

					FROM [dbo].[#tempAssociateRecognition] ART WHERE  CategoryId > 0 AND AwardId > 0
					AND AccountId > 0 AND ProjectID > 0 AND (ESAProjectID IS NOT NULL AND ESAProjectID != '')
					AND Isempexist = 1 AND IsCadMapexist = 1 AND CertificationMonth > 0 AND CertificationYear > 0) AS ART WHERE row_num=1
					AND NOT EXISTS
  (SELECT *
   FROM   AC.TRN_Associate_Lens_Certification ALC
   WHERE  ALC.CategoryId = ART.CategoryId AND ALC.AwardId = ART.AwardId 
   AND ALC.AccountId = ART.AccountId
   AND ALC.ProjectID = ART.ProjectID
   AND ALC.ESAProjectID = ART.ESAProjectID
   AND ALC.EmployeeID = ART.EmployeeID
   AND ALC.CertificationMonth = ART.CertificationMonth
   AND ALC.CertificationYear = ART.CertificationYear )

UPDATE ART SET ART.Remarks = TAR.Remarks FROM [dbo].[AssociateRecognitionTemplate] ART INNER JOIN [dbo].[#tempAssociateRecognition]
TAR ON TAR.ID = ART.AssociateRecogID
 
DELETE FROM [dbo].[AssociateRecognitionTemplate]  
WHERE (Remarks IS NULL or Remarks = '') AND IsDeleted = 0								   

DROP TABLE #tempAssociateRecognition								   
 
END TRY  
	BEGIN CATCH  
  --ROLLBACK TRANSACTION;  
  DECLARE @ErrorMessage VARCHAR(4000);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error        
  EXEC AVL_InsertError '[dbo].[InsertAssociateRecon]'  
   ,@ErrorMessage  
   ,0  
	END CATCH 
 
  END
