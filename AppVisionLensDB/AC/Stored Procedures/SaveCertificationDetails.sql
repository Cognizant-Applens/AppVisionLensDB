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
-- Author:  <>  
-- Create date: <>  
-- Description: <>  
-- Execution  : [AC].[SaveCertificationDetails]  '',''  
-- =============================================  
CREATE PROCEDURE [AC].[SaveCertificationDetails]    
(    
@CategoryId nvarchar(50),            --Table : int    
@AwardId nvarchar(50),               -- :  int    
@EmployeeId nvarchar(50),    
@AccountId BIGINT,    
@EsaProjectId nvarchar(50)= NULL,    
@ProjectID BIGINT,    
@Designation nvarchar(500)= NULL,    
@CertificationMonth nvarchar(50),   --tinyint    
@CertificationYear smallint,    
@NoOfATicketsClosed int = NULL,    
@NoOfHTicketsClosed int= NULL,    
@IncReductionMonth int= NULL,    
@EffortReductionMonth int= NULL,    
@SolutionIdentified int= NULL,    
@NoOfKEDBCreatedApproved int= NULL,    
@NoOfCodeAssetContributed int= NULL,    
@CreatedBy nvarchar(50),  
@ReferenceId as AC.TVP_ReferenceIdDetails READONLY  
)    
AS    
BEGIN    
 --BEGIN TRANSACTION;  
 BEGIN TRY
   SET NOCOUNT ON;  
   declare @MONTH int   
   declare @CategoryIds int     
   declare @AwardIds int   
  
   declare @AccountIds int     
   declare @ProjectIDs int 

   set @AccountIds =(select CustomerID from avl.MAS_ProjectMaster (NOLOCK) where EsaProjectID=@EsaProjectId)
   set @ProjectIDs =(select ProjectID from avl.MAS_ProjectMaster (NOLOCK) where EsaProjectID=@EsaProjectId)
   set @MONTH= (MONTH(@CertificationMonth + ' 1 2021'))  
   set @CategoryIds =(select AttributeValueID from MAS.PPAttributeValues (NOLOCK) where AttributeValueName=@CategoryId)  
   set @AwardIds =(select AttributeValueID from MAS.PPAttributeValues (NOLOCK) where AttributeValueName=@AwardId)  
  
   if Not EXISTS (select AccountId, EsaProjectId,  ProjectID  from AC.TRN_Associate_Lens_Certification (NOLOCK) where AccountId =@AccountIds and    
   EsaProjectId = @EsaProjectId and  ProjectID=@ProjectIDs  and EmployeeId=@EmployeeId and NoOfATicketsClosed =@NoOfATicketsClosed and  
   NoOfHTicketsClosed = @NoOfHTicketsClosed AND CertificationMonth=@MONTH  and CertificationYear=@CertificationYear  and
   CategoryId=@CategoryIds AND AwardId=@AwardIds)  
   BEGIN                         
   Insert into AC.TRN_Associate_Lens_Certification(    
   CategoryId,    
   AwardId,    
   EmployeeId,    
   AccountId,    
   EsaProjectId,    
   ProjectID,    
   Designation,    
   CertificationMonth,    
   CertificationYear,    
   NoOfATicketsClosed,    
   NoOfHTicketsClosed,    
   IncReductionMonth,    
   EffortReductionMonth,    
   SolutionIdentified,    
   NoOfKEDBCreatedApproved,    
   NoOfCodeAssetContributed,    
   Isdeleted,    
   CreatedBy,    
   CreatedDate)    
   values(    
   @CategoryIds,    
   @AwardIds,    
   @EmployeeId,    
   @AccountIds,    
   @EsaProjectId,    
   @ProjectIDs,    
   @Designation ,    
   @MONTH,    
   @CertificationYear,    
   @NoOfATicketsClosed,    
   @NoOfHTicketsClosed,    
   @IncReductionMonth,    
   @EffortReductionMonth,    
   @SolutionIdentified,    
   @NoOfKEDBCreatedApproved,    
   @NoOfCodeAssetContributed,    
   0,    
   'SYSTEM',    
   GETDATE()    
   )   
  
   Declare @Certification int  
   set @Certification=SCOPE_IDENTITY()  
  
   select ReferenceId into #ReferenceIds from @ReferenceId 
   select TTC.ReferenceId,B.CertificationId into #Refer from [AC].[TRN_Certification_Track](nolock) TTC inner join @ReferenceId R on TTC.ReferenceId=R.ReferenceId  
   INNER JOIN AC.TRN_Associate_Lens_Certification(NOLOCK) B  ON B.CertificationId=TTC.CertificationId where TTC.Isdeleted=0 and B.Isdeleted=0  
  
   UPDATE  B    
   SET     B.NoOfATicketsClosed = CASE WHEN B.NoOfATicketsClosed <> 0     
     THEN B.NoOfATicketsClosed-1  END,    
   B.ModifiedDate = GETDATE()    
   FROM #Refer (NOLOCK) T     
   INNER JOIN AC.TRN_Associate_Lens_Certification(NOLOCK) B    
   ON B.CertificationId=T.CertificationId    
   WHERE B.CertificationId=T.CertificationId   
  
  
   delete RI from #ReferenceIds RI join #Refer RF on RI.ReferenceId=RF.ReferenceId   
   Insert into [AC].[TRN_Certification_Track]   
   (  
   CertificationId,  
   Module,  
   ReferenceId,  
   Isdeleted,  
   CreatedDate,  
   CreatedBy  
   )select @Certification,@CategoryIds,R.ReferenceId,0,Getdate(),'SYSTEM' from #ReferenceIds (NOLOCK) R    
  
   DROP TABLE #ReferenceIds  
   DROP TABLE #Refer  
   --COMMIT TRANSACTION;  
 END
 SET NOCOUNT OFF;  
 END TRY  
 BEGIN CATCH  
  --ROLLBACK TRANSACTION;  
  DECLARE @ErrorMessage VARCHAR(4000);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error        
  EXEC AVL_InsertError '[AC].[SaveCertificationDetails]'  
   ,@ErrorMessage  
   ,0  
 END CATCH    
END
