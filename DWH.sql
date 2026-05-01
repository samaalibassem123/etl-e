/* =============================================================
   DATA WAREHOUSE DDL + LOAD SCRIPT
   Source staging: STAGING_E.dbo
   Target DWH:     DWH_E.dbo
   SQL Server
   ============================================================= */

USE DWH_E;
GO

/* =============================================================
   1) DROP OBJECTS IF THEY ALREADY EXIST
   ============================================================= */

IF OBJECT_ID('dbo.vw_stg_exportation_unified', 'V') IS NOT NULL
    DROP VIEW dbo.vw_stg_exportation_unified;
GO

IF OBJECT_ID('dbo.FactExportation', 'U') IS NOT NULL
    DROP TABLE dbo.FactExportation;
GO

IF OBJECT_ID('dbo.DimDate', 'U') IS NOT NULL
    DROP TABLE dbo.DimDate;
GO

IF OBJECT_ID('dbo.DimOcc', 'U') IS NOT NULL
    DROP TABLE dbo.DimOcc;
GO

IF OBJECT_ID('dbo.DimPaysExportation', 'U') IS NOT NULL
    DROP TABLE dbo.DimPaysExportation;
GO

IF OBJECT_ID('dbo.DimProduit', 'U') IS NOT NULL
    DROP TABLE dbo.DimProduit;
GO

IF OBJECT_ID('dbo.DimDevise', 'U') IS NOT NULL
    DROP TABLE dbo.DimDevise;
GO


/* =============================================================
   2) DIMENSIONS
   ============================================================= */

CREATE TABLE dbo.DimDate (
    DateKey         INT           NOT NULL PRIMARY KEY,   -- YYYYMMDD
    FullDate        DATE          NOT NULL UNIQUE,
    [Year]          SMALLINT      NOT NULL,
    [Quarter]       TINYINT       NOT NULL,
    [Month]         TINYINT       NOT NULL,
    MonthName       NVARCHAR(20)  NOT NULL,
    [Day]           TINYINT       NOT NULL,
    DayName         NVARCHAR(20)  NOT NULL,
    WeekOfYear      TINYINT       NOT NULL,
    IsWeekend       BIT           NOT NULL
);
GO

CREATE TABLE dbo.DimOcc (
    OccKey      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Occ         NVARCHAR(50)      NOT NULL,
    CONSTRAINT UQ_DimOcc_Occ UNIQUE (Occ)
);
GO

CREATE TABLE dbo.DimPaysExportation (
    PaysKey             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PaysExportation     NVARCHAR(100)     NOT NULL,
    CONSTRAINT UQ_DimPaysExportation UNIQUE (PaysExportation)
);
GO

CREATE TABLE dbo.DimProduit (
    ProduitKey      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Produit         NVARCHAR(255)     NOT NULL,
    CONSTRAINT UQ_DimProduit UNIQUE (Produit)
);
GO

CREATE TABLE dbo.DimDevise (
    DeviseKey       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Devise          NVARCHAR(50)      NOT NULL,
    CONSTRAINT UQ_DimDevise UNIQUE (Devise)
);
GO


/* =============================================================
   3) FACT TABLE
   Grain = 1 row per source record
   ============================================================= */

CREATE TABLE dbo.FactExportation (
    FactKey         BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    DateKey         INT             NOT NULL,
    OccKey          INT             NOT NULL,
    PaysKey         INT             NOT NULL,
    ProduitKey      INT             NOT NULL,
    DeviseKey       INT             NOT NULL,

    Quantite        DECIMAL(18,4)   NULL,
    PU              DECIMAL(18,4)   NULL,
    PT              DECIMAL(18,4)   NULL,
    EQ_DT           DECIMAL(18,4)   NULL,
    EQ_EU           DECIMAL(18,4)   NULL,

    SourceFile      NVARCHAR(255)   NULL,
    LoadedAt        DATETIME2(0)    NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_FactExportation_DimDate
        FOREIGN KEY (DateKey) REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT FK_FactExportation_DimOcc
        FOREIGN KEY (OccKey) REFERENCES dbo.DimOcc(OccKey),

    CONSTRAINT FK_FactExportation_DimPaysExportation
        FOREIGN KEY (PaysKey) REFERENCES dbo.DimPaysExportation(PaysKey),

    CONSTRAINT FK_FactExportation_DimProduit
        FOREIGN KEY (ProduitKey) REFERENCES dbo.DimProduit(ProduitKey),

    CONSTRAINT FK_FactExportation_DimDevise
        FOREIGN KEY (DeviseKey) REFERENCES dbo.DimDevise(DeviseKey)
);
GO

