#!/bin/bash
# vim:ts=2
# program: Using to creat a new img file, to mount a existed img file or to resize a exited img file
# made by: Engells
# date: Dec 20, 2011
# content:
#		注意本例使用 Dialog 取得各項變數，前述變數中「~」符號被視為單純字串, 不具有 bash 預設為使用者家目錄的內建變數之性質。
#		可能是 Dialog 輸出結果為字串，或後續用 awk 指令處理所造成。因此需特別處理或以完整目錄輸入替代「~」符號。

_creat_img()
{
dd if=/dev/zero of=$ImgDir/$ImgFile bs=512 count=$((${ImgSize:-1}*2048)) && \
mkfs.ext4 $ImgDir/$ImgFile
}

_mnt_img()
{
sudo mount -t ext4 -o loop $ImgDir/$ImgFile $MntDir && \
sudo chgrp -R $USER $MntDir && sudo chmod 777 $MntDir
}


# 由螢幕選擇操作方式
echo '選擇處理方式 c:增加映像檔 a:擴大映像檔 m:掛載映像檔 u:卸載映像檔'
read way

# 顯示所選擇之操作方式，並定義預設輸入值 $PreText
if [ -z $way ]; then
	echo '未輸入處理方式'
elif [ X"$way" = X"c" ]; then
	echo '處理方式: 增加映像檔 '
	PreText='-d:~ -f:aa.img -s:10 -m:~/mnt/usb'
elif [ X"$way" = X"a" ]; then 
	echo '處理方式: 擴大映像檔 '
	PreText='-d:~ -f:ab.img -s:5 -m:~/mnt/usb -o:aa.img'
elif [ X"$way" = X"m" ]; then 
	echo '處理方式: 掛載映像檔 '
	PreText='-d:~ -f:aa.img -m:~/mnt/usb'
elif [ X"$way" = X"u" ]; then 
	echo '處理方式: 卸載映像檔 '
	PreText='-m:~/mnt/usb'
else
	echo '錯誤,未定義之處理方式,2秒後跳出程式' && sleep 2 && exit 3
fi

sleep 1

DIA='/usr/bin/dialog'							# 標定dialog程式位置
TMP='/dev/shm/dialog.out.$$'			# 指定dialog輸入訊息之接收檔

# 設定 dialog 視窗的標題訊息
mTitile="請依序輸入 \n 映像檔目錄(-d:) 映像檔名(-f:) 映像檔大小(-s:)"
mTitile=$mTitile"\n 掛載點(-m:) 已存在映像檔名(-o:)"

# 執行 dialog 以取得各項參數
$DIA --inputbox "$mTitile" 10 75 "$PreText" 2> $TMP

# 若dialog輸入訊息為空值，以變數$PreText代入
InText=$( cat $TMP )
[ -z "$InText" ] && InText=$PreText

# 取得各項參數值
for i in $InText
do
	case $i in
		-d*) ImgDir0=$(echo $i | awk -F: '{ print $2 }') ;;
		-f*) ImgFile=$(echo $i | awk -F: '{ print $2 }') ;;
		-s*) ImgSize=$(echo $i | awk -F: '{ print $2 }') ;;
		-m*) MntDir0=$(echo $i | awk -F: '{ print $2 }') ;;
		-o*) OldImg=$(echo $i | awk -F: '{ print $2 }') ;;
	esac
done

# 處理映像檔所在目錄為家目錄項下，而且以~表示家目錄
if echo $ImgDir0 | grep '^~' > /dev/null ; then
	ImgDir0=$( echo $ImgDir0 | sed -n 's/~\///p' ) && ImgDir=~/$ImgDir0
else
	ImgDir=~/$ImgDir0
fi

# 處理掛載點為家目錄項下，而且以~表示家目錄
if echo $MntDir0 | grep '^~' > /dev/null ; then
	MntDir0=$( echo $MntDir0 | sed -n 's/~\///p' ) && MntDir=~/$MntDir0
else
	MntDir=~/$MntDir0
fi

unset ImgDir0 ; unset MntDir0


case $way in
	c)
		#依照輸入的目錄、檔名及掛載點，以dd產生映像檔，格式化映像檔，接著將映像檔掛載在掛載點

		if [ X${ImgDir-"-"} = X"-" -o X${ImgFile-"-"} = X"-" -o X${ImgSize-"-"} = X"-"  -o  X${MntDir-"-"} = X"-"  ] ;  then 

			echo '增加映像檔所需輸入之參數不足, 2秒後跳出程式' && sleep 2 && exit 4

		else

			if [ ! -e $ImgDir/$ImgFile ]; then

				_creat_img

			else

				echo $ImgDir/$ImgFile" 已存在, 直接進行掛載" 

			fi

			_mnt_img

		fi ;;

	a)
		#依照輸入的目錄、檔名及掛載點，以dd產生映像檔，cat新產生映像檔至原有映像檔，接著以resize2fs調整擴大後映像檔予以掛載

		if [ X${ImgDir-"-"} = X"-" -o X${ImgFile-"-"} = X"-" -o X${ImgSize-"-"} = X"-"  -o  X${MntDir-"-"} = X"-"  -o X${OldImg-"-"} = X"-" ] ;  then

			echo '擴大映像檔所需輸入之參數不足, 2秒後跳出程式' && sleep 2 && exit 5

		else

			if [ ! -e $ImgDir/$ImgFile -a -e $ImgDir/$OldImg ]; then

				dd if=/dev/zero of=$ImgDir/$ImgFile bs=512 count=$((${ImgSize:-1}*2048)) && \
				cat $ImgDir/$ImgFile >> $ImgDir/$OldImg && \
				resize2fs -F $ImgDir/$OldImg && \
				e2fsck -f $ImgDir/$OldImg && \
        sudo mount -t ext4 -o loop $ImgDir/$OldImg $MntDir
				#resize2fs -M $ImgDir/$OldImg

			else

				echo "$ImgDir/$ImgFile 已存在或 $ImgDir/$OldImg 不存在, 2秒後跳出程式" && sleep 2 && exit 5

			fi

		fi ;;

	m)
		#依照輸入的目錄、檔名及掛載點，將映像檔掛載在掛載點

		if [ X${ImgDir-"-"} != X"-" -a X${ImgFile-"-"} != X"-" -a X${MntDir-"-"} != X"-" ] && [ -e $ImgDir/$ImgFile -a -d $MntDir ];  then

			_mnt_img

		else

			echo '掛載映像檔所需輸入之參數不足, 或 $ImgDir/$ImgFile 或 $ImgDir/$OldImg 不存在, 2秒後跳出程式' && \
			sleep 2 && exit 6

		fi ;;

	u)
		#依照輸入掛載點，卸載映像檔

		if [ X${MntDir-"-"} != X"-" -a -d $MntDir ] ;  then

			sudo umount $MntDir

		else

			echo '卸載映像檔所需輸入之參數不足, 或指定之目錄不存在, 2秒後跳出程式' && sleep 2 && exit 7

		fi ;;

esac

rm -f "$TMP"

