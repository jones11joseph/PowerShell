Powershell Commands :::

(Get-ChildItem -Path "C:\Users\senoj\Documents\Movies\Tulsa.King" | Sort-Object).BaseName >> tk.m3u

(Get-ChildItem -Path "C:\Users\senoj\Documents\Movies\Tulsa.King" | Sort-Object) | Select-Object -ExpandProperty FullName >> tk.m3u

Get-ChildItem 'C:\Users\senoj\Documents\Movies\Tulsa.King\' -filter *.mkv | rename-item -NewName {$_.name.substring(0,$_.BaseName.length-22) + $_.Extension -replace "_"," "}

Get-ChildItem 'C:\Users\senoj\Documents\Movies\FBI.S06\' -filter *.mkv | rename-item -NewName {$_.name.substring(0,$_.BaseName.length-25) + $_.Extension -replace "_"," "}

Get-ChildItem 'C:\Users\senoj\Documents\Movies\Blue Bloods S14' -filter *.mkv | rename-item -NewName {$_.name.substring(0,$_.BaseName.length-22) + $_.Extension -replace "_"," "}

Remove-Item 'C:\Users\senoj\Documents\Movies\*' -Recurse -Include *.nfo, *.txt, WWW.YTS.AG.jpg, WWW.YIFY-TORRENTS.COM.jpg, www.YTS.MX.jpg

Remove-Item 'C:\Users\senoj\Documents\Movies\*' -Recurse -Include *.nfo, *.txt, WWW.YTS.AG.jpg, WWW.YIFY-TORRENTS.COM.jpg, www.YTS.MX.jpg -Verbose


Linux Commands :::



find /var/www/html/downloads \( -name '*.txt' -o -name '*.nfo' -o -name 'www.YTS.MX.jpg' -o -name 'WWW.YIFY-TORRENTS.COM.jpg' -o -name 'WWW.YTS.AG.jpg' \) -type f -print

find /var/www/html/downloads \( -name '*.txt' -o -name '*.nfo' -o -name 'www.YTS.MX.jpg' -o -name 'WWW.YIFY-TORRENTS.COM.jpg' -o -name 'WWW.YTS.AG.jpg' \) -type f -delete
find /var/www/html/downloads/FBI.S07/  -mindepth 2 -type f -print -exec mv {} . \;


find /var/www/html/downloads/Tulsa.King  -type f \( -name '*.mkv' \) -printf "%P\n" | sort > playlist.m3u
sed -i "s|^|http://192.168.1.10/downloads/Tulsa.King/|" playlist.m3u



find /var/www/html/downloads/FBI.S06.COMPLETE.720p.AMZN.WEBRip.x264-GalaxyTV\[TGx\]  -type f \( -name '*.mkv' \) -printf "%P\n" | sort > fbi.m3u

find /var/www/html/downloads/FBI*  -type f \( -name '*.mkv' \) -printf "%P\n" | sort > fbi07.m3u

sed -i "s|^|http://192.168.1.10/downloads/FBI.S07/|" fbi07.m3u


















