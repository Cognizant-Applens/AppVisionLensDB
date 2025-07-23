                          
CREATE PROCEDURE [ML].[CheckAppValidTickets] --'4589','2024-09-17 00:00:00.000','2024-09-17 00:00:00.000', '2038108',6,1251                                               
@returnValue int output,                   
@ProjectId Bigint,                                                                               
@FromDate Date,                                                        
@ToDate Date,                                                
@UserID NVARCHAR(50) ,  
@IssueDefinitionID Bigint ,
@TransactionID Bigint
AS                                                
BEGIN                                                
 BEGIN TRY                                                 
                                                 
SET NOCOUNT ON;                                             
              
DECLARE @ValidDebtFields DECIMAL(18, 2);                                                        
DECLARE @TotalTickets DECIMAL(18, 2);                                              
DECLARE @DebtMet BIT;                                              
DECLARE @TicketCountMet BIT ;       
DECLARE @IssueDefinitionColumn varchar(Max);   
   DECLARE @Count AS int=0  
DECLARE @SQL AS NVARCHAR(1000)    
--DECLARE @returnValue int= 0;            
  
                
DECLARE @IsCognizant INT;                  
 DECLARE @CustomerID BIGINT;                  
 SET @CustomerID =(SELECT CustomerID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectId AND ISNULL(IsDeleted,0)=0)                  
 SET @IsCognizant=(SELECT ISNULL(IsCognizant,0) FROM AVL.Customer(NOLOCK)  WHERE CustomerID=@CustomerID)  

       
 SELECT TD.*  INTO #SASSTickets FROM [AVL].[TK_TRN_TICKETDETAIL] (NOLOCK) TD         
   inner JOIN AVL.APP_MAS_ApplicationDetails AD(NOLOCK) ON TD.ApplicationID = AD.ApplicationID AND AD.IsActive = 1          
      inner JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) appMap ON AD.ApplicationID = appMap.ApplicationID            
   AND appmap.projectid =TD.projectid AND appMap.IsDeleted=0          
        WHERE  TD.ProjectID = @ProjectId AND TD.IsDeleted=0                                     
  AND ((TD.DARTStatusID = 8 AND TD.ClosedDate BETWEEN @FromDate AND @ToDate) OR                                                  
     (TD.DARTStatusID = 9 AND TD.CompletedDateTime BETWEEN @FromDate AND @ToDate))    
      
SELECT TV.*  
--TV.TicketID,DebtClassificationMapID,AvoidableFlag,ResidualDebtMapID, TicketTypeMapID  
INTO #CustomerTickets                                                 
        FROM [AVL].[TK_TRN_TICKETDETAIL] TV (NOLOCK)           
   inner JOIN AVL.APP_MAS_ApplicationDetails AD(NOLOCK) ON TV.ApplicationID = AD.ApplicationID AND AD.IsActive = 1          
      inner JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) appMap ON AD.ApplicationID = appMap.ApplicationID            
   AND appmap.projectid =TV.projectid AND appMap.IsDeleted=0          
  INNER JOIN AVL.TK_MAP_TicketTypeMapping TVM                  
  ON TV.TicketTypeMapID = TVM.TicketTypeMappingID                
        WHERE  TV.ProjectID = @ProjectId AND TV.IsDeleted=0                                     
  AND ((TV.DARTStatusID = 8 AND TV.ClosedDate BETWEEN @FromDate AND @ToDate) OR                                                  
     (TV.DARTStatusID = 9 AND TV.CompletedDateTime BETWEEN @FromDate AND @ToDate))                
  AND TVM.DebtConsidered ='Y'  
  
  ----Selected Application should consider in CL Fix 
 IF(@TransactionId<>0)
 BEGIN
 SELECT DISTINCT ApplicationId,SignOffDate INTO #TempILApplication
FROM  ML.TRN_ClusteringTicketValidation_App(NOLOCK) CTV 
JOIN ML.TRN_MLTransaction (NOLOCK)T ON CTV.MLTransactionId=T.TransactionId
WHERE CTV.MLTransactionId = @TransactionId  
AND CTV.IsSelected=1 AND CTV.Isdeleted=0 AND T.SignOffDate IS NOT NULL

DELETE CV FROM   
#SASSTickets CV  
JOIN  #TempILApplication(NOLOCK) CTV  
ON  CV.ApplicationId = CTV.ApplicationId 

DELETE CV FROM   
#CustomerTickets CV  
JOIN  #TempILApplication(NOLOCK) CTV  
ON  CV.ApplicationId = CTV.ApplicationId 
 
 END
  
    
  SET @IssueDefinitionColumn=(SELECT       
 PFM.TK_TicketDetailColumn  
 FROM [AVL].[ITSM_PRJ_SSISColumnMapping] A (NOLOCK)      
 INNER JOIN MAS.ML_Prerequisite_FieldMapping PFM (NOLOCK)      
 ON PFM.ITSMColumn = A.ServiceDartColumn        
 WHERE FieldKey='PR001' AND A.ProjectID = @ProjectId   
 and PFM.IsDeleted = 0  AND A.Isdeleted=0 AND PFM.FieldMappingId=@IssueDefinitionID)  
      
IF @IsCognizant = 0                 
BEGIN                                                              
DELETE TV  FROM #CustomerTickets   TV                                         
INNER JOIN AVL.TK_MAP_TicketTypeMapping TVM                                              
ON TV.TicketTypeMapID=TVM.TicketTypeMappingID AND TVM.DebtConsidered ! ='Y'                                                                  
END      
        
   
IF @IsCognizant = 1                  
BEGIN                
SET @TotalTickets=(SELECT COUNT(DISTINCT TicketID) FROM #SASSTickets);     
  
  
SET @SQL='SELECT @count1=COUNT(DISTINCT TicketID) FROM  #SASSTickets  
  WHERE'+ QUOTENAME(@IssueDefinitionColumn)+ 'IS NOT NULL AND'+ QUOTENAME(@IssueDefinitionColumn)+'<>''''';  
EXECUTE sp_executeSQL @SQL, N'@count1 INT OUTPUT', @count1=@Count OUTPUT  
  
END                
ELSE                
BEGIN    
  
SET @TotalTickets=(SELECT COUNT(DISTINCT TicketID) FROM #CustomerTickets);    
  
SET @SQL='SELECT @count1=COUNT(DISTINCT TicketID) FROM  #CustomerTickets  
  WHERE'+ QUOTENAME(@IssueDefinitionColumn)+ 'IS NOT NULL AND'+ QUOTENAME(@IssueDefinitionColumn)+'<>''''';  
EXECUTE sp_executeSQL @SQL, N'@count1 INT OUTPUT', @count1=@Count OUTPUT  
  
  
END     
  
                                                                                                                              

IF (@TotalTickets >= 500 AND @Count<>0 AND (( @Count * 100 / @TotalTickets)) >= 80)                                        
BEGIN                                        
set @returnValue=2                                        
END
ELSE IF(@TotalTickets >= 500)                                              
BEGIN                                              
set @returnValue=1   
END 
ELSE                                              
BEGIN                                              
set @returnValue=0                                                                                        
END   
                                             

  select @returnValue
    END TRY                                              
      BEGIN CATCH                                 
          DECLARE @ErrorMessage VARCHAR(MAX);                                 
          SELECT @ErrorMessage = ERROR_MESSAGE()                                                 
                                                
          --INSERT Error                                                     
      EXEC AVL_INSERTERROR                                                 
            '[ML].[CheckAppValidTickets]',                                                 
            @ErrorMessage,                                                 
            @ProjectId,                                                 
            @UserID                                                 
                                              
      END CATCH                                                 
  END   