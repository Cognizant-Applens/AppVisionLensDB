/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TK_FetchLookUpDataforTicketUpload]
@ProjectID VARCHAR(10)
AS
BEGIN

	SET NOCOUNT ON;

        --ProjectConfig            
    SELECT Uploadinactiveuser as Flag FROM [AVL].[MAP_ProjectConfig] (NOLOCK) WHERE ProjectID = @ProjectID              
    --TicketTypeMapping            
    SELECT TicketTypeMappingID, TicketType, AVMTicketType FROM [AVL].[TK_MAP_TicketTypeMapping]  (NOLOCK) WHERE IsDeleted = 0 AND ProjectID = @ProjectID            
    --TicketType            
    SELECT TicketTypeID FROM [AVL].[TK_MAS_TicketType]            
    --PriorityMaster            
    SELECT PriorityIDMapID, PriorityName FROM [AVL].[TK_MAP_PriorityMapping]  (NOLOCK) WHERE IsDeleted = 0 AND ProjectID = @ProjectID            
    --StatusMaster            
    SELECT StatusID, TicketStatus_ID, StatusName FROM [AVL].[TK_MAP_ProjectStatusMapping]  (NOLOCK) WHERE IsDeleted = 0 AND ProjectID = @ProjectID            
    --LoginMaster            
    IF EXISTS(Select IsDebtEnabled from [AVL].[MAS_ProjectMaster](NOLOCK) where ProjectID= @ProjectID and IsDebtEnabled='Y')
    BEGIN
    SELECT UserId, IsDeleted, ClientUserId FROM [AVL].[MAS_LoginMaster]  (NOLOCK) WHERE ProjectID = @ProjectID
    --UNION
    --SELECT UserID,IsDeleted,ClientUserID from PRJ.LoginMaster_External where ProjectID =  @ProjectID 
    END
    ELSE
    BEGIN
    SELECT UserId, IsDeleted, ClientUserId FROM [AVL].[MAS_LoginMaster]  (NOLOCK) WHERE ProjectID = @ProjectID
    END
    
             
    --LobTrackApplicationMapping            
    --SELECT ApplicationTrackID FROM MAP.LobTrackApplicationMapping  (NOLOCK) WHERE IsDeleted = 0 AND ProjectID = @ProjectID            
    --ApplicationMaster            
    --SELECT ApplicationID, AM.AppGroupID, RTRIM(LTRIM(ApplicationName)) AS ApplicationName, AppTrackID FROM  MAS.ApplicationMaster AM  (NOLOCK), MAP.LobTrackApplicationMapping LTAM  (NOLOCK)             
    --WHERE LTAM.ProjectID = @ProjectID AND AM.IsDeleted = 'N' AND LTAM.ApplicationTrackID = AM.AppTrackID AND LTAM.IsDeleted=0           
    --BaseView            
      --SELECT AccountProjectLobID, LOBTRACKID, APPGROUPID, APPLICATIONID, RTRIM(LTRIM(ApplicationName)) APPLICATIONNAME, ApplicationTrackID FROM Vw_AppBaseValues  WHERE ProjectID = @ProjectID   AND  ISNULL(ISAMHidden,0) = 0           
    --AttributeFieldMaster            
    --SELECT Id, AttributeType, CASE WHEN CHARINDEX('(',AttributeTypeValue) > 0                         
    --     THEN SUBSTRING(AttributeTypeValue,0,CHARINDEX('(',AttributeTypeValue))                      
    --     ELSE AttributeTypeValue END AS AttributeTypeValue FROM MAS.AttributeFieldMAster  (NOLOCK) WHERE IsDeleted = 0           
    --ProjectsourceDetails            
    SELECT SourceIDMapID, SourceName FROM [AVL].[TK_MAP_SourceMapping]  (NOLOCK) WHERE IsDeleted = 0 AND ProjectID = @ProjectID            
    --ProjectSeverityDetails            
    SELECT SeverityIDMapID, SeverityName FROM [AVL].[TK_MAP_SeverityMapping]  (NOLOCK) WHERE IsDeleted = 0 AND ProjectID = @ProjectID             
    --SSISColumnMapping            
    SELECT ServiceDartColumn, ProjectColumn FROM [AVL].[ITSM_PRJ_SSISColumnMapping]  (NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 0            
    --ProjectMaster            
    SELECT ProjectID FROM [AVL].[MAS_ProjectMaster]  (NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted =0            
    --AppGroupMaster            
    --SELECT AppGroupID FROM MAP.AppGroupMaster  (NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 'N'               
    --ServiceProjectMapping            
    SELECT CategoryID, CategoryName FROM [AVL].[TK_PRJ_ServiceProjectMapping]   (NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 0
    
    SELECT CauseID, CauseCode from [AVL].[DEBT_MAP_CauseCode](NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted =0  
    
    SELECT ResolutionID,ResolutionCode from [AVL].[DEBT_MAP_ResolutionCode](NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted =0    
    

END
