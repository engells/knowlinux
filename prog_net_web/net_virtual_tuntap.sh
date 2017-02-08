#!/bin/bash
# vim:ts=4
# program: Using to add or remove visual bridge and nic devices
# made by: Engells
# date: Feb 7, 2013
# content: 以 br0 代替 eth0 進行對外連接，其餘的虛擬裝置則連接到 br0，如此架構出虛擬系統橋接模式。
#		注意，本例中 eth0 採用動態 IP，所以 br0 也必須採用動態 IP。


_add_br()
{
brctl addbr br0
ifconfig eth0 0.0.0.0 promisc
brctl addif br0 eth0
dhclient br0	# 若 eth0 為靜態 IP，此處改為 ifconfig br0 固定IP netmask Netmask_IP

if [ ${num} -gt 0 ] ; echo 'add tap devices' && then _add_tap ; fi

#chmod 666 /dev/net/tun	
}


_add_tap()
{
for ((i=0; i<${num}; i++))
do
	tunctl -t tap${num} -u ${user_name}
	brctl addif br0 tap${num}
	ifconfig tap${num} up
done
}


_del_br()
{
if [ ${num} -gt 0 ] ; echo 'del tap devices' && then _del_tap ; fi

brctl delif br0 eth0
ifconfig br0 down
brctl delbr br0	
ifconfig eth0 down
ifconfig eth0 up
dhclient eth0	# 若 eth0 為靜態 IP，此處改為 ifconfig eth0 固定IP netmask Netmask_IP
}


_del_tap()
{
for ((i=0; i<${num}; i++))
do
	brctl delif br0 tap${num}
	ifconfig tap${num} down
	tunctl -d tap${num}
done
}


#_setup_tun()
#{
#mkdir /dev/net
#mknod /dev/net/tun c 10 200		# 新增設備檔，該檔在 Ubuntu 10.04 已存在
#chmod 0666 /dev/net/tun
#modprobe tun
#echo "if [ -f /dev/net/tun ]; then	# 設定自動載入 tun 模組
#> modprobe tun >/dev/null 2>&1
#> fi" >>/etc/rc.d/rc.sysinit
#}


#-在螢幕輸出訊息，讓使用者輸入作業方式及虛擬網卡數量
Des="請輸入處理方式:"; printf "%s\n" "$Des"
Des="add x: 增加 1 個虛擬橋接器以及 x 個虛擬網卡，虛擬網卡都將接入虛擬橋接器"; printf "%s\n" "$Des"
Des="del x: 移除 1 個虛擬橋接器以及 x 個虛擬網卡"; printf "%s\n" "$Des"
read way

#-確認處理方式及虛擬網卡數量---------------
if [ -z "$way" ]; then
	echo '未選擇處理方式, 兩秒鐘後離開程式...' && sleep 2 && exit 1
else	
	num=$(echo $way | awk '{ print $2 }')
	#if [ ${num} -le 0 ] ; then echo "虛擬網卡數量必需大於 0" && exit 0 ; fi
fi

user_name=engells

case $way in
	add*)
		_add_br ;;
	del*)
		_del_br ;;
	*)
		echo '未定義之處理方式, 兩秒鐘後離開程式...' && sleep 2 && exit 2
esac

unset way; unset num; unset user_name

