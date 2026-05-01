-- =============================================================
-- FINAL SSIS SOURCE QUERIES
-- Source tables      : STAGING_E.dbo
-- Data warehouse     : DWH_E.dbo
-- Use in OLE DB Source
-- =============================================================

/* =============================================================
   STEP 1 — dim_occ
   ============================================================= */
SELECT DISTINCT
    LOWER(LTRIM(RTRIM(src.occ))) AS occ_name,
    NULL AS occ_name_clean,
    NULL AS occ_type
FROM (
    SELECT occ FROM STAGING_E.dbo.stg_dattes3_with_produit WHERE occ IS NOT NULL
    UNION
    SELECT occ FROM STAGING_E.dbo.stg_ho1 WHERE occ IS NOT NULL
    UNION
    SELECT occ FROM STAGING_E.dbo.stg_prod_div2_final WHERE occ IS NOT NULL
) src
WHERE NOT EXISTS (
    SELECT 1
    FROM DWH_E.dbo.dim_occ t
    WHERE t.occ_name = LOWER(LTRIM(RTRIM(src.occ)))
);

GO

/* =============================================================
   STEP 2 — dim_pays
   ============================================================= */
SELECT DISTINCT
    LTRIM(RTRIM(src.pays_exportation)) AS pays_name,
    NULL AS pays_name_clean,
    NULL AS continent,
    NULL AS region
FROM (
    SELECT [pays_exportation] FROM STAGING_E.dbo.stg_dattes3_with_produit
    UNION
    SELECT [pays_exportation] FROM STAGING_E.dbo.stg_ho1
    UNION
    SELECT [pays_exportation] FROM STAGING_E.dbo.stg_prod_div2_final
) src
WHERE src.[pays_exportation] IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM DWH_E.dbo.dim_pays t
    WHERE t.pays_name = LTRIM(RTRIM(src.[pays_exportation]))
);

GO

/* =============================================================
   STEP 3a — dim_produit (dattes)
   ============================================================= */
SELECT DISTINCT
    LTRIM(RTRIM(s.produit)) AS produit_name,
    NULL AS produit_name_clean,
    d.division_key,
    NULL AS categorie
FROM STAGING_E.dbo.stg_dattes3_with_produit s
CROSS JOIN (
    SELECT division_key
    FROM DWH_E.dbo.dim_division
    WHERE division_code = 'dattes'
) d
WHERE s.produit IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM DWH_E.dbo.dim_produit p
    WHERE p.produit_name = LTRIM(RTRIM(s.produit))
      AND p.division_key = d.division_key
);

GO

/* =============================================================
   STEP 3b — dim_produit (huile_olive)
   ============================================================= */
SELECT DISTINCT
    LTRIM(RTRIM(s.produit)) AS produit_name,
    NULL AS produit_name_clean,
    d.division_key,
    NULL AS categorie
FROM STAGING_E.dbo.stg_ho1 s
CROSS JOIN (
    SELECT division_key
    FROM DWH_E.dbo.dim_division
    WHERE division_code = 'huile_olive'
) d
WHERE s.produit IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM DWH_E.dbo.dim_produit p
    WHERE p.produit_name = LTRIM(RTRIM(s.produit))
      AND p.division_key = d.division_key
);

GO

/* =============================================================
   STEP 3c — dim_produit (div2)
   ============================================================= */
SELECT DISTINCT
    LTRIM(RTRIM(s.produit)) AS produit_name,
    NULL AS produit_name_clean,
    d.division_key,
    NULL AS categorie
FROM STAGING_E.dbo.stg_prod_div2_final s
CROSS JOIN (
    SELECT division_key
    FROM DWH_E.dbo.dim_division
    WHERE division_code = 'div2'
) d
WHERE s.produit IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM DWH_E.dbo.dim_produit p
    WHERE p.produit_name = LTRIM(RTRIM(s.produit))
      AND p.division_key = d.division_key
);

GO

/* =============================================================
   STEP 4a — fact_exportation (dattes)
   ============================================================= */
SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), TRY_CAST(s.[date_exportation] AS DATE), 112)) AS date_key,
    p.pays_key,
    pr.produit_key,
    o.occ_key,
    dv.division_key,
    NULL AS n_lot,
    NULL AS n_fact,
    NULL AS emballage,
    NULL AS monnaie,
    TRY_CAST(s.Quantite AS DECIMAL(18,4)) AS quantite,
    TRY_CAST(s.PU AS DECIMAL(18,4)) AS pu,
    TRY_CAST(s.PT AS DECIMAL(18,4)) AS pt,
    TRY_CAST(s.Devise AS DECIMAL(18,6)) AS devise,
    TRY_CAST(s.[eq_eu] AS DECIMAL(18,4)) AS eq_eu,
    TRY_CAST(s.[eq_dt] AS DECIMAL(18,4)) AS eq_dt,
    'stg_dattes3_with_produit' AS stg_source_table
