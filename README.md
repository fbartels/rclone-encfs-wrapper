# rclone-encfs-wrapper
Wrapper script that uses an encfs reverse mount to encrypt before upload.

PLEASE NOTICE: EncFS is regarded as potentially unsecure, since an attacker that has multiple copies of the same scnrypted file might be able to calculate the encryption key. Please see https://defuse.ca/audits/encfs.htm for more information.
