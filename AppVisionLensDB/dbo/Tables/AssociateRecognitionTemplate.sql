CREATE TABLE [dbo].[AssociateRecognitionTemplate] (
    [AssociateRecogID]         INT            IDENTITY (1, 1) NOT NULL,
    [CategoryName]             NVARCHAR (50)  NULL,
    [AwardName]                NVARCHAR (50)  NULL,
    [EmployeeID]               NVARCHAR (50)  NULL,
    [ESAProjectID]             NVARCHAR (50)  NULL,
    [CertificationMonth]       TINYINT        NULL,
    [CertificationYear]        SMALLINT       NULL,
    [NoOfATicketsClosed]       INT            DEFAULT ((0)) NULL,
    [NoOfHTicketsClosed]       INT            DEFAULT ((0)) NULL,
    [IncReductionMonth]        INT            DEFAULT ((0)) NULL,
    [EffortReductionMonth]     INT            DEFAULT ((0)) NULL,
    [SolutionIdentified]       INT            DEFAULT ((0)) NULL,
    [NoOfKEDBCreatedApproved]  INT            DEFAULT ((0)) NULL,
    [NoOfCodeAssetContributed] INT            DEFAULT ((0)) NULL,
    [Remarks]                  NVARCHAR (200) NULL,
    [IsDeleted]                BIT            DEFAULT ((0)) NOT NULL,
    [CreatedDate]              DATETIME       DEFAULT (getdate()) NOT NULL,
    [ModifiedDate]             DATETIME       NULL,
    [CreatedBy]                NVARCHAR (50)  DEFAULT ('SYSTEM') NOT NULL,
    [ModifiedBy]               NVARCHAR (50)  NULL
);

