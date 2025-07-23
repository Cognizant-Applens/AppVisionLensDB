 
CREATE   PROCEDURE [AVL].[GetEffortUploadSharedPathdetails]
AS
SET NOCOUNT ON;
  BEGIN
      BEGIN try
          select
            distinct
            --top 30
            EUC.ID as ID,
            PM.ProjectID,
            PM.ESAprojectID,
            EUC.EffortUploadType as IsManualOrAuto,
            EUC.SharePathName as SharePath,
             'EffortUpload' as SharePathType,
            TUPC.TicketSharePathUsers as TicketSharePathUsers
        from
		    AVL.PRJ_ConfigurationProgress A(nolock)
		    join Avl.MAS_ProjectMaster PM(nolock) ON A.ProjectID=PM.ProjectID
            join TicketUploadProjectConfiguration TUPC(nolock)  on TUPC.ProjectID=PM.ProjectID
            join AVL.EffortUploadConfiguration EUC(nolock) on EUC.ProjectID=PM.ProjectID
        where
            A.screenID=4
            and A.CompletionPercentage=100
            and A.Isdeleted=0
            and PM.IsDeleted=0
            and len(trim(EUC.SharePathName))>0
            and PM.EsaProjectID NOT IN(
            '1000199408',
            '1000349590',
            '1000294266',
            '1000284634',
            '1000428652',
            '1000314619',
            '1000267138',
            '1000267219'
            )
      END try
 
      BEGIN catch
          DECLARE @ErrorMessage VARCHAR(5000);
          SELECT @ErrorMessage = Error_message()
          EXEC AVL_InsertError '[AVL].[GetEffortUploadSharedPathdetails]', @ErrorMessage, 0,0
      END catch
      SET NOCOUNT OFF;
  END
