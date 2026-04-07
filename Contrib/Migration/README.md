# Filters Migration

Starting with Wasabi v2.2.0.0, the backend migrated to SQLite for compact filter storage. If you still operate an older compatible deployment, this note explains how to migrate the historical plain-text filters.

## Migration Guide

### Using Nix

If you're deploying with `Nix`, migrating is straightforward. Simply run the following command on your server:

```bash
$ nix run github:nopara73/abw#migrateFilters

Database already exists. Skipping creation.
.....................................
Completed. Total processed: 371888, Total inserted: 371888
Max Block Height in DB: 853711
```
The migration tool will automatically process your filters and insert them into the new SQLite database.
The old filters will still be there untouched. We recommend to keep them for a while just in case a rollback
to a previous version is needed.


## Using dotnet

For those using dotnet, follow these steps:

* Clone the repository
* Navigate to the migration directory:
  ```
  $ cd <your abw repo dir>/Contrib/Migration
  ```
* Run the migration script:
  ```
  dotnet fsi migrateBackendFilters.fsx
  ```
