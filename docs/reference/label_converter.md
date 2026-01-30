# label converter

Script to convert labelnummer, soort en/of labeltype en jaar into
afschotlabel

## Usage

``` r
label_converter(
  input,
  id_column,
  labelnummer_column,
  soort_column,
  labeltype_column = NULL,
  jaar_column,
  output_style = "eloket"
)
```

## Arguments

- input:

  a dataframe containing the necessary columns.

- id_column:

  a character string pointing to a column used to link result with
  input.

- labelnummer_column:

  a character string pointing to the column containing label numbers.

- soort_column:

  a character string pointing to the column containing species.

- labeltype_column:

  a character string pointing to the column containing label types.

- jaar_column:

  a character string pointing to the column containing years.

- output_style:

  a character string specifying the output style. Can be "eloket" or
  "labo". Default is "eloket".

## Value

a dataframe containing 2 columns: id & label

## Details

The input dataframe should at least contain an id_column &
labelnummer_column other values can be 'hardcoded'.

## Examples

``` r
if (FALSE) { # \dontrun{

# provide a dataframe with the necessary columns
df <- data.frame(
  id = 1:1000,
  labelnummer = sample(1:1000, 1000, replace = TRUE),
  soort = sample(c("REE", "WILD ZWIJN", "DAMHERT"), 1000, replace = TRUE),
  labeltype = sample(c("REEKITS", "REEGEIT", "REEBOK", NA), 1000, replace = TRUE),
  jaar = sample(2018:2020, 1000, replace = TRUE)
)

labels <- label_converter(df, "id", "labelnummer", "soort", "labeltype", "jaar", "eloket")

# provide a dataframe with labelnummer & labeltype & hardcode soort & jaar
df <- data.frame(
id = 1:1000,
labelnummer = sample(1:1000, 1000, replace = TRUE),
labeltype = sample(c("REEKITS", "REEGEIT", "REEBOK", NA), 1000, replace = TRUE)
)

labels <- label_converter(df, "id", "labelnummer", "REE", "labeltype", 2020, "eloket")

# provide a dataframe with labelnummer & soort & hardcode labeltype & jaar

df <- data.frame(
id = 1:1000,
labelnummer = sample(1:1000, 1000, replace = TRUE),
soort = sample(c("REE", "WILD ZWIJN", "DAMHERT"), 1000, replace = TRUE))

labels <- label_converter(df, "id", "labelnummer", "soort", "REEKITS", 2020, "eloket")

# provide a dataframe with mixed labelnummers & labeltype & hardcode soort & jaar
## remark: run the function once prior to testing
df <- labels %>%
  left_join(df %>% select(-labelnummer), by = "id") %>%
  add_row(id = setdiff(1:1000, labels$id)) %>%
  mutate(labelnummer = ifelse(is.na(labelnummer), sample(1:1000, 1000, replace = TRUE), labelnummer)) %>%
  mutate(labeltype = ifelse(is.na(labeltype), sample(c("REEKITS", "REEGEIT", "REEBOK", NA), 1000, replace = TRUE), labeltype))

labels <- label_converter(df, "id", "labelnummer", "REE", "labeltype", 2020, "eloket")

# to troubleshoot
df_test <- df[!df$id %in% labels$id,]

} # }
```
