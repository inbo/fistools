# Populate agouti_imager_seq_done

A script to retrieve locally available seq_done files upload the
sequences to the
[agouti_imager_seq_done](https://docs.google.com/spreadsheets/d/1PcqJziXm-ZNbCi2JJliQH_FQY8YMPXNEGgYwiiP2Ws8/edit?gid=0#gid=0)
googlesheet.

## Usage

``` r
populate_agouti_imager_seq_done(
  dir = NULL,
  seqID = NULL,
  email = Sys.getenv("email"),
  sheet_id = "1PcqJziXm-ZNbCi2JJliQH_FQY8YMPXNEGgYwiiP2Ws8"
)
```

## Arguments

- dir:

  a character string specifying the directory to look for `seq_done.csv`

- seqID:

  a character list of sequences to add

- email:

  a character specifying your email used to authenticate googlesheet

- sheet_id:

  the character string of the
  [agouti_imager_seq_done](https://docs.google.com/spreadsheets/d/1PcqJziXm-ZNbCi2JJliQH_FQY8YMPXNEGgYwiiP2Ws8/edit?gid=0#gid=0)
  googlesheet

## Details

If both dir and seqID are provided the function will only add the
seqIDs.

## See also

Other agouti: [`agouti_imager()`](agouti_imager.md),
[`agouti_validate_ai()`](agouti_validate_ai.md),
[`depopulate_agouti_imager_seq_done()`](depopulate_agouti_imager_seq_done.md),
[`download_dep_media()`](download_dep_media.md),
[`download_seq_media()`](download_seq_media.md),
[`drg_example`](drg_example.md),
[`redo_non_tracked()`](redo_non_tracked.md),
[`rename_ct_files()`](rename_ct_files.md)

## Examples

``` r
if (FALSE) { # \dontrun{

seqID <- c("f9cfa2ac-36a5-45e0-bd84-2b3a5a234ee6",
"793b5057-90b3-47db-b400-96b2b31c9b59",
"53075b53-dd7b-41b0-b778-394f28e16268",
 "560c8d87-ec9a-43f2-adb9-d96a09f589ef",
  "7b2d6285-34af-4bd3-b9f9-40022a267ad8")

populate_agouti_imager_seq_done(seqID = seqID)
} # }
```
