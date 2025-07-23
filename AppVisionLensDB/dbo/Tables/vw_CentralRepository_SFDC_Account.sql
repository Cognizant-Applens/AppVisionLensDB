CREATE TABLE [dbo].[vw_CentralRepository_SFDC_Account] (
    [Id]                                VARCHAR (50)  NOT NULL,
    [Name]                              VARCHAR (80)  NOT NULL,
    [Customer_Category__C]              VARCHAR (50)  NOT NULL,
    [Global_Market__C]                  VARCHAR (100) NOT NULL,
    [Vertical__C]                       VARCHAR (100) NOT NULL,
    [Crm_Status__C]                     VARCHAR (100) NOT NULL,
    [Financial_Ultimate_Customer_Id__C] VARCHAR (20)  NULL,
    [Peoplesoft_Customer_Id__C]         VARCHAR (15)  NOT NULL,
    [LastUpdatedDateTime]               DATETIME      NULL,
    [Global_Market_Id__c]               VARCHAR (255) NULL,
    [SBU1_Id__c]                        VARCHAR (255) NULL,
    [SBU2_Id__c]                        VARCHAR (255) NULL,
    [VerticalID__c]                     VARCHAR (255) NULL,
    [Sub_Vertical_Id__c]                VARCHAR (255) NULL,
    [RHMS_Vertical_Id__c]               VARCHAR (255) NULL,
    [RefreshDate]                       DATETIME      DEFAULT (getdate()) NOT NULL,
    [RefreshBy]                         VARCHAR (50)  DEFAULT ('GetCentralRepository_SFDC_Account') NULL
);

