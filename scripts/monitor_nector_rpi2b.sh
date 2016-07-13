#!/bin/bash

echo 'basic monitoring test ...'
user=$1

# Start content
content="{\"user\":\"$user\",\"datapoints\":["
# Mac address as an id
mac=`cat /sys/class/net/*/address | head -n 1`

# Actual content for one device
ts=`date +"%s"`
#content="$content{\"devID\":\"$mac\",\"ts\":$ts,\"metadata\":{"
content="$content{\"id\":\"$mac\",\"ts\":$ts,"

# Get hostname
hostname=`hostname` 2> /dev/null
if [ -n "$hostname" ]; then
  content="$content\"hostname\":\"$hostname\","
fi

# Mac
content="$content\"mac\":\"$mac\","

# device type
content="$content\"devicetype\":\"raspberrypi3B\","

# Serial
serialno="$(cat /proc/cpuinfo | grep Serial | cut -d ':' -f 2)"
if [ -n "$serialno" ]; then
  content="$content\"serialno\":\"$serialno\","
fi

# IP address
ip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
if [ -n "$ip" ]; then
  content="$content\"ipaddress\":\"$ip\","
fi

# Firmware version
firmware=`/opt/vc/bin/vcgencmd version`
if [ -n "$firmware" ]; then
  content="$content\"version\":\"$firmware\","
fi

# Get uptime
if [ -f "/proc/uptime" ]; then
  uptime=`cat /proc/uptime`
  uptime=${uptime%%.*}
else
  uptime=""
fi
if [ -n "$uptime" ]; then
  content="$content\"uptime\":$uptime,"
fi

content="$content\"MEM_total\":$(free|awk '/^Mem:/{print $2}'),"
content="$content\"MEM_used\":$(free|awk '/^Mem:/{print $3}'),"
content="$content\"MEM_free\":$(free|awk '/^Mem:/{print $4}'),"
content="$content\"MEM_shared\":$(free|awk '/^Mem:/{print $5}'),"
content="$content\"MEM_buffers\":$(free|awk '/^Mem:/{print $6}'),"
content="$content\"MEM_cached\":$(free|awk '/^Mem:/{print $7}'),"

cpu_data=`vmstat -n 1 2 | tail -1`
cpu_user=`echo $cpu_data | awk '{ print $13 }'`
cpu_system=`echo $cpu_data | awk '{ print $14 }'`
cpu_iowait=`echo $cpu_data | awk '{ print $16 }'`
cpu_idle=`echo $cpu_data | awk '{ print $15 }'`

content="$content\"CPU_user\":$cpu_user,"
content="$content\"CPU_system\":$cpu_system,"
content="$content\"CPU_iowait\":$cpu_iowait,"
content="$content\"CPU_idle\":$cpu_idle,"

# Ping time
ping_time=$(ping -c 1 8.8.8.8 | tail -1| awk '{print $4}' | cut -d '/' -f 2)
if [ -n "$ping_time" ]; then
  content="$content\"NETWORK_error\":0,"
  content="$content\"NETWORK_pingtime\":$ping_time,"
else
  content="$content\"NETWORK_error\":1,"
fi

volt=`vcgencmd measure_volts core | sed "s/^volt=//" | sed "s/V$//"`
content="$content\"VOLT_core\":$volt,"
volt=`vcgencmd measure_volts sdram_c | sed "s/^volt=//" | sed "s/V$//"`
content="$content\"VOLT_sdram_c\":$volt,"
volt=`vcgencmd measure_volts sdram_i | sed "s/^volt=//" | sed "s/V$//"`
content="$content\"VOLT_sdram_i\":$volt,"
volt=`vcgencmd measure_volts sdram_p | sed "s/^volt=//" | sed "s/V$//"`
content="$content\"VOLT_sdram_p\":$volt,"

