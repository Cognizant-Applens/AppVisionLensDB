CREATE Procedure [dbo].[UpdateAprroveTicketsByTicketID]  
(  
@ticketDetails UpdateApproveTicketListDetails READONLY  
)  
AS  
BEGIN  
 SET NOCOUNT ON;    
 DECLARE @result bit  
  
 SELECT TD.TicketID,TD.DebtClassificationMapID,TD.ResolutionCodeMapID,TD.CauseCodeMapID,TD.ResidualDebtMapID,TD.AvoidableFlag,LN.UserID INTO #Temp   
     FROM @ticketDetails TD  
  JOIN [AVL].[MAS_LoginMaster] LN ON LN.EmployeeID=TD.AssignedTo  
  BEGIN TRY  
   BEGIN TRANSACTION  
  
     UPDATE [AVL].[TK_TRN_TicketDetail_Debt] SET AssignedTo=NULLIF(t2.UserID,0),  
    DebtClassificationMapID=NULLIF(t2.DebtClassificationMapID,0),ResolutionCodeMapID=NULLIF(t2.ResolutionCodeMapID,0),CauseCodeMapID=NULLIF(t2.CauseCodeMapID,0),ResidualDebtMapID=NULLIF(t2.ResidualDebtMapID,0),AvoidableFlag=NULLIF(t2.AvoidableFlag,0),
	AssignedTo=NULLIF(t2.AssignedTo,0),  
    LastUpdatedDate=getdate()  
          FROM [AVL].[TK_TRN_TicketDetail_Debt] t1  
     JOIN #Temp t2 ON t1.AssignedTo=t2.UserID  
    
  
 COMMIT TRANSACTION  
   SET @result= 1  
     END TRY  
  
  BEGIN CATCH  
       IF @@TRANCOUNT > 0  
      BEGIN  
      ROLLBACK TRANSACTION  
      SET @result= 0   
      END  
  END CATCH  
  
  SELECT @result AS RESULT  
  DROP TABLE #Temp  
    SET NOCOUNT OFF;   
END
