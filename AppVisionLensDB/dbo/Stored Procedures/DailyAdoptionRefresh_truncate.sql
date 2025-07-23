create procedure DailyAdoptionRefresh_truncate 
as begin
TRUNCATE TABLE [$(AVMCOEESADB)].[dbo].[RHMSProject] 
TRUNCATE TABLE [$(AVMCOEESADB)].dbo.GMSPMO_Associate  
TRUNCATE TABLE [$(AVMCOEESADB)].[dbo].[CentralRepository_Allocation]  
TRUNCATE TABLE [$(AVMCOEESADB)].[dbo].[RHMSParentCustomer]                                    
 TRUNCATE TABLE [$(AVMCOEESADB)].[dbo].[RHMSAccount]                  
TRUNCATE TABLE [$(AVMCOEESADB)].[dbo].[RHMSProjectManager]                  
end

                
