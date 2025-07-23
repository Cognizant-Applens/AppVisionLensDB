/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/




CREATE PROCEDURE [dbo].[sp_UpdServiceDetails]            

    @IsDeleted VARCHAR(50) ,            

    @ServProjMapID INT =NULL,            

    @serviceid VARCHAR(MAX) = NULL ,           

    @activityid VARCHAR(MAX) = NULL,           

    @createdby VARCHAR(50) = NULL ,            

    @projectid INT ,            

    @ServiceType VARCHAR(100) = NULL,

	@CustomerID INT            

AS             

    BEGIN       

	BEGIN TRY

BEGIN TRAN      

 SET NOCOUNT ON;            

        --DECLARE @C20Enablement CHAR                             

        DECLARE @SentString VARCHAR(MAX);                

		DECLARE @UpdatedServices VARCHAR(MAX);              

        DECLARE @count INT;                

        SET @count = 0;                

                     

        DECLARE @EqualString VARCHAR(MAX)= ',';                      

        DECLARE @TableString VARCHAR(MAX)= ',';                      

        DECLARE @InputString VARCHAR(MAX)= ',';                      

                      

        DECLARE @EqualCounter INT = 0;                      

        DECLARE @TableCounter INT = 0;                      

        DECLARE @InputCounter INT = 0;               

		DECLARE @MappedServiceCount INT = 0;   

		--DECLARE @isc20 int=0;          

  

        DECLARE @ConfiguredServiceCount INT = 0;                         

        SET @SentString = @serviceid;    

		

		DECLARE @ServiceProjectMapping table (ServiceID INT, ProjectID BIGINT, IsDeleted BIT)

		INSERT INTO @ServiceProjectMapping

		SELECT  SAM.ServiceID AS ServiceID, SPM.ProjectID AS ProjectID, SPM.IsDeleted FROM avl.TK_MAS_ServiceType ST

				JOIN avl.TK_MAS_Service S ON S.ServiceType = ST.ServiceTypeID

				JOIN avl.TK_MAS_ServiceActivityMapping SAM ON SAM.ServiceTypeID = ST.ServiceTypeID 
				AND SAM.ServiceID = S.ServiceID and ISNULL(SAM.IsMasterData,0)=1

				JOIN avl.TK_PRJ_ProjectServiceActivityMapping SPM ON SPM.ServiceMapID = SAM.ServiceMappingID  

		

		                

                      

        SELECT  @EqualCounter = COUNT(ServiceID)          

        FROM    ( SELECT    ServiceID          

                  FROM      @ServiceProjectMapping         

                  WHERE     ServiceID IN (          

                            SELECT  Item AS ServiceID          

                            FROM    dbo.Split(@SentString, ',') )          

                            AND ProjectID = @projectid          

                ) A;                      

        SELECT  @EqualString = @EqualString          

                + COALESCE(CAST(ServiceID AS VARCHAR), ',', '') + ','          

        FROM    ( SELECT    ServiceID          

                  FROM      @ServiceProjectMapping         

                  WHERE     ServiceID IN (          

                            SELECT  Item AS ServiceID          

                            FROM    dbo.Split(@SentString, ',') )          

                            AND ProjectID = @projectid          

                ) A;                      

                      

        SELECT  @TableCounter = COUNT(ServiceID)          

        FROM    ( SELECT    ServiceID          

                  FROM      @ServiceProjectMapping         

                  WHERE     ServiceID NOT IN (          

                            SELECT  Item AS ServiceID          

                            FROM    dbo.Split(@SentString, ',') )          

                            AND ProjectID = @projectid          

                ) A;                      

        SELECT  @TableString = @TableString          

                + COALESCE(CAST(ServiceID AS VARCHAR), ',', '') + ','          

        FROM    ( SELECT    ServiceID          

                  FROM      @ServiceProjectMapping        

                  WHERE     ServiceID NOT IN (          

                            SELECT  Item AS ServiceID          

                            FROM    dbo.Split(@SentString, ',') )          

                            AND ProjectID = @projectid          

                ) A;              

                      

        SELECT  @InputCounter = COUNT(ServiceID)          

        FROM    ( SELECT    Item AS ServiceID          

                  FROM      dbo.Split(@SentString, ',')          

                  WHERE     item NOT IN ( SELECT    ServiceID          

                                          FROM      @ServiceProjectMapping           

          WHERE     IsDeleted = 0          

                                                    AND ProjectID = @projectid )          

                ) A;                      

        SELECT  @InputString = @InputString          

                + COALESCE(CAST(ServiceID AS VARCHAR), ',', '') + ','          

        FROM    ( SELECT    Item AS ServiceID          

                  FROM      dbo.Split(@SentString, ',')          

                  WHERE     item NOT IN ( SELECT    ServiceID          

                               FROM      @ServiceProjectMapping          

                                          WHERE     IsDeleted = 0          

                          AND ProjectID = @projectid )          

                ) A;                      

                      

        DECLARE @LoopCounter INT = 0;                    

        IF (@IsDeleted = 'N')           

            BEGIN              

                IF ( @LoopCounter < @TableCounter )           

                    BEGIN                                

                        UPDATE  SPM          

                        SET     SPM.IsDeleted = 1,

								SPM.ModifiedDateTime = GETDATE() ,          

                                SPM.ModifiedBY = @createdby	

						FROM	avl.TK_MAS_ServiceType ST

								JOIN avl.TK_MAS_Service S ON S.ServiceType = ST.ServiceTypeID

								JOIN avl.TK_MAS_ServiceActivityMapping SAM ON SAM.ServiceTypeID = ST.ServiceTypeID 
								AND SAM.ServiceID = S.ServiceID and ISNULL(SAM.IsMasterData,0)=1

								JOIN avl.TK_PRJ_ProjectServiceActivityMapping SPM ON SPM.ServiceMapID = SAM.ServiceMappingID							          

                        WHERE   SAM.ServiceID IN (          

                                SELECT  Item          

                                FROM    dbo.Split(@TableString, ',') )          

                                AND ST.ServiceTypeName = @ServiceType          

                                AND ProjectID = @projectid               

                  

						 DELETE DTM FROM AVL.TK_MAP_TicketTypeServiceMapping DTM  WHERE           

						 DTM.ProjectID = @ProjectID          

						   AND DTM.ServiceID IN (            

													SELECT  Item            

													FROM    dbo.Split(@TableString, ',') )              

          

						 DELETE DTM FROM AVL.TK_MAP_TicketTypeServiceMapping DTM  WHERE          

						 DTM.ProjectID = @ProjectID          

						 AND DTM.ServiceID IN (            

													SELECT  Item            

													FROM    dbo.Split(@TableString, ',') )           

                   

						 SET @LoopCounter = @LoopCounter + 1                    

						 SET @count = @@ROWCOUNT             

      --              UPDATE PRJ.C20Configuration SET Isdeleted='Y' ,ModifiedBy=@createdby , ModifiedDateTime=GETDATE()              

      --WHERE                

      --ServiceID NOT IN (                

      --SELECT  Item                

      --FROM    dbo.Split(@UpdatedServices, ',') ) AND ProjectId=@projectid                   

                       

 --     UPDATE PMA                 

 --     SET PMA.IsDeleted=1 ,PMA.ModifiedBy=@createdby , PMA.ModifiedDateTime=GETDATE()                  

 --     FROM   TRN.ProjectMetricActuals PMA                

 --     JOIN TRN.MetricsReportingPeriod MRP ON PMA.ReportingID=MRP.ReportingID     

 --     WHERE                      

 --     ServiceID NOT IN (        

 --     SELECT  Item                      

 --     FROM    dbo.Split(@UpdatedServices, ',') ) AND PMA.ProjectID=@projectid                 

 -- AND MRP.ReportingStatusID NOT IN (3,4)          

                       

 --     SET @UpdatedServices=@UpdatedServices+',0'                

 --     UPDATE MV SET MV.IsDeleted=1 ,MV.ModifiedBy=@createdby , MV.ModifiedDateTime=GETDATE()                  

 --     FROM   TRN.MeasureValues MV                

 --     JOIN TRN.MetricsReportingPeriod MRP ON MRP.StartDate=CONVERT(DATE,DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0))              

 --     AND MRP.EndDate=CONVERT(DATE,DATEADD(ms, -3, DATEADD(mm, DATEDIFF(m, 0, GETDATE()) + 1, 0)))                 

 --     AND MRP.ProjectID=MV.ProjectID                

 --     WHERE                      

 --ServiceID NOT IN (                      

 --     SELECT  Item                      

 --     FROM    dbo.Split(@UpdatedServices, ',') ) AND MV.ProjectID=@projectid                 

 --     AND MRP.ReportingStatusID NOT IN (3,4)              

                    END                      

                SET @LoopCounter = 0;                      

                IF ( @LoopCounter < @InputCounter )           

                    BEGIN                                

                        INSERT INTO AVL.TK_PRJ_ProjectServiceActivityMapping         

                                ( ServiceMapID ,          

                                  ProjectID ,                               

                                  IsDeleted ,          

                                  CreatedDateTime ,          

                                  CreatedBY ,          

                                  ModifiedDateTime ,          

                                  ModifiedBY,

								  EffectiveDate                            

                                )          

                                SELECT  ServiceMappingID ,          

                                        @projectid ,                                          

										0 ,          

                                        GETDATE() ,          

                                        @createdby ,          

                                        NULL,          

                                        NULL,

										Null					     

                                FROM    AVL.TK_MAS_ServiceActivityMapping  SAM

								JOIN AVL.TK_MAS_ServiceType ST ON ST.ServiceTypeID = SAM.ServiceTypeID       

                                WHERE   ServiceID IN (          

                                        SELECT  Item          

                                        FROM    dbo.Split(@InputString, ',') )          

                                        AND ST.ServiceTypeName = @ServiceType  and ISNULL(SAM.IsMasterData,0)=1        

                        SET @LoopCounter = @LoopCounter + 1                     

                        SET @Count = 2        

                         SELECT  @Count;            

                    END    

				IF (EXISTS (SELECT 1 FROM AVL.TK_PRJ_ProjectServiceActivityMapping WHERE ProjectID = @ProjectID AND IsDeleted = 0)

					AND EXISTS(SELECT 1 FROM AVL.Customer where IsDeleted = 0 and CustomerID = @CustomerID AND IsEffortTrackActivityWise IS NOT NULL))

				BEGIN

					 IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] where ITSMScreenId=3 and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))

						begin

						  INSERT INTO [AVL].[PRJ_ConfigurationProgress] (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)

						  values(@CustomerID,@ProjectID,2,3,100,0,@createdby,getdate())

						end  

					else

						begin

							update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@createdby,ModifiedDate=getdate() where ProjectID=@ProjectID and ITSMScreenId=3 and customerid=@CustomerID and screenid=2 and IsDeleted=0 

						end

				END

				

				  update AVL.TK_PRJ_ProjectServiceActivityMapping set IsMainspringData = 'Y' 

					where ProjectID = @projectid and IsDeleted = 0

					and CONVERT(date,CreatedDateTime) = CONVERT(date,getdate()) AND ProjectID in (select ProjectID from AVL.MAS_ProjectMaster

																								where ProjectID = @projectid and  CustomerID = @CustomerID  and IsMainSpringConfigured = 'Y' and IsDeleted = 0)



				update AVL.TK_PRJ_ProjectServiceActivityMapping set IsMainspringData = 'N' 

				where IsDeleted = 0

				and CONVERT(date,CreatedDateTime) = CONVERT(date,getdate()) AND ProjectID in (select ProjectID from AVL.MAS_ProjectMaster

																								where ProjectID = @projectid and CustomerID = @CustomerID  and IsMainSpringConfigured = 'N' and IsDeleted = 0)            

            END          

        ELSE             

            IF ( @IsDeleted = 'Y' AND  @serviceid != '0' AND @activityid != '0' )             

                BEGIN               

					-- IF EXISTS (SELECT 1 from AVL.TK_MAP_TicketTypeServiceMapping where ProjectId = @projectid and ServiceId = @serviceid)     

		  	--	  		BEGIN          

					--		SET @count = 0          

					--	END          

					--ELSE    		  		  		  		  		  		  		  		  		  		  			  	  	  	  	  	  	  	  	  	  	  	  	  		  	  	  	  	  	  	  	  	  	  	  	  	  		  	  	  	  	  	  	  	  	  	  	  	  	  					  BEGIN          

					--	--DELETE  FROM AVL.TK_PRJ_ProjectServiceActivityMapping 

					--	UPDATE AVL.TK_PRJ_ProjectServiceActivityMapping SET   IsDeleted = 1,    ModifiedBY =  @createdby, ModifiedDateTime =  GETDATE()   

					--	WHERE   ServProjMapID = @ServProjMapID            

					--	AND ProjectID = @projectid                    

     

					--	SET @count = 1         

					--	SELECT  @count;     

					-- END    

					DECLARE @ServiceActivityCount int

					SET @ServiceActivityCount = (SELECT  COUNT(*) FROM avl.TK_MAS_ServiceType ST

											JOIN avl.TK_MAS_Service S ON S.ServiceType = ST.ServiceTypeID

											JOIN avl.TK_MAS_ServiceActivityMapping SAM ON SAM.ServiceTypeID = ST.ServiceTypeID AND SAM.ServiceID = S.ServiceID 
											and ISNULL(SAM.IsMasterData,0)=1
											
											JOIN avl.TK_PRJ_ProjectServiceActivityMapping SPM ON SPM.ServiceMapID = SAM.ServiceMappingID

											WHERE SPM.ProjectID = @ProjectID          

											      AND SAM.ServiceID = @Serviceid

												  AND SPM.Isdeleted = 0)

					 IF NOT EXISTS (    

								SELECT 1 from AVL.TM_TRN_TimesheetDetail NOLOCK where ProjectId = @ProjectID     

								and ServiceId = @Serviceid     

								and ActivityId = @ActivityId    

						)    

					BEGIN   

					--DELETE FROM AVL.TK_PRJ_ProjectServiceActivityMapping  

								IF (NOT EXISTS (SELECT 1 from AVL.TK_MAP_TicketTypeServiceMapping NOLOCK where ProjectId = @ProjectID     

									and ServiceId = @Serviceid) OR 

									 (EXISTS (SELECT 1 from AVL.TK_MAP_TicketTypeServiceMapping NOLOCK where ProjectId = @ProjectID     

									and ServiceId = @Serviceid) AND (@ServiceActivityCount > 1)))

								BEGIN

									UPDATE AVL.TK_PRJ_ProjectServiceActivityMapping SET   IsDeleted = 1, IsHidden = '1', EffectiveDate = GETDATE() ,ModifiedBY =  @createdby, ModifiedDateTime =  GETDATE()   

									WHERE   ServProjMapID = @ServProjMapID            

									AND ProjectID = @projectid                    

     

									SET @count = 1         

									SELECT  @count;          

								END 

								ELSE

									BEGIN

										SET @count = 0

										SELECT  @count;

									END	

					END					   

					ELSE    

					BEGIN    

						SET @count = 0

						SELECT  @count;   

					END                               

				END                                            

      --SET @MappedServiceCount= (SELECT COUNT(DISTINCT serviceid)            

      --FROM AVL.TK_PRJ_ProjectServiceActivityMapping where ProjectID=@projectid and IsDeleted=0)

	    --and ServiceID in (select c20serviceid from MAS.C20Services ))               

                                                                         

      --SET @ConfiguredServiceCount= (SELECT COUNT(DISTINCT serviceid) FROM PRJ.C20Configuration where ProjectID=@projectid and IsDeleted='N'  )               

                      

      --SELECT @C20Enablement=IsC2AppServiceMapCompleted FROM MAS.ProjectMaster WHERE ProjectID=@projectid                                    

      --IF @MappedServiceCount<>@ConfiguredServiceCount            

      -- BEGIN            

      --    IF (SELECT IsC2AppServiceMapCompleted FROM MAS.ProjectMaster WHERE ProjectID=@projectid) = 'Y'              

      --    BEGIN                

                        

      --   UPDATE MAS.ProjectMaster               

      -- SET IsC2AppServiceMapCompleted='N',              

      --C20AppServiceMapCompletedResetBy= @createdby ,              

      --   C20AppServiceMapCompletedTimestamp =  GETDATE()              

      --   WHERE ProjectID=@projectid              

                     

      --UPDATE SPM SET SPM.IsC20Configured  = 0 from MAP.ServiceProjectMapping SPMTK_MAS_ServiceMaster--DECLARE @tableHTML VARCHAR(MAX);                 

      --DECLARE @MailingToList VARCHAR(MAX)              

      --DECLARE @MailingCCList VARCHAR(MAX)                  

      --DECLARE @Subjecttext VARCHAR(100)          DECLARE @UnfreezenDate VARCHAR(MAX)               

      --DECLARE @ProjectName VARCHAR(MAX)                

      --DECLARE @ESAProjectID VARCHAR(MAX)             

      --DECLARE @IsESAProjectID CHAR               

                          

      --SELECT @MailingToList = COALESCE(@MailingToList+ ';', '') + CAST(RTRIM(ISNULL(CognizantEmail,';')) AS VARCHAR(200))                    

      --FROM PRJ.LoginMaster A            

      --WHERE  UserId IN  (SELECT TsSupervisorID FROM PRJ.LoginMaster WHERE ProjectID=@ProjectID AND IsDeleted = 'N') AND IsDeleted = 'N'            

                   

      ----Prepare the Mailing CC List to Managers               

                                  

      --SELECT @MailingCCList  = COALESCE(@MailingCCList + ';', '') + CAST(RTRIM(ISNULL(CognizantEmail,';')) AS VARCHAR(200))                    

      --FROM PRJ.LoginMaster                 

     --WHERE  UserId IN  (SELECT ManagerID FROM PRJ.LoginMaster WHERE ProjectID=@ProjectID AND IsDeleted = 'N') AND IsDeleted = 'N'                  

                  

      ----ProjectName              

      --SELECT @ProjectName = ProjectName ,@ESAProjectID = EsaProjectID,@IsESAProjectID=IsESAProject                          

      --FROM MAS.ProjectMaster  A            

      --WHERE  

      --A.ProjectID=@ProjectID            

      --AND A.IsDeleted = 'N'                

                         

                           

      ----Subject Text               

      --SET  @subjecttext = 'C2.0 Integration is disabled for the project - '+@ESAProjectID+' - '+@ProjectName               

                       

      --SET @tableHTML =  N'<font color="Black" face="Arial" Size = "2">Dear Associate(s),<br/><br> '                

      --+ N'<font color="Black" face="Arial" Size = "2">C2.0 Integration has been disabled since a new Service has been added in AVMDART.So tickets will not be pushed to C20. Please complete the C2.0 Integration setup.<br/><br>'                 

      --+ N'<font color="Black" face="Arial" Size = "2">Project Details: '+@ESAProjectID+' - '+@ProjectName+''           

      --+ N'<p align="left"><font color="Black" face="Arial" Size = "2">Ps :This is system generated mail,please do not reply to this mail.<br/><br>                    

      --Regards<br/>                    

      --AVMDART Team</font></p>';                    

      --IF @IsESAProjectID='Y' AND @C20Enablement='Y'              

      -- BEGIN            

      --   BEGIN TRY       

      --  EXEC msdb.dbo.sp_send_dbmail @recipients = @MailingToList,                    

      --  @profile_name = 'AD Mail Alerts',                    

      --  @copy_recipients = @MailingCCList,                   

      --  @subject = @Subjecttext,                  

      --  @body = @tableHTML,                 
      --  @body_format = 'HTML';               

      --  END TRY                 

      --     BEGIN CATCH                                                  

      --     INSERT  INTO PRJ.DefaulerMaillog(ProjectId, status, RecordsCount,ErrorDescription, CreatedDateTime,CreatedBY)                          

      --     SELECT DISTINCT                          

      --     @projectid,                          

      --    'Mail sending unsuccess with error',                          

      --   1,                          

      --    ERROR_MESSAGE(),                          

      --    GETDATE(),                          

      --    'C2.0  AppService mapping disabled'                

      --    END CATCH            

                      

      -- END               

      -- END            

                       

      --       END     

   

	     

 SET NOCOUNT OFF;   

 COMMIT TRAN

END TRY  

BEGIN CATCH  



		DECLARE @ErrorMessage VARCHAR(MAX);



		SELECT @ErrorMessage = ERROR_MESSAGE()

		ROLLBACK TRAN

		--INSERT Error    

		EXEC AVL_InsertError 'sp_UpdServiceDetails', 

@ErrorMessage, @CustomerID ,0

		

	END CATCH              

    END
