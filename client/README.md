# hostlint - run hostlint check scripts in batch and aggregate output

Hostlint checks are scripts that, upon succesful completion:

* return 0

* output nothing on the standard error

* output on the standard output matching
  /#{CHECK_NAME}\s\*:\s\*\[(OK|FAIL)\](\n#{BODY})?/

  Where CHECK_NAME is the name of the check, and the optional BODY contains
  details about the check

## dependencies
rubygem open4

## Config file options (See the config file for an example):

* :colo: colo

* :host: hostname

* :check_dir: directory of scripts to run

### Transports

Hostlint can output data in various YAML-based forms. They and their options
are specified under the :transports key. The currently implemented ones are
disk and post.

Disk writes yaml output to the corresponding local directory.

    :disk:
      :log_dir: "."


Post posts the data to a webserver, typically hostlint-server

    :post:
      :host: localhost
      :port: 9998

## Command line options take precedence over config file ones:

* -c FILE location of the config file

* -d DIR  directory of scripts to run

* -j N    run N jobs

* -v      print debugging information

* -u      allow running as a regular user
