# Snowflake source — setup

What you need to fill `SNOWFLAKE_*` in `.env`, plus the recommended least-privilege and
key-pair setup that satisfies the ticket's **security considerations** criterion.

## 1. Account locator (`SNOWFLAKE_ACCOUNT`)
Use the account identifier, e.g. `ab12345.eu-central-1` (locator + region) or `myorg-myaccount`
(org-account). It is the part before `.snowflakecomputing.com` in your Snowflake URL.

## 2. Least-privilege read-only role (run as ACCOUNTADMIN/SECURITYADMIN)
OpenMetadata only needs to **read metadata** (and query history for lineage). Do not grant write.

```sql
-- Dedicated warehouse + role for OpenMetadata
CREATE ROLE IF NOT EXISTS OPENMETADATA_ROLE;
CREATE WAREHOUSE IF NOT EXISTS OPENMETADATA_WH
  WITH WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE INITIALLY_SUSPENDED = TRUE;
GRANT USAGE ON WAREHOUSE OPENMETADATA_WH TO ROLE OPENMETADATA_ROLE;

-- Metadata read on the pilot database(s) — repeat per DB in scope
GRANT USAGE  ON DATABASE <DB>                   TO ROLE OPENMETADATA_ROLE;
GRANT USAGE  ON ALL SCHEMAS    IN DATABASE <DB> TO ROLE OPENMETADATA_ROLE;
GRANT USAGE  ON FUTURE SCHEMAS IN DATABASE <DB> TO ROLE OPENMETADATA_ROLE;
GRANT SELECT ON ALL TABLES     IN DATABASE <DB> TO ROLE OPENMETADATA_ROLE;
GRANT SELECT ON FUTURE TABLES  IN DATABASE <DB> TO ROLE OPENMETADATA_ROLE;
GRANT SELECT ON ALL VIEWS      IN DATABASE <DB> TO ROLE OPENMETADATA_ROLE;
GRANT SELECT ON FUTURE VIEWS   IN DATABASE <DB> TO ROLE OPENMETADATA_ROLE;

-- Required for lineage & usage (reads SNOWFLAKE.ACCOUNT_USAGE)
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE OPENMETADATA_ROLE;

-- Bind to the ingestion user
CREATE USER IF NOT EXISTS OPENMETADATA_USER
  DEFAULT_ROLE = OPENMETADATA_ROLE DEFAULT_WAREHOUSE = OPENMETADATA_WH;
GRANT ROLE OPENMETADATA_ROLE TO USER OPENMETADATA_USER;
```

Then in `.env`:
```
SNOWFLAKE_USER=OPENMETADATA_USER
SNOWFLAKE_ROLE=OPENMETADATA_ROLE
SNOWFLAKE_WAREHOUSE=OPENMETADATA_WH
SNOWFLAKE_DATABASE=<DB>        # or leave blank to ingest all visible databases
```

## 3. Authentication — prefer key-pair over password
Password auth works (`SNOWFLAKE_PASSWORD=...`) but key-pair is recommended for non-prod/prod.

```bash
# Generate an unencrypted PKCS#8 private key + public key
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
```
Register the public key on the user (strip the `-----BEGIN/END PUBLIC KEY-----` lines):
```sql
ALTER USER OPENMETADATA_USER SET RSA_PUBLIC_KEY='MIIBIjANBgkq...';
```
Configure `.env` (leave `SNOWFLAKE_PASSWORD` blank) and switch `snowflake.yaml` to the key-pair
lines (`privateKey` / `snowflakePrivatekeyPassphrase`, already present as comments):
```
SNOWFLAKE_PRIVATE_KEY=<contents of rsa_key.p8, including BEGIN/END lines>
# SNOWFLAKE_PRIVATE_KEY_PASSPHRASE=   # only if you created an encrypted key (-nocrypt omitted)
```
> `rsa_key.p8` / `rsa_key.pub` are gitignored. Keep the private key out of the repo and out of `.env`
> in pre-prod — use a secrets manager there.

## 4. Lineage
`snowflake_lineage.yaml` reads recent **query history** from `SNOWFLAKE.ACCOUNT_USAGE` (granted
above). Run it **after** the metadata ingest. Tune `queryLogDuration` (days) to your pilot. Note
`ACCOUNT_USAGE` has latency (up to ~3h) — very recent queries may not appear immediately.

## 5. Networking
Snowflake is reached over the public internet from the ingestion container — no host networking
needed. If your non-prod Snowflake enforces an **IP allowlist / network policy**, allowlist the
egress IP of the machine running ingestion.
