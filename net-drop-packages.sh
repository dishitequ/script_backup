#!/bin/bash


loss_value="50%"

while_flag=1

#模拟对每个物理网卡增加20%的丢包率
function add_loss(){
	tc qdisc add dev enp62s0f1 root netem loss ${loss_value}
	tc qdisc add dev enp62s0f0 root netem loss  ${loss_value}
	tc qdisc add dev enp216s0f1 root netem loss  ${loss_value}
	tc qdisc add dev enp216s0f0 root netem loss  ${loss_value}
}

#将模拟的丢包率删除
function del_loss(){
	tc qdisc del dev enp62s0f1 root netem loss ${loss_value}
	tc qdisc del dev enp62s0f0 root netem loss ${loss_value}
	tc qdisc del dev enp216s0f1 root netem loss ${loss_value}
	tc qdisc del dev enp216s0f0 root netem loss ${loss_value}
}




add_loss
date_now=`date +"%Y-%m-%d %H:%M:%S"`
##记录开始时间
echo $date_now >> ${loss_value}_eth_log.log


ip_151=1
ip_152=1

while [ ${while_flag}  == 1 ]; do
	ip_151_flag=`ip a|grep 172.16.30.151|wc -l`
	ip_152_flag=`ip a|grep 172.16.30.152|wc -l`
	#记录152ip飘逸信息
	if [ ${ip_152_flag} == 0 -a ${ip_152} ==  1 ];then
		date +"%Y-%m-%d %H:%M:%S"  >> ${loss_value}_eth_log.log
		ip a|grep 172.16 >> ${loss_value}_eth_log.log
		ip_152=0
	fi 
	#记录151ip漂移信息
	if [ ${ip_151_flag} == 0 -a ${ip_151} == 1 ];then
		date +"%Y-%m-%d %H:%M:%S"  >> ${loss_value}_eth_log.log
		ip a|grep 172.16 >> ${loss_value}_eth_log.log
		p_151=0
	fi 

	#如果151和152的ip都没了，则记录时间，并退出循环
	if [ ${ip_151_flag} == 0 -a ${ip_152_flag} == 0 ];then
		date +"%Y-%m-%d %H:%M:%S"  >> ${loss_value}_eth_log.log
		ip a|grep 172.16 >> ${loss_value}_eth_log.log
		while_flag=0
		del_loss
	fi 
	echo "########################################" >> ${loss_value}_eth_log.log
	echo "########################################" >> ${loss_value}_eth_log.log
	echo "########################################" >> ${loss_value}_eth_log.log

done

