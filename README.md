# go-install
![](https://img.shields.io/github/stars/Jrohy/go-install.svg)
![](https://img.shields.io/github/forks/Jrohy/go-install.svg) 
![](https://img.shields.io/github/license/Jrohy/go-install.svg)  
一键安装最新版golang, 国内vps自动设置GOPROXY([goproxy.cn](https://goproxy.cn)), 支持linux和macOS系统

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

脚本会自动安装`goupdate`全局命令, 命令和上面的`source <(curl -L https://go-install.netlify.app/install.sh)`命令等价, 后面可以直接运行`goupdate`命令来更新即可
