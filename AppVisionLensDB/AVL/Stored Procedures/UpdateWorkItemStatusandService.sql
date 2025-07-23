/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ========================================================================================================  
-- Author      : Shobana  
-- Create date : 05 June 2020  
-- Description : Procedure to Choose Work Item Details             
-- Test        : [AVL].[UpdateWorkItemStatusandService]   
-- Revision    :  
-- Revised By  :  
-- ========================================================================================================  
CREATE PROCEDURE [AVL].[UpdateWorkItemStatusandService]  
  
     @TimeTickerID BIGINT,    
  @ProjectID BIGINT,  
  @TicketID NVARCHAR(100),             
  @StatusID BIGINT NULL,   
  @ServiceID INT NULL,        
  @EmployeeID NVARCHAR(50)   
   
AS  
BEGIN 
SET NOCOUNT ON; 
 BEGIN TRY  
 BEGIN TRAN    
  
    DECLARE @Result bit;  
    UPDATE  ADM.ALM_TRN_WorkItem_Details SET ServiceId = @ServiceID,StatusMapId = @StatusID,  
    ModifiedBy = @EmployeeID,ModifiedDate = GetDate()  
    WHERE Project_Id = @ProjectID AND WorkItemDetailsId = @TimeTickerID AND WorkItem_Id = @TicketID and ISNULL(@ServiceID,0)<>0 and ISNULL(@StatusID,0)<>0  
    
	--Updated Actual start date and Actual end date
	Declare @actualstartdate date,@actualenddate date, @Workitemstatusid int
	set @Workitemstatusid =(select Top 1 StatusId from [PP].[ALM_MAP_Status] where StatusMapId =@StatusID AND ProjectId=@ProjectID)

	if(@Workitemstatusid = 4)
	Begin
		select @actualstartdate  =(select MIN (t.TimesheetDate) from  ADM.TM_TRN_WorkItemTimesheetDetail tw
		join AVL.TM_PRJ_Timesheet  t on t.TimesheetId = tw.TimesheetId
		where tw.IsDeleted =0 AND t.ProjectId =@ProjectID AND  tw.WorkItemDetailsId =@TimeTickerID)

		set @actualenddate = (select MAX (t.TimesheetDate) from  ADM.TM_TRN_WorkItemTimesheetDetail tw
		join AVL.TM_PRJ_Timesheet  t on t.TimesheetId = tw.TimesheetId
		where tw.IsDeleted =0 AND t.ProjectId =@ProjectID AND  tw.WorkItemDetailsId =@TimeTickerID )
		
		update ADM.ALM_TRN_WorkItem_Details  set Actual_EndDate=@actualenddate ,Actual_StartDate=@actualstartdate, 
		ModifiedBy = @EmployeeID,ModifiedDate = GetDate()
		where Project_Id=@ProjectID AND WorkItemDetailsId=@TimeTickerID AND IsDeleted=0 AND Actual_EndDate is null 
		AND Actual_StartDate is null
	End

    SET @Result = 1;  
    SELECT @Result as Result;  

 COMMIT TRAN  
 END TRY  
 BEGIN CATCH  
   DECLARE @ErrorMessage VARCHAR(MAX);  
   SET @Result = 0  
   SELECT @Result as Result  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  ROLLBACK TRAN  
 EXEC AVL_InsertError '[AVL].[UpdateWorkItemStatusandService]', @ErrorMessage, 0,@EmployeeID  
    
 END CATCH;  
SET NOCOUNT OFF;    
END
