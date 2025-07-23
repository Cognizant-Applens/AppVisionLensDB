/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[DeleteAssignmentGroup] --10337,'Infra_AG',2,0,'btnDelete'
@ProjectID Varchar(20),
@AssignmentGroup nvarchar(max),
@AssignmentGroupMapID varchar(20),
@IsBoTGroup int,
@Choice varchar(30)
AS
BEGIN
BEGIN TRY
if(@Choice='btnDelete')
BEGIN
declare @IsDelete int
	
	SET @IsDelete=CASE WHEN (SELECT  TOP 1 IsDelete  FROM 
	(
	select  ( CASE WHEN COUNT(TimeTickerID)>0   THEN 0 ELSE 1 end) as IsDelete from AVL.TK_TRN_TicketDetail 
	where ProjectID=@ProjectID and AssignmentGroupID=@AssignmentGroupMapID 
	and IsDeleted=0
	UNION
	select  ( CASE WHEN COUNT(TimeTickerID)>0   THEN 0 ELSE 1 end) as IsDelete from AVL.TK_TRN_InfraTicketDetail
	 where ProjectID=@ProjectID and AssignmentGroupID=@AssignmentGroupMapID 
	and IsDeleted=0
	UNION

	select  ( CASE WHEN COUNT(TimeTickerID)>0   THEN 0 ELSE 1 end) as IsDelete from AVL.TK_TRN_BOTTicketDetail
	 where ProjectID=@ProjectID and AssignmentGroupID=@AssignmentGroupMapID 
	and IsDeleted=0
	) as A
	WHERE A.IsDelete=0
	) IS NULL THEN 1 ELSE 0 END
	
	if(@IsDelete=1)
		BEGIN
			UPDATE AVL.BOTAssignmentGroupMapping 
			set IsDeleted=1 
			where AssignmentGroupMapID=@AssignmentGroupMapID and IsDeleted=0
		END
		select @IsDelete as IsDelete

END
	update AVL.UserAssignmentGroupMapping SET IsDeleted=1 where AssignmentGroupMapID=@AssignmentGroupMapID
END TRY
  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[DeleteAssignmentGroup]', @ErrorMessage, 0,0
	END CATCH  
END
