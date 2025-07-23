/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[SearchticketSampele]
	 @daterangebegin DATETIME ,      
 @daterangeend DATETIME ,      
 @ProjectID INT ,      
 @req NVARCHAR(MAX) ,      
 @AssignedTo NVARCHAR(MAX) ,           
 @applicationID NVARCHAR(MAX) ,      
 @create_date_begin DATETIME ,      
 @create_date_end DATETIME ,      
 @StatusIDs NVARCHAR(MAX),
 @IsDARTTicket INT 
--@TimesheetDate DATETIME            
AS       
BEGIN           
BEGIN TRY  
SET NOCOUNT ON;      
    
 DECLARE @datebegin DATETIME         
 DECLARE @dateend DATETIME          
 DECLARE @flgDate INT          
 DECLARE @closebegin DATETIME        
 DECLARE @closeend DATETIME            
 DECLARE @flgendDate INT         
 DECLARE @flag INT     
   SET @req = REPLACE(REPLACE(REPLACE(@req, '[', '[[]'), '_', '[_]'), '%', '[%]')          
    
 IF(@daterangebegin<>'' AND @daterangeend<>'')        
  BEGIN        
   SET @closebegin=CONVERT(DATETIME,@daterangebegin) + '00:00:00'        
   SET @closeend=CONVERT(DATETIME,@daterangeend) + '23:59:59'        
   SET @flgendDate=1        
  END        
 ELSE        
  BEGIN        
   IF(@daterangebegin='' AND @daterangeend='')        
    BEGIN        
     SET @closebegin=NULL;        
     SET @closeend=NULL;        
     SET @flgendDate=4        
    END        
  END        
    
 IF ( @create_date_begin <> '' AND @create_date_end <> '')       
  BEGIN        
   SET @datebegin = CONVERT(DATETIME, @create_date_begin)      
   + '00:00:00'            
   SET @dateend = CONVERT(DATETIME, @create_date_end)      
   + '23:59:59'        
   SET @flgDate = 1        
  END        
      
 ELSE IF ( @create_date_begin = '' AND @create_date_end = '')       
  BEGIN        
   SET @datebegin = NULL;        
   SET @dateend = NULL;        
   SET @flgDate = 4        
  END         
       
  IF (@applicationID <> '')     
   SET @flag = 1                                    
  ELSE     
   SET @flag = 2          
    
	select  Distinct
	TD.AssignedTo as UserID,
	TD.ProjectID as ProjectID,
	TD.ApplicationID as ApplicationID,
	TD.TicketID,TD.TicketDescription as TicketDescription,
	TSD.ServiceId as ServiceID,
	MASS.ServiceName as ServiceName,
	TSD.CategoryId as CategoryId,
	TSD.ActivityId as ActivityId,
	
	TD.TicketStatusMapID as StatusID,
	TD.TicketTypeMapID AS TicketTypeMapID,
	DTS.DARTStatusName as StatusName,
	TD.EffortTillDate as EffortTillDate,
	TD.ActualEffort as ITSMEffort,
	PM.IsMainSpringConfigured as IsMainSpringConfig,
	PM.IsDebtEnabled as IsDebtEnabled
	--TS.TimeSheetDate,
	--TS.StatusId as IsSaveOrSubmit
	from AVL.TK_TRN_TicketDetail TD
	
	left join  AVL.TM_TRN_TimesheetDetail TSD  on TD.TicketID=TSD.TicketID
	left join AVL.TM_PRJ_Timesheet TS on TSD.TimesheetId=TS.TimesheetId
	left join AVL.TK_MAS_Service MASS on TD.ServiceID=MASS.ServiceID
	left join [AVL].[TK_MAS_DARTTicketStatus] DTS on TD.TicketStatusMapID=DTS.DARTStatusID
	left join AVL.MAS_ProjectMaster PM on TD.ProjectID= PM.ProjectID 
	left join AVL.TK_PRJ_ServiceProjectMapping SPM on SPM.ServiceID=TD.ServiceID and SPM.ProjectID=TD.ProjectID
	WHERE PM.IsDeleted = 0

	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError ' [dbo].[SearchticketSampele] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  
	END
