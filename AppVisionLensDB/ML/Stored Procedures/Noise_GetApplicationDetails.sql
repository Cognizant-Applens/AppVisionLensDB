CREATE PROCEDURE [ML].[Noise_GetApplicationDetails]     
 -- Add the parameters for the stored procedure here    
   (@ProjectId BIGINT)    
AS    
BEGIN    
begin try    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
    
    -- Insert statements for procedure here    
 SELECT AD.ApplicationID,AD.ApplicationName from [AVL].[APP_MAP_ApplicationProjectMapping] APM    
 Join [AVL].[APP_MAS_ApplicationDetails] AD on APM.ApplicationID = AD.ApplicationID    
 where APM.projectID = @ProjectId and APM.isdeleted = 0    
    
 end try    
 begin catch    
 declare @ErrorMessage varchar(max);    
 select @ErrorMessage=error_message()    
 exec AVL_InsertError '[ML].[Noise_GetApplicationDetails] ',    
 @ErrorMessage,    
 @ProjectId,    
 0    
END catch    
set nocount off;    
END
