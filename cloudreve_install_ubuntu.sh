#!/usr/bin/env bash

cloudreve_prefix=/usr/local/cloudreve
cloudreve_service=/usr/lib/systemd/system/cloudreve.service

if systemctl status cloudreve >/dev/null 2>&1; then
    echo "检测到CloudReve进程"
    systemctl stop cloudreve
    systemctl disable cloudreve
    systemctl daemon-reload
else echo "未检测到CloudReve进程"
fi

if [ -f "$cloudreve_service" ]; then
    echo "检测到CloudReve服务文件"
    rm -rf $cloudreve_service
else echo "未检测到CloudReve服务文件"
fi

if [ -d "$cloudreve_prefix" ]; then
    echo "检测到CloudReve安装目录"
    rm -rf $cloudreve_prefix
else
    echo '未检测到CloudReve安装目录'
fi

sudo apt install -y wget

# 下载安装
mkdir -p "$cloudreve_prefix"
wget -O "$cloudreve_prefix/cloudreve.tar.gz" https://github.com/cloudreve/Cloudreve/releases/download/3.8.3/cloudreve_3.8.3_linux_amd64.tar.gz
tar -zxf "$cloudreve_prefix/cloudreve.tar.gz" -C "$cloudreve_prefix" cloudreve
rm -rf "$cloudreve_prefix/cloudreve.tar.gz"
chmod +x "$cloudreve_prefix/cloudreve"

# 配置文件
cat >"$cloudreve_service" <<EOF
[Unit]
Description=Cloudreve
Documentation=https://docs.cloudreve.org
After=network.target
After=mysqld.service
Wants=network.target

[Service]
WorkingDirectory=$cloudreve_prefix
ExecStart=$cloudreve_prefix/cloudreve
Restart=on-abnormal
RestartSec=5s
KillMode=mixed

StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=cloudreve-log

[Install]
WantedBy=multi-user.target
EOF

# 更新配置
systemctl daemon-reload
# 设置开机启动
systemctl enable cloudreve
# 启动服务
systemctl restart cloudreve