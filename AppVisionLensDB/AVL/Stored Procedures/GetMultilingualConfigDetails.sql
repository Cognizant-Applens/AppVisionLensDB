/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetMultilingualConfigDetails]   
 -- Add the parameters for the stored procedure here  
@ProjectID bigint=null,  
@CustomerID int=null  
  
AS  
BEGIN  

SET NOCOUNT ON;    
BEGIN TRY  
BEGIN TRAN  
  
  
SELECT  
 '0' AS IsMultilingualEnabled  
 ,PM.IsSingleORMulti  
 ,PM.MSubscriptionKey  
FROM AVL.MAS_ProjectMaster PM (NOLOCK)  
WHERE PM.ProjectID = @ProjectID  
AND PM.IsDeleted = 0  
  
  
  
----Get Field selection  
  
  
DECLARE @ColumnMaster TABLE(ColumnID INT,  
ColumnName NVARCHAR(MAX),  
IsSelected INT)  
  
SELECT  
 MMC.ColumnID INTO #Selectedcolumns  
FROM AVL.MAS_MultilingualColumnMaster MC (NOLOCK)  
LEFT JOIN AVL.PRJ_MultilingualColumnMapping MMC (NOLOCK)  
 ON MC.ColumnID = MMC.ColumnID  
WHERE MMC.ProjectID = @ProjectID  
AND MMC.IsActive = 1 AND MC.IsActive=1  
  
INSERT INTO @ColumnMaster  
 SELECT  
  MC.ColumnID  
  ,MC.ColumnName  
  ,0  
 FROM AVL.MAS_MultilingualColumnMaster MC (NOLOCK)  
 WHERE MC.IsActive = 1  
  
UPDATE A  
SET IsSelected = 1  
FROM @ColumnMaster A  
JOIN #Selectedcolumns B  
 ON A.ColumnID = B.ColumnID  
  
  
SELECT  
 ColumnID  
 ,ColumnName  
 ,IsSelected  
FROM @ColumnMaster  
  
DROP TABLE #Selectedcolumns  
  
  
---To Get lang master  
  
  
DECLARE @LangMaster Table  
(  
LanguageID int,  
LanguageName nvarchar(100),  
LanguageCode nvarchar(100),  
Isselected INT   
)  
  
  
insert into @LangMaster  
SELECT  
 LanguageID  
 ,LanguageName,  
 LanguageValue,0  
FROM MAS.MAS_LanguageMaster  (NOLOCK) 
WHERE ContentIsActive = 1  
AND ISDELETED = 0  
  
SELECT MML.LanguageID   
INTO #SelectedLang   
FROM MAS.MAS_LanguageMaster LM (NOLOCK)   
Left join AVL.PRJ_MAP_MultilingualLanguage MML (NOLOCK)  
ON LM.LanguageID=MML.LanguageID  
WHERE MML.ProjectID=@ProjectID AND MML.Isdeleted=0 AND LM.ContentIsActive=1 AND LM.IsDeleted = 0  
  
UPDATE A set IsSelected=1  
from @LangMaster A JOIN #SelectedLang B ON A.LanguageID=B.LanguageID  
  
SELECT * FROM @LangMaster  
DROP TABLE #SelectedLang  
  
COMMIT TRAN  
END TRY   
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  ROLLBACK TRAN  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[GetMultilingualConfigDetails]',    
@ErrorMessage, '' ,@ProjectID  
    
 END CATCH    
  SET NOCOUNT OFF;
END