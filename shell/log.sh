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

BASH='/bin/bash'

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

# for debug
debug "LOG_NO_COLOR: ${LOG_NO_COLOR}"
debug "LOG_LEVEL: ${LOG_LEVEL_P} => 0x`printf \"%x\" ${LOG_LEVEL}`"
debug "VERSION: ${VERSION}"
debug "BASH: ${BASH}"
debug ""

info "This is a info message"
error "This is a error message"
warning "This is a warning message"
debug "This is a debug message"
trace "This is a trace message"
