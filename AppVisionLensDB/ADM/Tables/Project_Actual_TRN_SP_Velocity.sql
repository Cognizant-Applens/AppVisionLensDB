CREATE TABLE [ADM].[Project_Actual_TRN_SP_Velocity] (
    [Project_SP_ID] BIGINT         IDENTITY (1, 1) NOT NULL,
    [BM_ID]         INT            NOT NULL,
    [ProjectID]     BIGINT         NOT NULL,
    [SP_per_Person] DECIMAL (5, 2) NOT NULL,
    [IsDeleted]     BIT            DEFAULT ((0)) NOT NULL,
    [CreatedBy]     NVARCHAR (50)  DEFAULT ('System') NOT NULL,
    [CreatedDate]   DATETIME       DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL,
    CONSTRAINT [PK_BM_ID_ProjectID] PRIMARY KEY CLUSTERED ([BM_ID] ASC, [ProjectID] ASC),
    CONSTRAINT [FK_BM_ID] FOREIGN KEY ([BM_ID]) REFERENCES [ADM].[AD_SP_Velocity_BM] ([BM_ID])
);

