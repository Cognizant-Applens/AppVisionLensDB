
CREATE PROCEDURE [AVL].[GetRHMSRoleDetails]    
AS     
 BEGIN    
  BEGIN TRY     
   DECLARE @PrimaryPortfolioName VARCHAR(20) = '%AVM'    
   DECLARE @PrimaryPortfolioFilter VARCHAR(20) = 'AVM-%'    
   DECLARE @IsActive BIT = 1   
    
        
  IF EXISTS(SELECT TOP 1 1 FROM          
     [CTSINTBMVPCRSR1].[CentralRepository_Report].[dbo].[vw_CentralRepository_RHMS_RoleMaster] AS rm        
     JOIN [CTSINTBMVPCRSR1].[CentralRepository_Report].[dbo].[vw_CentralRepository_RHMS_RoleDetails] AS rd        
     ON rm.RoleId = rd.RoleId        
     JOIN        
     [AVL].[RhmsRoleAccessLevels] AS ra         
     ON  rm.RoleName =  ra.RhmsRoleName        
    WHERE rd.ActiveFlag = 1         
    AND (rd.PrimaryPortfolioName  LIKE @PrimaryPortfolioName OR rd.PrimaryPortfolioName LIKE @PrimaryPortfolioFilter))

  BEGIN

	  TRUNCATE TABLE [AVL].[MigratedRhmsDetails]    
    
	  INSERT INTO [AVL].[MigratedRhmsDetails]    
	  SELECT DISTINCT    
		   rd.AssociateID,     
		   rd.PrimaryPortfolioName,    
		   rd.PrimaryPortfolioType,    
		   rd.PortfolioQualifier1Type,     
		   rd.PrimaryPortfolioId,    
		   rd.PortfolioQualifier1Id,    
		   rd.PortfolioQualifier1Name,    
		   rm.RoleName,    
		   ra.AccessLevel    
		  FROM      
		 [CTSINTBMVPCRSR1].[CentralRepository_Report].[dbo].[vw_CentralRepository_RHMS_RoleMaster] AS rm    
		 JOIN [CTSINTBMVPCRSR1].[CentralRepository_Report].[dbo].[vw_CentralRepository_RHMS_RoleDetails] AS rd    
		 ON rm.RoleId = rd.RoleId    
		 JOIN    
		 [AVL].[RhmsRoleAccessLevels] AS ra     
		 ON  rm.RoleName =  ra.RhmsRoleName    
		WHERE rd.ActiveFlag = @IsActive     
		AND (rd.PrimaryPortfolioName  LIKE @PrimaryPortfolioName OR rd.PrimaryPortfolioName LIKE @PrimaryPortfolioFilter) 
  END   
         
  END TRY     
    
  BEGIN CATCH      
       
     DECLARE @ErrorMessage VARCHAR(MAX);      
     SELECT @ErrorMessage = ERROR_MESSAGE()      
     --INSERT Error          
     EXEC AVL_InsertError '[AVL].[GetRHMSRoleDetails]', @ErrorMessage,0    
        
  END CATCH        
    
END