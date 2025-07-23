/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
  
CREATE PROCEDURE [AVL].[TK_GetProjectCauseCode]   
(  
@ProjectID INT,  
@ApplicationID BIGINT  
)  
AS  
BEGIN 
SET NOCOUNT ON;
BEGIN TRY  
 DECLARE @IsDDFlag CHAR  
 SET @IsDDFlag = (Select IsDDAutoClassified from AVL.MAS_ProjectDebtDetails(nolock) where ProjectID = @ProjectID AND IsDeleted=0)  
 IF @IsDDFlag='Y'  
 BEGIN  
    DECLARE @MapCount BIGINT;  
    SET @MapCount=(SELECT COUNT(DISTINCT A.CauseCodeID) AS MapCount FROM AVL.Debt_MAS_ProjectDataDictionary A (NOLOCK)  
 JOIN AVL.DEBT_MAP_CauseCode B (NOLOCK)  ON   
  A.ProjectID=B.ProjectID and B.causeid=A.causecodeId WHERE A.ApplicationID=@ApplicationID AND A.ProjectID=@ProjectID AND A.IsDeleted=0 AND B.IsDeleted=0)  
    
    CREATE TABLE #TmpCauseCodeMappingResult  
    (  
    CauseID BIGINT,  
    CauseCode NVARCHAR(500),  
    IsMapped BIT  
    )   
 --union  
 SELECT DISTINCT CauseID,CauseCode,1 AS IsMapped   
 INTO #temDataDictionaryResult  
 FROM AVL.DEBT_MAP_CauseCode CC (NOLOCK)  
 JOIN AVL.Debt_MAS_ProjectDataDictionary PDD (NOLOCK)  
 ON PDD.ProjectID=CC.ProjectID   
 WHERE CC.ProjectID = @ProjectID AND PDD.ApplicationID = @ApplicationID and cc.causeid=pdd.causecodeId AND CC.IsDeleted = 0 AND PDD.IsDeleted=0  
   
  
 INSERT INTO #TmpCauseCodeMappingResult  
 SELECT CauseID,CauseCode,IsMapped FROM #temDataDictionaryResult (NOLOCK)  
   
 CREATE TABLE #TmpCauseCodeMaster  
 (  
 ID int IDENTITY(1,1),  
 CauseID BIGINT,  
 CauseCode NVARCHAR(500),  
 IsMapped BIT  
 )  
  
 INSERT INTO #TmpCauseCodeMaster  
 SELECT distinct CauseID,CauseCode,IsMapped FROM #TmpCauseCodeMappingResult (NOLOCK) order by CauseCode  
   
 INSERT INTO #TmpCauseCodeMaster  
 SELECT CauseID,CauseCode,0 AS IsMapped FROM  
 (SELECT CauseID,CauseCode  FROM AVL.DEBT_MAP_CauseCode (NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 0   
 EXCEPT  
 SELECT CauseID,CauseCode FROM #temDataDictionaryResult (NOLOCK)) A order by CauseCode  
   
 SELECT distinct ID,CauseID,CauseCode,IsMapped,@MapCount AS MapCount FROM #TmpCauseCodeMaster (NOLOCK)  
  
     DROP TABLE #TmpCauseCodeMappingResult  
  DROP TABLE #temDataDictionaryResult  
  DROP TABLE #TmpCauseCodeMaster  
 END  
  
 ELSE  
  
 BEGIN  
  
 SELECT CauseID,CauseCode,0 AS IsMapped,0 AS MapCount FROM AVL.DEBT_MAP_CauseCode (NOLOCK) WHERE ProjectId = @ProjectID AND IsDeleted=0  
 ORDER BY CauseCode  
  
 END  
  
 END TRY   
  
 BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  EXEC AVL_InsertError '[AVL].[TK_GetProjectCauseCode] ', @ErrorMessage, @ProjectID,0  
      
 END CATCH   
  SET NOCOUNT OFF;
END
