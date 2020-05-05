#!/bin/bash

# History
# yyyy-mm-dd 初版做成
# 
# 依赖包
# sudo apt install xxxx xxxx
#

ARG0="$0"
PROGRAM="`basename $ARG0`"
VERSION="yyyy.mm.dd"

RETRY_MAX=3
BASH='/bin/bash'
LOCK_FILE=/tmp/${PROGRAM}.pid

# 日志输出定义
DATE_FORMAT="%Y-%m-%d %T%z"
LOG_NO_COLOR=FALSE
LOG_LEVEL_P=W,E
LOG_LEVEL_NONE=$((0x00))
LOG_LEVEL_ERROR=$((0x01))
LOG_LEVEL_WARNING=$((0x02))
LOG_LEVEL_DEBUG=$((0x04))
LOG_LEVEL_TRACE=$((0x08))
LOG_LEVEL_ALL=$((0xff))
LOG_LEVEL=${LOG_LEVEL_NONE} # log级别
LOG_LEVEL=$((${LOG_LEVEL} | ${LOG_LEVEL_ERROR})) # log级别
LOG_LEVEL=$((${LOG_LEVEL} | ${LOG_LEVEL_WARNING})) # log级别
#LOG_LEVEL=$((${LOG_LEVEL} | ${LOG_LEVEL_DEBUG})) # log级别
#LOG_LEVEL=$((${LOG_LEVEL} | ${LOG_LEVEL_TRACE})) # log级别
#LOG_LEVEL=$((${LOG_LEVEL} | ${LOG_LEVEL_ALL})) # log级别

# 错误信息
error()
{
  if [ $((${LOG_LEVEL} & ${LOG_LEVEL_ERROR})) -ne $((0x00)) ]; then
    if [ ${LOG_NO_COLOR} == TRUE ]; then
      echo -e "`date +\"$DATE_FORMAT\"` [E] $1"
    else
      echo -e "\033[31m`date +\"$DATE_FORMAT\"` [E] $1 \033[0m"
    fi
  fi
}
# 警告信息
warning()
{
  if [ $((${LOG_LEVEL} & ${LOG_LEVEL_WARNING})) -ne $((0x00)) ]; then
    if [ ${LOG_NO_COLOR} == TRUE ]; then
      echo -e "`date +\"$DATE_FORMAT\"` [W] $1"
    else
      echo -e "\033[35m`date +\"$DATE_FORMAT\"` [W] $1 \033[0m"
    fi
  fi
}
# 调试信息
debug()
{
  if [ $((${LOG_LEVEL} & ${LOG_LEVEL_DEBUG})) -ne $((0x00)) ]; then
    if [ ${LOG_NO_COLOR} == TRUE ]; then
      echo -e "`date +\"$DATE_FORMAT\"` [D] $1"
    else
      echo -e "\033[36m`date +\"$DATE_FORMAT\"` [D] $1 \033[0m"
    fi
  fi
}
# 跟踪
trace()
{
  if [ $((${LOG_LEVEL} & ${LOG_LEVEL_TRACE})) -ne $((0x00)) ]; then
    if [ ${LOG_NO_COLOR} == TRUE ]; then
      echo -e "`date +\"$DATE_FORMAT\"` [T] $1"
    else
      echo -e "\033[33m`date +\"$DATE_FORMAT\"` [T] $1 \033[0m"
    fi
  fi
}
# 信息
info()
{
  echo "`date +\"$DATE_FORMAT\"` [I] $1"
}

# 打印使用方法
print_usage()
{
  echo 'usage:'
  echo "  ${PROGRAM} <options>"
  echo ''
  echo 'options'
  echo '  --bash'
  echo '      bash 命令位置 (default: /bin/bash)'
  echo '  --retry'
  echo '      失败重试次数 (default: 3)'
  echo '  --log-level N,T,D,W,E,A'
  echo '      日志输出级别 (default: W,E)'
  echo '      N: none，T: trace，D: debug，W: warning，E: error，A: all'
  echo '  --no-color'
  echo '      日志输出不带颜色'
  echo ''
  echo '  -h, --help'
  echo '      display this help and exit.'
  echo '  -v, --version'
  echo '      output version information and exit.'
  echo ''
  echo 'e.g.'
  echo "./${PROGRAM} --bash /bin/sh --retry 5 --log-level T,D,W,E --no-color"
  return 0
}

# 打印版本信息
print_version()
{
  echo "${PROGRAM} version ${VERSION}"
  return 0
}

# $1 执行的命令
# $2 重试次数。默认是${RETRY_MAX}
# return 最后一次执行结果
function exec_retry() {
    local L_CMD=$1
    local L_RETRY_MAX=${RETRY_MAX}
    local L_RETRY=1
    local L_LAST_RESULT=0

    if [ ".$2" != "." ]; then
        L_RETRY_MAX=$2
    fi

    while (( ${L_RETRY} <= ${L_RETRY_MAX} )); do
        echo $L_CMD | ${BASH} -v
        L_LAST_RESULT=$?
        if [ ${L_LAST_RESULT} -eq 0 ]; then
            break
        fi
        error "Failed: ${L_LAST_RESULT} retry ${L_RETRY}/${L_RETRY_MAX}"
        L_RETRY=$(( L_RETRY + 1 ))
    done

    return ${L_LAST_RESULT}
}

