CREATE TABLE [ADM].[ALM_TRN_Release_Details] (
    [ReleaseDetailsId]   BIGINT          IDENTITY (1, 1) NOT NULL,
    [ReleaseId]          NVARCHAR (100)  NOT NULL,
    [ProjectId]          BIGINT          NOT NULL,
    [ReleaseName]        NVARCHAR (250)  NOT NULL,
    [ReleaseDescription] NVARCHAR (1000) NULL,
    [StatusId]           BIGINT          NOT NULL,
    [PlannedStartDate]   DATETIME        NOT NULL,
    [PlannedEndDate]     DATETIME        NOT NULL,
    [ActualStartDate]    DATETIME        NULL,
    [ActualEndDate]      DATETIME        NULL,
    [PlannedDuration]    INT             NULL,
    [ActualDuration]     INT             NULL,
    [IsDeleted]          BIT             NOT NULL,
    [CreatedBy]          NVARCHAR (50)   NOT NULL,
    [CreatedDate]        DATETIME        NOT NULL,
    [ModifiedBy]         NVARCHAR (50)   NULL,
    [ModifiedDate]       DATETIME        NULL,
    CONSTRAINT [PK_ALM_TRN_Release_Details] PRIMARY KEY CLUSTERED ([ReleaseDetailsId] ASC),
    CONSTRAINT [FK_ALM_TRN_Release_Details_MAS_Status] FOREIGN KEY ([StatusId]) REFERENCES [ADM].[MAS_Source] ([SourceId])
);

