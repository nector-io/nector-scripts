# nector-scripts
Open source scripts for nector.io

Nector is a powerful condition monitoring tool. It generates dashboards to monitor anything.
Monitoring scripts are Open Source, as we are willing to share with the community and help you customize scripts and create monitoring for new devices.

##Raspberry Pi and raspbian compatible OS
We have developed a full Rasberry PI compatible service. Using the script will start monitoring your devices immediately.

##Other IOTs and devices
We are willing to get full compatibility to as many devices as possible. In order to make this real, feel free to contribute with your own scripts for a specific device.

##API description to monitor anything

This is a simple sample data of the api. It has to be sent using a HTTP POST at the following url:
POST http://nectorc.ezako.com:8080/collector/

```json
{
	"user":"my_account_id",
	"datapoints":[{
		"id":"b8:27:aa:aa:aa:aa",
		"ts":1468407233,
		"hostname":"raspberrypi",
		"mac":"b8:27:aa:aa:aa:aa",
		"devicetype":"raspberrypi3B",
		"serialno":" 0000000054b7c784",
		"ipaddress":"192.168.1.3",
		"uptime":765946,
		"CPU_user":0,
		"CPU_system":0,
		"CPU_iowait":0,
		"CPU_idle":100,
		"NETWORK_error":0,
		"NETWORK_pingtime":900
	}]
}```

