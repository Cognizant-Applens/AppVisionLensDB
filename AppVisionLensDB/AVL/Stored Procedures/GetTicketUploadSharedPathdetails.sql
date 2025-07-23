CREATE   PROCEDURE [AVL].[GetTicketUploadSharedPathdetails] 
AS
SET NOCOUNT ON;  
  BEGIN
      BEGIN try
        select
            distinct
            --top 30
            TUPC.TicketUploadPrjConfigID as ID,
            TUPC.ProjectID,
            PM.ESAprojectID,
            TUPC.IsManualOrAuto as IsManualOrAuto,
            TUPC.SharePath as SharePath,
            'TicketUpload' as SharePathType,
            TUPC.TicketSharePathUsers as TicketSharePathUsers
        from
		    AVL.PRJ_ConfigurationProgress A(nolock)
		    join Avl.MAS_ProjectMaster PM(nolock) ON A.ProjectID=PM.ProjectID
            join TicketUploadProjectConfiguration TUPC(nolock)  on TUPC.ProjectID=PM.ProjectID
        where
            A.screenID=4
            and A.CompletionPercentage=100
            and A.Isdeleted=0
            and PM.IsDeleted=0
            and len(trim(TUPC.SharePath))>0
            and PM.EsaProjectID NOT IN(
                '1000249233',
                '1000075762',
                '1000277089',
                '1000281206',
                '1000314619',
                '1000320771',
                '1000349590',
                '1000383377',
                '1000428652'
                )
      END try
 
      BEGIN catch
          DECLARE @ErrorMessage VARCHAR(5000);
          SELECT @ErrorMessage = Error_message()
          EXEC AVL_InsertError '[AVL].[GetTicketUploadSharedPathdetails]', @ErrorMessage, 0,0
      END catch
      SET NOCOUNT OFF;
  END
