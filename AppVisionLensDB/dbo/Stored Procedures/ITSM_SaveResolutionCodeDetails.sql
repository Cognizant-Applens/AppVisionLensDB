/***************************************************************************        
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET        
*Copyright [2018] – [2021] Cognizant. All rights reserved.        
*NOTICE: This unpublished material is proprietary to Cognizant and        
*its suppliers, if any. The methods, techniques and technical        
  concepts herein are considered Cognizant confidential and/or trade secret information.         
          
*This material may be covered by U.S. and/or foreign patents or patent applications.         
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.        
***************************************************************************/        
CREATE PROCEDURE [dbo].[ITSM_SaveResolutionCodeDetails]         
 @ProjectID BIGINT,        
 @CognizantID VARCHAR(100)=NULL,        
 @tvp_ITSMResolutionId TVP_ITSMGetResolutionID READONLY,        
 @RCItsmTool VARCHAR(5)=NULL,        
 @CustomerID BIGINT=NULL        
AS        
BEGIN        
         
 SET NOCOUNT ON;        
 BEGIN TRY        
  BEGIN TRANSACTION        
        
   DECLARE @ClusterID INT,@result BIT=0,@IsCognizant INT,@ITSMScreenId INT=8;        
        
   SELECT  @IsCognizant=C.IsCognizant FROM AVL.Customer C WHERE CustomerID=@CustomerID        
        
   SELECT @ClusterID=ClusterID FROM MAS.Cluster(NOLOCK) WHERE ClusterName='NA' AND CategoryID = 2        
        
   CREATE TABLE #tempRCList ( ResolutionCode NVARCHAR(1000),ResolutionID INT, ResolutionStatusID INT, MResolutionCode VARCHAR(500),IsDelete VARCHAR(10))        
   INSERT INTO #tempRCList (ResolutionCode,ResolutionID,ResolutionStatusID, MResolutionCode,IsDelete)  
   SELECT DISTINCT [ITSM ResolutionCode Name],NULL,NULL,[Applens ResolutionCode Name],[Delete] FROM @tvp_ITSMResolutionId        
       
    
IF(@RCItsmTool = 'N')            
   BEGIN            
     UPDATE RC            
    SET RC.ResolutionCode = CL.ClusterName            
    FROM [AVL].[DEBT_MAP_ResolutionCode] RC JOIN MAS.Cluster CL ON CL.ClusterID = RC.ResolutionStatusID            
    WHERE CL.CategoryID = 2 AND RC.ProjectID = @ProjectID and RC.IsDeleted = 0 and CL.IsDeleted = 0             
           
   END    
  
   UPDATE  RCL         
    SET RCL.ResolutionID= ISNULL(RC.ResolutionID,0)        
     FROM #tempRCList RCL JOIN [AVL].[DEBT_MAP_ResolutionCode] RC ON RC.ResolutionCode=RCL.ResolutionCode         
     JOIN AVL.MAS_ProjectMaster PM on RC.ProjectID=PM.ProjectID        
      WHERE RC.ProjectID=@ProjectID AND RC.IsDeleted=0 AND PM.IsDeleted=0        
        
           
   UPDATE RCL        
    SET RCL.ResolutionStatusID=ISNULL(CL.ClusterID,0),RCL.MResolutionCode=CL.ClusterName        
    FROM #tempRCList RCL JOIN MAS.Cluster CL ON RCL.MResolutionCode=CL.ClusterName        
    WHERE CL.IsDeleted=0 and CL.CategoryID=2     
   
 UPDATE RC SET RC.IsDeleted=1 FROM [AVL].[DEBT_MAP_ResolutionCode] RC INNER JOIN #tempRCList RCL ON RC.ResolutionID=RCL.ResolutionID    
 WHERE RCL.IsDelete='Yes'    
        
   DELETE #tempRCList WHERE (ResolutionID IS NOT NULL OR ResolutionID<>0) AND (ResolutionStatusID IS NOT NULL OR ResolutionStatusID<>0)        
        
   UPDATE #tempRCList SET ResolutionStatusID=@ClusterID WHERE ResolutionStatusID=0 OR ResolutionStatusID IS NULL        
   UPDATE #tempRCList SET ResolutionID=ISNULL(ResolutionID,0) WHERE ResolutionID=0 OR ResolutionID IS NULL        
        
   INSERT INTO [AVL].[DEBT_MAP_ResolutionCode] (ResolutionCode,ResolutionStatusID,ProjectID,IsHealConsidered,IsDeleted,CreatedBy,CreatedDate)        
    SELECT ResolutionCode,ResolutionStatusID,@ProjectID,'Y',0,@CognizantID,GETDATE() FROM #tempRCList    
	
	;With CTE(ResolutionId, ResolutionCode, Rownum)
	AS (Select ResolutionId, ResolutionCode, Row_Number() 
	OVER (partition By ResolutionCode order by ResolutionCode, ResolutionID desc) as Rownum  from [AVL].[DEBT_MAP_ResolutionCode] WHERE ProjectId=@ProjectID )
	Update RC Set IsDeleted=1, ModifiedBy=@CognizantID,ModifiedDate=GETDATE()
	FROM [AVL].[DEBT_MAP_ResolutionCode] RC INNER JOIN CTE C ON RC.ResolutionId=C.ResolutionId
	WHERE C.Rownum>1

	Update RCM Set IsDeleted=1, ModifiedBy=@CognizantID,ModifiedDate=GETDATE()
	FROM AVL.CauseCodeResolutionCodeMapping RCM INNER JOIN [AVL].[DEBT_MAP_ResolutionCode] RC ON RCM.ResolutionCodeMapID=RC.ResolutionId
	WHERE RC.IsDeleted=1 AND RC.ProjectId=@ProjectID

        
  IF @IsCognizant=1        
  BEGIN         
   SET @ITSMScreenId=9        
  END        
  ELSE         
  BEGIN        
   SET @ITSMScreenId=8        
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
        
   UPDATE AVL.MAS_ProjectMaster set HasRCITSMTool = CASE WHEN @RCItsmTool = 'N' THEN 0 ELSE 1 END WHERE ProjectID = @ProjectID        
        
   --SELECT * FROM #tempRCList         
   DROP TABLE #tempRCList        
   SELECT 1 AS Result        
  COMMIT TRANSACTION        
 END TRY        
 BEGIN CATCH        
   DECLARE @ErrorMessage VARCHAR(MAX);        
        
  SELECT @ErrorMessage = ERROR_MESSAGE()        
  ROLLBACK TRAN        
  --INSERT Error            
  EXEC AVL_InsertError ' [dbo].[ITSM_SaveResolutionCodeDetails]', @ErrorMessage, 0 ,@CustomerID        
    SET @result=1        
 END CATCH        
        
        
        
END