disk=`df -m "/" | awk '!/Filesystem/ { print $2 }'`
content="$content\"DISK_size\":$disk,"
disk=`df -m "/" | awk '!/Filesystem/ { print $3 }'`
content="$content\"DISK_used\":$disk,"
disk=`df -m "/" | awk '!/Filesystem/ { print $4 }'`
content="$content\"DISK_available\":$disk,"
disk=`df -m "/" | awk '!/Filesystem/ { print $5 }' | head -c-2`
content="$content\"DISK_percent\":$disk,"

process=`ps -ef | grep -v 'PID' | wc -l`
content="$content\"PROCESS_count\":$process,"

temp=`cat /sys/class/thermal/thermal_zone0/temp`
content="$content\"temperature\":$((temp/1000)),"

#upgrade
upgrade=`apt-get --simulate upgrade | grep "newly installed," | tail -1 | awk '{print $1}'`
content="$content\"upgrade\":$upgrade,"

#GPU mem
gpumem=`vcgencmd get_mem gpu | cut -d "=" -f 2 | sed 's/\M//g'`
content="$content\"GPU_mem\":$gpumem,"

#GPIO
#0
echo "0" > /sys/class/gpio/export
sleep 0.5
GPIO0=$(cat /sys/class/gpio/gpio0/value)
GPIOdir0=$(cat /sys/class/gpio/gpio0/direction)
content="$content\"GPIOdir_0\":\"$GPIOdir0\","
content="$content\"GPIOvalue_0\":$GPIO0,"
echo "0" > /sys/class/gpio/unexport

#1
echo "1" > /sys/class/gpio/export
sleep 0.5
GPIO1=$(cat /sys/class/gpio/gpio1/value)
GPIOdir1=$(cat /sys/class/gpio/gpio1/direction)
content="$content\"GPIOdir_1\":\"$GPIOdir1\","
content="$content\"GPIOvalue_1\":$GPIO1,"
echo "1" > /sys/class/gpio/unexport

#4
echo "4" > /sys/class/gpio/export
sleep 0.5
GPIO4=$(cat /sys/class/gpio/gpio4/value)
GPIOdir4=$(cat /sys/class/gpio/gpio4/direction)
content="$content\"GPIOdir_4\":\"$GPIOdir4\","
content="$content\"GPIOvalue_4\":$GPIO4,"
echo "4" > /sys/class/gpio/unexport

#7
echo "7" > /sys/class/gpio/export
GPIO7=$(cat /sys/class/gpio/gpio7/value)
GPIOdir7=$(cat /sys/class/gpio/gpio7/direction)
content="$content\"GPIOdir_7\":\"$GPIOdir7\","
content="$content\"GPIOvalue_7\":$GPIO7,"
echo "7" > /sys/class/gpio/unexport

#8
echo "8" > /sys/class/gpio/export
sleep 0.5
GPIO8=$(cat /sys/class/gpio/gpio8/value)
GPIOdir8=$(cat /sys/class/gpio/gpio8/direction)
content="$content\"GPIOdir_8\":\"$GPIOdir8\","
content="$content\"GPIOvalue_8\":$GPIO8,"
echo "8" > /sys/class/gpio/unexport

#9
echo "9" > /sys/class/gpio/export
sleep 0.5
GPIO9=$(cat /sys/class/gpio/gpio9/value)
GPIOdir9=$(cat /sys/class/gpio/gpio9/direction)
content="$content\"GPIOdir_9\":\"$GPIOdir9\","
content="$content\"GPIOvalue_9\":$GPIO9,"
echo "9" > /sys/class/gpio/unexport

#10
echo "10" > /sys/class/gpio/export
sleep 0.5
GPIO10=$(cat /sys/class/gpio/gpio10/value)
GPIOdir10=$(cat /sys/class/gpio/gpio10/direction)
content="$content\"GPIOdir_10\":\"$GPIOdir10\","
content="$content\"GPIOvalue_10\":$GPIO10,"
echo "10" > /sys/class/gpio/unexport

#11
echo "11" > /sys/class/gpio/export
sleep 0.5
GPIO11=$(cat /sys/class/gpio/gpio11/value)
GPIOdir11=$(cat /sys/class/gpio/gpio11/direction)
content="$content\"GPIOdir_11\":\"$GPIOdir11\","
content="$content\"GPIOvalue_11\":$GPIO11,"
echo "11" > /sys/class/gpio/unexport

