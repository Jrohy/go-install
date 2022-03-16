#!/bin/bash
# Author: Jrohy
# Github: https://github.com/Jrohy/go-install

# cancel centos alias
[[ -f /etc/redhat-release ]] && unalias -a

INSTALL_VERSION=""

CAN_GOOGLE=1

FORCE_MODE=0

SUDO=""

OS="Linux"

PROXY_URL="https://goproxy.cn"

#######color code########
RED="31m"      
GREEN="32m"  
YELLOW="33m" 
BLUE="36m"
FUCHSIA="35m"

colorEcho(){
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

#######get params#########
while [[ $# > 0 ]];do
    KEY="$1"
    case $KEY in
        -v|--version)
        INSTALL_VERSION="$2"
        echo -e "准备安装$(colorEcho ${BLUE} $INSTALL_VERSION)版本golang..\n"
        shift
        ;;
        -f)
        FORCE_MODE=1
        echo -e "强制更新golang..\n"
        ;;
        *)
                # unknown option
        ;;
    esac
    shift # past argument or value
done
#############################

ipIsConnect(){
    ping -c2 -i0.3 -W1 $1 &>/dev/null
    if [ $? -eq 0 ];then
        return 0
    else
        return 1
    fi
}

setupEnv(){
    if [[ $SUDO == "" ]];then
        PROFILE_PATH="/etc/profile"
    elif [[ -e ~/.zshrc ]];then
        PROFILE_PATH="$HOME/.zprofile"
    fi
    if [[ $SUDO == "" && -z `echo $GOPATH` ]];then
        while :
        do
            read -p "默认GOPATH路径: `colorEcho $BLUE /home/go`, 回车直接使用或者输入自定义绝对路径: " GOPATH
            if [[ $GOPATH ]];then
                if [[ ${GOPATH:0:1} != "/" ]];then
                    colorEcho $YELLOW "请输入绝对路径!"
                    continue
                fi
            else
                GOPATH="/home/go"
            fi
            break
        done
        echo "GOPATH值为: `colorEcho $BLUE $GOPATH`"
        echo "export GOPATH=$GOPATH" >> $PROFILE_PATH
        echo 'export PATH=$PATH:$GOPATH/bin' >> $PROFILE_PATH
        mkdir -p $GOPATH
    fi
    if [[ -z `echo $PATH|grep /usr/local/go/bin` ]];then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> $PROFILE_PATH
    fi
    source $PROFILE_PATH
}

checkNetwork(){
    ipIsConnect "golang.org"
    [[ ! $? -eq 0 ]] && CAN_GOOGLE=0
}

setupProxy(){
    if [[ $CAN_GOOGLE == 0 && `go env|grep proxy.golang.org` ]]; then
        go env -w GO111MODULE=on
        go env -w GOPROXY=$PROXY_URL,direct
        colorEcho $GREEN "当前网络环境为国内环境, 成功设置goproxy代理!"
    fi
}

sysArch(){
    ARCH=$(uname -m)
    if [[ `uname -s` == "Darwin" ]];then
        OS="Darwin"
        if [[ "$ARCH" == "arm64" ]];then
            VDIS="darwin-arm64"
        else
            VDIS="darwin-amd64"
        fi
    else
        if [[ "$ARCH" == "i686" ]] || [[ "$ARCH" == "i386" ]]; then
            VDIS="linux-386"
        elif [[ "$ARCH" == *"armv7"* ]] || [[ "$ARCH" == "armv6l" ]]; then
            VDIS="linux-armv6l"
        elif [[ "$ARCH" == *"armv8"* ]] || [[ "$ARCH" == "aarch64" ]]; then
            VDIS="linux-arm64"
        elif [[ "$ARCH" == *"s390x"* ]]; then
            VDIS="linux-s390x"
        elif [[ "$ARCH" == "ppc64le" ]]; then
            VDIS="linux-ppc64le"
        elif [[ "$ARCH" == "x86_64" ]]; then
            VDIS="linux-amd64"
        fi
    fi
    [ $(id -u) != "0" ] && SUDO="sudo"
}

installGo(){
    if [[ -z $INSTALL_VERSION ]];then
        echo "正在获取最新版golang..."
        if [[ $CAN_GOOGLE == 0 ]];then
            INSTALL_VERSION=`curl -s https://golang.google.cn/dl/|grep -w downloadBox|grep src|grep -oE '[0-9]+\.[0-9]+\.?[0-9]*'|head -n 1`
        else
            INSTALL_VERSION=`curl -s https://github.com/golang/go/tags|grep releases/tag|grep -v rc|grep -v beta|grep -oE '[0-9]+\.[0-9]+\.?[0-9]*'|head -n 1`
        fi
        [[ ${INSTALL_VERSION: -1} == '.' ]] && INSTALL_VERSION=${INSTALL_VERSION%?}
        [[ -z $INSTALL_VERSION ]] && { colorEcho $YELLOW "\n获取go版本号失败!"; exit 1; }
        echo "最新版golang: `colorEcho $BLUE $INSTALL_VERSION`"
        if [[ $FORCE_MODE == 0 && `command -v go` ]];then
            if [[ `go version|awk '{print $3}'|grep -Eo "[0-9.]+"` == $INSTALL_VERSION ]];then
                return
            fi
        fi
    fi
    FILE_NAME="go${INSTALL_VERSION}.$VDIS.tar.gz"
    local TEMP_PATH=`mktemp -d`

    curl -H 'Cache-Control: no-cache' -L https://dl.google.com/go/$FILE_NAME -o $FILE_NAME
    tar -C $TEMP_PATH -xzf $FILE_NAME
    if [[ $? != 0 ]];then
        colorEcho $YELLOW "\n解压失败! 正在重新下载..."
        rm -rf $FILE_NAME
        curl -H 'Cache-Control: no-cache' -L https://dl.google.com/go/$FILE_NAME -o $FILE_NAME
        tar -C $TEMP_PATH -xzf $FILE_NAME
        [[ $? != 0 ]] && { colorEcho $YELLOW "\n解压失败!"; rm -rf $TEMP_PATH $FILE_NAME; exit 1; }

    fi
    [[ -e /usr/local/go ]] && $SUDO rm -rf /usr/local/go
    $SUDO mv $TEMP_PATH/go /usr/local/
    rm -rf $TEMP_PATH $FILE_NAME
}

installUpdater(){
    if [[ $OS == "Linux" && ! -e /usr/local/bin/goupdate ]];then
        echo "source <(curl -L https://go-install.netlify.app/install.sh)" > /usr/local/bin/goupdate
        chmod +x /usr/local/bin/goupdate
    elif [[ $OS == "Darwin" && ! -e $HOME/go/bin/goupdate ]];then
        cat > $HOME/go/bin/goupdate << EOF
#!/bin/zsh
source <(curl -L https://go-install.netlify.app/install.sh)
EOF
        chmod +x $HOME/go/bin/goupdate
    fi
}

main(){
    sysArch
    checkNetwork
    installGo
    setupEnv
    setupProxy
    installUpdater
    echo -e "golang `colorEcho $BLUE $INSTALL_VERSION` 安装成功!"
}

main