CREATE PROCEDURE [AVL].[GetDetailsAddTicket] --10337,'627384',1
	@ProjectID bigint,
	@UserID nvarchar(50),
	@supportTypeID int=null
AS
BEGIN
	BEGIN TRY
	SET NOCOUNT ON
	
	declare @AssGroupCount int,@supporttypecheck bit 
	set  @supportTypeID = case when @supportTypeID is null or @supportTypeID=0 THEN (select ISNULL(SupportTypeId,1) from AVL.MAP_ProjectConfig where ProjectID=@ProjectID)
	ELSE @supportTypeID END
	if(@supportTypeID=1 or @supportTypeID=2)
	BEGIN
	set @supporttypecheck=1

	END
	ELSE
	BEGIN
	set @supporttypecheck=0
	END

	--To get support type for the project
	SELECT SupportTypeId FROM AVL.MAP_ProjectConfig With (NOLOCK) WHERE ProjectID=@ProjectID

	set @AssGroupCount=(SELECT COUNT(AG.AssignmentGroupMapID) from AVL.UserAssignmentGroupMapping AG With (NOLOCK) 
	JOIN AVL.BOTAssignmentGroupMapping AGM (NOLOCK) ON AGM.AssignmentGroupMapID=AG.AssignmentGroupMapID AND AG.ProjectID=AGM.ProjectID AND AG.IsDeleted=0 AND AGM.IsDeleted=0
	JOIN AVL.MAS_LoginMaster LM (NOLOCK) ON LM.UserID=AG.UserID AND LM.ProjectID=AG.ProjectID AND AG.IsDeleted=0 AND LM.IsDeleted=0
	
	 where AG.ProjectID=@ProjectID and LM.EmployeeID=@UserID AND AGM.IsBOTGroup=0 AND AGM.SupportTypeID=@supportTypeID)
   
   --if(@AssGroupCount=0)
   --BEGIN
   -- SELECT AssignmentGroupMapID,AssignmentGroupName from AVL.BOTAssignmentGroupMapping WHERE ProjectID=@ProjectID
   --END
   --ELSE
   --BEGIN
   -- SELECT BAGM.AssignmentGroupMapID,BAGM.AssignmentGroupName from AVL.UserAssignmentGroupMapping AGM
   -- join AVL.BOTAssignmentGroupMapping BAGM on BAGM.AssignmentGroupMapID=AGM.AssignmentGroupMapID
   -- where AGM.ProjectID=@ProjectID and AGM.UserID=@UserID
   --END


   SELECT agm.AssignmentGroupMapID,agm.AssignmentGroupName from  AVL.UserAssignmentGroupMapping
ag With (NOLOCK) JOIN AVL.MAS_LoginMaster LG (NOLOCK) ON
LG.ProjectID=AG.ProjectID AND LG.IsDeleted=0 AND LG.UserID=ag.UserID
AND AG.IsDeleted=0 and LG.EmployeeID=@UserID and ag.ProjectID=@ProjectID

RIGHT JOIN AVL.BOTAssignmentGroupMapping AGM (NOLOCK) ON AGM.AssignmentGroupMapID=AG.AssignmentGroupMapID AND AGM.IsDeleted=0 
WHERE ((@AssGroupCount>0 and ag.ID is NOT NULL) OR (@AssGroupCount=0 AND ((@supporttypecheck=1 AND agm.SupportTypeID=@supportTypeID) OR(@supporttypecheck=0)))) and agm.ProjectID=@ProjectID 
AND AGM.IsBOTGroup=0 
and agm.IsDeleted=0


   
   --to get tower details for the project
    SELECT TPM.TowerID,TDT.TowerName FROM AVL.InfraTowerProjectMapping TPM With (NOLOCK)
    JOIN AVL.InfraTowerDetailsTransaction TDT (NOLOCK)
    ON TDT.InfraTowerTransactionID=TPM.TowerID WHERE TPM.ProjectID=@ProjectID and TPM.IsEnabled=1 and TDT.IsDeleted=0
	--TO GET Ticket Type details

	SELECT TTM.TicketTypeMappingID,TTM.TicketType,TTM.AVMTicketType,TTM.IsDefaultTicketType,TTM.SupportTypeID  from AVL.TK_MAP_TicketTypeMapping TTM With (NOLOCK) 
	
	LEFT JOIN [AVL].[TK_MAS_TicketType] TT (NOLOCK) ON TTM.AVMTicketType=TT.TicketTypeID and TT.IsDeleted=0
	
	where TTM.ProjectID=@ProjectID and TTM.IsDeleted=0 and TTM.SupportTypeID IN(@supportTypeID,3)
	and isnull(TT.TicketTypeID,0) not in(9,10,20)

	--Assignment group tower id mapping
	Select AssignmentGroupMapId,TowerId from PP.TowerAssignmentGroupMapping where ProjectId=@ProjectID and IsDeleted=0;
	SET NOCOUNT OFF
	END TRY  
	BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		
		EXEC AVL_InsertError '[AVL].[GetDetailsAddTicket]', @ErrorMessage, @UserID, @ProjectID 
		
	END CATCH  

END
