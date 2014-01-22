# cbm

* A clone of the Cognitive Bias Modification application written in Elm. 
* A Demo is visible here: https://s3.amazonaws.com/cbm-elm/index.html
* The original implementation is here: http://baldwinlab.mcgill.ca/labmaterials/materials_BBC.html

## Install

### Host Libraries

Vagrant is used to provision an linux virtual machine in which to install the dependencies and compile and start the server.

Requires installation of (with tested versions):
* Virtual Box (4.3.6)
* Vagrant (1.4.3)

### Provisioning

The guest VM can then be provisioned using:

```bash
host:cbm$ ./cbm provision
```

## Use

To build the source and start the http server

```bash
host:cbm$ ./cbm up && ./cbm connect
guest:~$/ cd ./cbm
guest:cbm$ ./cbm build && ./cbm start
```

You can now browse to the web page using

```bash
host:cbm$ ./cbm browse
```
