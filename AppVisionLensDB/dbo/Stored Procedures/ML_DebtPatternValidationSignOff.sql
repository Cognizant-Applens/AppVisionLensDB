/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_DebtPatternValidationSignOff] 
@ProjectID VARCHAR(200), 
@Datefrom  DATETIME = NULL, 
@UserID VARCHAR(50),
@SupportTypeID int
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

          DECLARE @EsaProjectID VARCHAR(500) 
          DECLARE @Initialid BIGINT 
		  if(@SupportTypeID=1)
		  begin
          SET @Initialid = (SELECT TOP 1 ID 
                            FROM   AVL.ML_PRJ_INITIALLEARNINGSTATE (NOLOCK) 
                            WHERE  ProjectID = @ProjectID 
                                   AND IsDeleted = 0 
                            ORDER  BY ID DESC) 
							END

							ELSE
							BEGIN

							 SET @Initialid = (SELECT TOP 1 ID 
                            FROM   avl.ML_PRJ_InitialLearningStateInfra(NOLOCK) 
                            WHERE  ProjectID = @ProjectID 
                                   AND IsDeleted = 0 
                            ORDER  BY ID DESC)
							END

          UPDATE AVL.ML_TRN_REGENERATEDAPPLICATIONDETAILS 
          SET    IsMLSignOff = 1 
          WHERE  ProjectID = @ProjectID 
                 AND InitialLearningID = @Initialid 
                 AND IsDeleted = 0 and @SupportTypeID=1



          UPDATE AVL.ML_TRN_RegeneratedTowerDetails
          SET    IsMLSignOff = 1 
          WHERE  ProjectID = @ProjectID 
                 AND InitialLearningID = @Initialid 
                 AND IsDeleted = 0 and @SupportTypeID=2


          UPDATE debt 
          SET    debt.IsMLSignOff = (case when @SupportTypeID=1 THEN 1 ELSE debt.IsMLSignOff END), 
                 debt.MLSignOffDate = (case when @SupportTypeID=1 THEN @Datefrom ELSE debt.MLSignOffDate END), 
                 debt.MLSignOffUserId =(case when @SupportTypeID=1 THEN @UserID ELSE debt.MLSignOffUserId END) , 
                 DebtEnablementDate = (case when @SupportTypeID=1 THEN @Datefrom ELSE DebtEnablementDate END),
				 debt.IsMLSignOffInfra= (case when @SupportTypeID=2 THEN 1 ELSE debt.IsMLSignOffInfra END),
				 debt.MLSignOffDateInfra=(case when @SupportTypeID=2 THEN @Datefrom ELSE debt.MLSignOffDateInfra END),
				 debt.MLSignOffUserIdInfra=(case when @SupportTypeID=2 THEN @UserID ELSE debt.MLSignOffUserIdInfra END)
          FROM   [AVL].[MAS_PROJECTDEBTDETAILS] (NOLOCK) debt 
                 JOIN [AVL].[MAS_PROJECTMASTER] (NOLOCK) prj 
                   ON prj.ProjectID = debt.ProjectID 
                LEFT JOIN AVL.ML_PRJ_INITIALLEARNINGSTATE (NOLOCK) IT 
                   ON IT.ID = @Initialid 
                      AND IT.IsDeleted = 0 
					  left JOIN AVL.ML_PRJ_InitialLearningStateInfra(NOLOCK) ITInfra
					  ON  ITInfra.ID = @Initialid 
                      AND ITInfra.IsDeleted = 0 
          WHERE  prj.projectid = @projectid 
                 AND ISNULL(IT.IsRegenerated, 0) = 0 
				 and ((@SupportTypeID=2 AND ITInfra.ID is NOT NULL) OR (@SupportTypeID=1 AND IT.ID is NOT NULL))

				
          UPDATE [AVL].[MAS_PROJECTMASTER] 
          SET    IsDebtEnabled = 'Y' 
          WHERE  ProjectID = @ProjectID 
                 AND IsDeleted = 0 

          IF NOT EXISTS(SELECT 1 
                        FROM   AVL.CL_PROJECTJOBDETAILS (NOLOCK) 
                        WHERE  ProjectID = @ProjectID) 
            BEGIN 
                DECLARE @JobDate DATETIME; 
                DECLARE @NextDayID INT = 5

                SET @JobDate= DATEADD(DAY, (DATEDIFF(DAY, @NextDayID, GETDATE()) / 7) * 7 + 7, @NextDayID) 

                INSERT INTO AVL.CL_PROJECTJOBDETAILS 
                            (ProjectID, 
							StartDateTime,
                             JobDate, 
                             StatusForJob, 
                             CreatedBy, 
                             CreatedDate, 
                             IsDeleted) 
                VALUES     (@ProjectID, 
				            @Datefrom,
                            @JobDate, 
							0, 
							'SYSTEM', 
                            GETDATE(), 
                            0); 
            END 

          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          -- Insert Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_DebtPatternValidationSignOff] ', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