FROM STAGING_E.dbo.stg_dattes3_with_produit s
JOIN DWH_E.dbo.dim_pays p
    ON p.pays_name = LTRIM(RTRIM(s.[pays_exportation]))
JOIN DWH_E.dbo.dim_occ o
    ON o.occ_name = LOWER(LTRIM(RTRIM(s.occ)))
JOIN DWH_E.dbo.dim_division dv
    ON dv.division_code = 'dattes'
JOIN DWH_E.dbo.dim_produit pr
    ON pr.produit_name = LTRIM(RTRIM(s.produit))
   AND pr.division_key = dv.division_key
WHERE TRY_CAST(s.[date_exportation] AS DATE) IS NOT NULL;

GO

/* =============================================================
   STEP 4b — fact_exportation (huile_olive)
   ============================================================= */
SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), TRY_CAST(s.[date_exportation] AS DATE), 112)) AS date_key,
    p.pays_key,
    pr.produit_key,
    o.occ_key,
    dv.division_key,
    NULL AS n_lot,
    NULL AS n_fact,
    NULL AS emballage,
    NULL AS monnaie,
    TRY_CAST(s.Quantite AS DECIMAL(18,4)) AS quantite,
    TRY_CAST(s.PU AS DECIMAL(18,4)) AS pu,
    TRY_CAST(s.PT AS DECIMAL(18,4)) AS pt,
    TRY_CAST(s.Devise AS DECIMAL(18,6)) AS devise,
    TRY_CAST(s.[eq_eu] AS DECIMAL(18,4)) AS eq_eu,
    TRY_CAST(s.[eq_dt] AS DECIMAL(18,4)) AS eq_dt,
    'stg_ho1' AS stg_source_table
FROM STAGING_E.dbo.stg_ho1 s
JOIN DWH_E.dbo.dim_pays p
    ON p.pays_name = LTRIM(RTRIM(s.[pays_exportation]))
JOIN DWH_E.dbo.dim_occ o
    ON o.occ_name = LOWER(LTRIM(RTRIM(s.occ)))
JOIN DWH_E.dbo.dim_division dv
    ON dv.division_code = 'huile_olive'
JOIN DWH_E.dbo.dim_produit pr
    ON pr.produit_name = LTRIM(RTRIM(s.produit))
   AND pr.division_key = dv.division_key
WHERE TRY_CAST(s.[date_exportation] AS DATE) IS NOT NULL;

GO

/* =============================================================
   STEP 4c — fact_exportation (div2)
   ============================================================= */
SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), TRY_CAST(s.[date_exportation] AS DATE), 112)) AS date_key,
    p.pays_key,
    pr.produit_key,
    o.occ_key,
    dv.division_key,
    NULL AS n_lot,
    s.N_Fact AS n_fact,
    s.Emballage AS emballage,
    s.Monnaie AS monnaie,
    TRY_CAST(s.Quantite AS DECIMAL(18,4)) AS quantite,
    TRY_CAST(s.PU AS DECIMAL(18,4)) AS pu,
    TRY_CAST(s.PT AS DECIMAL(18,4)) AS pt,
    TRY_CAST(s.Devise AS DECIMAL(18,6)) AS devise,
    TRY_CAST(s.[eq_eu] AS DECIMAL(18,4)) AS eq_eu,
    TRY_CAST(s.[eq_dt] AS DECIMAL(18,4)) AS eq_dt,
    'stg_prod_div2_final' AS stg_source_table
FROM STAGING_E.dbo.stg_prod_div2_final s
JOIN DWH_E.dbo.dim_pays p
    ON p.pays_name = LTRIM(RTRIM(s.[pays_exportation]))
JOIN DWH_E.dbo.dim_occ o
    ON o.occ_name = LOWER(LTRIM(RTRIM(s.occ)))
JOIN DWH_E.dbo.dim_division dv
    ON dv.division_code = 'div2'
JOIN DWH_E.dbo.dim_produit pr
    ON pr.produit_name = LTRIM(RTRIM(s.produit))
   AND pr.division_key = dv.division_key
WHERE TRY_CAST(s.[date_exportation] AS DATE) IS NOT NULL;

GO