# vim:ts=4



手動以 Nautilus 連接
==============================
Nautilus → File → Connection to Server
	Server：www.box.net/dav
	Type：Secure WebDAV(HTTPS)
	Port：443
	User name：box_user_account
	Folder：/
		# 其意義為 box_user_account 在網路空間的根目錄，非在本機的根目錄




自動同步 Box.com 的資料 - 系統公用
==============================
安裝 davfs2
	sudo apt-get install davfs2

設定 davfs2 公用組態
	在 /etc/davfs2/davfs2.conf 加入「	use_locks 0」
		# 或 sudo echo "use_locks 0" >> /etc/davfs2/davfs2.conf
	在 /etc/davfs2/secrets 檔案尾端加入「https://www.box.com/dav box_user_account box_password」
		# 會將 /etc/fstab 的內容從 noauto 改成 auto reference:
		# 或 sudo echo "https://www.box.com/dav box_user_account box_password" >> /etc/davfs2/secrets

設定掛載 box.com WebDAV 空間
	mkdir /path/to/mount
	sudo mount -t davfs https://www.box.net/dav /mnt/box
		# 會提示輸入 box user account (full email) 和 password
	sudo umount /mnt/box

允許一般 User 身份掛載 box.com WebDAV 空間
	sudo chmod u+s /sbin/mount.davfs
	sudo usermod -G davfs -a linux_user_account

開機時自動掛載
	編輯 /etc/fstab，加入新的掛載點
		https://www.box.com/dav /path/to/mount davfs rw,user,noauto 0 0




自動同步 Box.com 的資料 - 特定用戶
==============================
將 linux_user_name 加入 davfs2 群組
	sudo adduser linux_user_name davfs2
	sudo chmod u+s /sbin/mount.davfs

建立組態檔
	mkdir ~/.davfs2
	cp /etc/davfs2/davfs2.conf ~/.davfs2
	sudo chown -R linux_user_account:linux_user_account ~/.davfs2
	echo "use_locks 0" >> ~/.davfs2/davfs2.conf
	在「ignore_home kernoops,distccd ...」行首加入註解符號 #
	移除「# secrets ~/.davfs2/secrets ...」行首的註解符號 #

編輯 ~/.davfs2/secrets
	touch ~/.davfs2/secrets
		# secrets 檔案不要接副檔名
	echo 'https://www.box.com/dav box_user_account "box_password" >> ~/.davfs2/secrets
		# 注意，登入 Box.Com 密碼前後要維持雙引號括住
	chmod 600 ~/.davfs2/secrets

開機時自動掛載
	編輯 /etc/fstab，加入新的掛載點
		https://www.box.com/dav /path/to/mount davfs rw,user,noauto 0 0

若未自動掛載於 nautilus
	建立 x 自動啟動項目
	Name：Mount Box.com
	Command：mount /path/to/mount

