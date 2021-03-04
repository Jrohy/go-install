# go-install
![](https://img.shields.io/github/stars/Jrohy/go-install.svg)
![](https://img.shields.io/github/forks/Jrohy/go-install.svg) 
![](https://img.shields.io/github/license/Jrohy/go-install.svg)  
一键安装最新版golang, 国内vps使用[go镜像源](https://gomirrors.org/)下载并自动设置GOPROXY([goproxy.cn](https://goproxy.cn))

## 安装/更新 最新版golang
```
source <(curl -L https://go-install.netlify.app/install.sh)
```

## 安装/更新 指定版本golang
```
source <(curl -L https://go-install.netlify.app/install.sh) -v 1.13.5
``` 

## 强制更新golang
默认更新策略是已有版本和最新版本一样就不去更新, 要强制更新添加-f
```
source <(curl -L https://go-install.netlify.app/install.sh) -f
```