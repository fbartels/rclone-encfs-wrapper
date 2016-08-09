# rclone-encfs-wrapper
Wrapper script that uses an encfs reverse mount to encrypt before upload.

PLEASE NOTICE: EncFS is regarded as potentially unsecure, since an attacker that has multiple copies of the same scnrypted file might be able to calculate the encryption key. Please see https://defuse.ca/audits/encfs.htm for more information.

I have put some words of reasoning behind this wrapper into a [blog post](http://blog.host-consultants.de/2016/08/backups-in-die-amazon-cloud-schieben/) (in german). If you are looking for a way to mount your cloud backup have a look at my [mount-encfs-cloud](https://github.com/fbartels/mount-encfs-cloud) script.

# Setup & usage
The script requires that encfs and [rclone](https://github.com/ncw/rclone) are already installed, [rclone is configured](http://rclone.org/docs/) and will fail if these requirements are not met.

## Configuration
Additionally the ```config-example``` file has to be renamed to ```config``` and adapted to the local environment.


```
SOURCECLEARTEXT=/backup/data                    # local directory that should be backed up
RCLONE_REMOTE="acd"                             # name of the remote configured in rclone
RCLONE_PATH="backup"                            # directory at cloud provider, will be created if it does not exist
ENCFS_PASSWORD=$HOME/.config/encfs-password
ENCFS_CONFIG=$HOME/.config/encfs-cloud.xml
```
```RCLONE_REMOTE``` must be the name of a valid configured storage provider (you can configure multiple storage providers in rclone). Please make a separate Backup of ```ENCFS_PASSWORD``` and ```ENCFS_CONFIG```, since you cannot access your offsite data without these. These both files will be automatically created on the first run of the script.

If you are running multiple backup jobs from the same machine the you can also specify a different configuration at runtime. The syntax is as followed:

```
BACKUP_CONFIG=config-test ./rclone-encfs-wrapper.sh
```
