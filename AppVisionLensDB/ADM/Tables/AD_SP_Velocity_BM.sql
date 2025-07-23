CREATE TABLE [ADM].[AD_SP_Velocity_BM] (
    [BM_ID]                    INT            IDENTITY (1, 1) NOT NULL,
    [Month]                    TINYINT        NOT NULL,
    [Year]                     SMALLINT       NOT NULL,
    [Sprint_Duration_in_weeks] TINYINT        NOT NULL,
    [PoD_SizeID]               TINYINT        NOT NULL,
    [SP_Person]                DECIMAL (5, 2) NOT NULL,
    [LowerLimit]               DECIMAL (5, 2) NOT NULL,
    [UpperLimit]               DECIMAL (5, 2) NOT NULL,
    [IsDeleted]                BIT            DEFAULT ((0)) NOT NULL,
    [CreatedBy]                NVARCHAR (50)  DEFAULT ('System') NOT NULL,
    [CreatedDate]              DATETIME       DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]               NVARCHAR (50)  NULL,
    [ModifiedDate]             DATETIME       NULL,
    CONSTRAINT [PK_BM_ID] PRIMARY KEY CLUSTERED ([BM_ID] ASC),
    CONSTRAINT [FK_PoD_SizeID] FOREIGN KEY ([PoD_SizeID]) REFERENCES [ADM].[MAS_PoDSize] ([PoD_SizeID])
);

