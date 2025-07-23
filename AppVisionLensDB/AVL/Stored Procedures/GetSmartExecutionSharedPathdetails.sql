CREATE   PROCEDURE [AVL].[GetSmartExecutionSharedPathdetails] 
AS
SET NOCOUNT ON;  
  BEGIN
      BEGIN try
      --Reference SP's: [PP].[GetAdminProxyAdminDetails] ,[ADM].[SaveSmartExecutionSharePathDetails]
  select 
          ID,
          ProjectID,
          ESAprojectID,
          IsManualOrAuto,
          SharePath,
          SharePathType,
          TicketSharePathUsers
  into #PathTemp
    from(
        SELECT
            distinct
            --top 30
            SEPD.SharePathId as ID,
            SEPD.ProjectID,
            PM.ESAprojectID,
            0 as IsManualOrAuto,
            SEPD.WorkItemDetailsPath as SharePath,
            'WorkItemDetails' as SharePathType,
            '' as TicketSharePathUsers
        from 
            Avl.MAS_ProjectMaster PM(nolock)
            join ADM.SmartExecutionSharePathDetails SEPD(nolock)  on SEPD.ProjectID=PM.ProjectID
        where  
             PM.IsDeleted=0
            and SEPD.IsDeleted=0
            and len(trim(SEPD.WorkItemDetailsPath))>0
 
        UNION ALL
        SELECT
            distinct
            --top 30
            SEPD.SharePathId as ID,
            SEPD.ProjectID,
            PM.ESAprojectID,
            0 as IsManualOrAuto,
            SEPD.IterationOrSprintOrPhaseDetailsPath as SharePath,
            'IterationOrSprintOrPhaseDetails' as SharePathType,
            '' as TicketSharePathUsers
        from 
            Avl.MAS_ProjectMaster PM(nolock)
            join ADM.SmartExecutionSharePathDetails SEPD(nolock)  on SEPD.ProjectID=PM.ProjectID
        where  
             PM.IsDeleted=0
            and SEPD.IsDeleted=0
            and len(trim(SEPD.IterationOrSprintOrPhaseDetailsPath))>0
 
        UNION ALL
        SELECT
            distinct
            --top 30
            SEPD.SharePathId as ID,
            SEPD.ProjectID,
            PM.ESAprojectID,
            0 as IsManualOrAuto,
            SEPD.ReleaseDetailsPath as SharePath,
            'ReleaseDetails' as SharePathType,
            '' as TicketSharePathUsers
        from 
            Avl.MAS_ProjectMaster PM(nolock)
            join ADM.SmartExecutionSharePathDetails SEPD(nolock)  on SEPD.ProjectID=PM.ProjectID
        where  
             PM.IsDeleted=0
            and SEPD.IsDeleted=0
            and len(trim(SEPD.ReleaseDetailsPath))>0
       ) as T1
 
       select distinct 
               PM.ProjectID, VWPRAD.AssociateId into #UserTemp 
            from  RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK)VWPRAD
                    join avl.MAS_ProjectMaster (NOLOCK) PM on  VWPRAD.esaprojectid=PM.ESAProjectID
                    and  VWPRAD.rolekey in ('RLE004','RLE005')
             order by PM.ProjectID
 
       select
          Distinct
          pt.ID,
          pt.ProjectID,
          pt.ESAprojectID,
          pt.IsManualOrAuto,
          pt.SharePath,
          pt.SharePathType,
          ut.AssociateId as TicketSharePathUsers
        from #PathTemp pt
        join #UserTemp ut on pt.ProjectID=ut.ProjectID
  --      and pt.ESAprojectID In('1999999999')
		--and ut.AssociateId in ('825231')
 
      END try
 
      BEGIN catch
          DECLARE @ErrorMessage VARCHAR(5000);
          SELECT @ErrorMessage = Error_message()
          EXEC AVL_InsertError '[AVL].[GetSmartExecutionSharedPathdetails]', @ErrorMessage, 0,0
      END catch
      SET NOCOUNT OFF;
  END
