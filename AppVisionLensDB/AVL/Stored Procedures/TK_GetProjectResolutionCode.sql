/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
  
CREATE PROCEDURE [AVL].[TK_GetProjectResolutionCode]  
(  
@ProjectID INT,  
@CauseCode INT=NULL  
)  
AS  
BEGIN 
SET NOCOUNT ON;
BEGIN TRY  
  
DECLARE @MapCount BIGINT;  
SET @MapCount=(SELECT COUNT(A.ResolutionCodeMapID) AS MapCount FROM AVL.CauseCodeResolutionCodeMapping A (NOLOCK) 
 JOIN AVL.DEBT_MAP_ResolutionCode B (NOLOCK) ON A.ResolutionCodeMapID=B.ResolutionID  
 AND A.ProjectID=B.ProjectID WHERE A.CauseCodeMapID=@CauseCode AND A.ProjectID=@ProjectID AND A.IsDeleted=0 AND B.IsDeleted=0)  
  CREATE TABLE #TmpResolutionMappingResult  
  (  
  ResolutionID BIGINT,  
  ResolutionCode NVARCHAR(500),  
  IsMapped BIT  
  )  
 INSERT INTO #TmpResolutionMappingResult  
 (ResolutionID,ResolutionCode,IsMapped)  
 SELECT '0' as ResolutionID,'--Select--' as ResolutionCode,0 AS IsMapped  
  
 SELECT distinct A.ResolutionCodeMapID AS ResolutionID,B.ResolutionCode,1 AS IsMapped INTO #TmpResolutionMapping FROM AVL.CauseCodeResolutionCodeMapping A (NOLOCK)   
 JOIN AVL.DEBT_MAP_ResolutionCode B (NOLOCK)   ON A.ResolutionCodeMapID=B.ResolutionID  
 AND A.ProjectID=B.ProjectID WHERE A.CauseCodeMapID=@CauseCode AND A.ProjectID=@ProjectID AND A.IsDeleted=0 AND B.IsDeleted=0  
 ORDER BY ResolutionCode DESC  
  
 INSERT INTO #TmpResolutionMappingResult  
 (ResolutionID,ResolutionCode,IsMapped)  
 SELECT ResolutionID,ResolutionCode,IsMapped FROM #TmpResolutionMapping (NOLOCK)   
  
 CREATE TABLE #TmpResolutionMaster  
 (  
  
 ID int IDENTITY(1,1),  
 ResolutionID BIGINT,  
 ResolutionCode NVARCHAR(500),  
 IsMapped BIT  
 )  
    
 INSERT INTO #TmpResolutionMaster  
 SELECT distinct ResolutionID,ResolutionCode,IsMapped FROM #TmpResolutionMappingResult (NOLOCK)    
  
 INSERT INTO #TmpResolutionMaster  
 SELECT ResolutionID,ResolutionCode,0 AS IsMapped FROM  
 (SELECT ResolutionID,ResolutionCode  FROM AVL.DEBT_MAP_ResolutionCode (NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 0   
 EXCEPT  
 SELECT ResolutionID,ResolutionCode FROM #TmpResolutionMapping (NOLOCK)) A order by ResolutionCode  
  
  
 SELECT distinct ID,ResolutionID,ResolutionCode,IsMapped,@MapCount AS MapCount FROM #TmpResolutionMaster (NOLOCK)  
  
   
  
 DROP TABLE #TmpResolutionMapping  
 DROP TABLE #TmpResolutionMaster  
 DROP TABLE #TmpResolutionMappingResult  
  
 END TRY    
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[TK_GetProjectResolutionCode] ', @ErrorMessage, @ProjectID,0  
    
 END CATCH    
  
 SET NOCOUNT OFF; 
  
END
