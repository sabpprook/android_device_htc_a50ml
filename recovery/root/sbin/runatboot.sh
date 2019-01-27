#!/sbin/sh

bootmid=$(getprop ro.boot.mid)
bootcid=$(getprop ro.boot.cid)

case $bootmid in
    "0PGZ12000")
        resetprop ro.build.product "htc_a50ml"
        resetprop ro.product.device "htc_a50ml"
        ;;
    *)
        resetprop ro.build.product "htc_a50ml"
        resetprop ro.product.device "htc_a50ml"
        ;;
esac

exit 0
