/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[TK_GetAttributeByService] --7,4 

@serviceid INT,
@ProjectId VARCHAR(50)
AS 
BEGIN 
BEGIN TRY
SET NOCOUNT ON;

DECLARE @TicketAttributeIntegration INT
DECLARE @IsDebt VARCHAR(5)
DECLARE @IsMainspring VARCHAR(5)
SET @TicketAttributeIntegration = (SELECT isnull(TicketAttributeIntegartion,0) AS tt FROM AVL.MAS_ProjectMaster WHERE ProjectID = @ProjectId AND IsDeleted = 0)
SET @IsDebt = (SELECT isnull(IsDebtEnabled,0) AS d FROM AVL.MAS_ProjectMaster WHERE ProjectID = @ProjectId)
SET @IsMainspring = (SELECT isnull(IsMainSpringConfigured,0) AS m FROM AVL.MAS_ProjectMaster WHERE ProjectID = @ProjectId)

PRINT @TicketAttributeIntegration
print @IsDebt
print @IsMainspring
 IF(@TicketAttributeIntegration = 1)
	BEGIN
	PRINT '1 if begin'
		IF NOT EXISTS(SELECT TOP 1 StatusName from AVL.PRJ_StandardAttributeProjectStatusMaster (NOLOCK) WHERE Projectid = @ProjectId and IsDeleted = 0) 
				BEGIN
			    	PRINT 'IN 1 IF'   
				   SELECT DISTINCT 
					  D.ServiceID, 
					  D.AttributeName, 
					  D.StatusName,
					  C.StatusName as ProjectStatusName, 
					  C.ProjectID as ProjectID,  
					  D.FieldType,
					  DS.DARTStatusName AS ValueName,
					  C.StatusName as SDValueName, 
					  'Status' AttributeType ,
					CASE WHEN D.ServiceID IN(SELECT ServiceID FROM AVL.TK_MAS_Service (NOLOCK)) THEN 'Y' ELSE 'N' END AS IsService ,  
					   D.TicketMasterFields
					FROM AVL.MAS_StandardAttributeStatusMaster D (NOLOCK) 
						LEFT JOIN AVL.TK_MAP_ProjectStatusMapping C (NOLOCK) on C.TicketStatus_ID=D.StatusID AND C.ProjectID = @ProjectId AND C.IsDeleted=0     
						LEFT JOIN AVL.TK_MAS_DARTTicketStatus DS (NOLOCK) on D.StatusID=DS.DARTStatusID   
					WHERE  D.IsDeleted = 0     
						AND DS.IsDeleted = 0  
						AND (C.IsDeleted = 0 OR C.StatusName IS NULL ) 
						AND D.ServiceID = @serviceid 
						and C.ProjectID = @ProjectId
					ORDER BY 
						AttributeType 
				END
				ELSE
				BEGIN
					PRINT 'IN 1 ELSE'  
					SELECT DISTINCT 
					 D.ServiceID, 
					 D.AttributeName, 
					 D.StatusName,
					 C.StatusName as ProjectStatusName, 
					 ISNULL(D.ProjectID,0) as ProjectID,  
					 D.FieldType ,
					 DS.DARTStatusName AS ValueName ,
					 C.StatusName as SDValueName , 
					 'Status' AttributeType ,
					CASE WHEN D.ServiceID IN(SELECT ServiceID FROM AVL.TK_MAS_Service (NOLOCK)) THEN 'Y' ELSE 'N' END AS IsService ,  
					  D.TicketMasterFields
					FROM
						AVL.PRJ_StandardAttributeProjectStatusMaster D (NOLOCK)
						LEFT JOIN AVL.TK_MAP_ProjectStatusMapping C (NOLOCK)on C.ProjectID=D.Projectid and C.TicketStatus_ID=D.StatusID AND C.IsDeleted=0
						LEFT JOIN AVL.TK_MAS_DARTTicketStatus DS (NOLOCK) on D.StatusID=DS.DARTStatusID  
					WHERE D.Projectid=@ProjectId
						AND D.IsDeleted= 0     
						AND DS.IsDeleted = 0 
						AND (C.IsDeleted=0 OR C.StatusName IS NULL ) 
						AND D.ServiceID=@serviceid
					
				END
	END
	ELSE IF(@TicketAttributeIntegration = 2)
		BEGIN
		PRINT '1 else begin'
		IF NOT EXISTS(SELECT TOP 1 StatusName from AVL.PRJ_MainspringAttributeProjectStatusMaster (NOLOCK) WHERE Projectid = @ProjectId and IsDeleted = 0) 
			BEGIN
				SELECT DISTINCT 
				  D.ServiceID, 
				  D.AttributeName, 
				  D.StatusName,
				  C.StatusName as ProjectStatusName, 
				  C.ProjectID as ProjectID,  
				  D.FieldType,
				  DS.DARTStatusName AS ValueName,
				  C.StatusName as SDValueName, 
				  'Status' AttributeType ,
				 CASE WHEN D.ServiceID IN(SELECT ServiceID FROM AVL.TK_MAS_Service (NOLOCK)) THEN 'Y' ELSE 'N' END AS IsService ,  
				   D.[TicketDetailFields]
				FROM AVL.MAS_MainspringAttributeStatusMaster D (NOLOCK) 
					LEFT JOIN AVL.TK_MAP_ProjectStatusMapping C (NOLOCK) on C.TicketStatus_ID=D.StatusID AND C.ProjectID = @ProjectId AND C.IsDeleted=0     
					LEFT JOIN AVL.TK_MAS_DARTTicketStatus DS (NOLOCK) on D.StatusID=DS.DARTStatusID   
				WHERE  D.IsDeleted= 0    
					AND DS.IsDeleted = 0
					AND (C.IsDeleted=0 OR C.StatusName IS NULL )  AND D.ServiceID=@serviceid and C.ProjectID = @ProjectId
					ORDER BY 
					AttributeType 
		
			END
			ELSE
			BEGIN	  
		
			  SELECT DISTINCT 
				 D.ServiceID, 
				 D.AttributeName, 
				 D.StatusName,
				 DS.StatusName as ProjectStatusName, 
				 ISNULL(D.ProjectID,0) as ProjectID,  
				 D.FieldType ,
				 SM.DARTStatusName AS ValueName ,
				 DS.StatusName as SDValueName , 
				 'Status' AttributeType ,
				CASE WHEN D.ServiceID IN(SELECT ServiceID FROM AVL.TK_MAS_Service (NOLOCK)) THEN 'Y' ELSE 'N' END AS IsService , 
				  D.TicketMasterFields
				FROM
					[AVL].[PRJ_MainspringAttributeProjectStatusMaster] D (NOLOCK)
					--LEFT JOIN AVL.MAS_MainspringAttributeStatusMaster C (NOLOCK)on C.ProjectID=D.Projectid and C.DARTStatusId=D.StatusID AND C.IsDeleted=0
					LEFT JOIN AVL.TK_MAP_ProjectStatusMapping DS (NOLOCK) on D.StatusID=DS.STatusID  and DS.ProjectID=D.Projectid and DS.isdeleted=0
					LEFT JOIN AVL.TK_MAS_DARTTicketStatus  SM (NOLOCK) ON SM.DARTStatusID=D.StatusID AND SM.IsDeleted=0
					Left JOIN AVL.TK_MAS_Service MS(NOLOCK) ON MS.SERVICEID=D.SERVICEID AND MS.IsDeleted=0
				WHERE D.Projectid=@ProjectId
					AND D.IsDeleted= 0     
					AND DS.IsDeleted = 0
					--AND (C.IsDeleted=0 OR C.StatusName IS NULL )   
			  AND D.ServiceID=@serviceid
			  ORDER BY 
					AttributeType 
			  						
			END
		END
		ELSE IF(@TicketAttributeIntegration = 1 AND (@IsDebt = '0' OR @IsDebt = 'Y') AND (@IsMainspring = '0' OR @IsMainspring = 'Y'))
		BEGIN
		PRINT '1 else begin'
		IF NOT EXISTS(SELECT TOP 1 StatusName from AVL.PRJ_MainspringAttributeProjectStatusMaster (NOLOCK) WHERE Projectid = @ProjectId and IsDeleted = 0) 
			BEGIN
				SELECT DISTINCT 
				  D.ServiceID, 
				  D.AttributeName, 
				  D.StatusName,
				  C.StatusName as ProjectStatusName, 
				  C.ProjectID as ProjectID,  
				  D.FieldType,
				  DS.DARTStatusName AS ValueName,
				  C.StatusName as SDValueName, 
				  'Status' AttributeType ,
				 CASE WHEN D.ServiceID IN(SELECT ServiceID FROM MAS.ServiceMaster (NOLOCK)) THEN 'Y' ELSE 'N' END AS IsService ,  
				   D.TicketDetailFields
				   --D.TicketMasterFields
				FROM AVL.MAS_MainspringAttributeStatusMaster D (NOLOCK) 
					LEFT JOIN AVL.TK_MAP_ProjectStatusMapping C (NOLOCK) on C.TicketStatus_ID=D.StatusID AND C.ProjectID = @ProjectId AND C.IsDeleted=0     
					LEFT JOIN AVL.TK_MAS_DARTTicketStatus DS (NOLOCK) on D.StatusID=DS.DARTStatusID   
				WHERE  D.IsDeleted= 0    
					AND DS.IsDeleted = 0
					AND (C.IsDeleted=0 OR C.StatusName IS NULL )  AND D.ServiceID=@serviceid and C.ProjectID = @ProjectId
					ORDER BY 
					AttributeType 
		
			END
			ELSE
			BEGIN	  
		
			  SELECT DISTINCT 
				D.ServiceID, 
				 D.AttributeName, 
				 D.StatusName,
				 DS.StatusName as ProjectStatusName, 
				 ISNULL(D.ProjectID,0) as ProjectID,  
				 D.FieldType ,
				 SM.DARTStatusName AS ValueName ,
				 DS.StatusName as SDValueName , 
				 'Status' AttributeType ,
				CASE WHEN D.ServiceID IN(SELECT ServiceID FROM MAS.ServiceMaster (NOLOCK)) THEN 'Y' ELSE 'N' END AS IsService , 
				  D.TicketMasterFields
				FROM
					MAS.MainspringAttributeProjectStatusMaster D (NOLOCK)
					LEFT JOIN AVL.TK_MAP_ProjectStatusMapping DS (NOLOCK) on D.StatusID=DS.STatusID  and DS.ProjectID=D.Projectid and DS.isdeleted=0
					LEFT JOIN AVL.TK_MAS_DARTTicketStatus  SM (NOLOCK) ON SM.DARTStatusID=D.StatusID AND SM.IsDeleted=0
					Left JOIN AVL.TK_MAS_Service MS(NOLOCK) ON MS.SERVICEID=D.SERVICEID AND MS.IsDeleted=0
				WHERE D.Projectid=@ProjectId
					AND D.IsDeleted= 0     
					AND DS.IsDeleted = 0
					--AND (C.IsDeleted=0 OR C.StatusName IS NULL )   
			  AND D.ServiceID=@serviceid
			  						
			END
		END

SET NOCOUNT OFF;
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[TK_GetAttributeByService] ', @ErrorMessage, @ProjectId,0
		
	END CATCH  



END
