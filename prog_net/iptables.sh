#!/bin/bash
#URL:http://www.ubuntu-tw.org/modules/newbb/viewtopic.php?topic_id=10836&viewmode=flat&order=ASC&type=&mode=0&start=0
#URL:#http://wiki.archlinux.org/index.php/Firewall

#我的防火牆設定
# 127.0.0.1 本地端回應全接受
iptables -P INPUT DROP
iptables -A INPUT -i lo -j ACCEPT

#針對 eth0 這張網卡，設定我主動發出去的回應都予放行
iptables -A INPUT -i eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

#針對 ppp0 (撥號連線)這張網卡，設定我主動發出去的回應都予放行
iptables -A INPUT -i ppp0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# 192.168.0.1~255 這個網段全放行
iptables -A INPUT -i eth0 -s 192.168.0.0/24 -j ACCEPT
iptables -A INPUT -i br0 -s 192.168.10.0/24 -j ACCEPT

#針對撥號連線 port 位 TCP 4662 & UDP 4672 (emule) 放行
iptables -A INPUT  -i ppp0 -p tcp --dport 4662 -j ACCEPT
iptables -A INPUT  -i ppp0 -p udp --dport 4672 -j ACCEPT

#針對撥號連線 port 位 TCP 51413 (BT) 放行
iptables -A INPUT  -i ppp0 -p tcp --dport 51413 -j ACCEPT

#建立捷徑，請下指令
#sudo ln -s /home/user/backup/iptables.sh /etc/init.d/iptables.sh

#設定成可執行的權限,/home/user 這個地方的"user"請更改成你的登入帳號名稱
#chmod 755 /home/user/backup/iptables.sh

#加入啟動項目，請下指令
#sudo update-rc.d -f iptables.sh defaults

#重開機後，請用指令檢查
#sudo iptables -L -n
