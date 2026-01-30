# install sp

Helper function that installs sp when missing, from a tarball.

## Usage

``` r
install_sp(force = FALSE)
```

## Arguments

- force:

  A logical indicating whether the installation should be forced

## Details

The "sp" package should be unloaded from the namespace when it is not
needed anymore. Every function that uses "sp" should start with a call
to this function. And end with a call to `unloadNamespace("sp")`. This
is because the "sp" package is known to cause conflicts with other
packages.

## Author

Sander Devisscher
