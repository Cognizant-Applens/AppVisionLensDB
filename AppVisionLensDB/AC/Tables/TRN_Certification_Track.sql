CREATE TABLE [AC].[TRN_Certification_Track] (
    [Id]              BIGINT         IDENTITY (1, 1) NOT NULL,
    [CertificationId] BIGINT         NULL,
    [Module]          INT            NOT NULL,
    [ReferenceId]     NVARCHAR (100) NOT NULL,
    [Isdeleted]       BIT            NOT NULL,
    [CreatedDate]     DATETIME       NOT NULL,
    [CreatedBy]       NVARCHAR (50)  NOT NULL,
    [ModifiedDate]    DATETIME       NULL,
    [ModifiedBy]      NVARCHAR (50)  NULL,
    FOREIGN KEY ([CertificationId]) REFERENCES [AC].[TRN_Associate_Lens_Certification] ([CertificationId])
);

