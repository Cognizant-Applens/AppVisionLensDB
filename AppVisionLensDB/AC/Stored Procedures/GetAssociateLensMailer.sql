CREATE Procedure [AC].[GetAssociateLensMailer]   --'HalfYearly'
(  
@JobType nvarchar(50)  
)  
AS BEGIN  
BEGIN TRY  
Declare @TargetFromMonth int, @TargetToMonth int,  
        @TargetYear int,  
  @IsConfigured bit,@CurrentMonth int ,@CurrentYear int,@CurrentQuarter int,@Period nvarchar(20);  
  
Select @IsConfigured = IsConfigured from AC.AssociateLensMailerConfig WHERE JobType=@JobType  
SELECT @CurrentMonth=MONTH(GetDate());  
SELECT @CurrentYear=Year(GetDate());  
   
IF(@JobType ='Quarterly')  
BEGIN  
  
  
IF(@IsConfigured=0)  
BEGIN  
IF(@CurrentMonth Between 1 and 3)  
BEGIN  
SELECT @TargetYear = @CurrentYear-1, @TargetFromMonth = 9, @TargetToMonth=12  
SELECT @Period='Q4'+'-'+CAST(@TargetYear as VARCHAR)  
END  
ELSE IF(@CurrentMonth Between 4 and 6)  
BEGIN  
SELECT @TargetFromMonth = 1, @TargetToMonth=2, @TargetYear = @CurrentYear  
SELECT @Period='Q1'+'-'+CAST(@TargetYear as VARCHAR)  
END  
ELSE IF(@CurrentMonth Between 7 and 9)  
BEGIN  
SELECT @TargetFromMonth = 4, @TargetToMonth=6, @TargetYear = @CurrentYear  
SELECT @Period='Q2'+'-'+CAST(@TargetYear as VARCHAR)  
END  
ELSE IF(@CurrentMonth Between 10 and 12)  
BEGIN  
SELECT @TargetFromMonth = 7, @TargetToMonth=9, @TargetYear = @CurrentYear  
SELECT @Period='Q3'+'-'+CAST(@TargetYear as VARCHAR)  
END  
END  
  
ELSE  
BEGIN  
SELECT @TargetYear = SpecificYear,  
@TargetFromMonth = CASE WHEN SpecificPeriod=1 THEN 1 WHEN SpecificPeriod=2 THEN 4 WHEN SpecificPeriod=3 THEN 7 WHEN SpecificPeriod=4 THEN 10  END,  
@TargetToMonth= CASE WHEN SpecificPeriod=1 THEN 3 WHEN SpecificPeriod=2 THEN 6 WHEN SpecificPeriod=3 THEN 9 WHEN SpecificPeriod=4 THEN 12 END  
FROM AC.AssociateLensMailerConfig WHERE JobType = @JobType   
  
SELECT @Period = CASE WHEN @TargetFromMonth =1 THEN 'Q1'+'-'+CAST(@TargetYear as VARCHAR)   
       WHEN @TargetFromMonth =4 THEN 'Q2'+'-'+CAST(@TargetYear as VARCHAR)  
       WHEN @TargetFromMonth =7 THEN 'Q3'+'-'+CAST(@TargetYear as VARCHAR)  
       ELSE 'Q4'+'-'+CAST(@TargetYear as VARCHAR) END  
END  
  
END  
ELSE IF (@JobType='HalfYearly')  
BEGIN  
  
IF(@IsConfigured=0)  
BEGIN  
IF(@CurrentMonth Between 1 and 6)  
BEGIN  
SELECT @TargetYear = @CurrentYear-1, @TargetFromMonth = 7, @TargetToMonth=12  
SELECT @Period='H2'+'-'+CAST(@TargetYear as VARCHAR)  
END  
ELSE  
BEGIN  
SELECT @TargetFromMonth = 1, @TargetToMonth=6, @TargetYear = @CurrentYear  
SELECT @Period='H1'+'-'+CAST(@TargetYear as VARCHAR)  
END  
END  
  
ELSE  
BEGIN  
SELECT @TargetYear = SpecificYear,  
@TargetFromMonth = CASE WHEN SpecificPeriod=1 THEN 1 WHEN SpecificPeriod=2 THEN 7 END,  
@TargetToMonth= CASE WHEN SpecificPeriod=1 THEN 6 WHEN SpecificPeriod=2 THEN 12 END  
FROM AC.AssociateLensMailerConfig WHERE JobType = @JobType   
  
SELECT @Period = CASE WHEN @TargetFromMonth =1 THEN 'H1'+'-'+CAST(@TargetYear as VARCHAR) ELSE 'H2'+'-'+CAST(@TargetYear as VARCHAR) END  
END  
  
END  
ELSE IF (@JobType='Yearly')  
BEGIN  
SELECT @TargetFromMonth =1,@TargetToMonth = 12,@TargetYear = CASE WHEN  @IsConfigured = 0 THEN @CurrentYear-1 ELSE SpecificYear END  
FROM AC.AssociateLensMailerConfig WHERE JobType = @JobType  
SELECT @Period = @TargetYear  
END  
  
Select MAX(A.SuperVisor_Name) AS Supervisor,  
       MAX(TRIM(A1.AssociateId)) AS SupervisorId,  
       MAX(A.AssociateName)+'-'+MAX(A.AssociateId) AS Associate,  
       MAX(A.Email) AS AssociateMail,  
       MAX(A1.Email) AS SupervisorMail,  
   
  
    ISNULL(Count(PAV1.AttributeValueId),0) AS IronPillar,  
    ISNULL(Count(PAV2.AttributeValueId),0) AS AutomationMaster,  
    ISNULL(Count(PAV3.AttributeValueId),0) AS UltimateContributor,  
    ISNULL(Count(PAV4.AttributeValueId),0) AS HyperCitizen,  
    @Period AS [Period]  
  
  
From ESA.Associates(NOLOCK) A  
INNER JOIN AC.[TRN_Associate_Lens_Certification] AC ON AC.EmployeeId = A.AssociateId And AC.Isdeleted=0  
INNER JOIN ESA.Associates A1 ON A1.AssociateId = A.SuperVisor_Id And A1.IsActive=1  
LEFT JOIN MAS.PPAttributeValues PAV1 ON PAV1.AttributeValueId = AC.AwardId and PAV1.Isdeleted=0 and PAV1.AttributeValueName ='The Iron Pillar'  
LEFT JOIN MAS.PPAttributeValues PAV2 ON PAV2.AttributeValueId = AC.AwardId and PAV2.Isdeleted=0 and PAV2.AttributeValueName ='The Automation Master'  
LEFT JOIN MAS.PPAttributeValues PAV3 ON PAV3.AttributeValueId = AC.AwardId and PAV3.Isdeleted=0 and PAV3.AttributeValueName ='The Ultimate Contributor'  
LEFT JOIN MAS.PPAttributeValues PAV4 ON PAV4.AttributeValueId = AC.AwardId and PAV4.Isdeleted=0 and PAV4.AttributeValueName ='The Hyper Citizen'  
WHERE (AC.CertificationMonth BETWEEN @TargetFromMonth AND @TargetToMonth ) AND AC.CertificationYear = @TargetYear AND A.IsActive=1   
GROUP BY AC.EmployeeId   
  
END TRY  
BEGIN CATCH  
    
  DECLARE @ErrorMessage VARCHAR(4000);    
    
  SELECT @ErrorMessage = ERROR_MESSAGE()    
    
  --INSERT Error                                        
  EXEC AVL_InsertError 'AC.GetAssociateLensMailer',@ErrorMessage,0    
    
END CATCH  
END
