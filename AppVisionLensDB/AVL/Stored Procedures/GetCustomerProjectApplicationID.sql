/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetCustomerProjectApplicationID] --NULL,NULL,NULL,'1000180254'
@CustomerName NVARCHAR(50) = NULL,
@ProjectName NVARCHAR(50) = NULL,
@ApplicationName NVARCHAR(100) = NULL,
@EsaProjectID NVARCHAR(50) = NULL,
@PriorityName VARCHAR(500) = NULL,
@TicketType VARCHAR(500) = NULL,
@StatusName VARCHAR(500) = NULL,
@EmployeeID NVARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	

	DECLARE @ProjectID BIGINT, @CustomerID BIGINT

	SET @CustomerID = (SELECT TOP 1 CustomerID FROM AVL.Customer WHERE LTRIM(RTRIM(CustomerName)) = LTRIM(RTRIM(@CustomerName)) AND IsDeleted = 0)
	SELECT @CustomerID AS CustomerID

	SET @ProjectID = (SELECT TOP 1 ProjectID FROM AVL.MAS_ProjectMaster WHERE LTRIM(RTRIM(EsaProjectID)) = LTRIM(RTRIM(@EsaProjectID)) AND IsDeleted = 0)
	SELECT @ProjectID AS ProjectID

	SELECT TOP 1 ApplicationID FROM AVL.APP_MAS_ApplicationDetails WHERE LTRIM(RTRIM(ApplicationName)) = LTRIM(RTRIM(@ApplicationName)) AND IsActive = 1

	SELECT TOP 1 PPM.PriorityIDMapID
	FROM [AVL].[TK_MAP_PriorityMapping] PPM 
	LEFT  JOIN [AVL].[TK_MAS_Priority] PM 
	ON PPM.PriorityID=PM.PriorityID AND PM.IsDeleted=0 
	where PPM.ProjectID=@ProjectID AND PPM.IsDeleted=0 and PPM.PriorityIDMapID IS NOT NULL AND LTRIM(RTRIM(PPM.PriorityName)) = LTRIM(RTRIM(@PriorityName))

	select TOP 1 TTM.TicketTypeMappingID
	from [AVL].[TK_MAP_TicketTypeMapping] TTM 
	INNER JOIN AVL.MAP_ProjectConfig PC ON PC.ProjectID=TTM.ProjectID
	LEFT JOIN [AVL].[TK_MAS_TicketType] TT ON TTM.AVMTicketType=TT.TicketTypeID and TT.IsDeleted=0
	where TTM.ProjectID=@ProjectID  and TTM.IsDeleted=0 AND TTM.TicketTypeMappingID IS NOT NULL
	and isnull(TT.TicketTypeID,0) not in(9,10,20) AND 
	CASE WHEN PC.SupportTypeId=3 AND (TTM.SupportTypeID IN (1,2,3)) THEN 1
	WHEN PC.SupportTypeId=2 AND TTM.SupportTypeID =2 THEN 1
	WHEN PC.SupportTypeId=1 AND TTM.SupportTypeID =1 THEN 1
	ELSE 0
	END=1 AND LTRIM(RTRIM(TTM.TicketType)) = LTRIM(RTRIM(@TicketType))

	select TOP 1 StatusID
	from [AVL].[TK_MAP_ProjectStatusMapping] PSM
	INNER join [AVL].[TK_MAS_DARTTicketStatus] DTS 
	ON PSM.TicketStatus_ID=DTS.DARTStatusID 
	where PSM.ProjectID=@ProjectID and DTS.IsDeleted=0 AND PSM.IsDeleted=0 AND PSM.StatusID IS NOT NULL AND LTRIM(RTRIM(StatusName)) = LTRIM(RTRIM(@StatusName))
	ORDER BY StatusName

	select TOP 1 TicketStatus_ID 
	from [AVL].[TK_MAP_ProjectStatusMapping] PSM
	INNER join [AVL].[TK_MAS_DARTTicketStatus] DTS 
	ON PSM.TicketStatus_ID=DTS.DARTStatusID 
	where PSM.ProjectID=@ProjectID and DTS.IsDeleted=0 AND PSM.IsDeleted=0 AND PSM.StatusID IS NOT NULL AND LTRIM(RTRIM(StatusName)) = LTRIM(RTRIM(@StatusName))
	ORDER BY DTS.DARTStatusName

	select distinct 
	ISNULL(LM.UserID,0) as UserID
	from AVL.MAS_LoginMaster LM
	join AVL.MAS_ProjectMaster PM ON PM.ProjectID=LM.ProjectID
	join AVL.Customer Cust on LM.CustomerID=Cust.CustomerID
	left JOIN PP.ScopeOfWork SW ON SW.ProjectID = LM.ProjectID AND ISNULL(SW.IsDeleted,0)=0
	LEFT join AVL.RoleMaster RM on LM.RoleID=RM.RoleID
	LEFT join AVL.MAS_TimeZoneMaster TZM on LM.TimeZoneId=TZM.TimeZoneID
	left join  [AVL].[MAP_ProjectConfig] PC ON TZM.TimeZoneId=PC.TimeZoneID
	where LTRIM(RTRIM(LM.EmployeeID)) = LTRIM(RTRIM(@EmployeeID)) and LM.IsDeleted=0 
	and LM.CustomerID=@CustomerID AND LM.ProjectID = @ProjectID
   
END
