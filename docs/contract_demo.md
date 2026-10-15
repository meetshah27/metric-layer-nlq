# Contract enforcement demo

Every mart model in `rack-delivery-pipeline` has an enforced dbt model contract: each column is declared with an explicit `data_type` in `dbt/models/marts/_marts.yml`, and `contract: {enforced: true}` is set for the whole `marts` folder. A breaking change to a mart's columns fails the build before the table is replaced, so it never reaches the dashboard or the NLQ service.

Recorded 2026-10-15 on a throwaway branch (`contract-demo`) of `rack-delivery-pipeline`, against the local DuckDB target. The branch was deleted afterwards.

## The breaking change

A column that consumers read as a number becomes text:

```diff
--- a/dbt/models/marts/dim_site.sql
+++ b/dbt/models/marts/dim_site.sql
@@ -4,6 +4,6 @@ select
     site_name,
     site_region,
     country,
-    capacity_racks,
+    cast(capacity_racks as varchar) as capacity_racks,
     opened_date
 from {{ ref('stg_sites') }}
```

## The build fails

```
$ dbt build --target local --select dim_site
...
Completed with 1 error, 0 partial successes, and 0 warnings:
[ERROR]: in model dim_site (models\marts\dim_site.sql)
  Compilation Error in model dim_site (models\marts\dim_site.sql)
This model has an enforced contract that failed.
Please ensure the name, data_type, and number of columns in your contract match the columns in your model's definition.
| column_name    | definition_type | contract_type | mismatch_reason    |
| -------------- | --------------- | ------------- | ------------------ |
| capacity_racks | VARCHAR         | INTEGER       | data type mismatch |
> in macro assert_columns_equivalent (macros\relations\column\columns_spec_ddl.sql)
...
Done. PASS=0 WARN=0 ERROR=1 SKIP=4 NO-OP=0 REUSED=0 TOTAL=5
```

Exit code 1. The four tests on `dim_site` were skipped and the existing table was left as it was.

## Why it matters here

- The check runs before any data moves, in the same `dbt build` that CI runs on every push, so a breaking change fails the pull request rather than the dashboard.
- The NLQ service generates SQL from the column names and types in the marts. A silent type change would break generated queries, or worse, change their results.
- A deliberate breaking change follows the process in [GOVERNANCE.md](GOVERNANCE.md): a new model `version`, a deprecation window for the old one, and owner approval.

## After the demo

The change was reverted, the branch deleted, and `dbt build --select dim_site` passes again.
