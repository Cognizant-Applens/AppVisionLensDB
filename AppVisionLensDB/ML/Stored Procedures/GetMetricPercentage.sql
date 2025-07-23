  
  
-- =============================================    
-- Author:  <Author,,Name>    
-- Create date: <Create Date,,>    
-- Description: <Description,,>    
-- =============================================    
CREATE PROCEDURE [ML].[GetMetricPercentage]    
     
AS    
BEGIN    
 SET NOCOUNT ON;    
    
   SELECT [MetricName]    
   ,[PercentFrom]    
   ,[PercentTo]    
   ,[ColorCode] from [ML].[MetricConfigPercentage]    
END 