CREATE PROCEDURE [ML].[CLandManualReviewWeekDetails]  --21,0,'2024-07-06'                                             
@TransactionID BIGINT ,         
@IsManual BIT,  
@DeploymentDate nvarchar(50)  
         
  
AS                                                      
BEGIN                                                        
BEGIN TRY    
Declare @DeployDate DateTime = @DeploymentDate;  
DECLARE @IsApp bit
  SET @IsApp =(Select Case when SupportTypeId=1 THEN 1 ELSE 0 END
  from ML.TRN_MLTransaction WHERE TransactionId=@TransactionId);
  
 IF OBJECT_ID(N'tempdb..#ReviewDetails') IS NOT NULL            
 BEGIN DROP TABLE #ReviewDetails END        
 Select IDENTITY(INT,1,1) AS ID,Fromdate AS StartDate,Todate AS EndDate,[FileName] into #ReviewDetails        
 from [ML].[CLandManualClassificationReviewDetails](NOLOCK)        
 where MLTransactionId = @TransactionID AND IsManual = (CASE WHEN @IsManual=1 THEN 1 ELSE 0 END)        
      
 IF OBJECT_ID(N'tempdb..#WeekRangeSplittedDates') IS NOT NULL            
 BEGIN DROP TABLE #WeekRangeSplittedDates END       
 CREATE TABLE #WeekRangeSplittedDates(        
  StartDate DateTime,        
  EndDate DateTime        
 )        
        
 DECLARE @current_id INT;                
 SELECT @current_id = (select MIN(Id) FROM #ReviewDetails)                
                
 WHILE @current_id <= (select MAX(Id) FROM #ReviewDetails)                
 BEGIN        
        
 Declare @StartDate DateTime;        
 Declare @EndDate DateTime;          
 SELECT @StartDate = (select StartDate FROM #ReviewDetails where id = @current_id)                
 SELECT @EndDate = (select EndDate FROM #ReviewDetails where id = @current_id)         
        
 ------------------ Date Calculation ------------------        
        
 ;with cte as        
 (        
  select @StartDate StartDate,         
    DATEADD(wk, DATEDIFF(wk, 0, @StartDate), 6) EndDate        
  union all        
  select dateadd(ww, 1, StartDate),        
    dateadd(ww, 1, EndDate)        
  from cte        
  where dateadd(ww, 1, StartDate)<=  @EndDate        
 )        
 Insert Into #WeekRangeSplittedDates        
 select * from cte        
                
 SELECT @current_id = (select MIN(Id) FROM #ReviewDetails WHERE Id > @current_id)         
 END        
        
 --select * from #WeekRangeSplittedDates     
     
 ----------------------- Last 3 Months Date --------------------    
 IF OBJECT_ID(N'tempdb..#Last3MonthDates') IS NOT NULL            
 BEGIN DROP TABLE #Last3MonthDates END      
 CREATE TABLE #Last3MonthDates(        
  StartDate DateTime,        
  EndDate DateTime        
 )     
    
 DECLARE @gridEndDate DateTime = GETDATE() --(SELECT DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6));     
 DECLARE @threeMonthBeforeDate DateTime = (select DATEADD(MONTH, -3, (SELECT DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6))))    
  
  IF (@threeMonthBeforeDate <= @DeployDate)  
   BEGIN   
   SET @threeMonthBeforeDate = @DeployDate  
   END  
  
 DECLARE @gridStartDate DateTime = (SELECT DATEADD(DAY, (DATEDIFF(DAY, 0, @threeMonthBeforeDate) / 7) * 7 + 7, 0));    
   --2024-04-21 00:00:00.000   
   -- 2024 - 07-06  
    
  
  
 ;with cte as        
 (        
  select @gridStartDate StartDate,         
    DATEADD(wk, DATEDIFF(wk, 0, @gridStartDate), 6) EndDate        
  union all        
  select dateadd(ww, 1, StartDate),        
    dateadd(ww, 1, EndDate)        
  from cte        
  where dateadd(ww, 1, StartDate)<=  @gridEndDate        
 )      
     
 Insert Into #Last3MonthDates        
 select * from cte     
  
    
    
 IF OBJECT_ID(N'tempdb..#GridDetails') IS NOT NULL            
 BEGIN DROP TABLE #GridDetails END    
    
   
  select @TransactionID as TransactionId, T1.StartDate as StartDate,T1.EndDate as EndDate,    
  convert(nvarchar(50), T1.StartDate, 103)+'-'+convert(nvarchar(50), T1.EndDate, 103) as Weekdetail,    
  @IsManual AS IsManual    
  into #GridDetails  
  from #Last3MonthDates T1    
  LEFT JOIN #WeekRangeSplittedDates T2 ON    
  T1.StartDate=T2.StartDate AND T1.EndDate=T2.EndDate    
   ORDER BY StartDate desc    
    
  
  SELECT Weekdetail, 0 as ReviewedTicketCount, 0 as  UnReviewedTicketCount,  
  0 as ReviewedClusterCount, 0 as UnReviewedClusterCount,StartDate,EndDate  
  into #finalTemp  
  FROM #GridDetails GD    
  WHERE TransactionId = @TransactionID    
  AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
  ORDER BY GD.StartDate desc    
  
  -- Reviewed Tickets 
	create table #ReviewedTickets(  
	Weekdetail nvarchar(1000),  
	Counts Int  
	)  
  IF(@IsApp = 1)
  BEGIN
	  INSERT into #ReviewedTickets
	  Select Weekdetail,Count(TicketId) as Counts 
	  from ML.TRN_ClusteringTicketValidation_app(NOLOCK)  T1  
	  join  #GridDetails GD  on  
	  T1.MlTransactionId=GD.TransactionId  
	  WHERE  T1.CLJobRunDate between GD.StartDate and GD.EndDate    
	  AND TransactionId =  @TransactionID   
	  AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
	  and T1.TicketType NOT IN ('LT002') and ISNULL(T1.IsCLReviewCompleted,0) = 1   
	  and NOT(T1.ClusterID_Desc = 0 and T1.ClusterID_Resolution = 0)   
	  AND isnull(T1.IsManualClassification,0) = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END  
	  GROUP BY Weekdetail  
  END
  ELSE
  BEGIN
	  INSERT into #ReviewedTickets
	  Select Weekdetail,Count(TicketId) as Counts  
	  from ML.TRN_ClusteringTicketValidation_infra(NOLOCK)  T1  
	  join  #GridDetails GD  on  
	  T1.MlTransactionId=GD.TransactionId  
	  WHERE  T1.CLJobRunDate between GD.StartDate and GD.EndDate    
	  AND TransactionId =  @TransactionID   
	  AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
	  and T1.TicketType NOT IN ('LT002') and ISNULL(T1.IsCLReviewCompleted,0) = 1   
	  and NOT(T1.ClusterID_Desc = 0 and T1.ClusterID_Resolution = 0)   
	  AND isnull(T1.IsManualClassification,0) = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END  
	  GROUP BY Weekdetail  
  END
  
   create table #UnReviewedTickets(  
   Weekdetail nvarchar(1000),  
   Counts Int  
   )  
  
   IF(@IsManual = 1)  
   BEGIN  
     IF(@IsApp = 1)
	  BEGIN
	   INSERT INTO #UnReviewedTickets  
	   Select Weekdetail,Count(TicketId) as Counts  
	   from ML.TRN_ClusteringTicketValidation_app(NOLOCK)  T1  
	   join  #GridDetails GD  on  
	   T1.MlTransactionId=GD.TransactionId  
	   WHERE  T1.CLJobRunDate between GD.StartDate and GD.EndDate    
	   AND TransactionId = @TransactionID    
	   AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
	   and T1.TicketType NOT IN ('LT002') and ISNULL(T1.IsCLReviewCompleted,0) <>1   
	   and NOT(T1.ClusterID_Desc = 0 and T1.ClusterID_Resolution = 0)   
	   AND ISNULL(T1.DebtClassificationId,0)=0 AND ISNULL(T1.AvoidableFlagID,0)=0 AND ISNULL(T1.ResidualDebtID,0)=0  
	   GROUP BY Weekdetail 
	  END
	  ELSE
	  BEGIN
		INSERT INTO #UnReviewedTickets  
		Select Weekdetail,Count(TicketId) as Counts  
		from ML.TRN_ClusteringTicketValidation_infra(NOLOCK)  T1  
		join  #GridDetails GD  on  
		T1.MlTransactionId=GD.TransactionId  
		WHERE  T1.CLJobRunDate between GD.StartDate and GD.EndDate    
		AND TransactionId = @TransactionID    
		AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
		and T1.TicketType NOT IN ('LT002') and ISNULL(T1.IsCLReviewCompleted,0) <>1   
		and NOT(T1.ClusterID_Desc = 0 and T1.ClusterID_Resolution = 0)   
		AND ISNULL(T1.DebtClassificationId,0)=0 AND ISNULL(T1.AvoidableFlagID,0)=0 AND ISNULL(T1.ResidualDebtID,0)=0  
		GROUP BY Weekdetail
	  END
   END  
   ELSE  
   BEGIN  
    IF(@IsApp = 1)
	BEGIN
		INSERT INTO #UnReviewedTickets  
		Select Weekdetail,Count(TicketId) as Counts  
		from ML.TRN_ClusteringTicketValidation_app(NOLOCK)  T1  
		join  #GridDetails GD  on  
		T1.MlTransactionId=GD.TransactionId  
		WHERE  T1.CLJobRunDate between GD.StartDate and GD.EndDate    
		AND TransactionId = @TransactionID    
		AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
		and T1.TicketType NOT IN ('LT002') and ISNULL(T1.IsCLReviewCompleted,0) <>1   
		and NOT(T1.ClusterID_Desc = 0 and T1.ClusterID_Resolution = 0)   
		AND ISNULL(T1.DebtClassificationId,0)<>0 AND ISNULL(T1.AvoidableFlagID,0)<>0 AND ISNULL(T1.ResidualDebtID,0)<>0  
		GROUP BY Weekdetail 
	END
	ELSE
	BEGIN
	INSERT INTO #UnReviewedTickets  
		Select Weekdetail,Count(TicketId) as Counts  
		from ML.TRN_ClusteringTicketValidation_infra(NOLOCK)  T1  
		join  #GridDetails GD  on  
		T1.MlTransactionId=GD.TransactionId  
		WHERE  T1.CLJobRunDate between GD.StartDate and GD.EndDate    
		AND TransactionId = @TransactionID    
		AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
		and T1.TicketType NOT IN ('LT002') and ISNULL(T1.IsCLReviewCompleted,0) <>1   
		and NOT(T1.ClusterID_Desc = 0 and T1.ClusterID_Resolution = 0)   
		AND ISNULL(T1.DebtClassificationId,0)<>0 AND ISNULL(T1.AvoidableFlagID,0)<>0 AND ISNULL(T1.ResidualDebtID,0)<>0  
		GROUP BY Weekdetail 
	END
   END  
   -- Reviewed Clusters 
   create table #ReviewedClusters(  
   Weekdetail nvarchar(1000),  
   Counts Int  
   )  
   IF(@IsApp = 1)
   BEGIN
     INSERT into #ReviewedClusters
     Select Weekdetail,Count(Distinct NULLIF(ClusterID_Desc,0)) as Counts     
	 from ML.TRN_ClusteringTicketValidation_app(NOLOCK)  T1  
	 join  #GridDetails GD  on  
	 T1.MlTransactionId=GD.TransactionId  
	 WHERE  T1.CLJobRunDate between GD.StartDate and GD.EndDate    
	 AND TransactionId = @TransactionID   
	 AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
     and T1.TicketType NOT IN ('LT002') and ISNULL(T1.IsCLReviewCompleted,0) = 1   
     AND isnull(T1.IsManualClassification,0) = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END  
     GROUP BY Weekdetail 
	END	 
	ELSE
	BEGIN
	 INSERT into #ReviewedClusters
	 Select Weekdetail,Count(Distinct NULLIF(ClusterID_Desc,0)) as Counts 
	 from ML.TRN_ClusteringTicketValidation_infra(NOLOCK)  T1  
	 join  #GridDetails GD  on  
	 T1.MlTransactionId=GD.TransactionId  
	 WHERE  T1.CLJobRunDate between GD.StartDate and GD.EndDate    
	 AND TransactionId = @TransactionID   
	 AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
     and T1.TicketType NOT IN ('LT002') and ISNULL(T1.IsCLReviewCompleted,0) = 1   
     AND isnull(T1.IsManualClassification,0) = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END  
     GROUP BY Weekdetail 
	END
  
   -- Unreviewed Clusters  
  
     
     create table #UnreviewedClusters(  
   Weekdetail nvarchar(1000),  
   Counts Int  
   )  
  
   IF(@IsManual = 1)  
   BEGIN 
     IF(@IsApp = 1)
	 BEGIN
		INSERT INTO #UnreviewedClusters   
		Select Weekdetail,Count(Distinct NULLIF(ClusterID_Desc,0)) as Counts  
		from ML.TRN_ClusteringTicketValidation_app(NOLOCK)  T1  
		join  #GridDetails GD  on  
		T1.MlTransactionId=GD.TransactionId  
		WHERE  T1.CLJobRunDate between GD.StartDate and GD.EndDate    
		AND TransactionId = @TransactionID   
		AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
		and T1.TicketType NOT IN ('LT002') and ISNULL(T1.IsCLReviewCompleted,0) <> 1   
		AND ISNULL(T1.DebtClassificationId,0)=0 AND ISNULL(T1.AvoidableFlagID,0)=0 AND ISNULL(T1.ResidualDebtID,0)=0  
		GROUP BY Weekdetail  
	 END
	 ELSE
	 BEGIN
		INSERT INTO #UnreviewedClusters   
		Select Weekdetail,Count(Distinct NULLIF(ClusterID_Desc,0)) as Counts  
		from ML.TRN_ClusteringTicketValidation_infra(NOLOCK)  T1  
		join  #GridDetails GD  on  
		T1.MlTransactionId=GD.TransactionId  
		WHERE  T1.CLJobRunDate between GD.StartDate and GD.EndDate    
		AND TransactionId = @TransactionID   
		AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
		and T1.TicketType NOT IN ('LT002') and ISNULL(T1.IsCLReviewCompleted,0) <> 1   
		AND ISNULL(T1.DebtClassificationId,0)=0 AND ISNULL(T1.AvoidableFlagID,0)=0 AND ISNULL(T1.ResidualDebtID,0)=0  
		GROUP BY Weekdetail 
	 END
   END  
   ELSE   
   BEGIN  
     IF(@IsApp = 1)
	 BEGIN
		  INSERT INTO #UnreviewedClusters  
		  Select Weekdetail,Count(Distinct NULLIF(ClusterID_Desc,0)) as Counts  
		  from ML.TRN_ClusteringTicketValidation_app(NOLOCK)  T1  
		  join  #GridDetails GD  on  
		  T1.MlTransactionId=GD.TransactionId  
		  WHERE  T1.CLJobRunDate between GD.StartDate and GD.EndDate    
		  AND TransactionId = @TransactionID   
		  AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
		  and T1.TicketType NOT IN ('LT002') and ISNULL(T1.IsCLReviewCompleted,0) <> 1   
		  AND ISNULL(T1.DebtClassificationId,0)<>0 AND ISNULL(T1.AvoidableFlagID,0)<>0 AND ISNULL(T1.ResidualDebtID,0)<>0  
		  GROUP BY Weekdetail  
	 END
	 ELSE
	 BEGIN
		  INSERT INTO #UnreviewedClusters  
		  Select Weekdetail,Count(Distinct NULLIF(ClusterID_Desc,0)) as Counts  
		  from ML.TRN_ClusteringTicketValidation_infra(NOLOCK)  T1  
		  join  #GridDetails GD  on  
		  T1.MlTransactionId=GD.TransactionId  
		  WHERE  T1.CLJobRunDate between GD.StartDate and GD.EndDate    
		  AND TransactionId = @TransactionID   
		  AND IsManual = CASE WHEN @IsManual=1 THEN 1 ELSE 0 END    
		  and T1.TicketType NOT IN ('LT002') and ISNULL(T1.IsCLReviewCompleted,0) <> 1   
		  AND ISNULL(T1.DebtClassificationId,0)<>0 AND ISNULL(T1.AvoidableFlagID,0)<>0 AND ISNULL(T1.ResidualDebtID,0)<>0  
		  GROUP BY Weekdetail
	 END
   END  
  
   update ft set ft.ReviewedClusterCount = rc.counts  
   from #finaltemp ft  
   join #ReviewedClusters rc on rc.Weekdetail = ft.weekdetail   
  
      update ft set ft.UnReviewedClusterCount = rc.counts  
   from #finaltemp ft  
   join #UnReviewedClusters rc on rc.Weekdetail = ft.weekdetail   
  
      update ft set ft.ReviewedTicketCount = rc.counts  
   from #finaltemp ft  
   join #ReviewedTickets rc on rc.Weekdetail = ft.weekdetail   
  
      update ft set ft.UnReviewedTicketCount = rc.counts  
   from #finaltemp ft  
   join #UnReviewedTickets rc on rc.Weekdetail = ft.weekdetail   
  
  
   select * from #finaltemp order by startdate desc  
  
END TRY                                                      
BEGIN CATCH                                                                                  
                                   
 DECLARE @ErrorMessage NVARCHAR(4000);                                                                                            
 DECLARE @ErrorSeverity INT;                                                                                            
 DECLARE @ErrorState INT;                                            
                                                                               
select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();                                                                                
                                                              
   --INSERT Error                                                                                            
   EXEC AVL_InsertError '[ML].[CLandManualWeekDetails]',@ErrorMessage ,0,0                                                         
                                                                                        
END CATCH                                                                                         
END  