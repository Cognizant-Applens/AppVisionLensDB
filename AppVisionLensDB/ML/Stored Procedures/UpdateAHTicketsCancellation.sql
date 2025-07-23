CREATE procedure [ML].[UpdateAHTicketsCancellation]  --1,136408          
@SupportTypeId Int,            
@ProjectId BIGINT            
AS            
BEGIN      
Insert Into AVL.Errors(CustomerID, ErrorSource, ErrorDescription, CreatedBy, CreatedDate)  
Values(@ProjectId,'UpdateAHTicketsCancellation','CancelTicket called', 'LearningWeb',GETDATE())  
Declare @Reasonforcancellation nvarchar(50)            
          
SET @Reasonforcancellation = (select ReasonforCancellation from avl.Debt_MAS_ReasonforCancellation where id=7)            
------------------------------------------------------------------------            
Begin Transaction  
If (@SupportTypeId = 1)          
begin          
 Update HTD            
 set ReasonForCancellation= (select ReasonforCancellation from avl.Debt_MAS_ReasonforCancellation where id=7),            
 Comments = 'Auto Cancelled by System due to Incorrect grouping done by old logic',            
 IsMandatory= 1,  
 HTD.DARTStatusID= 5,  
 ModifiedDate = GETDATE(),            
 ModifiedBy='System',            
 CancellationDate=GETDATE()            
  
 FROM [AVL].[DEBT_TRN_HealTicketDetails]  HTD         
 INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPD        
 ON HTD.ProjectPatternMapID = HPD.ProjectPatternMapID        
 WHERE HPD.ProjectID=@ProjectId and HTD.IsDeleted=0 and HPD.IsDeleted=0   and HTD.DARTStatusID IN (12)     
            
end          
else          
begin          
 Update [AVL].[DEBT_TRN_InfraHealTicketDetails]            
 set ReasonForCancellation= @Reasonforcancellation,            
 Comments = 'Auto Cancelled by System due to Incorrect grouping done by old logic',            
 IsMandatory= 1,            
 ModifiedDate = GETDATE(),            
 ModifiedBy='System',            
 CancellationDate=GETDATE(),            
 DARTStatusID=5          
 FROM [AVL].[DEBT_TRN_InfraHealTicketDetails] HTD         
 INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] HPD        
 ON HTD.ProjectPatternMapID = HPD.ProjectPatternMapID        
 WHERE HPD.ProjectID=@ProjectId and HTD.IsDeleted=0 and HPD.IsDeleted=0        
 and HTD.DARTStatusID IN (12)          
end          
-------------------------------------------------------------------------            
If (@SupportTypeId = 1)          
 begin          
 update HPD            
 set            
 ModifiedBy='System',            
 ModifiedDate=GETDATE()                   
 FROM [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPD        
 INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] HTD        
  ON HPD.ProjectPatternMapID = HTD.ProjectPatternMapID        
 WHERE HPD.ProjectID=@ProjectId and HTD.IsDeleted=0 and HPD.IsDeleted=0        
 and HTD.DARTStatusID IN (12)            
 end          
else          
 begin          
 update [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic]            
 set            
 ModifiedBy='System',            
 ModifiedDate=GETDATE()                      
 FROM [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] HPD        
 INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails] HTD        
  ON HPD.ProjectPatternMapID = HTD.ProjectPatternMapID        
 WHERE HPD.ProjectID=@ProjectId and HTD.IsDeleted=0 and HPD.IsDeleted=0        
 and HTD.DARTStatusID IN (12)          
 end          
--------------------------------------------------------------------------          
if(@SupportTypeId = 1)          
begin          
 update TD            
 set            
 TD.ModifiedDate=GETDATE(),            
 TD.ModifiedBy='System',            
 TD.LastUpdatedDate=GETDATE()            
 from avl.TK_TRN_TicketDetail TD            
 INNER JOIN [AVL].[DEBT_PRJ_HealParentChild] HPC            
 ON TD.TicketID = HPC.DARTTicketID         
 INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPD        
 ON HPD.ProjectPatternMapID = HPC.ProjectPatternMapID        
 INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] HTD        
 ON HTD.ProjectPatternMapID=HPC.ProjectPatternMapID        
 WHERE HPD.ProjectID=@ProjectId and HPD.IsDeleted=0 and HPC.IsDeleted=0 AND TD.IsDeleted=0        
 and HTD.DARTStatusID IN (12)               
end          
else          
begin          
 update TD            
 set            
 TD.ModifiedDate=GETDATE(),            
 TD.ModifiedBy='System',            
 TD.LastUpdatedDate=GETDATE()            
 from avl.TK_TRN_infraTicketDetail TD            
 INNER JOIN [AVL].[DEBT_PRJ_InfraHealParentChild] HPC            
 ON TD.TicketID = HPC.DARTTicketID            
 INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] HPD        
 ON HPD.ProjectPatternMapID = HPC.ProjectPatternMapID        
 INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails] HTD        
 ON HTD.ProjectPatternMapID=HPC.ProjectPatternMapID        
 WHERE HPD.ProjectID=@ProjectId and HPD.IsDeleted=0 and HPC.IsDeleted=0 AND TD.IsDeleted=0        
 and HTD.DARTStatusID  IN (12)               
end          
commit  
end
