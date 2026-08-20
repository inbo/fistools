# Close localhost connection

A local host connection will remain open unless closed therefor you
should use this function to close it. This function uses
`get_active_localhost` under the hood to collect a list of active
localhost connections on a given port.

## Usage

``` r
end_localhost_connection(port = 5555)
```

## Arguments

- port:

  connection port of the localhost instance, default = 5555

## See also

[`start_localhost_connection()`](start_localhost_connection.md)

## Author

Jens Polspoel

Sander Devisscher
