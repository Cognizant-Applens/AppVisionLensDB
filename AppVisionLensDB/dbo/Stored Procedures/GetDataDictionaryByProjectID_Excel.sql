/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


   --exec [GetDataDictionaryByProjectID_Excel] 74,1013,10411
--exec GetDataDictionaryByProjectID 4,12,50
--exec [GetDataDictionaryByProjectID_Excel] 73,0,0
CREATE PROC [dbo].[GetDataDictionaryByProjectID_Excel] 
(
@ProjectID int,
@ApplicationID int,
@PortfolioID int
)
AS
BEGIN
set @ApplicationID=0;
set @PortfolioID=0;
Select * into #reasonresidual from (Select ReasonResidualID,ReasonResidualName from [AVL].[TK_MAS_ReasonForResidual] where isDeleted=0 
Union All
select ReasonResidualID,ReasonResidualName from [AVL].[Data_others_ReasonForResidual] where isDeleted=0
And ProjectID=@ProjectID)as ReasonResidual

SELECT distinct [ID]
      ,DD.[ProjectID]
	  ,PM.ProjectName
      ,DD.[ApplicationID]
	  ,AD.ApplicationName
      ,DD.[CauseCodeID]
	  ,CC.CauseCode
      ,DD.[ResolutionCodeID]
	  ,RC.ResolutionCode
      ,DD.[DebtClassificationID]
	  ,DC.DebtClassificationName
      ,DD.[AvoidableFlagID]
	  ,AF.AvoidableFlagName
      ,DD.[ResidualDebtID]
	  ,RD.ResidualDebtName
      ,DD.[ReasonForResidual]
	  ,RFR.ReasonResidualName
	  --,DD.[ExpectedCompletionDate]
	  ,case when convert(varchar, DD.[ExpectedCompletionDate], 101)='01/01/1900' then '' else convert(varchar, DD.[ExpectedCompletionDate], 101) end as ExpectedCompletionDate
      ,DD.[IsDeleted]
      ,DD.[CreatedBy]
      ,DD.[CreatedDate]
      ,DD.[ModifiedBy]
      ,DD.[ModifiedDate]
	 into #temp
	FROM [AVL].[Debt_MAS_ProjectDataDictionary] DD
    join AVL.MAS_ProjectMaster PM on PM.ProjectID=DD.ProjectID and PM.ProjectID=@ProjectID
	inner join AVL.APP_MAS_ApplicationDetails AD on AD.ApplicationID=DD.ApplicationID and AD.IsActive=1
	inner join [AVL].[APP_MAP_ApplicationProjectMapping] APPPM on APPPM.ProjectID=DD.ProjectID and APPPM.ProjectID=@ProjectID
	inner join AVL.DEBT_MAP_ResolutionCode RC on RC.ResolutionID=DD.ResolutionCodeID and RC.ProjectID=@ProjectID
	Inner join AVL.DEBT_MAP_CauseCode CC on CC.CauseID=DD.CauseCodeID and CC.ProjectID=@ProjectID
	inner join AVl.DEBT_MAS_DebtClassification DC on DC.DebtClassificationID=DD.DebtClassificationID
	inner join AVL.DEBT_MAS_AvoidableFlag AF on AF.AvoidableFlagID=DD.AvoidableFlagID
	inner join AVL.DEBT_MAS_ResidualDebt RD on RD.ResidualDebtID=DD.ResidualDebtID
	left join #reasonresidual RFR on RFR.ReasonResidualID=DD.ReasonForResidual
	inner join
	(
	SELECT DISTINCT BC.BusinessClusterMapID PortfolioId,BusinessClusterBaseName,LM.ProjectID 	FROM AVL.APP_MAS_ApplicationDetails AD JOIN					   AVL.BusinessClusterMapping BC	ON	AD.SubBusinessClusterMapID=BC.BusinessClusterMapID 	JOIN
			AVL.MAS_LoginMaster LM	ON	BC.CustomerID=LM.CustomerID	WHERE 
			BC.IsHavingSubBusinesss=0 	AND	 BC.IsDeleted=0 AND	AD.IsActive=1
	) Portfolio on Portfolio.ProjectId= DD.ProjectID

  where DD.ProjectID=@ProjectID and (Portfolio.PortfolioId=case when @portfolioId =0 then Portfolio.PortfolioId else  @portfolioId end) and (DD.ApplicationID =case when @ApplicationID =0 then  DD.ApplicationID else  @ApplicationId end) and DD.IsDeleted=0
 

 declare @applicationMaster table (
 ApplicationId int,
 ApplicationName varchar(255)  
 )
 
 insert into @applicationMaster
 exec [AVL].[Effort_GetApplicationDetails]  @projectId
 
 
  declare @ResolutionMaster table (
 ResolutionId int,
 ResolutionName varchar(255)  
 )
insert into @ResolutionMaster
 exec [AVL].[ReMap_GetResolutionCodeDetails]  @projectId

   declare @CausecodeMaster table (
 CauseId int,
 CauseName varchar(255)  
 )
insert into @CausecodeMaster
 exec [AVL].[ReMap_GetCauseCodeDetails]  @projectId

 select ApplicationId, ApplicationName,ResolutionId,ResolutionName,CauseId,CauseName into #temp1 from @applicationMaster
  cross join @ResolutionMaster
   cross join  @CausecodeMaster

   select 
		  T1.[ApplicationID]
  		  ,T1.ApplicationName
		  ,T1.CauseId [CauseCodeID]
		  ,T1.CauseName CauseCode
		  ,T1.ResolutionId [ResolutionCodeID]
		  ,T1.ResolutionName ResolutionCode
		  ,[DebtClassificationID]
		  ,DebtClassificationName
		  ,[AvoidableFlagID]
		  ,AvoidableFlagName
		  ,[ResidualDebtID]
		  ,ResidualDebtName
		  ,[ReasonForResidual]
		  ,ReasonResidualName
		  ,ExpectedCompletionDate
		  ,[IsDeleted]
		  ,[CreatedBy]
		  ,[CreatedDate]
		  ,[ModifiedBy]
		  ,[ModifiedDate]
		  ,@ProjectID [ProjectID]
		  ,ProjectName
		  from #temp t right join #temp1 t1 on t.[ApplicationID]=t1.[ApplicationID] and
		  t.[CauseCodeID]=t1.CauseId and
		  t.[ResolutionCodeID]=t1.ResolutionId

		 
  END
