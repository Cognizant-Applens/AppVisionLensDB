/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

  
CREATE PROCEDURE [AVL].[GetMandatoryAttributes_Standard]   
@ProjectID INT   ,          
@ServiceID INT   ,      
@StatusID INT,    
@FieldType varchar(10),    
@Type varchar(20)  
AS       
BEGIN         
 SET NOCOUNT ON;  
  
 DECLARE @IsMainspring Char(1)  
 SET @IsMainspring = (SELECT ISNULL(IsMainSpringConfigured,'N') FROM [AVL].[MAS_ProjectMaster](NOLOCK) WHERE ProjectID=@ProjectID)  
 IF(@IsMainspring='Y')  
 BEGIN  
CREATE TABLE #ProjectServiceMS(ServiceID INT)  
 IF NOT EXISTS(SELECT (1) FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] (NOLOCK) WHERE Projectid = @ProjectID)  
 BEGIN  
  EXEC [AVL].[InsertTicketAttributeToProject_NewProjectInsert_Mainspring] @ProjectID  
 END  
  
    
 IF(@IsMainspring='Y')  
 BEGIN  
  INSERT INTO #ProjectServiceMS  
   SELECT DISTINCT ServiceID  FROM [AVL].[TK_PRJ_ProjectServiceActivityMapping] PSA (NOLOCK) INNER JOIN [AVL].[TK_MAS_ServiceActivityMapping] MSM (NOLOCK)   
   ON PSA.ServiceMapID = MSM.ServiceMappingID AND MSM.IsDeleted = 0  
   and PSA.IsMainspringData = 'Y'   
   and (PSA.IsHidden = 0 or PSA.IsHidden IS NULL)  
   WHERE PSA.ProjectID = @ProjectID and PSA.IsDeleted = 0   
  --SELECT DISTINCT ServiceID  FROM avl.TK_PRJ_ProjectServiceActivityMapping  WHERE ProjectID = 4 and IsDeleted = 0 and IsMainspringData = 'Y'   
  --and (IsHidden = 0 or IsHidden IS NULL)  
 END  
 ELSE  
 BEGIN  
  INSERT INTO #ProjectServiceMS   
   SELECT DISTINCT ServiceID FROM [AVL].[TK_PRJ_ProjectServiceActivityMapping] PSA (NOLOCK) INNER JOIN [AVL].[TK_MAS_ServiceActivityMapping] MSM (NOLOCK)   
   ON PSA.ServiceMapID = MSM.ServiceMappingID AND MSM.IsDeleted = 0  
   and (PSA.IsHidden = 0 or PSA.IsHidden IS NULL)  
   WHERE PSA.ProjectID = @ProjectID and PSA.IsDeleted = 0   
   --SELECT DISTINCT ServiceID  FROM avl.TK_PRJ_ProjectServiceActivityMapping  WHERE ProjectID = @ProjectID and IsDeleted = 0  and (IsHidden = 0 or IsHidden IS NULL)  
 END  
 DECLARE @isdebtMS Char  
 SET @isdebtMS=(select top 1 ISNULL(IsDebtEnabled,'N') FROM [AVL].[MAS_ProjectMaster](NOLOCK) WHERE ProjectID=@ProjectID)  
   
 -- to get the mainspring attributes  
 SELECT * INTO #MainspringAttributeStatusMaster FROM [AVL].[MAS_MainspringAttributeStatusMaster] (NOLOCK) where IsDeleted = 0  
  
 --UPDATE  A      
 --SET     A.AttributeName=B.ProjectColumn     
 --FROM    #MainspringAttributeStatusMaster A ,      
 --AVL.ITSM_PRJ_SSISColumnMapping  B      
 --WHERE   A.AttributeName = B.ServiceDartColumn     
 --AND B.ProjectID = @ProjectID  
 --AND A.AttributeName IN('Flex Field (1)', 'Flex Field (2)','Flex Field (3)','Flex Field (4)')  
  
  
 IF @isdebtMS= 'Y'  
  BEGIN  
   --DECLARE @NatureOfTicketMS INT;  
   --DECLARE @KEDBPathMS INT;  
   DECLARE @FlexField1 INT;  
   DECLARE @FlexField2 INT;  
   DECLARE @FlexField3 INT;  
   DECLARE @FlexField4 INT;     
     
   --SET @NatureOfTicketMS=(SELECT top 1 ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping]  
   --      WHERE ColumnID=7 AND ProjectID=@ProjectID AND IsActive=0)  
   --SET @KEDBPathMS=(SELECT top 1 ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping]  
   --      WHERE ColumnID=9 AND ProjectID=@ProjectID AND IsActive=0)  
   SET @FlexField1=(SELECT top 1 ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping] (NOLOCK) 
         WHERE ColumnID= 11 AND ProjectID=@ProjectID AND IsActive=1)  
   SET @FlexField2=(SELECT top 1 ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping] (NOLOCK)  
         WHERE ColumnID=12 AND ProjectID=@ProjectID AND IsActive=1)  
   SET @FlexField3=(SELECT top 1 ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping] (NOLOCK)  
         WHERE ColumnID=13 AND ProjectID=@ProjectID AND IsActive=1)  
   SET @FlexField4=(SELECT top 1 ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping] (NOLOCK)  
         WHERE ColumnID=14 AND ProjectID=@ProjectID AND IsActive=1)  
  
   --IF @NatureOfTicketMS>0  
   -- BEGIN  
   --  UPDATE #MainspringAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=37  
   -- END  
   --IF @KEDBPathMS >0  
   -- BEGIN  
   -- UPDATE #MainspringAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=53  
   -- END  
   IF @FlexField1 >0  
   BEGIN     
   UPDATE #MainspringAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=93 AND serviceid in (1,4,5,6,7,8,10)  
   END  
   IF @FlexField2 >0  
   BEGIN  
   UPDATE #MainspringAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=94 AND serviceid in (1,4,5,6,7,8,10)  
   END  
   IF @FlexField3 >0  
   BEGIN  
   UPDATE #MainspringAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=95 AND serviceid in (1,4,5,6,7,8,10)  
   END  
   IF @FlexField4 >0  
   BEGIN  
   UPDATE #MainspringAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=96 AND serviceid in (1,4,5,6,7,8,10)  
   END  
 END  
   
 IF(@Type ='Mandatory')  
 BEGIN  
 IF(@FieldType ='M')  
 BEGIN  
  IF EXISTS (SELECT (1) FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] (NOLOCK) WHERE Projectid=@ProjectID AND FieldType='M' AND IsDeleted=0)        
  BEGIN       
  IF(@isdebtMS='N')  
   BEGIN  
    SELECT DISTINCT       
    CASM.AttributeId,       
    CASM.ServiceID,   
    CASM.StatusID AS CStatusID,        
    CASM.AttributeName,       
    CASM.StatusName AS CStatusName,   
    CASM.ServiceName,     
    'SavedAttributes'  AS StatusName,        
    CASE WHEN CASM.FieldType='M' THEN 'M'   
    ELSE D.FieldType   
    END AS FieldType,        
    'Status' AttributeType ,      
    CASE WHEN CASM.FieldType='M' THEN 0      
    ELSE 1      
    END AS IsEnabled ,    
    CASM.TicketDetailFields AS TicketMasterFields     
    FROM       
    #MainspringAttributeStatusMaster CASM  (NOLOCK)   
    INNER JOIN #ProjectServiceMS PS (NOLOCK) ON  CASM.ServiceID=PS.ServiceID  
    LEFT JOIN [AVL].[PRJ_MainspringAttributeProjectStatusMaster] D (NOLOCK)      
    ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName      
    WHERE        
    D.ProjectID = @ProjectID  
    AND D.ISDeleted =0          
    AND CASM.ISDeleted =0       
    AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration')    
    AND (D.FieldType='M' OR CASM.FieldType = 'M')      
   END  
   ELSE  
   BEGIN         
    SELECT DISTINCT       
    CASM.AttributeId,       
    CASM.ServiceID,   
    CASM.StatusID AS CStatusID,        
    CASM.AttributeName,       
    CASM.StatusName AS CStatusName,   
    CASM.ServiceName,     
    'SavedAttributes'  AS StatusName,        
    CASE WHEN CASM.FieldType='M' THEN 'M'   
    ELSE D.FieldType   
    END AS FieldType,           
    'Status' AttributeType ,      
    CASE WHEN CASM.FieldType='M' THEN 0      
    ELSE 1      
    END AS IsEnabled ,    
    CASM.TicketDetailFields AS TicketMasterFields     
    FROM       
    #MainspringAttributeStatusMaster CASM  (NOLOCK)   
    INNER JOIN #ProjectServiceMS PS (NOLOCK) ON  CASM.ServiceID=PS.ServiceID  
    LEFT JOIN [AVL].[PRJ_MainspringAttributeProjectStatusMaster] D (NOLOCK)      
    ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName      
    WHERE        
    D.ProjectID = @ProjectID  
    AND D.ISDeleted =0          
    AND CASM.ISDeleted =0       
    AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration')    
    AND (D.FieldType='M' OR CASM.FieldType = 'M')  
    AND CASM.AttributeID not in(85,86,87,88,89,90)   
   UNION   
    SELECT DISTINCT       
    CASM.AttributeId,       
    CASM.ServiceID,   
    CASM.StatusID AS CStatusID,        
    CASM.AttributeName,       
    CASM.StatusName AS CStatusName,   
    CASM.ServiceName,     
    'SavedAttributes'  AS StatusName,        
    CASE WHEN CASM.FieldType='M' THEN 'M'   
    ELSE D.FieldType   
    END AS FieldType,           
    'Status' AttributeType ,      
    0 AS IsEnabled ,    
    CASM.TicketDetailFields AS TicketMasterFields    
    FROM       
    #MainspringAttributeStatusMaster CASM  (NOLOCK)   
    INNER JOIN #ProjectServiceMS PS (NOLOCK) ON  CASM.ServiceID=PS.ServiceID  
    LEFT JOIN [AVL].[PRJ_MainspringAttributeProjectStatusMaster] D (NOLOCK)      
    ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName      
    WHERE        
    D.ProjectID = @ProjectID  
    AND D.ISDeleted =0          
    AND CASM.ISDeleted =0       
    AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration')    
    AND (D.FieldType='M' OR CASM.FieldType = 'M')  
    AND CASM.AttributeID in(85,86,87,88,89,90)   
   END  
  END    
 ELSE IF EXISTS (SELECT (1) FROM #MainspringAttributeStatusMaster (NOLOCK) WHERE FieldType='M' AND IsDeleted=0)       
  BEGIN      
    SELECT DISTINCT            
    D.AttributeId,           
    D.ServiceID,  
    D.StatusID AS CStatusID,             
    D.AttributeName,   
    D.ServiceName AS CStatusName,            
    D.StatusName,       
    'C20Services'  AS StatusName,        
    ISNULL(@ProjectID,0) AS ProjectID,             
    D.FieldType ,              
    'Status' AttributeType ,      
    CASE WHEN D.FieldType='M' THEN 0      
    ELSE 1      
    END AS IsEnabled  ,    
    D.TicketDetailFields AS TicketMasterFields          
    FROM       
    #MainspringAttributeStatusMaster D (NOLOCK)  
    INNER JOIN #ProjectServiceMS PS (NOLOCK) ON  D.ServiceID=PS.ServiceID  
    WHERE   
    D.ISDeleted =0      
    AND D.AttributeName NOT IN ('Planned Duration','Actual Duration')    
    AND D.FieldType='M'           
  END         
 END   
ELSE IF(@FieldType ='O')  
 BEGIN  
  IF EXISTS (SELECT (1) FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster]  (NOLOCK) WHERE Projectid=@ProjectID AND ServiceID=@ServiceID   
  AND StatusID=@StatusID AND FieldType='O' AND IsDeleted=0)        
  BEGIN   
    SELECT DISTINCT       
    CASM.AttributeId,       
    CASM.ServiceID,  
    CASM.StatusID AS CStatusID,       
    CASM.AttributeName,       
    CASM.StatusName AS CStatusName,   
    CASM.ServiceName,     
    'SavedAttributes'  AS StatusName,        
    D.FieldType,        
    'Status' AttributeType ,      
    CASE WHEN CASM.FieldType='M' THEN 0      
    ELSE 1      
    END AS IsEnabled ,    
    CASM.TicketDetailFields AS TicketMasterFields     
    FROM       
    #MainspringAttributeStatusMaster CASM  (NOLOCK)   
    INNER JOIN #ProjectServiceMS PS (NOLOCK) ON  CASM.ServiceID=PS.ServiceID  
    LEFT JOIN AVL.PRJ_MainspringAttributeProjectStatusMaster D (NOLOCK)      
    ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName  
    WHERE        
    D.ProjectID = @ProjectID          
    AND CASM.ServiceID=@ServiceID      
    AND CASM.StatusID=@StatusID         
    AND D.ISDeleted =0          
    AND CASM.ISDeleted =0       
    AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration')    
    AND (D.FieldType='O' AND CASM.FieldType='O')   
  END      
  ELSE IF EXISTS (SELECT (1) FROM #MainspringAttributeStatusMaster (NOLOCK) WHERE ServiceID=@ServiceID AND StatusID=@StatusID AND FieldType='O' AND IsDeleted=0)       
  BEGIN      
    SELECT DISTINCT            
    D.AttributeId,           
    D.ServiceID,   
    D.StatusID AS CStatusID,            
    D.AttributeName,   
    D.ServiceName,            
    D.StatusName AS CStatusName,       
    'C20Services'  AS StatusName,        
    ISNULL(@ProjectID,0) AS ProjectID,             
    D.FieldType ,              
    'Status' AttributeType ,      
    CASE WHEN D.FieldType='M' THEN 0      
    ELSE 1      
    END AS IsEnabled  ,    
    D.TicketDetailFields AS TicketMasterFields         
    FROM       
    #MainspringAttributeStatusMaster D (NOLOCK)   
    INNER JOIN #ProjectServiceMS PS ON  D.ServiceID=PS.ServiceID  
    WHERE       
    D.ServiceID=@ServiceID      
    AND D.StatusID=@StatusID         
    AND D.ISDeleted =0     
    AND D.AttributeName NOT IN ('Planned Duration','Actual Duration')    
    AND D.FieldType='O'           
  END        
 END  
 END   
  
  ELSE IF(@Type ='Download')  
 BEGIN   
  IF EXISTS (SELECT (1) FROM AVL.PRJ_MainspringAttributeProjectStatusMaster (NOLOCK) WHERE Projectid=@ProjectID  AND IsDeleted='N')        
  BEGIN    
   SELECT  DISTINCT    
   CASM.ServiceName,   
   CASE WHEN CASM.AttributeName='Resolution Method' THEN 'Resolution Remarks'  
   ELSE CASM.AttributeName      
   END AS AttributeName,   
   CASM.StatusName as [Status Name],      
   CASE WHEN CASM.FieldType='M' THEN 'M'   
    ELSE D.FieldType   
    END AS FieldType       
   FROM       
   #MainspringAttributeStatusMaster CASM  (NOLOCK)   
   INNER JOIN #ProjectServiceMS PS (NOLOCK) ON  CASM.ServiceID=PS.ServiceID  
   LEFT JOIN AVL.PRJ_MainspringAttributeProjectStatusMaster D (NOLOCK)      
   ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID --AND CASM.C20StatusName=D.C20StatusName    
   WHERE      
   D.ProjectID = @ProjectID   
   AND D.ISDeleted =0          
   AND CASM.ISDeleted =0       
   AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration')    
   AND (D.FieldType='M' OR CASM.FieldType = 'M')     
   UNION   
   SELECT   DISTINCT     
   CASM.ServiceName,   
   CASE WHEN CASM.AttributeName='Resolution Method' THEN 'Resolution Remarks'  
   ELSE CASM.AttributeName  END AS AttributeName,     
   CASM.StatusName as [Status Name],    
   D.FieldType   
   FROM       
   #MainspringAttributeStatusMaster CASM  (NOLOCK)   
   INNER JOIN #ProjectServiceMS PS (NOLOCK) ON  CASM.ServiceID=PS.ServiceID  
   LEFT JOIN AVL.PRJ_MainspringAttributeProjectStatusMaster D (NOLOCK)      
   ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID --AND CASM.C20StatusName=D.C20StatusName  
   WHERE       
   D.ProjectID = @ProjectID          
   AND CASM.ServiceID=@ServiceID      
   AND CASM.StatusID=@StatusID         
   AND D.ISDeleted =0          
   AND CASM.ISDeleted =0       
   AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration')    
   AND (D.FieldType='O' AND CASM.FieldType='O')   
 END      
 ELSE IF EXISTS (SELECT (1) FROM #MainspringAttributeStatusMaster(NOLOCK) WHERE IsDeleted='N')       
 BEGIN      
   SELECT  DISTINCT   
   D.StatusID,    
   D.ServiceName,  
   CASE WHEN D.AttributeName='Resolution Method' THEN 'Resolution Remarks'  
   ELSE D.AttributeName  END AS AttributeName,       
   D.StatusName as [Status Name],             
   D.FieldType              
   FROM       
   #MainspringAttributeStatusMaster D (NOLOCK)   
   INNER JOIN #ProjectServiceMS PS (NOLOCK) ON  D.ServiceID=PS.ServiceID  
   WHERE   
   D.ISDeleted =0     
   AND D.AttributeName NOT IN ('Planned Duration','Actual Duration')    
   AND D.FieldType='M'   
   UNION  
   SELECT  DISTINCT   
   D.StatusID,  
   D.ServiceName,    
   CASE WHEN D.AttributeName='Resolution Method' THEN 'Resolution Remarks'  
   ELSE D.AttributeName  END AS AttributeName,                
   D.StatusName as [Status Name],              
   D.FieldType            
   FROM       
   #MainspringAttributeStatusMaster D (NOLOCK)      
   INNER JOIN #ProjectServiceMS PS (NOLOCK) ON  D.ServiceID=PS.ServiceID  
   WHERE     
   D.ServiceID=@ServiceID      
   AND D.StatusID=@StatusID         
   AND D.ISDeleted =0      
   AND D.AttributeName NOT IN ('Planned Duration','Actual Duration')    
   AND D.FieldType='O'                
 END       
 END  
  
 END  
  
 --------------STANDARD PROJECT----------------------  
 ELSE  
 BEGIN  
--[AVL].[InsertTicketAttributeToProject_NewProjectInsert_Mainspring]  
  IF NOT EXISTS(SELECT (1) FROM [AVL].[PRJ_StandardAttributeProjectStatusMaster] (NOLOCK) WHERE Projectid = @ProjectID)  
   BEGIN  
    EXEC [AVL].[InsertTicketAttributeToProject_NewProjectInsert_Standard] @ProjectID  
   END  
    
    
    
 SELECT DISTINCT ServiceID INTO #ProjectService FROM [AVL].[TK_PRJ_ProjectServiceActivityMapping] PSA (NOLOCK) 
 INNER JOIN [AVL].[TK_MAS_ServiceActivityMapping] MSM (NOLOCK)   
 ON PSA.ServiceMapID = MSM.ServiceMappingID AND MSM.IsDeleted = 0  
  WHERE PSA.ProjectID = @ProjectID and PSA.IsDeleted = 0   
   
 DECLARE @isdebt Char  
 SET @isdebt=(select ISNULL(IsDebtEnabled,'N') FROM [AVL].[MAS_ProjectMaster](NOLOCK) WHERE ProjectID=@ProjectID)  
   
 --  to get the standard attributes  
 SELECT * INTO #StandardAttributeStatusMaster FROM [AVL].[MAS_StandardAttributeStatusMaster] (NOLOCK)  
    
 --UPDATE  A      
 --SET     A.AttributeName=B.ProjectColumn     
 --FROM    #StandardAttributeStatusMaster A ,      
 --AVL.ITSM_PRJ_SSISColumnMapping  B      
 --WHERE   A.AttributeName = B.ServiceDartColumn     
 --AND B.ProjectID = @ProjectID  
 --AND A.AttributeName IN('Flex Field (1)', 'Flex Field (2)','Flex Field (3)','Flex Field (4)')  
  
  print '1'  
 IF @isdebt= 'Y'  
  BEGIN  
   --DECLARE @NatureOfTicket INT;  
   --DECLARE @KEDBPath INT;  
   DECLARE @FlexFieldCust1 INT;  
   DECLARE @FlexFieldCust2 INT;  
   DECLARE @FlexFieldCust3 INT;  
   DECLARE @FlexFieldCust4 INT;  
     
   --SET @NatureOfTicket=(SELECT top 1 ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping]   
   --     WHERE ColumnID=7 AND ProjectID=@ProjectID AND IsActive=0)  
   --SET @KEDBPath=(SELECT top 1 ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping]   
   --      WHERE ColumnID=9 AND ProjectID=@ProjectID AND IsActive=0)  
   SET @FlexFieldCust1=(SELECT top 1 ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping] (NOLOCK)  
         WHERE ColumnID= 11 AND ProjectID=@ProjectID AND IsActive=1)  
   SET @FlexFieldCust2=(SELECT top 1 ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping] (NOLOCK)  
         WHERE ColumnID=12 AND ProjectID=@ProjectID AND IsActive=1)  
   SET @FlexFieldCust3=(SELECT top 1 ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping] (NOLOCK)  
         WHERE ColumnID=13 AND ProjectID=@ProjectID AND IsActive=1)  
   SET @FlexFieldCust4=(SELECT top 1 ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping] (NOLOCK)  
         WHERE ColumnID=14 AND ProjectID=@ProjectID AND IsActive=1)  
  
   --IF @NatureOfTicket>0  
   -- BEGIN  
   --  UPDATE #StandardAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=37  
   -- END  
   --IF @KEDBPath >0  
   -- BEGIN  
   -- UPDATE #StandardAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=53  
   -- END      
   IF @FlexFieldCust1 >0  
   BEGIN  
   UPDATE #StandardAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=93 AND serviceid in (1,4,5,6,7,8,10)  
   END  
   IF @FlexFieldCust2 >0  
   BEGIN  
   UPDATE #StandardAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=94 AND serviceid in (1,4,5,6,7,8,10)  
   END  
   IF @FlexFieldCust3 >0  
   BEGIN  
   UPDATE #StandardAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=95 AND serviceid in (1,4,5,6,7,8,10)  
   END  
   IF @FlexFieldCust4 >0  
   BEGIN  
   UPDATE #StandardAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=96 AND serviceid in (1,4,5,6,7,8,10)  
   END  
 END  
   
 IF(@Type ='Mandatory')  
 BEGIN  
 IF(@FieldType ='M')  
 BEGIN  
  IF EXISTS (SELECT (1) FROM [AVL].[PRJ_StandardAttributeProjectStatusMaster] (NOLOCK) WHERE Projectid=@ProjectID AND FieldType='M' AND IsDeleted=0)        
  BEGIN     
         
       IF(@isdebt='N')  
       BEGIN  
       print '2'  
        SELECT DISTINCT       
        CASM.AttributeId,       
        CASM.ServiceID AS ServiceID,    
        CASM.StatusID AS CStatusID,       
        CASM.AttributeName,       
        CASM.StatusName AS CStatusName,   
        CASM.ServiceName,     
        'SavedAttributes'  AS StatusName,        
       CASE WHEN CASM.FieldType='M' THEN 'M'   
       ELSE D.FieldType   
       END AS FieldType,     
        'Status' AttributeType ,      
        CASE WHEN  CASM.FieldType='M' THEN 0      
        ELSE 1      
        END AS IsEnabled ,    
        CASM.TicketMasterFields      
        FROM       
        #StandardAttributeStatusMaster CASM  (NOLOCK)   
        INNER JOIN #ProjectService PS (NOLOCK) ON  CASM.ServiceID=PS.ServiceID  
        LEFT JOIN [AVL].[PRJ_StandardAttributeProjectStatusMaster] D (NOLOCK)      
        ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName     
        WHERE    
        D.ProjectID = @ProjectID  
        AND D.ISDeleted =0       
        AND CASM.ISDeleted =0       
        AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration')    
        AND (D.FieldType='M' OR CASM.FieldType = 'M')   
        AND CASM.IsDeleted=0  
       END  
       ELSE  
       BEGIN  
       print '3'  
        SELECT DISTINCT       
        CASM.AttributeId,       
        CASM.ServiceID,    
        CASM.StatusID AS CStatusID,       
        CASM.AttributeName,       
        CASM.StatusName AS CStatusName,   
        CASM.ServiceName,     
        'SavedAttributes'  AS StatusName,        
       CASE WHEN CASM.FieldType='M' THEN 'M'   
       ELSE D.FieldType   
       END AS FieldType,     
        'Status' AttributeType ,      
        CASE WHEN  CASM.FieldType='M' THEN 0      
        ELSE 1      
        END AS IsEnabled ,    
        CASM.TicketMasterFields      
        FROM       
        #StandardAttributeStatusMaster CASM  (NOLOCK)   
        INNER JOIN #ProjectService PS (NOLOCK) ON  CASM.ServiceID=PS.ServiceID  
        LEFT JOIN [AVL].[PRJ_StandardAttributeProjectStatusMaster] D (NOLOCK)      
        ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName     
        WHERE    
        --D.ServiceID in (select ServiceID from #ProjectService) AND      
        D.ProjectID = @ProjectID  
        AND D.ISDeleted =0          
        AND CASM.ISDeleted =0       
        AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration')    
        AND (D.FieldType='M'  OR CASM.FieldType = 'M')  
        AND CASM.AttributeID NOT in(85,86,87,88,89,90)   
      UNION  
        SELECT DISTINCT       
        CASM.AttributeId,       
        CASM.ServiceID,    
        CASM.StatusID AS CStatusID,       
        CASM.AttributeName,       
        CASM.StatusName AS CStatuName,   
        CASM.ServiceName,     
        'SavedAttributes'  AS StatusName,        
       CASE WHEN CASM.FieldType='M' THEN 'M'   
       ELSE D.FieldType   
       END AS FieldType,     
        'Status' AttributeType ,      
       0 AS IsEnabled ,    
        CASM.TicketMasterFields      
        FROM       
        #StandardAttributeStatusMaster CASM  (NOLOCK)   
        INNER JOIN #ProjectService PS (NOLOCK) ON  CASM.ServiceID=PS.ServiceID  
        LEFT JOIN [AVL].[PRJ_StandardAttributeProjectStatusMaster] D (NOLOCK)      
        ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName     
        WHERE        
        D.ProjectID = @ProjectID  
        AND D.ISDeleted =0          
        AND CASM.ISDeleted =0       
        AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration')    
        AND (D.FieldType='M' OR CASM.FieldType ='M')  
        AND CASM.AttributeID in(85,86,87,88,89,90)   
       END  
         
 END      
 ELSE IF EXISTS (SELECT (1) FROM [AVL].[MAS_StandardAttributeStatusMaster] (NOLOCK) WHERE FieldType='M' AND IsDeleted=0)       
 BEGIN      
   SELECT DISTINCT            
   D.AttributeId,           
   D.ServiceID,     
   D.StatusID AS CStatusID,            
   D.AttributeName,   
   D.ServiceName,            
   D.StatusName AS CStatusName,       
   'C20Services'  AS StatusName,        
   ISNULL(@ProjectID,0) AS ProjectID,             
   D.FieldType ,              
   'Status' AttributeType ,      
   CASE WHEN D.FieldType='M' THEN 0      
   ELSE 1      
   END AS IsEnabled  ,    
   D.TicketMasterFields          
   FROM       
   #StandardAttributeStatusMaster D (NOLOCK)  
   INNER JOIN #ProjectService PS ON  D.ServiceID=PS.ServiceID  
   WHERE   
   D.ISDeleted =0      
   AND D.AttributeName NOT IN ('Planned Duration','Actual Duration')    
   AND D.FieldType='M'           
 END        
 END  
 ELSE IF(@FieldType ='O')  
 BEGIN  
 IF EXISTS (SELECT (1) FROM [AVL].[PRJ_StandardAttributeProjectStatusMaster] (NOLOCK) WHERE Projectid=@ProjectID AND ServiceID=@ServiceID   
 AND StatusID=@StatusID AND FieldType='O' AND IsDeleted=0)        
 BEGIN   
   SELECT DISTINCT       
   CASM.AttributeId,       
   CASM.ServiceID,       
   CASM.StatusID AS CStatusID,    
   CASM.AttributeName,       
   CASM.StatusName AS CStatusName,   
   CASM.ServiceName,     
   'SavedAttributes'  AS StatusName,        
   D.FieldType,       
   'Status' AttributeType ,      
   CASE WHEN  CASM.FieldType='M' THEN 0      
   ELSE 1      
   END AS IsEnabled ,    
   CASM.TicketMasterFields      
   FROM       
   #StandardAttributeStatusMaster CASM  (NOLOCK)   
   INNER JOIN #ProjectService PS (NOLOCK) ON  CASM.ServiceID=PS.ServiceID  
   LEFT JOIN [AVL].[PRJ_StandardAttributeProjectStatusMaster] D (NOLOCK)      
   ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName   
     
   WHERE    
   D.ProjectID = @ProjectID          
   AND CASM.ServiceID=@ServiceID      
   AND CASM.StatusID=@StatusID         
   AND D.ISDeleted =0          
   AND CASM.ISDeleted =0       
   AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration')    
   AND (D.FieldType='O' AND CASM.FieldType='O')   
 END      
 ELSE IF EXISTS (SELECT (1) FROM #StandardAttributeStatusMaster (NOLOCK)WHERE ServiceID=@ServiceID AND StatusID=@StatusID AND FieldType='O' AND IsDeleted=0)       
 BEGIN      
 SELECT DISTINCT            
   D.AttributeId,           
   D.ServiceID,   
   D.StatusID AS CStatusID,      
   D.AttributeName,   
   D.ServiceName,            
   D.StatusName AS CStatusName,       
   'C20Services'  AS StatusName,        
   ISNULL(@ProjectID,0) AS ProjectID,             
   D.FieldType ,              
   'Status' AttributeType ,      
   CASE WHEN D.FieldType='M' THEN 0      
   ELSE 1      
   END AS IsEnabled  ,    
   D.TicketMasterFields          
   FROM       
   #StandardAttributeStatusMaster D (NOLOCK)  
   INNER JOIN #ProjectService PS (NOLOCK) ON  D.ServiceID=PS.ServiceID  
   WHERE    
   --D.ServiceID in (select ServiceID from #ProjectService) AND       
   D.ServiceID=@ServiceID      
   AND D.StatusID=@StatusID         
   AND D.ISDeleted =0      
   AND D.AttributeName NOT IN ('Planned Duration','Actual Duration')    
   AND D.FieldType='O'           
 END        
 END  
 END  
 ELSE IF(@Type ='Download')  
 BEGIN  
   
  IF EXISTS (SELECT (1) FROM [AVL].[PRJ_StandardAttributeProjectStatusMaster] (NOLOCK) WHERE Projectid=@ProjectID  AND IsDeleted=0)        
  BEGIN    
   SELECT DISTINCT      
   CASM.ServiceName,   
   CASE WHEN CASM.AttributeName='Resolution Method' THEN 'Resolution Remarks'  
   ELSE CASM.AttributeName      
   END AS AttributeName,      
   CASM.StatusName  as [Status Name],       
   CASE WHEN CASM.FieldType='M' THEN 'M'   
    ELSE D.FieldType   
    END AS FieldType     
   FROM       
   #StandardAttributeStatusMaster CASM  (NOLOCK)   
   INNER JOIN #ProjectService PS (NOLOCK) ON  CASM.ServiceID=PS.ServiceID  
   LEFT JOIN [AVL].[PRJ_StandardAttributeProjectStatusMaster] D (NOLOCK)      
   ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName       
   WHERE      
   D.ProjectID = @ProjectID   
   AND D.ISDeleted =0          
   AND CASM.ISDeleted =0       
   AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration')    
   AND (D.FieldType='M' OR CASM.FieldType ='M')     
 UNION   
   SELECT DISTINCT    
   CASM.ServiceName,  
   CASE WHEN CASM.AttributeName='Resolution Method' THEN 'Resolution Remarks'  
   ELSE CASM.AttributeName      
   END AS AttributeName,   
   CASM.StatusName  as [Status Name],  
   D.FieldType      
   FROM       
  #StandardAttributeStatusMasterCASM  (NOLOCK)  
   INNER JOIN #ProjectService PS (NOLOCK) ON  CASM.ServiceID=PS.ServiceID  
   LEFT JOIN [AVL].[PRJ_StandardAttributeProjectStatusMaster] D (NOLOCK)      
   ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName   
   WHERE   
  
   D.ProjectID = @ProjectID          
   AND CASM.ServiceID=@ServiceID      
   AND CASM.StatusID=@StatusID         
   AND D.ISDeleted =0          
   AND CASM.ISDeleted =0      
   AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration')    
   AND (D.FieldType='O' AND CASM.FieldType='O')   
 END      
 ELSE IF EXISTS (SELECT (1) FROM [AVL].[MAS_StandardAttributeStatusMaster] (NOLOCK) WHERE IsDeleted=0)       
 BEGIN      
   SELECT DISTINCT   
   CASE WHEN D.AttributeName='Resolution Method' THEN 'Resolution Remarks'  
   ELSE D.AttributeName      
   END AS AttributeName,   
   D.ServiceName,            
   D.StatusName  as [Status Name],  
   ISNULL(@ProjectID,0) AS ProjectID,             
   D.FieldType      
   FROM       
  #StandardAttributeStatusMasterD  
   INNER JOIN #ProjectService PS (NOLOCK) ON  D.ServiceID=PS.ServiceID   
   WHERE   
   D.ISDeleted =0     
   AND D.AttributeName NOT IN ('Planned Duration','Actual Duration')    
   AND D.FieldType='M'   
 UNION  
   SELECT DISTINCT   
   CASE WHEN D.AttributeName='Resolution Method' THEN 'Resolution Remarks'  
   ELSE D.AttributeName      
   END AS AttributeName,   
   D.ServiceName,            
   D.StatusName  as [Status Name],  
   ISNULL(@ProjectID,0) AS ProjectID,             
   D.FieldType          
   FROM       
   #StandardAttributeStatusMaster D (NOLOCK)      
   INNER JOIN #ProjectService PS (NOLOCK) ON  D.ServiceID=PS.ServiceID  
   WHERE      
   D.ServiceID=@ServiceID      
   AND D.StatusID=@StatusID         
   AND D.ISDeleted =0      
   AND D.AttributeName NOT IN ('Planned Duration','Actual Duration')    
   AND D.FieldType='O'                
 END       
 END  
 END  
 SET NOCOUNT OFF; 
 END
