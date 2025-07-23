
CREATE   PROCEDURE [AVL].[UpdateSmartExecutionSharedPathdetails]
(
 @ID BIGINT
,@ProjectID char(50)
,@SharedPath VARCHAR(6000)
,@SharedPathType char(100)
)
AS
SET NOCOUNT ON;
  BEGIN
      BEGIN try
  
       IF (@SharedPathType is not null and ltrim(rtrim(@SharedPathType))!='')
       BEGIN
           IF(@SharedPathType='WorkItemDetails')
                UPDATE SESPD 
                    set SESPD.WorkItemDetailsPath=@SharedPath
                    ,SESPD.ModifiedBy='825231'
                    ,SESPD.ModifiedDate=GETDATE()
                FROM ADM.SmartExecutionSharePathDetails SESPD
                WHERE SESPD.SharePathId=@ID
                AND SESPD.ProjectID=@ProjectID 
            ELSE IF(@SharedPathType='IterationOrSprintOrPhaseDetails')
                UPDATE SESPD 
                    set SESPD.IterationOrSprintOrPhaseDetailsPath=@SharedPath
                    ,SESPD.ModifiedBy='825231'
                    ,SESPD.ModifiedDate=GETDATE()
                FROM ADM.SmartExecutionSharePathDetails SESPD
                WHERE SESPD.SharePathId=@ID
                AND SESPD.ProjectID=@ProjectID 
            ELSE IF(@SharedPathType='ReleaseDetails')
                UPDATE SESPD 
                    set SESPD.ReleaseDetailsPath=@SharedPath
                    ,SESPD.ModifiedBy='825231'
                    ,SESPD.ModifiedDate=GETDATE()
                FROM ADM.SmartExecutionSharePathDetails SESPD
                WHERE SESPD.SharePathId=@ID
                AND SESPD.ProjectID=@ProjectID 
       END

      END try

      BEGIN catch
          DECLARE @ErrorMessage VARCHAR(5000);
          SELECT @ErrorMessage = Error_message()
          EXEC AVL_InsertError '[AVL].[UpdateSmartExecutionSharedPathdetails]', @ErrorMessage, 0,0   
      END catch
      SET NOCOUNT OFF;
  END