CREATE INDEX IX_FactExportation_DateKey   ON dbo.FactExportation(DateKey);
CREATE INDEX IX_FactExportation_OccKey    ON dbo.FactExportation(OccKey);
CREATE INDEX IX_FactExportation_PaysKey   ON dbo.FactExportation(PaysKey);
CREATE INDEX IX_FactExportation_ProduitKey ON dbo.FactExportation(ProduitKey);
CREATE INDEX IX_FactExportation_DeviseKey ON dbo.FactExportation(DeviseKey);
GO


/* =============================================================
   4) UNIFIED VIEW OVER STAGING TABLES
   Source: STAGING_E.dbo.*
   ============================================================= */

CREATE VIEW dbo.vw_stg_exportation_unified
AS
    SELECT
        LTRIM(RTRIM(occ))              AS occ,
        LTRIM(RTRIM(date_exportation)) AS date_exportation,
        LTRIM(RTRIM(pays_exportation)) AS pays_exportation,
        LTRIM(RTRIM(quantite))         AS quantite,
        LTRIM(RTRIM(pu))               AS pu,
        LTRIM(RTRIM(pt))               AS pt,
        LTRIM(RTRIM(eq_dt))            AS eq_dt,
        LTRIM(RTRIM(eq_eu))            AS eq_eu,
        LTRIM(RTRIM(devise))           AS devise,
        LTRIM(RTRIM(produit))          AS produit,
        stg_source_file                AS source_file
    FROM STAGING_E.dbo.stg_dattes3_with_produit

    UNION ALL

    SELECT
        LTRIM(RTRIM(occ)),
        LTRIM(RTRIM(date_exportation)),
        LTRIM(RTRIM(pays_exportation)),
        LTRIM(RTRIM(quantite)),
        LTRIM(RTRIM(pu)),
        LTRIM(RTRIM(pt)),
        LTRIM(RTRIM(eq_dt)),
        LTRIM(RTRIM(eq_eu)),
        LTRIM(RTRIM(devise)),
        LTRIM(RTRIM(produit)),
        stg_source_file
    FROM STAGING_E.dbo.stg_ho1

    UNION ALL

    SELECT
        LTRIM(RTRIM(occ)),
        LTRIM(RTRIM(date_exportation)),
        LTRIM(RTRIM(pays_exportation)),
        LTRIM(RTRIM(quantite)),
        LTRIM(RTRIM(pu)),
        LTRIM(RTRIM(pt)),
        LTRIM(RTRIM(eq_dt)),
        LTRIM(RTRIM(eq_eu)),
        LTRIM(RTRIM(devise)),
        LTRIM(RTRIM(produit)),
        stg_source_file
    FROM STAGING_E.dbo.stg_prod_div2_final;
GO


/* =============================================================
   5) LOAD DIMENSIONS
   ============================================================= */

-- Date dimension from all valid dates in staging
INSERT INTO dbo.DimDate (DateKey, FullDate, [Year], [Quarter], [Month], MonthName, [Day], DayName, WeekOfYear, IsWeekend)
SELECT DISTINCT
    CONVERT(INT, FORMAT(ParsedDate, 'yyyyMMdd')) AS DateKey,
    ParsedDate                                   AS FullDate,
    YEAR(ParsedDate)                             AS [Year],
    DATEPART(QUARTER, ParsedDate)                AS [Quarter],
    MONTH(ParsedDate)                            AS [Month],
    DATENAME(MONTH, ParsedDate)                  AS MonthName,
    DAY(ParsedDate)                              AS [Day],
    DATENAME(WEEKDAY, ParsedDate)                AS DayName,
    DATEPART(ISO_WEEK, ParsedDate)               AS WeekOfYear,
    CASE WHEN DATENAME(WEEKDAY, ParsedDate) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS IsWeekend
FROM (
    SELECT DISTINCT
        COALESCE(
            TRY_CONVERT(date, date_exportation, 23),   -- yyyy-mm-dd
            TRY_CONVERT(date, date_exportation, 120),  -- yyyy-mm-dd hh:mi:ss
            TRY_CONVERT(date, date_exportation, 103),  -- dd/mm/yyyy
            TRY_CONVERT(date, date_exportation)        -- default
        ) AS ParsedDate
    FROM dbo.vw_stg_exportation_unified
) d
WHERE ParsedDate IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.DimDate x
      WHERE x.FullDate = d.ParsedDate
  );
