/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Debt_SaveHealReMappingData]
(
 @UserId VARCHAR(50)
,@ProjectID BIGINT
,@DesTicket VARCHAR(200)
,@SrcHealticktID VARCHAR(MAX)
,@HealTicketList dbo.SaveHealRemappingDetails READONLY
)
AS
BEGIN
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON;      
              CREATE TABLE #temp
              (
              ID INT IDENTITY
              ,TicketID VARCHAR(50)
              ,Ischecked VARCHAR(50)
              )

              INSERT INTO #temp               
              SELECT * FROM @HealTicketList 

			  DECLARE @SrcProjectPatternMapID VARCHAR(50) 
              
              SET @SrcProjectPatternMapID = (SELECT TOP 1 ProjectPatternMapID FROM [AVL].[DEBT_TRN_HealTicketDetails] WHERE HealingTicketID = @SrcHealticktID and IsDeleted=0 AND  ISNULL(ManualNonDebt,0) != 1 )
              
              DECLARE @DesProjectPatternMapID VARCHAR(50) 
                           
              SET @DesProjectPatternMapID = (SELECT TOP 1 ProjectPatternMapID FROM [AVL].[DEBT_TRN_HealTicketDetails] WHERE HealingTicketID = @DesTicket AND IsDeleted =0 AND  ISNULL(ManualNonDebt,0) != 1)
              PRINT @DesProjectPatternMapID
              
			  
			  /* ---- Checking whether A exists for H ticket ---*/
			 DECLARE @srcPartialAutomationTicketID NVARCHAR(50)
			 DECLARE @srcPartialProjectPatternMapID INT
			 
			 SELECT @srcPartialAutomationTicketID = PartialAutomationTicketID
					--@srcPartialProjectPatternMapID = ProjectPatternMapID
						FROM AVL.DEBT_TRN_HealTicketDetails 
						WHERE HealingTicketID=@SrcHealticktID --and IsPartialAutomationHealTicket=1
							  AND TicketType='H'

			 DECLARE @desPartialAutomationTicketID NVARCHAR(50)
			 DECLARE @desPartialProjectPatternMapID INT

			 SELECT @desPartialAutomationTicketID = PartialAutomationTicketID, 
					@desPartialProjectPatternMapID = ProjectPatternMapID
						FROM AVL.DEBT_TRN_HealTicketDetails 
						WHERE HealingTicketID=@DesTicket --and IsPartialAutomationHealTicket=1
							  AND TicketType='H'
							  							   
              -- check if the temp table have more than 1 value              
              DECLARE @TotalCount VARCHAR(50)
              SET @TotalCount = (SELECT COUNT(*) FROM #temp where IsChecked = '1')
              WHILE (@TotalCount > 0)
                     BEGIN
                           PRINT @TotalCount
                                  DECLARE @TicketID VARCHAR(50)
                                  DECLARE @Checked VARCHAR(100)
                                  SET @TicketID = (SELECT TOP 1 TicketID FROM #temp where IsChecked = '1')
                                  SET @Checked = (SELECT TOP 1 IsChecked FROM #temp where IsChecked = '1')
                                  
                                  --deactivate the link betwen dart ticket and old helaing ticket
                                  IF(@Checked  = '1')                             
                                  BEGIN                                                                
                                         
                                         UPDATE A SET A.MapStatus = 0, A.ModifiedBy = @UserID, ModifiedDate = GETDATE() 
                                         FROM [AVL].[DEBT_PRJ_HealParentChild] A INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] B 
                                         ON A.ProjectPatternMapID = B.ProjectPatternMapID
                                         WHERE A.DARTTicketID = @TicketID AND A.IsDeleted =0
                                         AND A.ProjectPatternMapID = @SrcProjectPatternMapID  AND  ISNULL(B.ManualNonDebt,0) != 1       
                                        
										 UPDATE AVL.DEBT_PRJ_HealProjectPatternMappingDynamic SET PatternFrequency = PatternFrequency - 1 
										  WHERE ProjectPatternMapID = @SrcProjectPatternMapID AND ProjectID = @ProjectID AND  ISNULL(ManualNonDebt,0) != 1

										
										 UPDATE AVL.DEBT_PRJ_HealProjectPatternMappingDynamic SET PatternFrequency = PatternFrequency + 1 
										 WHERE ProjectPatternMapID = @DesProjectPatternMapID AND ProjectID = @ProjectID AND  ISNULL(ManualNonDebt,0) != 1
                                         
                                         --insert the child ticket details into PRJ.Heal_ParentChild
                                         INSERT INTO [AVL].[DEBT_PRJ_HealParentChild]
										 (ProjectPatternMapID,DARTTicketID,MapStatus,IsManual,IsDeleted,CreatedBy,CreatedDate,
										 ModifiedBy,ModifiedDate,TicketDescription,ResolutionRemarks,EffortTillDate,ITSMEffort)
										 SELECT @DesProjectPatternMapID,@TicketID,1,1,0,@UserID,GETDATE(),NULL,NULL, 
										 TicketDescription,ResolutionRemarks,EffortTillDate,ITSMEffort
										 FROM [AVL].[DEBT_PRJ_HealParentChild] WHERE ProjectPatternMapID = @SrcProjectPatternMapID
										 AND DARTTicketID = @TicketID AND IsDeleted =0 AND MapStatus = 0

                                         --Insert the mapping into [TRN].[Heal_ReMappingTickets] table                             
                                         
                                         INSERT INTO [AVL].[Heal_ReMappingTickets] VALUES (@SrcHealticktID,@SrcProjectPatternMapID,@DesTicket
                                         ,@DesProjectPatternMapID,@TicketID,0,@UserID,GETDATE(),NULL,NULL)    
                                         
                                         --insert into log table
                                         INSERT INTO [AVL].[DEBT_TRN_HealTicketsLog] VALUES (@ProjectID,@DesTicket,16,NULL,NULL,NULL,NULL,NULL,NULL,@TicketID,'DE.ReMappingTickets',NULL,NULL,NULL,NULL,@UserID,GETDATE())                               



										 -- Deactivating the child tickets of partail automated A tickets 
										 IF(@srcPartialAutomationTicketID is not null and @srcPartialAutomationTicketID!='')
										 BEGIN

											UPDATE A SET A.MapStatus = 0, A.ModifiedBy = @UserID, ModifiedDate = GETDATE() 
											FROM [AVL].[DEBT_PRJ_HealParentChild] A 
											INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] B 
														ON A.ProjectPatternMapID = B.ProjectPatternMapID
											WHERE A.DARTTicketID = @TicketID AND A.IsDeleted =0
											AND B.HealingTicketID= @srcPartialAutomationTicketID and B.TicketType='A'
											AND B.IsManual=1

											SELECT @srcPartialProjectPatternMapID = ProjectPatternMapID
											FROM AVL.DEBT_TRN_HealTicketDetails 
											WHERE HealingTicketID=@srcPartialAutomationTicketID --and IsPartialAutomationHealTicket=1
											AND TicketType='A' and IsManual=1

											 UPDATE AVL.DEBT_PRJ_HealProjectPatternMappingDynamic 
											 SET PatternFrequency = PatternFrequency - 1 
											 WHERE ProjectPatternMapID = @srcPartialProjectPatternMapID  
											 and ProjectID = @ProjectID  AND IsManual=1
											 AND ISNULL(ManualNonDebt,0) != 1

										 END  
										 
										 IF(@desPartialAutomationTicketID is not null and @desPartialAutomationTicketID!='')
										 BEGIN
												SELECT @desPartialProjectPatternMapID = ProjectPatternMapID
												FROM AVL.DEBT_TRN_HealTicketDetails 
												WHERE HealingTicketID=@desPartialAutomationTicketID  --and IsPartialAutomationHealTicket=1
												AND TicketType='A'

												UPDATE AVL.DEBT_PRJ_HealProjectPatternMappingDynamic 
												SET PatternFrequency = PatternFrequency + 1 
												WHERE ProjectPatternMapID = @desPartialProjectPatternMapID 
												AND ProjectID = @ProjectID AND  ISNULL(ManualNonDebt,0) != 1
                                         
												--insert the child ticket details into PRJ.Heal_ParentChild
												INSERT INTO [AVL].[DEBT_PRJ_HealParentChild] 
												(ProjectPatternMapID,DARTTicketID,MapStatus,IsManual,IsDeleted,CreatedBy,
												CreatedDate,ModifiedBy,ModifiedDate,TicketDescription,ResolutionRemarks,
												EffortTillDate,ITSMEffort)
												--VALUES(@desPartialProjectPatternMapID,
												--@TicketID,'Active',@UserID,GETDATE(),NULL,NULL,0,1)
												 SELECT @desPartialProjectPatternMapID,@TicketID,1,1,0,@UserID,GETDATE(),NULL,NULL, 
												 TicketDescription,ResolutionRemarks,EffortTillDate,ITSMEffort
												 FROM [AVL].[DEBT_PRJ_HealParentChild] WHERE ProjectPatternMapID = @srcPartialProjectPatternMapID
												 AND DARTTicketID = @TicketID AND IsDeleted =0 AND MapStatus = 0
												
										 END
   
                                  END
                                  
                      DELETE FROM #temp WHERE TicketID = @TicketID
                                  --SELECT * FROM #temp
                                  SET @TotalCount = @TotalCount-1
                                  PRINT @TotalCount
                     END    
                     COMMIT TRAN
                     END TRY  
 BEGIN CATCH  

              DECLARE @ErrorMessage VARCHAR(MAX);
              SELECT @ErrorMessage = ERROR_MESSAGE()
              ROLLBACK TRAN
              --INSERT Error    
              EXEC AVL_InsertError '[dbo].[Debt_SaveHealReMappingData] ', @ErrorMessage, @Projectid,0
END CATCH  

END
