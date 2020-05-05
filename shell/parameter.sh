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

# 打印使用方法
print_usage()
{
  echo 'usage:'
  echo "  ${PROGRAM} <options>"
  echo ''
  echo 'options'
  echo '  --bash'
  echo '      bash 命令位置 (default: /bin/bash)'
  echo ''
  echo '  -h, --help'
  echo '      display this help and exit.'
  echo '  -v, --version'
  echo '      output version information and exit.'
  echo ''
  echo 'e.g.'
  echo "./${PROGRAM} --bash /bin/sh"
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
echo "VERSION: ${VERSION}"
echo "BASH: ${BASH}"
echo ""
