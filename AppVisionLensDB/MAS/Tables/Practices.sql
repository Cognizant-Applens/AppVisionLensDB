CREATE TABLE [MAS].[Practices] (
    [PracticeID]        INT            IDENTITY (1, 1) NOT NULL,
    [PracticeName]      NVARCHAR (100) NOT NULL,
    [ESAHorizontalCode] NVARCHAR (60)  NULL,
    [IsDeleted]         BIT            CONSTRAINT [DF__Practices__IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]         NVARCHAR (50)  NOT NULL,
    [CreatedDate]       DATETIME       NOT NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [ModifiedDate]      DATETIME       NULL,
    CONSTRAINT [PK__Practices] PRIMARY KEY CLUSTERED ([PracticeID] ASC),
    CONSTRAINT [UQ__Practices] UNIQUE NONCLUSTERED ([ESAHorizontalCode] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Practices]
    ON [MAS].[Practices]([IsDeleted] ASC)
    INCLUDE([PracticeName]);