GO

INSERT INTO dbo.DimOcc (Occ)
SELECT DISTINCT
    LOWER(LTRIM(RTRIM(occ))) AS Occ
FROM dbo.vw_stg_exportation_unified
WHERE NULLIF(LTRIM(RTRIM(occ)), '') IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.DimOcc d
      WHERE d.Occ = LOWER(LTRIM(RTRIM(vw_stg_exportation_unified.occ)))
  );
GO

INSERT INTO dbo.DimPaysExportation (PaysExportation)
SELECT DISTINCT
    LTRIM(RTRIM(pays_exportation)) AS PaysExportation
FROM dbo.vw_stg_exportation_unified
WHERE NULLIF(LTRIM(RTRIM(pays_exportation)), '') IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.DimPaysExportation d
      WHERE d.PaysExportation = LTRIM(RTRIM(vw_stg_exportation_unified.pays_exportation))
  );
GO

INSERT INTO dbo.DimProduit (Produit)
SELECT DISTINCT
    LTRIM(RTRIM(produit)) AS Produit
FROM dbo.vw_stg_exportation_unified
WHERE NULLIF(LTRIM(RTRIM(produit)), '') IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.DimProduit d
      WHERE d.Produit = LTRIM(RTRIM(vw_stg_exportation_unified.produit))
  );
GO

INSERT INTO dbo.DimDevise (Devise)
SELECT DISTINCT
    UPPER(LTRIM(RTRIM(devise))) AS Devise
FROM dbo.vw_stg_exportation_unified
WHERE NULLIF(LTRIM(RTRIM(devise)), '') IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.DimDevise d
      WHERE d.Devise = UPPER(LTRIM(RTRIM(vw_stg_exportation_unified.devise)))
  );
GO


/* =============================================================
   6) LOAD FACT TABLE
   ============================================================= */

INSERT INTO dbo.FactExportation
(
    DateKey,
    OccKey,
    PaysKey,
    ProduitKey,
    DeviseKey,
    Quantite,
    PU,
    PT,
    EQ_DT,
    EQ_EU,
    SourceFile
)
SELECT
    dd.DateKey,
    docc.OccKey,
    dp.PaysKey,
    dpr.ProduitKey,
    dv.DeviseKey,

    TRY_CONVERT(DECIMAL(18,4), REPLACE(NULLIF(s.quantite, ''), ',', '.')) AS Quantite,
    TRY_CONVERT(DECIMAL(18,4), REPLACE(NULLIF(s.pu, ''), ',', '.'))       AS PU,
    TRY_CONVERT(DECIMAL(18,4), REPLACE(NULLIF(s.pt, ''), ',', '.'))       AS PT,
    TRY_CONVERT(DECIMAL(18,4), REPLACE(NULLIF(s.eq_dt, ''), ',', '.'))    AS EQ_DT,
    TRY_CONVERT(DECIMAL(18,4), REPLACE(NULLIF(s.eq_eu, ''), ',', '.'))    AS EQ_EU,

    s.source_file
FROM dbo.vw_stg_exportation_unified s
CROSS APPLY (
    SELECT COALESCE(
        TRY_CONVERT(date, s.date_exportation, 23),
        TRY_CONVERT(date, s.date_exportation, 120),
        TRY_CONVERT(date, s.date_exportation, 103),
        TRY_CONVERT(date, s.date_exportation)
    ) AS ParsedDate
) p
INNER JOIN dbo.DimDate dd
    ON dd.FullDate = p.ParsedDate
INNER JOIN dbo.DimOcc docc
    ON docc.Occ = LOWER(LTRIM(RTRIM(s.occ)))
INNER JOIN dbo.DimPaysExportation dp
    ON dp.PaysExportation = LTRIM(RTRIM(s.pays_exportation))
INNER JOIN dbo.DimProduit dpr
    ON dpr.Produit = LTRIM(RTRIM(s.produit))
INNER JOIN dbo.DimDevise dv
    ON dv.Devise = UPPER(LTRIM(RTRIM(s.devise)))
WHERE p.ParsedDate IS NOT NULL;
GO