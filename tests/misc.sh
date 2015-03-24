# $FreeBSD: src/tools/regression/fstest/tests/misc.sh,v 1.1 2007/01/17 01:42:08 pjd Exp $

ntest=1

name253="_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_12"
name255="${name253}34"
name256="${name255}5"
path1021="${name255}/${name255}/${name255}/${name253}"
path1023="${path1021}/x"
path1024="${path1023}x"

echo ${dir} | egrep '^/' >/dev/null 2>&1
if [ $? -eq 0 ]; then
	maindir="${dir}/../.."
else
	maindir="`pwd`/${dir}/../.."
fi
fstest="${maindir}/fstest"
. ${maindir}/tests/conf

run_getconf()
{
	if val=$(getconf "${1}" .); then
		if [ "$value" = "undefined" ]; then
			echo "${1} is undefined"
			exit 1
		fi
	else
		echo "Failed to get ${1}"
		exit 1
	fi

	echo $val
}

name_max_val=$(run_getconf NAME_MAX)
path_max_val=$(run_getconf PATH_MAX)

name_max="_"
i=1
while test $i -lt $name_max_val ; do 
	name_max="${name_max}x"
	i=$(($i+1))
done

num_of_dirs=$(( ($path_max_val + $name_max_val) / ($name_max_val + 1) - 1 ))

long_dir="${name_max}"
i=1
while test $i -lt $num_of_dirs ; do 
	long_dir="${long_dir}/${name_max}"
	i=$(($i+1))
done
long_dir="${long_dir}/x"

too_long="${long_dir}/${name_max}"

create_too_long()
{
	mkdir -p ${long_dir}
}

unlink_too_long()
{
	rm -rf ${name_max}
}

expect()
{
	e="${1}"
	shift
	r=`${fstest} $* 2>/dev/null | tail -1`
	echo "${r}" | egrep '^'${e}'$' >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "ok ${ntest}"
	else
		echo "not ok ${ntest}"
	fi
	ntest=`expr $ntest + 1`
}

jexpect()
{
	s="${1}"
	d="${2}"
	e="${3}"
	shift 3
	r=`jail -s ${s} / fstest 127.0.0.1 /bin/sh -c "cd ${d} && ${fstest} $* 2>/dev/null" | tail -1`
	echo "${r}" | egrep '^'${e}'$' >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "ok ${ntest}"
	else
		echo "not ok ${ntest}"
	fi
	ntest=`expr $ntest + 1`
}

test_check()
{
	if [ $* ]; then
		echo "ok ${ntest}"
	else
		echo "not ok ${ntest}"
	fi
	ntest=`expr $ntest + 1`
}

namegen()
{
	echo "fstest_`dd if=/dev/urandom bs=1k count=1 2>/dev/null | md5sum  | cut -f1 -d' '`"
}

quick_exit()
{
	echo "1..1"
	echo "ok 1"
	exit 0
}

supported()
{
	case "${1}" in
	chflags)
		if [ ${os} != "FreeBSD" -o ${fs} != "UFS" ]; then
			return 1
		fi
		;;
	lchmod)
		if [ ${os} != "FreeBSD" ]; then
			return 1
		fi
		;;
	esac
	return 0
}

require()
{
	if supported ${1}; then
		return
	fi
	quick_exit
}

# POSIX:
# {NAME_MAX}
#     Maximum number of bytes in a filename (not including terminating null).
namegen_max()
{
	echo ${name_max}
}

# POSIX:
# {PATH_MAX}
#     Maximum number of bytes in a pathname, including the terminating null character.
dirgen_max()
{
	echo ${too_long} | cut -b -$((path_max_val-1))
}

create_file() {
	type="${1}"
	name="${2}"

	case "${type}" in
	none)
		return
		;;
	regular)
		expect 0 create ${name} 0644
		;;
	dir)
		expect 0 mkdir ${name} 0755
		;;
	fifo)
		expect 0 mkfifo ${name} 0644
		;;
	block)
		expect 0 mknod ${name} b 0644 1 2
		;;
	char)
		expect 0 mknod ${name} c 0644 1 2
		;;
	socket)
		expect 0 bind ${name}
		;;
	symlink)
		expect 0 symlink test ${name}
		;;
	esac
	if [ -n "${3}" -a -n "${4}" -a -n "${5}" ]; then
		expect 0 lchmod ${name} ${3}
		expect 0 lchown ${name} ${4} ${5}
	elif [ -n "${3}" -a -n "${4}" ]; then
		expect 0 lchown ${name} ${3} ${4}
	elif [ -n "${3}" ]; then
		expect 0 lchmod ${name} ${3}
	fi
}
