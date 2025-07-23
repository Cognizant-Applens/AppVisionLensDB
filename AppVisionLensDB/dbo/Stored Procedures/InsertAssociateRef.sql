CREATE PROCEDURE [dbo].[InsertAssociateRef] 
AS
BEGIN
BEGIN TRY
	CREATE TABLE [dbo].[#tempAssociateReferenceTemplate](
	[ID] [int]  NOT NULL,
	[CategoryName] [nvarchar](50) NULL,
	[AwardName] [nvarchar](50)  NULL,
	[EmployeeID] [nvarchar] (50) NULL,
	[ESAProjectID] [nvarchar] (50) NULL,
	[ReferenceId] [nvarchar] (200) NULL,
	[Isempexist] [bit]  NULL,
	[IsCadMapexist] [bit]  NULL,
	[Remarks] [nvarchar] (500) NULL,
	[CategoryId] [int] NULL,
	[AwardId] [int]  NULL,
	[ProjectID] [bigint]  NULL)

ALTER TABLE [dbo].[#tempAssociateReferenceTemplate] ADD  DEFAULT ((0)) FOR [Isempexist]
ALTER TABLE [dbo].[#tempAssociateReferenceTemplate] ADD  DEFAULT ((0)) FOR [IsCadMapexist]


INSERT INTO [dbo].[#tempAssociateReferenceTemplate]
(   [ID], 
	[CategoryName],
	[AwardName],
	[EmployeeID],
	[ESAProjectID],
	[ReferenceId]
	)
SELECT [AssociateRefid], 
	[CategoryName],
	[AwardName],
	[EmployeeID],
	[ESAProjectID],
	[ReferenceId]
FROM [dbo].[AssociateReferenceTemplate] where IsDeleted =0 AND (Remarks is null or Remarks = '')

DECLARE @CategoryAttributeID INT = 0, @AwardAttributeID INT = 0
SET @CategoryAttributeID = (SELECT TOP 1 AttributeID FROM [MAS].[PPAttributes] WHERE IsDeleted = 0 AND AttributeName = 'Category')
SET @AwardAttributeID = (SELECT TOP 1 AttributeID FROM [MAS].[PPAttributes] WHERE IsDeleted = 0 AND AttributeName = 'AwardName')

UPDATE ART SET ART.CategoryId = PPAV.AttributeValueID
FROM [dbo].[#tempAssociateReferenceTemplate] ART
INNER JOIN [MAS].[PPAttributeValues] PPAV ON LTRIM(RTRIM(ART.CategoryName)) = LTRIM(RTRIM(PPAV.AttributeValueName))
INNER JOIN [MAS].[PPAttributes] PPA ON PPA.AttributeID = PPAV.AttributeID
WHERE PPA.AttributeID = @CategoryAttributeID AND PPA.IsDeleted = 0 AND PPAV.IsDeleted = 0 -- AND ART.IsDeleted = 0

UPDATE ART SET ART.AwardId = PPAV.AttributeValueID
FROM [dbo].#tempAssociateReferenceTemplate ART
INNER JOIN [MAS].[PPAttributeValues] PPAV ON  LTRIM(RTRIM(ART.AwardName)) = LTRIM(RTRIM(PPAV.AttributeValueName))
INNER JOIN [MAS].[PPAttributes] PPA ON PPA.AttributeID = PPAV.AttributeID
WHERE PPA.AttributeID = @AwardAttributeID AND PPA.IsDeleted = 0 AND PPAV.IsDeleted = 0 --AND ART.IsDeleted = 0

UPDATE ART SET ART.IsCadMapexist = 1
FROM [dbo].#tempAssociateReferenceTemplate ART
INNER JOIN [MAS].[PPAttributeValues] CAM ON CAM.AttributeValueID=ART.CategoryId AND CAM.ParentID = ART.AwardId
WHERE  CAM.IsDeleted = 0 --AND ART.IsDeleted = 0

UPDATE [dbo].#tempAssociateReferenceTemplate SET Remarks =  COALESCE(Remarks,'') + 'Category & Award is not mapped correctly;' 
WHERE (CategoryId IS NOT NULL AND CategoryId != '') AND (AwardId IS NOT NULL AND AwardId != '') AND IsCadMapexist  = 0 --AND IsDeleted = 0

UPDATE ART SET ART.Isempexist = 1
FROM [dbo].#tempAssociateReferenceTemplate ART
INNER JOIN [AVL].[MAS_LoginMaster] LM ON LTRIM(RTRIM(ART.EmployeeID)) = LTRIM(RTRIM(LM.EmployeeID))
WHERE LM.IsDeleted = 0  --AND ART.IsDeleted = 0 

UPDATE ART SET ART.ProjectID = PM.ProjectID
FROM [dbo].#tempAssociateReferenceTemplate ART
INNER JOIN AVL.MAS_ProjectMaster PM ON LTRIM(RTRIM(ART.ESAProjectID)) = LTRIM(RTRIM(PM.EsaProjectID))
WHERE PM.IsDeleted = 0 --AND ART.IsDeleted = 0 

UPDATE [dbo].#tempAssociateReferenceTemplate SET Remarks =  COALESCE(Remarks,'') + 'Category Name is null or empty;'
WHERE (CategoryName IS NULL OR CategoryName = '') --AND  IsDeleted = 0
 
UPDATE [dbo].#tempAssociateReferenceTemplate SET Remarks =  COALESCE(Remarks,'') + 'Award Name is null or empty;'
WHERE (AwardName IS NULL OR AwardName = '') --AND IsDeleted = 0

UPDATE [dbo].#tempAssociateReferenceTemplate SET Remarks =  COALESCE(Remarks,'') + 'ESAProjectID is null or empty;' 
WHERE (ESAProjectID IS NULL OR ESAProjectID ='') --AND IsDeleted = 0
 
UPDATE [dbo].#tempAssociateReferenceTemplate SET Remarks =  COALESCE(Remarks,'') + 'EmployeeID is null or empty;' 
WHERE (EmployeeID IS NULL OR EmployeeID ='') --AND IsDeleted = 0

UPDATE [dbo].#tempAssociateReferenceTemplate SET Remarks =  COALESCE(Remarks,'') + 'Category Name does not exist;' 
WHERE CategoryName IS NOT NULL AND CategoryName != '' AND
(CategoryId IS NULL OR CategoryId = '')  --AND IsDeleted = 0

UPDATE [dbo].#tempAssociateReferenceTemplate SET Remarks =  COALESCE(Remarks,'') + 'Award Name does not exist;' 
WHERE AwardName IS NOT NULL AND AwardName != '' AND 
(AwardId IS NULL OR AwardId = '') --AND IsDeleted = 0

UPDATE [dbo].#tempAssociateReferenceTemplate SET Remarks =  COALESCE(Remarks,'') + 'ESAProjectId does not exist;' 
WHERE ESAProjectID  IS NOT NULL AND ESAProjectID ! = ''  AND
ProjectID  IS NULL OR ProjectID = '' --AND IsDeleted = 0

UPDATE [dbo].#tempAssociateReferenceTemplate SET Remarks =  COALESCE(Remarks,'') + 'EmployeeId does not exist;' 
WHERE EmployeeID IS NOT NULL AND EmployeeID != '' AND Isempexist = 0 --AND IsDeleted = 0


Insert into [AC].[TRN_Certification_Track](      
									   CertificationId,      
									   Module,      
									   ReferenceId,      
									   Isdeleted,
									   CreatedDate,
									   CreatedBy    
									  )   
									  
		SELECT 
			 CertificationId
			,Module
			,ReferenceId
			,0
			,GETDATE()
			,'SYSTEM' FROM 
		(SELECT 
			 ALC.CertificationId
			,ART.CategoryId AS Module
			,ReferenceId
			,ROW_NUMBER() OVER (PARTITION BY ART.CategoryId,CertificationId,ReferenceId
			ORDER BY ID)
			AS row_num
					FROM [dbo].#tempAssociateReferenceTemplate ART 
					INNER JOIN AC.TRN_Associate_Lens_Certification ALC ON ART.CategoryId = ALC.CategoryId 
					 AND  ART.AwardId = ALC.AwardId 
					AND  ART.ESAProjectID = ALC.ESAProjectID
					 AND ART.EmployeeID = ALC.EmployeeID
					WHERE  ART.CategoryId > 0 AND ART.AwardId > 0
					 AND ART.ProjectID > 0 
					AND ART.Isempexist = 1 AND IsCadMapexist = 1) ARTS WHERE row_num = 1

			AND  NOT EXISTS
(SELECT *
 FROM   [AC].[TRN_Certification_Track] TCT
 WHERE   ARTS.ReferenceId = TCT.ReferenceId
       AND  ARTS.CertificationId = TCT.CertificationId)
   
UPDATE ART SET ART.Remarks = TAR.Remarks FROM [dbo].[AssociateReferenceTemplate] ART INNER JOIN [dbo].#tempAssociateReferenceTemplate
TAR ON TAR.ID = ART.AssociateRefID
 
DELETE FROM [dbo].[AssociateReferenceTemplate]  
WHERE (Remarks is null or Remarks = '') AND IsDeleted = 0								   

DROP TABLE #tempAssociateReferenceTemplate			

END TRY  
 BEGIN CATCH  
  --ROLLBACK TRANSACTION;  
  DECLARE @ErrorMessage VARCHAR(4000);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error        
  EXEC AVL_InsertError '[dbo].[InsertAssociateRef]'  
   ,@ErrorMessage  
   ,0  
 END CATCH   

									   
 END
