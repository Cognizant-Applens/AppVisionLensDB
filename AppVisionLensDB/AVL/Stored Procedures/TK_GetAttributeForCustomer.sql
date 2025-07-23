/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[TK_GetAttributeForCustomer] --7,4 

@StatusID INT
  
AS 
BEGIN 
BEGIN TRY
SET NOCOUNT ON;

Select SM.DARTStatusID, SM.DARTStatusName ,D.FieldType,D.TicketDetailFields,'Status' AttributeType  from [AVL].[MAS_TicketTypeStatusAttributeMaster] D

LEFT JOIN AVL.TK_MAS_DARTTicketStatus  SM (NOLOCK) on SM.DARTStatusID=D.StatusID   and D.isdeleted=0

AND D.IsDeleted= 0     

	where D.StatusID=@StatusID
				--D.ServiceID, 
				-- D.AttributeName, 
				-- D.StatusName,
				-- DS.StatusName as ProjectStatusName, 
				-- ISNULL(D.ProjectID,0) as ProjectID,  
				-- D.FieldType ,
				-- SM.DARTStatusName AS ValueName ,
				-- DS.StatusName as SDValueName , 
				-- 'Status' AttributeType ,
				--CASE WHEN D.ServiceID IN(SELECT ServiceID FROM MAS.ServiceMaster (NOLOCK)) THEN 'Y' ELSE 'N' END AS IsService , 
				--  D.TicketMasterFields
				--FROM
				--	[AVL].[MAS_TicketTypeStatusAttributeMaster] D (NOLOCK)
				--	LEFT JOIN AVL.TK_MAP_ProjectStatusMapping DS (NOLOCK) on D.StatusID=DS.STatusID  and DS.ProjectID=D.Projectid and DS.isdeleted=0
				--	LEFT JOIN AVL.TK_MAS_DARTTicketStatus  SM (NOLOCK) ON SM.DARTStatusID=D.StatusID AND SM.IsDeleted=0
				--	Left JOIN AVL.TK_MAS_Service MS(NOLOCK) ON MS.SERVICEID=D.SERVICEID AND MS.IsDeleted=0
				--WHERE D.Projectid=@ProjectId
				--	AND D.IsDeleted= 0     
				--	AND DS.IsDeleted = 0
				--	--AND (C.IsDeleted=0 OR C.StatusName IS NULL )   
			 -- AND D.ServiceID=@serviceid
			  						
			--END
		
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		---EXEC AVL_InsertError '[AVL].[TK_GetAttributeByService] ', @ErrorMessage, @ProjectId,0
		
	END CATCH  



END
