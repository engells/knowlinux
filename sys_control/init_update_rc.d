# vim:ts=4


使用 update-rc.d 管理 Linux服務
==============================
在 Linux 系統下，服務的啟動、停止以及重啟通常是通過 /etc/init.d 目錄下的腳本來控制的。實務上，在啟動或改變運行級別時，是在 /etc/rcX.d 中來搜索腳本。其中 X 是運行級別的 number。

在 Debian 下安裝一個新的服務，比如 Apache2，安裝完成後，預設情況下它會在安裝後啟動，並在下一次開機時自動啟動。但如果不是一直需要這個服務，只在需要的時候啟用它，可以先禁用它。直到需要使用的時候，執行指令：/etc/init.d/apache2 start

要達成此機制，需先 /etc/rcX.d 目錄中刪除所有 apache2 的軟鏈結。但這個方法操作麻煩，且效率低下。因此，建議使用 update-rc.d 指令。


刪除服務
-------------------------

手動完全禁用 Apache2 服務，需刪除所有在 /etc/rcX.d 中的軟連結。

使用 update-rc.d，則非常簡單：
	update-rc.d -f apache2 remove
		# 參數 -f 是強制刪除符號鏈結，此指令移除 /etc/init.d/rc[1-6].d/*apache2* ，保留 /etc/init.d/apache2 檔案。

    update-rc.d apache2 stop 80 0 1 2 3 4 5 6 .
		# 此指令增加 /etc/init.d/rc[1-6].d/K80apache2 檔案，因此關機時會停用 apache2。


增加服務
-------------------------

添加服務並讓其開機自動執行
	update-rc.d apache2 defaults

指定該服務的啟動順序
	update-rc.d apache2 defaults 90

詳細控制 start 與 kill 順序
	update-rc.d apache2 defaults 20 80
		# 前面的 20 是 start 時的運行順序級別，80 為 kill 時的級別

    update-rc.d apache2 start 20 2 3 4 5 . stop 80 0 1 6 .
		# 另一種指令語法，效果與上述指令相同。 0 ~ 6 為運行級別。 

update-rc.d 命令不僅適用Linux服務，bash script 同樣可以用這個命令設為開機自動運行。具體參見《簡單高效的防火牆腳本》一文。


停用服務
-------------------------
sudo /etc/init.d/apache2 stop
sudo invoke-rc.d apache2 stop
sudo service apache2 stop

url: http://sys.firnow.com/linux/x8002010n06m/15s9087971.html