#14
echo "14" > /sys/class/gpio/export
sleep 0.5
GPIO14=$(cat /sys/class/gpio/gpio14/value)
GPIOdir14=$(cat /sys/class/gpio/gpio14/direction)
content="$content\"GPIOdir_14\":\"$GPIOdir14\","
content="$content\"GPIOvalue_14\":$GPIO14,"
echo "14" > /sys/class/gpio/unexport

#15
echo "15" > /sys/class/gpio/export
sleep 0.5
GPIO15=$(cat /sys/class/gpio/gpio15/value)
GPIOdir15=$(cat /sys/class/gpio/gpio15/direction)
content="$content\"GPIOdir_15\":\"$GPIOdir15\","
content="$content\"GPIOvalue_15\":$GPIO15,"
echo "15" > /sys/class/gpio/unexport

#17
echo "17" > /sys/class/gpio/export
sleep 0.5
GPIO17=$(cat /sys/class/gpio/gpio17/value)
GPIOdir17=$(cat /sys/class/gpio/gpio17/direction)
content="$content\"GPIOdir_17\":\"$GPIOdir17\","
content="$content\"GPIOvalue_17\":$GPIO17,"
echo "17" > /sys/class/gpio/unexport

#18
echo "18" > /sys/class/gpio/export
sleep 0.5
GPIO18=$(cat /sys/class/gpio/gpio18/value)
GPIOdir18=$(cat /sys/class/gpio/gpio18/direction)
content="$content\"GPIOdir_18\":\"$GPIOdir18\","
content="$content\"GPIOvalue_18\":$GPIO18,"
echo "18" > /sys/class/gpio/unexport

#21
echo "21" > /sys/class/gpio/export
sleep 0.5
GPIO21=$(cat /sys/class/gpio/gpio21/value)
GPIOdir21=$(cat /sys/class/gpio/gpio21/direction)
content="$content\"GPIOdir_21\":\"$GPIOdir21\","
content="$content\"GPIOvalue_21\":$GPIO21,"
echo "21" > /sys/class/gpio/unexport


#22
echo "22" > /sys/class/gpio/export
sleep 0.5
GPIO22=$(cat /sys/class/gpio/gpio22/value)
GPIOdir22=$(cat /sys/class/gpio/gpio22/direction)
content="$content\"GPIOdir_22\":\"$GPIOdir22\","
content="$content\"GPIOvalue_22\":$GPIO22,"
echo "22" > /sys/class/gpio/unexport

#23
echo "23" > /sys/class/gpio/export
sleep 0.5
GPIO23=$(cat /sys/class/gpio/gpio23/value)
GPIOdir23=$(cat /sys/class/gpio/gpio23/direction)
content="$content\"GPIOdir_23\":\"$GPIOdir23\","
content="$content\"GPIOvalue_23\":$GPIO23,"
echo "23" > /sys/class/gpio/unexport

#24
echo "24" > /sys/class/gpio/export
sleep 0.5
GPIO24=$(cat /sys/class/gpio/gpio24/value)
GPIOdir24=$(cat /sys/class/gpio/gpio24/direction)
content="$content\"GPIOdir_24\":\"$GPIOdir24\","
content="$content\"GPIOvalue_24\":$GPIO24,"
echo "24" > /sys/class/gpio/unexport

#25
echo "25" > /sys/class/gpio/export
sleep 0.5
GPIO25=$(cat /sys/class/gpio/gpio25/value)
GPIOdir25=$(cat /sys/class/gpio/gpio25/direction)
content="$content\"GPIOdir_25\":\"$GPIOdir25\","
content="$content\"GPIOvalue_25\":$GPIO25}"
echo "25" > /sys/class/gpio/unexport

# end content
content="$content]}"

echo -e $content

curl -i \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST --data "$content" "http://nectorc.ezako.com:8080/collector/"

exit 0
