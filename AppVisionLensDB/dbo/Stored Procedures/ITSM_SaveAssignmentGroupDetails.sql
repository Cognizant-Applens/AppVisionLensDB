/***************************************************************************            
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET            
*Copyright [2018] – [2021] Cognizant. All rights reserved.            
*NOTICE: This unpublished material is proprietary to Cognizant and            
*its suppliers, if any. The methods, techniques and technical            
  concepts herein are considered Cognizant confidential and/or trade secret information.             
              
*This material may be covered by U.S. and/or foreign patents or patent applications.             
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.            
***************************************************************************/            
    
CREATE PROCEDURE [dbo].[ITSM_SaveAssignmentGroupDetails]             
 @ProjectID BIGINT,            
 @CognizantID VARCHAR(100)=NULL,            
 @tvp_ITSMAssignmentGroupId TVP_ITSMGetAssignmentGroupID READONLY,            
 @CustomerID INT=NULL            
AS            
BEGIN                 
 SET NOCOUNT ON;            
 BEGIN TRY            
  BEGIN TRANSACTION            
    DECLARE @result BIT=0, @IsCognizant INT, @ITSMScreenId INT;          
    SELECT  @IsCognizant=C.IsCognizant FROM AVL.Customer C (NOLOCK) WHERE CustomerID=@CustomerID AND IsDeleted = 0        
        
 CREATE TABLE #tempList (AssignmentGroupName NVARCHAR(1000), AssignmentGroupMapID BIGINT, CategoryName VARCHAR(500), AssignmentGroupCategoryTypeID INT, SupportTypeName VARCHAR(500), SupportTypeID INT, IsBotGroup VARCHAR(10), IsDelete VARCHAR(10))         
 
    INSERT INTO #tempList (AssignmentGroupName,AssignmentGroupMapID,CategoryName,AssignmentGroupCategoryTypeID,SupportTypeName,SupportTypeID,IsBotGroup,IsDelete)         
 SELECT DISTINCT ID,NULL,Category,NULL,[Support Type],NULL,[Is Bot Group],[Delete] FROM @tvp_ITSMAssignmentGroupId         
         
 UPDATE temp           
    SET temp.AssignmentGroupMapID= ISNULL(AGM.AssignmentGroupMapID,0)          
    FROM #tempList temp (NOLOCK) JOIN AVL.BOTAssignmentGroupMapping AGM (NOLOCK) ON AGM.AssignmentGroupName=temp.AssignmentGroupName           
    JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON AGM.ProjectID=PM.ProjectID          
    WHERE AGM.ProjectID=@ProjectID AND AGM.IsDeleted=0 AND PM.IsDeleted=0          
          
 UPDATE temp          
    SET temp.AssignmentGroupCategoryTypeID=ISNULL(AGT.AssignmentGroupTypeID,0)          
    FROM #tempList temp (NOLOCK) JOIN AVL.MAS_AssignmentGroupType AGT (NOLOCK) ON temp.CategoryName=AGT.AssignmentGroupTypeName          
    WHERE AGT.IsDeleted=0          
        
 UPDATE temp          
    SET temp.SupportTypeID=ISNULL(STM.SupportTypeId,0)          
    FROM #tempList temp (NOLOCK) JOIN AVL.SupportTypeMaster STM (NOLOCK) ON temp.SupportTypeName=STM.SupportTypeName          
    WHERE STM.IsDeleted=0          
        
              
 --UPDATE AGM SET AGM.IsDeleted=1 FROM AVL.BOTAssignmentGroupMapping AGM INNER JOIN #tempList temp ON AGM.AssignmentGroupMapId=temp.AssignmentGroupMapID        
 --WHERE temp.IsDelete='Yes'        
     
 SELECT      
 (CASE WHEN (COUNT(TD.TimeTickerID)>0 or COUNT(ITD.TimeTickerID)>0 or COUNT(BTD.TimeTickerID)>0) THEN 1 ELSE 0 END) as 'TicketCount'      
 ,AGM.AssignmentGroupMapID as 'AssignmentGroupMapID'      
 into #TicketCountTemp      
 from AVL.BOTAssignmentGroupMapping AGM (NOLOCK)       
 left join AVL.TK_TRN_TicketDetail TD (NOLOCK)  on TD.AssignmentGroupID=AGM.AssignmentGroupMapID and TD.IsDeleted=0      
 left join AVL.TK_TRN_InfraTicketDetail ITD (NOLOCK)  on ITD.AssignmentGroupID=AGM.AssignmentGroupMapID and ITD.IsDeleted=0      
 left join AVL.TK_TRN_BOTTicketDetail BTD (NOLOCK)  on BTD.AssignmentGroupID=AGM.AssignmentGroupMapID and BTD.IsDeleted=0      
 where AGM.ProjectID=@ProjectID and AGM.IsDeleted=0       
 GROUP by AGM.AssignmentGroupMapID     
  
 UPDATE AGM          
 SET AGM.AssignmentGroupName = temp.AssignmentGroupName,        
 AGM.AssignmentGroupCategoryTypeID = temp.AssignmentGroupCategoryTypeID,        
 AGM.SupportTypeID = temp.SupportTypeID,        
 AGM.IsBOTGroup = CASE WHEN temp.IsBotGroup='Yes' THEN 1 ELSE 0 END,     
 AGM.IsDeleted = CASE WHEN (temp.IsDelete = 'Yes' AND tickettemp.TicketCount = 0) THEN 1 ELSE 0 END,  
 AGM.ModifiedBy = @CognizantID,        
 AGM.ModifiedDate = GETDATE()          
 FROM AVL.BOTAssignmentGroupMapping AGM  (NOLOCK)         
 JOIN #tempList temp          
 ON temp.AssignmentGroupMapID = AGM.AssignmentGroupMapID        
 JOIN #TicketCountTemp tickettemp ON tickettemp.AssignmentGroupMapID = AGM.AssignmentGroupMapID  
 WHERE tickettemp.TicketCount = 0 AND AGM.ProjectID = @ProjectID AND AGM.IsDeleted = 0     
    
 DELETE #tempList WHERE (AssignmentGroupMapID IS NOT NULL OR AssignmentGroupMapID<>0)        
        
 UPDATE #tempList SET AssignmentGroupMapID=ISNULL(AssignmentGroupMapID,0)         
 WHERE AssignmentGroupMapID=0 OR AssignmentGroupMapID IS NULL          
        
 INSERT INTO AVL.BOTAssignmentGroupMapping (AssignmentGroupName, ProjectID, AssignmentGroupCategoryTypeID, SupportTypeID,         
 IsBOTGroup, IsDeleted, CreatedBy, CreatedDate)          
 (SELECT AssignmentGroupName,@ProjectID,AssignmentGroupCategoryTypeID,SupportTypeID,CASE WHEN IsBotGroup='Yes' THEN 1 ELSE 0 END,0,@CognizantID,GETDATE()          
 FROM #tempList (NOLOCK) WHERE AssignmentGroupMapID = 0)          
         
  IF @IsCognizant=1            
  BEGIN             
   SET @ITSMScreenId=12            
  END            
  ELSE             
  BEGIN            
   SET @ITSMScreenId=10            
  END            
  IF(NOT EXISTS(SELECT (Id) FROM [AVL].[PRJ_ConfigurationProgress] (NOLOCK) WHERE ITSMScreenId=@ITSMScreenId AND projectid=@ProjectID AND IsDeleted=0 AND  customerid=@CustomerID AND screenid=2))            
  BEGIN            
    INSERT INTO [AVL].[PRJ_ConfigurationProgress] (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)            
    VALUES(@CustomerID,@ProjectID,2,@ITSMScreenId,100,0,@CognizantID,GETDATE())            
  END              
  ELSE            
  BEGIN            
 UPDATE [AVL].[PRJ_ConfigurationProgress]         
 SET ModifiedBy=@CognizantID,ModifiedDate=GETDATE()         
 WHERE ProjectID=@ProjectID AND ITSMScreenId=@ITSMScreenId AND customerid=@CustomerID AND screenid=2 AND IsDeleted=0             
  END            
             
   DROP TABLE #tempList   
   DROP TABLE #TicketCountTemp   
   SELECT 1 AS Result            
  COMMIT TRANSACTION            
 END TRY            
 BEGIN CATCH            
   DECLARE @ErrorMessage VARCHAR(MAX);            
            
  SELECT @ErrorMessage = ERROR_MESSAGE()            
  ROLLBACK TRAN            
  --INSERT Error                
  EXEC AVL_InsertError '[dbo].[ITSM_SaveAssignmentGroupDetails]', @ErrorMessage, 0 ,@CustomerID            
    SET @result=1        
 END CATCH            
 SET NOCOUNT OFF;          
END