#-------------------- main --------------------

# 解析输入参数
while [ ".$1" != . ]
do
  case "$1" in
    --bash )
      BASH=$2
      shift; shift;
      continue
    ;;
    --retry )
      RETRY_MAX=$2
      shift; shift;
      continue
    ;;
    --no-color )
      LOG_NO_COLOR=TRUE
      shift;
      continue
    ;;
    --log-level )
      LOG_LEVEL_P=$2
      LOG_LEVEL=${LOG_LEVEL_NONE}
      for _LOG_LEVEL_ in ${LOG_LEVEL_P//\,/ };
      do
        if [ ".${_LOG_LEVEL_}" == ".N" ]; then
          LOG_LEVEL=${LOG_LEVEL_NONE}
        elif [ ".${_LOG_LEVEL_}" == ".T" ]; then
          LOG_LEVEL=$((${LOG_LEVEL} | ${LOG_LEVEL_TRACE}))
        elif [ ".${_LOG_LEVEL_}" == ".D" ]; then
          LOG_LEVEL=$((${LOG_LEVEL} | ${LOG_LEVEL_DEBUG}))
        elif [ ".${_LOG_LEVEL_}" == ".W" ]; then
          LOG_LEVEL=$((${LOG_LEVEL} | ${LOG_LEVEL_WARNING}))
        elif [ ".${_LOG_LEVEL_}" == ".E" ]; then
          LOG_LEVEL=$((${LOG_LEVEL} | ${LOG_LEVEL_ERROR}))
        elif [ ".${_LOG_LEVEL_}" == ".A" ]; then
          LOG_LEVEL=$((${LOG_LEVEL} | ${LOG_LEVEL_ALL}))
        fi
      done
      shift; shift;
      continue
    ;;

    -h | --help ) # 使用方法
      print_usage
      exit 0
    ;;
    -v | --version ) # 版本
      print_version
      exit 0
    ;;
    * )
      echo "unknown param: $1"
      shift;
      continue
    ;;
  esac
done

# 单例判断
if [ -f ${LOCK_FILE} ]; then
    ps -ef | grep -v grep | grep ${PROGRAM} | grep `cat ${LOCK_FILE}` >> /dev/null
    if [ $? -eq 0 ]; then
        error "another ${PROGRAM} (pid `cat ${LOCK_FILE}`) is running."
        exit 1
    fi
fi
echo $$ > ${LOCK_FILE}

# for debug
debug "LOG_NO_COLOR: ${LOG_NO_COLOR}"
debug "LOG_LEVEL: ${LOG_LEVEL_P} => 0x`printf \"%x\" ${LOG_LEVEL}`"
debug "VERSION: ${VERSION}"
debug "RETRY_MAX: ${RETRY_MAX}"
debug "BASH: ${BASH}"
debug ""

# 创建命名管道
[ -e ./fd1 ] || mkfifo ./fd1
# 创建文件描述符，以可读(<)可写(>)方式关联管道文件，这时候文件描述符就有了命名管道文件的所有特性
exec 3<> ./fd1
# 关联后的文件描述符拥有管道文件的所有特性，所以这时候管道文件可以删除，留下文件描述符来用就可以了
rm -rf ./fd1

# 查询逻辑 CPU 个数
CPU_NUM=`cat /proc/cpuinfo | grep "processor" | wc -l`
# 创建令牌
for token in `seq 1 ${CPU_NUM}`;
do
    # echo 每次输出一个换行符，也就是一个令牌
    echo $token >&3
done

info "========== $(date +'%Y-%m-%d %T%z') =========="
index=0
total=20
for loop in `seq 1 ${total}`;
do
    index=`expr $index + 1`
    info "$index job is waiting for start"
    # 拿出令牌，进行并发操作
    read -u3 token  # read 命令每次读取一行，也就是拿到一个令牌
    {
        lindex=${index}
        lpercent=$(printf "%d%%" $((lindex*100/total)))
        info ">>>>>>>>>> $(date +'%Y-%m-%d %T%z') thread(${token}) - ${lpercent}(${lindex}/${total}) >>>>>>>>>>"

        random=`expr $RANDOM % 10 + 1`
        info "job ${index} sleep ${random} seconds"
        exec_retry "sleep ${random}" ${RETRY_MAX}
        info "job ${index} return $?"

        info "<<<<<<<<<< $(date +'%Y-%m-%d %T%z') thread(${token}) - ${lpercent}(${lindex}/${total}) <<<<<<<<<<"
        echo ${token} >&3  # 执行完毕将令牌放回管道
    }&
done

wait
info "========== $(date +'%Y-%m-%d %T%z') =========="

exec 3<&-   # 关闭文件描述符的读
exec 3>&-   # 关闭文件描述符的写

# 单例判断
if [ -f ${LOCK_FILE} ]; then
    rm -f ${LOCK_FILE}
fi

