/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
-- declare @ticketDetails UpdateApproveTicketList    
-- insert into @ticketDetails(TicketID,DebtClassificationMapID,ResolutionCodeMapID,ResidualDebtMapID,CauseCodeMapID,AvoidableFlag,AssignedTo,    
--EmployeeID,FlexField1,FlexField2,FlexField3,FlexField4,IsFlexField1Modified,IsFlexField2Modified,IsFlexField3Modified,IsFlexField4Modified)    
--values('test06242019',1,2,2,2,2,'687591','687591','El servicio gratuito de Applens traduce instantáneamente palabras, frases y páginas web entre el inglés y más de 100 idiomas diferentes.',    
--'try','ytry','El servicio gratuito de Applens traduce instantáneamente palabras, frases y páginas web entre el inglés y más de 100 idiomas diferentes.','1','0','0','1')    
--EXEC [dbo].[UpdateApproveTicketsByTicketID] '687591',10337,@ticketDetails    
CREATE Procedure [dbo].[UpdateApproveTicketsByTicketID]     
(    
@EmployeeID Varchar(100),    
@ProjectID BigInt,    
@ticketDetails UpdateApproveTicketList READONLY    
)    
AS    
BEGIN    
BEGIN TRY    
SET NOCOUNT ON;      
DECLARE @result bit    
DECLARE @AlgorithmKey nvarchar(6);      
  SET @AlgorithmKey =ISNULL( (SELECT AlgorithmKey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE ProjectId =@PROJECTID AND ISNULL(IsActiveTransaction,0)=1 AND IsDeleted=0 AND SupportTypeId=1),'AL002')    
IF(@AlgorithmKey='AL001')    
BEGIN    
 EXEC [dbo].[UpdateApproveTicketsByTicketIDAlgoone] @EmployeeID,@ProjectID,@ticketDetails    
END    
ELSE BEGIN    
 EXEC [dbo].[UpdateApproveTicketsByTicketIDAlgotwo] @EmployeeID,@ProjectID,@ticketDetails    
END    
SET NOCOUNT OFF;    
END TRY      
BEGIN CATCH      
  IF @@TRANCOUNT > 0    
      BEGIN    
      ROLLBACK TRAN    
      SET @result= 0     
      END    
  DECLARE @ErrorMessage VARCHAR(MAX);    
      
  SELECT @ErrorMessage = ERROR_MESSAGE()     
  print @ErrorMessage     
  --INSERT Error        
  EXEC AVL_InsertError 'UpdateApproveTicketsByTicketID', @ErrorMessage, 0,0    
      
 END CATCH      
END
