
CREATE   PROCEDURE [AVL].[GetActiveUserdetails]
AS
SET NOCOUNT ON;
  BEGIN
      BEGIN try
  
        select
            PM.ESAprojectID into #Temp1
        from AVL.PRJ_ConfigurationProgress A(nolock)
            join Avl.MAS_ProjectMaster PM ON A.ProjectID=PM.ProjectID
        where
            screenID=4
            and CompletionPercentage=100
            and A.Isdeleted=0
            and PM.IsDeleted=0
 
        select
            ProjectID,
            STRING_AGG(CAST(AssociateID AS NVARCHAR(MAX)),',') WITHIN GROUP (ORDER BY AssociateID) AS Users
        from [ESA].[ProjectAssociates]
        where
            ProjectID in (select ESAprojectID from #Temp1) Group By ProjectID;

      END try

      BEGIN catch
          DECLARE @ErrorMessage VARCHAR(5000);
          SELECT @ErrorMessage = Error_message()
          EXEC AVL_InsertError '[AVL].[GetActiveUserdetails]', @ErrorMessage, 0,0
      END catch
      SET NOCOUNT OFF;
  END
