# Clouduploader

A blob uploader that takes a local file and uploads it to azure cloud storage

## Instalaiton

- Clone this repo
- Do not run install.sh with sudo
- Run `install.sh`, install.sh will ask for root privelages

## Usage

clouduploader [options] -f FILEPATH -n FILENAME <br>
-c &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Set Container Name<br>
-s &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Set Storage Acount<br>
-a &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Set a configuration path<br>
-o &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Overwrites currently saved blob with the same name<br>

## Configurations

Configurations are saved by default at /etc/clouduploader/clouduploader.config<br>
Configurations must follow the following structure:<br>
container_name=<your_variable> <br>
storage_account_name=<your_variable> <br>
