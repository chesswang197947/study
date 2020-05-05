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

# 打印使用方法
print_usage()
{
  echo 'usage:'
  echo "  ${PROGRAM} <options>"
  echo ''
  echo 'options'
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

echo "========== $(date +'%Y-%m-%d %T%z') =========="
index=0
total=20
for loop in `seq 1 ${total}`;
do
    index=`expr $index + 1`
    echo "$index job is waiting for start"
    # 拿出令牌，进行并发操作
    read -u3 token  # read 命令每次读取一行，也就是拿到一个令牌
    {
        lindex=${index}
        lpercent=$(printf "%d%%" $((lindex*100/total)))
        echo ">>>>>>>>>> $(date +'%Y-%m-%d %T%z') thread(${token}) - ${lpercent}(${lindex}/${total}) >>>>>>>>>>"

        random=`expr $RANDOM % 10 + 1`
        echo "job ${index} sleep ${random} seconds"
        sleep ${random}
        echo "job ${index} return $?"

        echo "<<<<<<<<<< $(date +'%Y-%m-%d %T%z') thread(${token}) - ${lpercent}(${lindex}/${total}) <<<<<<<<<<"
        echo ${token} >&3  # 执行完毕将令牌放回管道
    }&
done

wait
echo "========== $(date +'%Y-%m-%d %T%z') =========="

exec 3<&-   # 关闭文件描述符的读
exec 3>&-   # 关闭文件描述符的写
