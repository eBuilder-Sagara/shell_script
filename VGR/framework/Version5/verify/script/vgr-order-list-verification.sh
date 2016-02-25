#!/bin/bash
#
. ~/.bash_profile
#
base_root="/opt/mxib/scripts/verify"
#
#
cd $base_root
## Clear previousely created file.
rm $base_root/tmp/integration-missing-orders.txt
rm $base_root/tmp/integration-order-list-sorted.txt
rm $base_root/tmp/integration-order-list.txt
rm $base_root/tmp/vgr-db-order-list-sorted.txt
rm $base_root/tmp/vgr-db-order-list.txt
rm $base_root/tmp/xib-duplicate-order-list.txt
rm $base_root/output/vgr-check-orders.txt
#
touch $base_root/tmp/vgr-db-order-list.txt
#
##Load functions
##Integration order list function
#source /etc/profile
source $base_root/src/vgr-integration-order-list.sh
##VGR DB Order List function
source $base_root/sql/vgr-db-order-list.sh
source $base_root/src/vgr-db-access.txt
#
#
sleep 59
#
## Time range generate for VGR Order list.
current_hour=$(date +"%H")
#tm1=''
#tm2=''
ctm=$(date +"%Y%m%d%H%M%S")
echo $ctm >> $base_root/output/log.txt
#
if [ $current_hour -ge 6 -a $current_hour -le 18 ]
then
tm1=$(date --date='75 minute ago' +"%Y/%m/%d %H:%M:%S")
tm2=$(date --date='15 minute ago' +"%Y/%m/%d %H:%M:%S")
tm3="120"
tm4=$( echo $tm1" to "$tm2)
echo $tm1 >> $base_root/output/log.txt
echo $tm2 >> $base_root/output/log.txt
echo $tm3 >> $base_root/output/log.txt
echo $tm4 >> $base_root/output/log.txt
else
tm1=$(date --date='1455 minute ago' +"%Y/%m/%d %H:%M:%S")
tm2=$(date --date='15 minute ago' +"%Y/%m/%d %H:%M:%S")
tm3="1500"
tm4=$( echo $tm1" to "$tm2)
echo $tm1 >> $base_root/output/log.txt
echo $tm2 >> $base_root/output/log.txt
echo $tm3 >> $base_root/output/log.txt
echo $tm4 >> $base_root/output/log.txt
fi
#
#
##Call SQL method to create DB Order List
#VgrDBOrderList ( spool_file , start_time , end_time)
VgrDBOrderList $base_root/tmp/vgr-db-order-list.txt $tm1 $tm2
#VgrDBOrderList '2014/09/21 11:07:48' '2014/09/21 12:09:48'
#
## Get DB order count before duplicate handle
echo "DB order list created in  vgr-db-order-list.txt" >> $base_root/output/log.txt
#echo "Test - Do changes in  vgr-db-order-list.txt - To verify missing orders." >> $base_root/output/log.txt
#sleep 15
dbordercnt=$(cat $base_root/tmp/vgr-db-order-list.txt | wc -l)
echo "DB order count in  vgr-db-order-list.txt - $dbordercnt" >> $base_root/output/log.txt
#
##Call Integration Order List create method
CreateOrderIdList "$tm3"
#
## Get total order count before duplicate handle
echo "XIB order list created in integration-order-list.txt" >> $base_root/output/log.txt
echo "Do changes to integration-order-list.txt - To verify missing Orders: Delete | Duplicate" >> $base_root/output/log.txt
sleep 25
xibordercnt=$(cat $base_root/tmp/integration-order-list.txt | wc -l)
echo "XIB order count in  integration-order-list.txt - $xibordercnt" >> $base_root/output/log.txt
#
##Sort files
sort $base_root/tmp/vgr-db-order-list.txt | uniq -i > $base_root/tmp/vgr-db-order-list-sorted.txt
sort $base_root/tmp/integration-order-list.txt | uniq -i > $base_root/tmp/integration-order-list-sorted.txt
#
echo "XIB and DB order list sorted" >> $base_root/output/log.txt
#
## Sorted Order list counts
srtdbordercnt=$(cat $base_root/tmp/vgr-db-order-list-sorted.txt | wc -l)
echo "DB order count in  vgr-db-order-list-sorted.txt - $srtdbordercnt" >> $base_root/output/log.txt
srtxibordercnt=$(cat $base_root/tmp/integration-order-list-sorted.txt | wc -l)
echo "XIB order count in  integration-order-list-sorted.txt - $srtxibordercnt" >> $base_root/output/log.txt
#
##Check Duplicate Orders in XIB side
echo "XIB Order count before sort : $xibordercnt - XIB Order count after sort : $srtxibordercnt" >> $base_root/output/log.txt
intdupcnt=0
if [ $xibordercnt -gt $srtxibordercnt ]
then
#
echo "Duplicate Orders found at XIB" >> $base_root/output/log.txt
uniq -id $base_root/tmp/integration-order-list.txt > $base_root/tmp/xib-duplicate-order-list.txt
intdupcnt=$(expr $xibordercnt - $srtxibordercnt) 
## v3=$(expr $v1 + $v2 )
fi
#
echo "XIB duplicate Order count : $intdupcnt" >> $base_root/output/log.txt
#
#
echo "Testing - Change vgr-db-order-list-sorted.txt" >> $base_root/output/log.txt
#sleep 15
### List only the differed lines
### Check only the XIB missing Orders
diff -iBwa $base_root/tmp/vgr-db-order-list-sorted.txt $base_root/tmp/integration-order-list-sorted.txt | grep '<' | awk -F '<' '{print $2}' > $base_root/tmp/integration-missing-orders.txt
#
#
#Missing Orde Count
mis_cnt=$(cat $base_root/tmp/integration-missing-orders.txt | wc -l)
echo "XIB missing Order count $mis_cnt" >> $base_root/output/log.txt
if [ $mis_cnt -ge 1 ]
then
#Send alert mail
echo "VGR Order verification result !!!" > $base_root/output/vgr-missing-orders-at-$ctm.txt
echo "Time duration $tm4" >> $base_root/output/vgr-missing-orders-at-$ctm.txt
echo " " >> $base_root/output/vgr-missing-orders-at-$ctm.txt
echo "Integration Missing Orders Count - $mis_cnt" >> $base_root/output/vgr-missing-orders-at-$ctm.txt
echo " " >> $base_root/output/vgr-missing-orders-at-$ctm.txt
echo "Database Order count - $dbordercnt" >> $base_root/output/vgr-missing-orders-at-$ctm.txt
echo " " >> $base_root/output/vgr-missing-orders-at-$ctm.txt
if [ $intdupcnt -gt 0 ]
then
echo "DUPLICATE ORDER OUT DETECTED !!!" >> $base_root/output/vgr-missing-orders-at-$ctm.txt
echo "Duplicate Order count : $intdupcnt" >> $base_root/output/vgr-missing-orders-at-$ctm.txt
echo "Duplicated Order ID/s" >> $base_root/output/vgr-missing-orders-at-$ctm.txt
echo "----------------------------------------------" >> $base_root/output/vgr-missing-orders-at-$ctm.txt
cat $base_root/tmp/xib-duplicate-order-list.txt >> $base_root/output/vgr-missing-orders-at-$ctm.txt
fi
echo " " >> $base_root/output/vgr-missing-orders-at-$ctm.txt
echo "Integration Missing Order IDs list." >> $base_root/output/vgr-missing-orders-at-$ctm.txt
echo "----------------------------------------------" >> $base_root/output/vgr-missing-orders-at-$ctm.txt
cat $base_root/tmp/integration-missing-orders.txt >> $base_root/output/vgr-missing-orders-at-$ctm.txt
sleep 2
#mail -s "VGR Orders missing !!! - $ctm" procurement.2ndline.int@ebuilder.com procurement.2ndline.int@ebuilder.com < $base_root/output/vgr-missing-orders-at-$ctm.txt
mail -s "VGR Orders missing !!! - $ctm" sagara.jayathilaka@ebuilder.com < $base_root/output/vgr-missing-orders-at-$ctm.txt
#
else
#
echo "VGR Order verification result !!!" > $base_root/output/vgr-check-orders.txt
echo "Time duration $tm4" >> $base_root/output/vgr-check-orders.txt
echo " " >> $base_root/output/vgr-check-orders.txt
echo "Database Order count - $dbordercnt" >> $base_root/output/vgr-check-orders.txt
echo " " >> $base_root/output/vgr-check-orders.txt
if [ $dbordercnt -gt 0 ]
then
echo "All $dbordercnt received to the Integration successfully ...!!!" >> $base_root/output/vgr-check-orders.txt
fi
echo " " >> $base_root/output/vgr-check-orders.txt
if [ $intdupcnt -gt 0 ]
then
echo "DUPLICATE ORDER OUT DETECTED !!!" >> $base_root/output/vgr-check-orders.txt
echo " " >> $base_root/output/vgr-check-orders.txt
echo "Duplicate Order count : $intdupcnt" >> $base_root/output/vgr-check-orders.txt
echo "Duplicated Order ID/s" >> $base_root/output/vgr-check-orders.txt
echo "----------------------------------------------" >> $base_root/output/vgr-check-orders.txt
cat $base_root/tmp/xib-duplicate-order-list.txt >> $base_root/output/vgr-check-orders.txt
else
echo "Duplicates not detected within above time range" >> $base_root/output/vgr-check-orders.txt
fi
#
#mail -s "VGR Orders check !!! - $ctm" procurement.2ndline.int@ebuilder.com procurement.2ndline.int@ebuilder.com < $base_root/output/vgr-check-orders.txt
mail -s "VGR Orders check !!! - $ctm" sagara.jayathilaka@ebuilder.com < $base_root/output/vgr-check-orders.txt
#
fi
