/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[ITSM_SaveCauseCodeDetails]           
 @ProjectID INT,          
 @CognizantID VARCHAR(100)=NULL,          
 @tvp_ITSMCauseId TVP_ITSMGetCauseID READONLY,          
 @CCItsmTool VARCHAR(5)=NULL,          
 @CustomerID INT=NULL          
AS          
BEGIN          
           
 SET NOCOUNT ON;          
 BEGIN TRY       
 --delete from tempCCList      
  --INSERT INTO tempCCList (CauseCode,CauseID,CauseStatusID, MCauseCode,IsDelete)         
  -- SELECT DISTINCT [ITSM CauseCode Name],NULL,NULL,[Applens CauseCode Name],[Delete] FROM @tvp_ITSMCauseId          
  BEGIN TRANSACTION          
           
   DECLARE @ClusterID INT,@result BIT=0,@ITSMCC BIT = 1,@IsCognizant INT,@ITSMScreenId INT=7;          
          
   SELECT  @IsCognizant=C.IsCognizant FROM AVL.Customer C WHERE CustomerID=@CustomerID          
          
   SELECT @ClusterID=ClusterID FROM MAS.Cluster(NOLOCK) WHERE ClusterName='NA' AND CategoryID = 1          
          
   CREATE TABLE #tempCCList ( CauseCode NVARCHAR(1000),CauseID INT, CauseStatusID INT, MCauseCode VARCHAR(500),IsDelete VARCHAR(10))          
   INSERT INTO #tempCCList (CauseCode,CauseID,CauseStatusID, MCauseCode,IsDelete)         
   SELECT DISTINCT [ITSM CauseCode Name],NULL,NULL,[Applens CauseCode Name],[Delete] FROM @tvp_ITSMCauseId        
     
   IF(@CCItsmTool = 'N')          
   BEGIN          
     UPDATE CC          
    SET CC.CauseCode = CL.ClusterName          
    FROM [AVL].[DEBT_MAP_CauseCode] CC JOIN MAS.Cluster CL ON CL.ClusterID = CC.CauseStatusID          
    WHERE CL.CategoryID = 1 AND CC.ProjectID = @ProjectID and CC.IsDeleted = 0 and CL.IsDeleted = 0           
         
   END          
        
  UPDATE  ICI           
     SET ICI.CauseID= ISNULL(CC.CauseID,0) FROM #tempCCList ICI         
  INNER JOIN [AVL].[DEBT_MAP_CauseCode] CC ON CC.CauseCode=ICI.CauseCode          
     WHERE CC.ProjectID=@ProjectID AND CC.IsDeleted=0          
          
             
    UPDATE ICI          
     SET ICI.CauseStatusID=ISNULL(CL.ClusterID,0),ICI.MCauseCode=CL.ClusterName          
     FROM #tempCCList ICI JOIN MAS.Cluster CL ON ICI.MCauseCode=CL.ClusterName          
     WHERE CL.IsDeleted=0          
        
 UPDATE CC SET CC.IsDeleted=1 FROM [AVL].[DEBT_MAP_CauseCode] CC INNER JOIN #tempCCList CCL ON CC.CauseId=CCL.CauseId  
 WHERE CCL.IsDelete='Yes'  
           
    DELETE #tempCCList WHERE (CauseID IS NOT NULL OR CauseID<>0) AND (CauseStatusID IS NOT NULL OR CauseStatusID<>0)    
  
          
    UPDATE #tempCCList SET CauseStatusID=@ClusterID WHERE CauseStatusID=0 OR CauseStatusID IS NULL          
    UPDATE #tempCCList SET CauseID=ISNULL(CauseID,0) WHERE CauseID=0 OR CauseID IS NULL          
          
    INSERT INTO [AVL].[DEBT_MAP_CauseCode] (CauseCode,CauseStatusID,ProjectID,IsHealConsidered,IsDeleted,CreatedBy,CreatedDate)          
     SELECT CauseCode,CauseStatusID,@ProjectID,'Y',0,@CognizantID,GETDATE() FROM #tempCCList
	 
	 ;With CTE(CauseId, CauseCode, Rownum)
	AS (Select CauseId, CauseCode, Row_Number() 
	OVER (partition By CauseCode order by CauseCode, CauseId desc) as Rownum  from [AVL].[DEBT_MAP_CauseCode] WHERE ProjectId=@ProjectID )
	Update CC Set IsDeleted=1, ModifiedBy=@CognizantID,ModifiedDate=GETDATE()
	FROM [AVL].[DEBT_MAP_CauseCode] CC INNER JOIN CTE C ON CC.CauseId=C.CauseId
	WHERE C.Rownum>1

          
  IF @IsCognizant=1          
  BEGIN           
   SET @ITSMScreenId=8          
  END          
  ELSE           
  BEGIN          
   SET @ITSMScreenId=7          
        END          
  IF(NOT EXISTS(SELECT ITSMScreenId FROM [AVL].[PRJ_ConfigurationProgress] WHERE ITSMScreenId=@ITSMScreenId AND projectid=@ProjectID AND IsDeleted=0 AND  customerid=@CustomerID AND screenid=2))          
  BEGIN          
    INSERT INTO [AVL].[PRJ_ConfigurationProgress] (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)          
    VALUES(@CustomerID,@ProjectID,2,@ITSMScreenId,100,0,@CognizantID,GETDATE())          
  END            
  ELSE          
  BEGIN          
          
  UPDATE [AVL].[PRJ_ConfigurationProgress]  SET ModifiedBy=@CognizantID,ModifiedDate=GETDATE() WHERE ProjectID=@ProjectID AND ITSMScreenId=@ITSMScreenId AND customerid=@CustomerID AND screenid=2 AND IsDeleted=0           
  END          
          
   UPDATE AVL.MAS_ProjectMaster set HasCCITSMTool = CASE WHEN @CCItsmTool = 'N' THEN 0 ELSE 1 END WHERE ProjectID = @ProjectID          
          
   --SELECT * FROM #tempCCList          
   DROP TABLE #tempCCList          
   SELECT 1 AS Result          
  COMMIT TRANSACTION          
 END TRY          
 BEGIN CATCH          
   DECLARE @ErrorMessage VARCHAR(MAX);          
          
  SELECT @ErrorMessage = ERROR_MESSAGE()          
  ROLLBACK TRAN          
 --INSERT Error              
  EXEC AVL_InsertError ' [dbo].[ITSM_SaveCauseCodeDetails]', @ErrorMessage, 0 ,@CustomerID          
    SET @result=1          
 END CATCH          
          
          
          
END
