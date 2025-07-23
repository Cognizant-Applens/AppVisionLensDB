/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE  PROCEDURE [AVL].[GetMandatoryAttributes_Mainspring] --4,53,6,'M','Mandatory'
@ProjectID INT   ,        
@ServiceID INT   ,    
@StatusID INT,  
@FieldType VARCHAR(10),  
@Type VARCHAR(20)
AS     
BEGIN  
 SET NOCOUNT ON;
	CREATE TABLE #ProjectService(ServiceID INT)
	IF NOT EXISTS(SELECT (1) FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster]  WHERE Projectid = @ProjectID)
	BEGIN
		EXEC [AVL].[InsertTicketAttributeToProject_NewProjectInsert_Mainspring] @ProjectID
	END
		
	DECLARE @IsMainspring Char(1)
	SET @IsMainspring = (SELECT ISNULL(IsMainSpringConfigured,'N') FROM [AVL].[MAS_ProjectMaster](NOLOCK) WHERE ProjectID=@ProjectID)	
	IF(@IsMainspring='Y')
	BEGIN
		INSERT INTO #ProjectService
		 SELECT DISTINCT ServiceID  FROM [AVL].[TK_PRJ_ProjectServiceActivityMapping] PSA INNER JOIN [AVL].[TK_MAS_ServiceActivityMapping] MSM 
		 ON PSA.ServiceMapID = MSM.ServiceMappingID AND MSM.IsDeleted = 0
		 and PSA.IsMainspringData = 'Y' and (PSA.IsHidden = 0 or PSA.IsHidden IS NULL)
		 WHERE PSA.ProjectID = @ProjectID and PSA.IsDeleted = 0 
		--SELECT DISTINCT ServiceID  FROM avl.TK_PRJ_ProjectServiceActivityMapping  WHERE ProjectID = 4 and IsDeleted = 0 and IsMainspringData = 'Y' 
		--and (IsHidden = 0 or IsHidden IS NULL)
	END
	ELSE
	BEGIN
		INSERT INTO #ProjectService 
		 SELECT DISTINCT ServiceID FROM [AVL].[TK_PRJ_ProjectServiceActivityMapping] PSA INNER JOIN [AVL].[TK_MAS_ServiceActivityMapping] MSM 
		 ON PSA.ServiceMapID = MSM.ServiceMappingID AND MSM.IsDeleted = 0
		 and (PSA.IsHidden = 0 or PSA.IsHidden IS NULL)
		 WHERE PSA.ProjectID = @ProjectID and PSA.IsDeleted = 0 
	 	--SELECT DISTINCT ServiceID  FROM avl.TK_PRJ_ProjectServiceActivityMapping  WHERE ProjectID = @ProjectID and IsDeleted = 0  and (IsHidden = 0 or IsHidden IS NULL)
	END
	DECLARE @isdebt Char
	SET @isdebt=(select ISNULL(IsDebtEnabled,'N') FROM [AVL].[MAS_ProjectMaster](NOLOCK) WHERE ProjectID=@ProjectID)
 
	-- to get the mainspring attributes
	SELECT * INTO #MainspringAttributeStatusMaster FROM [AVL].[MAS_MainspringAttributeStatusMaster]



 IF @isdebt= 'Y'
	 BEGIN
		 DECLARE @NatureOfTicket INT;
		 DECLARE @KEDBPath INT;
		 SET @NatureOfTicket=(SELECT ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping]
							  WHERE ColumnID=7 AND ProjectID=@ProjectID AND IsActive=0)
		 --SET @KEDBPath=(SELECT ColumnID FROM [AVL].[DEBT_PRJ_HealProjectPatternColumnMapping]
			--				  WHERE ColumnID=9 AND ProjectID=@ProjectID AND IsActive=0)
		 IF @NatureOfTicket>0
			 BEGIN
				 UPDATE #MainspringAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=37
			 END
		 --IF @KEDBPath >0
			-- BEGIN
			--	UPDATE #MainspringAttributeStatusMaster SET FieldType='M' WHERE StatusID=8 AND AttributeID=53
			-- END
	END
 
 IF(@Type ='Mandatory')
 BEGIN
 IF(@FieldType ='M')
 BEGIN
	 IF EXISTS (SELECT (1) FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] (NOLOCK) WHERE Projectid=@ProjectID AND FieldType='M' AND IsDeleted=0)      
	 BEGIN  		 
		IF(@isdebt='N')
			BEGIN
				SELECT DISTINCT     
				CASM.AttributeId,     
				CASM.ServiceID, 
				CASM.StatusID AS CStatusID,      
				CASM.AttributeName,     
				CASM.StatusName AS CStatusName, 
				CASM.ServiceName,   
				'SavedAttributes'  AS StatusName,      
				D.FieldType ,      
				'Status' AttributeType ,    
				CASE WHEN CASM.FieldType='M' THEN 0    
				ELSE 1    
				END AS IsEnabled ,  
				CASM.TicketDetailFields    
				FROM     
				#MainspringAttributeStatusMaster CASM  (NOLOCK) 
				INNER JOIN #ProjectService PS ON  CASM.ServiceID=PS.ServiceID
				LEFT JOIN [AVL].[PRJ_MainspringAttributeProjectStatusMaster] D (NOLOCK)    
				ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName 	  
				WHERE      
				D.ProjectID = @ProjectID
				AND D.ISDeleted =0        
				AND CASM.ISDeleted =0     
				AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration','Release Date')  
				AND D.FieldType='M'		   
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
				D.FieldType ,      
				'Status' AttributeType ,    
				CASE WHEN CASM.FieldType='M' THEN 0    
				ELSE 1    
				END AS IsEnabled ,  
				CASM.TicketDetailFields    
				FROM     
				#MainspringAttributeStatusMaster CASM  (NOLOCK) 
				INNER JOIN #ProjectService PS ON  CASM.ServiceID=PS.ServiceID
				LEFT JOIN [AVL].[PRJ_MainspringAttributeProjectStatusMaster] D (NOLOCK)    
				ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName 	  
				WHERE      
				D.ProjectID = @ProjectID
				AND D.ISDeleted =0        
				AND CASM.ISDeleted =0     
				AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration','Release Date')  
				AND D.FieldType='M' 
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
				D.FieldType ,      
				'Status' AttributeType ,    
				0 AS IsEnabled ,  
				CASM.TicketDetailFields    
				FROM     
				#MainspringAttributeStatusMaster CASM  (NOLOCK) 
				INNER JOIN #ProjectService PS ON  CASM.ServiceID=PS.ServiceID
				LEFT JOIN [AVL].[PRJ_MainspringAttributeProjectStatusMaster] D (NOLOCK)    
				ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName 	  
				WHERE      
				D.ProjectID = @ProjectID
				AND D.ISDeleted =0        
				AND CASM.ISDeleted =0     
				AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration','Release Date')  
				AND D.FieldType='M' 
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
		  D.TicketDetailFields        
		  FROM     
		  #MainspringAttributeStatusMaster D (NOLOCK)
		  INNER JOIN #ProjectService PS ON  D.ServiceID=PS.ServiceID
		  WHERE 
		  D.ISDeleted =0    
		  AND D.AttributeName NOT IN ('Planned Duration','Actual Duration','Release Date')  
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
		  D.FieldType ,   
		  'Status' AttributeType ,    
		  CASE WHEN CASM.FieldType='M' THEN 0    
		  ELSE 1    
		  END AS IsEnabled ,  
		  CASM.TicketDetailFields    
		  FROM     
		  #MainspringAttributeStatusMaster CASM  (NOLOCK) 
		  INNER JOIN #ProjectService PS ON  CASM.ServiceID=PS.ServiceID
		  LEFT JOIN MAS.MainspringAttributeProjectStatusMaster D (NOLOCK)    
		  ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.StatusName=D.StatusName
		  WHERE      
		  D.ProjectID = @ProjectID        
		  AND CASM.ServiceID=@ServiceID    
		  AND CASM.StatusID=@StatusID       
		  AND D.ISDeleted =0        
		  AND CASM.ISDeleted =0     
		  AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration','Release Date')  
		  AND D.FieldType='O'    
		END    
		ELSE IF EXISTS (SELECT (1) FROM #MainspringAttributeStatusMaster (NOLOCK)WHERE ServiceID=@ServiceID AND StatusID=@StatusID AND FieldType='O' AND IsDeleted=0)     
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
		  D.TicketDetailFields        
		  FROM     
		  #MainspringAttributeStatusMaster D (NOLOCK) 
		  INNER JOIN #ProjectService PS ON  D.ServiceID=PS.ServiceID
		  WHERE     
		  D.ServiceID=@ServiceID    
		  AND D.StatusID=@StatusID       
		  AND D.ISDeleted =0   
		  AND D.AttributeName NOT IN ('Planned Duration','Actual Duration','Release Date')  
		  AND D.FieldType='O'         
		END      
	END
 END 

  ELSE IF(@Type ='Download')
 BEGIN 
	 IF EXISTS (SELECT (1) FROM MAS.MainspringAttributeProjectStatusMaster (NOLOCK) WHERE Projectid=@ProjectID  AND IsDeleted='N')      
	 BEGIN  
	  SELECT  DISTINCT  
	  CASM.ServiceName, 
	  CASE WHEN CASM.AttributeName='Resolution Method' THEN 'Resolution Remarks'
	  ELSE CASM.AttributeName    
	  END AS AttributeName, 
	  CASM.StatusName as [Status Name],    
	  D.FieldType    
	  FROM     
	  #MainspringAttributeStatusMaster CASM  (NOLOCK) 
	  INNER JOIN #ProjectService PS ON  CASM.ServiceID=PS.ServiceID
	  LEFT JOIN MAS.MainspringAttributeProjectStatusMaster D (NOLOCK)    
	  ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.C20StatusName=D.C20StatusName  
	  WHERE    
	  D.ProjectID = @ProjectID 
	  AND D.ISDeleted =0        
	  AND CASM.ISDeleted =0     
	  AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration','Release Date')  
	  AND D.FieldType='M'    
	  UNION 
	  SELECT   DISTINCT   
	  CASM.ServiceName, 
	  CASE WHEN CASM.AttributeName='Resolution Method' THEN 'Resolution Remarks'
	  ELSE CASM.AttributeName  END AS AttributeName,   
	  CASM.StatusName as [Status Name],  
	  D.FieldType     
	  FROM     
	  #MainspringAttributeStatusMaster CASM  (NOLOCK) 
	  INNER JOIN #ProjectService PS ON  CASM.ServiceID=PS.ServiceID
	  LEFT JOIN MAS.MainspringAttributeProjectStatusMaster D (NOLOCK)    
	  ON CASM.AttributeId=D.AttributeId AND CASM.ServiceID=D.ServiceID AND CASM.C20StatusName=D.C20StatusName
	  WHERE     
	  D.ProjectID = @ProjectID        
	  AND CASM.ServiceID=@ServiceID    
	  AND CASM.StatusID=@StatusID       
	  AND D.ISDeleted =0        
	  AND CASM.ISDeleted =0     
	  AND CASM.AttributeName NOT IN ('Planned Duration','Actual Duration','Release Date')  
	  AND D.FieldType='O' 
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
	  INNER JOIN #ProjectService PS ON  D.ServiceID=PS.ServiceID
	  WHERE 
	  D.ISDeleted =0   
	  AND D.AttributeName NOT IN ('Planned Duration','Actual Duration','Release Date')  
	  AND D.FieldType='M' 
	  UNION
	  SELECT  DISTINCT 
	  D.ServiceName,  
	  CASE WHEN D.AttributeName='Resolution Method' THEN 'Resolution Remarks'
	  ELSE D.AttributeName  END AS AttributeName, 	            
	  D.StatusName as [Status Name],            
	  D.FieldType          
	  FROM     
	  #MainspringAttributeStatusMaster D (NOLOCK)    
	  INNER JOIN #ProjectService PS ON  D.ServiceID=PS.ServiceID
	  WHERE   
	  D.ServiceID=@ServiceID    
	  AND D.StatusID=@StatusID       
	  AND D.ISDeleted =0    
	  AND D.AttributeName NOT IN ('Planned Duration','Actual Duration','Release Date')  
	  AND D.FieldType='O'              
	END     
 END
 SET NOCOUNT OFF;  
END
