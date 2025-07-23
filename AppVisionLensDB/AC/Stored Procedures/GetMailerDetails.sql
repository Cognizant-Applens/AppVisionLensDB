/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [AC].[GetMailerDetails] (
 @Month int
)
 AS
BEGIN  
	SET NOCOUNT ON;  
	BEGIN TRY 
	

	  select projectID  into  #TempProject from [PP].[OplEsaData] where owningBU = 'ADM'
     DECLARE @CurrentYear AS INT   
  
IF (@month=12)  
BEGIN  
 SET   @CurrentYear = YEAR(GETDATE()) -1;  
END   
ELSE  
BEGIN  
 SET  @CurrentYear = YEAR(GETDATE());  
END
	 select PPAC.AttributeValueName AS CategoryName,PPA.AttributeValueName AS AwardName,LM.EmployeeId,LM.EmployeeName,LM.EmployeeEmail,ALC.AccountId,ALC.ProjectID,CM.CustomerName,  
	 DATENAME(mm,CONCAT('1900',FORMAT(CAST(ALC.CertificationMonth AS INT),'00'),'01')) AS Month,ALC.CertificationYear AS Year, PM.EsaProjectID 
	 into  #Temp
	 from [AC].[TRN_Associate_Lens_Certification] as ALC     
	 join avl.customer CM on cm.CustomerID = ALC.AccountId  
	 join [AVL].[MAS_LoginMaster] LM on LM.EmployeeID = ALC.EmployeeId and LM.CustomerID = ALC.AccountId and Lm.ProjectID = ALC.ProjectID  
	 join [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = ALC.ProjectID  
	 join [MAS].[PPAttributeValues]  PPAC on PPAC.AttributeValueID = ALC.CategoryId and ALC.AwardId = PPAC.ParentID  
	 join [MAS].[PPAttributeValues]  PPA on PPA.AttributeValueID = ALC.AwardId 
	 join #TempProject TP on TP.ProjectID = ALC.ProjectID  
	 where CertificationMonth = @Month AND CertificationYear= @CurrentYear


	 select  CategoryName,AwardName ,EmployeeId , EmployeeName , EmployeeEmail, AccountId,CustomerName , Month ,Year,
	 EsaProjectID = 
		STUFF((SELECT Distinct  ', ' + EsaProjectID
			   FROM #Temp b 
			   WHERE b.EmployeeId = t.EmployeeId and  b.AccountId = t.AccountId 
			  FOR XML PATH('')), 1, 2, '') ,
			  ProjectID = 
		STUFF((SELECT Distinct ', ' + cast(ProjectID as varchar(50))
			   FROM #Temp b 
			   WHERE b.EmployeeId = t.EmployeeId and  b.AccountId = t.AccountId 
			  FOR XML PATH('')), 1, 2, '') 
 
	 from #Temp t group by CategoryName,AwardName,EmployeeId , EmployeeName , EmployeeEmail, AccountId,CustomerName , Month ,Year

	 drop table #Temp
	
	     
	END TRY  
	BEGIN CATCH  
	DECLARE @errorMessage VARCHAR(MAX);  
  
	  SELECT @errorMessage = ERROR_MESSAGE()  
  
	  --INSERT Error      
	  EXEC AVL_InsertError '[AC].[GetMailerDetails]',@errorMessage,'',0  
	END CATCH  
End