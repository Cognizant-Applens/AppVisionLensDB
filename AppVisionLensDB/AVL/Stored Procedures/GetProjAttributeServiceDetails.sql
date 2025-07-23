/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetProjAttributeServiceDetails] --51469  

 @projectid INT      

AS  
BEGIN 
    SET NOCOUNT ON; 
    --DECLARE @IsMainspringConfig CHAR;  
    --SET @IsMainspringConfig=(SELECT IsMainSpringConfigured FROM [AVL].[MAS_ProjectMaster]   
    --     WHERE ProjectID=@projectid)
    --DECLARE @TicketAttributeIntegartion INT
    --SET @TicketAttributeIntegartion = (SELECT TicketAttributeIntegartion FROM [AVL].[MAS_ProjectMaster]
    --     WHERE ProjectID=@projectid)

 --  IF(@TicketAttributeIntegartion = 1)
	--BEGIN --Normal Flow Start
		 SELECT       
                MSM.ServiceID ,
                MSM.ServiceName ,
               MSM.ServiceShortName  
        FROM    [AVL].[TK_PRJ_ProjectServiceActivityMapping] SPM   
		--INNER JOIN [AVL].[TK_MAS_ServiceMaster] CS ON SPM.ServiceName=CS.ServiceName 
		INNER JOIN [AVL].[TK_MAS_ServiceActivityMapping] MSM ON MSM.ServiceMappingID = SPM.ServiceMapID AND MSM.IsDeleted = 0
        WHERE   SPM.ProjectID = @projectid  
                AND SPM.IsDeleted = 0  
                AND MSM.ServiceID <> 41
				AND (SELECT COUNT(*) 
					 FROM [AVL].[TK_PRJ_ProjectServiceActivityMapping] B
					 join [AVL].[TK_MAS_ServiceActivityMapping] A 
					 ON A.ServiceMappingID=B.ServiceMapID
					 WHERE 
							A.ServiceID=MSM.ServiceID and 
							B.ProjectID=SPM.ProjectID
							AND B.IsDeleted = 0 
							AND ISNULL(B.IsHidden,0)=0)>0
                GROUP BY MSM.ServiceID , 
                MSM.ServiceName ,   
                MSM.ServiceShortName  
        ORDER BY MSM.ServiceName 
		--END  --Normal Flow End
		--ELSE
		--BEGIN --Mainspring flow Start
		--SELECT @TicketAttributeIntegartion
	--	IF(@IsMainspringConfig='Y')
	--	BEGIN
	--	 SELECT      
	--				MSM.ServiceID ,  
	--				MSM.ServiceName ,  
	--				MSM.ServiceName as ServiceShortName   
	--		FROM    [AVL].[TK_PRJ_ProjectServiceActivityMapping] SPM
	--		INNER JOIN [AVL].[TK_MAS_ServiceActivityMapping]  MSM ON MSM.ServiceMappingID = SPM.ServiceMapID AND MSM.IsDeleted = 0
	--		INNER JOIN [AVL].[MAS_MainspringAttributeStatusMaster] CS ON MSM.ServiceName=CS.ServiceName 
	--		WHERE   SPM.ProjectID = @projectid  
	--				AND SPM.IsDeleted = 0  
	--				AND MSM.ServiceID <> 41
	--				AND (SELECT COUNT(*) 
	--					 FROM [AVL].[TK_PRJ_ProjectServiceActivityMapping]
	--					 WHERE 
	--							CS.ServiceID=MSM.ServiceID
	--							AND ProjectID=SPM.ProjectID
	--							AND IsMainspringData='Y'
	--							AND IsDeleted = 0
	--							AND ISNULL(IsHidden,0)=0)>0
	--							AND SPM.IsMainspringData='Y'
	--				GROUP BY MSM.ServiceID , 
	--				MSM.ServiceName    
	--		ORDER BY MSM.ServiceName  
	--	END
	--	ELSE
	--	BEGIN		
	--	 SELECT     
	--				MSM.ServiceID ,   
	--				MSM.ServiceName ,  
	--				MSM.ServiceName as ServiceShortName  
	--		FROM    [AVL].[TK_PRJ_ProjectServiceActivityMapping] SPM
	--		INNER JOIN [AVL].[TK_MAS_ServiceActivityMapping]  MSM ON MSM.ServiceMappingID = SPM.ServiceMapID AND MSM.IsDeleted = 0    
	--		INNER JOIN [AVL].[MAS_MainspringAttributeStatusMaster] CS ON MSM.ServiceName=CS.ServiceName 
	--		WHERE   SPM.ProjectID = @projectid    
	--				AND SPM.IsDeleted = 0    
	--				AND MSM.ServiceID <> 41
	--				AND (SELECT COUNT(*) 
	--					 FROM [AVL].[TK_PRJ_ProjectServiceActivityMapping]
	--					 WHERE 
	--						CS.ServiceID=MSM.ServiceID
	--							AND ProjectID=SPM.ProjectID
	--							AND IsDeleted = 0 
	--							AND ISNULL(IsHidden,0)=0)>0
	--				GROUP BY MSM.ServiceID ,  
	--				MSM.ServiceName   
	--		ORDER BY MSM.ServiceName  
	--	END
	--END

       

SET NOCOUNT OFF;      

END
