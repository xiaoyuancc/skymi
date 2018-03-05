
./sepolicy-inject -s system_server -t rootfs -c system -p module_load -P sepolicy
./sepolicy-inject -s system_server -t app_data_file -c file -p open,read,write -P sepolicy
./sepolicy-inject -s system_server -t default_prop -c property_service -p set -P sepolicy
./sepolicy-inject -s system_server -t media_rw_data_file -c dir -p getattr -P sepolicy
./sepolicy-inject -s shell -t rootfs -c file -p getattr -P sepolicy

./sepolicy-inject -s fsck -t block_device -c blk_file -p getattr,open,read,write,ioctl -P sepolicy
./sepolicy-inject -s init -t debugfs_trace_marker -c file -p getattr -P sepolicy
./sepolicy-inject -s rmt_storage -t debugfs -c file -p open,read,write -P sepolicy
./sepolicy-inject -s miui_init_shell -t rootfs -c lnk_file -p getattr -P sepolicy
./sepolicy-inject -s miui_init_shell -t rootfs -c dir -p open,read -P sepolicy
./sepolicy-inject -s smcinvoke_daemon -t rootfs -c lnk_file -p getattr -P sepolicy
./sepolicy-inject -s fdpp -t rootfs -c lnk_file -p getattr -P sepolicy
./sepolicy-inject -s shelld -t rootfs -c lnk_file -p getattr -P sepolicy
./sepolicy-inject -s qvrd -t rootfs -c lnk_file -p getattr -P sepolicy
./sepolicy-inject -s mcd -t rootfs -c lnk_file -p getattr -P sepolicy
./sepolicy-inject -s mcd -t mcd -c capability -p sys_ptrace -P sepolicy

./sepolicy-inject -s time_daemon -t diag_device -c chr_file -p open,read,write,ioctl -P sepolicy
./sepolicy-inject -s dpmd -t diag_device -c chr_file -p open,read,write,ioctl -P sepolicy
./sepolicy-inject -s sensors -t diag_device -c chr_file -p open,read,write,ioctl -P sepolicy
./sepolicy-inject -s cnd -t diag_device -c chr_file -p open,read,write,ioctl -P sepolicy
./sepolicy-inject -s ipacm-diag -t diag_device -c chr_file -p open,read,write,ioctl -P sepolicy
./sepolicy-inject -s thermal-engine -t diag_device -c chr_file -p open,read,write,ioctl -P sepolicy
./sepolicy-inject -s surfaceflinger -t diag_device -c chr_file -p open,read,write,ioctl -P sepolicy
./sepolicy-inject -s priv_app -t priv_app -c udp_socket -p ioctl -P sepolicy

./sepolicy-inject -s nv_mac -t property_socket -c sock_file -p open,read,write -P sepolicy
./sepolicy-inject -s nv_mac -t init -c unix_stream_socket -p read,write,connectto -P sepolicy
./sepolicy-inject -s nv_mac -t default_prop -c property_service -p set -P sepolicy
./sepolicy-inject -s radio -t net_radio_prop -c property_service -p set -P sepolicy

./sepolicy-inject -s zygote -t mnt_expand_file -c dir -p getattr -P sepolicy
./sepolicy-inject -s qti_init_shell -t sysfs -c dir -p write -P sepolicy
./sepolicy-inject -s profman -t rootfs -c lnk_file -p getattr -P sepolicy





